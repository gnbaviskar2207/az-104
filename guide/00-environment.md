# Stage 0 — Lab environment and operating rules

## Lab 1 — Tooling, subscription context, resource groups, tags, and safe cleanup

**Time:** 60–75 minutes  
**Exam domains:** all domains; manage resource groups and subscriptions  
**Cost:** no material charge for an empty resource group

### Theory checkpoint

Azure Resource Manager is the control plane. A tenant contains identities; a management-group hierarchy contains subscriptions; a subscription is a billing, quota, and access boundary; resource groups are lifecycle and deployment containers; resources exist in a region even when their resource group metadata has a different location. RBAC and Policy assignments inherit downward by scope. Tags do not automatically inherit unless Policy applies them.

Know the difference between authentication (`az login`), subscription context (`az account set`), authorization (RBAC), and governance (Policy/locks). Azure CLI commands are imperative operations against ARM; Bicep/ARM templates are declarative and idempotent when designed correctly.

### Prerequisites

- A disposable Azure subscription where you are at least Contributor. User Access Administrator or Owner is required for RBAC labs; Global Administrator is not the same as subscription Owner.
- Permission to create Entra test identities for Lab 2. Entra P1/P2 features may require a trial or separate tenant.
- Latest Azure CLI, or Bash in Azure Cloud Shell. PowerShell examples require the Az module.
- Optional: VS Code with Bicep extension, Bicep CLI, AzCopy, and Azure Storage Explorer.

Never place passwords, access keys, SAS tokens, client secrets, or private keys in this repository or shell history. Prefer managed identities and Entra authentication.

### Naming and common variables

Use lowercase names, a short workload code, environment, region code, and a random suffix where global uniqueness is required. Run the following in Bash or Cloud Shell at the start of each lab, changing the region if your subscription lacks a SKU:

```bash
export LOCATION="centralindia"
export LOCATION2="southindia"
export PREFIX="az104"
export SUFFIX="$(openssl rand -hex 3)"
export RG="${PREFIX}-lab01-${SUFFIX}-rg"
export OWNER_TAG="student"
export EXPIRY_TAG="$(date -u -d '+2 days' +%F 2>/dev/null || date -u +%F)"
```

On macOS, set `EXPIRY_TAG` manually if BSD `date` rejects the GNU syntax.

### Portal journey

1. Go to `portal.azure.com`. Open **Microsoft Entra ID > Overview** and record the tenant ID.
2. Search for **Subscriptions**. Open the lab subscription and record its subscription ID, current spending information, and IAM access.
3. Open **Cost Management > Budgets** and note where Lab 5 will create a budget.
4. Search for **Resource groups > Create**.
5. Select the lab subscription, enter a unique name such as `az104-lab01-portal-rg`, and choose the lab region.
6. On **Tags**, add `workload=az104`, `environment=lab`, `owner=<your name>`, and `expires=<date>`.
7. Select **Review + create > Create**. Open the resource group and inspect **Deployments**, **Activity log**, **Access control (IAM)**, **Tags**, **Locks**, and **Resource costs**.
8. Use the top search bar and the resource-group blade search. Pin the resource group to the dashboard, then unpin it; this is navigation practice only.
9. Delete only the empty portal practice resource group: **Overview > Delete resource group**, type its name, and confirm.

### Azure CLI implementation

```bash
# Inspect the client and authenticate. Use --use-device-code when a browser cannot open.
az version
az login

# Never assume which subscription is active.
az account list --output table
export SUBSCRIPTION_ID="<your-lab-subscription-id>"
az account set --subscription "$SUBSCRIPTION_ID"
az account show --query '{name:name,id:id,tenantId:tenantId,user:user.name}' -o yaml

# Create a tagged resource group.
az group create \
  --name "$RG" \
  --location "$LOCATION" \
  --tags workload=az104 environment=lab owner="$OWNER_TAG" expires="$EXPIRY_TAG"

# Read data in useful formats and use JMESPath queries.
az group show --name "$RG" -o jsonc
az group list \
  --query "[?tags.workload=='az104'].{name:name,location:location,expires:tags.expires}" \
  -o table

# Inspect provider registration and supported locations without changing anything.
az provider show --namespace Microsoft.Compute \
  --query '{state:registrationState,types:resourceTypes[].resourceType}' -o jsonc
az account list-locations --query "[].{name:name,displayName:displayName}" -o table

# Discover syntax rather than guessing.
az group --help
az group create --help

# Preview targets, then delete this resource group when the lab is complete.
az resource list --resource-group "$RG" -o table
az group delete --name "$RG" --yes --no-wait
az group exists --name "$RG"
```

Use `--only-show-errors` in stable automation, not while learning. Use `--query` to minimize output and avoid accidentally displaying sensitive fields.

### PowerShell reference

```powershell
Connect-AzAccount
Get-AzSubscription | Format-Table Name, Id, TenantId
Set-AzContext -SubscriptionId '<subscription-id>'
$tags = @{ workload='az104'; environment='lab'; owner='student'; expires='YYYY-MM-DD' }
New-AzResourceGroup -Name 'az104-lab01-ps-rg' -Location 'centralindia' -Tag $tags
Get-AzResourceGroup -Name 'az104-lab01-ps-rg'
Remove-AzResourceGroup -Name 'az104-lab01-ps-rg' -Force
```

### Validation

- `az account show` displays the intended tenant and subscription.
- `az group show -n "$RG"` returns the four tags before deletion.
- After deletion completes, `az group exists -n "$RG"` returns `false`.

### Production notes

- Use separate subscriptions for production, nonproduction, connectivity, identity, and sandbox according to organizational scale and landing-zone design.
- Treat tags as management metadata, not security boundaries. Policy can require or append tags.
- Prefer workload identities or managed identities for automation. Interactive user login is for administration and learning.
- Enable budgets early. A budget alerts; it does not stop consumption.
- Register resource providers deliberately. Creation normally auto-registers providers, but least privilege and deployment timing can matter.

### Exam tips

- Resource-group location stores deployment metadata; resources inside can use other regions.
- A resource belongs to one subscription and one resource group at a time.
- Deleting a resource group deletes its contained resources; a `CanNotDelete` lock prevents deletion.
- Management groups, subscriptions, resource groups, and resources are RBAC/Policy scopes. The effect generally inherits downward.
- Know `az account set`, `az resource list`, `az group create/delete`, help, JMESPath, and output formats.

### Cleanup

This lab already deletes its practice group. Before every future cleanup, list the group contents and confirm the `workload=az104` tag. Never turn a variable or wildcard into a broad deletion target.

## Daily operating checklist

```bash
az login
az account set --subscription "$SUBSCRIPTION_ID"
az account show --query '{subscription:name,id:id,tenant:tenantId}' -o table
az version
az group list --query "[?tags.workload=='az104'].{group:name,expires:tags.expires}" -o table
```

At the end of a session:

1. Stop or deallocate VMs if the lab continues later.
2. Remove paid transient services such as Bastion, public IPs, gateways, AKS, and private endpoints.
3. Delete completed lab resource groups after inspecting contents.
4. Check **Cost Management > Cost analysis** and active budgets.
5. Run `az logout` on shared machines.
