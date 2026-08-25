# Module 04 compute v2 — answer book

Open this only after completing the checkpoint with the timer running.

---

**1. C — Temporary disk contents are not preserved across redeployment, host maintenance moves, or VM deallocation.**

The temporary disk (D: on Windows, `/dev/sdb` or `/mnt` on Linux) provides fast local storage but is ephemeral. It is lost on host maintenance migrations, VM redeployment, deallocation, or resize. Only OS disks and attached managed data disks survive these events. Authoritative data must never be stored on the temporary disk.

*Trap:* Developers often use temp disk for speed and assume it behaves like a data disk.

---

**2. D — Compute allocation may still be billed because the VM is stopped but not deallocated in Azure.**

Shutting down the guest OS puts the VM in the `Stopped` state from Azure's perspective but does **not** release the compute allocation. Azure continues charging for the vCPU and RAM reservation. To stop compute billing, you must deallocate the VM via Portal **Stop** button (which deallocates), `az vm deallocate`, or `Stop-AzVM`. Managed disks, public IPs (static), and other attached resources remain billable regardless.

*Trap:* This is one of the most frequently missed questions on the real exam.

---

**3. C — 8 — the maximum boundary is enforced.**

Autoscale rules request a change in capacity, but the configured maximum acts as a hard ceiling. Current capacity 6 + requested 5 = 11, which exceeds maximum 8. Azure caps at 8. The minimum (2) and maximum (8) boundaries are always respected regardless of rule quantity.

*Trap:* Candidates calculate 6+5=11 and select it, missing the maximum constraint.

---

**4. B — The production slot now has the staging database connection string.**

Application settings and connection strings that are **not** marked as deployment slot settings travel with the deployment package during a swap. Sticky (slot-specific) settings stay with their slot regardless of swaps. Since the connection string was not marked sticky, it moved from staging to production during the swap.

*Trap:* Many candidates assume that connection strings always stay with their slot. They only stay if explicitly marked as slot-sticky.

---

**5. B — The Container App's registry configuration must explicitly reference the user-assigned identity as the pull identity.**

When using a user-assigned managed identity for ACR pull in Container Apps, you must configure the Container App's registry authentication to use that specific identity. Simply attaching the identity to the Container App does not automatically route ACR authentication through it — the registry entry in the Container App config must explicitly specify which identity to use.

*Trap:* The `AcrPull` role is correct and the identity is attached, but the explicit wiring in the Container App registry config is missing.

---

**6. B — The resource's symbolic name or `name` property changed in the Bicep file.**

Azure Resource Manager tracks resources by their resource ID, which includes the resource name. If either the symbolic name (used internally by Bicep) or the `name` property changes, ARM treats the new entry as a different resource and plans to delete the old one and create the new one. Use the `existing` keyword to reference an existing resource without redeploying it, or ensure naming is consistent.

*Trap:* Candidates assume `what-if` is broken or that schema changes cause deletions. The root cause is always the resource identifier change.

---

**7. B — Validate move support and include dependent resources.**

VM moves require: (1) verifying that all resource types (VM, NIC, OS disk, data disks, public IP) support the move operation, (2) moving all dependent resources together in the same move operation, and (3) source and destination subscriptions must be in the same Entra tenant for a supported move. Use `az resource invoke-action --action validateMoveResources` before executing.

---

**8. C — An availability set with two or more VMs provides a higher SLA for planned maintenance than a single VM, but does not protect against a zone-wide failure.**

Availability sets distribute VMs across fault domains (power/network isolation) and update domains (maintenance batches) within one datacenter. This protects against host-level failures and staggered maintenance, raising SLA vs. a single VM. However, all fault domains are within the same physical datacenter — a zone-level failure affects all of them. Availability zones protect against datacenter-level failures.

*Trap:* Option A — a single Premium SSD VM does have a higher SLA than a single standard VM, but not as high as two VMs in an availability set. Read exact SLA pages before exam day.

---

**9. B — The target size is not available in the current cluster or region, or a quota limit is reached.**

After deallocation, Azure reassigns the VM to a new cluster when it starts. If the target SKU is not available in the region, current cluster, or has reached quota, resize fails with `OperationNotAllowed`. Solutions: check `az vm list-vm-resize-options`, verify quota with `az vm list-usage`, try a different region/zone, or request quota increase.

---

**10. B — VNet integration enables outbound calls into the VNet; the private endpoint enables private inbound access — they serve opposite directions.**

These two features are complementary and directionally distinct:
- **VNet integration**: app → VNet (outbound), allowing the app to reach private resources like databases.
- **Private endpoint**: client in VNet → app (inbound), giving the app a private IP accessible within the VNet.

*Trap:* Candidates confuse the two or think one replaces the other.

---

**11. A — The managed identity has the `AcrPull` role assigned at the registry scope.**

For ACI with system-assigned managed identity to pull from ACR without admin credentials: the identity (represented by its object/principal ID) must have `AcrPull` role at the ACR resource scope. The ACI must be configured with the identity at creation time. Admin user does not need to be enabled.

---

**12. A and C — Availability zones protect against datacenter-level failure; availability sets distribute within one datacenter scope; availability sets distribute across fault and update domains.**

Correct: (A) zones = separate physical datacenters (power, cooling, networking); sets = within one datacenter across rack/update groups. (C) availability sets use fault domains and update domains within one datacenter.

Wrong: (B) reversed definitions. (D) they cannot be combined on the same VM. (E) zones are production features.

---

**13. B — It applies the destination slot's settings to staging so you can validate startup behavior before completing the swap.**

A swap preview (two-phase swap) first applies the production slot's configuration to staging and validates that the app starts correctly with those settings. You can then either complete the swap (which makes the exchange permanent) or cancel it (which rolls back staging to its original configuration). This gives you a chance to abort if the staging app fails to start with production settings.

---

**14. C — Temporary disk and VM host cache (disk cache) are encrypted.**

Azure Storage Service Encryption (SSE) encrypts data at rest in Azure Storage. Encryption at host extends encryption to the temporary disk and the host cache (data cached on the physical host for OS and data disks), which SSE does not cover. This ensures all data at rest on the physical host is encrypted.

---

**15. C — Azure Container Apps — it provides revision management, ingress, and KEDA-based scale-to-zero without control-plane administration.**

Container Apps is built on Kubernetes but abstracts the control plane entirely. Key features: revision-based deployments, traffic splitting between revisions, HTTPS managed ingress, KEDA-based autoscaling including scale-to-zero. ACI does not support revision traffic splitting. AKS requires control-plane management. App Service scale-to-zero is limited to specific plan tiers (Consumption/Flex) and lacks revision traffic splitting natively.
