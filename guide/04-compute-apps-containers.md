# Stage 4 — Compute, App Service, and containers

## Lab 14 — ARM templates and Bicep: interpret, modify, validate, deploy, export, and decompile

**Time:** 120 minutes  
**Exam domain:** Automate deployment with ARM templates or Bicep files  
**Included artifacts:** [`../artifacts/lab14/main.bicep`](../artifacts/lab14/main.bicep) and [`../artifacts/lab14/dev.bicepparam`](../artifacts/lab14/dev.bicepparam)

### Theory checkpoint

ARM templates and Bicep describe desired resource state. Parameters accept environment-specific input; variables calculate reusable values; resources declare Azure objects; outputs expose values; functions and symbolic references express relationships. Bicep transpiles to ARM JSON. A deployment is incremental by default; complete mode can delete resources absent from the template and must be handled with extreme care.

Dependencies should usually be implicit through symbolic references. Secure parameters protect display/logging but are not a secret-management system. Use Key Vault or workload identity for real secrets. Preview with `what-if`, validate, then deploy with a named deployment for traceability.

### Portal journey

1. Open [`main.bicep`](../artifacts/lab14/main.bicep). Identify target scope, parameters, allowed values, default expressions, tags, resource API versions, child resources, symbolic parent references, and outputs.
2. In Portal search **Deploy a custom template > Build your own template in the editor**.
3. Because the Portal editor consumes ARM JSON, compile locally with `az bicep build`, then load the generated JSON. Review resources and parameters before saving.
4. Create a resource group and complete the deployment with a unique lowercase storage name.
5. Open the resource group **Deployments**, select the deployment, and inspect inputs, outputs, operations, template, and correlation ID.
6. Open the storage account **Automation > Export template**. Compare the export with the intentionally authored template; exported templates often need cleanup and parameterization.
7. Return to **Deploy a custom template**, change the SKU or a tag, select **Review + create**, and inspect the change impact.

### Azure CLI implementation

```bash
export IAC_RG="az104-lab14-${SUFFIX}-rg"
export IAC_SA="az104iac${SUFFIX}"
az group create -n "$IAC_RG" -l "$LOCATION" --tags workload=az104 environment=lab

cd artifacts/lab14
az bicep version
az bicep build --file main.bicep --outfile /tmp/az104-main.json
az bicep lint --file main.bicep

# Validate and preview. Replace the placeholder through an inline parameter override.
az deployment group validate -g "$IAC_RG" -n lab14-validate \
  --template-file main.bicep --parameters dev.bicepparam storageAccountName="$IAC_SA"
az deployment group what-if -g "$IAC_RG" -n lab14-preview \
  --template-file main.bicep --parameters dev.bicepparam storageAccountName="$IAC_SA"
az deployment group create -g "$IAC_RG" -n lab14-deploy \
  --template-file main.bicep --parameters dev.bicepparam storageAccountName="$IAC_SA"

az deployment group show -g "$IAC_RG" -n lab14-deploy \
  --query '{state:properties.provisioningState,outputs:properties.outputs}' -o jsonc
az deployment operation group list -g "$IAC_RG" -n lab14-deploy -o table

# Modify a safe parameter and use what-if again before applying.
az deployment group what-if -g "$IAC_RG" -n lab14-zrs-preview \
  --template-file main.bicep --parameters storageAccountName="$IAC_SA" storageSku=Standard_ZRS

# Export deployed state as ARM JSON and decompile to Bicep for learning.
az group export -g "$IAC_RG" --skip-resource-name-params > /tmp/az104-export.json
az bicep decompile --file /tmp/az104-export.json --outfile /tmp/az104-exported.bicep --force
az bicep build --file /tmp/az104-exported.bicep --outfile /tmp/az104-roundtrip.json

cd -
az group delete -n "$IAC_RG" --yes --no-wait
```

If the Storage API version in the artifact is not yet supported in a restricted cloud/region, use `az bicep upgrade`, inspect available API versions, and select the newest stable version supported by that environment.

### PowerShell reference

```powershell
Test-AzResourceGroupDeployment -ResourceGroupName $iacRg -TemplateFile ./main.bicep `
  -storageAccountName $iacSa
New-AzResourceGroupDeployment -Name lab14-deploy -ResourceGroupName $iacRg `
  -TemplateFile ./main.bicep -storageAccountName $iacSa
Get-AzResourceGroupDeploymentWhatIfResult -ResourceGroupName $iacRg -TemplateFile ./main.bicep `
  -storageAccountName $iacSa
