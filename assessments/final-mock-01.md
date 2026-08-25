# AZ-104 Final Mock Exam 1

**Questions:** 50  
**Time:** 100 minutes  
**Readiness target:** 40/50 overall and at least 70% in every domain  
**Answer book:** [Open only after submitting all answers](answers/final-mock-01-answers.md)

Unless the question says **Choose two**, select one answer.

1. A group must manage resources only in `rg-app1` and must not grant access. What is the best assignment?
   - A. User Access Administrator on `rg-app1`
   - B. Owner on the subscription
   - C. Contributor on `rg-app1`
   - D. Contributor on the tenant

2. A workload uses a managed identity to upload blobs. Which role should be assigned at the narrowest suitable scope?
   - A. Reader
   - B. Storage Account Contributor
   - C. Owner
   - D. Storage Blob Data Contributor

3. You need a repeatable resource deployment that exposes environment-specific values without editing the template. What should Bicep use?
   - A. Blob snapshots
   - B. Parameters
   - C. Resource locks
   - D. NSG priorities

4. Spoke1 and Spoke2 are each peered only with Hub. They cannot communicate through Hub. What is the reason?
   - A. Peering supports only public traffic.
   - B. All three VNets must overlap.
   - C. DNS prevents routed traffic.
   - D. Peering is nontransitive without explicit routing/forwarding design.

5. A platform metric alert fires, but nobody is notified. The condition and evaluation history are correct. What should you inspect first?
   - A. Storage access tier
   - B. Action group association and receiver status
   - C. VM disk caching
   - D. VNet address space

6. A user needs to view cost data but not resources. Which role is the best starting point?
   - A. Owner
   - B. Virtual Machine Contributor
   - C. Storage Blob Data Owner
   - D. Cost Management Reader at the required scope

7. A VM requires durable application data separate from its OS. What should you attach?
   - A. Container writable layer
   - B. Managed data disk
   - C. Temporary disk
   - D. Cloud Shell storage

8. You need account-level protection against accidental deletion of containers and individual blobs. **Choose two.**
   - A. Anonymous access
   - B. Container soft delete
   - C. Blob soft delete
   - D. Read-access geo-redundancy only
   - E. Static website hosting

9. A subnet must access Storage through its public endpoint while the storage firewall allows only that subnet. What is required?
   - A. Public Load Balancer
   - B. Microsoft.Storage service endpoint and a storage VNet rule
   - C. Private endpoint only, with no DNS
   - D. VNet peering to every Azure region

10. A Deny policy is assigned at subscription scope. A Contributor deployment violates it. What is the result?
    - A. Contributor bypasses Policy.
    - B. The deployment succeeds and becomes Reader.
    - C. Policy evaluates only monthly.
    - D. The request is denied.

11. A web application release must be validated before production and switched with minimal interruption. What should you use?
    - A. Blob archive tier
    - B. VM temporary disk
    - C. App Service deployment slot and swap
    - D. A second tenant

12. You need to query `Heartbeat` records for the last hour. Which service/language pair is correct?
    - A. Key Vault and XPath
    - B. Log Analytics and KQL
    - C. Azure DNS and Bicep
    - D. Cost Management and SQL

13. An NSG rule allows TCP 443 at priority 250. Another denies all inbound at priority 200. What happens?
    - A. TCP 443 is denied because priority 200 evaluates first.
    - B. TCP 443 is allowed because specific rules always win.
    - C. Both are merged into Allow.
    - D. The NIC ignores subnet NSGs.

14. A storage workload must remain available after a zone failure but does not need a secondary region. Which redundancy is appropriate?
    - A. LRS
    - B. GRS
    - C. RA-GRS
    - D. ZRS

15. A new policy with `modify` marks existing resources noncompliant. Which two components enable remediation? **Choose two.**
    - A. Public IP
    - B. Availability set
    - C. Stored access policy
    - D. Remediation task
    - E. Assignment managed identity with required role

