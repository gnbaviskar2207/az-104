# Module 05 checkpoint v2: monitoring and recovery — trap edition

**Time:** 25 minutes  
**Target:** 12/15  
**Answer book:** [Open only after finishing](answers/module-05-monitoring-v2-answers.md)

> Every question in this set uses deliberate wording traps found in the real AZ-104 exam.
> Read each scenario constraint carefully before selecting an answer.

1. A diagnostic setting is configured on a VM to send **platform metrics** and **Activity Log** to Log Analytics. The `Heartbeat` table in the workspace is empty. What is the most likely reason?

   - A. The diagnostic setting must be recreated with a different destination.
   - B. `Heartbeat` is a guest-level metric; platform diagnostic settings do not collect it. Azure Monitor Agent with a data collection rule is required.
   - C. Log Analytics only stores metrics, not heartbeat records.
   - D. The VM must be restarted for diagnostic settings to activate.

2. An Azure Monitor alert rule fires and appears in the alert history with status **Fired**. No notification email was received. The metric condition and evaluation period are correct. What should you inspect **first**?

   - A. The metric chart, to verify the condition threshold is appropriate.
   - B. The action group associated with the alert rule — verify it is attached, the receiver email address is correct, and no alert processing rule is suppressing notifications.
   - C. The Log Analytics workspace linked to the subscription.
   - D. The diagnostic setting on the resource.

3. A backup policy is created in a Recovery Services vault for daily backups with 30-day retention. The next day, there are no recovery points for a VM. What is the most likely explanation?

   - A. The vault must be in the same region as the Log Analytics workspace.
   - B. A backup policy must be paired with a diagnostic setting.
   - C. Creating a policy does not protect a VM; the VM must be separately enrolled in backup (protection enabled) with the policy.
   - D. Recovery points take 48 hours to appear after policy creation.

4. An ASR test failover is initiated. The test VM is started in the **production VNet**. What risk does this introduce?

   - A. The test VM will permanently replace the production VM.
   - B. The production VM will be deallocated automatically.
   - C. The test VM may register in production DNS, contact live dependencies, or conflict with the source workload — test failovers must use an isolated test network.
   - D. Test failover is safe in any network because ASR isolates test VMs by default.

5. An ASR failover is committed for a VM. The team now wants to return the workload to the original region. What is the correct next step before failback is possible?

   - A. Delete the recovery plan and create a new one.
   - B. Run another test failover.
   - C. Reprotect the VM — this establishes replication in the reverse direction, from the recovery region back to the source region.
   - D. Enable soft delete on the Recovery Services vault.

6. A VM metric alert is configured with **evaluation frequency every 1 minute** and **aggregation period 5 minutes**. The alert rule has **no action group**. CPU spikes above the threshold. What happens?

   - A. The alert is silently evaluated; it fires internally but no notification or action is triggered.
   - B. Azure automatically sends an email to the subscription owner.
   - C. The alert rule is automatically disabled without an action group.
   - D. Azure Advisor generates a recommendation instead.

7. Operations wants to suppress alert notifications for `rg-maintenance` only, every Sunday between 02:00 and 04:00, without deleting the alert rule or action group. Which feature achieves this?

   - A. Deleting the action group on Saturdays and recreating it on Sundays.
   - B. Disabling the alert rule during the maintenance window.
   - C. A scheduled alert processing rule scoped to `rg-maintenance` with the suppression window defined.
   - D. A ReadOnly lock on the resource group.

8. You query:

   ```kql
   Heartbeat
   | where TimeGenerated > ago(1h)
   | summarize LastHeartbeat = max(TimeGenerated) by Computer
   ```

   The query returns no rows for `vm-prod`, but the VM is running. Which two causes are most likely? **Choose two.**

   - A. The VM has no managed disk attached.
   - B. Azure Monitor Agent is not installed or is unhealthy on the VM.
   - C. A data collection rule is not associated with the VM.
   - D. The VM is in a different availability zone.
   - E. The storage account key has been rotated.

9. A Recovery Services vault must be deleted, but the Portal returns an error citing remaining dependencies. Which sequence is correct?

   - A. Delete the vault directly using the `--force` flag.
   - B. Stop protection and delete backup data for all items, remove soft-deleted items, deregister containers, clean up ASR fabrics/mappings, remove private endpoints and locks, then delete the vault.
   - C. Delete the resource group containing the vault without touching the vault directly.
   - D. Reassign the vault to a different subscription to bypass the dependency check.

10. A Log Analytics alert query runs every 5 minutes and is expected to count failed login events, but it never fires despite confirmed failures appearing in sign-in logs. What should you verify?

    - A. Whether the Entra sign-in logs are being routed to the correct Log Analytics workspace, and whether the DCR/diagnostic setting is configured to include that log category.
    - B. Whether the storage account key is correct.
    - C. Whether the VM has a managed disk.
    - D. Whether blob versioning is enabled on the workspace storage account.

11. A Network Watcher **Connection Monitor** test shows packet loss between a VM and a PaaS endpoint. **IP flow verify** on the source VM shows `Allow` for the destination. What is a likely remaining cause?

    - A. IP flow verify covers all layers; no further investigation is needed.
    - B. The NSG evaluation is correct but the issue may be in guest OS firewall, application listener, routing beyond the NIC, or PaaS-side network restrictions not visible to IP flow verify.
    - C. Connection Monitor is not compatible with PaaS endpoints.
    - D. IP flow verify results are delayed by 24 hours.

12. A VM is protected by Azure Backup. A disk is accidentally deleted. The team wants to restore **only the deleted disk** without replacing the entire VM. Which restore option provides this?

    - A. This is not possible; Azure Backup only restores entire VMs.
    - B. Restore files and folders from the backup agent.
    - C. Restore disks from a recovery point to a staging storage account, then attach the restored disk to the VM.
    - D. Use ASR failover to recover the disk.

13. An alert rule uses a **static threshold**. The resource's normal CPU baseline increases over time due to organic growth. Alerts start firing during peak-but-normal business hours. Which alert type better handles this pattern?

    - A. Platform metric alert with a lower static threshold.
    - B. A dynamic threshold alert, which learns the resource's historical behavior and adjusts the threshold automatically.
    - C. Deleting the alert rule during business hours.
    - D. An alert processing rule that suppresses all alerts permanently.

14. A VM Insights workbook shows degraded disk performance. Which Log Analytics table contains the underlying performance counter data collected by Azure Monitor Agent?

    - A. `Heartbeat`
    - B. `AzureActivity`
    - C. `Perf`
    - D. `SecurityEvent`

15. **Choose two.** Which statements correctly describe the difference between a Recovery Services vault and a Backup vault?

    - A. Recovery Services vault supports Azure VM backup and Azure Site Recovery; Backup vault supports newer datasources like Azure Disks, Blobs, and PostgreSQL flexible server.
    - B. Backup vault supports VM backup and ASR just like Recovery Services vault.
    - C. Recovery Services vault uses backup policies; Backup vault uses no policies.
    - D. Both vault types can be used for Azure Files backup, but the underlying datasource determines which vault type is required.
    - E. Backup vault is always the preferred choice for Azure VM backup.