Export-AzResourceGroup -ResourceGroupName $iacRg -Path ./exported.json
```

### Production notes and exam tips

- `what-if` predicts changes; it does not guarantee that runtime policy, quota, or naming constraints will pass.
- Incremental deployment does not delete resources absent from a template, but it can reset unspecified properties depending on API behavior.
- Complete mode can delete. Use deployment stacks or carefully governed pipelines for lifecycle ownership.
- Exported templates are starting points, not clean source code. Remove runtime/read-only properties and parameterize appropriately.
- Bicep modules, verified registries, CI validation, linting, environment parameter files, and reviewed API versions improve production quality.

## Lab 15 — VMs, SSH/RDP, resizing, disks, host encryption, moves, and diagnostics

**Time:** 150 minutes  
**Exam domain:** Create and configure virtual machines  
**Cost:** two small VMs plus disks; deallocate between sessions  
**Guest artifact:** [`../artifacts/lab15/mount-data-disk.sh`](../artifacts/lab15/mount-data-disk.sh)

### Theory checkpoint

VM size controls vCPU, memory, temporary disk, NIC/data-disk limits, and accelerated networking support. Managed disks have independent SKUs, performance, encryption, caching, snapshots, and lifecycle. The OS disk persists through deallocation; temporary disk does not. Stopping inside the guest may continue compute billing; deallocation releases compute allocation (public dynamic IP behavior can differ).

Trusted Launch provides Secure Boot and vTPM for supported Gen2 images. Server-side managed-disk encryption is default; encryption at host encrypts temp disks/cache and must be supported/enabled. Availability choices are creation/design decisions, not a checkbox added freely later.

### Portal journey

1. Create a VNet with `management` and `workload` subnets plus an NSG allowing SSH/RDP only from your IP. Prefer Bastion and no public VM IP in production.
2. Create Ubuntu 24.04 LTS VM `linux01` with SSH public-key authentication, Standard SSD OS disk, Trusted Launch, boot diagnostics, and system-assigned managed identity.
3. Create Windows Server VM `win01` only if budget permits. Use a generated password stored in a password manager/Key Vault, not the guide.
4. Open **Size**, filter compatible sizes, resize `linux01`, and observe whether restart/deallocation is required.
5. Under **Disks**, create/attach a small Standard SSD data disk. In the guest, identify, partition, format, mount by UUID, and add a safe `/etc/fstab` entry.
6. Create a disk snapshot after writing a marker file. Create a new disk from the snapshot and attach it as a recovery-copy exercise.
7. Inspect **Configuration** for host encryption and security type. Enable encryption at host only when the subscription/region/VM supports it, usually at creation.
8. Use **Run command**, **Serial console** prerequisites, **Boot diagnostics**, **Reset password/SSH configuration**, and **Redeploy + reapply** menus; understand their purposes without invoking destructive actions unnecessarily.
9. Move the VM and every dependent resource to a second resource group after running move validation. Compare resource-group/subscription moves with cross-region Azure Resource Mover.

### Azure CLI implementation

```bash
export VM_RG="az104-lab15-${SUFFIX}-rg"
export VM_DST_RG="az104-lab15-dst-${SUFFIX}-rg"
az group create -n "$VM_RG" -l "$LOCATION" --tags workload=az104 environment=lab
az group create -n "$VM_DST_RG" -l "$LOCATION" --tags workload=az104 environment=lab
az network vnet create -g "$VM_RG" -n vm-vnet -l "$LOCATION" \
  --address-prefixes 10.40.0.0/16 --subnet-name workload --subnet-prefixes 10.40.1.0/24

az vm create -g "$VM_RG" -n linux01 --location "$LOCATION" --image Ubuntu2404 \
  --size Standard_B1s --vnet-name vm-vnet --subnet workload \
  --admin-username azureadmin --generate-ssh-keys --assign-identity \
  --security-type TrustedLaunch --enable-secure-boot true --enable-vtpm true \
  --public-ip-sku Standard

az vm show -g "$VM_RG" -n linux01 \
  --query '{size:hardwareProfile.vmSize,security:securityProfile,identity:identity.type,storage:storageProfile}' -o jsonc
