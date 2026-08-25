# AZ-104 break-fix troubleshooting challenges

These 25 challenges test diagnosis rather than command copying. Complete the related core module first. Keep the [solution book](../assessments/answers/break-fix-challenges-answers.md) closed until you have recorded evidence and a proposed correction.

## Rules

- Use only a sandbox subscription and disposable resources.
- Inspect before changing anything.
- Record the symptom, at least two hypotheses, Portal evidence, CLI evidence, root cause, correction, validation, and preventive control.
- Do not solve a control-plane problem by assigning Owner or solve a network problem by opening all traffic.
- Use `--help` and Microsoft Learn, but do not copy from the core lab during the first attempt.
- Award 4 points per challenge: root cause, evidence, least-privilege correction, and validation. Target 80/100.

## Identity and governance

### Challenge 1 — The assignment exists, but access fails

**Setup:** A group has Virtual Machine Contributor on `rg-compute`. A member tries to start a VM in `rg-app`, where the VM was moved yesterday.

**Symptom:** The Portal shows the VM, but Start returns an authorization error.

**Tasks:** Determine the effective assignment scope, identify what changed during the move, and restore only the required access. Prove the result through IAM **Check access** and Azure CLI.

### Challenge 2 — Policy remediation completes without changing resources

**Setup:** A `modify` Policy assignment should add an `environment` tag. Existing resources remain noncompliant after a remediation task runs.

**Symptom:** The remediation deployment reports authorization failures.

**Tasks:** Inspect the assignment identity, required role definitions, assignment scope, and remediation deployments. Correct the authorization without granting Owner.

### Challenge 3 — An administrator cannot update a locked resource

**Setup:** A ReadOnly lock was applied to a production resource group to prevent deletion.

**Symptom:** An authorized Contributor cannot update a web app setting or tag.

**Tasks:** Explain why RBAC does not solve the problem, choose the narrower lock for the stated requirement, and validate that updates work while deletion remains blocked.

### Challenge 4 — A departed guest still has access

**Setup:** A guest's direct resource-group role assignment was removed.

**Symptom:** IAM **Check access** still reports Reader through a group inherited from subscription scope.

**Tasks:** Trace every access path, remove only the obsolete membership/assignment, and define an offboarding check that prevents recurrence.

### Challenge 5 — The budget threshold did not stop a VM

**Setup:** A subscription budget reached 100% overnight.

**Symptom:** The VM continues running and cost continues accumulating.

**Tasks:** Explain the expected budget behavior, confirm whether notifications/actions ran, and propose a controlled cost-response design that does not risk stopping production indiscriminately.

## Storage

### Challenge 6 — Reader can see the account but not its blobs

**Setup:** A user has Reader on a storage account.

**Symptom:** The user can inspect account properties but receives an authorization error when listing a private container.

**Tasks:** Distinguish management-plane and data-plane authorization, assign the narrowest suitable Blob role, wait for propagation, and validate without using an account key.

### Challenge 7 — A newly generated SAS is rejected

**Setup:** A read-only SAS has a 30-minute expiry and a start time equal to the administrator workstation's current time.

**Symptom:** The service reports that the SAS is not yet valid.

**Tasks:** Investigate UTC clock skew, token scope, protocol, permissions, and expiry. Generate a safer test token without displaying it in logs or source control.

### Challenge 8 — The allowed subnet cannot reach Storage

**Setup:** The storage firewall default action is Deny. A subnet appears in the intended design but traffic to the public Blob endpoint fails.

**Symptom:** DNS returns a public service IP and requests receive a network authorization error.

**Tasks:** Determine whether the Microsoft.Storage service endpoint and storage virtual-network rule both exist. Correct only the missing component and validate from a VM in the subnet.

### Challenge 9 — A private endpoint resolves publicly

**Setup:** A Blob private endpoint has a private IP and an approved connection.

**Symptom:** `nslookup <account>.blob.core.windows.net` from the client VM returns the public endpoint.

**Tasks:** Inspect the private DNS zone name, A record, VNet link, and client DNS path. Correct resolution and prove that the normal Blob FQDN returns the private IP.

### Challenge 10 — Key rotation caused an outage

**Setup:** An application still uses storage account key1. An administrator regenerated key1 before changing the application.

**Symptom:** All application storage requests fail authentication.

**Tasks:** Restore service using the unaffected key, design the correct alternating-key rotation, and plan migration to managed identity. Do not print either key in the incident record.

## Virtual networking

### Challenge 11 — A specific Allow rule does not win

**Setup:** An NSG has `Deny-Internet-Inbound` priority 200 and `Allow-HTTPS` priority 300.

**Symptom:** Internet clients cannot reach TCP 443.

**Tasks:** Use effective security rules or IP flow verify to prove the first match, correct the priorities or sources without adding an Any/Any rule, and retest.

### Challenge 12 — Two spokes cannot communicate

**Setup:** Spoke1 and Spoke2 are each peered with Hub. Both peerings show Connected.

**Symptom:** A VM in Spoke1 cannot reach a VM in Spoke2.

**Tasks:** Explain peering transitivity, inspect effective routes, and design either direct peering or hub transit through an authorized NVA/gateway with the required forwarding and UDR settings.

