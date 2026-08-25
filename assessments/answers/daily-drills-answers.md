# Daily drill reference answers

These are representative starting points, not the only valid answers. Substitute controlled resource IDs and inspect current `--help`. Never paste secrets into command history.

## CLI patterns for Drills 1–15

```bash
# Context and inventory
az account set --subscription '<subscription-id>'
az account show --query '{name:name,id:id,tenant:tenantId,state:state}' -o jsonc
az resource list --tag workload=az104 \
  --query '[].{name:name,type:type,group:resourceGroup,location:location}' -o table

# Groups, tags, and locks
az group create -n rg-az104-drill -l '<location>' \
  --tags workload=az104 owner='<owner>' environment=lab expires='<yyyy-mm-dd>'
az group show -n rg-az104-drill --query 'tags.expires' -o tsv
az lock create -g rg-az104-drill -n protect-lab --lock-type CanNotDelete
az lock list -g rg-az104-drill -o table

# RBAC
az role assignment create --assignee-object-id '<object-id>' \
  --assignee-principal-type Group --role Reader --scope '<resource-group-id>'
az role assignment list --assignee '<object-id>' --all --include-inherited -o table

# Policy
az policy assignment list --disable-scope-strict-match true \
  --query '[].{name:name,scope:scope,enforcement:enforcementMode}' -o table
az policy state summarize -o jsonc

# Storage management/data state
az storage account show -g '<rg>' -n '<account>' \
  --query '{kind:kind,sku:sku.name,https:enableHttpsTrafficOnly,tls:minimumTlsVersion,publicBlob:allowBlobPublicAccess,defaultAction:networkRuleSet.defaultAction}' -o jsonc
az storage container list --account-name '<account>' --auth-mode login -o table
az storage account blob-service-properties show -g '<rg>' -n '<account>' -o jsonc

# VNets and effective state
az network vnet list --query '[].{name:name,group:resourceGroup,prefixes:addressSpace.addressPrefixes}' -o jsonc
az network vnet subnet list -g '<rg>' --vnet-name '<vnet>' -o jsonc
az network nic show-effective-route-table -g '<rg>' -n '<nic>' -o table
az network nic list-effective-nsg -g '<rg>' -n '<nic>' -o jsonc

# VM and App Service
az vm get-instance-view -g '<rg>' -n '<vm>' \
  --query '{size:hardwareProfile.vmSize,power:instanceView.statuses[1].displayStatus}' -o jsonc
az vm list-vm-resize-options -g '<rg>' -n '<vm>' -o table
az webapp show -g '<rg>' -n '<app>' \
  --query '{https:httpsOnly,host:defaultHostName,state:state,identity:identity.type}' -o jsonc
az webapp deployment slot list -g '<rg>' -n '<app>' -o table

# Containers
az acr list --query '[].{name:name,server:loginServer,admin:adminUserEnabled}' -o table
az containerapp revision list -g '<rg>' -n '<app>' -o table

# Metrics/diagnostics
az monitor metrics list --resource '<resource-id>' --metrics '<supported-metric>' -o jsonc
az monitor diagnostic-settings list --resource '<resource-id>' -o jsonc

# Backup
az backup item list -g '<rg>' -v '<vault>' -o table
az backup job list -g '<rg>' -v '<vault>' -o table
az backup recoverypoint list -g '<rg>' -v '<vault>' \
  --container-name '<container>' --item-name '<item>' --backup-management-type AzureIaasVM -o table
```

For Drill 6, compute UTC start/expiry safely, store the generated token in a protected variable, use it without echoing, and `unset` it. A correct user-delegation flow uses Entra login and suitable Blob data permissions rather than an account key.

For Drill 7, `azcopy login`, `azcopy copy '<local-path>' 'https://<account>.blob.core.windows.net/<container>/<prefix>' --recursive`, validate counts, then remove only the controlled prefix.

For Drill 10, combine `az network private-endpoint list/show`, NIC inspection, private DNS zone link/record listing, and `nslookup`/`dig` from the actual client network.

## KQL patterns for Drills 16–20

Adjust column names to the actual table schema; inspect the schema rather than forcing a memorized query.

```kusto
// Drill 16
AzureActivity
| where TimeGenerated > ago(1h)
| where ActivityStatusValue =~ "Failure"
| project TimeGenerated, Caller, OperationNameValue, ResourceGroup, ResourceId, ActivityStatusValue
| order by TimeGenerated desc
| take 100

// Drill 17
AzureActivity
| where TimeGenerated > ago(24h)
| where ActivityStatusValue =~ "Failure"
| summarize Failures=count() by OperationNameValue, ResourceGroup
| order by Failures desc

// Drill 18
Heartbeat
| summarize LastHeartbeat=max(TimeGenerated) by Computer, _ResourceId
| extend MinutesSinceHeartbeat=datetime_diff('minute', now(), LastHeartbeat)
| order by MinutesSinceHeartbeat desc

// Drill 20: adapt the predicate/table to available data
AzureActivity
| where TimeGenerated > ago(5m)
| where ActivityStatusValue =~ "Failure"
| summarize FailureCount=count()
```

For Drill 19, the correct query depends on enabled instrumentation and actual tables. Credit requires a valid table, time filter, failure predicate, aggregation, and evidence that data is arriving.

## Bicep patterns for Drills 21–27

```bash
az bicep build --file '<file>.bicep'
az deployment group validate -g '<rg>' -f '<file>.bicep' -p '<file>.bicepparam'
az deployment group what-if -g '<rg>' -f '<file>.bicep' -p '<file>.bicepparam'
az deployment group create -g '<rg>' -n '<deployment>' \
  -f '<file>.bicep' -p '<file>.bicepparam'
az deployment operation group list -g '<rg>' -n '<deployment>' -o jsonc
az group export -n '<rg>' > '<reviewed-output-path>.json'
az bicep decompile --file '<reviewed-output-path>.json'
```

Representative existing-resource pattern:

```bicep
param workspaceName string

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: workspaceName
}

output workspaceId string = workspace.id
```

Drill 28 should use JMESPath through `--query`; exact expressions depend on the chosen command's JSON shape. Credit requires correct filtering/projection/sorting and no unsafe follow-up mutation.

Drills 29–30 are outcome tests. Use the patterns above only after the timed attempt and compare resource state, not merely command spelling.