az vm list-vm-resize-options -g "$VM_RG" -n linux01 --query '[].name' -o table
az vm resize -g "$VM_RG" -n linux01 --size Standard_B2s

az disk create -g "$VM_RG" -n linux01-data01 --size-gb 32 --sku StandardSSD_LRS
az vm disk attach -g "$VM_RG" --vm-name linux01 --name linux01-data01 --lun 0 --caching ReadWrite
az vm run-command invoke -g "$VM_RG" -n linux01 --command-id RunShellScript \
  --scripts @artifacts/lab15/mount-data-disk.sh

export DISK_ID="$(az disk show -g "$VM_RG" -n linux01-data01 --query id -o tsv)"
az snapshot create -g "$VM_RG" -n linux01-data01-snap --source "$DISK_ID" --sku Standard_LRS
export SNAP_ID="$(az snapshot show -g "$VM_RG" -n linux01-data01-snap --query id -o tsv)"
az disk create -g "$VM_RG" -n linux01-data01-restore --source "$SNAP_ID" --sku StandardSSD_LRS
az vm disk attach -g "$VM_RG" --vm-name linux01 --name linux01-data01-restore --lun 1 --caching None

# Boot diagnostics and instance view.
az vm boot-diagnostics enable -g "$VM_RG" -n linux01
az vm get-instance-view -g "$VM_RG" -n linux01 \
  --query '{power:instanceView.statuses[1].displayStatus,agent:instanceView.vmAgent.statuses[0].displayStatus}' -o yaml
az vm boot-diagnostics get-boot-log -g "$VM_RG" -n linux01

# Encryption at host is best selected at creation. Availability depends on subscription/region/SKU.
az feature show --namespace Microsoft.Compute --name EncryptionAtHost -o jsonc
# az vm update -g "$VM_RG" -n linux01 --set securityProfile.encryptionAtHost=true

# Move: gather VM and dependencies; validate carefully in Portal before production moves.
export DST_SCOPE="$(az group show -n "$VM_DST_RG" --query id -o tsv)"
az resource list -g "$VM_RG" --query '[].{name:name,type:type,id:id}' -o table
# az resource move --destination-group "$DST_SCOPE" --ids <vm-id> <nic-id> <disk-ids> <public-ip-id>

az vm deallocate -g "$VM_RG" -n linux01
```

The guest disk script assumes the first non-OS disk is the new disk. Always inspect `lsblk`, LUNs, existing signatures, and filesystem ownership before partitioning production disks.

Cross-region move uses Azure Resource Mover, with prepare/initiate/commit/discard stages and service-specific support. In a sandbox, inspect `az resource-mover --help` and the Portal workflow; do not perform a paid cross-region move solely to memorize clicks.

### PowerShell reference

```powershell
New-AzVM -ResourceGroupName $vmRg -Name linux01 -Location $location -Image Ubuntu2204 `
  -Size Standard_B1s -GenerateSshKey
Resize-AzVM -ResourceGroupName $vmRg -Name linux01 -Size Standard_B2s
$diskConfig = New-AzDiskConfig -Location $location -CreateOption Empty -DiskSizeGB 32 -SkuName StandardSSD_LRS
$disk = New-AzDisk -ResourceGroupName $vmRg -DiskName linux01-data01 -Disk $diskConfig
Add-AzVMDataDisk -VM $vm -Name linux01-data01 -ManagedDiskId $disk.Id -Lun 0 -CreateOption Attach
Stop-AzVM -ResourceGroupName $vmRg -Name linux01 -Force
```

### Exam tips

- Resize availability depends on the current cluster; deallocation may expose more sizes.
- Data-disk host caching should match the workload; database write logs often require `None`.
- A managed-disk snapshot is crash-consistent unless the workload is quiesced.
- Move operations have dependency and support constraints. Moving resource group/subscription does not move region.
- Deallocate to stop compute charges; disks and static public IPs can still incur charges.

## Lab 16 — Availability sets/zones, VM Scale Sets, and autoscale

**Time:** 130 minutes  
**Exam domain:** VM availability and Virtual Machine Scale Sets

### Theory checkpoint

Availability sets distribute VMs across fault and update domains inside a datacenter scope and require VMs to be placed at creation. Availability zones are physically separate locations within a region and can tolerate datacenter failure. Zone-redundant services spread automatically; zonal resources are pinned. VMSS provides a model for multiple instances, orchestration, health, rolling upgrades, and autoscale. Uniform mode emphasizes identical instances; flexible mode offers VM-like control and broader orchestration options.

