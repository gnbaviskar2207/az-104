# Stage 2 — Implement and manage storage

## Lab 6 — Secure storage-account baseline and authorization models

**Time:** 75 minutes  
**Exam domain:** Implement and manage storage  
**Cost:** pennies for small test data

### Theory checkpoint

A general-purpose v2 account can expose Blob, Files, Queue, and Table services. Account kind, performance tier, redundancy, region, access tier, hierarchical namespace, and networking choices affect supported features and cost. Control-plane RBAC such as Contributor does not automatically grant blob/file data access. Prefer Entra ID with data-plane RBAC, use short-lived user-delegation SAS when delegation is required, and treat account keys as high-privilege shared secrets.

Secure defaults for production include TLS 1.2 or later, HTTPS only, public blob access disabled, shared-key authorization disabled when compatible, no anonymous containers, restricted networking, diagnostic settings, soft delete/versioning where needed, and least-privilege data roles.

### Portal journey

1. Create a dedicated resource group, then **Storage accounts > Create**.
2. Choose **Standard**, **StorageV2**, and locally redundant storage for the lab. On **Advanced**, require secure transfer, set minimum TLS 1.2, disallow Blob anonymous access, and prefer Microsoft Entra authorization in the portal.
3. Leave public network access enabled only for this first exercise. Do not enable hierarchical namespace because later object replication exercises have feature constraints.
4. Create the account. Inspect **Configuration**, **Redundancy**, **Encryption**, **Networking**, **Access keys**, **Shared access signature**, and **Access control (IAM)**.
5. In **IAM**, assign your user **Storage Blob Data Contributor** at the account scope. Wait for propagation.
6. Open **Data storage > Containers**, create private container `evidence`, and upload a small text file using Entra user credentials.
7. Open **Storage browser** in the Portal and verify the blob. Compare what is visible before and after the data role assignment.
8. Rotate one access key only after checking whether anything depends on it; in this sandbox nothing should. Observe that two keys enable staged rotation.

### Azure CLI implementation

```bash
export STORAGE_RG="az104-lab06-${SUFFIX}-rg"
export STORAGE_ACCOUNT="az104st${SUFFIX}"
az group create -n "$STORAGE_RG" -l "$LOCATION" --tags workload=az104 environment=lab
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$STORAGE_RG" \
  --location "$LOCATION" \
  --kind StorageV2 \
  --sku Standard_LRS \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --default-action Allow

export STORAGE_ID="$(az storage account show -g "$STORAGE_RG" -n "$STORAGE_ACCOUNT" --query id -o tsv)"
export MY_OBJECT_ID="$(az ad signed-in-user show --query id -o tsv)"
az role assignment create --assignee-object-id "$MY_OBJECT_ID" --assignee-principal-type User \
  --role "Storage Blob Data Contributor" --scope "$STORAGE_ID"

# RBAC propagation can take several minutes.
az storage container create --account-name "$STORAGE_ACCOUNT" --name evidence --auth-mode login
printf 'AZ-104 storage evidence\n' > /tmp/az104-evidence.txt
az storage blob upload --account-name "$STORAGE_ACCOUNT" --container-name evidence \
  --name evidence.txt --file /tmp/az104-evidence.txt --auth-mode login --overwrite
az storage blob list --account-name "$STORAGE_ACCOUNT" --container-name evidence \
  --auth-mode login --query '[].{name:name,tier:properties.blobTier,size:properties.contentLength}' -o table

# Inspect settings without exposing keys.
az storage account show -g "$STORAGE_RG" -n "$STORAGE_ACCOUNT" \
  --query '{kind:kind,sku:sku.name,tls:minimumTlsVersion,https:enableHttpsTrafficOnly,publicBlob:allowBlobPublicAccess,keyAccess:allowSharedKeyAccess}' -o yaml
az storage account keys list -g "$STORAGE_RG" -n "$STORAGE_ACCOUNT" --query '[].keyName' -o table

# Practice staged key rotation in the sandbox. Do not display the new key.
az storage account keys renew -g "$STORAGE_RG" -n "$STORAGE_ACCOUNT" --key primary \
  --query keyName -o tsv
```

