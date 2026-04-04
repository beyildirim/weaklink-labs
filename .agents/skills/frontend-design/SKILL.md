---
name: Frontend Engineering & UI/UX Design
description: Comprehensive best practices for modern UI/UX design, accessibility, and OWASP frontend security protocols to be used by all agents.
---

# Frontend Engineering: UX, UI, and Security Guidelines

When developing, architecting, or extending frontend components, agents MUST abide by a holistic approach combining user-centered design, modern UI/UX aesthetics, and defense-in-depth security.

## Part 1: Modern UI/UX & Design Aesthetics
Frontend work shouldn't just "function"; it must feel intentional, professional, and accessible.
- **Visual Excellence & Modernity:** Use rich aesthetics. Implement curated color palettes (e.g. sleek dark modes, vibrant CTA accents), modern typography (Inter, Roboto), and smooth gradients. Ensure the UI feels premium. No raw browser defaults.
- **Visual Hierarchy & Simplicity:** Use size, color, typography, and spacing to prioritize important elements. Reduce cognitive load by keeping layouts clean ("Don't make me think"). Remove unnecessary elements.
- **Feedback & Micro-animations:** An interface should feel alive. Always provide immediate, clear feedback when a user interacts (loading states, hover effects, success toasts, error styling).
- **Consistency:** Maintain a unified design language (fonts, colors, spacing, button styles) across all views. Follow established Design System patterns.

## Part 2: Accessibility (a11y) & Performance
- **Semantic HTML & A11Y:** Build for everyone. Use proper semantic HTML (`<main>`, `<nav>`, `<aside>`). Ensure proper color contrast. Use ARIA attributes (`aria-expanded`, `aria-label`) for complex widgets.
- **Mobile-First Responsiveness:** UIs must scale fluidly. Use Flexbox/Grid CSS over hardcoded pixel widths. Test all designs for how they wrap on small viewports.
- **Performance:** Do not introduce massive external NPM packages for trivial features. Optimize image loading. Keep DOM depth reasonably shallow.

## Part 3: OWASP Security (Defense-in-Depth)
Assume the client environment is universally untrusted.
- **Input Validation and Sanitization (Anti-XSS):** Sanitize user input contextually. If rendering rich text, it must run through `DOMPurify`.
- **Safe Authentication Handling:** Do not store JWTs, API keys, or PII in `localStorage`/`sessionStorage`. authentication tokens should rely on `HttpOnly`, `Secure`, `SameSite=Strict` cookies.
- **Secure Communication & Headers:** Ensure all requests occur over HTTPS. Apps should implement Strict-Transport-Security (HSTS), Anti-Clickjacking (`X-Frame-Options: DENY`), and robust Content Security Policies (CSP).
- **Subresource Integrity (SRI):** When consuming external CDNs, scripts must use integrity hashes.

## Agent Protocol
Before finalizing any frontend codebase change, verify that:
1. The UI looks premium and follows UX principles (hover states, hierarchy, spacing).
2. The layout is mobile-responsive and accessible.
3. No XSS vectors or secret leakages have been accidentally introduced.
