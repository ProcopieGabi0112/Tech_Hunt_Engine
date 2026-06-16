"use client";

import Image from "next/image";
import { useRouter } from "next/navigation";
import { useEffect, useState, useRef } from "react";
import { API } from "@/config";

export default function StudentDashboard() {
  const router = useRouter();

  const [typedText, setTypedText] = useState("");
  const [userInfo, setUserInfo] = useState({ role: "", name: "" });

  // Avatar state
  const [avatar, setAvatar] = useState<string | null>(null);

  // Dropdown-uri
  const [showCvMenu, setShowCvMenu] = useState(false);
  const [showProfileMenu, setShowProfileMenu] = useState(false);

  const cvRef = useRef<HTMLDivElement | null>(null);
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
      .catch(() => {
        router.push("/2-authentication/1-login_page");
      });
  }, []);

  // Load avatar
  async function loadAvatar() {
    const res = await fetch(`${API}/users/me/profile-image`, {
      method: "GET",
      credentials: "include",
    });

    if (res.ok) {
      const blob = await res.blob();
      setAvatar(URL.createObjectURL(blob));
    } else {
      setAvatar(null); // IMPORTANT: null => afișăm inițiale
    }
  }

  useEffect(() => {
    loadAvatar();

    // listen for profile image update event
    const handler = () => loadAvatar();
    window.addEventListener("profile-image-updated", handler);

    return () => window.removeEventListener("profile-image-updated", handler);
  }, []);

  // Close dropdowns when clicking outside
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (cvRef.current && !cvRef.current.contains(e.target as Node)) {
        setShowCvMenu(false);
      }
      if (profileRef.current && !profileRef.current.contains(e.target as Node)) {
        setShowProfileMenu(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // Typing text
  const message =
    "Your future starts here. Keep learning. Keep growing. Keep winning.";

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
    <main className="min-h-screen bg-black text-white flex flex-col">

      {/* NAVBAR */}
      <nav className="w-full h-20 bg-white text-black border-b border-gray-300 
      flex items-center justify-between px-10 fixed top-0 z-50 shadow-md">

        {/* LEFT MENU */}
        <div className="flex-1 flex justify-center">
          <div className="flex gap-10 text-lg font-semibold">

            <button onClick={() => router.push("/3-student/email")} className="hover:text-gray-600">
              Email
            </button>

            {/* CV DROPDOWN */}
            <div className="relative" ref={cvRef}>
              <button
                onClick={() => setShowCvMenu((prev) => !prev)}
                className="hover:text-gray-600"
              >
                Curriculum Vitae
              </button>

              {showCvMenu && (
                <div className="absolute top-8 left-0 bg-white text-black shadow-lg rounded-lg w-56 py-2 z-50">

                  <div
                    className="px-4 py-2 hover:bg-gray-100 cursor-pointer"
                    onClick={() => router.push("/3-student/cv/institutions")}
                  >
                    Instituții acreditate
                  </div>

                  <div
                    className="px-4 py-2 hover:bg-gray-100 cursor-pointer"
                    onClick={() => router.push("/3-student/cv/skills")}
                  >
                    Competențe tehnice
                  </div>

                  <div
                    className="px-4 py-2 hover:bg-gray-100 cursor-pointer"
                    onClick={() => router.push("/3-student/cv/languages")}
                  >
                    Certificări lingvistice
                  </div>

                </div>
              )}
            </div>

            <button onClick={() => router.push("/3-student/application")} className="hover:text-gray-600">
              My Applications
            </button>

            <button onClick={() => router.push("/3-student/job")} className="hover:text-gray-600">
              Jobs
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
            {/* Avatar OR Initiale */}
            <div className="w-10 h-10 rounded-full overflow-hidden bg-gray-200 flex items-center justify-center">
              {avatar ? (
                <img
                  src={avatar}
                  alt="Avatar"
                  width={40}
                  height={40}
                  className="object-cover w-full h-full"
                />
              ) : (
                <span className="text-black font-bold">
                  {userInfo.name
                    ?.split(" ")
                    .map((n) => n[0])
                    .join("")
                    .toUpperCase()}
                </span>
              )}
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
                onClick={() => router.push("/3-student/profile")}
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

        <Image
          src="/logo.svg"
          alt="Tech Hunter Logo"
          width={700}
          height={700}
          className="opacity-90 mb-10 mt-32 max-w-full h-auto"
          unoptimized
        />

        <h1 className="text-4xl font-bold tracking-wide">
          {typedText}
          <span className="animate-pulse">|</span>
        </h1>
      </section>
    </main>
  );
}