16. A VM Scale Set should keep 2–10 instances and add one when average CPU exceeds 75%. What should you configure?
    - A. DNS alias record
    - B. Autoscale profile with min/max/default and a scale-out metric rule
    - C. Availability set only
    - D. Resource-group lock

17. A VM can resolve a Storage FQDN but gets the public IP rather than its private endpoint IP. What should you fix?
    - A. Private DNS zone record/linkage
    - B. VM size
    - C. Blob lifecycle rule
    - D. Subscription budget

18. Which scope ordering is correct for inherited governance?
    - A. Resource → subscription → tenant → resource group
    - B. Subscription → management group → resource → resource group
    - C. Resource group → region → subscription → resource
    - D. Management group → subscription → resource group → resource

19. Operations wants scheduled suppression of notifications during maintenance without disabling detection. What should be used?
    - A. ReadOnly lock
    - B. Backup policy
    - C. Alert processing rule
    - D. Delete the alerts

20. A partner needs read access to one container for two hours. Which option best follows least privilege?
    - A. Contributor at subscription scope
    - B. Read-only, HTTPS-only, short-lived SAS scoped to the container
    - C. Storage account key
    - D. Public anonymous access

21. An ARM template must be converted to a readable starting-point Bicep file. Which workflow is appropriate?
    - A. Decompile, review/fix warnings, validate, then use what-if
    - B. Rename `.json` to `.bicep`
    - C. Export VM logs to DNS
    - D. Create a resource lock

22. An operator needs Portal RDP/SSH to private VMs without public IPs. Which service fits?
    - A. Azure Front Door
    - B. Azure Files
    - C. Azure Backup
    - D. Azure Bastion

23. A resource group has a CanNotDelete lock. Which operation is still normally allowed?
    - A. Deleting every child resource
    - B. Removing the lock without lock-management permission
    - C. Updating a tag on a child resource
    - D. Deleting the locked resource group

24. Which service is best for a single short-running container with no orchestrator management requirement?
    - A. App Service Environment only
    - B. Azure Container Instances
    - C. Azure Kubernetes Service
    - D. VM Scale Sets

25. A file share must be recoverable after accidental share deletion. What should be enabled before the incident?
    - A. Azure Files soft delete with an appropriate retention period
    - B. Blob versioning
    - C. Container Apps revisions
    - D. NSG flow logs

26. A department tag on a resource group must appear on all resources. What is true by default?
    - A. The tag always propagates instantly.
    - B. Tags cannot be applied to resource groups.
    - C. Only global admins can read tags.
    - D. It requires Policy/automation because tags do not automatically inherit.

27. Which Network Watcher feature reports the NSG rule that allows or denies a sample flow?
    - A. Topology only
    - B. Service Health
    - C. IP flow verify
    - D. Connection Monitor

28. A VM must be restored to investigate yesterday's application state without overwriting production. What is the best approach?
    - A. Disable soft delete.
    - B. Restore disks or create a new VM in an isolated validation scope from the chosen recovery point.
    - C. Delete the production VM first.
    - D. Run ASR commit before testing.

29. Which App Service capability supports outbound access from an app into a VNet?
    - A. VNet integration
    - B. Private endpoint only
    - C. Deployment slot swap
    - D. Custom domain verification

30. A subscription budget crosses 90%. What is a valid expectation?
    - A. The subscription is deleted.
    - B. All VMs are resized.
    - C. RBAC assignments are removed.
    - D. Configured notifications/actions occur; resources are not automatically stopped by the budget itself.

31. Which feature automatically moves blobs to cool storage based on last modification age?
    - A. Stored access policy
    - B. Resource lock
    - C. Lifecycle management
    - D. Object replication

32. Which two facts about peering are correct? **Choose two.**
    - A. Peering merges the VNets into one resource.
    - B. Address spaces must not overlap.
    - C. Each peering direction has configurable properties.
    - D. Peering is transitive by default.
    - E. Peering requires public IPs on all VMs.

