"use client";

import { useEffect, useState } from "react";
import { API } from "@/config";
import Image from "next/image";

interface Employee {
  userId: number;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  departmentName: string;
  jobTitle: string;
  profileImage?: string | null;
  skills: string[];
}

export default function ManagerEmployeesPage() {
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [filtered, setFiltered] = useState<Employee[]>([]);
  const [search, setSearch] = useState("");

  useEffect(() => {
    fetchEmployees();
  }, []);

  const fetchEmployees = async () => {
    try {
      const res = await fetch(`${API}/manager/team`, {
        credentials: "include",
      });

      if (!res.ok) throw new Error("Failed to load employees");

      const data = await res.json();
      setEmployees(data);
      setFiltered(data);
    } catch (err) {
      console.error(err);
    }
  };

  const handleSearch = (value: string) => {
    setSearch(value);

    const lower = value.toLowerCase();

    const result = employees.filter((e) =>
      `${e.firstName} ${e.lastName}`.toLowerCase().includes(lower)
    );

    setFiltered(result);
  };

  return (
    <div className="p-8">
      <h1 className="text-3xl font-semibold mb-6">Team Overview</h1>

      {/* Search */}
      <div className="mb-6">
        <input
          type="text"
          placeholder="Search employees..."
          value={search}
          onChange={(e) => handleSearch(e.target.value)}
          className="w-full px-4 py-2 border rounded-lg shadow-sm"
        />
      </div>

      {/* Employees Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filtered.map((emp) => (
          <div
            key={emp.userId}
            className="border rounded-xl p-5 shadow hover:shadow-lg transition bg-white"
          >
            {/* Profile Image */}
            <div className="flex justify-center mb-4">
              {emp.profileImage ? (
                <Image
                  src={`data:image/png;base64,${emp.profileImage}`}
                  alt="profile"
                  width={80}
                  height={80}
                  className="rounded-full object-cover"
                />
              ) : (
                <div className="w-20 h-20 bg-gray-300 rounded-full" />
              )}
            </div>

            {/* Name */}
            <h2 className="text-xl font-semibold text-center">
              {emp.firstName} {emp.lastName}
            </h2>

            {/* Job Title */}
            <p className="text-center text-gray-600">{emp.jobTitle}</p>

            {/* Department */}
            <p className="text-center text-gray-500 text-sm">
              {emp.departmentName}
            </p>

            {/* Contact */}
            <div className="mt-4 text-sm">
              <p>
                <strong>Email:</strong> {emp.email}
              </p>
              <p>
                <strong>Phone:</strong> {emp.phone}
              </p>
            </div>

            {/* Skills */}
            <div className="mt-4">
              <strong>Skills:</strong>
              <div className="flex flex-wrap gap-2 mt-2">
                {emp.skills.map((s, idx) => (
                  <span
                    key={idx}
                    className="px-2 py-1 bg-blue-100 text-blue-700 rounded-md text-xs"
                  >
                    {s}
                  </span>
                ))}
              </div>
            </div>

            {/* View Profile Button */}
            <div className="mt-6">
              <button className="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition">
                View Profile
              </button>
            </div>
          </div>
        ))}
      </div>

      {filtered.length === 0 && (
        <p className="text-gray-500 text-center mt-10">No employees found.</p>
      )}
    </div>
  );
}
