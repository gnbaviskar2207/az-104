# Stage 5 — Monitor, maintain, back up, and recover Azure resources

## Lab 20 — Azure Monitor metrics, diagnostic settings, Logs, KQL, alerts, and processing rules

**Time:** 150 minutes plus ingestion delay  
**Exam domain:** Monitor resources in Azure  
**Cost:** Log Analytics ingestion/retention, VM, and alert evaluations; use small volumes

### Theory checkpoint

Azure Monitor metrics are numeric time-series data suited to fast near-real-time alerting. Resource logs are service-specific events sent through diagnostic settings. The subscription Activity Log records control-plane events. Log Analytics workspaces store/query logs with KQL. A diagnostic setting routes logs/metrics to destinations; it does not itself retain data.

An alert rule combines scope, signal, condition, evaluation, and severity. Action groups define notifications/automation. Alert processing rules add or suppress action groups under filters/schedules without changing the original alert logic. Azure Monitor Agent (AMA) collects guest data according to Data Collection Rules (DCRs); the legacy Log Analytics agent should not be the default for new work.

### Portal journey

1. Create a resource group, Log Analytics workspace, small StorageV2 account, and small Linux VM. Generate a few storage operations and start/stop the VM once.
2. Open **Monitor > Activity log**. Filter by resource group, operation, status, and time. Open an event and inspect caller, correlation ID, JSON, and change history.
3. On the storage account open **Diagnostic settings > Add**. Send available logs and `AllMetrics` to the workspace. Also configure the Blob service diagnostic categories if needed.
4. On the subscription **Activity log > Export Activity Logs**, create a diagnostic setting to the workspace.
5. Open **Monitor > Metrics**, scope to the storage account, chart Transactions and Availability, split by API name if available, change aggregation/time grain, and pin/save.
6. Enable **VM insights** for the VM, select the workspace, install AMA, and create/use a DCR. Inspect Performance, Map (if supported), Processes, and health.
7. Open **Logs** and run the KQL queries below. Change time range and inspect schema before assuming a table exists.
8. Create an **Action group** with an email notification you control. Create a metric alert for high VM CPU or low storage Availability. Use a realistic severity and description.
9. Create an alert processing rule that suppresses action groups for the lab VM during a short maintenance window. Understand that the alert can still fire while its actions are suppressed.
10. Review **Alerts**, alert history, fired/resolved state, action status, and rule health.

### Azure CLI implementation