### Portal journey

1. In a supported region, check which VM SKUs support zones. Create two small VMs across zones 1 and 2, or create an availability set and two VMs in it if zones/quotas are unavailable.
2. Compare SLA prerequisites and failure scope; no configuration can guarantee application availability without multiple healthy instances and a traffic layer.
3. Create **Virtual machine scale sets > Create**, choose Ubuntu, Uniform orchestration for the first exercise, two instances, zones where available, and a load balancer.
4. Add cloud-init or an extension to install nginx and expose an instance identifier.
5. Set manual instance count to 3, verify, then return to 2.
6. Add autoscale: minimum 2, default 2, maximum 4; scale out by 1 when average CPU > 70% for 10 minutes; scale in by 1 when CPU < 25% for 10 minutes. Observe cooldown and flapping risk.
7. Inspect upgrade policy, health, instance repair, overprovisioning, scale-in policy, and rolling-upgrade settings.
8. Delete the VMSS promptly.

### Azure CLI implementation

```bash
export SCALE_RG="az104-lab16-${SUFFIX}-rg"
export VMSS="web-vmss"
az group create -n "$SCALE_RG" -l "$LOCATION" --tags workload=az104 environment=lab
az vmss create -g "$SCALE_RG" -n "$VMSS" -l "$LOCATION" \
  --image Ubuntu2404 --vm-sku Standard_B1s --instance-count 2 \
  --admin-username azureadmin --generate-ssh-keys \
  --upgrade-policy-mode Automatic --lb web-vmss-lb --backend-pool-name web-pool

az vmss extension set -g "$SCALE_RG" --vmss-name "$VMSS" \
  --publisher Microsoft.Azure.Extensions --name CustomScript --version 2.1 \
  --settings '{"commandToExecute":"apt-get update && apt-get install -y nginx && hostname > /var/www/html/index.html"}'
az vmss scale -g "$SCALE_RG" -n "$VMSS" --new-capacity 3
az vmss list-instances -g "$SCALE_RG" -n "$VMSS" \
  --query '[].{instance:instanceId,state:provisioningState,latestModel:latestModelApplied}' -o table

export VMSS_ID="$(az vmss show -g "$SCALE_RG" -n "$VMSS" --query id -o tsv)"
az monitor autoscale create -g "$SCALE_RG" -n web-vmss-autoscale \
  --resource "$VMSS_ID" --resource-type Microsoft.Compute/virtualMachineScaleSets \
  --min-count 2 --max-count 4 --count 2
az monitor autoscale rule create -g "$SCALE_RG" --autoscale-name web-vmss-autoscale \
  --condition "Percentage CPU > 70 avg 10m" --scale out 1 --cooldown 5
az monitor autoscale rule create -g "$SCALE_RG" --autoscale-name web-vmss-autoscale \
  --condition "Percentage CPU < 25 avg 10m" --scale in 1 --cooldown 5
az monitor autoscale show -g "$SCALE_RG" -n web-vmss-autoscale -o jsonc

az group delete -n "$SCALE_RG" --yes --no-wait
```

### PowerShell reference

```powershell
$vmss = New-AzVmssConfig -Location $location -SkuCapacity 2 -SkuName Standard_B1s `
  -UpgradePolicyMode Automatic
