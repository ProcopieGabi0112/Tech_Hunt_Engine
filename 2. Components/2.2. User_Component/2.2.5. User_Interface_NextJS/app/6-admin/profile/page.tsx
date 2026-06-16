"use client";

import { useState, useEffect } from "react";
import { safeFetch } from "@/lib/safeFetch";
import Image from "next/image";
import { API } from "@/config";

export default function ProfilePage() {
  const [userName, setUserName] = useState("Utilizator");

  useEffect(() => {
    loadUserName();
  }, []);

  async function loadUserName() {
    const res = await safeFetch("/users/me");
    if (res.ok) {
      const data = await res.json();
      setUserName(`${data.firstName} ${data.lastName}`);
    }
  }

  return (
    <main className="min-h-screen bg-[#242428] p-10 text-black">
      <div className="max-w-4xl mx-auto space-y-10">

        <Header userName={userName} />
        <PersonalData />
        <AccountSettings />

      </div>
    </main>
  );
}

/* ----------------------------------------------------------
   HEADER
---------------------------------------------------------- */

function Header({ userName }: { userName: string }) {
  const [showModal, setShowModal] = useState(false);
  const [preview, setPreview] = useState<string | null>(null);

useEffect(() => {
  loadProfileImage();
}, []);

async function loadProfileImage() {
  try {
    const res = await fetch(`${API}/users/me/profile-image`, {
      method: "GET",
      credentials: "include",
    });

    if (res.ok) {
      const blob = await res.blob();
      setPreview(URL.createObjectURL(blob));
    } else {
      setPreview(null); // NU mai folosim default-avatar.png
    }
  } catch {
    setPreview(null); // fallback la inițiale
  }
}

  return (
    <>
      <div className="bg-[#F7F8FA] shadow-lg rounded-md p-10 flex items-center gap-8 border border-gray-200">

       <div
  className="relative w-28 h-28 rounded-full overflow-hidden group cursor-pointer border border-gray-300 bg-gray-200 flex items-center justify-center"
  onClick={() => setShowModal(true)}
>
  {preview ? (
    <Image
      src={preview}
      alt="Profile"
      fill
      sizes="112px"
      className="object-cover"
    />
  ) : (
    <span className="text-4xl font-bold text-gray-700">
      {userName
        ?.split(" ")
        .map((n) => n[0])
        .join("")
        .toUpperCase()}
    </span>
  )}

  <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 
flex items-center justify-center text-white font-medium transition text-center">
  Schimbă fotografia
</div>
</div>


        <div>
          <h1 className="text-3xl font-bold text-[#111]">{userName}</h1>
          <p className="text-gray-600 text-lg">Profilul meu</p>
          <p className="text-gray-500">Setări cont & informații personale</p>
        </div>
      </div>

      {showModal && (
        <UploadModal onClose={() => { setShowModal(false); loadProfileImage(); }} />
      )}
    </>
  );
}

/* ----------------------------------------------------------
   MODAL UPLOAD
---------------------------------------------------------- */

function UploadModal({ onClose }: { onClose: () => void }) {
  const [file, setFile] = useState<File | null>(null);

  function handleDrop(e: React.DragEvent) {
    e.preventDefault();
    const f = e.dataTransfer.files[0];
    if (f) setFile(f);
  }

  function handleSelectFile(e: React.ChangeEvent<HTMLInputElement>) {
    const f = e.target.files?.[0];
    if (f) setFile(f);
  }

  async function uploadImage() {
    if (!file) return;

    const formData = new FormData();
    formData.append("file", file);

    const res = await fetch(`${API}/users/me/profile-image`, {
      method: "POST",
      body: formData,
      credentials: "include",
    });

    if (res.ok) {
      window.dispatchEvent(new Event("profile-image-updated"));
      onClose();
    } else {
      alert("Eroare la încărcarea fotografiei.");
    }
  }

  return (
    <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50">
      <div
        className="bg-[#F7F8FA] border border-gray-300 p-8 rounded-md w-[400px] space-y-6 text-black shadow-2xl"
        onDragOver={(e) => e.preventDefault()}
        onDrop={handleDrop}
      >
        <h2 className="text-xl font-semibold">Încarcă fotografia de profil</h2>

        <div
          className="border border-gray-300 rounded-md p-10 text-center cursor-pointer bg-white"
          onClick={() => document.getElementById("fileInput")?.click()}
        >
          {file ? (
            <p className="text-green-600 font-medium">{file.name}</p>
          ) : (
            <p className="text-gray-600">
              Trage aici o poză sau apasă pentru a selecta
            </p>
          )}

          <input
            id="fileInput"
            type="file"
            accept="image/*"
            className="hidden"
            onChange={handleSelectFile}
          />
        </div>

        <div className="flex justify-end gap-4">
          <button
            onClick={onClose}
            className="px-4 py-2 bg-gray-200 rounded-md flex items-center gap-2"
          >
            <span>✖</span>
            <span>Anulează</span>
          </button>

          <button
            onClick={uploadImage}
            className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 transition shadow-sm flex items-center gap-2"
          >
            <span>⬆</span>
            <span>Salvează</span>
          </button>
        </div>
      </div>
    </div>
  );
}

