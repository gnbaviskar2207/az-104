# Module 03 checkpoint: virtual networking

**Time:** 25 minutes  
**Target:** 12/15  
**Answer book:** [Open only after finishing](answers/module-03-networking-answers.md)

1. Two VNets have nonoverlapping address spaces and need private IP connectivity over the Microsoft backbone. What should you configure?
   - A. Azure DNS public zone
   - B. Blob lifecycle policy
   - C. Recovery Services vault
   - D. VNet peering

2. Is VNet peering transitive by default?
   - A. Only when NSGs are absent
   - B. Yes, across every peered VNet
   - C. No; hub routing requires an explicit design such as an NVA/gateway and routes
   - D. Only for Basic public IPs

3. A subnet sends `0.0.0.0/0` to a firewall appliance. Which resource defines that next hop?
   - A. Application security group
   - B. Private DNS zone
   - C. Availability set
   - D. User-defined route in a route table associated with the subnet

4. An NSG has an inbound Allow TCP 443 rule at priority 200 and a DenyAny rule at priority 300. What happens to TCP 443 traffic that matches both?
   - A. It alternates between rules.
   - B. It is allowed because lower priority numbers are processed first.
   - C. It is denied because Deny always wins regardless of priority.
   - D. Both rules are ignored.

5. Why use an application security group?
   - A. To provide DNS recursion
   - B. To store VM disks
   - C. To create a public load balancer
   - D. To group NICs logically for NSG rules without maintaining IP lists

6. Which view combines applicable subnet and NIC NSG rules for a VM interface?
   - A. Access reviews
   - B. Effective security rules
   - C. Cost analysis
   - D. Deployment history

7. Azure Bastion primarily provides which capability?
   - A. Layer 7 web application firewall
   - B. Blob replication
   - C. Entra license assignment
   - D. Browser-based RDP/SSH to VMs without requiring a public IP on each VM

8. **Choose two.** Which resources are required for a typical private endpoint DNS design for Blob Storage?
   - A. A Basic Load Balancer
   - B. A Recovery Services vault
   - C. A private endpoint for the blob subresource
   - D. A private DNS zone linked to the client VNet
   - E. An Azure DNS public zone only

9. A public Standard Load Balancer marks both backends unhealthy. What should you verify first?
   - A. Storage lifecycle policy
   - B. Entra group type
   - C. Subscription budget
   - D. Health probe path/port, NSG allowance, guest firewall, and application listener

10. Which load-balancer component maps a frontend IP and port to a backend pool and port?
    - A. DNS TXT record
    - B. Route Server
    - C. Load-balancing rule
    - D. Health probe only

11. You want `app.contoso.com` to resolve publicly to an IPv4 address. Which DNS record type is appropriate?
    - A. PTR in the forward zone
    - B. A
    - C. CNAME only to an IP literal
    - D. MX

12. Which Network Watcher tool tests whether a proposed packet is allowed or denied by NSG rules?
    - A. IP flow verify
    - B. Azure Advisor
    - C. Change Analysis
    - D. Service Health

13. A VM cannot reach a destination. Which two datasets are most helpful for diagnosing routing and filtering?
    - A. Tags and budgets
    - B. Blob versions and snapshots
    - C. App Service slots and backups
    - D. Effective routes and effective security rules

14. What does a public IP resource provide to a load balancer or NIC?
    - A. A Kubernetes service account
    - B. A storage data role
    - C. An Azure-managed public address with SKU/allocation/zone properties
    - D. A private DNS zone link

15. Two subnet address prefixes overlap. Can both be created in the same VNet?
    - A. Only with ZRS.
    - B. Yes, if their names differ.
    - C. No, subnets within a VNet cannot overlap.
    - D. Yes, with an NSG.
