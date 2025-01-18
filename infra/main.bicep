targetScope = 'subscription'

param location string = 'northeurope'
@secure()
param password string

module hostingEnvironment 'br/public:avm/ptn/aca-lza/hosting-environment:0.2.0' = {
  name: 'hostingEnvironmentDeployment'
  params: {
    // Required parameters
    applicationGatewayCertificateKeyName: 'appgwcert'
    deploymentSubnetAddressPrefix: '10.1.4.0/24'
    enableApplicationInsights: true
    enableDaprInstrumentation: false
    spokeApplicationGatewaySubnetAddressPrefix: '10.1.3.0/24'
    spokeInfraSubnetAddressPrefix: '10.1.0.0/23'
    spokePrivateEndpointsSubnetAddressPrefix: '10.1.2.0/27'
    spokeVNetAddressPrefixes: [
      '10.1.0.0/21'
    ]
    vmAdminPassword: password
    vmJumpBoxSubnetAddressPrefix: '10.1.2.32/27'
    vmSize: 'Standard_B1s'
    // Non-required parameters
    deployZoneRedundantResources: true
    enableDdosProtection: true
    environment: 'prod'
    exposeContainerAppsWith: 'applicationGateway'
    location: location
    storageAccountType: 'Premium_LRS'
    tags: {
      environment: 'test'
    }
    vmAuthenticationType: 'sshPublicKey'
    vmJumpboxOSType: 'linux'
    workloadName: 'advworks'
  }
}

output AZURE_CONTAINERAPPSENV_RESOURCE_ID string = hostingEnvironment.outputs.containerAppsEnvironmentResourceId
output AZURE_CONTAINERREGISTRY_RESOURCE_ID string = hostingEnvironment.outputs.containerRegistryResourceId
output AZURE_KEYVAULT_RESOURCE_ID string = hostingEnvironment.outputs.keyVaultResourceId

