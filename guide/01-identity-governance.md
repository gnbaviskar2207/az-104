# Stage 1 — Identity, access, resources, and governance

## Lab 2 — Microsoft Entra users, groups, licenses, guests, and SSPR

**Time:** 90 minutes  
**Exam domain:** Manage Azure identities and governance  
**Permissions/licensing:** User Administrator for user/group work; License Administrator for licenses; Authentication Policy Administrator or Global Administrator for SSPR. Some features require Entra ID P1.

### Theory checkpoint

Microsoft Entra roles authorize directory operations; Azure RBAC roles authorize Azure resource operations. They are separate systems. A user, group, service principal, or managed identity is a security principal. Group-based licensing and group-scoped SSPR can require Entra ID P1. External B2B users authenticate with their home identity but receive authorization in the resource tenant.

Know member versus guest user types, assigned versus dynamic groups, security versus Microsoft 365 groups, direct versus group-based license assignment, usage location prerequisites, and SSPR authentication-method registration.

### Portal journey

1. Open **Microsoft Entra admin center** (`entra.microsoft.com`) or **Portal > Microsoft Entra ID**.
2. Go to **Users > All users > New user > Create new user**. Create `az104-operator` with a generated temporary password; require password change at next sign-in.
3. Open the user. Set **Job title**, **Department=Operations**, and **Usage location**. Do not assign privileged directory roles.
4. Go to **Groups > All groups > New group**. Create a **Security** group named `AZ104-Storage-Operators`, membership type **Assigned**, and add the user.
5. Inspect the group **Properties**, **Members**, **Owners**, **Licenses**, and **Audit logs**.
6. If licenses exist, open **Billing > Licenses > All products**, select a test product, and assign it to either the user or group. Record failed assignment reasons; usage location is a common cause. Remove the assignment after validation.
7. Go to **Users > New user > Invite external user**. Use an address you control only if acceptable; add a personal invitation message and optionally add the guest to the group. Do not invite an arbitrary person.
8. Open **Protection > Password reset > Properties**. For a P1 test tenant, choose **Selected** and the test group. Configure at least two authentication methods and registration settings. For a free tenant, observe settings and document the license limitation rather than enabling unsupported scope.
9. Review **Sign-in logs** and **Audit logs** after testing. Delete the test guest if created.

### Azure CLI implementation

```bash
export TENANT_DOMAIN="<yourtenant>.onmicrosoft.com"
export TEST_UPN="az104-operator-${SUFFIX}@${TENANT_DOMAIN}"
read -rsp "Temporary Entra password: " ENTRA_TEMP_PASSWORD; echo

# Create and update a test user. Avoid putting passwords directly on the command line in shared systems.
az ad user create \
  --display-name "AZ104 Operator ${SUFFIX}" \
  --user-principal-name "$TEST_UPN" \
  --password "$ENTRA_TEMP_PASSWORD" \
  --force-change-password-next-sign-in true

export USER_ID="$(az ad user show --id "$TEST_UPN" --query id -o tsv)"
az rest --method PATCH \
  --url "https://graph.microsoft.com/v1.0/users/${USER_ID}" \
  --headers 'Content-Type=application/json' \
  --body '{"department":"Operations","jobTitle":"Cloud Operator","usageLocation":"IN"}'

# Create a security group and add the user.
az ad group create \
  --display-name "AZ104-Storage-Operators-${SUFFIX}" \
  --mail-nickname "az104storageops${SUFFIX}"
export GROUP_ID="$(az ad group show --group "AZ104-Storage-Operators-${SUFFIX}" --query id -o tsv)"
az ad group member add --group "$GROUP_ID" --member-id "$USER_ID"
az ad group member check --group "$GROUP_ID" --member-id "$USER_ID"
az ad group member list --group "$GROUP_ID" --query '[].{name:displayName,upn:userPrincipalName}' -o table

# List subscribed SKUs. License assignment is a Microsoft Graph operation.
az rest --method GET \
  --url 'https://graph.microsoft.com/v1.0/subscribedSkus' \
  --query 'value[].{skuPartNumber:skuPartNumber,skuId:skuId,enabled:prepaidUnits.enabled,consumed:consumedUnits}' \
  -o table

# If a spare test SKU is available, substitute its GUID. Empty disabledPlans assigns all service plans.
export SKU_ID="<sku-guid-or-skip>"
az rest --method POST \
  --url "https://graph.microsoft.com/v1.0/users/${USER_ID}/assignLicense" \
  --headers 'Content-Type=application/json' \
  --body "{\"addLicenses\":[{\"skuId\":\"${SKU_ID}\",\"disabledPlans\":[]}],\"removeLicenses\":[]}" 

# Optional, controlled B2B invitation. Use only an address you own or have permission to invite.
export GUEST_EMAIL="<controlled-address-or-skip>"
az rest --method POST \
  --url 'https://graph.microsoft.com/v1.0/invitations' \
  --headers 'Content-Type=application/json' \
  --body "{\"invitedUserEmailAddress\":\"${GUEST_EMAIL}\",\"inviteRedirectUrl\":\"https://portal.azure.com\",\"sendInvitationMessage\":false}" 

# Azure CLI has no dedicated SSPR command. Microsoft Graph can toggle tenant-wide SSPR.
# Do this only in a disposable tenant after inspecting the current policy and license implications.
az rest --method GET --url 'https://graph.microsoft.com/v1.0/policies/authorizationPolicy' -o jsonc
# az rest --method PATCH --url 'https://graph.microsoft.com/v1.0/policies/authorizationPolicy' \
#   --headers 'Content-Type=application/json' --body '{"allowedToUseSSPR":true}'

# Cleanup order: remove group, then user. Remove any assigned test license first if necessary.
az ad group delete --group "$GROUP_ID"
az ad user delete --id "$USER_ID"
unset ENTRA_TEMP_PASSWORD
```