New-AzVmss -ResourceGroupName $scaleRg -VMScaleSetName web-vmss -VirtualMachineScaleSet $vmss
Update-AzVmss -ResourceGroupName $scaleRg -VMScaleSetName web-vmss -SkuCapacity 3
```

### Exam tips

- Availability sets and zones address different failure domains. Neither replaces backup.
- You cannot place an existing ordinary VM into an availability set without redeployment.
- Autoscale is based on rules/profiles and takes time; configure both scale-out and safe scale-in.
- Instance model changes may require an upgrade action depending on upgrade policy.

## Lab 17 — App Service plans, apps, TLS, custom DNS, networking, slots, scaling, and backup

**Time:** 150 minutes  
**Exam domain:** Create and configure Azure App Service  
**Cost:** Standard/Premium tier required for several features; delete same day

### Theory checkpoint

An App Service plan supplies regional compute; apps in the plan share workers and scale together. Scale up changes SKU; scale out changes instance count. Deployment slots are live apps with their own hostnames; slot settings remain with a slot during swap. VNet integration is outbound from the app into a delegated subnet; private endpoints are inbound private access. Custom domains require DNS validation; TLS can use App Service managed certificates or imported certificates. Backups require supported tiers and storage.

### Portal journey

1. Create a Linux App Service plan in Standard S1 (or the current lowest tier supporting slots, autoscale, and backup) and a web app with a globally unique name.
2. Under **Configuration > General settings**, enforce HTTPS, minimum TLS 1.2 or newer, FTPS disabled, and an appropriate runtime stack.
3. Deploy a small application from a controlled source. Verify the default hostname.
4. Under **Deployment slots**, add `staging`. Deploy a visibly different version, mark a sample setting as a deployment-slot setting, warm it, then swap staging to production. Swap back for rollback practice.
5. Under **Scale up**, compare tiers. Under **Scale out**, configure two instances or autoscale with CPU thresholds and safe minimum/maximum counts.
6. Add a delegated subnet `appservice-integration` and configure **Networking > VNet integration**. Explain outbound-only behavior.
7. If you own a domain, add **Custom domains**, create required TXT/A/CNAME records, validate, then add an App Service managed certificate and bind TLS. Do not invent ownership.
8. Create a private storage container and short-lived SAS for **Backups**. Configure a backup, run it, and inspect status. Restore to a slot/new app when possible rather than overwriting production.
9. Delete the entire resource group promptly.

### Azure CLI implementation

```bash
export APP_RG="az104-lab17-${SUFFIX}-rg"
export PLAN="az104-plan-${SUFFIX}"
export WEBAPP="az104-web-${SUFFIX}"
az group create -n "$APP_RG" -l "$LOCATION" --tags workload=az104 environment=lab
az appservice plan create -g "$APP_RG" -n "$PLAN" -l "$LOCATION" --is-linux --sku S1
az webapp create -g "$APP_RG" -p "$PLAN" -n "$WEBAPP" --runtime 'PYTHON:3.12'
az webapp update -g "$APP_RG" -n "$WEBAPP" --https-only true
az webapp config set -g "$APP_RG" -n "$WEBAPP" \
  --min-tls-version 1.2 --ftps-state Disabled --http20-enabled true --always-on true

az webapp config appsettings set -g "$APP_RG" -n "$WEBAPP" \
  --settings ENVIRONMENT=production FEATURE_FLAG=blue
az webapp deployment slot create -g "$APP_RG" -n "$WEBAPP" --slot staging
az webapp config appsettings set -g "$APP_RG" -n "$WEBAPP" --slot staging \
  --slot-settings ENVIRONMENT=staging FEATURE_FLAG=green
az webapp deployment slot swap -g "$APP_RG" -n "$WEBAPP" --slot staging --target-slot production

# Manual scale and autoscale at the plan resource.
az appservice plan update -g "$APP_RG" -n "$PLAN" --number-of-workers 2
export PLAN_ID="$(az appservice plan show -g "$APP_RG" -n "$PLAN" --query id -o tsv)"
az monitor autoscale create -g "$APP_RG" -n app-plan-autoscale --resource "$PLAN_ID" \
  --resource-type Microsoft.Web/serverfarms --min-count 1 --max-count 3 --count 1
az monitor autoscale rule create -g "$APP_RG" --autoscale-name app-plan-autoscale \
  --condition "CpuPercentage > 70 avg 10m" --scale out 1 --cooldown 5
az monitor autoscale rule create -g "$APP_RG" --autoscale-name app-plan-autoscale \
  --condition "CpuPercentage < 30 avg 10m" --scale in 1 --cooldown 5

# VNet integration.
az network vnet create -g "$APP_RG" -n app-vnet -l "$LOCATION" \
  --address-prefixes 10.70.0.0/16 --subnet-name appservice-integration --subnet-prefixes 10.70.1.0/24
az network vnet subnet update -g "$APP_RG" --vnet-name app-vnet -n appservice-integration \
  --delegations Microsoft.Web/serverFarms
az webapp vnet-integration add -g "$APP_RG" -n "$WEBAPP" --vnet app-vnet --subnet appservice-integration
az webapp vnet-integration list -g "$APP_RG" -n "$WEBAPP" -o table

# Custom domain only with a domain you control.
# az webapp config hostname add -g "$APP_RG" -n "$WEBAPP" --hostname app.example.com
# az webapp config ssl create -g "$APP_RG" -n "$WEBAPP" --hostname app.example.com
# az webapp config ssl bind -g "$APP_RG" -n "$WEBAPP" --certificate-thumbprint <thumbprint> --ssl-type SNI

