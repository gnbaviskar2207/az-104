# Break-fix challenge solution book

Use these as diagnostic baselines, not scripts to run blindly. Azure resource IDs, supported SKUs, policies, and command surfaces vary. Open this file only after recording your own evidence.

## Identity and governance solutions

### 1 — Assignment scope no longer contains the VM

**Root cause:** Resource moves change the resource ID/resource-group ancestry. An assignment on `rg-compute` does not follow a VM moved to `rg-app`.

**Prove:** Use **VM > Access control (IAM) > Check access** and `az role assignment list --assignee <object-id> --all --include-inherited -o table`. Compare assignment scopes with `az vm show -g rg-app -n <vm> --query id -o tsv`.

**Fix:** Assign Virtual Machine Contributor to the group at `rg-app` or the VM scope, according to the required operating boundary; remove the obsolete assignment if unused. Validate Start/Stop and confirm the group still cannot create role assignments.

### 2 — Remediation identity lacks required permissions

**Root cause:** `modify`/`deployIfNotExists` remediation runs as the assignment's managed identity. Creating that identity does not automatically grant its required remediation roles.

**Prove:** Inspect Policy assignment identity, definition `roleDefinitionIds`, remediation/deployment errors, and role assignments at the assignment scope.

**Fix:** Grant only the role definitions required by the Policy at the correct scope, rerun remediation, and trigger/await a compliance scan. Do not assign Owner.

### 3 — ReadOnly is broader than deletion protection

**Root cause:** ReadOnly blocks control-plane writes even when RBAC allows them.

**Fix:** An authorized lock administrator removes ReadOnly and applies CanNotDelete if the actual requirement is only deletion prevention. Validate a harmless update, then prove a delete attempt is blocked. Locks and RBAC are separate authorization layers.

### 4 — Access is inherited through group membership

**Root cause:** Removing one direct role assignment does not remove group-derived or inherited assignments.

**Prove:** Use IAM **Check access**, group membership inspection, and role assignment listing with inherited assignments.

**Fix:** Remove the guest from the obsolete group or remove the inappropriate group assignment. Then block/delete the guest object according to retention policy. Offboarding must check direct assignments, nested/group memberships, privileged roles, application access, and active credentials.

### 5 — Budgets notify; they are not hard caps

**Root cause:** A budget evaluates cost and sends configured notifications or invokes configured actions. It does not automatically stop every resource.

**Fix:** Validate threshold configuration, forecast/actual basis, contacts/action groups, and delivery. Use approved automation for explicitly tagged nonproduction resources, plus Policy, quotas, schedules, and owner escalation. Require safeguards and dry-run inventory before any automatic stop.

## Storage solutions

### 6 — Reader is management-plane only

**Root cause:** Reader can view account configuration but lacks Blob `dataActions`.

**Fix:** Assign Storage Blob Data Reader at the container or account scope as required. Validate using Entra authentication such as `az storage blob list --auth-mode login`; allow time for RBAC propagation. Do not distribute account keys.

### 7 — SAS start time is ahead of service time

**Root cause:** Clock skew can make a token with an immediate start time temporarily invalid. Wrong service/resource scope or permissions can produce similar errors.

**Fix:** Prefer omitting the start time for immediate use or set it slightly in the past, keep expiry short, require HTTPS, and grant only read at the intended container/blob. Prefer a user-delegation SAS for Blob where practical. Keep the token in protected input/environment state and unset it after validation.

### 8 — Service endpoint or network rule is missing

**Root cause:** Public-endpoint VNet restriction needs both subnet service-endpoint configuration and an allowed storage VNet rule.

**Prove:** Inspect `az network vnet subnet show` service endpoints and `az storage account network-rule list`.

**Fix:** Add only the missing element, retain default Deny, and validate from both an allowed and a disallowed source.

### 9 — Private DNS is incomplete

**Root cause:** An approved endpoint does not automatically guarantee every client uses the correct private DNS answer.

**Fix:** Use `privatelink.blob.core.windows.net`, ensure the account A record points to the endpoint IP, link the client VNet, and configure conditional forwarding/private resolver behavior when custom DNS is used. Validate with `nslookup`/`dig` and a data request to the normal Blob hostname.

### 10 — The active shared key was regenerated first

**Root cause:** Clients using key1 immediately lose authentication after key1 changes.

**Fix:** Temporarily update the application to the valid key2 through a protected configuration path. For future rotation, regenerate the unused key, update and validate every consumer, then rotate the former key. Migrate to managed identity and data-plane RBAC to remove shared-key rotation from the application path.

## Virtual networking solutions

### 11 — Lower priority number Deny matches first

**Root cause:** NSG rules evaluate ascending priority number; first match wins.

**Fix:** Narrow the Deny source or place the required HTTPS Allow at a lower numeric priority. Validate with IP flow verify/effective rules and an actual application request. Do not use unrestricted source/destination/port rules.

### 12 — Peering is nontransitive

**Root cause:** Hub-to-spoke peerings do not make spokes transitively connected.

**Fix:** Directly peer the spokes when appropriate, or implement an NVA/gateway transit design with allow-forwarded-traffic, IP forwarding, UDRs, security controls, and symmetric return routes. Effective routes on both ends must show the intended next hop.

