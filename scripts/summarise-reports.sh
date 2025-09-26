#!/usr/bin/env bash
# summarise-reports.sh — Generate a CSV summary of all scan reports
# Usage: ./scripts/summarise-reports.sh > reports/summary.csv
#
# This script searches under reports/ for scan folders and extracts
# key information into a single CSV file for quick review.

set -euo pipefail

REPORTS_DIR="reports"

if [ ! -d "$REPORTS_DIR" ]; then
  echo "Error: reports directory not found." >&2
  exit 1
fi

# CSV header
echo "scan_folder,target,timestamp,nmap_ports,nikto_findings"

find "$REPORTS_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
  # skip artifacts/sqlmap directories
  case "$dir" in
    *artifacts*|*sqlmap*) continue;;
  esac

  target_file="$dir/target.txt"
  ts_file="$dir/scan-timestamp.txt"
  nmap_file="$dir/nmap-top.nmap"
  nikto_file="$dir/nikto.txt"

  target=""
  ts=""
  nmap_ports=""
  nikto_issues=""

  if [ -f "$target_file" ]; then
    target=$(tr -d '\n' < "$target_file")
  fi

  if [ -f "$ts_file" ]; then
    ts=$(tr -d '\n' < "$ts_file")
  fi

  if [ -f "$nmap_file" ]; then
    nmap_ports=$(grep -Eo '^[0-9]+/(tcp|udp)' "$nmap_file" | cut -d/ -f1 | paste -sd ':' -)
  fi

  if [ -f "$nikto_file" ]; then
    nikto_issues=$(grep -c "+ " "$nikto_file" || true)
  fi

  folder=$(basename "$dir")
  echo "$folder,$target,$ts,$nmap_ports,$nikto_issues"
done