# Portal is preferred for the first backup because it safely creates/validates storage settings.
az webapp config backup list -g "$APP_RG" --webapp-name "$WEBAPP" -o jsonc
az webapp log config -g "$APP_RG" -n "$WEBAPP" --application-logging filesystem \
  --web-server-logging filesystem --detailed-error-messages true --failed-request-tracing true

az group delete -n "$APP_RG" --yes --no-wait
```

### PowerShell reference

```powershell
New-AzAppServicePlan -ResourceGroupName $appRg -Name $plan -Location $location -Tier Standard `
  -WorkerSize Small -Linux
New-AzWebApp -ResourceGroupName $appRg -Name $webapp -Location $location -AppServicePlan $plan
New-AzWebAppSlot -ResourceGroupName $appRg -Name $webapp -Slot staging
Switch-AzWebAppSlot -ResourceGroupName $appRg -Name $webapp -SourceSlotName staging -DestinationSlotName production
```

### Production notes and exam tips

- Apps in one plan share scale and failure/capacity boundaries. Separate plans when isolation or independent scale is required.
- Slot swaps move non-slot settings; mark secrets/endpoints that must remain with the slot.
- VNet integration is outbound. A private endpoint addresses inbound private connectivity.
- Always validate DNS ownership before binding a custom hostname. Enable HTTPS-only and correct TLS binding.
- Backups do not include every external dependency; test full application recovery.

## Lab 18 — ACR, ACI, and Container Apps with managed identity, revisions, and scaling

**Time:** 150 minutes  
**Exam domain:** Provision and manage containers in the Azure portal  
**Artifacts:** [`../artifacts/lab18/Dockerfile`](../artifacts/lab18/Dockerfile), [`../artifacts/lab18/index.html`](../artifacts/lab18/index.html), and the [`v2 image context`](../artifacts/lab18-v2/Dockerfile)

### Theory checkpoint

ACR stores OCI images/artifacts and supports authentication, RBAC, tasks, webhooks, geo-replication in higher tiers, retention, and content trust/scanning integrations. ACI runs containers without orchestration; container groups share lifecycle/network/storage. Container Apps is a serverless application platform built on Kubernetes concepts with environments, revisions, ingress, Dapr options, KEDA-based scale, secrets, and managed identity.

Use immutable version tags or digests, scan images, avoid `latest`, run as non-root, use managed identity for pulls, keep secrets out of images/environment where possible, and constrain CPU/memory and network exposure.

### Portal journey

1. Create **Container Registry > Basic**, disable admin user, and inspect repositories, access keys, networking, encryption, tasks, and permissions.
2. Use an ACR Task or Cloud Shell to build the included image as `az104-web:v1`. Inspect the manifest/digest and vulnerability/security recommendations available in your subscription.
3. Create a user-assigned managed identity and grant it **AcrPull** at the registry scope.
4. Create **Container instances** from the private ACR image, use the identity for registry access, 1 vCPU/1 GB, public DNS label for the lab, TCP 8080, and restart policy Always. Validate logs, events, IP/FQDN, and restart behavior.
5. Create a **Container Apps environment** and app. Use external ingress on port 8080, the same image/identity, minimum 0 or 1 and maximum 3 replicas.
6. Deploy `v2`, create a new revision, split traffic 80/20, validate, then route 100% to v2. Compare single versus multiple revision mode.
7. Add an HTTP scaling rule or use concurrent requests; observe replicas. Store a sample secret and reference it without displaying its value.
8. Delete the group promptly.

### Azure CLI implementation

