targetScope = 'subscription'

param location string = 'northeurope'
@secure()
param password string
@secure()
param githubpat string

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
      environment: 'prod'
    }
    vmAuthenticationType: 'sshPublicKey'
    vmJumpboxOSType: 'linux'
    workloadName: 'advworks'
  }
}

// hosted runner Jobs application
module hostedRunner 'br/public:avm/res/app/job:0.5.2' = {
  name: 'hostedRunnerDeployment'
  scope: resourceGroup('rg-advworks-spoke-prod-neu')
  params: {
    name: 'hosted-runner-job'
    location: location
    tags: {
      environment: 'prod'
    }
    environmentResourceId: hostingEnvironment.outputs.containerAppsEnvironmentResourceId
    workloadProfileName: 'general-purpose'
    triggerType: 'Event'
    replicaTimeout: 1800
    replicaRetryLimit: 0
    secrets: [
      {
        name: 'personal-access-token'
        value: githubpat
      }
    ]
    eventTriggerConfig: {
      parallelism: 1
      replicaCompletionCount: 1
      scale: {
        minExecutions: 0
        maxExecutions: 10
        pollingInterval: 30
        rules: [
          {
            name: 'github-runner'
            type: 'github-runner'
            metadata: {
              githubAPIURL: 'https://api.github.com'
              owner: 'kpantos'
              runnerScope : 'repo'
              repos: 'AdventureWorks.Web'
              targetWorkflowQueueLength: '1'
            }
            auth: [
              {
                secretRef: 'personal-access-token'
                triggerParameter: 'personalAccessToken'
              }
            ]
          }
        ]
      }
    }
    containers: [
      {
        name: 'hosted-runner-job'
        image: 'docker.io/kpantos/github-actions-runner:1.0'
        resources: {
          cpu: '2.0'
          memory: '4Gi'
        }
        env: [
          {
            name: 'GITHUB_PAT'
            secretRef: 'personal-access-token'
          }
          {
            name: 'GH_URL'
            value: 'https://github.com/kpantos/AdventureWorks.Web'
          }
          {
            name: 'REGISTRATION_TOKEN_API_URL'
            value: 'https://api.github.com/repos/kpantos/AdventureWorks.Web/actions/runners/registration-token'
          }
        ]
      }
    ]
  }
}

output AZURE_CONTAINERAPPSENV_RESOURCE_ID string = hostingEnvironment.outputs.containerAppsEnvironmentResourceId
output AZURE_CONTAINERREGISTRY_RESOURCE_ID string = hostingEnvironment.outputs.containerRegistryResourceId
output AZURE_KEYVAULT_RESOURCE_ID string = hostingEnvironment.outputs.keyVaultResourceId

