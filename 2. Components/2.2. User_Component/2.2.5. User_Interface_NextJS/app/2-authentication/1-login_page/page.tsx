"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Image from "next/image";
import { API } from "@/config";

export default function LoginPage() {
  const router = useRouter();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [remember, setRemember] = useState(false);
  const [error, setError] = useState("");
  const [showPassword, setShowPassword] = useState(false);

  // Load Remember Me email
  useEffect(() => {
    const savedEmail = localStorage.getItem("rememberEmail");
    if (savedEmail) {
      setEmail(savedEmail);
      setRemember(true);
    }
  }, []);

  // Normal login (email + password)
  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    try {
      const res = await fetch(`${API}/auth/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({ email, password }),
      });

      if (!res.ok) {
        setError("Email sau parolă greșită");
        return;
      }

      // Remember Me
      if (remember) {
        localStorage.setItem("rememberEmail", email);
      } else {
        localStorage.removeItem("rememberEmail");
      }

      // Așteptăm puțin ca browserul să aplice cookie-ul JWT
      await new Promise((resolve) => setTimeout(resolve, 50));

      // Fetch profile
      const profileRes = await fetch(`${API}/users/me`, {
        method: "GET",
        credentials: "include",
      });

      if (!profileRes.ok) {
        setError("Nu s-a putut încărca profilul");
        return;
      }

      const profile = await profileRes.json();

      // Redirect by role
      switch (profile.roleName) {
        case "ADMIN":
          router.push("/6-admin");
          break;
        case "MANAGER":
          router.push("/5-manager");
          break;
        case "SPECIALIST_HR":
          router.push("/4-specialist_hr");
          break;
        case "STUDENT":
          router.push("/3-student");
          break;
        default:
          router.push("/1-landing_page");
      }
    } catch (err) {
      console.error(err);
      setError("A apărut o eroare la login");
    }
  };

  // OAuth2 Login (Google / GitHub)
  const loginWithGoogle = () => {
    window.location.href = `${API}/oauth2/authorization/google`;
  };

  const loginWithGitHub = () => {
    window.location.href = `${API}/oauth2/authorization/github`;
  };

  return (
    <main className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-100 via-purple-100 to-pink-100 px-6">
      <div className="bg-white shadow-xl rounded-2xl p-10 w-full max-w-md">

        {/* LOGO */}
        <div className="flex justify-center mb-6">
          <Image src="/logo.svg" alt="Logo" width={120} height={120} unoptimized />
        </div>

        <h1 className="text-3xl font-bold text-center mb-6 text-gray-900">
          Welcome
        </h1>

        {error && (
          <p className="text-red-600 text-center font-medium mb-4">{error}</p>
        )}

        <form onSubmit={handleLogin} className="space-y-5">

          {/* EMAIL */}
          <div>
            <label className="block text-gray-700 font-medium mb-1">Email</label>
            <input
              type="email"
              className="w-full p-3 border border-gray-400 rounded-xl text-black placeholder-gray-500 focus:border-blue-600 focus:ring-blue-600"
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
                className="w-full p-3 border border-gray-400 rounded-xl text-black placeholder-gray-500 focus:border-purple-600 focus:ring-purple-600"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />

              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-600 hover:text-black"
              >
                {showPassword ? <span>👁️‍🗨️</span> : <span>🔒</span>}
              </button>
            </div>
          </div>

          {/* REMEMBER + FORGOT */}
          <div className="flex justify-between items-center text-sm">
            <label className="flex items-center gap-2 text-black">
              <input
                type="checkbox"
                checked={remember}
                onChange={() => setRemember(!remember)}
                className="accent-purple-600"
              />
              Remember me
            </label>

            <button
              type="button"
              onClick={() => router.push("/2-authentication/3-forgot_password")}
              className="text-blue-600 hover:underline"
            >
              Forgot password
            </button>
          </div>

          {/* LOGIN BUTTON */}
          <button
            type="submit"
            className="w-full bg-blue-600 hover:bg-blue-700 text-white py-3 rounded-xl font-semibold"
          >
            Login
          </button>

          {/* SOCIAL LOGIN */}
          <div className="space-y-3 mt-4">

            {/* GOOGLE */}
            <button
              type="button"
              onClick={loginWithGoogle}
              className="w-full border border-black py-3 rounded-xl flex justify-center gap-3 hover:bg-gray-100 text-black font-medium"
            >
              <Image src="/google.svg" alt="Google" width={20} height={20} />
              Login with Google
            </button>

            {/* GITHUB */}
            <button
              type="button"
              onClick={loginWithGitHub}
              className="w-full py-3 rounded-xl flex justify-center gap-3 bg-black text-white hover:bg-gray-900 font-medium"
            >
              <Image src="/github.png" alt="GitHub" width={30} height={20} unoptimized />
              Login with GitHub
            </button>
          </div>

          {/* REGISTER LINK */}
          <p className="text-center text-black text-sm mt-4">
            Nu ai cont?{" "}
            <button
              type="button"
              onClick={() => router.push("/2-authentication/2-register")}
              className="text-purple-600 hover:underline"
            >
              Creează cont
            </button>
          </p>
        </form>
      </div>
    </main>
  );
}