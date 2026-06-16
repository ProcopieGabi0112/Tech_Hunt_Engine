import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  // 0. Ignorăm ORICE request către backend (indiferent de IP)
  if (req.nextUrl.href.includes(":8080")) {
    return NextResponse.next();
  }

  // 1. Public paths
  const publicPaths = [
    "/",
    "/1-landing_page",
    "/2-authentication/1-login_page",
    "/2-authentication/2-register",
    "/2-authentication/3-forgot_password",
    "/2-authentication/4-reset_password",
    "/2-authentication/5-reset_succes",
  ];

  if (publicPaths.includes(pathname)) {
    return NextResponse.next();
  }

  // 2. Token
  const raw = req.cookies.get("token")?.value;
  const token = raw ? decodeURIComponent(raw) : null;

  if (!token) {
    return NextResponse.redirect(
      new URL("/2-authentication/1-login_page", req.url)
    );
  }

 // 3. Decode JWT
let payload = null;
try {
  const base64 = token.split(".")[1];
  payload = JSON.parse(atob(base64));
} catch {
  return NextResponse.redirect(
    new URL("/2-authentication/1-login_page", req.url)
  );
}

  const role = payload?.roleName;

  // 4. Role → route mapping
  const roleRoutes: Record<string, string> = {
    ROLE_ADMIN: "/6-admin",
    ROLE_MANAGER: "/5-manager",
    ROLE_SPECIALIST_HR: "/4-specialist_hr",
    ROLE_STUDENT: "/3-student",
  };

  for (const [expectedRole, routePrefix] of Object.entries(roleRoutes)) {
    if (pathname.startsWith(routePrefix) && role !== expectedRole) {
      return NextResponse.redirect(new URL("/1-landing_page", req.url));
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/((?!_next|favicon.ico|.*\\.png|.*\\.jpg|.*\\.jpeg|.*\\.gif|.*\\.svg|.*\\.ico).*)",
  ],
};
