# Supplemental course labs

These labs reconcile useful breadth from the supplied CloudLee/Udemy syllabi and the broader Microsoft course overview with the narrower April 17, 2026 exam blueprint. Complete them after the 25 core labs. Do not displace higher-weight current objectives unless your job also needs these services.

## Supplemental A — Managed identities and Azure Key Vault

**Time:** 100 minutes  
**Blueprint status:** adjacent security/identity skill; not a named April 2026 AZ-104 bullet  
**Cost:** small VM and Key Vault operations

### Theory checkpoint

A system-assigned managed identity shares the Azure resource lifecycle; a user-assigned identity is an independent reusable resource. Both are service principals whose credentials Azure manages. Key Vault separates management-plane RBAC from secrets/keys/certificates data-plane access. Prefer the Azure RBAC permission model, private access where required, soft delete, purge protection for production, key rotation, logging, and no secrets in source or command history.

### Portal journey

1. Create a Key Vault with Azure RBAC authorization, soft delete, purge protection for a real production design (purge protection is intentionally hard to reverse), and public access temporarily enabled for the sandbox.
2. Create a private test secret with a short expiration. Never use a real credential.
3. Create a small VM with system-assigned managed identity and no public IP.
4. Assign the VM identity **Key Vault Secrets User** at vault scope. Do not assign Key Vault Administrator.
5. From **Run command**, request a managed-identity token from IMDS and call the Key Vault Secret REST endpoint. Do not print the secret in screenshots/logs; validate only an expected hash/marker.
6. Create a user-assigned identity, attach it to the VM, assign the same minimum role, and compare lifecycle/reuse.
7. Enable Key Vault diagnostic settings to the operations workspace. Review access and audit logs.
8. Delete the test resources. Understand soft-deleted vault naming and purge permissions.

### Azure CLI implementation

```bash
export KV_RG="az104-sup-kv-${SUFFIX}-rg"
export KV="az104-kv-${SUFFIX}"
az group create -n "$KV_RG" -l "$LOCATION" --tags workload=az104 environment=lab
az keyvault create -g "$KV_RG" -n "$KV" -l "$LOCATION" \
  --enable-rbac-authorization true --retention-days 7
read -rsp 'Disposable lab secret value: ' LAB_SECRET; echo
az keyvault secret set --vault-name "$KV" -n app-marker --value "$LAB_SECRET" \
  --expires "$(date -u -d '+1 day' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo '2026-12-31T23:59:59Z')" \
  --query id -o tsv
unset LAB_SECRET

az vm create -g "$KV_RG" -n kvvm01 --image Ubuntu2404 --size Standard_B1s \
  --admin-username azureadmin --generate-ssh-keys --public-ip-address '' --assign-identity
export VM_PRINCIPAL="$(az vm identity show -g "$KV_RG" -n kvvm01 --query principalId -o tsv)"
export KV_ID="$(az keyvault show -g "$KV_RG" -n "$KV" --query id -o tsv)"
az role assignment create --assignee-object-id "$VM_PRINCIPAL" --assignee-principal-type ServicePrincipal \
  --role 'Key Vault Secrets User' --scope "$KV_ID"

# Use IMDS inside the VM. The script prints only the secret identifier, not its value.
export KV_READ_SCRIPT="$(sed "s/__KV_NAME__/${KV}/g" artifacts/supplemental/keyvault-read.sh)"
az vm run-command invoke -g "$KV_RG" -n kvvm01 --command-id RunShellScript \
  --scripts "$KV_READ_SCRIPT"
unset KV_READ_SCRIPT

az group delete -n "$KV_RG" --yes --no-wait
```

### PowerShell reference

```powershell
$vault = New-AzKeyVault -ResourceGroupName $kvRg -VaultName $kv -Location $location -EnableRbacAuthorization
$secret = Read-Host 'Disposable lab secret' -AsSecureString
Set-AzKeyVaultSecret -VaultName $kv -Name app-marker -SecretValue $secret
New-AzRoleAssignment -ObjectId $vmPrincipal -RoleDefinitionName 'Key Vault Secrets User' -Scope $vault.ResourceId
```

