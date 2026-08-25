using './main.bicep'

param storageAccountName = 'REPLACE_WITH_UNIQUE_NAME'
param storageSku = 'Standard_LRS'
param tags = {
  workload: 'az104'
  environment: 'lab'
  owner: 'student'
  managedBy: 'bicep'
}
