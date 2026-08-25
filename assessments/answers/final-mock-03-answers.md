# Final Mock Exam 3 — answer book

Open this only after completing the mock with the timer running.

---

## Case study A: Northwind Traders

**1. C — Azure Policy with `modify` effect, remediation task, and managed identity with tag-write role.**

`modify` policy can both block new noncompliant resources (Deny behavior at deployment) and remediate existing ones via a remediation task. The assignment managed identity needs a role that permits `Microsoft.Resources/tags/write` on the scope. Reader assignment (A) is read-only, budget alerts (B) are cost controls, and locks (D) don't enforce tags.

**2. B and C — Private endpoint for blob subresource; private DNS zone linked with A record.**

A private endpoint gives the storage blob service a private NIC in the VNet. The private DNS zone resolves the public FQDN to that private IP. Both are required for DNS-based private access. A service endpoint (D) keeps traffic on the public IP. RA-GRS (E) is redundancy, not access control.

**3. B — Diagnostic setting on the App Service targeting the Log Analytics workspace.**

App Service exposes platform logs (AppServiceHTTPLogs, AppServiceConsoleLogs, etc.) through diagnostic settings. You configure which categories to collect and where to route them. AMA cannot be installed on PaaS App Service. Blob versioning is irrelevant.

**4. B — Azure Site Recovery with replication to secondary region.**

ASR provides continuous replication and supports RTO objectives measured in minutes to hours. Daily backup alone (A) cannot meet a 4-hour RTO — restoring from a 24-hour-old recovery point plus VM provisioning time can easily exceed 4 hours for non-trivial workloads. Availability zones (D) protect against zone failures within one region, not regional failures.

**5. B — Contributor on the dev subscription only.**

RBAC inheritance flows top-down. Contributor on the management group (A) would give access to both subscriptions. Contributor on dev only keeps developers out of production entirely, satisfying least privilege. Deny assignments (C) are complex and not necessary here. Assigning Contributor on every RG individually (D) achieves the same as subscription-level but with more management overhead.

---

## Case study B: Fabrikam Security Audit

**6. B — Assign managed identity role → migrate app → disable shared key.**

The safe migration sequence: enable managed identity, assign `Storage Blob Data Contributor` to the identity, update and validate the application using Entra auth, then disable shared key access once all clients are confirmed migrated. Disabling shared key before migrating causes an outage.

**7. C — Add `Allow-HTTPS` at priority 50, then change priority-100 rule to `Deny-All-Inbound`.**

To allow only TCP 443 from Internet: (1) add an allow rule at priority 50 (below 100) for TCP 443 from Internet, (2) change the existing priority-100 rule to `Deny-All-Inbound` with source `*`. The default `DenyAllInBound` at 65500 already provides a backstop, but the explicit deny makes the intent clear and removes the broad allow.

**8. A — Replace Owner with Cost Management Reader at subscription scope.**

Cost Management Reader grants access to view cost and usage data without resource management permissions. This is the minimum role that satisfies "review billing data only." Global Administrator (B) is an Entra directory role, not an Azure resource role. Contributor (D) is broader than needed.

**9. B — Create Recovery Services vault, configure backup policy, enable protection on the VM, run on-demand backup.**

All four steps are required. Creating a vault and policy without enabling protection means no backup runs. The on-demand backup creates the first recovery point immediately, satisfying the 24-hour accessibility requirement.

**10. B — Set autoscale maximum and configure a budget alert.**

Setting the maximum instance count caps the cost exposure from unbounded scale-out. A budget alert provides financial visibility and early warning. Deleting VMSS (A) removes the workload. ReadOnly lock (C) would prevent autoscale from running. Disabling autoscale (D) defeats the availability purpose of VMSS.

---

## Standalone questions

**11. B — Denied — `Deny-All-Inbound` at priority 100 evaluates before `Allow-HTTPS` at priority 300.**

The CLI output shows priority 100 as `Deny` on all ports, priority 300 as `Allow` on 443. Lower priority number = evaluated first. Priority 100 matches the TCP 443 packet (port `*` includes 443) and denies it. The allow rule at 300 is never reached.

**12. B — Stopped at guest OS level, allocated, compute charges continue.**

`PowerState/stopped` means the guest OS has shut down but Azure has not released the compute allocation. `PowerState/deallocated` indicates deallocation. This is the most commonly misunderstood VM state on the exam.

**13. C — Virtual Machine Contributor.**

Virtual Machine Contributor includes: start, stop, restart, resize, manage extensions, and disk operations on VMs. It excludes: creating/modifying VNets, NICs, NSGs (separate roles), and role assignments. Contributor (A) and Owner (B) are broader than needed.

**14. B — The UDR for `0.0.0.0/0 → VirtualAppliance 10.0.1.4` overrides the default Internet route.**

