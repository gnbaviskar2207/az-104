targetScope = 'resourceGroup'

@description('Globally unique storage account name.')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Deployment region. Defaults to the resource group location.')
param location string = resourceGroup().location

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
])
param storageSku string = 'Standard_LRS'

@description('Common governance tags.')
param tags object = {
  workload: 'az104'
  environment: 'lab'
  managedBy: 'bicep'
}

resource storage 'Microsoft.Storage/storageAccounts@2025-06-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    defaultToOAuthAuthentication: true
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Allow'
    }
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2025-06-01' = {
  parent: storage
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    isVersioningEnabled: true
  }
}

resource evidence 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-06-01' = {
  parent: blobService
  name: 'evidence'
  properties: {
    publicAccess: 'None'
  }
}

output storageAccountId string = storage.id
output blobEndpoint string = storage.properties.primaryEndpoints.blob