```bash
export CONTAINER_RG="az104-lab18-${SUFFIX}-rg"
export ACR="az104acr${SUFFIX}"
export ACI="az104-aci-${SUFFIX}"
export CA_ENV="az104-ca-env-${SUFFIX}"
export CA_APP="az104-ca-${SUFFIX}"
az group create -n "$CONTAINER_RG" -l "$LOCATION" --tags workload=az104 environment=lab
az acr create -g "$CONTAINER_RG" -n "$ACR" -l "$LOCATION" --sku Basic --admin-enabled false
az acr build -r "$ACR" -t az104-web:v1 artifacts/lab18
export ACR_ID="$(az acr show -g "$CONTAINER_RG" -n "$ACR" --query id -o tsv)"
export ACR_LOGIN="$(az acr show -g "$CONTAINER_RG" -n "$ACR" --query loginServer -o tsv)"
az acr manifest list-metadata -r "$ACR" -n az104-web \
  --query '[].{digest:digest,tags:tags,created:createdTime}' -o table

az identity create -g "$CONTAINER_RG" -n container-pull-id -l "$LOCATION"
export PULL_ID="$(az identity show -g "$CONTAINER_RG" -n container-pull-id --query id -o tsv)"
export PULL_PRINCIPAL="$(az identity show -g "$CONTAINER_RG" -n container-pull-id --query principalId -o tsv)"
az role assignment create --assignee-object-id "$PULL_PRINCIPAL" --assignee-principal-type ServicePrincipal \
  --role AcrPull --scope "$ACR_ID"

# ACI uses the user-assigned identity for the private registry pull.
az container create -g "$CONTAINER_RG" -n "$ACI" -l "$LOCATION" \
  --image "${ACR_LOGIN}/az104-web:v1" --registry-login-server "$ACR_LOGIN" \
  --assign-identity "$PULL_ID" --acr-identity "$PULL_ID" \
  --cpu 1 --memory 1 --ports 8080 --ip-address Public \
  --dns-name-label "$ACI" --restart-policy Always
az container show -g "$CONTAINER_RG" -n "$ACI" \
  --query '{state:instanceView.state,fqdn:ipAddress.fqdn,ip:ipAddress.ip,containers:containers[].instanceView.currentState}' -o jsonc
az container logs -g "$CONTAINER_RG" -n "$ACI"

# Container Apps extension and provider setup.
az extension add --name containerapp --upgrade
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights
az containerapp env create -g "$CONTAINER_RG" -n "$CA_ENV" -l "$LOCATION"
az containerapp create -g "$CONTAINER_RG" -n "$CA_APP" --environment "$CA_ENV" \
  --image "${ACR_LOGIN}/az104-web:v1" --user-assigned "$PULL_ID" \
  --registry-server "$ACR_LOGIN" --registry-identity "$PULL_ID" \
  --ingress external --target-port 8080 --min-replicas 0 --max-replicas 3 \
  --revision-suffix v1
az containerapp revision set-mode -g "$CONTAINER_RG" -n "$CA_APP" --mode multiple

# Build v2, update the app, and inspect revisions. Capture returned revision names before traffic split.
az acr build -r "$ACR" -t az104-web:v2 artifacts/lab18-v2
az containerapp update -g "$CONTAINER_RG" -n "$CA_APP" \
  --image "${ACR_LOGIN}/az104-web:v2" --revision-suffix v2
az containerapp revision list -g "$CONTAINER_RG" -n "$CA_APP" \
  --query '[].{name:name,active:properties.active,traffic:properties.trafficWeight,replicas:properties.replicas}' -o table
export REV_V1="$(az containerapp revision list -g "$CONTAINER_RG" -n "$CA_APP" --query "[?ends_with(name, '-v1')].name | [0]" -o tsv)"
export REV_V2="$(az containerapp revision list -g "$CONTAINER_RG" -n "$CA_APP" --query "[?ends_with(name, '-v2')].name | [0]" -o tsv)"
az containerapp ingress traffic set -g "$CONTAINER_RG" -n "$CA_APP" \
  --revision-weight "${REV_V1}=20" "${REV_V2}=80"
az containerapp show -g "$CONTAINER_RG" -n "$CA_APP" \
  --query '{fqdn:properties.configuration.ingress.fqdn,provisioning:properties.provisioningState}' -o yaml

az group delete -n "$CONTAINER_RG" --yes --no-wait
```

If identity propagation delays cause an initial `AcrPull` failure, wait a few minutes and retry. Do not solve it by permanently enabling the ACR admin account.

### PowerShell reference

```powershell
New-AzContainerRegistry -ResourceGroupName $containerRg -Name $acr -Sku Basic -Location $location
New-AzUserAssignedIdentity -ResourceGroupName $containerRg -Name container-pull-id -Location $location
New-AzContainerGroup -ResourceGroupName $containerRg -Name $aci -Image "$acr.azurecr.io/az104-web:v1" `
  -OsType Linux -IpAddressType Public -Port 8080