Do not disable shared-key access yet because Lab 7 uses a stored access policy, which is a service-SAS mechanism. After Lab 7, set `--allow-shared-key-access false` and validate that Entra/RBAC operations still work.

### PowerShell reference

```powershell
New-AzStorageAccount -ResourceGroupName $storageRg -Name $storageAccount -Location $location `
  -SkuName Standard_LRS -Kind StorageV2 -EnableHttpsTrafficOnly $true -MinimumTlsVersion TLS1_2 `
  -AllowBlobPublicAccess $false
New-AzRoleAssignment -ObjectId $myObjectId -RoleDefinitionName 'Storage Blob Data Contributor' `
  -Scope $storageId
$ctx = New-AzStorageContext -StorageAccountName $storageAccount -UseConnectedAccount
New-AzStorageContainer -Name evidence -Context $ctx -Permission Off
```

### Validation, production notes, and exam tips

- Upload and list a blob with `--auth-mode login`; this proves data-plane RBAC.
- Reader or Contributor alone is not a blob data role. Identify `DataActions` in storage roles.
- Key regeneration immediately invalidates clients using that key. Rotate key1, update clients, then key2.
- Disabling shared-key access blocks account-key and service/account SAS authorization but not Entra user-delegation SAS.
- The account name is globally unique, 3–24 lowercase letters/numbers.
- Do not clean up yet; Labs 7 and 8 reuse this account.

## Lab 7 — Blob tiers, lifecycle, versioning, soft delete, SAS, and stored access policies

**Time:** 100 minutes  
**Exam domain:** Configure Azure Files and Blob Storage; configure access to storage

### Theory checkpoint

Hot, cool, cold, and archive tiers trade storage cost against access/rehydration cost and minimum retention periods. Archive is offline. Lifecycle policies apply rule-based tiering/deletion to base blobs and optionally versions/snapshots. Versioning creates a previous version when a block blob changes. Soft delete protects deleted blobs/containers for a retention window but is not a full backup strategy.

A SAS delegates constrained access. Account SAS spans services; service SAS targets one service/resource; user-delegation SAS is signed with Entra credentials and is preferred for Blob. Stored access policies group permissions/expiry for service SAS and provide revocation, but not for account SAS or user-delegation SAS.

### Portal journey

1. Open the Lab 6 account **Data protection**. Enable blob soft delete (7 days), container soft delete (7 days), versioning, and change feed. Save.
2. Open `evidence`, upload a revised `evidence.txt`, and inspect **Versions**. Delete the current blob, show deleted blobs, and restore it.
3. Change the blob access tier to **Cool**. Explain why Archive would break immediate reads.
4. Go to **Lifecycle management > Add rule**. Scope to block blobs under prefix `evidence/archive/`; move base blobs to cool after 30 days and delete versions after 90 days. Review the generated JSON.
5. Open the container **Access policy > Add policy**, name it `read-policy`, grant Read/List, and use a near-term expiry.
6. Generate a service SAS tied to that policy for a disposable test. Test its URL without signing into Azure, then revoke it by deleting/changing the stored policy. Never capture the token in screenshots.
7. Separately generate a user-delegation SAS with minimal read/list permissions and a short expiry; compare its signing method and revocation characteristics.

### Azure CLI implementation

```bash
az storage account blob-service-properties update \
  --account-name "$STORAGE_ACCOUNT" --resource-group "$STORAGE_RG" \
  --enable-delete-retention true --delete-retention-days 7 \
  --enable-container-delete-retention true --container-delete-retention-days 7 \
  --enable-versioning true --enable-change-feed true

printf 'AZ-104 storage evidence version 2\n' > /tmp/az104-evidence-v2.txt
az storage blob upload --account-name "$STORAGE_ACCOUNT" --container-name evidence \
  --name evidence.txt --file /tmp/az104-evidence-v2.txt --auth-mode login --overwrite
az storage blob list --account-name "$STORAGE_ACCOUNT" --container-name evidence \
  --include v --auth-mode login \
  --query "[?name=='evidence.txt'].{name:name,versionId:versionId,current:isCurrentVersion}" -o table