```bash
export OPS_RG="az104-lab20-${SUFFIX}-rg"
export LAW="az104-law-${SUFFIX}"
export OPS_SA="az104ops${SUFFIX}"
export OPS_VM="opsvm01"
az group create -n "$OPS_RG" -l "$LOCATION" --tags workload=az104 environment=lab
az monitor log-analytics workspace create -g "$OPS_RG" -n "$LAW" -l "$LOCATION" \
  --retention-time 30
export LAW_ID="$(az monitor log-analytics workspace show -g "$OPS_RG" -n "$LAW" --query id -o tsv)"
export LAW_CUSTOMER_ID="$(az monitor log-analytics workspace show -g "$OPS_RG" -n "$LAW" --query customerId -o tsv)"

az storage account create -g "$OPS_RG" -n "$OPS_SA" -l "$LOCATION" \
  --sku Standard_LRS --kind StorageV2 --https-only true --min-tls-version TLS1_2 \
  --allow-blob-public-access false
export OPS_SA_ID="$(az storage account show -g "$OPS_RG" -n "$OPS_SA" --query id -o tsv)"
export BLOB_SERVICE_ID="${OPS_SA_ID}/blobServices/default"

# Discover valid categories, then configure only categories supported by the resource.
az monitor diagnostic-settings categories list --resource "$OPS_SA_ID" -o table
az monitor diagnostic-settings create -n storage-metrics-to-law --resource "$OPS_SA_ID" \
  --workspace "$LAW_ID" --metrics '[{"category":"AllMetrics","enabled":true}]'
az monitor diagnostic-settings categories list --resource "$BLOB_SERVICE_ID" -o table
az monitor diagnostic-settings create -n blob-logs-to-law --resource "$BLOB_SERVICE_ID" \
  --workspace "$LAW_ID" --logs '[{"categoryGroup":"allLogs","enabled":true}]'

# Subscription Activity Log diagnostic setting.
export SUB_SCOPE="/subscriptions/${SUBSCRIPTION_ID}"
az monitor diagnostic-settings create -n activity-to-law --resource "$SUB_SCOPE" \
  --workspace "$LAW_ID" --logs '[{"categoryGroup":"allLogs","enabled":true}]'

az vm create -g "$OPS_RG" -n "$OPS_VM" --image Ubuntu2404 --size Standard_B1s \
  --admin-username azureadmin --generate-ssh-keys --public-ip-address ''
export OPS_VM_ID="$(az vm show -g "$OPS_RG" -n "$OPS_VM" --query id -o tsv)"
az vm extension set -g "$OPS_RG" --vm-name "$OPS_VM" \
  --publisher Microsoft.Azure.Monitor --name AzureMonitorLinuxAgent --enable-auto-upgrade true

# Create the VM Insights DCR in Portal for the first pass, then associate/read it via CLI.
az monitor data-collection rule list -g "$OPS_RG" -o table
export DCR_ID="<vm-insights-dcr-resource-id>"
az monitor data-collection rule association create --name opsvm-dcr-association \
  --rule-id "$DCR_ID" --resource "$OPS_VM_ID"

# Platform metric inspection.
az monitor metrics list --resource "$OPS_SA_ID" --metric Transactions Availability \
  --interval PT1H --aggregation Total Average -o jsonc

# KQL after ingestion. Tables appear only after their corresponding data arrives.
az monitor log-analytics query -w "$LAW_CUSTOMER_ID" --analytics-query \
  "AzureActivity | where TimeGenerated > ago(24h) | summarize count() by OperationNameValue, ActivityStatusValue | top 10 by count_ desc"
az monitor log-analytics query -w "$LAW_CUSTOMER_ID" --analytics-query \
  "AzureMetrics | where TimeGenerated > ago(24h) | summarize Average=avg(Average) by MetricName, bin(TimeGenerated, 15m) | order by TimeGenerated desc"
az monitor log-analytics query -w "$LAW_CUSTOMER_ID" --analytics-query \
  "StorageBlobLogs | where TimeGenerated > ago(24h) | summarize Requests=count(), Failures=countif(StatusCode >= 400) by OperationName"

# Action group and metric alert.
export ALERT_EMAIL="<your-email>"
az monitor action-group create -g "$OPS_RG" -n az104-ops-ag --short-name az104ops \
  --action email Student "$ALERT_EMAIL"
export AG_ID="$(az monitor action-group show -g "$OPS_RG" -n az104-ops-ag --query id -o tsv)"
az monitor metrics alert create -g "$OPS_RG" -n storage-availability-low \
  --scopes "$OPS_SA_ID" --condition "avg Availability < 99" \
  --window-size 5m --evaluation-frequency 1m --severity 2 \
  --description 'Storage availability below objective' --action "$AG_ID"

# Maintenance suppression. Use actual UTC timestamps or a recurring window relevant to your region.
az extension add --name alertsmanagement --upgrade --allow-preview true
az monitor alert-processing-rule create -g "$OPS_RG" -n suppress-lab-vm-maintenance \
  --rule-type RemoveAllActionGroups --scopes "$OPS_VM_ID" \
  --schedule-time-zone 'India Standard Time' \
  --schedule-recurrence-type Weekly \
  --schedule-recurrence-start-time '22:00:00' \
  --schedule-recurrence-end-time '23:00:00' \
  --schedule-recurrence Saturday \
  --description 'Suppress notifications during the Saturday lab maintenance window'
```

### KQL practice

```kusto
AzureActivity
| where TimeGenerated > ago(24h)
| project TimeGenerated, Caller, OperationNameValue, ActivityStatusValue, ResourceGroup, CorrelationId
| order by TimeGenerated desc
```

