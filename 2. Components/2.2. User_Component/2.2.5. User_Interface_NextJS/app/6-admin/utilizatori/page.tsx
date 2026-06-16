"use client";

import { useEffect, useState } from "react";
import { API } from "@/config";

interface User {
  userId: number;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  role: string;
  status: string;
  profileImage?: string | null;
}

export default function AdminUsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [filtered, setFiltered] = useState<User[]>([]);
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState("ALL");
  const [editing, setEditing] = useState<User | null>(null);

  useEffect(() => {
    loadUsers();
  }, []);

  const loadUsers = async () => {
    try {
      const res = await fetch(`${API}/admin/users`, {
        credentials: "include",
      });

      const data = await res.json();
      setUsers(data);
      setFiltered(data);
    } catch (err) {
      console.error(err);
    }
  };

  const handleSearch = (value: string) => {
    setSearch(value);

    const lower = value.toLowerCase();

    const result = users.filter((u) =>
      `${u.firstName} ${u.lastName}`.toLowerCase().includes(lower) ||
      u.email.toLowerCase().includes(lower)
    );

    setFiltered(result);
  };

  const handleRoleFilter = (role: string) => {
    setRoleFilter(role);

    if (role === "ALL") {
      setFiltered(users);
      return;
    }

    setFiltered(users.filter((u) => u.role === role));
  };

  const updateUser = async () => {
    if (!editing) return;

    try {
      const res = await fetch(`${API}/admin/users/${editing.userId}`, {
        method: "PUT",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(editing),
      });

      if (!res.ok) throw new Error("Failed to update user");

      setEditing(null);
      await loadUsers();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="p-8">
      <h1 className="text-3xl font-semibold mb-8">Users Management</h1>

      {/* Filters */}
      <div className="flex flex-col md:flex-row gap-4 mb-8">
        <input
          type="text"
          placeholder="Search by name or email..."
          value={search}
          onChange={(e) => handleSearch(e.target.value)}
          className="flex-1 px-4 py-2 border rounded-lg shadow-sm"
        />

        <select
          value={roleFilter}
          onChange={(e) => handleRoleFilter(e.target.value)}
          className="px-4 py-2 border rounded-lg shadow-sm"
        >
          <option value="ALL">All Roles</option>
          <option value="ADMIN">Admin</option>
          <option value="MANAGER">Manager</option>
          <option value="SPECIALIST_HR">HR Specialist</option>
          <option value="STUDENT">Student</option>
        </select>
      </div>

      {/* Users Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filtered.map((u) => (
          <div
            key={u.userId}
            className="border rounded-xl p-5 shadow hover:shadow-lg transition bg-white"
          >
            {/* Profile Image */}
            <div className="flex justify-center mb-4">
              {u.profileImage ? (
                <img
                  src={`data:image/png;base64,${u.profileImage}`}
                  alt="profile"
                  className="w-20 h-20 rounded-full object-cover"
                />
              ) : (
                <div className="w-20 h-20 bg-gray-300 rounded-full" />
              )}
            </div>

            {/* Name */}
            <h2 className="text-xl font-semibold text-center">
              {u.firstName} {u.lastName}
            </h2>

            {/* Role */}
            <p className="text-center text-gray-600">{u.role}</p>

            {/* Status */}
            <p className="text-center text-sm text-gray-500">
              Status: {u.status}
            </p>

            {/* Contact */}
            <div className="mt-4 text-sm">
              <p>
                <strong>Email:</strong> {u.email}
              </p>
              <p>
                <strong>Phone:</strong> {u.phone}
              </p>
            </div>

            {/* Edit Button */}
            <button
              onClick={() => setEditing(u)}
              className="mt-6 w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition"
            >
              Edit User
            </button>
          </div>
        ))}
      </div>

      {filtered.length === 0 && (
        <p className="text-gray-500 text-center mt-10">No users found.</p>
      )}

      {/* EDIT MODAL */}
      {editing && (
        <div className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center">
          <div className="bg-white p-8 rounded-xl w-[500px] shadow-xl">
            <h2 className="text-xl font-semibold mb-4">Edit User</h2>

            <div className="grid grid-cols-1 gap-3">
              <input
                name="firstName"
                value={editing.firstName}
                onChange={(e) =>
                  setEditing({ ...editing, firstName: e.target.value })
                }
                className="border px-3 py-2 rounded-lg"
              />

              <input
                name="lastName"
                value={editing.lastName}
                onChange={(e) =>
                  setEditing({ ...editing, lastName: e.target.value })
                }
                className="border px-3 py-2 rounded-lg"
              />

              <input
                name="email"
                value={editing.email}
                onChange={(e) =>
                  setEditing({ ...editing, email: e.target.value })
                }
                className="border px-3 py-2 rounded-lg"
              />

              <input
                name="phone"
                value={editing.phone}
                onChange={(e) =>
                  setEditing({ ...editing, phone: e.target.value })
                }
                className="border px-3 py-2 rounded-lg"
              />

              <select
                value={editing.role}
                onChange={(e) =>
                  setEditing({ ...editing, role: e.target.value })
                }
                className="border px-3 py-2 rounded-lg"
              >
                <option value="ADMIN">Admin</option>
                <option value="MANAGER">Manager</option>
                <option value="SPECIALIST_HR">HR Specialist</option>
                <option value="STUDENT">Student</option>
              </select>

              <select
                value={editing.status}
                onChange={(e) =>
                  setEditing({ ...editing, status: e.target.value })
                }
                className="border px-3 py-2 rounded-lg"
              >
                <option value="ACTIVE">Active</option>
                <option value="INACTIVE">Inactive</option>
                <option value="SUSPENDED">Suspended</option>
              </select>
            </div>

            <div className="flex justify-between mt-6">
              <button
                onClick={() => setEditing(null)}
                className="px-4 py-2 bg-gray-300 rounded-lg"
              >
                Cancel
              </button>

              <button
                onClick={updateUser}
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