az storage blob set-tier --account-name "$STORAGE_ACCOUNT" --container-name evidence \
  --name evidence.txt --tier Cool --auth-mode login

# Lifecycle policy as a reviewed JSON artifact.
cat > /tmp/az104-lifecycle.json <<'EOF'
{
  "rules": [
    {
      "enabled": true,
      "name": "tier-and-expire-lab-evidence",
      "type": "Lifecycle",
      "definition": {
        "actions": {
          "baseBlob": {"tierToCool": {"daysAfterModificationGreaterThan": 30}},
          "version": {"delete": {"daysAfterCreationGreaterThan": 90}}
        },
        "filters": {"blobTypes": ["blockBlob"], "prefixMatch": ["evidence/archive/"]}
      }
    }
  ]
}
EOF
az storage account management-policy create -g "$STORAGE_RG" -n "$STORAGE_ACCOUNT" \
  --policy @/tmp/az104-lifecycle.json
az storage account management-policy show -g "$STORAGE_RG" -n "$STORAGE_ACCOUNT" -o jsonc

# Create a stored access policy. This needs shared-key authorization for the exercise.
export POLICY_EXPIRY="$(date -u -d '+2 hours' +%Y-%m-%dT%H:%MZ 2>/dev/null || echo '2026-12-31T23:59Z')"
export ACCOUNT_KEY="$(az storage account keys list -g "$STORAGE_RG" -n "$STORAGE_ACCOUNT" --query '[0].value' -o tsv)"
az storage container policy create --account-name "$STORAGE_ACCOUNT" --container-name evidence \
  --name read-policy --permissions rl --expiry "$POLICY_EXPIRY" --account-key "$ACCOUNT_KEY"

# Generate the service SAS without printing it; use it immediately and then unset it.
export SERVICE_SAS="$(az storage container generate-sas --account-name "$STORAGE_ACCOUNT" \
  --name evidence --policy-name read-policy --account-key "$ACCOUNT_KEY" -o tsv)"
curl -fsS "https://${STORAGE_ACCOUNT}.blob.core.windows.net/evidence?restype=container&comp=list&${SERVICE_SAS}" >/tmp/az104-sas-result.xml

# Revoke every SAS associated with this stored policy by deleting the policy.
az storage container policy delete --account-name "$STORAGE_ACCOUNT" --container-name evidence \
  --name read-policy --account-key "$ACCOUNT_KEY"
unset SERVICE_SAS ACCOUNT_KEY

# User-delegation SAS: Entra-backed, short-lived, and preferred for Blob delegation.
export UD_EXPIRY="$(date -u -d '+30 minutes' +%Y-%m-%dT%H:%MZ 2>/dev/null || echo '2026-12-31T23:59Z')"
export USER_SAS="$(az storage blob generate-sas --account-name "$STORAGE_ACCOUNT" \
  --container-name evidence --name evidence.txt --permissions r --expiry "$UD_EXPIRY" \
  --auth-mode login --as-user -o tsv)"
curl -fsS "https://${STORAGE_ACCOUNT}.blob.core.windows.net/evidence/evidence.txt?${USER_SAS}"
unset USER_SAS
```

### PowerShell reference

```powershell
Update-AzStorageBlobServiceProperty -ResourceGroupName $storageRg -StorageAccountName $storageAccount `
  -EnableVersioning $true -EnableChangeFeed $true -DeleteRetentionPolicyEnabled $true `
  -DeleteRetentionPolicyDays 7 -ContainerDeleteRetentionPolicyEnabled $true `
  -ContainerDeleteRetentionPolicyDays 7
Set-AzStorageBlobContent -File ./evidence.txt -Container evidence -Blob evidence.txt -Context $ctx -Force
Get-AzStorageBlob -Container evidence -Context $ctx -IncludeVersion
```

### Exam tips

- Stored access policies can revoke or change groups of service SAS tokens. Rotating an account key revokes SAS signed with that key but is much more disruptive.
- User-delegation SAS is Blob-only and has a maximum validity bounded by the user-delegation key.
- Versioning does not protect containers or every blob type; combine it with soft delete and proper backup/governance.
- Lifecycle actions are asynchronous and do not run immediately when a rule is created.

