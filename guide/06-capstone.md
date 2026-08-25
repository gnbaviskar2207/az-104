# Stage 6 — Integrated capstone and mock practical

## Lab 24 — Build, secure, observe, and recover a production-style workload

**Time:** 6–10 hours across two days  
**Exam domains:** all five domains  
**Cost:** VM Scale Set, Load Balancer, public IP, private endpoint, workspace ingestion, and backup; delete after assessment

### Scenario

Contoso needs a small externally reachable web tier with no public IPs on individual compute instances. Administrators require group-based least privilege. Blob evidence must not allow anonymous access and must be reachable privately from the workload network. The environment must have governance metadata, diagnostic logs, an availability alert, and a tested recovery point. Build it first with the Portal, delete it, then rebuild the equivalent with Azure CLI. On the second pass, use Bicep for at least the network and storage account.

### Target design

- Resource groups: `az104-cap-platform-<suffix>-rg`, `az104-cap-workload-<suffix>-rg`, and `az104-cap-ops-<suffix>-rg`.
- Tags: `workload=az104-capstone`, `environment=lab`, `owner`, `costCenter=training`, and `expires`.
- Hub VNet `10.100.0.0/16`; workload spoke `10.110.0.0/16`; nonoverlapping peerings.
- Workload subnets for web, private endpoints, and optional Bastion; NSG/ASG least privilege.
- Standard public Load Balancer feeding at least two VMSS web instances; no per-instance public IPs.
- StorageV2 account: HTTPS/TLS 1.2+, no anonymous Blob, Blob soft delete/versioning/lifecycle, private Blob endpoint and private DNS.
- Microsoft Entra test group with Reader at workload-group scope and Storage Blob Data Reader at the account.
- Log Analytics workspace, diagnostic settings, Activity Log export, action group, and availability/health alert.
- Recovery Services vault and VM/instance-compatible protection strategy. If VMSS backup is not supported for the chosen mode, protect a separate management VM and document the design gap instead of pretending protection exists.
- Budget and cleanup plan.

### Theory checkpoint

Before touching the Portal, write one sentence for each decision:

1. Why the three resource groups share or do not share a lifecycle.
2. Why RBAC scope is resource group versus subscription.
3. Why the web tier uses VMSS plus Load Balancer rather than one VM.
4. Why Blob private endpoint and private DNS are both required.
5. Why diagnostics go to a central workspace and how retention/cost is bounded.
6. What the backup RPO/RTO is and how restore will be proven.
7. Which controls prevent, detect, and recover from an error.

### Portal journey

1. **Cost and identity:** Create a small monthly budget. Create `AZ104-Capstone-Readers` security group and a controlled test user. Do not use a privileged account for application access testing.
2. **Resource organization:** Create and tag the three groups. Assign Reader to the test group on the workload group. Add a `CanNotDelete` lock to the ops group only after initial deployment.
3. **Policy:** Assign Allowed locations and a tag-audit/requirement policy at the three-group scope. Start with Audit for tags and Deny only for the known-safe allowed-region rule.
4. **Networking:** Create hub/spoke VNets and two-way peering. Create web, private-endpoint, and optional `AzureBastionSubnet` subnets. Associate an NSG allowing web traffic only from the Load Balancer/client requirement and probes from `AzureLoadBalancer`; restrict admin access.
5. **Compute and traffic:** Create Standard public Load Balancer frontend, health probe, backend pool, and HTTP rule. Deploy a VMSS with two instances, nginx/bootstrap script, and no instance public IPs. Verify two different instance responses and probe health.
6. **Storage:** Create the secure account and private `evidence` container. Enable Blob versioning, blob/container soft delete, and lifecycle tiering. Assign Storage Blob Data Reader to the test group.
7. **Private access:** Create Blob private endpoint in the private-endpoint subnet, integrate `privatelink.blob.core.windows.net`, link the zone to the spoke, disable account public network access, and validate normal Blob hostname resolution from a workload VM.
8. **Monitoring:** Create workspace and diagnostic settings for storage, Load Balancer, VMSS/VMs, and Activity Log. Enable Insights/AMA/DCR where supported. Create an action group and metric alert. Test alert routing with a controlled threshold or action-group test.
9. **Protection:** Create a Recovery Services vault, policy, on-demand recovery point for a supported VM, and verify a restore-to-disks operation. Create a Backup vault and document a supported modern data source even if not protected in this architecture.
10. **Operations:** Use Activity Log, metrics, Logs, Insights, effective NSG/route views, Network Watcher, and Connection Monitor. Introduce and diagnose one NSG or probe failure.
11. **Evidence:** Capture resource IDs, deployment names, Policy compliance, role assignments, private DNS resolution, load-balancer responses, KQL result, fired/test alert, backup job, and restore result. Redact object names only when necessary; never capture secrets/SAS/keys.
12. **Cleanup:** Remove the lock, stop protection/delete lab recovery data safely, delete resource groups, test identity/group, temporary Policy assignments, and budget.