```kusto
AzureMetrics
| where TimeGenerated > ago(24h)
| summarize AvgValue=avg(Average), MaxValue=max(Maximum) by ResourceId, MetricName, bin(TimeGenerated, 15m)
| order by TimeGenerated desc
```

```kusto
StorageBlobLogs
| where TimeGenerated > ago(24h)
| summarize Requests=count(), Failures=countif(StatusCode >= 400), P95=percentile(DurationMs, 95) by OperationName
| order by Failures desc
```

### PowerShell reference

```powershell
$workspace = New-AzOperationalInsightsWorkspace -ResourceGroupName $opsRg -Name $law `
  -Location $location -Sku PerGB2018
New-AzDiagnosticSetting -Name storage-metrics-to-law -ResourceId $storageId `
  -WorkspaceId $workspace.ResourceId -MetricCategory AllMetrics -Enabled $true
New-AzActionGroup -ResourceGroupName $opsRg -Name az104-ops-ag -ShortName az104ops `
  -Receiver $emailReceiver
```

### Production notes and exam tips

- Diagnostic settings are per resource/subresource and have limited destinations per setting. Discover categories rather than copying one resource's configuration to another.
- Metrics can exist without diagnostic export; exporting sends them to another destination for longer/cross-resource analysis.
- KQL `where` filters rows, `project` selects/renames columns, `summarize` aggregates, and `join` correlates tables.
- An action group is reusable. Alert processing rules control actions, not whether the alert condition becomes true.
- Control ingestion cost with targeted DCRs, transformations where supported, table plans, and defensible retention.
- Retain this resource group for Labs 21 and 22.

## Lab 21 — Resource Insights, Network Watcher, and Connection Monitor

**Time:** 120 minutes  
**Exam domain:** Monitor resources; use Network Watcher and Connection Monitor

### Theory checkpoint

Insights are curated workbooks/views over metrics, logs, dependencies, and health. VM Insights depends on AMA/DCR data. Storage Insights aggregates capacity, transactions, latency, and errors. Network Insights visualizes topology/health. Network Watcher provides targeted tools: IP flow verify, NSG diagnostics, next hop, effective routes/security rules, connection troubleshoot, packet capture, and Connection Monitor.

### Portal journey

1. Open **Monitor > Insights > Virtual Machines**. Inspect performance, guest data, map, and data gaps for `opsvm01`.
2. Open the storage account **Insights**. Identify availability, transactions, ingress/egress, latency, throttling, and server/client errors.
3. Open **Network Watcher > Topology** for the resource group. Trace VM, NIC, VNet, subnet, NSG, and route relationships.
4. Use **IP flow verify** for an inbound TCP test. Record the rule that allows/denies it.
5. Use **Next hop** for a destination such as `8.8.8.8`; compare effective route results.
6. Run **Connection troubleshoot** from the VM to `<storage>.blob.core.windows.net:443` and to a deliberately blocked port. Interpret DNS, NSG, route, and reachability results.
7. Create **Connection Monitor** from the VM to the storage endpoint port 443 with 60-second tests and the existing workspace. Wait for results and inspect reachability/latency.
8. Optional packet capture: define a short duration/size and filter. Capture only traffic you are authorized to inspect and delete the output afterward.

### Azure CLI implementation

```bash
# Ensure Network Watcher exists/enabled in the region.
az network watcher configure -g NetworkWatcherRG -l "$LOCATION" --enabled true
az network watcher list -o table

export OPS_NIC_ID="$(az vm show -g "$OPS_RG" -n "$OPS_VM" --query 'networkProfile.networkInterfaces[0].id' -o tsv)"
export OPS_NIC_NAME="${OPS_NIC_ID##*/}"
export OPS_PRIVATE_IP="$(az network nic show -g "$OPS_RG" -n "$OPS_NIC_NAME" \
  --query 'ipConfigurations[0].privateIPAddress' -o tsv)"

