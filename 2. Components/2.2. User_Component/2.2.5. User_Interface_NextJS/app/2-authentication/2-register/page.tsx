"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Image from "next/image";
import { API } from "@/config";

export default function RegisterPage() {
  const router = useRouter();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [dateOfBirth, setDateOfBirth] = useState("");
  const [gender, setGender] = useState("M");
  const [error, setError] = useState("");
  const [showPassword, setShowPassword] = useState(false);

  const isOver18 = (dob: string) => {
    const birth = new Date(dob);
    const today = new Date();

    const age =
      today.getFullYear() -
      birth.getFullYear() -
      (today.getMonth() < birth.getMonth() ||
      (today.getMonth() === birth.getMonth() &&
        today.getDate() < birth.getDate())
        ? 1
        : 0);

    return age >= 18;
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (!isOver18(dateOfBirth)) {
      setError("Trebuie să ai peste 18 ani ca să te înregistrezi în aplicație.");
      return;
    }

    try {
      const res = await fetch(`${API}/auth/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({
          email,
          password,
          firstName,
          lastName,
          dateOfBirth,
          gender,
          roleId: 1,
        }),
      });

      if (!res.ok) {
        setError("Înregistrarea a eșuat.");
        return;
      }

      router.push("/2-authentication/1-login_page");
    } catch (err) {
      console.error(err);
      setError("Eroare la înregistrare.");
    }
  };

  return (
    <main className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-100 via-pink-100 to-blue-100 px-6">
      <div className="bg-white shadow-xl rounded-2xl p-10 w-full max-w-md">

        <div className="flex justify-center mb-6">
          <Image src="/logo.svg" alt="Logo" width={120} height={120} unoptimized />
        </div>

        <h1 className="text-3xl font-bold text-center mb-6 text-gray-900">
          Creează un cont
        </h1>

        {error && (
          <p className="text-red-600 text-center font-medium mb-4">{error}</p>
        )}

        <form onSubmit={handleRegister} className="space-y-5">

          <div>
            <label className="block text-gray-700 font-medium mb-1">Prenume</label>
            <input
              type="text"
              className="w-full p-3 border rounded-xl text-black"
              value={firstName}
              onChange={(e) => setFirstName(e.target.value)}
              required
            />
          </div>

          <div>
            <label className="block text-gray-700 font-medium mb-1">Nume</label>
            <input
              type="text"
              className="w-full p-3 border rounded-xl text-black"
              value={lastName}
              onChange={(e) => setLastName(e.target.value)}
              required
            />
          </div>

          <div>
            <label className="block text-gray-700 font-medium mb-1">Email</label>
            <input
              type="email"
              className="w-full p-3 border rounded-xl text-black"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          {/* PASSWORD */}
          <div>
            <label className="block text-gray-700 font-medium mb-1">Parola</label>

            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                className="w-full p-3 border rounded-xl text-black"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />

              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-600 hover:text-black"
              >
                {showPassword ? "👁️‍🗨️" : "🔒"}
              </button>
            </div>
          </div>

          {/* DOB */}
          <div>
            <label className="block text-gray-700 font-medium mb-1">
              Data nașterii (yyyy-mm-dd)
            </label>
            <input
              type="date"
              className="w-full p-3 border rounded-xl text-black"
              value={dateOfBirth}
              onChange={(e) => setDateOfBirth(e.target.value)}
              required
            />
          </div>

          {/* GENDER */}
          <div>
            <label className="block text-gray-700 font-medium mb-1">Gen</label>
            <div className="flex gap-6">
              <label className="flex items-center gap-2 text-black">
                <input
                  type="radio"
                  name="gender"
                  value="M"
                  checked={gender === "M"}
                  onChange={() => setGender("M")}
                  className="accent-purple-600"
                />
                Male
              </label>

              <label className="flex items-center gap-2 text-black">
                <input
                  type="radio"
                  name="gender"
                  value="F"
                  checked={gender === "F"}
                  onChange={() => setGender("F")}
                  className="accent-purple-600"
                />
                Female
              </label>
            </div>
          </div>

          <button
            type="submit"
            className="w-full bg-purple-600 hover:bg-purple-700 text-white py-3 rounded-xl font-semibold"
          >
            Creează cont
          </button>

          <p className="text-center text-sm mt-4 text-black">
            Ai deja cont?{" "}
            <button
              type="button"
              onClick={() => router.push("/2-authentication/1-login_page")}
              className="text-purple-600 hover:underline"
            >
              Autentifică-te
            </button>
          </p>
        </form>
      </div>
    </main>
  );
}