`az ad` commands and `az rest` call Microsoft Graph and require matching Graph permissions. A CLI failure caused by insufficient directory permission is not repaired by assigning subscription Contributor.

### PowerShell reference

```powershell
Connect-MgGraph -Scopes 'User.ReadWrite.All','Group.ReadWrite.All','Organization.Read.All'
$pw = Read-Host 'Temporary password' -AsSecureString
New-MgUser -DisplayName 'AZ104 Operator' -UserPrincipalName 'az104-operator@tenant.onmicrosoft.com' `
  -MailNickname 'az104operator' -AccountEnabled -PasswordProfile @{Password=$pw; ForceChangePasswordNextSignIn=$true}
New-MgGroup -DisplayName 'AZ104-Storage-Operators' -MailEnabled:$false `
  -MailNickname 'az104storageops' -SecurityEnabled
```

### Validation and exam tips

- Confirm the user properties, group membership, and audit event through both Portal and Graph/CLI.
- License assignment normally requires `usageLocation`; group licensing can be delayed and requires appropriate licensing.
- Deleting a user places it in deleted users temporarily; restoration is possible during the retention window.
- SSPR and MFA are related but distinct. SSPR needs registration and allowed authentication methods.
- A guest is not automatically authorized to Azure resources. Grant the minimum RBAC role at the minimum scope separately.

### Cleanup

Remove the test license, guest, group, and user. Retain screenshots or command output without sensitive values as evidence.

## Lab 3 — Azure RBAC scopes, inheritance, effective access, and role interpretation

**Time:** 75 minutes  
**Exam domain:** Manage access to Azure resources  
**Permissions:** Owner, User Access Administrator, or Role Based Access Control Administrator at the lab scope

### Theory checkpoint

An RBAC assignment combines security principal, role definition, and scope. Effective access is the union of allowed actions from assignments; deny assignments override allows. Management-plane `Actions` differ from data-plane `DataActions`. Owner can manage resources and access; Contributor cannot assign roles; User Access Administrator can manage access but not resources. Assign groups rather than users for operational scale.

### Portal journey

1. Create resource groups `az104-rbac-parent-<suffix>-rg` and `az104-rbac-child-<suffix>-rg` (the names describe scope practice; resource groups are not actually nested).
2. Add a cheap storage account to the second group.
3. Open the second resource group **Access control (IAM) > Role assignments > Add role assignment**.
4. Choose **Reader**, assign access to **User, group, or service principal**, and select the Lab 2 group (re-create a group if Lab 2 was cleaned up).
5. Assign **Storage Blob Data Reader** to the group at the storage-account scope. Compare it with Reader: Reader sees control-plane configuration but does not grant blob data access; Storage Blob Data Reader grants blob read `DataActions`.
6. Open **Check access** for the test user/group and inspect inherited and direct assignments.
7. Open the role definition **JSON** and identify `Actions`, `NotActions`, `DataActions`, `NotDataActions`, and `AssignableScopes`.
8. Test with a nonprivileged account if available. Remove the assignments before cleanup.

### Azure CLI implementation