### Azure CLI implementation

Run in Bash/Cloud Shell. Read every variable before execution.

```bash
export CAP_PLATFORM_RG="az104-cap-platform-${SUFFIX}-rg"
export CAP_WORKLOAD_RG="az104-cap-workload-${SUFFIX}-rg"
export CAP_OPS_RG="az104-cap-ops-${SUFFIX}-rg"
export CAP_SA="az104cap${SUFFIX}"
export CAP_LAW="az104-cap-law-${SUFFIX}"
export CAP_VAULT="az104-cap-rsv-${SUFFIX}"

for rg in "$CAP_PLATFORM_RG" "$CAP_WORKLOAD_RG" "$CAP_OPS_RG"; do
  az group create -n "$rg" -l "$LOCATION" \
    --tags workload=az104-capstone environment=lab owner="$OWNER_TAG" costCenter=training expires="$EXPIRY_TAG"
done

# Governance: allowed location at workload group.
export CAP_SCOPE="$(az group show -n "$CAP_WORKLOAD_RG" --query id -o tsv)"
export ALLOWED_DEF="$(az policy definition list --query "[?displayName=='Allowed locations'].id | [0]" -o tsv)"
az policy assignment create -n cap-allowed-locations --scope "$CAP_SCOPE" --policy "$ALLOWED_DEF" \
  --params "{\"listOfAllowedLocations\":{\"value\":[\"${LOCATION}\"]}}"

# Identity and resource access. Substitute a group created in Entra ID.
export CAP_GROUP_ID="<capstone-group-object-id>"
az role assignment create --assignee-object-id "$CAP_GROUP_ID" --assignee-principal-type Group \
  --role Reader --scope "$CAP_SCOPE"

# Hub and spoke.
az network vnet create -g "$CAP_PLATFORM_RG" -n cap-hub-vnet -l "$LOCATION" \
  --address-prefixes 10.100.0.0/16 --subnet-name management --subnet-prefixes 10.100.1.0/24
az network vnet create -g "$CAP_WORKLOAD_RG" -n cap-spoke-vnet -l "$LOCATION" \
  --address-prefixes 10.110.0.0/16 --subnet-name web --subnet-prefixes 10.110.1.0/24
az network vnet subnet create -g "$CAP_WORKLOAD_RG" --vnet-name cap-spoke-vnet \
  -n private-endpoints --address-prefixes 10.110.2.0/24
export HUB_ID="$(az network vnet show -g "$CAP_PLATFORM_RG" -n cap-hub-vnet --query id -o tsv)"
export SPOKE_ID="$(az network vnet show -g "$CAP_WORKLOAD_RG" -n cap-spoke-vnet --query id -o tsv)"
az network vnet peering create -g "$CAP_PLATFORM_RG" --vnet-name cap-hub-vnet -n hub-to-spoke \
  --remote-vnet "$SPOKE_ID" --allow-vnet-access
az network vnet peering create -g "$CAP_WORKLOAD_RG" --vnet-name cap-spoke-vnet -n spoke-to-hub \
  --remote-vnet "$HUB_ID" --allow-vnet-access

# NSG and VM Scale Set behind Standard Load Balancer.
az network nsg create -g "$CAP_WORKLOAD_RG" -n cap-web-nsg -l "$LOCATION"
az network nsg rule create -g "$CAP_WORKLOAD_RG" --nsg-name cap-web-nsg -n Allow-HTTP \
  --priority 100 --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes Internet --destination-port-ranges 80
az network nsg rule create -g "$CAP_WORKLOAD_RG" --nsg-name cap-web-nsg -n Allow-LB-Probe \
  --priority 110 --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes AzureLoadBalancer --destination-port-ranges 80
az network vnet subnet update -g "$CAP_WORKLOAD_RG" --vnet-name cap-spoke-vnet -n web \
  --network-security-group cap-web-nsg

az network public-ip create -g "$CAP_WORKLOAD_RG" -n cap-lb-pip --sku Standard --allocation-method Static
az network lb create -g "$CAP_WORKLOAD_RG" -n cap-lb --sku Standard \
  --public-ip-address cap-lb-pip --frontend-ip-name frontend --backend-pool-name web-pool
az network lb probe create -g "$CAP_WORKLOAD_RG" --lb-name cap-lb -n http-probe \
  --protocol Http --port 80 --path / --interval 5 --probe-threshold 2
az network lb rule create -g "$CAP_WORKLOAD_RG" --lb-name cap-lb -n http-rule \
  --protocol Tcp --frontend-port 80 --backend-port 80 --frontend-ip-name frontend \
  --backend-pool-name web-pool --probe-name http-probe --enable-tcp-reset true
az vmss create -g "$CAP_WORKLOAD_RG" -n cap-web-vmss -l "$LOCATION" \
  --image Ubuntu2404 --vm-sku Standard_B1s --instance-count 2 \
  --admin-username azureadmin --generate-ssh-keys \
  --vnet-name cap-spoke-vnet --subnet web --lb cap-lb --backend-pool-name web-pool \
  --upgrade-policy-mode Automatic
az vmss extension set -g "$CAP_WORKLOAD_RG" --vmss-name cap-web-vmss \
  --publisher Microsoft.Azure.Extensions --name CustomScript --version 2.1 \
  --settings '{"commandToExecute":"apt-get update && apt-get install -y nginx && hostname > /var/www/html/index.html"}'

# Storage and data protection.
az storage account create -g "$CAP_WORKLOAD_RG" -n "$CAP_SA" -l "$LOCATION" \
  --kind StorageV2 --sku Standard_ZRS --https-only true --min-tls-version TLS1_2 \
  --allow-blob-public-access false --default-action Deny
export CAP_SA_ID="$(az storage account show -g "$CAP_WORKLOAD_RG" -n "$CAP_SA" --query id -o tsv)"
az role assignment create --assignee-object-id "$CAP_GROUP_ID" --assignee-principal-type Group \
  --role "Storage Blob Data Reader" --scope "$CAP_SA_ID"
az storage account blob-service-properties update -g "$CAP_WORKLOAD_RG" -n "$CAP_SA" \
  --enable-delete-retention true --delete-retention-days 14 \
  --enable-container-delete-retention true --container-delete-retention-days 14 \
  --enable-versioning true

# Private endpoint and DNS.
az network private-endpoint create -g "$CAP_WORKLOAD_RG" -n cap-blob-pe -l "$LOCATION" \
  --vnet-name cap-spoke-vnet --subnet private-endpoints \
  --private-connection-resource-id "$CAP_SA_ID" --group-id blob --connection-name cap-blob-connection
az network private-dns zone create -g "$CAP_PLATFORM_RG" -n privatelink.blob.core.windows.net
az network private-dns link vnet create -g "$CAP_PLATFORM_RG" -z privatelink.blob.core.windows.net \
  -n cap-spoke-link -v "$SPOKE_ID" -e false
export PRIVATE_ZONE_ID="$(az network private-dns zone show -g "$CAP_PLATFORM_RG" \
  -n privatelink.blob.core.windows.net --query id -o tsv)"
az network private-endpoint dns-zone-group create -g "$CAP_WORKLOAD_RG" --endpoint-name cap-blob-pe \
  -n blob-zone-group --private-dns-zone "$PRIVATE_ZONE_ID" --zone-name blob

# Workspace, diagnostics, action group, and alert.
az monitor log-analytics workspace create -g "$CAP_OPS_RG" -n "$CAP_LAW" -l "$LOCATION" --retention-time 30
export CAP_LAW_ID="$(az monitor log-analytics workspace show -g "$CAP_OPS_RG" -n "$CAP_LAW" --query id -o tsv)"
az monitor diagnostic-settings create -n cap-storage-metrics -r "$CAP_SA_ID" \
  --workspace "$CAP_LAW_ID" --metrics '[{"category":"AllMetrics","enabled":true}]'
export CAP_BLOB_ID="${CAP_SA_ID}/blobServices/default"
az monitor diagnostic-settings create -n cap-blob-logs -r "$CAP_BLOB_ID" \
  --workspace "$CAP_LAW_ID" --logs '[{"categoryGroup":"allLogs","enabled":true}]'
az monitor action-group create -g "$CAP_OPS_RG" -n cap-action-group --short-name capops \
  --action email Student '<your-email>'
export CAP_AG_ID="$(az monitor action-group show -g "$CAP_OPS_RG" -n cap-action-group --query id -o tsv)"
az monitor metrics alert create -g "$CAP_OPS_RG" -n cap-storage-availability \
  --scopes "$CAP_SA_ID" --condition 'avg Availability < 99' \
  --window-size 5m --evaluation-frequency 1m --severity 2 --action "$CAP_AG_ID"

# Recovery resources. Protect a supported standalone VM if VMSS mode cannot be protected as desired.
az backup vault create -g "$CAP_OPS_RG" -n "$CAP_VAULT" -l "$LOCATION" --job-failure-alerts Enable
az dataprotection backup-vault create -g "$CAP_OPS_RG" -v "az104-cap-bv-${SUFFIX}" -l "$LOCATION" \
  --storage-setting "[{type:'LocallyRedundant',datastore-type:'VaultStore'}]" \
  --mi-system-assigned --azure-monitor-alerts-for-job-failures Enabled

# Validate the public tier and private endpoint state.
export CAP_LB_IP="$(az network public-ip show -g "$CAP_WORKLOAD_RG" -n cap-lb-pip --query ipAddress -o tsv)"
for i in 1 2 3 4 5; do curl -fsS -H 'Connection: close' "http://${CAP_LB_IP}"; done
az network private-endpoint show -g "$CAP_WORKLOAD_RG" -n cap-blob-pe \
  --query 'privateLinkServiceConnections[0].privateLinkServiceConnectionState.status' -o tsv
az role assignment list --scope "$CAP_SCOPE" --include-inherited -o table
az policy state summarize --resource-group "$CAP_WORKLOAD_RG" -o jsonc
```