The effective route table shows the user route for `0.0.0.0/0` is `Active` with next hop `VirtualAppliance`. Azure uses this instead of the default `Internet` route because user-defined routes take precedence over default system routes. If `10.0.1.4` is unavailable or not forwarding, internet traffic is dropped.

**15. C — Acknowledge the alert, identify the root cause, then decide.**

Disk issues require investigation before action. Expanding disk resolves space but not the root cause (runaway logs, a full tmp partition, etc.). Deleting files without knowing their purpose risks data loss. Deallocating the VM causes an outage. Investigate first: `df -h`, check log directories, identify the largest consumers.

**16. A and C — Blob versioning not enabled on both accounts; replication policy/rule not correctly configured.**

Object replication prerequisites: blob versioning must be enabled on both source and destination accounts. The replication policy must include rules that match the source container and blob prefix. It is asynchronous (not synchronous zero-loss as stated in D). Identical names (B) and anonymous access (E) are not requirements.

**17. D — Deny.**

Deny prevents the resource from being created if it does not meet the policy condition. Audit (A) logs noncompliance without blocking. Modify (B) changes properties on existing or new resources but does not block. DeployIfNotExists (C) deploys a companion resource if one is missing.

**18. B — Zone-redundant storage (ZRS) for managed disks.**

ZRS for managed disks replicates the disk synchronously across three availability zones within the primary region. LRS (A) replicates within one datacenter. GRS (C) replicates to a secondary region. ZRS disks are available for Premium SSD, Standard SSD, and other supported disk types in supported regions.

**19. B — Stop. Do not deploy. Investigate the Bicep file before proceeding.**

`what-if` is a pre-flight check. Any unintended `Delete` must be resolved before deployment. Common causes: resource name/symbolic name changed, a resource block was removed, wrong scope. Deploying (A) would execute the deletion. Deleting manually (C) is unnecessary and harmful. A lock (D) would block the deployment but not fix the template.

**20. B — Cancel the swap preview; staging reverts to its original configuration automatically.**

The two-phase swap is designed for this scenario. Cancelling the preview rolls back the phase-1 changes to staging, restoring its original configuration. No data or slot is deleted. This is the safe exit path when startup validation fails during a preview.

**21. B — Existing tokens are immediately revoked when the user's permissions are removed.**

User delegation SAS tokens derive their authorization from the issuing user's Entra permissions at the time of each request. When those permissions are revoked, the token loses its authorization backing and requests are denied. This is a security advantage of user delegation SAS over account-key SAS (which cannot be revoked without key rotation).

*Trap:* Candidates assume SAS tokens have independent lifetimes. User delegation SAS is tied to the issuer's current permissions.

**22. B — The deployment is denied; Owner role does not override Azure Policy.**

Azure Policy operates at the resource management layer and applies to all principals regardless of RBAC role, including Owner and even Global Administrator for resource operations. The only ways to bypass a policy are: exemptions on specific resources/resource groups, or exclusions defined in the assignment scope.

**23. C — A read-only SAS scoped to the specific blob with a 2-hour expiry, HTTPS required.**

Least-privilege SAS: scope to the specific blob (not account or container), read-only permissions, 2-hour expiry matching the requirement, HTTPS required to prevent token interception in transit. An account key (A) grants full control. Account-level SAS with full permissions (B) is excessive. Contributor on the RG (D) is dramatically excessive.

**24. C — The application is not listening on TCP 443 inside the VM, or the guest OS firewall is blocking the port.**

`Connection refused` means the packet reached the OS but was rejected. If IP flow verify confirms `Allow`, the NSG is not the problem. The packet got through. Debug inside the VM: `ss -tlnp | grep 443` (Linux) or `netstat -ano` (Windows), and check `iptables`/`ufw` or Windows Firewall.

**25. A and C — Deny prevents noncompliant deployments; DeployIfNotExists deploys companion resources.**

Correct: (A) Deny blocks deployment. (C) DINE deploys a linked resource (e.g., diagnostic settings, Log Analytics agent) if missing on a new resource. Wrong: (B) Audit does not block. (D) policy assignments do inherit to child scopes. (E) Owner does not override Deny policy.

**26. C — 1 instance added; capacity becomes 10 (the maximum).**

Current capacity 9, rule requests +3 = 12. Maximum is 10. Autoscale caps at 10, adding only 1 instance. The rule quantity is a requested change, not a guaranteed result — the maximum boundary is always enforced.

**27. C — VPN Gateway or ExpressRoute, or Azure File Sync.**

TCP 445 (SMB) is frequently blocked by ISPs. Long-term solutions: (1) site-to-site VPN or ExpressRoute to carry SMB traffic privately without ISP interception, (2) Azure File Sync, which uses HTTPS (443) to sync a local Windows Server cache — on-premises clients access the local cache over LAN. Neither storage account name changes nor blob versioning affect TCP 445.