### Challenge 13 — Traffic reaches the NVA and stops

**Setup:** A subnet UDR sends `0.0.0.0/0` to virtual appliance `10.0.1.4`.

**Symptom:** The source VM's effective route is correct, but no traffic leaves the NVA.

**Tasks:** Inspect NIC IP forwarding, guest OS forwarding, NVA firewall/NAT behavior, and return routing. Correct the missing forwarding layer and capture before/after evidence.

### Challenge 14 — Every load-balancer backend is unhealthy

**Setup:** A Standard Load Balancer probes TCP 80, but the application listens on 8080. The NSG allows 8080 only from the Internet.

**Symptom:** Both backend instances show unhealthy and receive no new flows.

**Tasks:** Align the probe with the listener, allow the Azure LoadBalancer service tag where required, inspect the guest firewall, and validate the rule's frontend/backend ports.

### Challenge 15 — A private DNS record works from only one VNet

**Setup:** A private DNS zone is linked to Spoke1. Spoke2 is peered with Spoke1 and Hub.

**Symptom:** Spoke1 resolves the private name; Spoke2 returns NXDOMAIN or a public answer.

**Tasks:** Explain why peering does not automatically link private DNS, inspect custom DNS forwarding if used, and add the minimum required link or resolver configuration.

## Compute, App Service, and containers

### Challenge 16 — The desired VM size is missing

**Setup:** A running VM must resize to a supported SKU, but the SKU is not listed.

**Symptom:** The Portal and `az vm list-vm-resize-options` show only a subset of regional sizes.

**Tasks:** Check quota, regional/SKU restrictions, disk/network compatibility, and current-cluster availability. If appropriate, deallocate, resize, start, and verify the new size and service health.

### Challenge 17 — Application data disappeared after maintenance

**Setup:** A developer stored authoritative data on the VM temporary disk.

**Symptom:** The data disappears after redeployment or host maintenance.

**Tasks:** Identify the storage durability mistake, attach/use an appropriate managed data disk or PaaS store, restore from a valid backup if one exists, and document what belongs on temporary storage.

### Challenge 18 — Production received staging configuration

**Setup:** A database connection setting was added to the staging slot but not marked as a deployment-slot setting.

**Symptom:** After swap, production uses the staging database.

**Tasks:** Identify which settings moved, restore the production value securely, mark environment-specific settings as slot-sticky, and run a swap preview/validation procedure.

### Challenge 19 — Container Apps cannot pull from ACR

**Setup:** A Container App has a user-assigned identity, but its revision fails with an image-pull error.

**Symptom:** ACR authentication is denied.

**Tasks:** Verify the identity attached to the app, the registry configuration, and the `AcrPull` assignment scope/principal. Correct the identity-based pull without enabling the ACR admin user.

### Challenge 20 — Bicep what-if proposes unexpected deletion

**Setup:** A resource symbol/name or conditional parameter changed during refactoring.

**Symptom:** What-if shows Delete for the existing production resource and Create for a replacement.

**Tasks:** Stop the deployment, identify the identity/name change, preserve the existing resource where required by using consistent naming or `existing`, and rerun validation/what-if until no unintended destructive change remains.

## Monitoring, backup, and recovery

### Challenge 21 — Diagnostic settings exist, but `Heartbeat` is empty

**Setup:** VM platform metrics and Activity Log data are reaching a workspace through diagnostic settings.

**Symptom:** The `Heartbeat` table has no records for the VM.

**Tasks:** Explain why platform diagnostic settings do not collect all guest data. Inspect Azure Monitor Agent, data collection rule, destination, association, and VM connectivity.

### Challenge 22 — The alert fired silently

**Setup:** A CPU alert shows Fired in alert history.

**Symptom:** No operator received a notification.

**Tasks:** Inspect the alert rule's action group, receiver status, common alert schema/webhook behavior, alert processing rules, and notification delivery evidence. Fix the action path without changing the metric condition unnecessarily.

### Challenge 23 — A VM has no recovery points

**Setup:** A backup policy exists in a Recovery Services vault.

**Symptom:** The VM is absent from Backup instances and no recovery points exist.

**Tasks:** Explain why creating a policy does not protect a VM, enable protection with the intended policy, run an on-demand backup, and verify the job and recovery point.

### Challenge 24 — Test failover risks duplicate production traffic

**Setup:** An ASR test failover was started into the production VNet.

**Symptom:** The test VM may register production DNS, contact dependencies, or conflict with the source workload.

**Tasks:** Stop and clean up the test safely, create an isolated test network, repeat the validation, and document the difference between test failover, failover, commit, reprotect, and failback.

### Challenge 25 — A vault cannot be deleted

**Setup:** An administrator removed visible backup items and tries to delete the vault.

**Symptom:** Azure reports remaining dependencies.

**Tasks:** Inventory protected items, stopped items with retained data, soft-deleted items, registered containers, private endpoints, ASR fabrics/mappings, and locks. Remove only lab dependencies in the correct order and verify the vault is empty before deletion.

## Completion gate

Do not count a challenge as complete merely because the symptom disappeared. Your evidence must show the causal control changed and the intended security/reliability property still holds. Score at least 80/100, then repeat every challenge that lost a root-cause or validation point after 48 hours.