### PowerShell reference

PowerShell is intentionally a recognition exercise for the capstone. Identify the matching cmdlets before running them:

```powershell
New-AzResourceGroup
New-AzVirtualNetwork
Add-AzVirtualNetworkPeering
New-AzNetworkSecurityGroup
New-AzLoadBalancer
New-AzVmss
New-AzStorageAccount
New-AzPrivateEndpoint
New-AzPrivateDnsZone
New-AzOperationalInsightsWorkspace
New-AzDiagnosticSetting
New-AzRecoveryServicesVault
```

### Acceptance tests

- Two VMSS instance names appear across repeated new HTTP connections.
- No VMSS instance has a public IP.
- A higher-priority temporary NSG deny causes failure and effective-rule diagnostics identify it.
- Blob public network access is disabled; normal service FQDN resolves privately from the spoke.
- Test group has Reader at only the workload group and Blob Data Reader at only the storage account.
- Policy shows expected compliant/noncompliant results and no capstone resources exist outside allowed regions.
- Workspace receives Activity Log/platform logs or metrics; KQL returns at least one expected record.
- Action group test succeeds and alert configuration is healthy.
- Backup job succeeds and a restore-to-disks output exists for a supported protected VM.
- Cleanup leaves no capstone public IP, Bastion, VM/VMSS, private endpoint, vault data, budget, assignment, or test identity.

