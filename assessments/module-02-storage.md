# Module 02 checkpoint: storage

**Time:** 25 minutes  
**Target:** 12/15  
**Answer book:** [Open only after finishing](answers/module-02-storage-answers.md)

1. A storage account must tolerate a datacenter-zone failure in its primary region without regional replication. Which redundancy should you select?
   - A. RA-GRS
   - B. LRS
   - C. ZRS
   - D. GRS

2. An application should read blobs for 30 minutes without receiving the account key. What should you issue?
   - A. The storage account key
   - B. Owner at subscription scope
   - C. A public container setting
   - D. A narrowly scoped, short-lived SAS over HTTPS

3. Why associate a service SAS with a stored access policy?
   - A. To create a private IP
   - B. To change the account region
   - C. To centrally change or revoke policy constraints for associated SAS tokens
   - D. To enable ZRS

4. Which authorization approach is preferred for an Azure-hosted workload accessing blobs when supported?
   - A. Microsoft Entra identity with an appropriate data role
   - B. Anonymous public access
   - C. An unlimited account SAS
   - D. Embedded account key

5. A user has Reader on the storage account management plane. Can the user read private blob data?
   - A. Reader automatically includes all Storage data actions
   - B. Always
   - C. Not unless separately granted suitable data-plane access or a valid SAS/key
   - D. Only from the Portal

6. You enable a storage firewall with default action Deny. Which configuration allows a subnet to reach the public storage endpoint without a private IP?
   - A. VNet peering only
   - B. A route table only
   - C. Blob versioning
   - D. A Microsoft.Storage service endpoint plus an allowed virtual-network rule

7. What distinguishes a private endpoint from a service endpoint?
   - A. There is no difference.
   - B. A private endpoint gives the service subresource a private IP in your VNet.
   - C. A service endpoint creates a NIC in your subnet.
   - D. A private endpoint makes the account public.

8. A frequently accessed blob becomes rarely used after 30 days and can be deleted after 365 days. Which feature automates this?
   - A. Stored access policy
   - B. NSG
   - C. Resource lock
   - D. Lifecycle management policy

9. Which feature retains previous blob states after overwrites?
   - A. Static website hosting
   - B. Blob versioning
   - C. Object replication alone
   - D. LRS

10. A file is accidentally deleted from an Azure file share. Which feature must have been configured for recovery within a retention period?
    - A. Blob index tags
    - B. RA-GRS read endpoint
    - C. CDN
    - D. File share soft delete

11. Which tool is designed for high-performance command-line transfer to and from Azure Storage?
    - A. Network Watcher
    - B. Azure Policy
    - C. AzCopy
    - D. Azure Advisor

12. **Choose two.** Which statements about object replication are correct?
    - A. It asynchronously copies eligible block blobs between accounts.
    - B. Blob versioning is a prerequisite on participating accounts.
    - C. It is synchronous and guarantees zero data loss.
    - D. It replaces every backup requirement.
    - E. It replicates Azure Files shares.

13. A storage account must use a customer-managed key. Where is that key typically maintained?
    - A. Azure Key Vault or Managed HSM
    - B. Azure DNS
    - C. An NSG
    - D. A Recovery Services vault

14. You regenerate the account key currently used by an application without updating the application first. What is the likely result?
    - A. Automatic conversion to Entra authentication
    - B. ZRS failover
    - C. No effect because keys are informational
    - D. Authentication failures

15. A private blob endpoint resolves to the storage public IP from a VM in the VNet. What should you inspect first?
    - A. Lifecycle rule order
    - B. File share quota
    - C. Private DNS zone linkage and the `privatelink.blob.core.windows.net` record
    - D. Blob access tier