az network nic list-effective-nsg -g "$OPS_RG" -n "$OPS_NIC_NAME" -o jsonc
az network nic show-effective-route-table -g "$OPS_RG" -n "$OPS_NIC_NAME" -o table
az network watcher test-ip-flow -g "$OPS_RG" --vm "$OPS_VM" --direction Outbound \
  --protocol TCP --local "${OPS_PRIVATE_IP}:50000" --remote '8.8.8.8:443' -o jsonc
az network watcher show-next-hop -g "$OPS_RG" --vm "$OPS_VM" \
  --source-ip "$OPS_PRIVATE_IP" --dest-ip 8.8.8.8 -o jsonc
az network watcher test-connectivity -g "$OPS_RG" --source-resource "$OPS_VM" \
  --dest-address "${OPS_SA}.blob.core.windows.net" --dest-port 443 --protocol TCP -o jsonc

az network watcher connection-monitor create -l "$LOCATION" -n opsvm-to-storage \
  --endpoint-source-name opsvm --endpoint-source-resource-id "$OPS_VM_ID" \
  --endpoint-dest-name storage --endpoint-dest-address "${OPS_SA}.blob.core.windows.net" \
  --test-config-name tcp443 --protocol Tcp --tcp-port 443 --frequency 60
az network watcher connection-monitor show -l "$LOCATION" -n opsvm-to-storage -o jsonc

# Query Insights-relevant metrics directly.
az monitor metrics list --resource "$OPS_VM_ID" --metric 'Percentage CPU' \
  --interval PT5M --aggregation Average Maximum -o jsonc
az monitor metrics list --resource "$OPS_SA_ID" --metric Transactions Egress Ingress Availability \
  --interval PT1H --aggregation Total Average -o jsonc
```

### PowerShell reference

```powershell
Test-AzNetworkWatcherIPFlow -NetworkWatcher $networkWatcher -TargetVirtualMachineId $vmId `
  -Direction Outbound -Protocol TCP -LocalIPAddress $privateIp -LocalPort 50000 `
  -RemoteIPAddress '8.8.8.8' -RemotePort 443
Get-AzEffectiveRouteTable -NetworkInterfaceName $nicName -ResourceGroupName $opsRg
```

### Exam tips

- Start troubleshooting at the reported symptom, then check DNS, effective routes, effective NSG rules, load-balancer/backend health, guest firewall, and application listener.
- IP flow verify predicts NSG evaluation; it does not prove the application is listening.
- Connection Monitor provides ongoing measurements; Connection troubleshoot is an on-demand diagnostic.
- Network Watcher is regional. Source support/agents and permissions vary by tool.

## Lab 22 — Recovery Services vault, Backup vault, policies, backup, restore, reports, and alerts

**Time:** 150 minutes plus first backup  
**Exam domain:** Implement backup and recovery  
**Cost:** protected instance/storage and retained recovery points

### Theory checkpoint

Recovery Services vault supports workloads including Azure VM backup and Site Recovery. Backup vault (Azure Data Protection) supports newer data sources such as Blob vaulted backup, disks, PostgreSQL, and AKS according to region/support. They are different resource types. Backup policies define schedule and retention. Soft delete, immutability, multi-user authorization, private endpoints, cross-region/cross-subscription restore, and Resource Guard harden recovery.

RPO is acceptable data loss measured in time; RTO is acceptable restoration time. Backup protects recoverable data states; Site Recovery replicates/orchestrates workload continuity. High availability is not backup.

### Portal journey

1. Create a **Recovery Services vault** in the same region as the Lab 20 VM. Under **Properties**, inspect storage replication, soft delete/security, immutability, cross-subscription restore, and public network access. Make irreversible settings only in a sandbox after reading warnings.
2. Open **Backup > Azure > Azure Virtual Machine > Backup**. Create policy `az104-daily`: daily schedule and a short lab retention that still meets allowed minimums.
3. Enable backup for `opsvm01`, run **Backup now**, choose a valid retention date, and monitor **Backup Jobs** until success.
4. Stop/deallocate or alter the VM only after the recovery point exists. Open **Restore VM** and compare Create new VM, Restore disks, and Replace existing. Use **Restore disks** into a separate restore group/storage staging path.
5. Inspect the generated template/scripts and recovered disks. Do not attach a recovered OS disk to the original VM blindly.
6. Create a **Backup vault** in the same group with LRS VaultStore and system-assigned identity. Inspect supported data sources and built-in Azure Monitor job-failure alerts.
7. Open **Backup center**. Review Jobs, Backup instances, Policies, Vaults, Reports, and Alerts. Configure reports to the existing Log Analytics workspace and review the provided workbook after data arrives.
8. Create or inspect Azure Monitor alert rules for backup job failure and action groups. Distinguish classic alerts from current Azure Monitor alerts.
9. Stop protection and delete backup data only during cleanup, acknowledging soft-delete/immutability consequences.

### Azure CLI implementation

```bash
export RSV="az104-rsv-${SUFFIX}"
export BV="az104-bv-${SUFFIX}"
az backup vault create -g "$OPS_RG" -n "$RSV" -l "$LOCATION" \
  --job-failure-alerts Enable --tags workload=az104 environment=lab
