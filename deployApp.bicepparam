using './deployApp.bicep'

param location = 'northeurope'
param envName = 'prod'
param tags = {
  environment: envName
}
param name = 'advworks-app'
param containerAppsEnvironmentResourceId = '/subscriptions/f38945b8-4230-4b55-8c25-e2304297e2f8/resourceGroups/rg-advworks-spoke-prod-neu/providers/Microsoft.App/managedEnvironments/cae-advworks-prod-neu'
param managedIdentityResourceId = '/subscriptions/f38945b8-4230-4b55-8c25-e2304297e2f8/resourceGroups/rg-advworks-spoke-prod-neu/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-cradvworksdbqyjprodneu-AcrPull'
param workloadProfileName = 'general-purpose'

