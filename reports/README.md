# reports/README

This directory stores artifacts and outputs generated during tests and scans. This README explains what each file type means and where to look for evidence when reviewing findings.

---

## Structure (common paths)

* `reports/` — root reports directory. Subfolders are usually created per-scan or per-lab (e.g., `reports/local-scan/`, `reports/sqlmap/`).
* `reports/<scan-name>/` — output folder created by `scripts/run-scan.sh` containing artifacts for a single target.
* `reports/artifacts/<lab>/` — screenshots, Burp exports, and other manual artifacts from lab exercises.
* `reports/sqlmap/` — sqlmap output logs and HTTP request dumps (if used; use only in lab).

---

## Artifact meanings

* `scan-timestamp.txt` — timestamp when the scan was run.
* `target.txt` — the target string (URL or hostname) scanned.
* `http-headers.txt` — result of `curl -I` (HTTP response headers). Useful for identifying server types, headers, and potential misconfigurations.
* `http-body-partial.html` — first ~10KB of the HTTP response body (useful for confirming content differences without saving full pages).
* `nmap-top.nmap`, `nmap-top.xml`, `nmap-top.gnmap` — Nmap outputs (normal, XML, and grepable formats). Use these to review open ports and service versions.
* `nikto.txt` — Nikto scan results (if Nikto was run). Contains discovered issues and informational findings; can be noisy.
* `sqlmap-guidance.txt` — Guidance file explaining how to run sqlmap manually and safely. This repository intentionally does not run sqlmap automatically.
* `dir-listing.txt` — snapshot of the report directory contents for quick review.
* `summary.txt` — a short human-readable summary of the scan results and notes.

---

## How to use these artifacts in reports

1. When writing a vulnerability report, reference the exact artifact path (e.g., `reports/local-scan/example.com/http-headers.txt`).
2. For proof-of-concept, include exact request/response snippets and point to the Burp export or `http-body-partial.html` as evidence.
3. For automated scans, collect Nmap and Nikto outputs and attach them to the issue tracker or report.

---

## Handling sensitive data

* Treat report artifacts as sensitive. Do not publish full artifacts containing credentials, PII, or database dumps.
* Store artifacts in a private repository or secure storage if they contain sensitive information.

---

## Cleanup and retention

* Keep only the artifacts you need for reporting and remediation validation.
* Consider snapshotting or archiving old reports to reduce clutter.

---