az backup vault backup-properties set -g "$OPS_RG" -n "$RSV" \
  --backup-storage-redundancy LocallyRedundant --soft-delete-feature-state Enable

# Start from the default VM policy, then inspect/modify JSON for a custom policy exercise.
az backup policy list -g "$OPS_RG" -v "$RSV" --backup-management-type AzureIaasVM -o table
az backup policy show -g "$OPS_RG" -v "$RSV" -n DefaultPolicy -o jsonc
az backup protection enable-for-vm -g "$OPS_RG" -v "$RSV" \
  --vm "$OPS_VM" --policy-name DefaultPolicy

# Discover the actual container/item names; do not assume display names equal internal names.
az backup container list -g "$OPS_RG" -v "$RSV" --backup-management-type AzureIaasVM \
  --query '[].{friendly:properties.friendlyName,name:name}' -o table
az backup item list -g "$OPS_RG" -v "$RSV" --backup-management-type AzureIaasVM \
  --workload-type VM --query '[].{friendly:properties.friendlyName,name:name,state:properties.protectionState}' -o table
export BACKUP_CONTAINER="$(az backup container list -g "$OPS_RG" -v "$RSV" \
  --backup-management-type AzureIaasVM --query "[?properties.friendlyName=='${OPS_VM}'].name | [0]" -o tsv)"
export BACKUP_ITEM="$(az backup item list -g "$OPS_RG" -v "$RSV" \
  --backup-management-type AzureIaasVM --workload-type VM \
  --query "[?properties.friendlyName=='${OPS_VM}'].name | [0]" -o tsv)"
export RETAIN_UNTIL="$(date -u -d '+30 days' +%d-%m-%Y 2>/dev/null || echo '31-12-2026')"
az backup protection backup-now -g "$OPS_RG" -v "$RSV" \
  --container-name "$BACKUP_CONTAINER" --item-name "$BACKUP_ITEM" \
  --backup-management-type AzureIaasVM --retain-until "$RETAIN_UNTIL"
az backup job list -g "$OPS_RG" -v "$RSV" \
  --query '[].{operation:properties.operation,status:properties.status,start:properties.startTime}' -o table

# List recovery points. Perform restore-disks after a successful recovery point exists.
az backup recoverypoint list -g "$OPS_RG" -v "$RSV" \
  --container-name "$BACKUP_CONTAINER" --item-name "$BACKUP_ITEM" \
  --backup-management-type AzureIaasVM -o table
# export RP_NAME='<recovery-point-name>'
# export STAGING_SA='<separate-staging-storage-account>'
# az backup restore restore-disks -g "$OPS_RG" -v "$RSV" \
#   --container-name "$BACKUP_CONTAINER" --item-name "$BACKUP_ITEM" \
#   --rp-name "$RP_NAME" --storage-account "$STAGING_SA" --target-resource-group "$OPS_RG"

