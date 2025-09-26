#!/usr/bin/env bash
# run-scan.sh — Non-destructive lab scan workflow
# Purpose: Example script for safe, non-destructive reconnaissance and lightweight scanning
# Usage: ./run-scan.sh -t http://localhost -o reports/2025-09-26-target
# NOTE: Only run this against systems you own or have written authorization to test.

set -euo pipefail
IFS=$'\n\t'

###############################################################################
# Default configuration
###############################################################################
TARGET=""
OUTDIR="reports/scan-$(date +%F_%H%M%S)"
MAX_PORTS=100            # limit port scan depth for safety
TOP_PORTS=100            # nmap --top-ports
VERBOSE=0
NO_PROMPT=0

###############################################################################
# Helper functions
###############################################################################
print_usage(){
  cat <<'USAGE'
run-scan.sh — safe, non-destructive lab scan

Usage:
  ./run-scan.sh -t <target-url-or-host> [-o <outdir>] [--no-prompt] [-v]

Examples:
  ./run-scan.sh -t http://localhost -o reports/local-scan
  ./run-scan.sh -t 192.168.56.101 --no-prompt

This script performs:
  1) Basic HTTP sanity checks (HEAD/GET)
  2) Lightweight Nmap service/version discovery (limited ports)
  3) Optional Nikto scan in safe mode (non-destructive)
  4) Optional sqlmap dry-run guidance (no automatic exploitation)

Only run in an isolated lab and with written permission for targets.
USAGE
}

log(){
  if [ "$VERBOSE" -eq 1 ]; then
    echo "[+] $*"
  fi
}

ensure_tool(){
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required tool '$1' not found in PATH. Install it or adjust PATH." >&2
    exit 2
  fi
}

confirm_continue(){
  if [ "$NO_PROMPT" -eq 1 ]; then
    return 0
  fi
  read -r -p "Proceed with safe scan against '$TARGET'? (y/N): " ans
  case "$ans" in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) echo "Aborted by user."; exit 0 ;;
  esac
}

###############################################################################
# Parse args
###############################################################################
while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target)
      TARGET="$2"; shift 2;;
    -o|--outdir)
      OUTDIR="$2"; shift 2;;
    -v|--verbose)
      VERBOSE=1; shift;;
    --no-prompt)
      NO_PROMPT=1; shift;;
    -h|--help)
      print_usage; exit 0;;
    *)
      echo "Unknown arg: $1"; print_usage; exit 1;;
  esac
done

if [ -z "$TARGET" ]; then
  echo "Error: target is required."; print_usage; exit 1
fi

###############################################################################
# Environment checks
###############################################################################
# Create output directory
mkdir -p "$OUTDIR"

# Ensure tools are available (soft checks)
ensure_tool curl
ensure_tool nmap
# nikto is optional; we will check before using

# Confirm user wants to continue
confirm_continue

###############################################################################
# 1) Basic HTTP checks
###############################################################################
log "Starting basic HTTP checks..."
HOSTNAME_FILE="$OUTDIR/host-info.txt"

# Save timestamp
date > "$OUTDIR/scan-timestamp.txt"

# Save the target as provided
printf "Target: %s\n" "$TARGET" > "$HOSTNAME_FILE"

# Perform a safe HEAD and a GET (limited) to capture headers and a small body
log "Fetching headers (HEAD)..."
curl -I --max-time 15 --location --retry 2 "$TARGET" > "$OUTDIR/http-headers.txt" 2>&1 || true

log "Fetching lightweight GET (first 10KB)..."
curl --max-time 15 --location --retry 2 --range 0-10240 "$TARGET" -o "$OUTDIR/http-body-partial.html" 2>/dev/null || true

###############################################################################
# 2) Lightweight Nmap discovery (non-aggressive)
###############################################################################
log "Running lightweight nmap (service discovery on top ports)..."
NMAP_BASE_OPTS=( -sV --version-intensity 2 --top-ports "$TOP_PORTS" --open --reason -Pn )
# --top-ports + --open + -Pn used for speed in lab; adjust as needed
nmap "${NMAP_BASE_OPTS[@]}" -oA "$OUTDIR/nmap-top" "$TARGET"

###############################################################################
# 3) Optional Nikto (safe mode recommendation)
###############################################################################
if command -v nikto >/dev/null 2>&1; then
  log "Nikto available — running in conservative mode (non-destructive).
  Note: Nikto can be noisy; ensure this is safe in your lab."
  # Nikto tuning: -Tuning 1 (info) is minimal; -nointeractive to avoid prompts
  nikto -h "$TARGET" -output "$OUTDIR/nikto.txt" -nointeractive -Tuning 1 || true
else
  log "Nikto not found; skipping nikto step."
fi

###############################################################################
# 4) Guidance for sqlmap (no automatic run)
###############################################################################
cat > "$OUTDIR/sqlmap-guidance.txt" <<'SQLGUIDE'
Do NOT run sqlmap against targets without written permission.

If you wish to perform a non-destructive confirmation using sqlmap, run it manually and start with
--technique=BE (boolean + error), --level=1, --risk=1, and --batch for non-interactive mode.
Example (manual, lab-only):
  sqlmap -u "http://TARGET/vuln.php?id=1" --batch --level=1 --risk=1 --technique=BE --output-dir=.

This script intentionally does not run sqlmap automatically to avoid accidental destructive testing.
SQLGUIDE

###############################################################################
# 5) Save metadata and wrap up
###############################################################################
# Save the list of discovered files
ls -la "$OUTDIR" > "$OUTDIR/dir-listing.txt"

cat <<EOF > "$OUTDIR/summary.txt"
Scan summary for target: $TARGET
Timestamp: $(date --iso-8601=seconds)
Outputs saved to: $OUTDIR
Tools used: curl, nmap$(if command -v nikto >/dev/null 2>&1; then echo ", nikto"; fi)
Notes: This is a lightweight, non-destructive scan for lab use only.
EOF

log "Scan complete. Outputs saved to: $OUTDIR"

echo "Scan finished — check $OUTDIR for artifacts (http-headers.txt, http-body-partial.html, nmap-top.* , nikto.txt if run, sqlmap-guidance.txt)."

# Exit cleanly
exit 0