## Lab 8 — Azure Files, snapshots, soft delete, identity access, Storage Explorer, and AzCopy

**Time:** 100 minutes  
**Exam domain:** Configure Azure Files; manage data by Storage Explorer and AzCopy  
**Licensing/domain note:** full identity-based SMB authentication requires a supported identity source and client setup

### Theory checkpoint

Azure Files offers managed SMB and NFS shares. Capacity, transaction patterns, redundancy, protocol, and tier affect cost/performance. Share-level Azure RBAC and file/directory ACLs are distinct authorization layers for identity-based SMB. Storage account keys grant broad access and should not be the production default. Share snapshots are read-only point-in-time copies; soft delete protects deleted shares.

### Portal journey

1. In the Lab 6 account open **Data storage > File shares > Create file share**. Name it `profiles`, choose transaction optimized or hot, and set a small quota.
2. Upload two files with **Storage browser**. Create a directory `user01`.
3. Open **Data protection** for Files and enable share soft delete for 7 days.
4. Open the share **Snapshots > Add snapshot**. Change/delete a test file, browse the snapshot, and restore by copying it back.
5. Open **File shares > Identity-based access**. Inspect Microsoft Entra Kerberos, AD DS, and Entra Domain Services options. Enable only if using a disposable domain-capable test tenant and supported client.
6. Assign your test group **Storage File Data SMB Share Contributor** at the storage-account or share scope. Explain why SMB ACLs may still restrict access.
7. In Azure Storage Explorer, sign in with your Entra account, select the account, browse the Blob container and file share, upload/download a file, and inspect properties. Do not attach using an account key unless specifically testing key authorization.
8. Delete the share, view **Deleted shares**, and restore it within the retention period.

### Azure CLI implementation

```bash
az storage account file-service-properties update -g "$STORAGE_RG" -n "$STORAGE_ACCOUNT" \
  --enable-delete-retention true --delete-retention-days 7
az storage share-rm create -g "$STORAGE_RG" --storage-account "$STORAGE_ACCOUNT" \
  --name profiles --quota 10 --enabled-protocols SMB --access-tier TransactionOptimized

printf 'profile evidence\n' > /tmp/profile.txt
az storage directory create --account-name "$STORAGE_ACCOUNT" --share-name profiles \
  --name user01 --auth-mode login
az storage file upload --account-name "$STORAGE_ACCOUNT" --share-name profiles \
  --source /tmp/profile.txt --path user01/profile.txt --auth-mode login

export SNAPSHOT="$(az storage share snapshot --account-name "$STORAGE_ACCOUNT" \
  --name profiles --auth-mode login --query snapshot -o tsv)"
az storage share list --account-name "$STORAGE_ACCOUNT" --include-snapshots --auth-mode login \
  --query '[].{name:name,snapshot:snapshot,quota:properties.quota}' -o table

# Share-level data role. Substitute the controlled test group ID.
export FILE_PRINCIPAL_ID="<test-group-object-id>"
az role assignment create --assignee-object-id "$FILE_PRINCIPAL_ID" --assignee-principal-type Group \
  --role "Storage File Data SMB Share Contributor" --scope "$STORAGE_ID"

# Inspect identity configuration. Enabling Entra Kerberos is optional and tenant/client dependent.
az storage account show -g "$STORAGE_RG" -n "$STORAGE_ACCOUNT" \
  --query 'azureFilesIdentityBasedAuthentication' -o jsonc
# az storage account update -g "$STORAGE_RG" -n "$STORAGE_ACCOUNT" --enable-files-aadkerb true

# AzCopy with Entra login; do not embed SAS in scripts.
azcopy login --tenant-id "$(az account show --query tenantId -o tsv)"
mkdir -p /tmp/az104-azcopy
printf 'AzCopy evidence\n' > /tmp/az104-azcopy/azcopy.txt
azcopy copy '/tmp/az104-azcopy/azcopy.txt' \
  "https://${STORAGE_ACCOUNT}.blob.core.windows.net/evidence/azcopy.txt"
azcopy list "https://${STORAGE_ACCOUNT}.blob.core.windows.net/evidence"
azcopy logout

az role assignment delete --assignee "$FILE_PRINCIPAL_ID" \
  --role "Storage File Data SMB Share Contributor" --scope "$STORAGE_ID"
```

