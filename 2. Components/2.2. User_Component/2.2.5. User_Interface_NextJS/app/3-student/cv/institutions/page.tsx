"use client";

import { useState, useEffect } from "react";
import { safeFetch } from "@/lib/safeFetch";

type Region = { regionId: number; name: string; code: string };
type Country = { countryId: number; name: string; code: string };
type AdministrativeUnit = {
  administrativeUnitId: number;
  name: string;
  code: string;
  population: number;
  area: number;
  numberOfCities: number;
  description: string;
  administrativeUnitTypeId: number;
  administrativeUnitTypeName: string;
  countryId: number;
  label?: string;
};
type City = { cityCode: number; name: string };
type Location = {
  locationId: number;
  streetName: string;
  streetNumber: string;
  postalCode: string;
  building: string;
  staircase: string;
  floor: string;
  apartmentNumber: string;
  label?: string;
};
type Institution = { institutionId: number; name: string };
type Specialization = { specializationId: number; name: string };

type UserSpec = {
  specializationId: number;
  specializationName: string;
  institutionName: string;
  cityName: string;
  countryName: string;
  graduationDate?: string;
};

export default function InstitutionsPage() {
  const [mySpecs, setMySpecs] = useState<UserSpec[]>([]);
  const [showWizard, setShowWizard] = useState(false);

  const [regions, setRegions] = useState<Region[]>([]);
  const [countries, setCountries] = useState<Country[]>([]);
  const [units, setUnits] = useState<AdministrativeUnit[]>([]);
  const [cities, setCities] = useState<City[]>([]);
  const [locations, setLocations] = useState<Location[]>([]);
  const [institutions, setInstitutions] = useState<Institution[]>([]);
  const [specializations, setSpecializations] = useState<Specialization[]>([]);

  const [selectedRegion, setSelectedRegion] = useState("");
  const [selectedCountry, setSelectedCountry] = useState("");
  const [selectedUnit, setSelectedUnit] = useState("");
  const [selectedCity, setSelectedCity] = useState("");
  const [selectedLocation, setSelectedLocation] = useState("");
  const [selectedInstitution, setSelectedInstitution] = useState("");
  const [selectedSpecialization, setSelectedSpecialization] = useState("");

  const [graduationDate, setGraduationDate] = useState("");

  // LOAD INITIAL DATA
  useEffect(() => {
    loadMySpecs();

    safeFetch("/regions").then(async (res) => {
      if (res.ok) setRegions(await res.json());
    });
  }, []);

  async function loadMySpecs() {
    const res = await safeFetch("/users/me/specializations/view");
    if (res.ok) setMySpecs(await res.json());
  }

  // REGION → COUNTRIES
  useEffect(() => {
    if (!selectedRegion) return;

    safeFetch(`/countries?regionId=${selectedRegion}`).then(async (res) => {
      if (res.ok) setCountries(await res.json());
    });
  }, [selectedRegion]);

  // COUNTRY → ADMIN UNITS
  useEffect(() => {
    if (!selectedCountry) return;

    safeFetch(`/admin-units?countryId=${selectedCountry}`).then(async (res) => {
      if (res.ok) {
        const raw = await res.json();

        const withLabels = raw.map((u: AdministrativeUnit) => {
          const type =
            u.administrativeUnitTypeName.charAt(0).toUpperCase() +
            u.administrativeUnitTypeName.slice(1).toLowerCase();

          return {
            ...u,
            label: `${type} ${u.name}`,
          };
        });

        setUnits(withLabels);
      }
    });
  }, [selectedCountry]);

  // UNIT → CITIES
  useEffect(() => {
    if (!selectedUnit) return;

    safeFetch(`/cities?administrativeUnitId=${selectedUnit}`).then(async (res) => {
      if (res.ok) setCities(await res.json());
    });
  }, [selectedUnit]);

  // CITY → LOCATIONS
  useEffect(() => {
    if (!selectedCity) return;

    safeFetch(`/locations?cityCode=${selectedCity}`).then(async (res) => {
      if (res.ok) {
        const raw = await res.json();

        const withLabels = raw.map((l: Location) => {
          const parts = [];

          if (l.streetName) parts.push(l.streetName);
          if (l.streetNumber) parts.push(l.streetNumber);
          if (l.building) parts.push(`Bl. ${l.building}`);
          if (l.staircase) parts.push(`Sc. ${l.staircase}`);
          if (l.floor) parts.push(`Et. ${l.floor}`);
          if (l.apartmentNumber) parts.push(`Ap. ${l.apartmentNumber}`);
          if (l.postalCode) parts.push(`CP ${l.postalCode}`);

          return { ...l, label: parts.join(", ") };
        });

        setLocations(withLabels);
      }
    });
  }, [selectedCity]);

  // LOCATION → INSTITUTIONS
  useEffect(() => {
    if (!selectedLocation) return;

    safeFetch(`/institutions?locationId=${selectedLocation}`).then(async (res) => {
      if (res.ok) setInstitutions(await res.json());
    });
  }, [selectedLocation]);

  // INSTITUTION → SPECIALIZATIONS
  useEffect(() => {
    if (!selectedInstitution) return;

    safeFetch(`/specializations?institutionId=${selectedInstitution}`).then(async (res) => {
      if (res.ok) setSpecializations(await res.json());
    });
  }, [selectedInstitution]);

  // SAVE SPECIALIZATION
  async function saveSpecialization() {
    const body = {
      specializationId: Number(selectedSpecialization),
      graduationDate: graduationDate || null,
    };

    const res = await safeFetch("/users/me/specializations", {
      method: "POST",
      body: JSON.stringify(body),
    });

    if (res.ok) {
      setShowWizard(false);
      resetWizard();
      loadMySpecs();
    }
  }

  function resetWizard() {
    setSelectedRegion("");
    setSelectedCountry("");
    setSelectedUnit("");
    setSelectedCity("");
    setSelectedLocation("");
    setSelectedInstitution("");
    setSelectedSpecialization("");
    setGraduationDate("");
  }

  async function updateGraduationDate(specializationId: number, date: string) {
    const res = await safeFetch(`/users/me/specializations/${specializationId}`, {
      method: "PUT",
      body: JSON.stringify({ graduationDate: date }),
    });

    if (res.ok) loadMySpecs();
  }

  async function deleteSpecialization(specializationId: number) {
    const res = await safeFetch(`/users/me/specializations/${specializationId}`, {
      method: "DELETE",
    });

    if (res.ok) loadMySpecs();
  }

  return (
    <div className="min-h-screen bg-gray-100 p-8 space-y-10 text-black">

      {/* TABLE */}
      <section className="bg-white shadow-md rounded-lg p-6">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-3xl font-bold">Instituții & Specializări</h1>

          <button
            onClick={() => setShowWizard(true)}
            className="px-5 py-2.5 bg-blue-600 text-white rounded-lg shadow hover:bg-blue-700 transition"
          >
            Adaugă specializare
          </button>
        </div>

        <h2 className="text-xl font-semibold mb-4">Specializările tale</h2>

        {mySpecs.length === 0 ? (
          <div className="text-gray-600 italic">
            Nu ai adăugat încă nicio specializare.
          </div>
        ) : (
          <table className="w-full mt-4 border-collapse text-black">
            <thead>
              <tr className="bg-gray-200 text-left">
                <th className="p-3">Specializare</th>
                <th className="p-3">Instituție</th>
                <th className="p-3">Oraș</th>
                <th className="p-3">Țară</th>
                <th className="p-3">Graduation Date</th>
                <th className="p-3">Acțiuni</th>
              </tr>
            </thead>

            <tbody>
              {mySpecs.map((spec) => (
                <tr key={spec.specializationId} className="border-b">
                  <td className="p-3">{spec.specializationName}</td>
                  <td className="p-3">{spec.institutionName}</td>
                  <td className="p-3">{spec.cityName}</td>
                  <td className="p-3">{spec.countryName}</td>

                  <td className="p-3">
                    <input
                      type="date"
                      className="p-2 border rounded text-black bg-white"
                      value={spec.graduationDate || ""}
                      onChange={(e) =>
                        updateGraduationDate(spec.specializationId, e.target.value)
                      }
                    />
                  </td>

                  <td className="p-3">
                    <button
                      onClick={() => deleteSpecialization(spec.specializationId)}
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

      {/* WIZARD */}
      {showWizard && (
        <section className="bg-white shadow-lg rounded-lg p-8">
          <h2 className="text-2xl font-bold mb-6">Adaugă o specializare</h2>

          <div className="grid grid-cols-2 gap-6">
            <Select label="Regiune" value={selectedRegion} onChange={setSelectedRegion} items={regions} idField="regionId" nameField="name" />

            {selectedRegion && (
              <Select label="Țară" value={selectedCountry} onChange={setSelectedCountry} items={countries} idField="countryId" nameField="name" />
            )}

            {selectedCountry && (
              <Select
                label="Unitate administrativă"
                value={selectedUnit}
                onChange={setSelectedUnit}
                items={units}
                idField="administrativeUnitId"
                nameField="label"
              />
            )}

            {selectedUnit && (
              <Select label="Oraș" value={selectedCity} onChange={setSelectedCity} items={cities} idField="cityCode" nameField="name" />
            )}

            {selectedCity && (
              <Select
                label="Locație"
                value={selectedLocation}
                onChange={setSelectedLocation}
                items={locations}
                idField="locationId"
                nameField="label"
              />
            )}

            {selectedLocation && (
              <Select
                label="Instituție"
                value={selectedInstitution}
                onChange={setSelectedInstitution}
                items={institutions}
                idField="institutionId"
                nameField="name"
              />
            )}

            {selectedInstitution && (
              <Select
                label="Specializare"
                value={selectedSpecialization}
                onChange={setSelectedSpecialization}
                items={specializations}
                idField="specializationId"
                nameField="name"
              />
            )}
          </div>

          {selectedSpecialization && (
            <div className="mt-6">
              <label className="block text-sm font-medium mb-2">Graduation Date</label>
              <input
                type="date"
                className="p-3 border rounded bg-gray-50 text-black"
                value={graduationDate}
                onChange={(e) => setGraduationDate(e.target.value)}
              />
            </div>
          )}

          {selectedSpecialization && (
            <div className="flex gap-4 mt-6">
              <button
                onClick={saveSpecialization}
                className="px-5 py-2.5 bg-green-600 text-white rounded-lg shadow hover:bg-green-700 transition"
              >
                Salvează
              </button>

              <button
                onClick={() => {
                  setShowWizard(false);
                  resetWizard();
                }}
                className="px-5 py-2.5 bg-gray-300 rounded-lg hover:bg-gray-400 transition"
              >
                Anulează
              </button>
            </div>
          )}
        </section>
      )}
    </div>
  );
}

type SelectProps<T> = {
  label: string;
  value: string;
  onChange: (value: string) => void;
  items: T[];
  idField: keyof T;
  nameField: keyof T;
};

function Select<T>({ label, value, onChange, items, idField, nameField }: SelectProps<T>) {
  return (
    <div className="flex flex-col">
      <label className="text-sm font-medium mb-1">{label}</label>

      <select
        className="p-3 border rounded bg-gray-50 text-black"
        value={value}
        onChange={(e) => onChange(e.target.value)}
      >
        <option value="">Selectează...</option>

        {items.map((item) => (
          <option key={String(item[idField])} value={String(item[idField])}>
            {String(item[nameField])}
          </option>
        ))}
      </select>
    </div>
  );
}