### Best practices

- Managed identity removes credential management, not authorization design.
- Key Vault Contributor cannot read secret values under the RBAC data plane; select a data role.
- Purge protection is a production defense against malicious/accidental permanent deletion; test its operational consequences in a disposable vault.

## Supplemental B — VPN Gateway, ExpressRoute, and Virtual WAN concepts

**Time:** 3–5 hours  
**Blueprint status:** broader course/hybrid-networking knowledge; not an explicit April 2026 bullet  
**Cost:** VPN gateways are expensive and slow to provision; delete the same day

### Theory checkpoint

VPN Gateway provides encrypted connectivity: point-to-site for clients, site-to-site for networks, and VNet-to-VNet. Route-based VPN is the modern general choice. The dedicated `GatewaySubnet` must be appropriately sized and must not contain arbitrary workloads. Active-active, zone-redundant SKUs, BGP, local network gateways, connection shared keys/certificates, and throughput/SLA must match requirements.

ExpressRoute provides private connectivity through a provider; private peering uses BGP and is not encrypted by default. Virtual WAN provides Microsoft-managed hubs for branch/VPN/ExpressRoute/user connectivity and routing at scale.

### Portal journey

1. Create VNet A `10.120.0.0/16` and VNet B `10.130.0.0/16`, each with workload subnet and `GatewaySubnet` `/27` or larger according to current SKU guidance.
2. Create one zone-redundant/standard public IP and route-based VPN gateway in each VNet using the lowest appropriate lab SKU. Provisioning can take 30–60 minutes.
3. Create **Connections > VNet-to-VNet** from A to B with a generated lab-only shared key. Create/verify the reciprocal relationship if required by the workflow.
4. Inspect connection status, bytes in/out, learned routes/BGP settings, effective routes, diagnostics, and reset controls.
5. Deploy one private VM in each VNet, allow only private test traffic, and validate across the gateway.
6. Open **ExpressRoute circuits > Create** and inspect provider, peering location, bandwidth, SKU, billing, and authorization without purchasing a circuit.
7. Open **Virtual WAN** and inspect Standard versus Basic, virtual hub, VPN/ER gateways, connections, route tables, and secured virtual hub without deploying paid gateways.
8. Delete both VPN gateways/public IPs and verify deletion before leaving.

### Azure CLI implementation

```bash
export HYBRID_RG="az104-sup-hybrid-${SUFFIX}-rg"
az group create -n "$HYBRID_RG" -l "$LOCATION" --tags workload=az104 environment=lab
az network vnet create -g "$HYBRID_RG" -n vnet-a -l "$LOCATION" \
  --address-prefixes 10.120.0.0/16 --subnet-name workload --subnet-prefixes 10.120.1.0/24
az network vnet subnet create -g "$HYBRID_RG" --vnet-name vnet-a -n GatewaySubnet \
  --address-prefixes 10.120.255.0/27
az network vnet create -g "$HYBRID_RG" -n vnet-b -l "$LOCATION2" \
  --address-prefixes 10.130.0.0/16 --subnet-name workload --subnet-prefixes 10.130.1.0/24
az network vnet subnet create -g "$HYBRID_RG" --vnet-name vnet-b -n GatewaySubnet \
  --address-prefixes 10.130.255.0/27
az network public-ip create -g "$HYBRID_RG" -n gw-a-pip -l "$LOCATION" --sku Standard --allocation-method Static
az network public-ip create -g "$HYBRID_RG" -n gw-b-pip -l "$LOCATION2" --sku Standard --allocation-method Static

az network vnet-gateway create -g "$HYBRID_RG" -n gw-a -l "$LOCATION" \
  --vnet vnet-a --public-ip-address gw-a-pip --gateway-type Vpn --vpn-type RouteBased --sku VpnGw1 --no-wait
az network vnet-gateway create -g "$HYBRID_RG" -n gw-b -l "$LOCATION2" \
  --vnet vnet-b --public-ip-address gw-b-pip --gateway-type Vpn --vpn-type RouteBased --sku VpnGw1 --no-wait

# Continue only after both gateways show Succeeded.
az network vnet-gateway list -g "$HYBRID_RG" \
  --query '[].{name:name,region:location,state:provisioningState}' -o table
read -rsp 'Disposable VPN shared key: ' VPN_KEY; echo
export GW_A_ID="$(az network vnet-gateway show -g "$HYBRID_RG" -n gw-a --query id -o tsv)"
export GW_B_ID="$(az network vnet-gateway show -g "$HYBRID_RG" -n gw-b --query id -o tsv)"
az network vpn-connection create -g "$HYBRID_RG" -n a-to-b \
  --vnet-gateway1 "$GW_A_ID" --vnet-gateway2 "$GW_B_ID" --shared-key "$VPN_KEY"
unset VPN_KEY
az network vpn-connection show -g "$HYBRID_RG" -n a-to-b \
  --query '{status:connectionStatus,ingress:ingressBytesTransferred,egress:egressBytesTransferred}' -o yaml

# Inspect ExpressRoute/Virtual WAN command surfaces without purchasing.
az network express-route list-service-providers -o table
az network vwan --help

az group delete -n "$HYBRID_RG" --yes --no-wait
```

