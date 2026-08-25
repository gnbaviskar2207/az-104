# AZ-104 advanced break-fix challenges (26–35)

These 10 challenges extend the original 25 with multi-layer failures, cross-domain root causes, and monitoring-led diagnosis. Complete the core module labs and all original 25 challenges before attempting these. Keep the [solution book](../assessments/answers/break-fix-challenges-answers.md) closed until you have recorded your full evidence.

## Rules (same as challenges 1–25)

- Use only a sandbox subscription and disposable resources.
- Inspect before changing anything. Record the symptom, at least two hypotheses, Portal evidence, CLI evidence, root cause, correction, validation, and preventive control.
- Award 4 points per challenge: root cause, evidence, least-privilege correction, and validation. Target 80/100.
- Do not solve a network problem by opening all traffic. Do not solve an access problem by assigning Owner.

---

## Challenge 26 — Three layers are broken and only one symptom is visible

**Domain:** Networking + RBAC + Private Endpoint  
**Complete after:** Labs 3, 10, 12, and 21

**Setup:** A developer was granted `Storage Blob Data Reader` on a storage account. The storage account has a private endpoint in `vnet-app` and the default firewall action is Deny. The developer's workstation is outside the VNet. The developer's VM is in `vnet-dev`, which is peered with `vnet-app`. The private DNS zone for blob is linked only to `vnet-app`.

**Symptom:** From `vm-dev` in `vnet-dev`, the developer receives an HTTP 403 when listing blobs.

**Tasks:**

1. List every possible cause of HTTP 403 from the VM (RBAC, network, DNS resolution, firewall). Do not assume only one cause.
2. Use `nslookup <account>.blob.core.windows.net` from `vm-dev`. Record whether you get the private IP or the public IP.
3. Use `az storage blob list` with the developer identity and record the exact error.
4. Confirm whether the private DNS zone is linked to `vnet-dev`.
5. Confirm whether `vnet-dev` is in the storage firewall's allowed network rules.
6. Fix all broken layers in order of dependency (DNS first, then network rule, then verify RBAC), and prove each fix independently before moving to the next.
7. Validate that the developer can list and read blobs from `vm-dev` and that no access exists from outside the VNet.

---

## Challenge 27 — Blob upload succeeds but reads fail for the same identity

**Domain:** Storage — data plane role mismatch  
**Complete after:** Labs 6, 7

**Setup:** A managed identity is assigned `Storage Blob Data Contributor` on a storage account. An application uses the identity to upload blobs successfully. A second application path tries to read a blob and receives HTTP 403.

**Symptom:** Same identity, same storage account, same container — writes work, reads fail.

**Tasks:**

1. List the permissions included in `Storage Blob Data Contributor`. Use `az role definition show --name "Storage Blob Data Contributor" --query permissions`.
2. Compare with `Storage Blob Data Reader`. Identify whether `DataActions` include both read and write for Contributor.
3. If Contributor includes read actions, identify what else could cause selective 403 on reads. Consider: container-level access policy, SAS restrictions on the read path, network rules applying selectively, or a code path using a different identity for reads.
4. Inspect the application code or configuration — does the read path use the same identity, or does it fall back to an anonymous or key-based request that is now blocked?
5. Correct the root cause and validate that the same identity can upload and download the same blob.

---

## Challenge 28 — Alert fires every 2 minutes with no actual threshold breach

**Domain:** Monitoring — stateless alert misconfiguration  
**Complete after:** Lab 20

**Setup:** A metric alert is configured on a VM with condition `CPU > 50%` evaluated every 1 minute over a 1-minute aggregation window. The VM's CPU is consistently at 45%. The alert history shows `Fired` entries every 2 minutes.

**Symptom:** The alert fires repeatedly despite CPU being below threshold. Operators receive hundreds of notifications per day.

**Tasks:**

1. Examine the alert rule configuration. Verify the threshold, aggregation type (average/max/min), evaluation frequency, and aggregation period.
2. Determine whether the alert uses a **stateless** configuration (fires on every evaluation that meets the condition) versus a **stateful** configuration (fires once on breach, resolves when condition clears).
3. Check the exact CPU data points in the metrics chart for the 1-minute granularity. Are there brief spikes above 50% that the 1-minute window is catching?
4. Examine whether an alert processing rule is re-triggering suppressed alerts.
5. Design a corrective configuration: adjust the aggregation period (e.g., 5 minutes average) so brief spikes do not trigger, and ensure the alert is configured as stateful where supported.
6. Validate that the alert does not fire during normal CPU at 45% for 30 minutes after your fix.

---

## Challenge 29 — Bicep deployment deletes and recreates a storage account

**Domain:** Compute/IaC — Bicep naming and `existing` resource reference  
**Complete after:** Lab 14

