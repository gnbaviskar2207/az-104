# Module 03 answers

1. **D.** Peering provides low-latency private VNet connectivity over Azure's backbone when address spaces do not overlap.
2. **C.** Peering is nontransitive. Hub-and-spoke transit needs explicit forwarding, route, gateway, or NVA design.
3. **D.** A route table with a UDR can direct a prefix to a virtual appliance next hop.
4. **B.** NSG custom rules evaluate ascending priority number; first match wins. Default rules follow custom rules.
5. **D.** ASGs give application-role labels to NIC configurations and simplify NSG source/destination rules.
6. **B.** Effective security rules aggregate NIC/subnet NSGs. Effective routes similarly aggregate system, BGP, and user routes.
7. **D.** Bastion supplies managed RDP/SSH access through the Portal/client while VMs can remain without public IPs.
8. **C and B.** The endpoint supplies the private NIC/IP; the linked private zone makes the service FQDN resolve to it.
9. **D.** Work from probe configuration through network controls to the guest listener. Unhealthy backends receive no new flows.
10. **C.** A rule binds frontend/protocol/port to the pool and backend port and references a probe.
11. **B.** An A record maps a name to IPv4. CNAME maps a name to another hostname, not an IP literal.
12. **A.** IP flow verify evaluates an example five-tuple against NSG rules and reports Allow/Deny plus the matched rule.
13. **D.** Routing chooses the next hop; security rules permit or deny the flow. Both must support the connection.
14. **C.** Public IP is a first-class resource whose allocation, SKU, tier, and zone behavior affect attached frontends.
15. **C.** Subnet prefixes in one VNet cannot overlap, and peered VNet address spaces must also be nonoverlapping.

Remediate misses in [virtual networking](../../guide/03-networking.md), Labs 9–13.
