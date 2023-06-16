param autoscalingMaxReplicas int
param extraEnv array
param imageFlavor string
param imageName string
param imageRegistry string
param imageVersion string
param location string
// param pipelinesCacheSize string
// param pipelinesCacheType string
param pipelinesCapabilities array
param pipelinesOrganizationURL string
@secure()
param pipelinesPersonalAccessToken string
param pipelinesPoolName string
param pipelinesTimeout int
// param pipelinesTmpdirSize string

var pipelinesCapabilitiesDict = [for capability in pipelinesCapabilities: {
  name: 'capability_${capability}'
  value: ''
}]

var extraEnvDict = [for env in extraEnv: {
  name: env.name
  value: env.value
}]

var defaultJobConf = {
  configuration: {
    registries: [
      {
        server: '${acr.name}.azurecr.io'
        identity: identity.properties.principalId
      }
    ]
    replicaTimeout: pipelinesTimeout
    replicaRetryLimit: 1
    secrets: [
      {
        name: 'personal-access-token'
        value: pipelinesPersonalAccessToken
      }
      {
        name: 'organization-url'
        value: pipelinesOrganizationURL
      }
    ]
  }
  environmentId: acaEnv.id
  template: {
    containers: [
      {
        image: '${imageName}:${imageFlavor}-${imageVersion}'
        name: 'azp-agent'
        env: union([
          {
            name: 'VSO_AGENT_IGNORE'
            value: 'AZP_TOKEN'
          }
          {
            name: 'AGENT_ALLOW_RUNASROOT'
            value: '1'
          }
          {
            name: 'AZP_URL'
            secretRef: 'organization-url'
          }
          {
            name: 'AZP_POOL'
            value: pipelinesPoolName
          }
          {
            name: 'AZP_TOKEN'
            secretRef: 'personal-access-token'
          }
          {
            name: 'flavor_${imageFlavor}'
            value: ''
          }
        ], pipelinesCapabilitiesDict, extraEnvDict)
        resources: {
          cpu: 2
          memory: '4Gi'
        }
        volumeMounts: [
          {
            volumeName: 'azp-work'
            mountPath: '/app-root/azp-work'
          }
          {
            volumeName: 'local-tmp'
            mountPath: '/app-root/.local/tmp'
          }
        ]
      }
    ]
    volumes: [
      {
        name: 'azp-work'
        storageType: 'EmptyDir'
      }
      {
        name: 'local-tmp'
        storageType: 'EmptyDir'
      }
    ]
  }
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: resourceGroup().name
  location: location
}

resource acrRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: resourceGroup().name
  scope: acr
  properties: {
    principalId: identity.properties.principalId
    roleDefinitionId: tenantResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2022-12-01' = {
  name: replace(resourceGroup().name, '-', '')
  location: location
  sku: {
    name: 'Basic'
  }
}

resource acrCache 'Microsoft.ContainerRegistry/registries/cacheRules@2023-01-01-preview' = {
  name: resourceGroup().name
  parent: acr
  properties: {
    sourceRepository: '${imageRegistry}/${imageName}'
    targetRepository: imageName
  }
}

resource acaEnv 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: resourceGroup().name
  location: location
  sku: {
    name: 'Consumption'
  }
  properties: {}
}

resource jobStarter 'Microsoft.App/jobs@2023-04-01-preview' = {
  name: 'pipeline-starter'
  location: location
  properties: union(defaultJobConf, {
    configuration: {
      manualTriggerConfig: {
        parallelism: 1
        replicaCompletionCount: 1
      }
      triggerType: 'Manual'
    }
  })
}

resource jobScaled 'Microsoft.App/jobs@2023-04-01-preview' = {
  name: 'pipeline-scaled'
  location: location
  properties: union(defaultJobConf, {
    configuration: {
      eventTriggerConfig: {
        scale: {
          minExecutions: 0
          maxExecutions: autoscalingMaxReplicas
          pollingInterval: 15
          rules: [
            {
              name: 'azure-pipelines'
              type: 'azure-pipelines'
              metadata: {
                poolName: pipelinesPoolName
                parent: 'pipeline-${deployment().properties.template.contentVersion}'
              }
              auth: [
                {
                  secretRef: 'organization-url'
                  triggerParameter: 'organizationURL'
                }
                {
                  secretRef: 'personal-access-token'
                  triggerParameter: 'personalAccessToken'
                }
              ]
            }
          ]
        }
      }
      triggerType: 'Event'
    }
  })
}
