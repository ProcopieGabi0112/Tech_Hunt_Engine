"use client";

import { useState, useEffect } from "react";
import { API } from "@/config";

export default function ForgotPasswordPage() {
  useEffect(() => {
    console.log("Forgot Password page loaded");
  }, []);

  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    console.log("Submitting...", email);

    setLoading(true);
    setMessage("");

    try {
      const res = await fetch(`${API}/auth/forgot-password`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email }),
      });

      if (res.ok) {
        setMessage("If the email exists, a reset link was sent.");
      } else {
        setMessage("Something went wrong.");
      }
    } catch (err) {
      setMessage("Server error.");
    }

    setLoading(false);
  };

  return (
    <div
      style={{
        minHeight: "100vh",
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        background: "#f5f7fa",
        padding: 20,
      }}
    >
      <div
        style={{
          width: "100%",
          maxWidth: 420,
          background: "#fff",
          padding: 30,
          borderRadius: 12,
          boxShadow: "0 4px 20px rgba(0,0,0,0.08)",
          color: "#000",
        }}
      >
        <h2
          style={{
            marginBottom: 20,
            fontSize: 26,
            fontWeight: 600,
            textAlign: "center",
            color: "#111",
          }}
        >
          Forgot Password
        </h2>

        <p
          style={{
            marginBottom: 20,
            fontSize: 14,
            color: "#444",
            textAlign: "center",
          }}
        >
          Enter your email address and we’ll send you a link to reset your password.
        </p>

        <form onSubmit={handleSubmit}>
          <label
            style={{
              display: "block",
              marginBottom: 6,
              fontSize: 14,
              fontWeight: 500,
              color: "#000",
            }}
          >
            Email
          </label>

          <input
            type="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            style={{
              width: "100%",
              padding: "10px 12px",
              borderRadius: 8,
              border: "1px solid #ccc",
              fontSize: 15,
              marginBottom: 20,
              color: "#000",
            }}
          />

          <button
            type="submit"
            disabled={loading}
            style={{
              width: "100%",
              padding: "12px 0",
              background: loading ? "#6aa8ff" : "#0070f3",
              color: "white",
              border: "none",
              borderRadius: 8,
              fontSize: 16,
              fontWeight: 600,
              cursor: loading ? "not-allowed" : "pointer",
              transition: "0.2s",
            }}
          >
            {loading ? "Sending..." : "Send Reset Link"}
          </button>
        </form>

        {message && (
          <p
            style={{
              marginTop: 20,
              padding: "10px 12px",
              background: message.includes("If")
                ? "#e6f9e6"
                : "#ffe6e6",
              color: message.includes("If")
                ? "#0a7a0a"
                : "#b30000",
              borderRadius: 8,
              fontSize: 14,
              textAlign: "center",
            }}
          >
            {message}
          </p>
        )}
      </div>
    </div>
  );
}
