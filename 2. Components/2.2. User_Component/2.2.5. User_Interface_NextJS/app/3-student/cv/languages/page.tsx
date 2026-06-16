"use client";

import { useEffect, useState } from "react";
import { API } from "@/config";

type Language = {
  langCode: number;
  name: string;
  isoCode: string;
  rating: number;
};

type LangLevel = {
  langLevelId: number;
  name: string;
  nivel: string;
  rating: number;
  validityPeriod: number;
};

type UserLanguage = {
  langLevelId: number;
  languageName: string;
  isoCode: string;
  certificationName: string;
  nivel: string;
  ratingLanguage: number;
  ratingCertification: number;
  validityPeriod: number;
  obtainedDate: string;
};

export default function LanguagesPage() {
  const [userLanguages, setUserLanguages] = useState<UserLanguage[]>([]);
  const [languages, setLanguages] = useState<Language[]>([]);
  const [langLevels, setLangLevels] = useState<LangLevel[]>([]);

  const [showAdd, setShowAdd] = useState(false);
  const [selectedLanguage, setSelectedLanguage] = useState("");
  const [selectedCertification, setSelectedCertification] = useState<number | null>(null);
  const [obtainedDate, setObtainedDate] = useState("");

  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");

  const [loading, setLoading] = useState(false);
  const [highlightId, setHighlightId] = useState<number | null>(null);

  const [sortField, setSortField] = useState<string | null>(null);
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("asc");

  const today = new Date().toISOString().split("T")[0];

  // Auto-clear messages
  useEffect(() => {
    if (errorMessage) {
      const timer = setTimeout(() => setErrorMessage(""), 3000);
      return () => clearTimeout(timer);
    }
    if (successMessage) {
      const timer = setTimeout(() => setSuccessMessage(""), 2000);
      return () => clearTimeout(timer);
    }
  }, [errorMessage, successMessage]);

  // Load user certifications
  const loadUserLanguages = () => {
    setLoading(true);
    fetch(`${API}/users/me/languages`, { credentials: "include" })
      .then((res) => res.json())
      .then((data) => setUserLanguages(data))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    loadUserLanguages();
  }, []);

  // Load languages
  useEffect(() => {
    fetch(`${API}/languages`)
      .then((res) => res.json())
      .then((data) => setLanguages(data));
  }, []);

  // Load certifications for selected language
  useEffect(() => {
    if (!selectedLanguage) return;

    fetch(`${API}/lang-levels?langCode=${selectedLanguage}`)
      .then((res) => res.json())
      .then((data) => setLangLevels(data));
  }, [selectedLanguage]);

  // Sorting logic
  const sortData = (field: string) => {
    let direction = sortDirection;

    if (sortField === field) {
      direction = sortDirection === "asc" ? "desc" : "asc";
      setSortDirection(direction);
    } else {
      setSortField(field);
      setSortDirection("asc");
      direction = "asc";
    }

    const sorted = [...userLanguages].sort((a, b) => {
      let valA: any = a[field as keyof UserLanguage];
      let valB: any = b[field as keyof UserLanguage];

      if (field === "obtainedDate") {
        return direction === "asc"
          ? new Date(valA).getTime() - new Date(valB).getTime()
          : new Date(valB).getTime() - new Date(valA).getTime();
      }

      if (typeof valA === "string") {
        return direction === "asc"
          ? valA.localeCompare(valB)
          : valB.localeCompare(valA);
      }

      return direction === "asc" ? valA - valB : valB - valA;
    });

    setUserLanguages(sorted);
  };

  // Add certification
  const addCertification = () => {
    if (!selectedCertification) {
      setErrorMessage("Te rog selectează certificarea.");
      return;
    }

    if (!obtainedDate) {
      setErrorMessage("Te rog selectează data obținerii.");
      return;
    }

    setLoading(true);

    fetch(`${API}/users/me/languages`, {
      method: "POST",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        langLevelId: selectedCertification,
        obtainedDate,
      }),
    })
      .then(() => {
        setShowAdd(false);
        setSelectedLanguage("");
        setSelectedCertification(null);
        setObtainedDate("");
        setSuccessMessage("Certificare adăugată!");
        loadUserLanguages();
      })
      .catch(() => {});
  };

  // Update certification date
  const updateCertificationDate = (langLevelId: number, date: string) => {
    setLoading(true);

    fetch(`${API}/users/me/languages/${langLevelId}`, {
      method: "PUT",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ obtainedDate: date }),
    })
      .then(() => {
        setSuccessMessage("Data actualizată!");
        setHighlightId(langLevelId);
        setTimeout(() => setHighlightId(null), 1000);
        loadUserLanguages();
      });
  };

  // Delete certification
  const deleteCertification = (langLevelId: number) => {
    if (!confirm("Ești sigur că vrei să ștergi această certificare?")) return;

    setLoading(true);

    fetch(`${API}/users/me/languages/${langLevelId}`, {
      method: "DELETE",
      credentials: "include",
    })
      .then(() => {
        setSuccessMessage("Certificare ștearsă!");
        loadUserLanguages();
      });
  };

  // --------------------------
  // UI SECTION
  // --------------------------

  return (
    <main className="min-h-screen bg-gray-100 text-black p-10">

      {loading && (
        <div className="w-full h-1 bg-blue-200 mb-4">
          <div className="h-full bg-blue-600 animate-pulse"></div>
        </div>
      )}

      <div className="flex items-center justify-between mb-10">
        <h1 className="text-3xl font-bold">Certificări lingvistice</h1>

        <button
          onClick={() => setShowAdd(!showAdd)}
          className="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold"
        >
          {showAdd ? "Închide" : "Adaugă certificare"}
        </button>
      </div>

      {successMessage && (
        <div className="mb-4 p-3 bg-green-100 text-green-700 rounded">
          {successMessage}
        </div>
      )}

      {/* TABEL CERTIFICĂRI */}
      <section className="bg-white shadow-md rounded-lg p-6 mb-12">
        <h2 className="text-xl font-semibold mb-4">Certificările tale</h2>

        {userLanguages.length === 0 ? (
          <div className="text-gray-600 italic">
            Nu ai adăugat încă nicio certificare lingvistică.
          </div>
        ) : (
          <table className="w-full mt-4 border-collapse">
            <thead>
              <tr className="bg-gray-200 text-left">
                <th className="p-3 cursor-pointer" onClick={() => sortData("languageName")}>
                  Limba ↑↓
                </th>
                <th className="p-3">ISO</th>
                <th className="p-3 cursor-pointer" onClick={() => sortData("certificationName")}>
                  Certificare ↑↓
                </th>
                <th className="p-3 cursor-pointer" onClick={() => sortData("nivel")}>
                  Nivel ↑↓
                </th>
                <th className="p-3 cursor-pointer" onClick={() => sortData("ratingLanguage")}>
                  Rating limbă ↑↓
                </th>
                <th className="p-3 cursor-pointer" onClick={() => sortData("ratingCertification")}>
                  Rating certificare ↑↓
                </th>
                <th className="p-3">Valabilitate</th>
                <th className="p-3 cursor-pointer" onClick={() => sortData("obtainedDate")}>
                  Data obținerii ↑↓
                </th>
                <th className="p-3">Acțiuni</th>
              </tr>
            </thead>

            <tbody>
              {userLanguages.map((ul) => (
                <tr
                  key={ul.langLevelId}
                  className={`border-b transition ${
                    highlightId === ul.langLevelId ? "bg-green-100" : ""
                  }`}
                >
                  <td className="p-3">{ul.languageName}</td>
                  <td className="p-3">{ul.isoCode}</td>
                  <td className="p-3">{ul.certificationName}</td>
                  <td className="p-3">{ul.nivel}</td>
                  <td className="p-3">{ul.ratingLanguage}</td>
                  <td className="p-3">{ul.ratingCertification}</td>
                  <td className="p-3">{ul.validityPeriod} luni</td>

                  <td className="p-3">
                    <input
                      type="date"
                      className="p-2 border rounded"
                      value={ul.obtainedDate}
                      max={today}
                      min="1900-01-01"
                      onChange={(e) =>
                        updateCertificationDate(ul.langLevelId, e.target.value)
                      }
                    />
                  </td>

                  <td className="p-3">
                    <button
                      onClick={() => deleteCertification(ul.langLevelId)}
                      className="px-3 py-1 bg-red-600 hover:bg-red-700 text-white rounded"
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

      {/* CARD ADD CERTIFICATION */}
      {showAdd && (
        <section className="bg-white shadow-lg rounded-lg p-8">

          <h2 className="text-2xl font-bold mb-6">Adaugă o certificare lingvistică</h2>

          {errorMessage && (
            <div className="mb-4 p-3 bg-red-100 text-red-700 rounded">
              {errorMessage}
            </div>
          )}

          {/* SELECT LANGUAGE */}
          <div className="mb-10">
            <h3 className="text-xl font-semibold mb-4">1. Selectează limba</h3>

            <select
              className="w-full p-3 border rounded-lg bg-gray-50"
              value={selectedLanguage}
              onChange={(e) => {
                setSelectedLanguage(e.target.value);
                setSelectedCertification(null);
                setObtainedDate("");
              }}
            >
              <option value="">Selectează limba</option>
              {languages.map((lang) => (
                <option key={lang.langCode} value={lang.langCode}>
                  {lang.name} ({lang.isoCode}) — Rating: {lang.rating}
                </option>
              ))}
            </select>
          </div>

          {/* SELECT CERTIFICATION */}
          {selectedLanguage && (
            <div>
              <h3 className="text-xl font-semibold mb-4">2. Selectează certificarea</h3>

              <div className="space-y-4">
                {langLevels.map((level) => (
                  <div
                    key={level.langLevelId}
                    className="p-4 border rounded-lg bg-gray-50 flex items-center justify-between"
                  >
                    <div>
                      <div className="font-semibold">{level.name}</div>
                      <div className="text-sm text-gray-600">
                        Nivel: {level.nivel} | Rating: {level.rating} | Valabilitate:{" "}
                        {level.validityPeriod} luni
                      </div>
                    </div>

                    <button
                      onClick={() => setSelectedCertification(level.langLevelId)}
                      className="px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg"
                    >
                      Selectează
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* SELECT DATE */}
          {selectedCertification && (
            <div className="mb-10 mt-10">
              <h3 className="text-xl font-semibold mb-4">3. Selectează data obținerii</h3>

              <input
                type="date"
                className="w-full p-3 border rounded-lg bg-gray-50"
                value={obtainedDate}
                max={today}
                min="1900-01-01"
                onChange={(e) => setObtainedDate(e.target.value)}
              />
            </div>
          )}

          {/* ADD BUTTON */}
          {selectedCertification && obtainedDate && (
            <button
              onClick={addCertification}
              className="px-6 py-3 bg-green-600 hover:bg-green-700 text-white rounded-lg font-semibold"
            >
              ➕ Adaugă certificarea
            </button>
          )}

        </section>
      )}
    </main>
  );
}