**28. C — The VM has not been enrolled in backup protection.**

An empty `az backup item list` output means no resources are protected by that vault. A vault with policies but no enrolled items protects nothing. The VM must be explicitly configured for backup (protection enabled). The vault can be in any region and still list protected items across regions.

**29. B — `"rg-prod"` (case-sensitive string match).**

KQL string comparisons are case-sensitive by default with `==`. The value must match exactly how the resource group name appears in the `AzureActivity` table (typically lowercase). Use `=~` for case-insensitive matching. Unquoted values (C) are treated as column references. `contains()` (D) is a function call, not a direct filter operator in this position.

**30. C — Link the existing private DNS zone to `vnet-dev`.**

The private DNS zone already has the correct A record. The problem is DNS zone visibility: the zone is linked only to `vnet-app`. Adding a VNet link from the zone to `vnet-dev` allows `vnet-dev` VMs to resolve the private IP. A new private endpoint (A) is unnecessary — the existing one serves both VNets once DNS is configured.

**31. C — The update is blocked; ReadOnly locks prevent write operations.**

ReadOnly locks block all write and delete operations. Tag updates are write operations on the resource. Contributor role does not override locks — locks apply to all authorized users. CanNotDelete locks allow writes but block deletion. This is a common exam scenario testing lock type selection.

*Trap:* The scenario says "prevent deletion" but a ReadOnly lock was applied — the wrong lock for the stated requirement. Always match lock type to the intent: CanNotDelete for deletion prevention, ReadOnly for change prevention.

**32. B — Regenerate key2 → migrate clients to key2 → validate → then regenerate key1.**

The safe alternating key rotation: always rotate the key that applications are NOT currently using. Migrate clients to the newly rotated key and validate. Then the formerly active key can be safely rotated later. Rotating the active key first (A) causes immediate authentication failures.

**33. B — Verify the identity resource ID in `--acr-identity` matches the identity with `AcrPull`, and registry DNS resolves correctly.**

The `--acr-identity` flag must reference the exact identity resource ID that holds the `AcrPull` role. A mismatch (wrong identity ID, incorrect principal) results in auth failure even though the role appears assigned correctly. Also verify the registry hostname is resolvable from the ACI service (relevant when using private endpoints or custom DNS).

**34. B — App's DNS resolution must use the VNet's DNS, and the private DNS zone must be linked to the integration VNet.**

VNet integration routes outbound traffic through the integration subnet, but DNS resolution still depends on configuration. By default, App Service uses Azure DNS. To resolve private endpoint FQDNs: configure the app to use the VNet's DNS server (or Azure DNS Private Resolver), and link the `privatelink.blob.core.windows.net` zone to the integration VNet. Without this, the app resolves the public CNAME chain.

**35. C — The container and its blobs can be recovered within the 14-day retention window.**

Container soft delete (enabled in this scenario) protects against accidental container deletion. The container and all its blobs are soft-deleted and remain recoverable for the retention period. Use Portal (Storage account → Data protection → Containers → Show deleted) or `az storage container restore`.

*Trap:* Option A is wrong — Azure does support container-level soft delete separately from blob-level soft delete.

**36. C — You must hold at least the role you are assigning at the target scope, in addition to the write permission.**

This is Azure RBAC's "elevation of privilege" prevention. Having `Microsoft.Authorization/roleAssignments/write` allows creating role assignment objects, but you cannot assign a role that grants more permissions than you yourself hold at that scope. This prevents privilege escalation. `roleDefinitions/read` (B) is included implicitly.

**37. B — Hub peering must enable `Allow gateway transit`; spoke peering must enable `Use remote gateways`.**

