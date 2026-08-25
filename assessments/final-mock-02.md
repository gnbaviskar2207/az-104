# AZ-104 Final Mock Exam 2

<!-- markdownlint-disable MD029 -->

**Questions:** 50  
**Time:** 100 minutes  
**Readiness target:** 40/50 overall and at least 70% in every domain  
**Answer book:** [Open only after submitting all answers](answers/final-mock-02-answers.md)

Unless the question says **Choose two**, select one answer.

## Case study: Contoso operations

Contoso has one tenant, a production subscription, and a sandbox subscription under the same management group. Production resources require `environment=production`. A two-tier application uses an App Service frontend, two VMs, and a Storage account. Administrators need private Storage access, centralized logs, recoverability, and least-privilege operations.

1. Which control should enforce the required production tag on new resources and remediate supported existing resources?
   - A. Reader role assignment
   - B. DNS CNAME
   - C. VM backup policy
   - D. Azure Policy assignment using an appropriate modify effect and remediation

2. The VMs must resolve the Blob service to a private IP. Which two resources are central to this design? **Choose two.**
   - A. Route to Internet next hop
   - B. Blob private endpoint
   - C. Linked `privatelink.blob.core.windows.net` private DNS zone
   - D. Public DNS A record only
   - E. Basic public IP

3. The application must upload blobs without secrets. What should Contoso configure?
   - A. Account key in source control
   - B. Anonymous container write access
   - C. Reader on the resource group
   - D. Managed identity plus Storage Blob Data Contributor at the required scope

4. A release must be smoke-tested and then promoted with minimal interruption. Which App Service feature should be used?
   - A. Resource lock
   - B. Deployment slot
   - C. Azure Files snapshot
   - D. Availability set

5. Which configuration sends selected App Service platform logs to the central workspace?
   - A. Network security group
   - B. Storage lifecycle rule
   - C. Management-group RBAC
   - D. Diagnostic setting targeting Log Analytics

## Standalone questions

6. The sandbox subscription must inherit an allowed-locations policy. Where should it be assigned for both current and future child subscriptions?
   - A. Availability zone
   - B. Parent management group
   - C. One sandbox resource
   - D. Entra user object

7. A user delegation SAS is preferred over an account-key SAS primarily because it is authorized with what?
   - A. A VM temporary disk
   - B. DNSSEC
   - C. An NSG default rule
   - D. Microsoft Entra credentials and delegated permissions

8. You run:

   ```bash
   az deployment group what-if -g rg-app -f main.bicep
   ```

   What is the intended result?
   - A. Reimage every VM
   - B. Preview proposed deployment changes
   - C. Delete the resource group
   - D. Export Activity Logs

9. A route table has `10.20.0.0/16 → VirtualAppliance 10.1.0.4` and `0.0.0.0/0 → Internet`. Traffic to `10.20.5.8` uses which next hop?
   - A. Internet, because `/0` has broader scope
   - B. None, because UDRs cannot use private prefixes
   - C. VNet peering automatically
   - D. Virtual appliance, because longest-prefix match selects `/16`

10. A user is Contributor on a resource group and User Access Administrator on one VM. What can the user do on that VM?
    - A. Manage access across the tenant
    - B. Bypass Azure Policy
    - C. Manage the VM and manage its access assignments, subject to denies/conditions
    - D. View only

11. A Linux VM is stopped from inside the guest, but Azure still shows `Stopped` rather than `Stopped (deallocated)`. What cost behavior is expected?
    - A. Backup retention stops automatically.
    - B. Compute allocation may continue to be billed until deallocated in Azure.
    - C. All disks are immediately deleted.
    - D. The VM becomes free permanently.

12. An NSG is associated with both a subnet and a NIC. For inbound traffic, what must be true?
    - A. The traffic must be allowed by both applicable NSG evaluations.
    - B. Only the NIC NSG is evaluated.
    - C. Only the subnet NSG is evaluated.
    - D. The rules are ignored when peering exists.

13. You need guest OS performance counters and logs from VMs. Which modern collection design should you configure?
    - A. Resource lock and DNS zone
    - B. SAS and blob versioning
    - C. VNet peering only
    - D. Azure Monitor Agent with data collection rules and a Log Analytics destination

14. An account requires secondary-region read access before Microsoft initiates a failover. Which redundancy option supports it?
    - A. ZRS only
    - B. Premium LRS only
    - C. RA-GRS or RA-GZRS, as requirements permit
    - D. LRS

15. Which statement best describes an Azure Policy initiative?
    - A. A storage transfer tool
    - B. A collection of policy definitions managed and assigned together
    - C. A collection of RBAC users
    - D. A VM availability construct

