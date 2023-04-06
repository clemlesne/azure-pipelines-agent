#!/bin/bash
set -e

if [ -z "$AZP_URL" ]; then
  echo 1>&2 "error: missing AZP_URL environment variable"
  exit 1
fi

if [ -z "$AZP_TOKEN_FILE" ]; then
  if [ -z "$AZP_TOKEN" ]; then
    echo 1>&2 "error: missing AZP_TOKEN environment variable"
    exit 1
  fi

  AZP_TOKEN_FILE=/azp/.token
  echo -n $AZP_TOKEN >"$AZP_TOKEN_FILE"
fi

unset AZP_TOKEN

if [ -n "$AZP_WORK" ]; then
  mkdir -p "$AZP_WORK"
fi

cleanup() {
  if [ -e config.sh ]; then
    print_header "Cleanup, removing agent..."

    # If the agent has some running jobs, the configuration removal process will fail.
    # So, give it some time to finish the job.
    while true; do
      bash config.sh remove --unattended --auth PAT --token $(cat "$AZP_TOKEN_FILE") && break

      echo "Retrying in 30 seconds..."
      sleep 30
    done
  fi
}

print_header() {
  lightcyan='\033[1;36m'
  nocolor='\033[0m'
  echo -e "${lightcyan}$1${nocolor}"
}

print_header "Configuring agent..."

# Allow the agent to run as root (only feasible because the agent is running in a not-reused container)
export AGENT_ALLOW_RUNASROOT="1"
# Let the agent ignore the token env variables
export VSO_AGENT_IGNORE=AZP_TOKEN,AZP_TOKEN_FILE

bash config.sh \
  --acceptTeeEula \
  --agent "${AZP_AGENT_NAME:-$(hostname)}" \
  --auth PAT \
  --pool "${AZP_POOL:-Default}" \
  --replace \
  --token $(cat "$AZP_TOKEN_FILE") \
  --unattended \
  --url "$AZP_URL" \
  --work "${AZP_WORK:-_work}"

print_header "Running agent..."

if ! grep -q "template" <<<"$AZP_AGENT_NAME"; then
  echo "Cleanup traps enabled."

  trap 'cleanup; exit 0' EXIT
  trap 'cleanup; exit 130' INT
  trap 'cleanup; exit 143' TERM
fi

# To be aware of TERM and INT signals call "run-docker.sh", running it with the --once flag at the end will shut down the agent after the build is executed
bash run-docker.sh "$@" --once