# Create the distinct Azure Data Protection Backup vault.
az extension add --name dataprotection --upgrade
az dataprotection backup-vault create -g "$OPS_RG" -v "$BV" -l "$LOCATION" \
  --storage-setting "[{type:'LocallyRedundant',datastore-type:'VaultStore'}]" \
  --mi-system-assigned --azure-monitor-alerts-for-job-failures Enabled \
  --tags workload=az104 environment=lab
az dataprotection backup-vault show -g "$OPS_RG" -v "$BV" -o jsonc

az backup job list -g "$OPS_RG" -v "$RSV" -o table
az dataprotection job list-from-resourcegraph \
  --subscriptions "$SUBSCRIPTION_ID" --resource-groups "$OPS_RG" -o table
```

### PowerShell reference

```powershell
$vault = New-AzRecoveryServicesVault -Name $rsv -ResourceGroupName $opsRg -Location $location
Set-AzRecoveryServicesVaultContext -Vault $vault
$policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name DefaultPolicy
Enable-AzRecoveryServicesBackupProtection -ResourceGroupName $opsRg -Name $opsVm -Policy $policy
$container = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -FriendlyName $opsVm
$item = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM
Backup-AzRecoveryServicesBackupItem -Item $item -ExpiryDateTimeUTC (Get-Date).ToUniversalTime().AddDays(30)
```

### Production notes and exam tips

- Vault and protected resource region/support rules matter. Select redundancy before protection where required.
- Soft delete is a safety control; immutability can become irreversible when locked.
- Backup jobs, backup alerts, and restore drills are operational requirements. A green policy assignment alone does not prove recoverability.
- Restore disks provides maximum control; create new VM is convenient; replace existing is highest risk.
- Do not delete `$OPS_RG` yet if you will complete Site Recovery. Otherwise stop protection, remove retained data per sandbox policy, and delete paid resources.

## Lab 23 — Azure Site Recovery, test failover, failover, reprotection, and cleanup

**Time:** 3–6 hours including initial replication  
**Exam domain:** Configure Site Recovery, perform failover, interpret reports/alerts  
**Cost:** replicated disks, cache storage, target networking, vault, and temporary test VM

### Theory checkpoint

Azure-to-Azure Site Recovery replicates VM disks asynchronously and orchestrates recovery. A recovery plan orders groups and automation/manual steps. Test failover validates recovery in an isolated network without changing replication direction. Planned failover aims for minimal data loss when source is available; unplanned failover handles outage. After failover, commit finalizes the selected recovery point; reprotect reverses replication before failback.

Define RPO/RTO, dependency order, IP/DNS changes, capacity/quotas, target RBAC/Policy, encryption keys, and communication plans before an incident. Test failover is essential evidence, not optional ceremony.

### Portal journey

1. Confirm source and target regions support Azure-to-Azure Site Recovery and the VM meets disk/OS/network prerequisites. Create a target VNet with nonoverlapping address space in the target region.
2. Use a Recovery Services vault in a supported region. Open **Site Recovery > Enable replication**.
3. Select source region, subscription, resource group, deployment model, and `opsvm01`. Select target region, target group, VNet/subnet, availability, storage, cache, and replication policy.
4. Review disk inclusion and encryption/key requirements. Enable replication and monitor the Site Recovery job until protected and healthy.
5. Open **Replicated items > opsvm01**. Inspect replication health, latest recovery points, RPO, target properties, compute/network settings, and jobs.
6. Create an isolated test-failover VNet with no route to production. Run **Test failover** to the latest app-consistent or crash-consistent recovery point. Validate boot, service, data, network, monitoring, and access.
7. Select **Cleanup test failover**, record test notes, and verify temporary resources are removed.
8. In a dedicated sandbox only, perform failover to the target, validate, then **Commit**. Understand that commit prevents choosing a different recovery point for that failover.
9. **Re-protect** to establish reverse replication before planning failback.
10. Review Site Recovery **Jobs**, **Events**, vault health, Azure Monitor alerts, and notification settings.

### Azure CLI implementation

The Site Recovery CLI is a GA extension, but Azure-to-Azure setup is ID-heavy. Use variables from live queries and save reviewed provider JSON; never paste guessed resource IDs. The sequence below is the CLI counterpart to the Portal workflow.

```bash
az extension add --name site-recovery --upgrade
export ASR_RG="az104-lab23-${SUFFIX}-rg"
export ASR_VAULT="az104-asr-${SUFFIX}"
export SOURCE_REGION="$LOCATION"
export TARGET_REGION="$LOCATION2"
export SOURCE_FABRIC="${SOURCE_REGION}-fabric"
export TARGET_FABRIC="${TARGET_REGION}-fabric"
export SOURCE_CONTAINER="${SOURCE_REGION}-container"
export TARGET_CONTAINER="${TARGET_REGION}-container"
export ASR_POLICY="az104-a2a-policy"

