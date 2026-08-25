# Module 05 monitoring v2 — answer book

Open this only after completing the checkpoint with the timer running.

---

**1. B — `Heartbeat` is a guest-level record; platform diagnostic settings do not collect it.**

`Heartbeat` is written by the Log Analytics agent or Azure Monitor Agent (AMA) running **inside** the VM guest OS. Platform diagnostic settings route platform metrics (CPU, Disk IOPS from the hypervisor layer) and the Activity Log to a workspace — they cannot reach inside the guest. To populate `Heartbeat`, install AMA on the VM and associate a Data Collection Rule (DCR) that targets the workspace.

*Trap:* Candidates configure diagnostic settings carefully and assume all monitoring data flows through them. Platform and guest data collection use separate paths.

---

**2. B — Inspect the action group — verify it is attached, receiver is correct, and no alert processing rule is suppressing notifications.**

The alert fired correctly (confirmed by alert history). The notification pipeline is the problem. Check in order: (1) is an action group attached to the rule? (2) is the receiver email/webhook address correct? (3) is there an alert processing rule suppressing notifications for this scope/time window? Changing the metric condition is unnecessary because the condition is confirmed correct.

*Trap:* Candidates revisit the alert condition when the problem is downstream in the action group.

---

**3. C — Creating a policy does not protect a VM; the VM must be separately enrolled (protection enabled) with the policy.**

A backup policy defines the schedule and retention for a vault. It does not automatically protect any resource. Each VM must be individually enrolled in backup (via **Backup** → **Backup items** → **Configure backup** → select VM + policy). Until enrolled, no backup jobs run and no recovery points exist.

*Trap:* Candidates assume creating a policy activates protection for all VMs in scope. This is the most common backup misconception on the real AZ-104.

---

**4. C — The test VM may register in production DNS, contact live dependencies, or conflict with the source workload.**

An ASR test failover starts a copy of the protected VM. If started in the production VNet, the test VM gets an IP in the production subnet, may register with production DNS, contact production databases, and generate real traffic. Always use an **isolated test VNet** for test failovers. The test VM does not replace the production VM (production replication continues uninterrupted).

*Trap:* Candidates assume test failover is always safe regardless of network selection.

---

**5. C — Reprotect the VM — this establishes replication in the reverse direction.**

After committing a failover, the source VM (now the recovery region) is running but replication has stopped. To enable failback: reprotect the VM, which configures ASR to replicate from the recovery region back to the original source region. Only after reprotection is established can you perform a planned failback. Cleanup alone does not create reverse replication.

---

**6. A — The alert is silently evaluated; it fires internally but no notification or action is triggered.**

An alert rule without an action group will evaluate its condition and record a fired state in alert history, but no email, webhook, or automation is invoked. Azure does not automatically notify subscription owners or fallback contacts. This is a configuration oversight, not a system error.

---

**7. C — A scheduled alert processing rule scoped to `rg-maintenance` with the suppression window defined.**

Alert processing rules can suppress action group notifications for specific scopes (resource, resource group, subscription) during configured time windows, without deleting the alert rule or action group. Deleting or disabling the alert rule or action group would affect all resources, not just `rg-maintenance`. A ReadOnly lock has no effect on alert notifications.

---

**8. B and C — Azure Monitor Agent is not installed or unhealthy; a data collection rule is not associated with the VM.**

`Heartbeat` requires AMA running inside the VM and a DCR that includes the `Heartbeat` data source associated with the VM. Missing either (AMA not installed/healthy, or DCR not associated) results in no heartbeat records. Managed disk presence, availability zone, and storage keys are irrelevant to heartbeat collection.

---

**9. B — Stop protection and delete backup data, remove soft-deleted items, deregister containers, clean up ASR fabrics/mappings, remove private endpoints and locks, then delete the vault.**

Azure enforces a strict dependency order for vault deletion. Skipping any step causes a dependency error. The `--force` flag does not exist for vault deletion. Deleting the resource group without clearing vault dependencies will also fail because the vault still has active dependencies.

*Trap:* Candidates try to delete the vault directly or via resource group deletion and encounter repeated errors because they skip intermediate cleanup steps.

---

**10. A — Whether Entra sign-in logs are routed to the correct Log Analytics workspace, and whether the diagnostic setting includes that log category.**

A query can be syntactically correct and logically sound but return no data if the source logs are not flowing into the target workspace. Entra sign-in logs require a dedicated diagnostic setting configured in the **Microsoft Entra ID** blade (not the subscription or VM), and they must be directed to the same workspace the alert query targets. Managed disks, blob versioning, and storage keys are irrelevant.

---

**11. B — The issue may be in guest OS firewall, application listener, routing beyond the NIC, or PaaS-side network restrictions.**

IP flow verify tests whether an NSG rule allows or denies a sample flow at the NIC level. It does not validate: guest OS firewall, application listening state, routing beyond the VM's NIC, private endpoint connection state, or PaaS-side service firewalls. Connection Monitor captures end-to-end packet loss, which may reveal a layer IP flow verify cannot see.

*Trap:* IP flow verify showing `Allow` is commonly misinterpreted as full end-to-end connectivity confirmation.

---

**12. C — Restore disks from a recovery point to a staging storage account, then attach the restored disk to the VM.**

Azure Backup supports **Restore disks** as a granular recovery option. This restores selected disks to a staging storage account without touching the running VM. You can then create a snapshot or attach the restored VHD as a new data disk to the running VM for investigation or data retrieval.

*Trap:* Option A (not possible) is wrong — Azure Backup does support partial recovery via disk restore.

---

**13. B — A dynamic threshold alert learns the resource's historical behavior and adjusts the threshold automatically.**

Dynamic thresholds use machine learning on historical metric data to compute adaptive upper and lower bounds. As baseline CPU increases over time, the threshold adjusts, reducing false positives during normal-but-elevated activity. Static thresholds require manual tuning as workloads grow.

---

**14. C — `Perf`**

The `Perf` table stores performance counter data collected by Azure Monitor Agent or the legacy Log Analytics agent (MMA). VM Insights uses this table for disk, CPU, memory, and network performance visualizations. `Heartbeat` = agent liveness; `AzureActivity` = control-plane events; `SecurityEvent` = Windows security log.

---

**15. A and D — Recovery Services vault supports VM backup and ASR; Backup vault supports newer datasources. Both vault types apply to specific datasources depending on requirements.**

Correct: (A) Recovery Services vault is the established type for Azure VM backup, Azure Files, and ASR. Backup vault is the newer type for Azure Disks, Azure Blobs, Azure Database for PostgreSQL Flexible Server, and other newer datasources. (D) Azure Files is actually supported by Recovery Services vault — the datasource determines the vault type.

Wrong: (B) Backup vault does not support VM backup or ASR. (C) both vault types use backup policies. (E) Backup vault cannot be used for VM backup.
