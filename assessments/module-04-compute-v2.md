# Module 04 checkpoint v2: compute, apps, and containers — trap edition

**Time:** 25 minutes  
**Target:** 12/15  
**Answer book:** [Open only after finishing](answers/module-04-compute-v2-answers.md)

> Every question in this set uses deliberate wording traps found in the real AZ-104 exam.
> Read each scenario constraint carefully before selecting an answer.

1. A developer stored important application data in the VM's **temporary disk** (`/dev/sdb` on Linux, `D:` on Windows) during testing. After a planned host maintenance event, the data is gone. What is the cause?

   - A. The OS disk was accidentally detached during maintenance.
   - B. The managed data disk was deleted with the VM.
   - C. Temporary disk contents are not preserved across redeployment, host maintenance moves, or VM deallocation.
   - D. The VM backup policy excluded the temporary disk.

2. An administrator shuts down a Windows VM from inside the guest OS using the Start menu **Shut down** option. The Azure Portal shows the VM status as **Stopped** (not `Stopped (deallocated)`). What is the cost implication?

   - A. Compute billing stops as soon as the guest OS shuts down.
   - B. The VM is free because it is stopped.
   - C. Only disk billing continues; compute stops immediately.
   - D. Compute allocation may still be billed because the VM is stopped but not deallocated in Azure; run `az vm deallocate` or use Portal **Stop** to release the allocation.

3. A VM Scale Set is configured with minimum **2**, default **3**, maximum **8** instances. An autoscale rule fires and requests adding **5** instances. Current capacity is **6**. What is the resulting instance count?

   - A. 11 — autoscale always honors the scale rule quantity.
   - B. 6 — autoscale never scales while rules are firing.
   - C. 8 — the maximum boundary is enforced; capacity cannot exceed the configured maximum.
   - D. 3 — the instance count resets to default on rule trigger.

4. A production App Service deployment slot swap is complete. The staging database connection string was **not** marked as a deployment slot setting. What happened to the production slot's connection string after the swap?

   - A. The production slot kept its original connection string because slot settings always stay with the slot.
   - B. The production slot now has the staging database connection string because non-sticky settings travel with the code during swap.
   - C. The swap was blocked because the connection strings did not match.
   - D. Both slots received a merged connection string.

5. A Container App revision is failing with `image pull: unauthorized`. The Container App has a **user-assigned managed identity**. The identity has `AcrPull` on the correct registry. What is the most likely oversight?

   - A. The `AcrPull` role must be assigned to the system-assigned identity, not the user-assigned identity.
   - B. The Container App's registry configuration must explicitly reference the user-assigned identity as the pull identity; simply attaching the identity is not sufficient.
   - C. ACR admin user must be enabled for managed-identity pull.
   - D. The Container App must be in the same region as the registry.

6. A Bicep `what-if` operation shows **Delete** for an existing storage account followed by **Create** for a new one with the same intended configuration. No deletion was planned. What is the most likely cause?

   - A. The storage account SKU changed.
   - B. The resource's symbolic name or the `name` property changed in the Bicep file, causing Azure Resource Manager to treat it as a different resource.
   - C. The resource group was accidentally changed.
   - D. The `what-if` command always deletes and recreates resources on every run.

7. A VM needs to move to a different resource group. Which statement is correct?

   - A. All VM resource types support moves to any target without validation.
   - B. You must validate move support for the VM and all dependent resources (NIC, disk, public IP), and the destination resource group must be in a subscription under the same Entra tenant for a supported move.
   - C. VMs cannot move between resource groups after creation.
   - D. You must delete the VM and redeploy it in the new resource group.

8. An availability set distributes VMs across fault and update domains. A second VM is added. Which statement about SLA is correct?

   - A. A single VM with a Premium SSD has the same SLA as two VMs in an availability set.
   - B. An availability set guarantees zero downtime during host maintenance.
   - C. An availability set with two or more VMs provides a higher SLA against planned maintenance than a single VM, but does not protect against a zone-wide failure.
   - D. Availability sets are deprecated and replaced by availability zones in all regions.

9. You run:

   ```bash
   az vm deallocate --resource-group rg-prod --name vm-web
   az vm resize --resource-group rg-prod --name vm-web --size Standard_D4s_v5
   az vm start --resource-group rg-prod --name vm-web
   ```

   The resize fails with `OperationNotAllowed`. What is the most likely reason?

   - A. The VM must be running for resize to succeed.
   - B. The target size is not available in the current cluster or region, or a quota limit is reached.
   - C. Resizing requires deleting all managed disks first.
   - D. Only the Portal supports resize operations.

10. An App Service app has VNet integration configured for outbound traffic. An inbound private endpoint is also deployed. Which statement correctly describes the two features?

    - A. VNet integration handles both inbound and outbound; the private endpoint is redundant.
    - B. VNet integration enables the app to make outbound calls into the VNet; the private endpoint enables private inbound access to the app from within the VNet — they serve opposite directions.
    - C. Both features require a dedicated App Service Environment.
    - D. VNet integration replaces the need for DNS resolution inside the VNet.

11. An ACR image is pushed successfully. An ACI instance tries to pull the same image and fails with `unauthorized`. The ACI was created with a system-assigned managed identity. What must be verified?

    - A. The managed identity has the `AcrPull` role assigned at the registry scope.
    - B. The registry admin user must be enabled for ACI pulls.
    - C. The ACI must be in the same resource group as the ACR.
    - D. The image tag must be `latest` for managed-identity pull to work.

12. **Choose two.** Which statements correctly describe the difference between availability zones and availability sets?

    - A. Availability zones protect against datacenter-level (physical zone) failure; availability sets distribute within a single datacenter.
    - B. Availability sets span multiple regions; availability zones are single-datacenter constructs.
    - C. Availability sets distribute VMs across fault and update domains within one datacenter scope.
    - D. Availability zones and availability sets can be combined on the same VM.
    - E. Availability zones are only available for non-production workloads.

13. A deployment slot labeled **staging** contains a tested release. Before swapping to production you run a swap preview. What is the purpose of the preview step?

    - A. It permanently applies the staging configuration to production.
    - B. It applies the destination slot's settings to staging so you can validate startup behavior before completing the swap — the swap can then be completed or cancelled.
    - C. It deletes the staging slot automatically after validation.
    - D. It copies the production database connection string into staging.

14. A Linux VM has encryption at host enabled. Which storage locations does this encrypt, beyond what Azure Storage Service Encryption already covers?

    - A. Only the OS disk is additionally encrypted.
    - B. Only managed data disks are additionally encrypted.
    - C. Temporary disk and VM host cache (disk cache) — data that was previously unencrypted at rest on the physical host — are encrypted.
    - D. Encryption at host has no additional effect; it duplicates existing SSE coverage.

15. You need a containerized HTTP workload that supports **traffic splitting between revisions**, **scale to zero**, and **managed ingress** — without managing Kubernetes control plane nodes. Which service fits?

    - A. Azure Container Instances — it supports revision traffic splitting natively.
    - B. Azure Kubernetes Service — you must manage the control plane for these features.
    - C. Azure Container Apps — it provides revision management, ingress, and KEDA-based scale-to-zero without control-plane administration.
    - D. Azure App Service with Docker — it supports scale to zero on all plan tiers.