az group create -n "$ASR_RG" -l "$SOURCE_REGION" --tags workload=az104 environment=lab
az backup vault create -g "$ASR_RG" -n "$ASR_VAULT" -l "$SOURCE_REGION" \
  --job-failure-alerts Enable
az network vnet create -g "$ASR_RG" -n recovery-vnet -l "$TARGET_REGION" \
  --address-prefixes 10.90.0.0/16 --subnet-name recovery-subnet --subnet-prefixes 10.90.1.0/24
export RECOVERY_VNET_ID="$(az network vnet show -g "$ASR_RG" -n recovery-vnet --query id -o tsv)"
export RECOVERY_RG_ID="$(az group show -n "$ASR_RG" --query id -o tsv)"
export SOURCE_VM_ID="$OPS_VM_ID"
export SOURCE_OS_DISK_ID="$(az vm show --ids "$SOURCE_VM_ID" --query 'storageProfile.osDisk.managedDisk.id' -o tsv)"

# Build the A2A fabrics, containers, and policy.
az site-recovery fabric create -g "$ASR_RG" --vault-name "$ASR_VAULT" \
  -n "$SOURCE_FABRIC" --custom-details "{azure:{location:${SOURCE_REGION}}}"
az site-recovery fabric create -g "$ASR_RG" --vault-name "$ASR_VAULT" \
  -n "$TARGET_FABRIC" --custom-details "{azure:{location:${TARGET_REGION}}}"
az site-recovery protection-container create -g "$ASR_RG" --vault-name "$ASR_VAULT" \
  --fabric-name "$SOURCE_FABRIC" -n "$SOURCE_CONTAINER" --provider-input '[{instance-type:A2A}]'
az site-recovery protection-container create -g "$ASR_RG" --vault-name "$ASR_VAULT" \
  --fabric-name "$TARGET_FABRIC" -n "$TARGET_CONTAINER" --provider-input '[{instance-type:A2A}]'
az site-recovery policy create -g "$ASR_RG" --vault-name "$ASR_VAULT" -n "$ASR_POLICY" \
  --provider-specific-input '{a2a:{multi-vm-sync-status:Enable}}'
export POLICY_ID="$(az site-recovery policy show -g "$ASR_RG" --vault-name "$ASR_VAULT" \
  -n "$ASR_POLICY" --query id -o tsv)"
export TARGET_CONTAINER_ID="$(az site-recovery protection-container show -g "$ASR_RG" \
  --vault-name "$ASR_VAULT" --fabric-name "$TARGET_FABRIC" -n "$TARGET_CONTAINER" --query id -o tsv)"

# Create a cache storage account in the source region.
export CACHE_SA="az104asrcache${SUFFIX}"
az storage account create -g "$ASR_RG" -n "$CACHE_SA" -l "$SOURCE_REGION" \
  --sku Standard_LRS --kind StorageV2 --https-only true
export CACHE_SA_ID="$(az storage account show -g "$ASR_RG" -n "$CACHE_SA" --query id -o tsv)"