Some file data operations support OAuth only under specific service/client conditions. If `--auth-mode login` is rejected for an operation in your environment, diagnose permissions and client support; use a short-lived SAS for the lab rather than normalizing account-key usage.

### PowerShell reference

```powershell
$share = New-AzRmStorageShare -ResourceGroupName $storageRg -StorageAccountName $storageAccount `
  -Name profiles -QuotaGiB 10 -AccessTier TransactionOptimized
New-AzStorageShare -Name profiles -Context $ctx
New-AzStorageShareSASToken -Name profiles -Permission r -ExpiryTime (Get-Date).AddMinutes(30) -Context $ctx
```

### Validation and exam tips

- Restore one file from a share snapshot and one deleted share through soft delete.
- Share snapshots apply to the entire share, not an individual file.
- Identity-based SMB combines share-level RBAC with Windows ACLs. Both must permit the operation.
- NFS and SMB have different identity/network requirements; do not assume SMB AD integration applies to NFS.
- AzCopy handles high-performance data transfer; Storage Explorer provides interactive data management.

## Lab 9 — Storage networking, encryption, redundancy, and object replication

**Time:** 120 minutes  
**Exam domain:** Configure access to storage; configure and manage storage accounts  
**Cost:** private endpoints incur hourly/data charges; delete promptly

### Theory checkpoint

Storage firewall rules limit the public endpoint by network. Service endpoints keep service traffic on the Azure backbone and allow subnet rules but still use the service public endpoint. Private endpoints create private IPs for a specific storage subresource and require correct private DNS. Encryption at rest is automatic with Microsoft-managed keys; customer-managed keys offer control but add Key Vault lifecycle/availability responsibilities. Infrastructure encryption adds a second encryption layer for supported scenarios.

LRS keeps copies in one datacenter; ZRS spans zones in one region; GRS/GZRS add asynchronous secondary-region copies; RA variants allow secondary reads. Account failover changes the primary and can lose recent writes. Object replication asynchronously copies block blobs between accounts and requires versioning/change feed; it is not the same as account redundancy.

### Portal journey

1. Create a small VNet `10.60.0.0/16` with subnet `storage-clients` (`10.60.1.0/24`). Enable the `Microsoft.Storage` service endpoint on the subnet.
2. Open the Lab 6 account **Networking > Firewalls and virtual networks**. Change public network access to **Enabled from selected virtual networks and IP addresses** and add the subnet. Add your current public IP only if required for the browser test.
3. Validate allowed and denied access paths. Do not lock yourself out before creating a recovery path.
4. Open **Encryption**. Compare Microsoft-managed keys, customer-managed keys, and infrastructure encryption. Do not configure a CMK unless you can manage Key Vault soft delete, purge protection, identity permissions, and key rotation correctly.
5. Open **Redundancy** and compare available options. Change LRS to ZRS only if supported/affordable; document failover implications for geo-redundant choices.
6. Create a second StorageV2 account. Enable blob versioning on both and change feed on the source. Create source and destination private containers.
7. Configure **Object replication** from the source container to the destination. Upload a new block blob after the rule is active, wait, and verify its replica. Existing blobs require separate handling depending on rule configuration.
8. Delete the replication rule and the second account. Return the original account networking to an appropriate state for cleanup.

### Azure CLI implementation

```bash
export NET_RG="$STORAGE_RG"
export STORAGE_VNET="az104-storage-vnet"
export STORAGE_SUBNET="storage-clients"
az network vnet create -g "$NET_RG" -n "$STORAGE_VNET" -l "$LOCATION" \
  --address-prefixes 10.60.0.0/16 --subnet-name "$STORAGE_SUBNET" --subnet-prefixes 10.60.1.0/24
az network vnet subnet update -g "$NET_RG" --vnet-name "$STORAGE_VNET" -n "$STORAGE_SUBNET" \
  --service-endpoints Microsoft.Storage
