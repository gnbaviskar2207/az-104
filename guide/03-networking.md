# Stage 3 — Implement and manage virtual networking

## Lab 10 — VNets, subnets, public IPs, NSGs, ASGs, and effective rules

**Time:** 110 minutes  
**Exam domain:** Implement and manage virtual networking  
**Cost:** one small VM and public IP while running

### Theory checkpoint

A VNet is a private routing boundary in one region; address spaces and subnets must not overlap when networks will be connected. Azure reserves five IPv4 addresses in every subnet. A NIC receives a private IP from a subnet; a public IP is a separate resource mapped by Azure. Standard public IPs are secure by default and require an NSG rule for inbound traffic.

NSGs are stateful layer-3/4 filters. Rules are processed by priority (lowest number first) until a match. Inbound traffic must pass both subnet and NIC NSGs when both exist; outbound traffic must also pass both. ASGs group NIC IP configurations logically so rules do not hard-code application IPs. Effective rules combine applicable NSGs and defaults.

### Portal journey

1. Create resource group `az104-lab10-<suffix>-rg`.
2. Go to **Virtual networks > Create**. Use `10.10.0.0/16` and create `web-subnet` (`10.10.1.0/24`) plus `app-subnet` (`10.10.2.0/24`).
3. Create NSG `web-nsg`. Add inbound rule priority 100 allowing TCP 80 from Internet and priority 110 allowing TCP 22 only from **My IP address**. Associate it to `web-subnet`.
4. Create ASGs `web-asg` and `app-asg`.
5. Create a Standard static public IP, then a small Ubuntu VM in `web-subnet`. Add its NIC IP configuration to `web-asg`. Use SSH keys, not a password.
6. Install nginx with the VM Run command. Test HTTP from your workstation and SSH only from the allowed IP.
7. Open the VM **Networking > Network settings**, select the NIC, and inspect **Effective security rules** and **Effective routes**.
8. Add a temporary higher-priority Deny TCP 80 rule, observe failure, then remove it. This proves first-match priority behavior.

### Azure CLI implementation

```bash
export NET_RG="az104-lab10-${SUFFIX}-rg"
export VNET="core-vnet"
export WEB_SUBNET="web-subnet"
az group create -n "$NET_RG" -l "$LOCATION" --tags workload=az104 environment=lab
az network vnet create -g "$NET_RG" -n "$VNET" -l "$LOCATION" \
  --address-prefixes 10.10.0.0/16 --subnet-name "$WEB_SUBNET" --subnet-prefixes 10.10.1.0/24
az network vnet subnet create -g "$NET_RG" --vnet-name "$VNET" -n app-subnet \
  --address-prefixes 10.10.2.0/24

az network nsg create -g "$NET_RG" -n web-nsg -l "$LOCATION"
az network nsg rule create -g "$NET_RG" --nsg-name web-nsg -n Allow-HTTP \
  --priority 100 --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes Internet --source-port-ranges '*' \
  --destination-address-prefixes '*' --destination-port-ranges 80

# Replace with one trusted CIDR; never use '*' for SSH/RDP in a production design.
export ADMIN_CIDR="<your-public-ip>/32"
az network nsg rule create -g "$NET_RG" --nsg-name web-nsg -n Allow-SSH-Admin \
  --priority 110 --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes "$ADMIN_CIDR" --destination-port-ranges 22
az network vnet subnet update -g "$NET_RG" --vnet-name "$VNET" -n "$WEB_SUBNET" \
  --network-security-group web-nsg

az network asg create -g "$NET_RG" -n web-asg -l "$LOCATION"
az network asg create -g "$NET_RG" -n app-asg -l "$LOCATION"
az network public-ip create -g "$NET_RG" -n web-pip --sku Standard --allocation-method Static

az vm create -g "$NET_RG" -n web01 --image Ubuntu2404 --size Standard_B1s \
  --vnet-name "$VNET" --subnet "$WEB_SUBNET" --public-ip-address web-pip \
  --nsg '' --admin-username azureadmin --generate-ssh-keys
az vm run-command invoke -g "$NET_RG" -n web01 --command-id RunShellScript \
  --scripts 'sudo apt-get update && sudo apt-get install -y nginx && echo web01 | sudo tee /var/www/html/index.html'

export NIC_ID="$(az vm show -g "$NET_RG" -n web01 --query 'networkProfile.networkInterfaces[0].id' -o tsv)"
export NIC_NAME="${NIC_ID##*/}"
export WEB_ASG_ID="$(az network asg show -g "$NET_RG" -n web-asg --query id -o tsv)"
az network nic ip-config update -g "$NET_RG" --nic-name "$NIC_NAME" -n ipconfigweb01 \
  --application-security-groups "$WEB_ASG_ID"

export WEB_IP="$(az network public-ip show -g "$NET_RG" -n web-pip --query ipAddress -o tsv)"
curl -fsS "http://${WEB_IP}"
az network nic list-effective-nsg -g "$NET_RG" -n "$NIC_NAME" -o jsonc
az network nic show-effective-route-table -g "$NET_RG" -n "$NIC_NAME" -o table

# Demonstrate priority: this deny wins over Allow-HTTP.
az network nsg rule create -g "$NET_RG" --nsg-name web-nsg -n Deny-HTTP-Test \
  --priority 90 --direction Inbound --access Deny --protocol Tcp \
  --source-address-prefixes Internet --destination-port-ranges 80
az network nsg rule delete -g "$NET_RG" --nsg-name web-nsg -n Deny-HTTP-Test
```