For on-premises routes (learned by the VPN Gateway in Hub) to propagate to a spoke via BGP: the Hub→Spoke peering must have `Allow gateway transit` enabled (Hub advertises its gateway to the spoke), and the Spoke→Hub peering must have `Use remote gateways` enabled (spoke accepts routes from Hub's gateway). Without both settings, the spoke learns no on-premises routes.

**38. A and C — System-assigned identity is tied to one resource's lifecycle; user-assigned identity can be attached to multiple resources.**

Correct: (A) system-assigned identity is created with and deleted with its parent resource. (C) user-assigned identity is an independent resource that can be attached to multiple VMs, Container Apps, etc. Wrong: (B) user-assigned identity is not deleted when detached. (D) system-assigned cannot be shared. (E) managed identities work with storage accounts (Blob Data roles).

**39. B — The Application Insights resource is not connected to the workspace or `requests` table is not receiving data.**

A syntactically valid query returning 0 rows for a populated metric always points to a data pipeline issue, not a query logic issue (when errors are confirmed externally). Check: Is Application Insights configured on the application (SDK or auto-instrumentation)? Is the Application Insights resource connected to the workspace being queried? Are requests being logged (check `requests | take 10` with no filter)?

**40. B — Budgets trigger notifications and actions but do NOT automatically stop or delete resources.**

Budget actions can invoke an Azure Function, Logic App, or send notifications, but the budget itself has no built-in VM stop capability. The Function must contain explicit logic (`az vm stop` or `az vm deallocate`) to act on resources. Budgets are a financial tracking and alerting tool, not an enforcement mechanism.

**41. B — Add the Key Vault resource to the template, or reference it with `existing`.**

ARM/Bicep requires all resources referenced by a deployment to either be defined within the same deployment scope or referenced using the `existing` keyword. If Key Vault was deployed in a prior step, use `resource keyVault 'Microsoft.KeyVault/vaults@...' existing = { name: kvName, scope: ... }` to reference it. Removing `dependsOn` (D) does not resolve the scope issue.

**42. B — Restrictive NSG rules may block AKS-required cluster-internal traffic.**

AKS requires specific ports open for: kubelet communication, etcd, API server, CNI plugin traffic, and pod-to-pod depending on the network plugin. An NSG with no explicit rules relies solely on the default `AllowVnetInBound` (65000) and `DenyAllInBound` (65500). If pod networking uses IPs outside the VNet CIDR (overlay), VNet NSG rules may block it. Review AKS NSG documentation for required rules before applying custom NSGs to AKS subnets.

**43. B — Azure RBAC Check access on the VM resource for the specific user.**

**Check access** on a resource (IAM blade → Check access → select user) evaluates all role assignments — direct assignments, assignments via group membership, and inherited assignments from parent scopes — and reports the effective permissions. `az ad group list` (A) only shows groups, not their access. Policy compliance (C) is unrelated to access. IP flow verify (D) tests network connectivity, not authorization.

**44. B — Check the NSG Activity Log for recent changes, then use IP flow verify — before making any changes.**

Structured troubleshooting: (1) Activity Log confirms whether a change was made and what it was. (2) IP flow verify tests whether the suspected NSG rule blocks the specific flow. Only after confirming the root cause should you apply a fix. Rebooting (A), deleting the NSG (C), or adding allow-all (D) are all premature and potentially harmful.

**45. A and E — OS disk (managed disk) and public IP are not automatically deleted.**

When deleting a VM through Portal, you can choose to also delete attached disks, NICs, and public IPs — but this requires explicit selection. By default, managed disks (OS and data), NICs, and public IPs persist after VM deletion and continue to be billed. The VM compute resource itself (B) is what is deleted. The guest OS (D) is on the OS disk which persists.

**46. B — The `rg-legacy` alert is suppressed; the `rg-prod` alert triggers normally.**

Alert processing rules apply to specific scopes. This rule is scoped to `rg-legacy`, so it only suppresses notifications for alerts from resources within that resource group. `rg-prod` resources are outside the rule's scope and their alerts proceed to the action group normally. Action group sharing between resources does not cause cross-scope suppression.

**47. B — Deny policy with `allowedLocations` at subscription scope.**

Azure Policy with allowed locations (`allowedLocations` parameter) is the standard, scalable, enforceable control for location restrictions. It blocks deployments to non-allowed regions at the ARM layer, applies to all principals regardless of RBAC role, and is automatically inherited by all resource groups and resources in the subscription. Training (A) is not enforceable. Locks (C) prevent changes but not regional deployment. Reader (D) prevents all resource creation.

**48. C — Update the Container App registry config to use the system-assigned identity; then disable the ACR admin user.**

The goal is identity-based pull without admin credentials. The Container App's registry entry must be updated to reference the managed identity for authentication (removing the admin username/password). After validating that pulls work with the identity, disable the ACR admin user to complete the security improvement.

**49. B — Cross-region restore can be enabled on the vault to allow paired-region access; not enabled by default.**

GRS vault replication copies backup data to the paired region, but cross-region restore (CRR) is an opt-in feature. When enabled, CRR allows you to restore to the secondary region during a primary region outage. Without CRR enabled, the backup data exists in the secondary region but is not directly accessible for restore during an outage.

**50. A and B — Deny assignments are created by specific services and cannot be freely created; they block actions even for holders of explicit allow roles.**

Correct: (A) most deny assignments are created by Azure Blueprints, managed applications, or other services — not directly by users via the Portal or CLI. (B) a deny assignment overrides allow role assignments at the same or parent scope — this is the key difference from role assignments. Wrong: (C) Contributors cannot freely create deny assignments. (D) deny assignments at a resource do override broader role assignments, but this is a consequence of (B), not a separate fact about scope ordering specifically. (E) is false — they interact directly through the RBAC evaluation model.