export SUBNET_ID="$(az network vnet subnet show -g "$NET_RG" --vnet-name "$STORAGE_VNET" \
  -n "$STORAGE_SUBNET" --query id -o tsv)"

az storage account network-rule add -g "$STORAGE_RG" --account-name "$STORAGE_ACCOUNT" \
  --subnet "$SUBNET_ID"
az storage account update -g "$STORAGE_RG" -n "$STORAGE_ACCOUNT" --default-action Deny
az storage account network-rule list -g "$STORAGE_RG" --account-name "$STORAGE_ACCOUNT" -o jsonc

# Inspect encryption and redundancy. Infrastructure encryption must be selected at creation.
az storage account show -g "$STORAGE_RG" -n "$STORAGE_ACCOUNT" \
  --query '{sku:sku.name,encryption:encryption,networkRuleSet:networkRuleSet}' -o jsonc

# Object replication pair.
export REPL_ACCOUNT="az104rep${SUFFIX}"
az storage account create -g "$STORAGE_RG" -n "$REPL_ACCOUNT" -l "$LOCATION2" \
  --sku Standard_LRS --kind StorageV2 --https-only true --min-tls-version TLS1_2 \
  --allow-blob-public-access false
az storage account blob-service-properties update -g "$STORAGE_RG" -n "$STORAGE_ACCOUNT" \
  --enable-versioning true --enable-change-feed true
az storage account blob-service-properties update -g "$STORAGE_RG" -n "$REPL_ACCOUNT" \
  --enable-versioning true

# Temporarily allow the administrator's public path if needed, then use Entra data roles on both accounts.
export REPL_ID="$(az storage account show -g "$STORAGE_RG" -n "$REPL_ACCOUNT" --query id -o tsv)"
az role assignment create --assignee-object-id "$MY_OBJECT_ID" --assignee-principal-type User \
  --role "Storage Blob Data Contributor" --scope "$REPL_ID"
az storage container create --account-name "$REPL_ACCOUNT" --name evidence-copy --auth-mode login

# The command creates a replication policy and rule; inspect current help if extension/API syntax evolves.
az storage account or-policy create \
  --resource-group "$STORAGE_RG" \
  --account-name "$REPL_ACCOUNT" \
  --source-account "$STORAGE_ACCOUNT" \
  --destination-account "$REPL_ACCOUNT" \
  --source-container evidence \
  --destination-container evidence-copy
az storage account or-policy list -g "$STORAGE_RG" -n "$STORAGE_ACCOUNT" -o jsonc

# Restore public access for final cleanup tooling if required, then delete the whole lab group.
az storage account update -g "$STORAGE_RG" -n "$STORAGE_ACCOUNT" --default-action Allow
az group delete -n "$STORAGE_RG" --yes --no-wait
```

### PowerShell reference

```powershell
Add-AzStorageAccountNetworkRule -ResourceGroupName $storageRg -Name $storageAccount `
  -VirtualNetworkResourceId $subnetId
Update-AzStorageAccountNetworkRuleSet -ResourceGroupName $storageRg -Name $storageAccount `
  -DefaultAction Deny
Get-AzStorageAccount -ResourceGroupName $storageRg -Name $storageAccount | Select-Object SkuName, Encryption
```

### Production notes and exam tips

- Never enable **Allow trusted Microsoft services** as a reflex; it is a broad exception with service-specific behavior.
- A service endpoint does not assign a private IP to the storage account. A private endpoint does.
- Each storage subresource (`blob`, `file`, and others) needs its own private endpoint/DNS zone when private access is required.
- ZRS protects against a zone failure; GRS protects against regional failure but secondary replication is asynchronous.
- Object replication supports block blobs and has prerequisite/feature constraints. It is not a synchronous write or backup substitute.
- Infrastructure encryption is a creation-time decision for many storage configurations.

### Cleanup

Confirm the resource group contains only AZ-104 lab resources, then allow its asynchronous deletion to finish. Remove any local files containing test SAS results.

## Module checkpoint

Take the [storage checkpoint](../assessments/module-02-storage.md) closed-book. For each miss, repeat the relevant Portal and CLI validation from Labs 5–8 before retaking.