### 13 — Routing requires forwarding at every layer

**Root cause:** A UDR can deliver packets to an NVA, but the NIC and guest appliance must forward them and allow/NAT traffic as designed.

**Fix:** Enable NIC IP forwarding, enable OS forwarding, correct NVA firewall/NAT, and confirm return routing. Use packet capture/connection troubleshooting to prove both directions.

### 14 — Probe/listener/NSG are inconsistent

**Root cause:** The probe targets 80 while the app listens on 8080, and the NSG does not allow the probe source to 8080.

**Fix:** Point the probe to the real health port/path, allow the AzureLoadBalancer service tag to that port, confirm guest firewall/listener, and map the load-balancing rule to the correct backend port. Healthy status plus an application request are both required evidence.

### 15 — Peering does not link private DNS

**Root cause:** Private DNS zone VNet links are explicit and do not propagate through peering.

**Fix:** Link Spoke2 to the zone when the topology permits, or configure Azure DNS Private Resolver/custom DNS conditional forwarding. Validate the answer and application connection from both spokes.

## Compute, App Service, and container solutions

### 16 — Current allocation limits resize choices

**Root cause:** Resize options reflect the current cluster plus subscription/region/SKU constraints.

**Fix:** Check `az vm list-vm-resize-options`, quota, restrictions, accelerated networking/disk compatibility, and availability requirements. In an approved window, `az vm deallocate`, resize, and start. Validate size, boot, networking, and application health. Deallocation can affect dynamic addressing and causes downtime.

### 17 — Temporary disk is nondurable

**Root cause:** Temporary/local disk content can disappear during host events and redeployment.

**Fix:** Put authoritative data on a managed data disk or suitable PaaS data service and protect it with backup/replication appropriate to the RPO/RTO. Temporary disk is suitable only for disposable cache, paging/swap, or reproducible scratch data.

### 18 — Non-sticky settings move during swap

**Root cause:** Slot swaps exchange non-slot-specific configuration with content/routing behavior.

**Fix:** Restore the production connection securely, mark environment-specific settings as deployment-slot settings, validate dependencies in staging, review swap behavior, then swap and monitor. Keep secrets in Key Vault references where appropriate.

### 19 — Pull identity lacks a valid ACR authorization path

**Root cause:** Merely attaching an identity does not grant registry data access, or the Container App registry configuration references a different identity.

**Fix:** Confirm the principal/client/resource ID, grant `AcrPull` at the registry scope, and configure the app to use that identity for the registry. Wait for propagation and create a new revision. Keep the ACR admin user disabled.

### 20 — Refactoring changed ARM resource identity

**Root cause:** A name, scope, condition, or parent change causes ARM to see a new resource and an old resource no longer declared/managed as expected.

**Fix:** Do not deploy. Compare resource IDs, parameters, conditions, and module scopes. Reference the live resource with `existing` or preserve its name/identity when replacement is not intended. Validate and rerun what-if until destructive changes are explicitly approved.

## Monitoring, backup, and recovery solutions

### 21 — Platform routing is not guest collection

**Root cause:** Diagnostic settings route supported platform telemetry; guest `Heartbeat` generally requires Azure Monitor Agent and an associated data collection rule.

**Fix:** Verify AMA installation, DCR data sources/destination, DCR association, workspace ID, outbound connectivity, and agent health. Then query a suitable time range and confirm recent records for the VM resource ID.

### 22 — Detection works; action routing does not

**Root cause:** The condition is proven, so troubleshoot the action group/receiver or suppression path rather than changing thresholds.

**Fix:** Attach the intended enabled action group, validate receiver contact/webhook configuration, inspect alert processing rules and delivery status, and run the action-group test where supported. Document escalation and duplicate-notification behavior.

### 23 — A policy does not enroll a workload by itself

**Root cause:** The VM was never configured as a protected item using that policy.

**Fix:** Confirm vault region/support and VM eligibility, enable backup with the policy, run an on-demand backup, monitor the job to completion, and list the recovery point. Schedule plus retention applies only after protection is enabled.

### 24 — Test failover network is unsafe

**Root cause:** Test recovery instances should not normally share production connectivity because duplicate identities/services can act on live dependencies.

**Fix:** Clean up the test failover, create an isolated VNet with controlled validation access, repeat the test, collect evidence, and clean it up. Test failover validates without stopping replication; commit accepts a real failover recovery point; reprotect reverses replication for later failback.

### 25 — Vault dependencies remain

**Root cause:** Vault deletion is blocked until protection, retained/soft-deleted data, registrations, ASR configuration, endpoints, and locks are removed according to service rules.

**Fix:** Inventory Backup instances/items, jobs, soft-deleted items, containers/servers, private endpoints, locks, ASR fabrics/containers/mappings/policies, and cross-resource dependencies. Remove only confirmed lab data in the documented order, wait for asynchronous jobs, re-inventory, then delete the empty vault.

## Scoring

- 90–100: strong diagnostic readiness
- 80–89: ready after remediating missed evidence/prevention points
- 60–79: repeat the affected modules before another attempt
- Below 60: return to the guided Portal and CLI labs, then retry these challenges closed-book