# Enable protection. Include every protected disk in vm-managed-disks.
export PROTECTED_NAME="opsvm01-protected"
export PROVIDER_DETAILS="{a2a:{fabric-object-id:${SOURCE_VM_ID},vm-managed-disks:[{disk-id:${SOURCE_OS_DISK_ID},primary-staging-azure-storage-account-id:${CACHE_SA_ID},recovery-resource-group-id:${RECOVERY_RG_ID}}],recovery-azure-network-id:${RECOVERY_VNET_ID},recovery-container-id:${TARGET_CONTAINER_ID},recovery-resource-group-id:${RECOVERY_RG_ID},recovery-subnet-name:recovery-subnet}}"
az site-recovery protected-item create -g "$ASR_RG" --vault-name "$ASR_VAULT" \
  --fabric-name "$SOURCE_FABRIC" --protection-container "$SOURCE_CONTAINER" \
  -n "$PROTECTED_NAME" --policy-id "$POLICY_ID" --provider-details "$PROVIDER_DETAILS" --no-wait

az site-recovery job list -g "$ASR_RG" --vault-name "$ASR_VAULT" \
  --query '[].{name:name,state:properties.state,display:properties.displayName}' -o table
az site-recovery protected-item show -g "$ASR_RG" --vault-name "$ASR_VAULT" \
  --fabric-name "$SOURCE_FABRIC" --protection-container "$SOURCE_CONTAINER" \
  -n "$PROTECTED_NAME" -o jsonc

# Failover commands are deliberately not automatic. Run only after a healthy replication and approved test plan.
# az site-recovery protected-item unplanned-failover -g "$ASR_RG" --vault-name "$ASR_VAULT" \
#   --fabric-name "$SOURCE_FABRIC" --protection-container "$SOURCE_CONTAINER" \
#   -n "$PROTECTED_NAME" --failover-direction PrimaryToRecovery \
#   --provider-details '{a2a:{}}' --source-site-operations NotRequired
# az site-recovery protected-item failover-commit -g "$ASR_RG" --vault-name "$ASR_VAULT" \
#   --fabric-name "$SOURCE_FABRIC" --protection-container "$SOURCE_CONTAINER" -n "$PROTECTED_NAME"
# az site-recovery protected-item reprotect ...

# Clean disable is 'remove', not force 'delete'. Do this only after test/failover work is complete.
# az site-recovery protected-item remove -g "$ASR_RG" --vault-name "$ASR_VAULT" \
#   --fabric-name "$SOURCE_FABRIC" --protection-container "$SOURCE_CONTAINER" -n "$PROTECTED_NAME"
```

If your extension's A2A provider schema differs, run `az site-recovery protected-item create --help` and use the current official example. The Azure resource IDs and provider details are workload-specific by design.

### PowerShell reference

```powershell
$vault = Get-AzRecoveryServicesVault -ResourceGroupName $asrRg -Name $asrVault
Set-AzRecoveryServicesAsrVaultContext -Vault $vault
Get-AzRecoveryServicesAsrJob
Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $container
Start-AzRecoveryServicesAsrTestFailoverJob -ReplicationProtectedItem $protectedItem `
  -Direction PrimaryToRecovery -AzureVMNetworkId $testVnetId
```

### Production notes and exam tips

- Test failover should use an isolated network and does not stop ongoing replication.
- Commit is a decision point; perform validation before committing.
- Reprotect reverses protection after failover. Failback is a planned operational process, not an automatic undo.
- Added VM data disks may require explicit protection after replication is already enabled.
- Backup restores a point in time; Site Recovery targets workload continuity. Many critical systems need both.

### Cleanup

1. Clean up any test failover.
2. Disable replication with **Remove**, not force-delete, and wait for the job.
3. Stop VM backup protection and delete retained lab data if policy permits.
4. Delete empty vaults only after protected items, soft-deleted items, fabrics/containers/mappings, private endpoints, and registrations are removed.
5. Delete `$ASR_RG`, then the retained `$OPS_RG` after confirming no non-lab resources are present.
