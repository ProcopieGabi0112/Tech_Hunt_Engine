"use client";

import Image from "next/image";
import { useRouter } from "next/navigation";
import { Poppins } from "next/font/google";

const poppins = Poppins({
  subsets: ["latin"],
  weight: ["400", "600", "700", "800"],
});

export default function LandingPage() {
  const router = useRouter();

  return (
    <main
      className={`${poppins.className} min-h-screen flex flex-col items-center justify-center 
      px-6 md:px-12 lg:px-20 
      bg-gradient-to-br from-blue-100 via-purple-100 to-pink-100`}
    >
      {/* LOGO */}
      <div className="w-full flex justify-center mb-8">
        <Image
          src="/logo.svg"
          alt="Tech Hunter Engine Logo"
          width={350}
          height={350}
          className="drop-shadow-xl"
          priority
          unoptimized
        />
      </div>

      {/* SLOGAN */}
      <h1 className="text-3xl md:text-5xl font-extrabold text-gray-900 text-center leading-tight mb-4">
        From <span className="text-blue-600">"Hello World"</span><span></span>
        <br className="md:hidden" />
        To <span className="text-purple-600">Dream Job</span>
      </h1>

      {/* SUBTEXT */}
      <p className="text-gray-700 text-center text-lg md:text-xl max-w-2xl mb-10">
        Descoperă tehnologiile potrivite, învață eficient și găsește jobul ideal în IT.
      </p>

      {/* BUTTON */}
      <button
        onClick={() => router.push("/2-authentication/1-login_page")}
        className="px-10 py-4 bg-blue-600 hover:bg-blue-700 text-white text-lg 
        font-semibold rounded-xl shadow-lg transition-all duration-200"
      >
        Let’s get started
      </button>
    </main>
  );
}