/* ----------------------------------------------------------
   DATE PERSONALE
---------------------------------------------------------- */

function PersonalData() {
  const [editMode, setEditMode] = useState(false);

  const [profile, setProfile] = useState({
    firstName: "",
    lastName: "",
    email: "",
    dateOfBirth: "",
    phone: "",
    gender: "",
    nativeLangCode: "",
    locationId: "",
    supervizorId: "",
  });

  const [languages, setLanguages] = useState<any[]>([]);
  const [locations, setLocations] = useState<any[]>([]);
  const [supervisors, setSupervisors] = useState<any[]>([]);

  /* ------------------ FIX: toate funcțiile sunt definite ------------------ */

  async function loadProfile() {
    const res = await safeFetch("/users/me");
    if (res.ok) {
      const data = await res.json();
      setProfile({
        firstName: data.firstName,
        lastName: data.lastName,
        email: data.email,
        dateOfBirth: data.dateOfBirth || "",
        phone: data.phone || "",
        gender: data.gender || "",
        nativeLangCode: data.nativeLangCode || "",
        locationId: data.locationId || "",
        supervizorId: data.supervizorId || "",
      });
    }
  }

  async function loadLanguages() {
    const res = await safeFetch("/languages");
    if (res.ok) setLanguages(await res.json());
  }

  async function loadLocations() {
    const res = await safeFetch("/locations/all");
    if (res.ok) setLocations(await res.json());
  }

  async function loadSupervisors() {
    const res = await safeFetch("/users/supervisors");
    if (res.ok) {
      const all = await res.json();
      setSupervisors(all.filter((u: any) => u.role?.roleId === 2));
    }
  }

  /* ------------------ useEffect funcțional ------------------ */

  useEffect(() => {
    loadProfile();
    loadLanguages();
    loadLocations();
    loadSupervisors();
  }, []);

  /* ------------------ Salvare ------------------ */

  async function saveProfile() {
    const res = await safeFetch("/users/me", {
      method: "PUT",
      body: JSON.stringify(profile),
    });

    if (res.ok) {
      setEditMode(false);
      loadProfile();
    } else {
      alert("Eroare la salvarea datelor.");
    }
  }

  return (
    <section className="bg-[#F7F8FA] border border-gray-200 p-8 rounded-md shadow space-y-6">
      <h2 className="text-2xl font-semibold text-[#111]">Date personale</h2>

      {!editMode ? (
        <>
          <div className="grid grid-cols-2 gap-6 text-gray-700">
            <Field label="Prenume" value={profile.firstName} />
            <Field label="Nume" value={profile.lastName} />
            <Field label="Email" value={profile.email} />
            <Field label="Data nașterii" value={profile.dateOfBirth} />
            <Field label="Telefon" value={profile.phone} />
            <Field label="Gen" value={profile.gender} />
            <Field label="Limba nativă" value={profile.nativeLangCode} languages={languages} />
            <Field label="Supervizor" value={profile.supervizorId} supervisors={supervisors} />
            <Field label="Locație" value={profile.locationId} />
            
          </div>

          <button
            onClick={() => setEditMode(true)}
            className="px-6 py-3 bg-green-600 text-white rounded-md hover:bg-green-700 transition shadow-sm flex items-center gap-2"
          >
            <span>✏️</span>
            <span>Actualizează datele</span>
          </button>
        </>
      ) : (
        <>
          <div className="grid grid-cols-2 gap-6">
            <Input label="Prenume" value={profile.firstName} onChange={(v) => setProfile({ ...profile, firstName: v })} />
            <Input label="Nume" value={profile.lastName} onChange={(v) => setProfile({ ...profile, lastName: v })} />
            <Input label="Data nașterii" type="date" value={profile.dateOfBirth} onChange={(v) => setProfile({ ...profile, dateOfBirth: v })} />
            <Input label="Telefon" value={profile.phone} onChange={(v) => setProfile({ ...profile, phone: v })} />

            <Select label="Gen" value={profile.gender} onChange={(v) => setProfile({ ...profile, gender: v })}
              options={[{ value: "M", label: "Masculin" }, { value: "F", label: "Feminin" }]} />

            <Select label="Limba nativă" value={profile.nativeLangCode} onChange={(v) => setProfile({ ...profile, nativeLangCode: v })}
              options={languages.map((l) => ({ value: l.langCode, label: l.name }))} />

            <Select label="Locație" value={profile.locationId} onChange={(v) => setProfile({ ...profile, locationId: v })}
              options={locations.map((l) => ({
                value: l.locationId,
                label: `${l.streetName} ${l.streetNumber}, ${l.cityName}`,
              }))} />

            <Select label="Supervizor" value={profile.supervizorId} onChange={(v) => setProfile({ ...profile, supervizorId: v })}
              options={supervisors.map((s) => ({
                value: s.userId,
                label: `${s.firstName} ${s.lastName}`,
              }))} />
          </div>

          <div className="flex gap-4">
            <button
              onClick={saveProfile}
              className="px-6 py-3 bg-green-600 text-white rounded-md hover:bg-green-700 transition shadow-sm flex items-center gap-2"
            >
              <span>✔</span>
              <span>Salvează modificările</span>
            </button>

            <button
              onClick={() => setEditMode(false)}
              className="px-6 py-3 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 transition flex items-center gap-2"
            >
              <span>✖</span>
              <span>Anulează</span>
            </button>
          </div>
        </>
      )}
    </section>
  );
}