**Setup:** A team refactored a Bicep file. A symbolic name for the storage account changed from `storageAccount` to `primaryStorage`. The `name` property remains the same. The `what-if` output shows `Delete` for the old resource and `Create` for a new one.

**Symptom:** Running `az deployment group deploy` would delete the production storage account and recreate it — causing data loss.

**Tasks:**

1. Run `az deployment group what-if` and record the full output. Identify which resource is planned for deletion.
2. Examine the Bicep file. Confirm that only the symbolic name changed, not the `name` property (the actual Azure resource name).
3. Explain why ARM plans a delete-and-create despite the resource name being unchanged. *(Hint: ARM tracks resources by resource ID within a deployment, not by symbolic name.)*
4. Determine whether the correct fix is: (a) reverting the symbolic name to the original, (b) using `existing` to reference the storage account without re-deploying it, or (c) incremental deployment mode behavior.
5. Stop the deployment. Apply the correct fix. Rerun `what-if` and confirm no destructive change is planned.
6. Deploy successfully. Validate that the existing storage account data and configuration is intact.

---

## Challenge 30 — VM boots, application is unreachable: three-layer diagnosis

**Domain:** Networking + Compute — multi-layer connectivity  
**Complete after:** Labs 10, 15, 20

**Setup:** A web application on a Linux VM is unreachable on TCP 443. The NSG allows TCP 443 from Internet. The VM shows `Running` in Azure. The VM's public IP is responding to ping (ICMP).

**Symptom:** External browsers get `ERR_CONNECTION_REFUSED` on HTTPS. `nc -zv <ip> 443` returns `Connection refused`.

**Tasks:**

1. Confirm the NSG state. Use IP flow verify for TCP 443 inbound. Record the result.
2. SSH into the VM. Run `ss -tlnp | grep 443`. If the application is not listening, identify why (service not started, wrong port configured, TLS certificate issue).
3. Check the guest OS firewall: `sudo iptables -L -n` or `sudo ufw status`. Determine whether port 443 is allowed at the OS level.
4. Check application logs (`journalctl -u nginx` or equivalent) for startup errors.
5. Map the exact layer where the connection is refused and fix only that layer. Do not add allow-all NSG rules.
6. Validate end-to-end: external HTTPS request succeeds, and the NSG remains correctly scoped.

---

## Challenge 31 — Forgotten VMSS causes unexpected cost spike

**Domain:** Compute + Cost — autoscale without upper bound  
**Complete after:** Labs 16, and guide 05 (monitoring)

**Setup:** A VMSS was deployed for a load test last month. Autoscale is enabled with no maximum configured. The load test is finished but the VMSS was not deleted. A metric from an external system still sends requests. Autoscale has scaled the VMSS to 47 instances. A budget alert fires at 90%.

**Symptom:** The team receives a budget alert and discovers 47 unexpected VM instances running. The cost has already exceeded this month's budget.

**Tasks:**

1. Identify the VMSS using `az vmss list -o table`. Find the one with unexpected instance count.
2. Check the autoscale profile: `az monitor autoscale show`. Confirm whether a maximum is set.
3. Determine the source of the scale-out trigger. Inspect autoscale history and the metric source (is it external traffic, a misconfigured metric, or an internal loop?).
4. Safely scale down the VMSS to 0 instances (or delete it if confirmed lab-only). Do not affect other VMs.
5. Implement corrective controls: set autoscale maximum, create a budget action that notifies on 50% overage, and propose a governance policy that requires maximum instance count on all VMSS autoscale profiles.
6. Estimate the cost impact and document which resource tagging was missing that delayed discovery.

---

## Challenge 32 — ASR test failover contaminates production DNS

**Domain:** Monitoring + Recovery — ASR test failover in wrong network  
**Complete after:** Lab 23

**Setup:** An ASR test failover was started for `vm-api` into the production VNet `vnet-prod`. The test VM received the IP `10.1.0.25`. DNS is Azure DNS for the VNet with an A record `api.internal → 10.1.0.10` (production VM). The test VM registered itself in DNS as `api-testfailover.internal → 10.1.0.25`.

**Symptom:** Internal services resolving `api.internal` still get the correct production IP, but the test VM is receiving some traffic from services that resolved the test hostname. The test VM has no production firewall rules and is exposing the service endpoint unprotected.

**Tasks:**

1. Stop the test failover immediately without committing it. Record the ASR test failover cleanup procedure.
2. Document what damage occurred: which services contacted the test VM, what data (if any) was processed by the unprotected test endpoint.
3. Create an isolated test VNet with no connectivity to production services. Define its address space and confirm no overlap with `vnet-prod`.
4. Re-run the test failover using the isolated test VNet. Validate that the test VM is not reachable from production services.
5. Document the difference between test failover, planned failover, unplanned failover, commit, reprotect, and failback. Include when each should be used.