```bash
export RBAC_RG="az104-lab03-${SUFFIX}-rg"
export SA="az104rbac${SUFFIX}"
az group create -n "$RBAC_RG" -l "$LOCATION" --tags workload=az104 environment=lab
az storage account create -g "$RBAC_RG" -n "$SA" -l "$LOCATION" \
  --sku Standard_LRS --kind StorageV2 --https-only true --min-tls-version TLS1_2

export SCOPE="$(az group show -n "$RBAC_RG" --query id -o tsv)"
export SA_SCOPE="$(az storage account show -g "$RBAC_RG" -n "$SA" --query id -o tsv)"
export PRINCIPAL_ID="<test-group-object-id>"

az role assignment create \
  --assignee-object-id "$PRINCIPAL_ID" \
  --assignee-principal-type Group \
  --role Reader \
  --scope "$SCOPE"

az role assignment create \
  --assignee-object-id "$PRINCIPAL_ID" \
  --assignee-principal-type Group \
  --role "Storage Blob Data Reader" \
  --scope "$SA_SCOPE"

# Interpret role definitions and assignments.
az role definition list --name Reader \
  --query '[0].{roleName:roleName,actions:permissions[0].actions,dataActions:permissions[0].dataActions}' -o jsonc
az role definition list --name "Storage Blob Data Reader" \
  --query '[0].{actions:permissions[0].actions,dataActions:permissions[0].dataActions}' -o jsonc
az role assignment list --assignee "$PRINCIPAL_ID" --all --include-inherited \
  --query '[].{role:roleDefinitionName,scope:scope,principalType:principalType}' -o table

# Optional: create a narrowly assignable custom role only to practice interpreting JSON.
cat > /tmp/az104-role.json <<'EOF'
{
  "Name": "AZ104 Resource Reader",
  "IsCustom": true,
  "Description": "Read resources and support requests; no data-plane access.",
  "Actions": ["Microsoft.Resources/subscriptions/resourceGroups/read", "*/read"],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": ["SUBSCRIPTION_SCOPE"]
}
EOF
sed -i "s|SUBSCRIPTION_SCOPE|/subscriptions/${SUBSCRIPTION_ID}|" /tmp/az104-role.json
# az role definition create --role-definition /tmp/az104-role.json

az role assignment delete --assignee "$PRINCIPAL_ID" --role Reader --scope "$SCOPE"
az role assignment delete --assignee "$PRINCIPAL_ID" --role "Storage Blob Data Reader" --scope "$SA_SCOPE"
az group delete -n "$RBAC_RG" --yes --no-wait
```

The temporary JSON file contains no secret, but do not commit tenant-specific role definitions without review. Custom roles have propagation delays and tenant limits.

### PowerShell reference

```powershell
$scope = (Get-AzResourceGroup -Name $rbacRg).ResourceId
New-AzRoleAssignment -ObjectId '<group-object-id>' -RoleDefinitionName 'Reader' -Scope $scope
Get-AzRoleAssignment -ObjectId '<group-object-id>' -IncludeClassicAdministrators
Get-AzRoleDefinition -Name 'Storage Blob Data Reader' | ConvertTo-Json -Depth 10
Remove-AzRoleAssignment -ObjectId '<group-object-id>' -RoleDefinitionName 'Reader' -Scope $scope
```

### Production notes and exam tips

- Prefer group assignments at the highest justified scope, but avoid subscription-wide roles when resource-group scope meets the requirement.
- Use object IDs in automation to avoid ambiguity and lookup failures.
- RBAC changes can take minutes to propagate. Refresh credentials before diagnosing a permissions failure.
- `NotActions` is not a deny; another role assignment can grant the excluded operation.
- A role assignment at resource-group scope inherits to resources, but a resource-scope assignment does not flow upward.

## Lab 4 — Resource groups, tags, moves, locks, and subscription organization

**Time:** 75 minutes  
**Exam domain:** Manage Azure subscriptions and governance

### Theory checkpoint

Tags aid ownership, cost, automation, and inventory. Locks are control-plane safeguards: `ReadOnly` blocks updates as well as deletion; `CanNotDelete` allows changes but blocks deletion. Locks inherit. Moving resources does not change region, and not every resource type or dependency supports moves. Validate move support and dependent resources first.

### Portal journey

1. Create source and destination groups with `workload`, `environment`, `costCenter`, and `owner` tags.
2. Create a storage account in the source group. Observe that resource-group tags do not automatically appear on the account.
3. Add the same tags directly to the account.
4. Open **Locks > Add**, create `protect-from-delete` of type **Delete**.
5. Attempt to delete the account and record the lock error. Remove the lock.
6. Select **Move > Move to another resource group**, choose the destination, validate dependencies, acknowledge resource IDs can change, and start the move.
7. Verify the account in the destination group, role assignments, diagnostic settings, and any scripts that used the old resource ID.
8. Open **Subscriptions > your subscription > Resource groups** and practice filtering by tag.