```

### Exam tips

- ACI scaling means changing/redeploying group resources; Container Apps supports rule-based replica scaling.
- ACR `AcrPull` is data-plane image-read access. Assign it to the workload identity at registry scope.
- Container Apps revisions are immutable snapshots; traffic splitting enables canary/blue-green deployment.
- Container Apps environments provide a boundary for networking and observability; apps scale independently.

## Lab 19 — AKS fundamentals (enrichment)

**Time:** 120 minutes  
**Scope note:** explicitly requested enrichment. The April 17, 2026 AZ-104 blueprint names ACR, ACI, and Container Apps, not AKS administration.  
**Cost:** cluster nodes and public IP/load balancer; delete immediately

### Theory checkpoint

AKS provides a managed Kubernetes control plane while you manage node pools, workloads, networking choices, upgrades, identity/RBAC, policy, and operations. A Kubernetes Deployment manages replica Pods; a Service provides stable access; ClusterIP is internal and LoadBalancer provisions Azure networking. Do not confuse Azure RBAC with Kubernetes RBAC, even when Entra integration connects authentication.

### Portal journey

1. Create **Kubernetes services > Create** in a dedicated group. Select a small system node pool, managed identity, Azure RBAC integration where appropriate, and a supported Kubernetes version.
2. Review **Authentication and authorization**, **Networking**, **Integrations**, **Monitoring**, **Advanced**, and **Tags**. Keep default public API access only for this sandbox; production should restrict the API server.
3. Attach a small ACR or grant the kubelet identity `AcrPull`.
4. Connect with Cloud Shell, download credentials, and inspect nodes/namespaces.
5. Deploy a three-replica nginx Deployment and LoadBalancer Service. Verify external access, scale to five replicas, then return to three.
6. Inspect Pods, events, logs, service endpoints, node pool scaling, upgrade availability, and Insights.
7. Delete the resource group; do not merely delete the Kubernetes objects and leave paid nodes.

### Azure CLI implementation

```bash
export AKS_RG="az104-lab19-${SUFFIX}-rg"
export AKS="az104-aks-${SUFFIX}"
az group create -n "$AKS_RG" -l "$LOCATION" --tags workload=az104 environment=lab
az aks get-versions -l "$LOCATION" -o table
az aks create -g "$AKS_RG" -n "$AKS" -l "$LOCATION" \
  --node-count 1 --node-vm-size Standard_B2s \
  --enable-managed-identity --enable-aad --enable-azure-rbac \
  --generate-ssh-keys --network-plugin azure
az aks get-credentials -g "$AKS_RG" -n "$AKS" --overwrite-existing
kubectl get nodes -o wide

kubectl create deployment az104-web --image=nginx:1.27-alpine --replicas=3
kubectl expose deployment az104-web --type=LoadBalancer --port=80 --target-port=80
kubectl rollout status deployment/az104-web
kubectl get pods,service -o wide
kubectl scale deployment az104-web --replicas=5
kubectl get events --sort-by=.lastTimestamp
kubectl logs deployment/az104-web --tail=20
kubectl scale deployment az104-web --replicas=3

az aks nodepool list -g "$AKS_RG" --cluster-name "$AKS" -o table
az aks get-upgrades -g "$AKS_RG" -n "$AKS" -o table
az group delete -n "$AKS_RG" --yes --no-wait
```

### PowerShell reference

```powershell
New-AzAksCluster -ResourceGroupName $aksRg -Name $aks -Location $location `
  -NodeCount 1 -NodeVmSize Standard_B2s -GenerateSshKey
Import-AzAksCredential -ResourceGroupName $aksRg -Name $aks -Force
Get-AzAksCluster -ResourceGroupName $aksRg -Name $aks
```

### Production notes

- Use supported version/skew, maintenance windows, multiple zones/node pools, Pod disruption budgets, readiness/liveness probes, resource requests/limits, network policy, workload identity, private/restricted API access, backups, and tested upgrades.
- Avoid cluster-admin credentials for routine work. Separate Azure and Kubernetes authorization responsibilities.
- Revisit AKS in AZ-305/AZ-400 or Kubernetes-focused learning; do not let it displace higher-weight AZ-104 objectives.

## Module checkpoint

Take the [compute, apps, and containers checkpoint](../assessments/module-04-compute-apps-containers.md) closed-book. Revisit Labs 14–19 for misses; AKS questions remain enrichment and should not displace the named AZ-104 compute objectives.
