# HacktifyTests

**Security tests & reports repository** — a collection of penetration testing notes, lab exercises, and weekly reports documenting vulnerability assessments and test results.

---

## Contents

* `Ian_Week_1_Report.pdf` — Week 1 security testing report.
* `Ian_Week_2_Report.pdf` — Week 2 security testing report.
* `Ian_Week_3_Report.pdf` — Week 3 security testing report.
* `SQL Injection.txt` — notes / walkthrough covering SQL injection findings and reproduction steps.
* `lab3.txt` — lab 3 exercises and observations.

(These files were present in the repository at the time this README was created.)

---

## Purpose

This repository stores practical security testing artifacts created during penetration testing exercises and vulnerability assessments. It is intended to:

* Document findings, risk ratings, and remediation suggestions.
* Store lab notes and reproduction steps for specific vulnerabilities (for learning and reporting).
* Provide a base for converting manual test work into reproducible automated checks in the future.

---

## How this repo is organized

```
/                 <- repo root
├── README.md
├── README-tests.md
├── lab3.md
├── SQL Injection.txt
├── Ian_Week_1_Report.pdf
├── Ian_Week_2_Report.pdf
├── Ian_Week_3_Report.pdf
├── reports/
│   ├── README.md
│   ├── <scan-folder-1>/
│   │   ├── target.txt
│   │   ├── scan-timestamp.txt
│   │   ├── http-headers.txt
│   │   ├── http-body-partial.html
│   │   ├── nmap-top.nmap / .xml / .gnmap
│   │   ├── nikto.txt           # optional, if nikto was run
│   │   ├── sqlmap-guidance.txt
│   │   ├── dir-listing.txt
│   │   └── summary.txt
│   └── artifacts/
│       └── lab3/
│           ├── screenshots/
│           ├── burp-export.archive
│           └── other evidence files
├── scripts/
│   ├── run-scan.sh
│   ├── check-deps.sh
│   └── summarize-reports.sh
└── tests/  ← *proposed/future* (automated test scripts)

```

---

## Quick start — reading reports & reproducing findings

1. Open the weekly PDF reports (`Ian_Week_1_Report.pdf`, etc.) to review:

   * Scope & targets
   * Test methods used
   * Vulnerabilities discovered, evidence, and risk ratings
   * Suggested remediation steps

2. For hands-on reproduction of problems, consult `SQL Injection.txt` and `lab3.txt`:

   * Follow the step-by-step reproduction steps (payloads, request examples, expected responses).
   * Use a safe, isolated environment (local VM, intentionally vulnerable app, or lab sandbox) — **do not** test against systems you do not own or have written authorization to test.

3. Recommended tooling for reproducing or confirming issues:

   * Browser + DevTools, Burp Suite (Community / Professional), sqlmap for SQL injection testing, Nmap for network discovery.
   * Always follow ethical rules and get written permission before testing third-party targets.

---

## Suggested next steps (improvements / automation)

If you want to evolve this repo into a more reproducible test-suite, consider:

* **Add a `tests/` folder** with scripts (Python/bash) that automate repro steps where safe and legal.
* **Create `reports/` JSON or SARIF outputs** (or add machine-readable exports) for integration with CI.
* **Add `scripts/run-scan.sh`** that runs a non-destructive scan (e.g., Nmap, Nikto) with safe flags and saves outputs.
* **Add `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md`** to define how others can contribute (important for collaboration).
* **Version the reports** (e.g., `reports/2025-09-XX-week1.pdf`) to trace changes.

---

## How to contribute

1. Fork the repo.
2. Add tests or updated reports.
3. Submit a pull request describing the change and why it’s safe for this repo.

For any contribution that includes active scanning tools or scripts, include:

* A clear README describing the intended environment (lab / safe target).
* Any configuration or environment variables needed.
* A `README-tests.md` that explains how to run tests safely.

---

## Security & ethics

This repository documents vulnerabilities and testing artifacts that were generated as part of authorized exercises. Never use these materials to attack systems without clear, written permission. If you want to demonstrate an exploit, do so only in a dedicated lab (VMs, intentionally vulnerable apps like DVWA/OWASP Juice Shop) and document how the environment was provisioned.

---

## Contact / Author

Repository owner: Ian-Joseph (GitHub: `Ian-Joseph`)

---

## License

Add a license file if you want to allow reuse (e.g., `MIT`, or `CC-BY-NC` for non-commercial sharing). If no license is added, default GitHub behavior means others have **no** permission beyond viewing the repository.

---
