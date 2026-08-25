# Module 03 checkpoint v2: virtual networking — trap edition

**Time:** 25 minutes  
**Target:** 12/15  
**Answer book:** [Open only after finishing](answers/module-03-networking-v2-answers.md)

> Every question in this set uses deliberate wording traps found in the real AZ-104 exam.
> Read each scenario constraint carefully before selecting an answer.

1. An NSG attached to a subnet has two inbound rules:
   `Allow-HTTPS` on TCP 443 at priority **300** and
   `Deny-All-Inbound` at priority **100**.
   An internet client sends a TCP 443 packet. What is the result?

   - A. The packet is allowed because the specific allow rule for TCP 443 wins.
   - B. The packet is denied because priority 100 evaluates first regardless of specificity.
   - C. Both rules are merged and the packet is forwarded to the backend.
   - D. The NIC-level NSG overrides the subnet-level result.

2. Spoke1 and Spoke2 are each peered with Hub. Both peering connections show **Connected** status in the Portal. A VM in Spoke1 cannot reach a VM in Spoke2. What is the most accurate explanation?

   - A. The VNets must use overlapping address spaces for inter-spoke traffic.
   - B. Connected status means traffic flows freely between all peered VNets.
   - C. VNet peering is nontransitive; spoke-to-spoke traffic does not flow through Hub without explicit routing or forwarding.
   - D. Private DNS zones must be linked before peering carries traffic.

3. A private DNS zone `privatelink.blob.core.windows.net` is linked to Spoke1. Spoke2 is peered with Spoke1. A VM in Spoke2 queries the blob FQDN. What is the expected result?

   - A. Spoke2 resolves the private IP because peering shares DNS zone links automatically.
   - B. Spoke2 resolves the private IP because peering extends VNet DNS scope.
   - C. Spoke2 returns the public IP or NXDOMAIN because the DNS zone is linked only to Spoke1.
   - D. Spoke2 always uses Azure default DNS regardless of private zones.

4. A subnet needs to reach a Storage account's **public endpoint** while the storage firewall default action is **Deny**. No private endpoint exists. Which two components are required? **Choose two.**

   - A. A private endpoint NIC in the subnet
   - B. A `Microsoft.Storage` service endpoint on the subnet
   - C. A virtual-network rule in the storage firewall allowing the subnet
   - D. A public IP on every VM in the subnet
   - E. VNet peering to the storage region

5. A private endpoint is created for a Blob storage account, and the connection is approved. A VM in the same VNet still resolves the blob FQDN to the **public IP**. What is the most likely missing component?

   - A. The private endpoint NIC needs a larger private IP.
   - B. The storage firewall default action must be Allow.
   - C. The `privatelink.blob.core.windows.net` private DNS zone is not linked to the VNet, or the A record is missing.
   - D. NSG rules must explicitly allow port 443 to the private IP.

6. A UDR on a subnet contains two routes:
   - `10.20.0.0/16 → VirtualAppliance 10.1.0.4`
   - `0.0.0.0/0 → Internet`

   A packet is sent to `10.20.5.8`. Which next hop does Azure select?

   - A. Internet, because `0.0.0.0/0` is always the fallback for any destination.
   - B. No route matches because UDRs cannot override system routes.
   - C. VirtualAppliance `10.1.0.4`, because the longest-prefix match selects `/16` over `/0`.
   - D. VNet default because user-defined routes are advisory only.

7. A VM is sending traffic to an NVA. The NVA's effective route shows the correct next hop and packets arrive at the NVA NIC. Traffic does not exit the NVA. What setting is most likely missing?

   - A. NSG allow rule from the NVA to the Internet.
   - B. IP forwarding enabled on the NVA NIC in Azure.
   - C. A peering connection between the NVA and destination VNet.
   - D. A public IP attached to the NVA.

8. A Standard Load Balancer health probe is configured on TCP port **80**. The backend application listens on port **8080**. The NSG allows traffic from `Internet` service tag on port 8080. What is the backend health status?

   - A. Healthy — the NSG allows the application port.
   - B. Unhealthy — the probe targets port 80, which is not the listening application port. The `AzureLoadBalancer` service tag may also need to be explicitly allowed where the NSG blocks it.
   - C. Healthy — Azure Load Balancer translates probe ports automatically.
   - D. Healthy — NSG rules do not apply to health probes.

9. Two VMs are in different VNets connected by peering. DNS name resolution works from VNet1. A VM in VNet2 cannot resolve the same private DNS name. The private DNS zone is linked only to VNet1. What must you do?

   - A. Delete and recreate the peering connection.
   - B. Enable DNS forwarding on the peering itself.
   - C. Link the private DNS zone to VNet2 or configure a DNS resolver that VNet2 VMs can reach.
   - D. Assign a public IP to the DNS zone.

10. You need to allow SSH to a VM only from your corporate IP `203.0.113.10/32` and block all other inbound traffic on port 22. An existing default rule `AllowVnetInBound` at priority 65000 exists. What is the minimum addition?

    - A. An allow rule for `203.0.113.10/32` on TCP 22 at any priority below 65000, and a deny rule for `Any` on TCP 22 at a priority higher (larger number) than the allow rule.
    - B. An allow rule for `203.0.113.10/32` on TCP 22 at priority 65001, above the default rules.
    - C. An allow rule for `203.0.113.10/32` on TCP 22 at a priority below 65000. The `DenyAllInBound` default at 65500 already blocks all other sources.
    - D. No change needed — `AllowVnetInBound` blocks internet traffic automatically.

11. Azure Bastion is deployed in a hub VNet. A VM with no public IP is in a spoke VNet peered with the hub. An administrator tries to RDP through Bastion. The connection fails. Which configuration is most likely missing?

    - A. The spoke VM needs a public IP for Bastion to forward traffic.
    - B. The Bastion subnet requires an NSG allowing inbound from the Internet on ports 443 and 8080.
    - C. The peering must have **Allow gateway transit** or **Use remote gateways** configured, and/or the spoke NSG must permit the Bastion subnet range on RDP/SSH.
    - D. The spoke must have its own Bastion resource.

12. A virtual appliance NIC has IP forwarding enabled in Azure. The guest OS is Linux. Packets reach the NIC but the OS drops them. What is missing?

    - A. A second private IP on the NIC.
    - B. IP forwarding or packet forwarding enabled within the Linux guest OS (e.g., `net.ipv4.ip_forward=1`).
    - C. An NSG on the NVA subnet.
    - D. A dedicated public IP for the NVA.

13. **Choose two.** Which statements about Azure VNet peering are correct?

    - A. Address spaces of peered VNets must not overlap.
    - B. Peering is transitive — traffic flows freely through chained peered VNets.
    - C. Each direction of a peering (A→B and B→A) can have independently configured properties such as gateway transit.
    - D. Peering merges the two VNets into a single resource.
    - E. Peering is global and can connect VNets in different regions.

14. A `connection refused` error occurs when a client accesses a VM on TCP 443. The effective NSG rules show TCP 443 is allowed inbound. What should you check next?

    - A. The storage account key.
    - B. The VNet address space overlap.
    - C. Whether the application inside the VM is actually listening on TCP 443, and whether the guest OS firewall permits the port.
    - D. Whether blob versioning is enabled.

15. A private endpoint exists for an Azure SQL database. Its private DNS zone is correctly linked and the A record resolves to a private IP. Connections from a VM in the VNet still fail. What should you investigate?

    - A. Whether the private endpoint connection is in **Approved** state (not Pending or Rejected).
    - B. Whether blob soft delete is enabled.
    - C. Whether the VNet has a public IP prefix.
    - D. Whether the storage account key has been rotated.
