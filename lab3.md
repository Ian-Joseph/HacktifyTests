
# Lab 3 — Security Lab Notes

> Converted from `lab3.txt` into Markdown for readability. If you want the original raw text preserved, let me know and I will add it as `lab3.txt.orig`.

---

## Lab objective

Summarize the goal of the lab exercise in one sentence. Example:

> Perform basic web application vulnerability discovery and document findings for learning and reporting.

---

## Environment

* Target: (e.g. `http://localhost:8080` or `DVWA` / `OWASP Juice Shop`)
* Test machine: (e.g. `Kali VM`, `Parrot`, `Windows 10`)
* Snapshot taken: Yes / No
* Tools used: Burp Suite, curl, sqlmap, nmap, browser DevTools

---

## Steps performed

1. **Reconnaissance**

   * Visited the application home page and identified accessible endpoints.
   * Collected public endpoints: `/login`, `/search`, `/items?id=`.

2. **Input discovery**

   * Tested form fields and URL parameters for unusual behavior.
   * Captured requests in Burp for replay and modification.

3. **Injection testing**

   * Conducted simple quote probes (`'`) on likely DB-backed parameters.
   * Performed boolean-based probes (`OR '1'='1'`) and timing-based probes when needed.

4. **Confirmatory checks**

   * Used sqlmap for safe, non-destructive confirmation with `--technique=BE`.
   * Recorded response differences and saved sqlmap logs to `reports/sqlmap/`.

5. **Documentation**

   * Screenshots and Burp request/response saved under `reports/artifacts/lab3/`.

---

## Findings (example format)

* **Endpoint:** `/items?id=`

  * **Issue:** SQL Injection (boolean-based)
  * **Evidence:** Response content differed between `id=1' OR '1'='1` and `id=1' AND '1'='2` (see Burp screenshots).
  * **Impact:** Potential data disclosure from the items table.
  * **Recommendation:** Use prepared statements and parameterized queries; validate and sanitize input.

* **Endpoint:** `/search` (low severity)

  * **Issue:** Reflected XSS observed in search results when injecting `<script>` tags in a lab environment.
  * **Evidence:** The search result page reflected unsanitized input.
  * **Recommendation:** Apply output encoding/escaping for HTML contexts.

---

## Artifacts and evidence

* Burp project: `reports/artifacts/lab3/lab3-burp-project.zip`
* Screenshots: `reports/artifacts/lab3/screenshot-*.png`
* sqlmap logs (if run): `reports/sqlmap/lab3/`

---

## Remediation notes

1. Parameterize all database access and avoid dynamic SQL composition with user input.
2. Implement centralized input validation for expected data types and lengths.
3. Disable verbose error messages in production and log details server-side.
4. Adopt a secure SDLC review for the affected modules.

---

## Next steps / follow-ups

* Triage findings by severity and plan a re-test after fixes.
* Convert manual test steps into scripts under `tests/` for reproducible checks.
* Add CI-safe scans that run against a staging environment only.

---