### PowerShell reference

```powershell
$vnet = New-AzVirtualNetwork -Name core-vnet -ResourceGroupName $netRg -Location $location `
  -AddressPrefix '10.10.0.0/16'
Add-AzVirtualNetworkSubnetConfig -Name web-subnet -VirtualNetwork $vnet -AddressPrefix '10.10.1.0/24'
$vnet | Set-AzVirtualNetwork
$nsg = New-AzNetworkSecurityGroup -Name web-nsg -ResourceGroupName $netRg -Location $location
Get-AzEffectiveNetworkSecurityGroup -NetworkInterfaceName $nicName -ResourceGroupName $netRg
```

### Validation, production notes, and exam tips

- Confirm HTTP succeeds with Allow 100, fails with Deny 90, and succeeds after removal.
- NSGs are stateful: response traffic for an allowed connection does not need a separate reverse rule.
- A subnet-level and NIC-level NSG must both allow traffic. One allow does not override a deny in the other.
- ASGs apply only to NIC IP configurations in the same VNet and simplify rules; they do not create network boundaries themselves.
- Five IPs in each subnet are reserved by Azure. Do the usable-address math quickly.
- Retain resources through Lab 12, or deallocate `web01` between sessions: `az vm deallocate -g "$NET_RG" -n web01`.

## Lab 11 — Peering, user-defined routes, Azure DNS, and connectivity diagnosis

**Time:** 120 minutes  
**Exam domain:** Configure/manage virtual networks; name resolution; troubleshooting

### Theory checkpoint

VNet peering is private, low-latency, nontransitive connectivity over the Microsoft backbone. Address spaces cannot overlap. Peering options control forwarded traffic, gateway transit, and remote-gateway use. Azure routes use longest-prefix match, then route-source precedence. A UDR can send traffic to a virtual appliance, virtual network gateway, Internet, or `None`.

Azure-provided DNS resolves platform names and same-VNet VM names with limitations. Azure Private DNS zones provide managed internal records and VNet links; registration links auto-register supported VM records. Public Azure DNS hosts authoritative zones but requires delegation at a registrar to serve an owned domain.

### Portal journey

1. In the Lab 10 group create `spoke-vnet` with `10.20.0.0/16` and `workload-subnet` `10.20.1.0/24`.
2. Open `core-vnet > Peerings > Add`, create both directions between core and spoke, allow virtual-network access, and leave gateway transit/forwarded traffic disabled initially.
3. Create a small private-only VM `app01` in the spoke. Use Run command or Bastion later; do not add a public IP.
4. Create route table `app-rt`; add route `block-test` for `10.99.0.0/16` with next hop **None** and associate it to `workload-subnet`.
5. Open the `app01` NIC **Effective routes**. Identify System, VNet peering, default Internet, and User routes.
6. Create Private DNS zone `internal.contoso.test`, link both VNets, and add A record `api` for `app01`'s private IP. Test resolution from `web01`.
7. Optional public-DNS practice: create a zone for a subdomain you own, compare Azure-assigned name servers, add an A record, and delegate it at your registrar. If you do not own a domain, create/delete the zone without claiming delegation works.
8. Use **Network Watcher > Connection troubleshoot** from `web01` to `app01` port 22/80 and inspect next hop, NSG, route, and DNS findings.

### Azure CLI implementation

```bash
export SPOKE_VNET="spoke-vnet"
az network vnet create -g "$NET_RG" -n "$SPOKE_VNET" -l "$LOCATION" \
  --address-prefixes 10.20.0.0/16 --subnet-name workload-subnet --subnet-prefixes 10.20.1.0/24
