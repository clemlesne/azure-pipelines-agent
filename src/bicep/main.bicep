param autoscalingMaxReplicas int = 100
param extraEnv array = []
param imageFlavor string = 'bullseye'
param imageName string = 'clemlesne/azure-pipelines-agent'
param imageRegistry string = 'docker.io'
param imageVersion string
param location string
param pipelinesCapabilities array = []
param pipelinesOrganizationURL string
@secure()
param pipelinesPersonalAccessToken string
param pipelinesPoolName string
param pipelinesTimeout int = 3600
param prefix string

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: prefix
  location: location
}

module app 'app.bicep' = {
  name: '${rg.name}-app'
  scope: rg
  params: {
    autoscalingMaxReplicas: autoscalingMaxReplicas
    extraEnv: extraEnv
    imageFlavor: imageFlavor
    imageName: imageName
    imageRegistry: imageRegistry
    imageVersion: imageVersion
    location: location
    pipelinesCapabilities: pipelinesCapabilities
    pipelinesOrganizationURL: pipelinesOrganizationURL
    pipelinesPersonalAccessToken: pipelinesPersonalAccessToken
    pipelinesPoolName: pipelinesPoolName
    pipelinesTimeout: pipelinesTimeout
  }
}
