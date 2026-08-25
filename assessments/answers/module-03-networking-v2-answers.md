# Module 03 networking v2 — answer book

Open this only after completing the checkpoint with the timer running.

---

**1. B — The packet is denied because priority 100 evaluates first regardless of specificity.**

NSG rules are evaluated in ascending priority order (lowest number first). Priority 100 (`Deny-All-Inbound`) evaluates before priority 300 (`Allow-HTTPS`). The first matching rule wins. Unlike firewall ACLs in other products, Azure NSGs do **not** apply a "most specific match" rule — they apply the first match by priority number. Fix: move the allow rule to a lower number, e.g., priority 200, so it evaluates before the deny.

*Trap:* Many learners assume that a specific service rule (TCP 443 only) always overrides a broad deny. In Azure NSGs, priority number determines evaluation order exclusively.

---

**2. C — VNet peering is nontransitive; spoke-to-spoke traffic does not flow through Hub without explicit routing or forwarding.**

VNet peering is always a direct, non-transitive relationship. Even if Spoke1→Hub and Spoke2→Hub are both Connected, packets from Spoke1 to Spoke2 do not transit Hub automatically. Options: add direct Spoke1↔Spoke2 peering, or route through an NVA/Azure Firewall in Hub with UDRs on both spokes.

*Trap:* The Portal shows `Connected` for each individual peering, which candidates incorrectly interpret as end-to-end reachability.

---

**3. C — Spoke2 returns the public IP or NXDOMAIN because the DNS zone is linked only to Spoke1.**

Private DNS zone links are explicit per VNet. Peering provides network connectivity, not DNS zone visibility. Spoke2 VMs query Azure DNS (168.63.129.16), which returns the public endpoint unless the private DNS zone is also linked to Spoke2 or a DNS forwarder/resolver is in place.

*Trap:* Candidates assume that peering propagates DNS configuration. It does not.

---

**4. B and C — A `Microsoft.Storage` service endpoint on the subnet, and a virtual-network rule in the storage firewall allowing the subnet.**

A service endpoint routes subnet traffic to the Azure Storage backbone over the public endpoint IP — but the storage firewall also needs a VNet rule explicitly allowing that subnet. Both components are required. A private endpoint is not involved in this scenario. Public IPs on VMs are irrelevant.

---

**5. C — The `privatelink.blob.core.windows.net` private DNS zone is not linked to the VNet, or the A record is missing.**

A private endpoint only delivers private IP resolution if the DNS infrastructure is configured correctly. The NIC exists and the connection is approved (checked by the question), but DNS is the common missing piece. Without a linked private DNS zone (or equivalent resolver entry), the client's DNS query returns the public CNAME chain and public IP.

*Trap:* Candidates focus on the private endpoint NIC and connection state, not DNS.

---

**6. C — VirtualAppliance `10.1.0.4`, because the longest-prefix match selects `/16` over `/0`.**

Azure routing (like IP routing universally) uses longest-prefix match. `/16` is more specific than `/0` for the destination `10.20.5.8`, which falls within `10.20.0.0/16`. The packet goes to the NVA.

*Trap:* Option A is a common wrong answer because `0.0.0.0/0` is described as a "default" route, leading candidates to think it applies "by default" for all traffic.

---

**7. B — IP forwarding enabled on the NVA NIC in Azure.**

Azure drops packets where the destination IP does not match the NIC's assigned IP, unless IP forwarding is explicitly enabled on that NIC. This is the Azure platform-level setting. A separate guest OS IP forwarding setting (Q12) is also needed but that is the OS layer — this question confirms packets arrive at the NIC, pointing to the Azure setting.

---

**8. B — Unhealthy — the probe targets port 80, which is not the listening port. The `AzureLoadBalancer` service tag may also need to be explicitly allowed.**

The health probe must match the actual application port (8080). Azure Load Balancer health probes originate from a well-known IP (`168.63.129.16`), mapped to the `AzureLoadBalancer` service tag. NSGs must allow this tag inbound for probes to succeed, in addition to the application port.

*Trap:* Candidates assume the application's `Internet` allow rule covers probes. It does not cover the probe source IP correctly unless `AzureLoadBalancer` is also permitted.

---

**9. C — Link the private DNS zone to VNet2 or configure a DNS resolver that VNet2 VMs can reach.**

DNS zone links are per VNet. Peering shares network connectivity, not DNS zone visibility. The minimum fix is to add a VNet link from the private DNS zone to VNet2. Alternatively, configure Azure DNS Private Resolver or a forwarding rule set for cross-VNet resolution.

---

**10. C — An allow rule for `203.0.113.10/32` on TCP 22 at a priority below 65000. The `DenyAllInBound` default at 65500 already blocks all other sources.**

The `DenyAllInBound` default rule at priority 65500 blocks everything not explicitly allowed. You need only one new rule: allow the corporate IP on TCP 22 at any priority lower than 65500 (e.g., 1000). No explicit deny for other sources is needed because the default deny already covers them.

*Trap:* Option A adds an unnecessary explicit deny rule. Option B places the allow at 65001, which is still below the default deny (65500) and technically works, but option C explains the correct reasoning.

---

**11. C — The peering must have the correct settings, and/or the spoke NSG must permit the Bastion subnet range on RDP/SSH.**

For Bastion in a hub to reach VMs in a spoke: (1) the peering must allow traffic forwarding, (2) the spoke NSG must permit inbound traffic from the `AzureBastionSubnet` address range on port 3389/22. The spoke VM does not need a public IP — that is the point of Bastion.

*Trap:* Option A is the opposite of Bastion's purpose. Option D (deploy Bastion in each spoke) is not required when hub-spoke peering is configured correctly.

---

**12. B — IP forwarding or packet forwarding enabled within the Linux guest OS.**

Azure NIC IP forwarding allows Azure to pass packets with a foreign destination IP to the NIC. However, the guest OS must also be configured to forward those packets (e.g., `net.ipv4.ip_forward = 1` in `/etc/sysctl.conf`). Both layers are required. This question specifies packets arrive at the NIC, so the Azure NIC setting is already correct — the OS layer is missing.

---

**13. A and C — Address spaces must not overlap; each direction of a peering can have independently configured properties.**

Correct statements: (A) overlapping address spaces prevent peering. (C) each peering link (A→B and B→A) has independently configurable properties such as `AllowGatewayTransit` and `UseRemoteGateways`.

Wrong: (B) peering is nontransitive. (D) peering does not merge VNets. (E) is true (global peering exists) but is not listed as a correct choice — (A) and (C) are the target correct pair.

---

**14. C — Whether the application inside the VM is actually listening on TCP 443, and whether the guest OS firewall permits the port.**

`Connection refused` with an NSG Allow means the packet reached the VM. The OS or application is rejecting it. Check: `ss -tlnp | grep 443` or `netstat -an`; check `ufw`, `iptables`, or Windows Firewall. The NSG is not the culprit here.

*Trap:* Candidates re-check NSG rules when they already confirmed Allow. The next diagnostic step is always the guest layer.

---

**15. A — Whether the private endpoint connection is in Approved state.**

A private endpoint with DNS correctly configured and a resolved private IP can still fail if the connection request has not been approved (or was rejected). The connection state must be `Approved` for traffic to flow. This is checked in the Private Endpoint resource → Connection tab or the target resource's Private endpoint connections blade.