---

## Challenge 33 — Container App cannot pull from ACR after private endpoint is added

**Domain:** Containers + Networking + DNS — multi-layer  
**Complete after:** Labs 12, 18

**Setup:** A Container App was pulling images from `myregistry.azurecr.io` successfully. A private endpoint was added to the ACR. The Container App's managed environment is in a VNet. The private DNS zone `privatelink.azurecr.io` is created and linked to the Container App's VNet. The ACR public network access is now disabled.

**Symptom:** New Container App revisions fail to start with `image pull: unauthorized` or `name resolution failed`.

**Tasks:**

1. From within the Container App's VNet (deploy a test VM), run `nslookup myregistry.azurecr.io`. Record whether you get the private IP or the public IP.
2. If DNS resolves incorrectly, inspect the private DNS zone: verify the zone name is exactly `privatelink.azurecr.io`, verify the A record points to the private endpoint IP, and verify the zone is linked to the Container App's VNet.
3. Check the ACR private endpoint connection state — is it `Approved` or `Pending`?
4. Verify that the Container App's managed identity has `AcrPull` on the registry (not just attached, but correctly wired in the registry config of the Container App).
5. After fixing DNS, verify pull succeeds by deploying a new revision. Confirm that public network access disabled on ACR does not break the private pull path.

---

## Challenge 34 — KQL alert query returns no data silently: three-cause investigation

**Domain:** Monitoring — data pipeline diagnosis  
**Complete after:** Lab 20, 21

**Setup:** An alert rule runs the following KQL query every 5 minutes:

```kql
Heartbeat
| where TimeGenerated > ago(5m)
| where Computer == "vm-prod"
| summarize count()
```

The alert condition is `count < 1` (fires when no heartbeat). The VM is running. The alert never fires despite confirmed connectivity issues that lasted 2 hours.

**Symptom:** The alert never triggered even during a 2-hour outage when `vm-prod` was not sending heartbeats.

**Tasks:**

1. Query the workspace directly: `Heartbeat | where Computer == "vm-prod" | take 10`. Record whether any rows exist.
2. If no rows exist, check Azure Monitor Agent health on the VM. Look for AMA extension status in the Portal (VM → Extensions and applications).
3. Check the DCR: `az monitor data-collection rule list`. Verify a DCR with a `Heartbeat` data source is associated with the VM.
4. If AMA is healthy and DCR is associated but still no data, verify the workspace resource ID in the DCR matches the workspace being queried.
5. Identify a second possible cause: the alert query uses `count < 1`, but if the workspace receives **no data at all** for that computer, `summarize count()` returns 0 rows (not a row with count=0). Verify whether the alert condition evaluates correctly for an empty result set. Adjust if necessary (e.g., use `count() == 0` with `| summarize count()` and check threshold behavior for empty results).
6. Fix all identified causes, validate that `Heartbeat` records appear, and test the alert by stopping the AMA service briefly and confirming the alert fires.

---

## Challenge 35 — Vault deletion is blocked by a hidden dependency chain

**Domain:** Monitoring + Recovery — vault cleanup ordering  
**Complete after:** Labs 22 and 23

**Setup:** A sandbox Recovery Services vault named `rsv-lab` needs to be deleted at the end of the lab. The Portal returns: `Cannot delete vault. Vault has existing backup items and/or ASR configurations.`

**Symptom:** The vault cannot be deleted despite the team believing they removed everything.

**Tasks:**

1. Check backup items: `az backup item list --vault-name rsv-lab --resource-group rg-lab --backup-management-type AzureIaasVM`. Record all protected items.
2. Stop protection and delete backup data for each item. Note that soft-deleted items must be undeleted first, then re-deleted with `--delete-backup-data true`.
3. Check for soft-deleted items in the Portal (Backup Items → filter for soft deleted state). Undelete each, then stop protection with data deletion.
4. Check registered containers: `az backup container list --vault-name rsv-lab --resource-group rg-lab --backup-management-type AzureIaasVM`. Unregister any remaining containers.
5. Check ASR: Portal → Site Recovery → Replicated items. Remove all replicated items, then remove replication infrastructure (containers, fabrics) in order. Verify ASR infrastructure is fully removed.
6. Check for private endpoints on the vault and delete them.
7. Check for resource locks on the vault or its resource group and remove them.
8. Delete the vault: `az backup vault delete --name rsv-lab --resource-group rg-lab --yes`.
9. Document the exact dependency removal order so the team can follow it without errors next time.

---

## Completion gate

Score at least 80/100 across challenges 26–35 (same 4-point rubric as challenges 1–25). For every challenge where you lost a root-cause or validation point, repeat after 48 hours with no notes. A challenge is only complete when you can explain the multi-layer failure from memory and articulate why each layer needed to be fixed in the order you fixed it.