### Azure CLI implementation

```bash
export SRC_RG="az104-lab04-src-${SUFFIX}-rg"
export DST_RG="az104-lab04-dst-${SUFFIX}-rg"
export MOVE_SA="az104move${SUFFIX}"
az group create -n "$SRC_RG" -l "$LOCATION" --tags workload=az104 environment=lab costCenter=training
az group create -n "$DST_RG" -l "$LOCATION" --tags workload=az104 environment=lab costCenter=training
az storage account create -g "$SRC_RG" -n "$MOVE_SA" -l "$LOCATION" --sku Standard_LRS --kind StorageV2

export RESOURCE_ID="$(az storage account show -g "$SRC_RG" -n "$MOVE_SA" --query id -o tsv)"
az tag create --resource-id "$RESOURCE_ID" \
  --tags workload=az104 environment=lab costCenter=training owner="$OWNER_TAG"

az lock create --name protect-from-delete --lock-type CanNotDelete --resource "$MOVE_SA" \
  --resource-type Microsoft.Storage/storageAccounts --resource-group "$SRC_RG"
az lock list --resource-group "$SRC_RG" -o table

# This should fail. Read the error rather than bypassing it blindly.
az storage account delete -g "$SRC_RG" -n "$MOVE_SA" --yes

az lock delete --name protect-from-delete --resource "$MOVE_SA" \
  --resource-type Microsoft.Storage/storageAccounts --resource-group "$SRC_RG"

export DST_ID="$(az group show -n "$DST_RG" --query id -o tsv)"
az resource move --destination-group "$DST_ID" --ids "$RESOURCE_ID"
az resource list -g "$DST_RG" -o table

az group delete -n "$SRC_RG" --yes --no-wait
az group delete -n "$DST_RG" --yes --no-wait
```

### PowerShell reference

```powershell
New-AzResourceLock -LockName 'protect-from-delete' -LockLevel CanNotDelete `
  -ResourceGroupName $srcRg -ResourceName $storageName -ResourceType 'Microsoft.Storage/storageAccounts'
Remove-AzResourceLock -LockName 'protect-from-delete' -ResourceGroupName $srcRg `
  -ResourceName $storageName -ResourceType 'Microsoft.Storage/storageAccounts' -Force
Move-AzResource -DestinationResourceGroupName $dstRg -ResourceId $resourceId
```

### Exam tips

- A lock applies to all users and roles, including Owner, until someone with the right lock permission removes it.
- Locks protect control-plane operations; data-plane deletion behavior depends on the service.
- Tags are not inherited from resource groups by default. Use Policy for inheritance/remediation.
- Moving across subscriptions requires both subscriptions in the same Entra tenant and proper permissions; providers and quotas must be ready.

## Lab 5 — Azure Policy, management groups, compliance, budgets, and Advisor

**Time:** 100 minutes  
**Exam domain:** Manage Azure subscriptions and governance  
**Cost:** budget itself is free; Advisor is free; remediation may deploy resources

### Theory checkpoint

Policy evaluates resource properties for compliance; RBAC controls who can perform operations. Policy definitions are grouped into initiatives. Assignment scope and exclusions determine reach. Effects include Audit, Deny, Modify, Append, DeployIfNotExists, and AuditIfNotExists. Modify and DeployIfNotExists remediation need a managed identity and appropriate role assignments. Existing noncompliant resources are not necessarily changed until remediation.

A budget sends alerts but does not hard-stop resources. Azure Advisor recommendations span cost, security, reliability, operational excellence, and performance. Management groups organize subscriptions and allow inherited Policy/RBAC.

### Portal journey

1. Open **Management groups**. If permitted, create `AZ104-Sandbox` beneath the tenant root and inspect subscription placement. Do not move a production subscription.
2. Open **Policy > Definitions**. Find **Allowed locations** and inspect its parameters and `Deny` effect.
3. Go to **Assignments > Assign policy**. Scope it to the lab subscription or a dedicated lab resource group, exclude nothing initially, and allow only the primary lab region. Give it a descriptive assignment name.
4. Attempt to create a resource in a disallowed region. Read the deployment error and locate the policy assignment ID.
5. Assign **Require a tag and its value on resources** in Audit mode if the definition/effect supports it, or use an audit definition. Create an untagged resource and trigger/evaluate compliance.
6. Review **Policy > Compliance**. Understand that evaluation is asynchronous. Create a remediation task only for a safe Modify/DeployIfNotExists test assignment.
7. Delete the test assignments so later multi-region labs work.
8. Open **Cost Management + Billing > Cost Management > Budgets > Add**. Set a small monthly lab budget with 50%, 80%, and 100% actual/forecast alerts to your address.
9. Open **Azure Advisor**. Review all categories, impact, affected resources, postpone/dismiss controls, and recommendation details. Do not implement recommendations blindly.