16. A Windows VM must move to another resource group in the same subscription. What should you do before the move?
    - A. Validate move support and include dependent resources that must move together.
    - B. Convert the VM to a guest user.
    - C. Delete all managed disks.
    - D. Enable anonymous access.

17. A backend receives no new load-balanced connections after failing its probe. Existing flows may behave according to configuration. What is the probe's primary purpose?
    - A. Encrypt the frontend certificate
    - B. Create DNS records
    - C. Assign RBAC roles
    - D. Determine whether a backend should receive new flows

18. Which lock can unexpectedly prevent monitoring agents or services from updating resource settings because it allows only read operations?
    - A. No lock
    - B. DeleteOnly
    - C. ReadOnly
    - D. CanNotDelete

19. A lifecycle rule deletes previous blob versions after 30 days. What must you account for?
    - A. It changes the VNet address space.
    - B. Recovery of older versions will no longer be possible after deletion.
    - C. The rule automatically creates an ASR replica.
    - D. It rotates storage keys.

20. ACR image pulls from an Azure compute service should avoid registry admin credentials. What is preferred?
    - A. Managed identity/service identity with the appropriate ACR pull role
    - B. Publicly expose the registry
    - C. Store admin password in the image
    - D. Assign DNS Zone Contributor

21. Which public Load Balancer configuration distributes TCP 443 to backend TCP 8443?
    - A. Health probe alone
    - B. Inbound NAT rule for every client as the only component
    - C. A DNS TXT record
    - D. A load-balancing rule mapping frontend 443 to backend 8443

22. A backup job failed overnight. Which combination provides actionable operations response?
    - A. A public endpoint only
    - B. A ReadOnly lock only
    - C. Vault/Backup Center job status, Azure Monitor alerts, and an action group
    - D. VM tags only

23. Which identity is automatically tied to one Azure resource's lifecycle and cannot be shared independently?
    - A. Dynamic group
    - B. System-assigned managed identity
    - C. User-assigned managed identity
    - D. External guest

24. A VM must use a larger size, but the desired size is not listed while running. What should you try after validating regional/quota support?
    - A. Deallocate, resize, and start the VM
    - B. Delete the OS disk
    - C. Recreate the tenant
    - D. Add a DNS TXT record

25. An Azure Files share is mounted from on-premises and TCP 445 is blocked by the ISP. Which fact matters?
    - A. Blob versioning opens TCP 445.
    - B. ZRS bypasses all network controls.
    - C. A SAS changes the ISP firewall.
    - D. Direct SMB needs TCP 445; a VPN/ExpressRoute or other supported access design may be required.

26. A private endpoint exists for `blob`, but Azure Files remains public. Why?
    - A. Azure Files cannot use private endpoints.
    - B. Peering disables Azure Files.
    - C. Private endpoints target specific storage subresources; `file` needs its own endpoint/DNS configuration.
    - D. One private endpoint always covers all services.

27. A team should manage VMs but never assign RBAC roles. Why is Contributor safer than Owner at the same scope?
    - A. Owner cannot change resources.
    - B. Contributor excludes role-assignment management actions.
    - C. Contributor is data-plane read-only.
    - D. Contributor bypasses locks.

28. Which sequence is safest for an App Service slot release?
    - A. Deploy to staging → validate → verify sticky settings → swap → monitor
    - B. Delete production → deploy staging → disable TLS
    - C. Swap → deploy → validate DNS
    - D. Remove backup → swap → add public access

29. ASR has failed over a VM and the failover is committed. What prepares for eventual failback?
    - A. Test failover cleanup only
    - B. Delete the recovery point
    - C. Add a tag
    - D. Reprotect to establish replication in the reverse direction

30. You must copy several terabytes into Azure Blob Storage with restartable parallel transfers. Which tool is the best fit?
    - A. IP flow verify
    - B. Policy remediation
    - C. AzCopy
    - D. Azure Advisor

31. A resource has Reader inherited from the subscription and Contributor directly at the resource. Which effective allow capability applies there?
    - A. Owner
    - B. Contributor, with inherited Reader also present
    - C. Reader only because inheritance always wins
    - D. No access because the roles conflict

32. A VM cannot reach an internet destination. Effective routes show `0.0.0.0/0 → VirtualAppliance`, but the appliance is unavailable. What is the immediate cause?
    - A. The selected default route sends traffic to the unavailable appliance.
    - B. DNS always overrides routes.
    - C. The VM needs blob versioning.
    - D. The subnet prefix is too specific.