### PowerShell reference

```powershell
New-AzVirtualNetworkGatewayIpConfig -Name gw-a-ipconfig -SubnetId $gatewaySubnet.Id -PublicIpAddressId $pip.Id
New-AzVirtualNetworkGateway -Name gw-a -ResourceGroupName $hybridRg -Location $location `
  -IpConfigurations $ipConfig -GatewayType Vpn -VpnType RouteBased -GatewaySku VpnGw1
New-AzVirtualNetworkGatewayConnection -Name a-to-b -ResourceGroupName $hybridRg -Location $location `
  -VirtualNetworkGateway1 $gwA -VirtualNetworkGateway2 $gwB -ConnectionType Vnet2Vnet -SharedKey $sharedKey
```

### Best practices

- Store shared keys securely and rotate them; use certificates/Entra authentication for appropriate P2S designs.
- Avoid NSGs/UDRs on `GatewaySubnet` unless the exact supported design requires them.
- Gateway deletion is asynchronous. Confirm the paid resources are gone.

## Supplemental C — Application Gateway WAF and Azure Firewall

**Time:** 4–6 hours  
**Blueprint status:** important traffic/security services in the supplied courses; current named objective focuses on Load Balancer  
**Cost:** high. Use a dedicated sandbox and delete immediately.

### Theory checkpoint

Application Gateway is a regional layer-7 reverse proxy. Listener, frontend, backend pool, HTTP settings, probe, rule, and optional rewrite/redirect/TLS settings form the request path. WAF v2 adds managed/custom rules in Detection or Prevention mode. Azure Firewall is a stateful managed firewall with network, application, and DNAT rules; Firewall Policy centralizes rules and supports Premium features such as TLS inspection/IDPS where configured.

### Portal journey

1. Create hub VNet with dedicated `AzureFirewallSubnet` (minimum/current supported size) and spoke VNet with dedicated Application Gateway subnet plus backend subnet. Peer hub/spoke and allow forwarded traffic as designed.
2. Create WAF_v2 Application Gateway with public frontend, HTTP listener, two web backends, custom health probe, and path-based rule. Start WAF in Detection, inspect logs, then move tested rules to Prevention.
3. Validate backend health before testing client traffic. Add HTTPS only with a certificate you are authorized to use; redirect HTTP to HTTPS.
4. Create Firewall Policy and Azure Firewall in the hub. Add a route table to send spoke egress `0.0.0.0/0` to the firewall private IP.
5. Add the minimum application/network rules for required egress and optional DNAT for an authorized test. Verify logs and rule collection priority.
6. Send Application Gateway and Firewall logs/metrics to the workspace. Run KQL for denied flows and WAF matches.
7. Deliberately break one backend probe and one firewall rule, diagnose, then restore.
8. Delete Application Gateway, Firewall, public IPs, and group immediately.

### Azure CLI implementation outline

