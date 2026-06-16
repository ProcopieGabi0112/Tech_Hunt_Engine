"use client";

import { useEffect, useState } from "react";
import { API } from "@/config";

interface Company {
  companyId: number;
  name: string;
  legalEntityIdentifier: string;
  tradeRegisterNumber: string;
  website: string;
  noEmployees: number;
  industryType: string;
  companyType: string;
  description: string;
}

export default function ManagerCompaniesPage() {
  const [companies, setCompanies] = useState<Company[]>([]);
  const [loading, setLoading] = useState(true);

  // FORM STATE
  const [form, setForm] = useState({
    name: "",
    legalEntityIdentifier: "",
    tradeRegisterNumber: "",
    website: "",
    noEmployees: "",
    industryType: "",
    companyType: "",
    description: "",
  });

  // EDIT STATE
  const [editing, setEditing] = useState<Company | null>(null);

  useEffect(() => {
    loadCompanies();
  }, []);

  const loadCompanies = async () => {
    try {
      const res = await fetch(`${API}/manager/companies`, {
        credentials: "include",
      });

      const data = await res.json();
      setCompanies(data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e: any) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const addCompany = async () => {
    try {
      const res = await fetch(`${API}/manager/companies`, {
        method: "POST",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });

      if (!res.ok) throw new Error("Failed to add company");

      await loadCompanies();

      setForm({
        name: "",
        legalEntityIdentifier: "",
        tradeRegisterNumber: "",
        website: "",
        noEmployees: "",
        industryType: "",
        companyType: "",
        description: "",
      });
    } catch (err) {
      console.error(err);
    }
  };

  const updateCompany = async () => {
    if (!editing) return;

    try {
      const res = await fetch(`${API}/manager/companies/${editing.companyId}`, {
        method: "PUT",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(editing),
      });

      if (!res.ok) throw new Error("Failed to update company");

      setEditing(null);
      await loadCompanies();
    } catch (err) {
      console.error(err);
    }
  };

  if (loading) return <p className="p-8">Loading...</p>;

  return (
    <div className="p-8">
      <h1 className="text-3xl font-semibold mb-8">Manage Your Companies</h1>

      {/* ADD COMPANY FORM */}
      <div className="border p-6 rounded-xl shadow mb-10 bg-white">
        <h2 className="text-xl font-semibold mb-4">Add New Company</h2>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {Object.keys(form).map((key) => (
            <input
              key={key}
              name={key}
              value={(form as any)[key]}
              onChange={handleChange}
              placeholder={key.replace(/([A-Z])/g, " $1")}
              className="border px-3 py-2 rounded-lg"
            />
          ))}
        </div>

        <button
          onClick={addCompany}
          className="mt-6 bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700"
        >
          Add Company
        </button>
      </div>

      {/* COMPANY LIST */}
      <h2 className="text-2xl font-semibold mb-4">Your Companies</h2>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {companies.map((c) => (
          <div
            key={c.companyId}
            className="border p-5 rounded-xl shadow bg-white"
          >
            <h3 className="text-xl font-semibold">{c.name}</h3>
            <p className="text-gray-600">{c.description}</p>

            <div className="mt-4 text-sm">
              <p>
                <strong>Industry:</strong> {c.industryType}
              </p>
              <p>
                <strong>Company Type:</strong> {c.companyType}
              </p>
              <p>
                <strong>Employees:</strong> {c.noEmployees}
              </p>
              <p>
                <strong>Website:</strong> {c.website}
              </p>
            </div>

            <button
              onClick={() => setEditing(c)}
              className="mt-4 w-full bg-gray-800 text-white py-2 rounded-lg hover:bg-black"
            >
              Edit
            </button>
          </div>
        ))}
      </div>

      {/* EDIT MODAL */}
      {editing && (
        <div className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center">
          <div className="bg-white p-8 rounded-xl w-[500px] shadow-xl">
            <h2 className="text-xl font-semibold mb-4">Edit Company</h2>

            <div className="grid grid-cols-1 gap-3">
              {Object.keys(editing).map((key) =>
                key === "companyId" ? null : (
                  <input
                    key={key}
                    name={key}
                    value={(editing as any)[key]}
                    onChange={(e) =>
                      setEditing({
                        ...editing,
                        [e.target.name]: e.target.value,
                      })
                    }
                    className="border px-3 py-2 rounded-lg"
                  />
                )
              )}
            </div>

            <div className="flex justify-between mt-6">
              <button
                onClick={() => setEditing(null)}
                className="px-4 py-2 bg-gray-300 rounded-lg"
              >
                Cancel
              </button>

              <button
                onClick={updateCompany}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
              >
                Save Changes
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