### Azure CLI implementation

```bash
export GOV_RG="az104-lab05-${SUFFIX}-rg"
az group create -n "$GOV_RG" -l "$LOCATION" --tags workload=az104 environment=lab
export GOV_SCOPE="$(az group show -n "$GOV_RG" --query id -o tsv)"

# Find the built-in definition by display name rather than hard-coding a GUID.
export ALLOWED_LOC_DEF="$(az policy definition list \
  --query "[?displayName=='Allowed locations'].id | [0]" -o tsv)"
az policy definition show --name "${ALLOWED_LOC_DEF##*/}" \
  --query '{displayName:displayName,mode:mode,parameters:parameters,rule:policyRule}' -o jsonc

az policy assignment create \
  --name "az104-allowed-locations-${SUFFIX}" \
  --display-name "AZ104 lab allowed locations" \
  --scope "$GOV_SCOPE" \
  --policy "$ALLOWED_LOC_DEF" \
  --params "{\"listOfAllowedLocations\":{\"value\":[\"${LOCATION}\"]}}"

# Expected failure: the assignment allows only LOCATION.
az storage account create -g "$GOV_RG" -n "az104deny${SUFFIX}" -l "$LOCATION2" \
  --sku Standard_LRS --kind StorageV2

az policy assignment list --scope "$GOV_SCOPE" \
  --query '[].{name:name,displayName:displayName,policy:policyDefinitionId}' -o table
az policy state summarize --resource-group "$GOV_RG" -o jsonc

# Optional management group, only in a disposable tenant with suitable permission.
# az account management-group create --name "az104-sandbox-${SUFFIX}" --display-name 'AZ104 Sandbox'
# az account management-group show --name "az104-sandbox-${SUFFIX}" --expand --recurse

# Budget at resource-group scope. Dates must cover complete months and may require adjustment.
export START_DATE="$(date -u +%Y-%m-01)"
export END_DATE="$(date -u -d '+1 year' +%Y-%m-01 2>/dev/null || echo '2027-12-01')"
export ALERT_EMAIL="<your-email>"
az consumption budget create \
  --budget-name "az104-lab-budget-${SUFFIX}" \
  --amount 10 \
  --category Cost \
  --time-grain Monthly \
  --start-date "$START_DATE" \
  --end-date "$END_DATE" \
  --resource-group "$GOV_RG"
az consumption budget show --budget-name "az104-lab-budget-${SUFFIX}" --resource-group "$GOV_RG" -o jsonc

# Advisor CLI queries.
az advisor configuration show -o jsonc
az advisor recommendation list \
  --query '[].{category:category,impact:impact,resource:resourceMetadata.resourceId,problem:shortDescription.problem}' \
  -o table

az policy assignment delete --name "az104-allowed-locations-${SUFFIX}" --scope "$GOV_SCOPE"
az group delete -n "$GOV_RG" --yes --no-wait
```

Budget CLI notification schema varies by CLI/API version. Create rich threshold/action-group notifications in the Portal, then inspect the generated budget with `az consumption budget show` or `az rest`.

### PowerShell reference

```powershell
$definition = Get-AzPolicyDefinition | Where-Object DisplayName -eq 'Allowed locations'
New-AzPolicyAssignment -Name 'az104-allowed-locations' -Scope $scope `
  -PolicyDefinition $definition -PolicyParameterObject @{listOfAllowedLocations=@('centralindia')}
Get-AzPolicyState -ResourceGroupName $govRg
Remove-AzPolicyAssignment -Name 'az104-allowed-locations' -Scope $scope
Get-AzAdvisorRecommendation
```

### Production notes and exam tips

- Test Policy with Audit, then move to Deny after impact analysis. Use exclusions sparingly and document them.
- Policy compliance is not instantaneous. On-demand scans still take time.
- A Policy assignment with a managed identity does nothing useful unless that identity has the required remediation role.
- Management-group policies and RBAC inherit into child management groups and subscriptions.
- Budgets alert; quotas, Policy, automation, and organizational process provide stronger controls.
- Advisor recommendations are contextual input, not automatic production approval.

### Cleanup

Delete lab Policy assignments before the resource group. Remove the optional management group only if it is empty. Keep a low subscription budget if it is genuinely useful; otherwise remove the lab budget.
