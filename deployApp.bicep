targetScope = 'resourceGroup'

param location string = resourceGroup().location
param image string = 'mcr.microsoft.com/azuredocs/aci-helloworld'
param envName string = 'poc'
param tags object = {
  environment: envName
}
param name string
param containerAppsEnvironmentResourceId string
param managedIdentityResourceId string
param workloadProfileName string = 'general-purpose'


module sampleApplication 'br/public:avm/res/app/container-app:0.12.0' = {
  name: 'application-deployment'
  params: {
    name: name
    location: location
    tags: tags
    environmentResourceId: containerAppsEnvironmentResourceId
    managedIdentities: {
      userAssignedResourceIds: [
        managedIdentityResourceId
      ]
    }
    workloadProfileName: workloadProfileName
    containers: [
      {
        name: name
        image: image
        resources: {
          cpu: json('0.25')
          memory: '0.5Gi'
        }
      }
    ]
    scaleMinReplicas: 2
    scaleMaxReplicas: 10
    activeRevisionsMode: 'Single'
    ingressExternal: true
    ingressAllowInsecure: false
    ingressTargetPort: 80
    ingressTransport: 'auto'
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The FQDN of the "Hello World" Container App.')
output helloWorldAppFqdn string = sampleApplication.outputs.fqdn
