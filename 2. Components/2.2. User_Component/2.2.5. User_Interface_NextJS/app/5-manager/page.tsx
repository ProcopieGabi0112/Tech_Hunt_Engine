"use client";

import Image from "next/image";
import { useRouter } from "next/navigation";
import { useEffect, useState, useRef } from "react";
import { API } from "@/config";

export default function ManagerDashboard() {
  const router = useRouter();

  const [typedText, setTypedText] = useState("");
  const [userInfo, setUserInfo] = useState({ role: "", name: "" });

  // Dropdown Profile
  const [showProfileMenu, setShowProfileMenu] = useState(false);
  const profileRef = useRef<HTMLDivElement | null>(null);

  const logout = () => {
    document.cookie = "token=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT";
    router.push("/2-authentication/1-login_page");
  };

  // Fetch user profile
  useEffect(() => {
    fetch(`${API}/users/me`, {
      method: "GET",
      credentials: "include",
    })
      .then((res) => {
        if (!res.ok) throw new Error("Unauthorized");
        return res.json();
      })
      .then((profile) => {
        const role = profile.roleName
          ?.replace("ROLE_", "")
          .toLowerCase()
          .replace(/_/g, " ")
          .replace(/\b\w/g, (c: string) => c.toUpperCase());

        const name = `${profile.firstName} ${profile.lastName}`;

        setUserInfo({ role, name });
      })
      .catch(() => router.push("/2-authentication/1-login_page"));
  }, []);

  // Close dropdown on outside click
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (profileRef.current && !profileRef.current.contains(e.target as Node)) {
        setShowProfileMenu(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // Typed text effect
  const message =
    "Lead with vision. Empower your teams. Drive meaningful results.";

  useEffect(() => {
    let index = 0;
    const interval = setInterval(() => {
      setTypedText(message.slice(0, index));
      index++;
      if (index > message.length) index = 0;
    }, 120);

    return () => clearInterval(interval);
  }, []);

  return (
    <main className="min-h-screen bg-gradient-to-br from-blue-50 via-gray-100 to-blue-100 text-black flex flex-col">

      {/* NAVBAR */}
      <nav className="w-full h-20 bg-white text-black border-b border-gray-300 
      flex items-center justify-between px-10 fixed top-0 z-50 shadow-md">

        {/* LEFT MENU */}
        <div className="flex-1 flex justify-center">
          <div className="flex gap-10 text-lg font-semibold">
            <button onClick={() => router.push("/5-manager/email")} className="hover:text-blue-700">
              Email
            </button>
            <button onClick={() => router.push("/5-manager/employees")} className="hover:text-blue-700">
              Employees
            </button>
            <button onClick={() => router.push("/5-manager/company")} className="hover:text-blue-700">
              Company
            </button>
          </div>
        </div>

        {/* RIGHT SIDE – PROFILE BUTTON */}
        <div className="relative" ref={profileRef}>

          <button
            onClick={() => setShowProfileMenu((prev) => !prev)}
            className="flex items-center gap-3 px-4 py-2 bg-gray-100 hover:bg-gray-200 
                       text-black rounded-full shadow-sm transition-all"
          >
            {/* Avatar */}
            <div className="w-10 h-10 rounded-full bg-gray-300 flex items-center justify-center text-black font-bold">
              {userInfo.name
                ?.split(" ")
                .map((n) => n[0])
                .join("")
                .toUpperCase()}
            </div>

            {/* Name + Role */}
            <div className="flex flex-col text-left leading-tight">
              <span className="font-semibold">{userInfo.name}</span>
              <span className="text-xs text-gray-600">{userInfo.role}</span>
            </div>
          </button>

          {/* PROFILE DROPDOWN */}
          {showProfileMenu && (
            <div className="absolute right-0 top-16 bg-white text-black shadow-lg rounded-lg w-48 py-2 z-50">

              <div
                className="px-4 py-2 hover:bg-gray-100 cursor-pointer"
                onClick={() => router.push("/5-manager/profile")}
              >
                View Profile
              </div>

              <div
                className="px-4 py-2 hover:bg-gray-100 cursor-pointer text-red-600 font-semibold"
                onClick={logout}
              >
                Logout
              </div>

            </div>
          )}
        </div>
      </nav>

      {/* HERO SECTION */}
      <section className="flex flex-col items-center justify-center flex-1 text-center px-4">

        {/* LOGO */}
        <Image
          src="/logo.svg"
          alt="Tech Hunter Logo"
          width={650}
          height={650}
          className="opacity-90 mb-10 mt-32 max-w-full h-auto"
          unoptimized
        />

        {/* TEXT MOTIVAȚIONAL */}
        <h1 className="text-4xl font-bold tracking-wide text-blue-900">
          {typedText}
          <span className="animate-pulse">|</span>
        </h1>
      </section>
    </main>
  );
}
