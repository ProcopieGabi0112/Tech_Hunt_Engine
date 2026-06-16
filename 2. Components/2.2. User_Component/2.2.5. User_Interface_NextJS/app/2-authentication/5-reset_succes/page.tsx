"use client";

import { useRouter } from "next/navigation";

export default function ResetSuccessPage() {
  const router = useRouter();

  return (
    <main className="min-h-screen flex flex-col items-center justify-center bg-green-100 px-6">
      <h1 className="text-4xl font-bold text-green-800 mb-4">
        Parola a fost resetată!
      </h1>

      <p className="text-lg text-gray-700 mb-6">
        Te poți autentifica acum cu parola nouă.
      </p>

      <button
        onClick={() => router.push("/2-authentication/1-login_page")}
        className="px-6 py-3 bg-green-600 text-white rounded-xl hover:bg-green-700 font-semibold transition-all"
      >
        Mergi la login
      </button>
    </main>
  );
}
