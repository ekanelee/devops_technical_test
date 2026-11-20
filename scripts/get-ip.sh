#!/usr/bin/env bash
# get-ip.sh - prints the public IP of the load balancer in front of the Cloud Run service.
# (Cloud Run has no fixed public IP of its own; the load balancer's global IP is the app's address.)
#
# Usage:    ./scripts/get-ip.sh <dev|prod>
# Output:   the IP on stdout (so it can be used in $(...)); log lines go to stderr and get-ip.log
# Exit code: 0 on success, 1 on any error

set -eu

ENVIRONMENT="${1:-}"
LOG_FILE="${LOG_FILE:-get-ip.log}"

# Writes a timestamped line to the screen (stderr) and appends it to the log file.
log() {
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [$1] $2" | tee -a "$LOG_FILE" >&2
}

# Logs an error and stops the script.
fail() {
  log ERROR "$1"
  exit 1
}

# 1. Check the environment argument.
if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prod" ]; then
  fail "Usage: $0 <dev|prod>"
fi

# 2. Check that gcloud is installed.
command -v gcloud >/dev/null 2>&1 || fail "gcloud is not installed"

# 3. Find the project: GCP_PROJECT_ID if set, otherwise the gcloud default.
PROJECT="${GCP_PROJECT_ID:-$(gcloud config get-value project 2>/dev/null || true)}"
[ -n "$PROJECT" ] || fail "No project: set GCP_PROJECT_ID or run 'gcloud config set project <id>'"

# 4. The address name follows the Terraform naming: app-<environment>-ip
ADDRESS_NAME="app-${ENVIRONMENT}-ip"
log INFO "Looking up ${ADDRESS_NAME} in project ${PROJECT}"

# 5. Read the reserved global IP address.
IP="$(gcloud compute addresses describe "$ADDRESS_NAME" --global --project "$PROJECT" --format='value(address)' 2>/dev/null)" || IP=""
[ -n "$IP" ] || fail "Could not read ${ADDRESS_NAME} (not deployed, wrong project, or not logged in: run 'gcloud auth login')"

log INFO "environment=${ENVIRONMENT} ip=${IP}"
echo "$IP"