export CORE_ID="$(az network vnet show -g "$NET_RG" -n "$VNET" --query id -o tsv)"
export SPOKE_ID="$(az network vnet show -g "$NET_RG" -n "$SPOKE_VNET" --query id -o tsv)"
az network vnet peering create -g "$NET_RG" --vnet-name "$VNET" -n core-to-spoke \
  --remote-vnet "$SPOKE_ID" --allow-vnet-access
az network vnet peering create -g "$NET_RG" --vnet-name "$SPOKE_VNET" -n spoke-to-core \
  --remote-vnet "$CORE_ID" --allow-vnet-access
az network vnet peering list -g "$NET_RG" --vnet-name "$VNET" \
  --query '[].{name:name,state:peeringState,remote:remoteVirtualNetwork.id}' -o table

az vm create -g "$NET_RG" -n app01 --image Ubuntu2404 --size Standard_B1s \
  --vnet-name "$SPOKE_VNET" --subnet workload-subnet --public-ip-address '' \
  --admin-username azureadmin --generate-ssh-keys
export APP_IP="$(az vm list-ip-addresses -g "$NET_RG" -n app01 \
  --query '[0].virtualMachine.network.privateIpAddresses[0]' -o tsv)"

az network route-table create -g "$NET_RG" -n app-rt -l "$LOCATION"
az network route-table route create -g "$NET_RG" --route-table-name app-rt -n block-test \
  --address-prefix 10.99.0.0/16 --next-hop-type None
az network vnet subnet update -g "$NET_RG" --vnet-name "$SPOKE_VNET" -n workload-subnet \
  --route-table app-rt

az network private-dns zone create -g "$NET_RG" -n internal.contoso.test
az network private-dns link vnet create -g "$NET_RG" -z internal.contoso.test \
  -n core-link -v "$CORE_ID" -e false
az network private-dns link vnet create -g "$NET_RG" -z internal.contoso.test \
  -n spoke-link -v "$SPOKE_ID" -e false
az network private-dns record-set a create -g "$NET_RG" -z internal.contoso.test -n api
az network private-dns record-set a add-record -g "$NET_RG" -z internal.contoso.test \
  -n api -a "$APP_IP"

# Diagnose from the NIC and with Network Watcher.
export APP_NIC_ID="$(az vm show -g "$NET_RG" -n app01 --query 'networkProfile.networkInterfaces[0].id' -o tsv)"
export APP_NIC_NAME="${APP_NIC_ID##*/}"
az network nic show-effective-route-table -g "$NET_RG" -n "$APP_NIC_NAME" -o table
az network watcher test-ip-flow -g "$NET_RG" --vm app01 --direction Inbound \
  --protocol TCP --local 10.20.1.4:22 --remote 10.10.1.4:50000 -o jsonc
az network watcher show-next-hop -g "$NET_RG" --vm app01 \
  --source-ip "$APP_IP" --dest-ip 10.99.0.10 -o jsonc

