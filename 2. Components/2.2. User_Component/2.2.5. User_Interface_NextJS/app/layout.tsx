import "./globals.css";
import type { ReactNode } from "react";

export const metadata = {
  title: "Tech Hunter Engine",
  description: "From Hello World to Dream Job",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-[#242428] min-h-screen">
        {children}
      </body>
    </html>
  );
}