### Deliberate failure drills

1. Add NSG Deny HTTP priority 90; diagnose and roll back.
2. Change the health probe port to 81; inspect unhealthy backends and restore port 80.
3. Unlink private DNS; observe public resolution/failure with public access disabled, then restore the link.
4. Remove the Blob data role from the test group; distinguish authorization failure from network failure.
5. Delete and restore a versioned/soft-deleted blob.
6. Stop nginx on one instance; confirm Load Balancer removes it from new flows.

### Cleanup

```bash
# Inspect before any deletion.
for rg in "$CAP_PLATFORM_RG" "$CAP_WORKLOAD_RG" "$CAP_OPS_RG"; do
  az resource list -g "$rg" --query '[].{name:name,type:type}' -o table
done

# Remove protection/retained data and locks first; vaults will otherwise block deletion.
az policy assignment delete -n cap-allowed-locations --scope "$CAP_SCOPE"
az group delete -n "$CAP_WORKLOAD_RG" --yes --no-wait
az group delete -n "$CAP_PLATFORM_RG" --yes --no-wait
az group delete -n "$CAP_OPS_RG" --yes --no-wait
```

Do not run group deletion until backup/ASR cleanup and lock removal are confirmed. Remove the Entra test group/user and budget separately.

## Lab 25 — Timed mock practical and remediation pass