33. A service needs containerized HTTP workloads, revisions, secrets, and scale-to-zero without Kubernetes control-plane administration. Choose the service.
    - A. Azure Container Registry only
    - B. Azure Files
    - C. Azure Bastion
    - D. Azure Container Apps

34. A subscription owner cannot delete a locked resource. Why?
    - A. Locks are NSG rules.
    - B. The resource is automatically backed up.
    - C. Locks apply to authorized users and require removal with appropriate lock permissions before the blocked operation.
    - D. Owners have no resource permissions.

35. Which two settings most directly reduce the blast radius of a SAS? **Choose two.**
    - A. HTTP allowed
    - B. Indefinite validity
    - C. Short expiration
    - D. Minimum required permissions/resource scope
    - E. Account-wide full control

36. Two peered VNets use custom DNS servers. Name resolution fails although IP connectivity works. What should you remember?
    - A. Peering provides network connectivity but does not automatically design/configure DNS resolution.
    - B. Peering always copies DNS zones.
    - C. NSGs create host records.
    - D. Public IP SKU controls private DNS.

37. You need to suppress alerts only for `rg-maint` from 01:00–02:00 while leaving other resources unaffected. What configuration is most precise?
    - A. Delete the action group tenant-wide
    - B. Disable Log Analytics
    - C. Stop every subscription
    - D. Scheduled alert processing rule scoped to `rg-maint`

38. Which statement about AKS responsibility is correct?
    - A. AKS removes all need for RBAC.
    - B. Every Pod receives a public IP by default.
    - C. Azure manages the control plane, while the customer still governs workloads, node pools, access, networking, and upgrades within the shared model.
    - D. Azure writes every application manifest.

39. An existing noncompliant resource is under an Audit policy. What does Audit do?
    - A. Creates a backup.
    - B. Records noncompliance without blocking or changing the resource.
    - C. Deletes the resource.
    - D. Grants Owner.

40. A storage account key may have leaked. Which action is most urgent after identifying affected clients?
    - A. Rotate/regenerate the compromised key safely and move clients toward identity-based access.
    - B. Change the resource-group tag only.
    - C. Add a VM availability set.
    - D. Enable public blob access.

41. Which two must be checked when NSG-filtered application traffic fails? **Choose two.**
    - A. Backup retention only
    - B. Effective security rules
    - C. Guest OS firewall/listener
    - D. Storage lifecycle age
    - E. Entra license SKU

42. A VM workload requires host-level encryption of temporary disks and cache, where supported. Which setting is relevant?
    - A. VNet peering
    - B. Cost budget
    - C. Encryption at host
    - D. Blob public access

43. You enable SSPR for a selected group. A user outside the group tries to reset a password through SSPR. What is expected?
    - A. The password is stored in a blob.
    - B. The user is not enabled by that scoped configuration.
    - C. The user becomes subscription Owner.
    - D. Policy creates a VM.

44. Which recovery test should use an isolated network to avoid duplicate identities/IPs and unintended application traffic?
    - A. ASR test failover
    - B. Metric chart
    - C. Policy compliance scan
    - D. Budget forecast

45. A VM Scale Set has minimum 2, default 3, maximum 8. A scale-out rule requests four more instances while capacity is 6. What is the final capacity limit?
    - A. 10
    - B. 6
    - C. 3
    - D. 8

46. An external user no longer needs access. Which two actions provide the most complete cleanup? **Choose two.**
    - A. Disable storage encryption.
    - B. Remove relevant role/group assignments.
    - C. Block or remove the guest account according to governance policy.
    - D. Add Owner at subscription scope.
    - E. Publish a SAS.

47. Which command output is most useful to verify a NIC's learned routes?
    - A. `az backup vault list`
    - B. `az network nic show-effective-route-table`
    - C. `az storage blob list`
    - D. `az ad user list`

48. Customer-managed storage encryption loses access to its Key Vault key. What risk should you anticipate?
    - A. Storage data operations can fail because the account cannot unwrap its encryption key.
    - B. The VNet automatically overlaps.
    - C. All blobs become public.
    - D. The account converts to LRS.

49. A highly available web tier needs instances distributed across availability zones. Which deployment meets the requirement?
    - A. One large VM with a lock
    - B. One VM with two tags
    - C. A blob snapshot only
    - D. Multiple VM/scale-set instances placed across supported zones

50. Which statement correctly compares metrics and logs?
    - A. Logs cannot trigger alerts.
    - B. Metrics require a Recovery Services vault.
    - C. Metrics are numeric time series; logs are structured records queried for richer analysis.
    - D. Metrics contain every guest event automatically.