33. A container workload needs revisions, managed ingress, and event-driven scaling. Which service should you choose?
    - A. Azure Container Apps
    - B. ACR only
    - C. Azure DNS
    - D. Recovery Services vault

34. Which built-in role can manage role assignments without granting broad resource management?
    - A. Reader
    - B. Monitoring Reader
    - C. Virtual Machine User Login
    - D. User Access Administrator

35. What must be configured to send a storage account's platform logs to Log Analytics?
    - A. SSPR
    - B. App Service slot
    - C. Diagnostic setting selecting categories and the workspace destination
    - D. VNet peering

36. A load balancer backend is healthy on TCP 80, but the application returns HTTP 500. What change improves health detection?
    - A. Enable blob snapshots.
    - B. Use an HTTP/HTTPS probe against an application health path.
    - C. Increase the public IP address size.
    - D. Add an Entra group.

37. Blob data is overwritten frequently and prior states must remain recoverable. What should you enable?
    - A. Blob versioning
    - B. LRS only
    - C. Static website
    - D. SFTP only

38. A VM has no SLA requirement during planned host maintenance but must protect data from disk loss. Which choice addresses data durability, not VM availability?
    - A. Temporary disk
    - B. Availability set alone
    - C. One ephemeral container
    - D. Managed data disk with appropriate redundancy and backup

39. You invite an external consultant to your tenant. What is created for collaboration?
    - A. Storage account key
    - B. Availability zone
    - C. External guest user object
    - D. Managed identity tied to a VM

40. A subnet route table sends all traffic to an NVA, but the NVA cannot forward packets. Which setting may be missing on its NIC?
    - A. App Service backup
    - B. IP forwarding
    - C. Blob soft delete
    - D. SSPR

41. What does deallocating a VM do that stopping the guest OS alone may not?
    - A. Releases the compute allocation and stops compute billing, while disks remain billable.
    - B. Deletes all managed disks.
    - C. Converts it to a scale set.
    - D. Creates an ASR failover.

42. Object replication is being configured between two storage accounts. Which prerequisite is relevant?
    - A. Identical account names
    - B. Same resource group
    - C. Public container access
    - D. Blob versioning on source and destination

43. Which role should a user receive to view resources without changing them?
    - A. Contributor at subscription scope
    - B. Storage Blob Data Contributor
    - C. Reader at the required scope
    - D. Owner at tenant scope

44. Why perform an isolated ASR test failover?
    - A. To resize the source VM
    - B. To validate recovery without disrupting production or ongoing replication
    - C. To permanently reverse replication
    - D. To replace backup retention

45. A custom hostname maps to an App Service app, but browsers report an untrusted HTTPS connection. What is missing?
    - A. A valid certificate bound to that hostname
    - B. A VM availability set
    - C. Blob object replication
    - D. A management group

46. Which Entra group type/rule supports automatic membership by `department` attribute?
    - A. Assigned group with no automation
    - B. Device-only administrative unit
    - C. Resource group
    - D. Dynamic user security group

47. A Standard Load Balancer has healthy backends but they require deterministic outbound internet connectivity. What should be designed explicitly?
    - A. Resource lock
    - B. Entra license
    - C. NAT Gateway or an appropriate outbound rule
    - D. Blob snapshot

48. What is the safest account-key rotation sequence for applications that still use shared keys?
    - A. Never rotate keys.
    - B. Regenerate the unused key, update/validate clients, then rotate the former key.
    - C. Regenerate both keys simultaneously.
    - D. Publish both keys in source control.

49. Which availability construct distributes VMs across fault and update domains within a datacenter scope?
    - A. Availability set
    - B. Availability zone
    - C. Resource group
    - D. Deployment slot

50. What does an Azure Backup policy primarily control?
    - A. NSG rule evaluation
    - B. Entra group membership
    - C. VNet peering transit
    - D. Backup schedule and recovery-point retention