/* ----------------------------------------------------------
   CONFIGURATII CONT
---------------------------------------------------------- */

function AccountSettings() {
  return (
    <section className="bg-[#F7F8FA] border border-gray-200 p-8 rounded-md shadow space-y-10">
      <h2 className="text-2xl font-semibold text-[#111]">Configurații cont curent</h2>

      <ChangeEmail />
      <ChangePassword />
    </section>
  );
}

function ChangeEmail() {
  return (
    <div className="border border-gray-300 p-6 rounded-md space-y-4 bg-white">
      <h3 className="text-xl font-semibold text-[#111]">Schimbare email</h3>

      <Input label="Email nou" value="" onChange={() => {}} />
      <Input label="Confirmare email nou" value="" onChange={() => {}} />
      <Input label="Parola curentă" type="password" value="" onChange={() => {}} />

      <button className="px-6 py-3 bg-green-600 text-white rounded-md hover:bg-green-700 transition shadow-sm flex items-center gap-2">
        <span>📧</span>
        <span>Actualizează emailul</span>
      </button>
    </div>
  );
}

function ChangePassword() {
  return (
    <div className="border border-gray-300 p-6 rounded-md space-y-4 bg-white">
      <h3 className="text-xl font-semibold text-[#111]">Schimbare parolă</h3>

      <Input label="Parola veche" type="password" value="" onChange={() => {}} />
      <Input label="Parola nouă" type="password" value="" onChange={() => {}} />
      <Input label="Confirmare parolă nouă" type="password" value="" onChange={() => {}} />

      <button className="px-6 py-3 bg-green-600 text-white rounded-md hover:bg-green-700 transition shadow-sm flex items-center gap-2">
        <span>🔒</span>
        <span>Actualizează parola</span>
      </button>
    </div>
  );
}

/* ----------------------------------------------------------
   COMPONENTE MICI
---------------------------------------------------------- */

function Field({ label, value, languages, supervisors }: { 
  label: string; 
  value: any; 
  languages?: any[];
  supervisors?: any[];
}) {
  let displayValue = value;

  // GEN
  if (label === "Gen") {
    displayValue = value === "M" ? "Masculin" : value === "F" ? "Feminin" : "-";
  }

  // LIMBA NATIVĂ
  if (label === "Limba nativă" && languages) {
    const lang = languages.find((l) => l.langCode === value);
    displayValue = lang ? lang.name : "-";
  }

  // SUPERVIZOR
  if (label === "Supervizor" && supervisors) {
  const sup = supervisors.find((s) => s.userId === value);
  displayValue = sup ? `${sup.firstName} ${sup.lastName}` : "-";
}

  return (
    <div>
      <p className="text-sm text-gray-500">{label}</p>
      <p className="font-medium text-[#111]">{displayValue || "-"}</p>
    </div>
  );
}

function Input({
  label,
  value,
  onChange,
  type = "text",
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  type?: string;
}) {
  return (
    <div className="flex flex-col">
      <label className="text-sm font-medium mb-1 text-gray-700">{label}</label>
      <input
        type={type}
        className="p-3 border border-gray-300 rounded-md bg-white text-black focus:outline-none focus:ring-2 focus:ring-black/20"
        value={value}
        onChange={(e) => onChange(e.target.value)}
      />
    </div>
  );
}

function Select({
  label,
  value,
  onChange,
  options,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  options: { value: string | number; label: string }[];
}) {
  return (
    <div className="flex flex-col">
      <label className="text-sm font-medium mb-1 text-gray-700">{label}</label>
      <select
        className="p-3 border border-gray-300 rounded-md bg-white text-black focus:outline-none focus:ring-2 focus:ring-black/20"
        value={value}
        onChange={(e) => onChange(e.target.value)}
      >
        <option value="">Selectează...</option>
        {options.map((o, index) => (
          <option key={index} value={o.value}>
            {o.label}
          </option>
        ))}
      </select>
    </div>
  );
}
