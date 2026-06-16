"use client";

import { useState, useEffect } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { API } from "@/config";

export default function ResetPasswordPage() {
  const searchParams = useSearchParams();
  const router = useRouter();

  const token = searchParams.get("token");

  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);

  // 👁️ Show/hide states
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);

  useEffect(() => {
    if (!token) {
      setMessage("Invalid or missing token.");
    }
  }, [token]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (password !== confirm) {
      setMessage("Passwords do not match.");
      return;
    }

    setLoading(true);
    setMessage("");

    try {
      const res = await fetch(`${API}/auth/reset-password`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          token,
          newPassword: password,
        }),
      });

      if (res.ok) {
        setMessage("Password updated successfully. Redirecting...");
        setTimeout(() => router.push("/2-authentication/1-login_page"), 1500);
      } else {
        setMessage("Invalid or expired token.");
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
          Reset Password
        </h2>

        {!token ? (
          <p
            style={{
              padding: "10px 12px",
              background: "#ffe6e6",
              color: "#b30000",
              borderRadius: 8,
              textAlign: "center",
              fontSize: 14,
            }}
          >
            Invalid reset link.
          </p>
        ) : (
          <form onSubmit={handleSubmit}>
            {/* NEW PASSWORD */}
            <label
              style={{
                display: "block",
                marginBottom: 6,
                fontSize: 14,
                fontWeight: 500,
                color: "#000",
              }}
            >
              New Password
            </label>

            <div style={{ position: "relative", marginBottom: 20 }}>
              <input
                type={showPassword ? "text" : "password"}
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                style={{
                  width: "100%",
                  padding: "10px 40px 10px 12px",
                  borderRadius: 8,
                  border: "1px solid #ccc",
                  fontSize: 15,
                  color: "#000",
                }}
              />

              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                style={{
                  position: "absolute",
                  right: 10,
                  top: "50%",
                  transform: "translateY(-50%)",
                  background: "none",
                  border: "none",
                  cursor: "pointer",
                  fontSize: 18,
                  color: "#444",
                }}
              >
                {showPassword ? "👁️‍🗨️" : "🔒"}
              </button>
            </div>

            {/* CONFIRM PASSWORD */}
            <label
              style={{
                display: "block",
                marginBottom: 6,
                fontSize: 14,
                fontWeight: 500,
                color: "#000",
              }}
            >
              Confirm Password
            </label>

            <div style={{ position: "relative", marginBottom: 20 }}>
              <input
                type={showConfirm ? "text" : "password"}
                required
                value={confirm}
                onChange={(e) => setConfirm(e.target.value)}
                style={{
                  width: "100%",
                  padding: "10px 40px 10px 12px",
                  borderRadius: 8,
                  border: "1px solid #ccc",
                  fontSize: 15,
                  color: "#000",
                }}
              />

              <button
                type="button"
                onClick={() => setShowConfirm(!showConfirm)}
                style={{
                  position: "absolute",
                  right: 10,
                  top: "50%",
                  transform: "translateY(-50%)",
                  background: "none",
                  border: "none",
                  cursor: "pointer",
                  fontSize: 18,
                  color: "#444",
                }}
              >
                {showConfirm ? "👁️‍🗨️" : "🔒"}
              </button>
            </div>

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
              {loading ? "Updating..." : "Reset Password"}
            </button>
          </form>
        )}

        {message && (
          <p
            style={{
              marginTop: 20,
              padding: "10px 12px",
              background: message.includes("success")
                ? "#e6f9e6"
                : "#ffe6e6",
              color: message.includes("success")
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
