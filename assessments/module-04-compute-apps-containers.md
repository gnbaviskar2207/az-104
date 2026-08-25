# Module 04 checkpoint: compute, apps, and containers

**Time:** 25 minutes  
**Target:** 12/15  
**Answer book:** [Open only after finishing](answers/module-04-compute-apps-containers-answers.md)

1. Which Bicep benefit most directly improves repeatable Azure deployments?
   - A. Bypass of Azure RBAC
   - B. Declarative desired state with dependency analysis
   - C. Manual Portal clicks embedded in a binary
   - D. Automatic application backups for every resource

2. Before applying a Bicep change, which command helps preview creates, changes, and deletes?
   - A. `az group delete`
   - B. `az vm restart`
   - C. `az account clear`
   - D. `az deployment group what-if`

3. A target VM size is unavailable while the VM is running but supported by the region. What commonly expands the resize choices?
   - A. Enable SSPR.
   - B. Deallocate the VM before resizing.
   - C. Add a tag.
   - D. Create a blob container.

4. Which disk is designed for temporary data that can be lost during maintenance or redeployment?
   - A. OS managed disk
   - B. Premium data disk
   - C. Snapshot
   - D. Temporary disk

5. Which design protects a VM workload from a single datacenter-zone failure in a supported region?
   - A. Use one larger disk.
   - B. Deploy redundant instances across availability zones.
   - C. Put one VM in an availability set.
   - D. Add a CanNotDelete lock to one VM.

6. A VM Scale Set must add instances when average CPU is high. What should you configure?
   - A. A DNS MX record
   - B. Blob soft delete
   - C. Entra SSPR
   - D. Autoscale settings with metric rules and instance limits

7. You need a private registry for container images. Which service should you deploy?
   - A. Azure Policy
   - B. Azure Container Registry
   - C. Azure Container Instances
   - D. Azure Files only

8. You need to run one short-lived container without orchestrating a cluster. Which service is the simplest fit?
   - A. AKS with multiple node pools
   - B. VM Scale Sets
   - C. Application Gateway
   - D. Azure Container Instances

9. Which Container Apps feature supports immutable application versions and controlled traffic splitting?
   - A. Storage access keys
   - B. Revisions
   - C. Managed disks
   - D. Availability sets

10. App Service automatic scale-out is primarily constrained/configured at which compute boundary?
    - A. Private DNS zone
    - B. App Service plan and supported scaling features/tier
    - C. Resource-group region only
    - D. Entra group

11. What is the safest use of an App Service deployment slot?
    - A. Validate a release in a nonproduction slot, preserve slot-specific settings, then swap.
    - B. Use it as a storage backup.
    - C. Assign it Owner at tenant scope.
    - D. Replace TLS configuration with HTTP.

12. A custom domain has been validated for an App Service app. What else is required for trusted HTTPS?
    - A. Add an NSG to the multi-tenant App Service frontend.
    - B. Create an availability set.
    - C. Enable blob versioning.
    - D. Bind a valid certificate to the hostname and enforce suitable TLS/HTTPS settings.

13. **Choose two.** Which App Service networking statements are correct?
    - A. Deployment slots automatically share every networking resource and setting without review.
    - B. An NSG can be directly attached to an App Service app object.
    - C. VNet integration is primarily for outbound access from the app into a VNet.
    - D. A private endpoint can provide private inbound access to the app.
    - E. VNet integration alone makes the public app endpoint private.

14. In AKS, which layer is responsible for scheduling Pods onto nodes?
    - A. Recovery Services vault
    - B. Kubernetes control plane
    - C. Azure DNS public zone
    - D. Storage account firewall

15. A production container workload needs event-driven scale-to-zero, revisions, and managed ingress without cluster administration. Which service best matches?
    - A. Azure Container Apps
    - B. Azure Container Registry alone
    - C. Availability set
    - D. Azure Bastion