# Optional public zone without delegation.
# az network dns zone create -g "$NET_RG" -n lab.example.com
# az network dns record-set a add-record -g "$NET_RG" -z lab.example.com -n www -a "$WEB_IP"
```

Adjust the IPs passed to `test-ip-flow` to the actual NIC addresses shown by `az vm list-ip-addresses`; do not assume `.4` if other resources were created first.

### PowerShell reference

```powershell
Add-AzVirtualNetworkPeering -Name core-to-spoke -VirtualNetwork $core -RemoteVirtualNetworkId $spoke.Id
$route = New-AzRouteConfig -Name block-test -AddressPrefix '10.99.0.0/16' -NextHopType None
New-AzRouteTable -Name app-rt -ResourceGroupName $netRg -Location $location -Route $route
New-AzPrivateDnsZone -Name 'internal.contoso.test' -ResourceGroupName $netRg
```

### Exam tips

- Peering is not transitive. A hub peered with two spokes does not automatically route spoke-to-spoke traffic.
- Gateway transit is enabled on the hub peering; **Use remote gateways** is enabled on the spoke, and a VNet can use only one remote gateway.
- Longest prefix wins. For equal prefixes, UDR generally takes precedence over BGP and system routes.
- VNet peering status should be `Connected` in both directions.
- Creating a public DNS zone does not register or delegate the domain; name-server records must be configured at the parent/registrar.

## Lab 12 — Bastion, service endpoints, private endpoints, and private DNS

**Time:** 120 minutes  
**Exam domain:** Configure secure access to virtual networks  
**Cost:** Bastion and private endpoints incur charges; delete immediately after validation

### Theory checkpoint

Azure Bastion provides managed RDP/SSH access to private VM IPs through the Portal/native client, avoiding VM public IPs. The dedicated subnet must be named `AzureBastionSubnet` and sized according to the SKU's current requirements. NSGs must preserve required Bastion flows.

Service endpoints extend a subnet identity to a PaaS public endpoint. Private endpoints place a service-specific NIC/private IP inside your VNet. DNS must resolve the service's normal FQDN to the private endpoint IP from private clients; manually connecting to the private IP is not the correct validation.

### Portal journey

1. Add subnet `AzureBastionSubnet` with at least `/26` to `core-vnet`.
2. Open **Bastions > Create**, select the VNet, use the lowest suitable production-supported SKU for the required features, and create a new Standard static public IP.
3. Remove `web01`'s direct SSH public access or use `app01` (private only). Open the VM **Connect > Bastion**, authenticate with the SSH private key, and verify a shell.
4. Create a new secure StorageV2 account and private Blob container.
5. First configure a `Microsoft.Storage` service endpoint on `workload-subnet`, add that VNet/subnet under the account firewall, and validate service-endpoint access from `app01`.
6. Then create a **Private endpoint** for the Blob subresource in `workload-subnet`. Integrate with private DNS zone `privatelink.blob.core.windows.net` and link it to both VNets.
7. From `app01`, resolve `<account>.blob.core.windows.net`; confirm it returns the private endpoint IP. Test HTTPS with correct hostname/SNI.
8. Disable public network access to the storage account and prove the authorized private path still works. Compare with an external denied path.
9. Delete Bastion and its public IP immediately if not needed for the next lab.

### Azure CLI implementation

```bash
# Bastion. Confirm the current supported SKU/subnet size in your region before creation.
az extension add --name bastion --upgrade --allow-preview true
az network vnet subnet create -g "$NET_RG" --vnet-name "$VNET" \
  -n AzureBastionSubnet --address-prefixes 10.10.254.0/26
az network public-ip create -g "$NET_RG" -n bastion-pip --sku Standard --allocation-method Static
az network bastion create -g "$NET_RG" -n lab-bastion -l "$LOCATION" \
  --vnet-name "$VNET" --public-ip-address bastion-pip --sku Basic

# Service endpoint on the client subnet.
az network vnet subnet update -g "$NET_RG" --vnet-name "$SPOKE_VNET" -n workload-subnet \
  --service-endpoints Microsoft.Storage
export PE_SA="az104pe${SUFFIX}"
az storage account create -g "$NET_RG" -n "$PE_SA" -l "$LOCATION" \
  --sku Standard_LRS --kind StorageV2 --https-only true --min-tls-version TLS1_2 \
  --allow-blob-public-access false
export PE_SA_ID="$(az storage account show -g "$NET_RG" -n "$PE_SA" --query id -o tsv)"
export CLIENT_SUBNET_ID="$(az network vnet subnet show -g "$NET_RG" --vnet-name "$SPOKE_VNET" \
  -n workload-subnet --query id -o tsv)"
az storage account network-rule add -g "$NET_RG" --account-name "$PE_SA" --subnet "$CLIENT_SUBNET_ID"
az storage account update -g "$NET_RG" -n "$PE_SA" --default-action Deny

# Private endpoint and DNS.
az network private-endpoint create -g "$NET_RG" -n blob-pe -l "$LOCATION" \
  --vnet-name "$SPOKE_VNET" --subnet workload-subnet \
  --private-connection-resource-id "$PE_SA_ID" \
  --group-id blob --connection-name blob-pe-connection
az network private-dns zone create -g "$NET_RG" -n privatelink.blob.core.windows.net
az network private-dns link vnet create -g "$NET_RG" -z privatelink.blob.core.windows.net \
  -n spoke-blob-dns -v "$SPOKE_ID" -e false
