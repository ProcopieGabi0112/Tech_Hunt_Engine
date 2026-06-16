"use client";

import { useEffect, useState } from "react";
import { API } from "@/config";

type TechnologyType = {
  technologyTypeCode: number;
  name: string;
  rating: number;
};

type Technology = {
  technologyCode: number;
  name: string;
  rating: number;
  technologyTypeCode: number;
};

type Version = {
  versionCode: number;
  name: string;
  rating: number;
  technologyCode: number;
};

type Skill = {
  skillCode: number;
  name: string;
  rating: number;
};

type UserSkill = {
  skillCode: number;
  skillName: string;
  versionName: string;
  technologyName: string;
  technologyTypeName: string;
  proficiencyLevel: number;
  experienceMonths: number;
  lastUsedDate: string;
  confidenceScore?: number;
};

export default function TechnicalSkillsPage() {
  const [technologyTypes, setTechnologyTypes] = useState<TechnologyType[]>([]);
  const [technologies, setTechnologies] = useState<Technology[]>([]);
  const [versions, setVersions] = useState<Version[]>([]);
  const [skills, setSkills] = useState<Skill[]>([]);
  const [userSkills, setUserSkills] = useState<UserSkill[]>([]);

  const [selectedType, setSelectedType] = useState<string>("");
  const [selectedTechnology, setSelectedTechnology] = useState<string>("");
  const [selectedVersion, setSelectedVersion] = useState<string>("");
  const [selectedSkill, setSelectedSkill] = useState<string>("");

  const [proficiencyLevel, setProficiencyLevel] = useState<string>("");
  const [experienceMonths, setExperienceMonths] = useState<string>("");
  const [lastUsedDate, setLastUsedDate] = useState<string>("");
  const [confidenceScore, setConfidenceScore] = useState<string>("");

  const [showAddCard, setShowAddCard] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");
  const [highlightId, setHighlightId] = useState<number | null>(null);

  const today = new Date().toISOString().split("T")[0];

  useEffect(() => {
    if (errorMessage) {
      const t = setTimeout(() => setErrorMessage(""), 3500);
      return () => clearTimeout(t);
    }
  }, [errorMessage]);

  useEffect(() => {
    if (successMessage) {
      const t = setTimeout(() => setSuccessMessage(""), 2500);
      return () => clearTimeout(t);
    }
  }, [successMessage]);

  const loadUserSkills = () => {
    setLoading(true);
    fetch(`${API}/users/me/skills`, { credentials: "include" })
      .then((r) => r.json())
      .then((data) => setUserSkills(Array.isArray(data) ? data : []))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    const init = async () => {
      const r = await fetch(`${API}/users/me`, { credentials: "include" });

      if (r.ok) {
        loadUserSkills();
      } else {
        console.log("JWT not ready yet");
      }
    };

    init();
  }, []);

  // LOAD TECHNOLOGY TYPES
  useEffect(() => {
    fetch(`${API}/technology-types`)
      .then((r) => r.json())
      .then((data) => setTechnologyTypes(Array.isArray(data) ? data : []));
  }, []);

  // LOAD TECHNOLOGIES FOR TYPE
  useEffect(() => {
    const typeId = Number(selectedType);
    if (!typeId) {
      setTechnologies([]);
      return;
    }

    fetch(`${API}/technologies?type=${typeId}`)
      .then((r) => r.json())
      .then((data) => setTechnologies(Array.isArray(data) ? data : []))
      .catch(() => setTechnologies([]));
  }, [selectedType]);

  // LOAD VERSIONS FOR TECHNOLOGY
  useEffect(() => {
    const techId = Number(selectedTechnology);
    if (!techId) {
      setVersions([]);
      setSkills([]);
      return;
    }

    fetch(`${API}/versions?technology=${techId}`)
      .then((r) => r.json())
      .then((data) => setVersions(Array.isArray(data) ? data : []))
      .catch(() => setVersions([]));

    setSelectedVersion("");
    setSelectedSkill("");
    setSkills([]);
  }, [selectedTechnology]);

  // LOAD SKILLS FOR VERSION
  useEffect(() => {
    const versionId = Number(selectedVersion);
    if (!versionId) {
      setSkills([]);
      return;
    }

    fetch(`${API}/skills?version=${versionId}`)
      .then((r) => r.json())
      .then((data) => setSkills(Array.isArray(data) ? data : []))
      .catch(() => setSkills([]));
  }, [selectedVersion]);

  const addUserSkill = () => {
    if (!selectedType || !selectedTechnology || !selectedVersion || !selectedSkill) {
      setErrorMessage("Completează toate câmpurile.");
      return;
    }

    const payload = {
      skillCode: Number(selectedSkill),
      proficiencyLevel: Number(proficiencyLevel),
      experienceMonths: Number(experienceMonths),
      lastUsedDate,
      confidenceScore: confidenceScore ? Number(confidenceScore) : null,
    };

    setLoading(true);
    fetch(`${API}/users/me/skills`, {
      method: "POST",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    })
      .then(async (r) => {
        if (!r.ok) throw new Error("Add failed");
        const text = await r.text();
        return text ? JSON.parse(text) : null;
      })
      .then(() => {
        setSuccessMessage("Skill adăugat cu succes!");
        setShowAddCard(false);

        loadUserSkills();

        setTimeout(() => {
          setSelectedSkill("");
          setProficiencyLevel("");
          setExperienceMonths("");
          setLastUsedDate("");
          setConfidenceScore("");
        }, 3000);
      })
      .catch(() => setErrorMessage("Eroare la adăugare."))
      .finally(() => setLoading(false));
  };

  const updateUserSkill = (skillCode: number, field: any, value: string) => {
    const body: any = {};
    body[field] = field === "lastUsedDate" ? value : Number(value);

    fetch(`${API}/users/me/skills/${skillCode}`, {
      method: "PUT",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    })
      .then((r) => {
        if (r.status === 204) return null;
        return r.json().catch(() => null);
      })
      .then(() => {
        setHighlightId(skillCode);
        setTimeout(() => setHighlightId(null), 1000);
        loadUserSkills();
      });
  };

  const deleteUserSkill = (skillCode: number) => {
    if (!confirm("Ești sigur?")) return;

    fetch(`${API}/users/me/skills/${skillCode}`, {
      method: "DELETE",
      credentials: "include",
    }).then(() => loadUserSkills());
  };

  return (
    <main className="min-h-screen bg-gray-100 p-8 text-black">
      {loading && (
        <div className="w-full h-1 bg-blue-200 mb-4">
          <div className="h-full bg-blue-600" style={{ width: "100%" }} />
        </div>
      )}

      <div className="flex justify-between mb-6">
        <h1 className="text-3xl font-bold">Competențe Tehnice</h1>
        <button
          onClick={() => setShowAddCard(!showAddCard)}
          className="px-5 py-2 bg-blue-600 text-white rounded"
        >
          {showAddCard ? "Închide" : "Adaugă competență"}
        </button>
      </div>

      {errorMessage && (
        <div className="p-3 bg-red-100 text-red-700 mb-4">{errorMessage}</div>
      )}
      {successMessage && (
        <div className="p-3 bg-green-100 text-green-700 mb-4">
          {successMessage}
        </div>
      )}

      {/* TABEL USER SKILLS */}
      <section className="bg-white p-6 rounded shadow mb-8">
        <h2 className="text-xl font-semibold mb-4">Competențele tale</h2>

        {userSkills.length === 0 ? (
          <div className="text-gray-600 italic">
            Nu ai competențe adăugate.
          </div>
        ) : (
          <table className="w-full">
            <thead>
              <tr className="bg-gray-200">
                <th className="p-3">Type</th>
                <th className="p-3">Technology</th>
                <th className="p-3">Version</th>
                <th className="p-3">Skill</th>
                <th className="p-3">Proficiency</th>
                <th className="p-3">Experience</th>
                <th className="p-3">Last Used</th>
                <th className="p-3">Confidence</th>
                <th className="p-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              {userSkills.map((us) => (
                <tr
                  key={us.skillCode}
                  className={highlightId === us.skillCode ? "bg-green-100" : ""}
                >
                  <td className="p-3">{us.technologyTypeName}</td>
                  <td className="p-3">{us.technologyName}</td>
                  <td className="p-3">{us.versionName}</td>
                  <td className="p-3">{us.skillName}</td>

                  <td className="p-3">
                    <input
                      type="number"
                      value={us.proficiencyLevel}
                      onChange={(e) =>
                        updateUserSkill(
                          us.skillCode,
                          "proficiencyLevel",
                          e.target.value
                        )
                      }
                      className="border p-1 w-20"
                    />
                  </td>

                  <td className="p-3">
                    <input
                      type="number"
                      value={us.experienceMonths}
                      onChange={(e) =>
                        updateUserSkill(
                          us.skillCode,
                          "experienceMonths",
                          e.target.value
                        )
                      }
                      className="border p-1 w-20"
                    />
                  </td>

                  <td className="p-3">
                    <input
                      type="date"
                      value={us.lastUsedDate}
                      onChange={(e) =>
                        updateUserSkill(
                          us.skillCode,
                          "lastUsedDate",
                          e.target.value
                        )
                      }
                      className="border p-1"
                      max={today}
                    />
                  </td>

                  <td className="p-3">
                    <input
                      type="number"
                      value={us.confidenceScore ?? ""}
                      onChange={(e) =>
                        updateUserSkill(
                          us.skillCode,
                          "confidenceScore",
                          e.target.value
                        )
                      }
                      className="border p-1 w-20"
                    />
                  </td>

                  <td className="p-3">
                    <button
                      onClick={() => deleteUserSkill(us.skillCode)}
                      className="px-3 py-1 bg-red-600 text-white rounded"
                    >
                      🗑️
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>

      {/* CARD ADD SKILL */}
      {showAddCard && (
        <section className="bg-white p-6 rounded shadow">
          <h2 className="text-2xl font-bold mb-4">Adaugă competență</h2>

          <div className="space-y-4">
            <div>
              <label>Technology Type</label>
              <select
                value={selectedType}
                onChange={(e) => {
                  setSelectedType(e.target.value);
                  setSelectedTechnology("");
                  setSelectedVersion("");
                  setSelectedSkill("");
                  setTechnologies([]);
                  setVersions([]);
                  setSkills([]);
                }}
                className="w-full border p-2"
              >
                <option value="">Alege Technology Type</option>
                {technologyTypes.map((t) => (
                  <option
                    key={t.technologyTypeCode}
                    value={t.technologyTypeCode}
                  >
                    {t.name}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label>Technology</label>
              <select
                value={selectedTechnology}
                onChange={(e) => {
                  setSelectedTechnology(e.target.value);
                  setSelectedVersion("");
                  setSelectedSkill("");
                  setVersions([]);
                  setSkills([]);
                }}
                className="w-full border p-2"
                disabled={!selectedType}
              >
                <option value="">Alege Technology</option>
                {technologies.map((t) => (
                  <option key={t.technologyCode} value={t.technologyCode}>
                    {t.name}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label>Version</label>
              <select
                value={selectedVersion}
                onChange={(e) => {
                  setSelectedVersion(e.target.value);
                  setSelectedSkill("");
                  setSkills([]);
                }}
                className="w-full border p-2"
                disabled={!selectedTechnology}
              >
                <option value="">Alege Version</option>
                {versions.map((v) => (
                  <option key={v.versionCode} value={v.versionCode}>
                    {v.name}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label>Skill</label>
              <select
                value={selectedSkill}
                onChange={(e) => setSelectedSkill(e.target.value)}
                className="w-full border p-2"
                disabled={!selectedVersion}
              >
                <option value="">Alege Skill</option>
                {skills.map((s) => (
                  <option key={s.skillCode} value={s.skillCode}>
                    {s.name}
                  </option>
                ))}
              </select>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label>Proficiency</label>
                <input
                  type="number"
                  value={proficiencyLevel}
                  onChange={(e) => setProficiencyLevel(e.target.value)}
                  className="w-full border p-2"
                />
              </div>

              <div>
                <label>Experience Months</label>
                <input
                  type="number"
                  value={experienceMonths}
                  onChange={(e) => setExperienceMonths(e.target.value)}
                  className="w-full border p-2"
                />
              </div>

              <div>
                <label>Last Used</label>
                <input
                  type="date"
                  value={lastUsedDate}
                  onChange={(e) => setLastUsedDate(e.target.value)}
                  className="w-full border p-2"
                  max={today}
                />
              </div>

              <div>
                <label>Confidence</label>
                <input
                  type="number"
                  value={confidenceScore}
                  onChange={(e) => setConfidenceScore(e.target.value)}
                  className="w-full border p-2"
                />
              </div>
            </div>

            <button
              onClick={addUserSkill}
              className="px-5 py-2 bg-green-600 text-white rounded"
            >
              Adaugă
            </button>
          </div>
        </section>
      )}
    </main>
  );
}
