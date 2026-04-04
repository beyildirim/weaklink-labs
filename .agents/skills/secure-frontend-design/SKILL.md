---
name: Secure Frontend Design
description: Best practices and guidelines for secure frontend design (OWASP) to be used by all agents.
---

# Secure Frontend Design Guidelines

When developing, architecting, or extending frontend components, agents MUST abide by these core security principles and OWASP recommendations. This defense-in-depth approach assumes the client environment is untrusted.

## 1. Input Validation and Sanitization (Anti-XSS)
- **Sanitize by Default:** Always output-encode data correctly for the HTML context (React and Angular do this by default, but be careful with `dangerouslySetInnerHTML` or `innerHTML`).
- **DOMPurify:** If rendering user-generated Markdown or rich text, pass it through `DOMPurify` before injecting it into the DOM.
- **Client & Server:** Client-side validation is for UX; Server-side validation is for security. Assume client validation can be bypassed.

## 2. Secure Communication & Headers
- **HTTPS:** Ensure all assets, APIs, and pages are loaded over secure TLS/HTTPS. No mixed content.
- **Content Security Policy (CSP):** Always implement a strict CSP to whitelist allowable script execution origins (`script-src`), preventing inline XSS execution.
- **Anti-Clickjacking:** Ensure `X-Frame-Options: DENY` or `Content-Security-Policy: frame-ancestors 'none'` is used to prevent UI-redressing.

## 3. Safe State & Data Handling
- **No Secrets in Frontend Code:** Never embed API keys, client secrets, passwords, or PII directly in frontend repositories, HTML, JavaScript bundles, or `localStorage`/`sessionStorage`.
- **JWT Storage:** Store sensitive authenticated JWT tokens in `HttpOnly`, `Secure`, `SameSite=Strict` cookies. If tokens must be stored in memory for SPA (Single Page Applications), ensure they are wiped on logout. Do not store them in `localStorage`.

## 4. Third-Party Dependencies
- **Auditing:** Avoid pulling in massive, unvetted NPM packages for trivial frontend features. Update `package.json` dependencies frequently.
- **Subresource Integrity (SRI):** If loading scripts from a CDN, always include `integrity` hashes.

## 5. Cross-Site Request Forgery (CSRF) Prevention
- Use `SameSite=Lax` or `Strict` for all authentication cookies.
- For state-mutating API calls, ensure anti-CSRF token patterns are used if the backend relies on cookie-based authentication.

## Agent Protocol
Before finalizing any frontend codebase change, verify that no new XSS vectors have been introduced (e.g. executing unsanitized dynamic user input), that headers adhere to current OWASP standards, and that no credentials have been leaked to the build bundle.
