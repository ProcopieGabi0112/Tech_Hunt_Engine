import { API } from "@/config";

export async function safeFetch(url: string, options: RequestInit = {}) {
  return fetch(`${API}${url}`, {
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
    ...options,
  });
}