**Time:** 180 minutes build + 90 minutes review

### Rules

- Use a fresh suffix and a sandbox subscription.
- First 90 minutes: Portal only. Second 90 minutes: CLI only.
- You may use `--help` and Microsoft documentation but not this guide's command blocks.
- Record every failed hypothesis, the evidence that disproved it, and the correction.

### Tasks

1. Create two tagged resource groups, then enforce one allowed region without blocking the operations group.
2. Create a security group and give it Reader at one group; prove control-plane read but denied resource modification.
3. Create a secure StorageV2 account, private container, versioning, 7-day soft delete, lifecycle rule, and 30-minute read-only user-delegation SAS.
4. Create two VNets, nonoverlapping subnets, peering, NSG/ASG, a UDR to `None`, and a private DNS A record.
5. Create a private-only Linux VM and prove outbound HTTPS connectivity; diagnose one intentional NSG denial.
6. Deploy a Bicep file with `what-if`; modify a parameter and redeploy.
7. Create App Service with staging slot, slot-sticky setting, TLS 1.2+, scale settings, and VNet integration.
8. Create ACR and ACI or Container App using managed identity for image pull.
9. Route resource logs/metrics to a workspace, run a KQL aggregation, and create action group plus alert.
10. Create both vault types, protect a supported VM, run backup, list recovery points, and state the safest restore choice for the scenario.

### Portal journey for validation

Use Resource Graph/All resources to inventory by tag, IAM **Check access**, Policy **Compliance**, Storage **Data protection/Networking**, NIC **Effective routes/security rules**, App Service **Deployment slots/Networking**, Container **Identity/Logs**, Monitor **Diagnostic settings/Logs/Alerts**, and Backup center **Jobs/Instances/Vaults**.

### Azure CLI validation

```bash
az resource list --tag workload=az104 --query '[].{name:name,type:type,group:resourceGroup,location:location}' -o table
az role assignment list --all --include-inherited -o table
az policy state summarize -o jsonc
az storage account show -g '<rg>' -n '<account>' -o jsonc
az network nic list-effective-nsg -g '<rg>' -n '<nic>' -o jsonc
az network nic show-effective-route-table -g '<rg>' -n '<nic>' -o table
az deployment group list -g '<rg>' -o table
az webapp deployment slot list -g '<rg>' -n '<app>' -o table
az container show -g '<rg>' -n '<aci>' -o jsonc
az monitor diagnostic-settings list --resource '<resource-id>' -o jsonc
az monitor metrics alert list -g '<rg>' -o table
az backup job list -g '<rg>' -v '<vault>' -o table
```

### PowerShell reference

Use these only to recognize the equivalent validation surface after the timed Portal/CLI passes:

```powershell
Get-AzResource -TagName workload
Get-AzRoleAssignment -IncludeClassicAdministrators
Get-AzPolicyStateSummary
Get-AzStorageAccount -ResourceGroupName '<rg>' -Name '<account>'
Get-AzEffectiveNetworkSecurityGroup -ResourceGroupName '<rg>' -NetworkInterfaceName '<nic>'
Get-AzMetricAlertRuleV2 -ResourceGroupName '<rg>'
Get-AzRecoveryServicesBackupJob
```

### Scoring rubric

- **40 points — correctness:** every requested state exists and validates.
- **20 points — security:** least privilege, no anonymous data, no wildcard admin ports, managed identity, short-lived delegation.
- **15 points — reliability/recovery:** health, data protection, successful backup, defensible restore plan.
- **15 points — observability/troubleshooting:** diagnostic coverage, meaningful alert, evidence-led diagnosis.
- **10 points — hygiene:** naming/tags, repeatable commands, no secrets in history, and complete cleanup.

Score 80+ twice, with no security or cleanup critical failure, before treating the practical phase as complete.
