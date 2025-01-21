targetScope = 'resourceGroup'

param location string = resourceGroup().location
param image string
param server string
param envName string = 'poc'
param tags object = {
  environment: envName
}
param name string
param containerAppsEnvironmentResourceId string
param managedIdentityResourceId string
param workloadProfileName string = 'general-purpose'

param dbServerName string
param databaseName string
param dbServerAdminLogin string
@secure()
param dbServerAdminPassword string


module advworksApplication 'br/public:avm/res/app/container-app:0.12.0' = {
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
        env: [
          {
            name: 'ConnectionStrings__sampledbContext'
            secretRef: 'database-connection-string'
          }
        ]
      }
    ]
    registries: [
      {
        identity: managedIdentityResourceId
        server: server
      }
    ]
    scaleMinReplicas: 2
    scaleMaxReplicas: 10
    activeRevisionsMode: 'Single'
    ingressExternal: true
    ingressAllowInsecure: false
    ingressTargetPort: 80
    ingressTransport: 'auto'
    secrets: {
      secureList: [
      {
        name: 'database-connection-string'
        value: 'Server=tcp:${dbServerName}.${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${databaseName};Persist Security Info=False;User ID=${dbServerAdminLogin};Password=${dbServerAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
      }
    ]}
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The FQDN of the application deployed.')
output advworksAppFqdn string = advworksApplication.outputs.fqdn
