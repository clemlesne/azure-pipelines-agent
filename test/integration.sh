#!/bin/bash
set -e

instance="$1"
flavor="$2"

if [ -z "$instance" ] || [ -z "$flavor" ]; then
  echo "Usage: $1 <instance> $2 <flavor>"
  exit 1
fi

org_url="https://dev.azure.com/azure-pipelines-agent"

echo "Configuring Azure DevOps organization ${org_url}"
az devops configure --defaults organization=${org_url}

bash test/azure-devops/exists.sh "apa-${instance}-${flavor}"

bash test/azure-devops/pipeline.sh ${instance} root ${flavor}