```bash
export SEC_RG="az104-sup-security-${SUFFIX}-rg"
az group create -n "$SEC_RG" -l "$LOCATION" --tags workload=az104 environment=lab
az network vnet create -g "$SEC_RG" -n security-vnet -l "$LOCATION" \
  --address-prefixes 10.140.0.0/16 --subnet-name appgw-subnet --subnet-prefixes 10.140.1.0/24
az network vnet subnet create -g "$SEC_RG" --vnet-name security-vnet -n backend-subnet \
  --address-prefixes 10.140.2.0/24
az network vnet subnet create -g "$SEC_RG" --vnet-name security-vnet -n AzureFirewallSubnet \
  --address-prefixes 10.140.254.0/26

# Deploy backend VMs privately, then create WAF_v2 Application Gateway.
az network public-ip create -g "$SEC_RG" -n appgw-pip --sku Standard --allocation-method Static
az network application-gateway create -g "$SEC_RG" -n appgw -l "$LOCATION" \
  --sku WAF_v2 --capacity 2 --vnet-name security-vnet --subnet appgw-subnet \
  --public-ip-address appgw-pip --servers '<backend-private-ip-1>' '<backend-private-ip-2>' \
  --http-settings-port 80 --http-settings-protocol Http --frontend-port 80
az network application-gateway probe create -g "$SEC_RG" --gateway-name appgw -n app-health \
  --protocol Http --host 127.0.0.1 --path /health --interval 30 --timeout 30 --threshold 3
az network application-gateway show-backend-health -g "$SEC_RG" -n appgw -o jsonc

# Firewall and policy. Review every rule before applying forced tunneling.
az network firewall policy create -g "$SEC_RG" -n lab-fw-policy -l "$LOCATION"
az network public-ip create -g "$SEC_RG" -n firewall-pip --sku Standard --allocation-method Static
az network firewall create -g "$SEC_RG" -n lab-firewall -l "$LOCATION" \
  --vnet-name security-vnet --public-ip firewall-pip --firewall-policy lab-fw-policy
export FW_PRIVATE_IP="$(az network firewall show -g "$SEC_RG" -n lab-firewall \
  --query 'ipConfigurations[0].privateIPAddress' -o tsv)"
az network firewall policy rule-collection-group create -g "$SEC_RG" --policy-name lab-fw-policy \
  -n baseline-rules --priority 200
az network firewall policy rule-collection-group collection add-filter-collection -g "$SEC_RG" \
  --policy-name lab-fw-policy --rule-collection-group-name baseline-rules \
  --name allow-approved-web --collection-priority 100 --action Allow --rule-type ApplicationRule \
  --rule-name allow-microsoft-docs --source-addresses 10.140.2.0/24 \
  --protocols Http=80 Https=443 --target-fqdns learn.microsoft.com

# Delete promptly after diagnostics and validation.
az group delete -n "$SEC_RG" --yes --no-wait
```

Command shapes for Firewall Policy rule collections evolve; inspect `--help` and use the Portal's exported template when the local extension differs.

### PowerShell reference

```powershell
New-AzApplicationGateway -Name appgw -ResourceGroupName $secRg -Location $location `
  -Sku $appGwSku -GatewayIPConfigurations $gatewayIpConfig -FrontendIPConfigurations $frontend `
  -FrontendPorts $frontendPort -BackendAddressPools $backendPool -BackendHttpSettingsCollection $httpSettings `
  -HttpListeners $listener -RequestRoutingRules $rule
New-AzFirewallPolicy -Name lab-fw-policy -ResourceGroupName $secRg -Location $location
New-AzFirewall -Name lab-firewall -ResourceGroupName $secRg -Location $location `
  -VirtualNetwork $vnet -PublicIpAddress $firewallPip -FirewallPolicyId $policy.Id
```

### Best practices

- Diagnose Application Gateway from backend health outward: DNS/backend address, NSG/UDR, probe, HTTP settings, certificate/SNI, listener, and rule.
- WAF Detection records findings; Prevention blocks. Tune exclusions narrowly and from evidence.
- Forced tunneling without required firewall rules/DNS routes can strand workloads and management services.
- Application Gateway and Azure Firewall solve different problems and can coexist; one is not a drop-in replacement for the other.