az network private-endpoint dns-zone-group create -g "$NET_RG" --endpoint-name blob-pe \
  -n blob-zone-group --private-dns-zone privatelink.blob.core.windows.net --zone-name blob

az network private-endpoint show -g "$NET_RG" -n blob-pe \
  --query '{state:privateLinkServiceConnections[0].privateLinkServiceConnectionState.status,nic:networkInterfaces[0].id}' -o yaml
az storage account update -g "$NET_RG" -n "$PE_SA" --public-network-access Disabled

# Run DNS test inside the private VM.
az vm run-command invoke -g "$NET_RG" -n app01 --command-id RunShellScript \
  --scripts "getent hosts ${PE_SA}.blob.core.windows.net && curl -I https://${PE_SA}.blob.core.windows.net"

# Cost-sensitive cleanup for Bastion only; retain the rest until group cleanup.
az network bastion delete -g "$NET_RG" -n lab-bastion
az network public-ip delete -g "$NET_RG" -n bastion-pip
```

### PowerShell reference

```powershell
New-AzBastion -ResourceGroupName $netRg -Name lab-bastion -PublicIpAddressRgName $netRg `
  -PublicIpAddressName bastion-pip -VirtualNetworkRgName $netRg -VirtualNetworkName core-vnet
New-AzPrivateEndpoint -Name blob-pe -ResourceGroupName $netRg -Location $location `
  -Subnet $subnet -PrivateLinkServiceConnection $connection
```

### Exam tips

- Bastion secures the access path but does not replace VM authentication, RBAC, NSGs, patching, or endpoint protection.
- Private endpoints are per subresource. Blob private access does not automatically privatize Files.
- Correct private DNS is essential; clients normally use the original service hostname.
- Service endpoints and private endpoints solve related but different requirements. A service endpoint does not remove the public endpoint.

## Lab 13 — Standard Load Balancer, health probes, rules, and troubleshooting

**Time:** 120 minutes  
**Exam domain:** Configure name resolution and load balancing  
**Cost:** two small VMs, public IP, load balancer; optional Application Gateway costs more

### Theory checkpoint

Azure Load Balancer is regional layer 4 (TCP/UDP). A frontend IP, backend pool, health probe, and load-balancing rule work together. Standard Load Balancer is secure by default, so NSGs must allow client traffic and AzureLoadBalancer health probes. Health-probe failure removes a backend from new flows. Load distribution is hash based, not simple round-robin, and session persistence choices modify the hash.

Application Gateway is layer 7 HTTP(S), supports host/path routing, TLS termination, cookie affinity, autoscaling, and optional WAF. It remains useful course knowledge even though the April 2026 objective explicitly names internal/public Load Balancer rather than Application Gateway.

### Portal journey

1. Create subnet `lb-subnet` (`10.10.3.0/24`) in `core-vnet` and NSG allowing HTTP 80 from Internet plus probe traffic from service tag `AzureLoadBalancer`.
2. Create two private-only Ubuntu VMs `lbvm1` and `lbvm2` in an availability set or different zones where available. Install nginx and put each hostname on its page.
3. Create **Load balancers > Standard, Public** with a Standard static frontend public IP.
4. Create backend pool and add both NIC IP configurations.
5. Create HTTP health probe on port 80 path `/`, then a TCP load-balancing rule frontend 80 to backend 80 with the probe.
6. Repeatedly request the frontend. Record both backends over multiple new connections.
7. Stop nginx on one VM. Observe probe health and that new flows use the healthy backend. Restart nginx.
8. Troubleshoot a deliberate failure: wrong probe port, missing NSG probe rule, or backend NIC absent. Use backend health, NSG effective rules, and Network Watcher.
9. Optional: build a small Application Gateway in its own subnet, route `/images/*` and default traffic to different pools, inspect backend health, then delete it immediately.

### Azure CLI implementation

```bash
az network vnet subnet create -g "$NET_RG" --vnet-name "$VNET" -n lb-subnet \
  --address-prefixes 10.10.3.0/24
az network nsg create -g "$NET_RG" -n lb-nsg -l "$LOCATION"
az network nsg rule create -g "$NET_RG" --nsg-name lb-nsg -n Allow-HTTP \
  --priority 100 --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes Internet --destination-port-ranges 80
az network nsg rule create -g "$NET_RG" --nsg-name lb-nsg -n Allow-LB-Probe \
  --priority 110 --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes AzureLoadBalancer --destination-port-ranges 80
az network vnet subnet update -g "$NET_RG" --vnet-name "$VNET" -n lb-subnet --network-security-group lb-nsg

az network public-ip create -g "$NET_RG" -n lb-pip --sku Standard --allocation-method Static
az network lb create -g "$NET_RG" -n web-lb --sku Standard \
  --public-ip-address lb-pip --frontend-ip-name frontend --backend-pool-name web-pool

for vm in lbvm1 lbvm2; do
  az vm create -g "$NET_RG" -n "$vm" --image Ubuntu2404 --size Standard_B1s \
    --vnet-name "$VNET" --subnet lb-subnet --public-ip-address '' \
    --admin-username azureadmin --generate-ssh-keys
  az vm run-command invoke -g "$NET_RG" -n "$vm" --command-id RunShellScript \
    --scripts "sudo apt-get update && sudo apt-get install -y nginx && echo ${vm} | sudo tee /var/www/html/index.html"
  nic_id="$(az vm show -g "$NET_RG" -n "$vm" --query 'networkProfile.networkInterfaces[0].id' -o tsv)"
  nic_name="${nic_id##*/}"
  ipconfig="$(az network nic show -g "$NET_RG" -n "$nic_name" --query 'ipConfigurations[0].name' -o tsv)"
  az network nic ip-config address-pool add -g "$NET_RG" --nic-name "$nic_name" \
    --ip-config-name "$ipconfig" --lb-name web-lb --address-pool web-pool
done

az network lb probe create -g "$NET_RG" --lb-name web-lb -n http-probe \
  --protocol Http --port 80 --path / --interval 5 --probe-threshold 2
az network lb rule create -g "$NET_RG" --lb-name web-lb -n http-rule \
  --protocol Tcp --frontend-port 80 --backend-port 80 \
  --frontend-ip-name frontend --backend-pool-name web-pool --probe-name http-probe \
  --idle-timeout 4 --enable-tcp-reset true

export LB_IP="$(az network public-ip show -g "$NET_RG" -n lb-pip --query ipAddress -o tsv)"
for i in 1 2 3 4 5 6; do curl -fsS -H 'Connection: close' "http://${LB_IP}"; done

# Deliberate health change and recovery.
az vm run-command invoke -g "$NET_RG" -n lbvm1 --command-id RunShellScript --scripts 'sudo systemctl stop nginx'
az vm run-command invoke -g "$NET_RG" -n lbvm1 --command-id RunShellScript --scripts 'sudo systemctl start nginx'
az network lb show -g "$NET_RG" -n web-lb -o jsonc
```

### PowerShell reference

```powershell
$frontend = New-AzLoadBalancerFrontendIpConfig -Name frontend -PublicIpAddress $pip
$backend = New-AzLoadBalancerBackendAddressPoolConfig -Name web-pool
$probe = New-AzLoadBalancerProbeConfig -Name http-probe -Protocol Http -Port 80 -RequestPath '/' `
  -IntervalInSeconds 5 -ProbeCount 2
$rule = New-AzLoadBalancerRuleConfig -Name http-rule -Protocol Tcp -FrontendPort 80 -BackendPort 80 `
  -FrontendIpConfiguration $frontend -BackendAddressPool $backend -Probe $probe
New-AzLoadBalancer -Name web-lb -ResourceGroupName $netRg -Location $location `
  -FrontendIpConfiguration $frontend -BackendAddressPool $backend -Probe $probe -LoadBalancingRule $rule -Sku Standard
```

### Validation, production notes, and exam tips

- Validate the frontend, backend membership, health probe, rule, NSGs, guest firewall, and application listener in that order.
- A healthy TCP probe proves a port accepts connections, not that an HTTP application returns correct content; use HTTP/HTTPS probes when application-level health matters.
- Standard Load Balancer backend outbound access is explicit; design a NAT Gateway or outbound rule as required.
- Use zone-redundant frontends/backends where supported and align health probes with dependency readiness.

### Cleanup

List every resource in `$NET_RG`, confirm it is a lab group, then delete it. This removes running VMs, public IPs, load balancer, private endpoint, and DNS zones:

```bash
az resource list -g "$NET_RG" -o table
az group delete -n "$NET_RG" --yes --no-wait
```

## Module checkpoint

Take the [virtual networking checkpoint](../assessments/module-03-networking.md) closed-book. For each miss, draw the packet path and prove the route, DNS answer, NSG decision, and listener health with Portal and CLI evidence.
