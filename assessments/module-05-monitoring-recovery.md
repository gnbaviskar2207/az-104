# Module 05 checkpoint: monitoring and recovery

**Time:** 25 minutes  
**Target:** 12/15  
**Answer book:** [Open only after finishing](answers/module-05-monitoring-recovery-answers.md)

1. You need a near-real-time numeric CPU series for a VM. Which Azure Monitor data type should you inspect first?
   - A. Activity Log event only
   - B. Resource lock
   - C. Policy definition
   - D. Metric

2. You need to run KQL across collected VM events. Where should the data be sent?
   - A. NSG rule
   - B. Log Analytics workspace through the appropriate data collection/diagnostic configuration
   - C. Azure DNS zone
   - D. App Service slot

3. What does an Azure resource diagnostic setting do?
   - A. Creates a VM backup image
   - B. Assigns an Entra license
   - C. Configures VNet peering
   - D. Routes selected platform logs and metrics to supported destinations

4. Which KQL operator normally filters rows?
   - A. `deploy`
   - B. `where`
   - C. `extend-role`
   - D. `route`

5. An alert rule detects a condition. Which object defines notification or automation receivers?
   - A. Availability set
   - B. Private endpoint
   - C. Management group
   - D. Action group

6. During planned maintenance, existing alert rules should continue evaluating but notifications should be suppressed. What should you configure?
   - A. Storage SAS
   - B. Alert processing rule
   - C. Delete every alert rule
   - D. ReadOnly lock

7. Which capability provides curated performance and dependency views for monitored VMs?
   - A. Blob lifecycle management
   - B. Entra SSPR
   - C. Azure Policy initiative
   - D. VM insights

8. What is Connection Monitor designed to do?
   - A. Assign licenses
   - B. Continuously test and track network connectivity between selected endpoints
   - C. Rotate storage keys
   - D. Resize VM disks

9. Which vault is traditionally used for Azure VM Backup and Azure Site Recovery?
   - A. Key Vault
   - B. Backup vault only for every workload
   - C. Log Analytics workspace
   - D. Recovery Services vault

10. Before restoring a production VM, what should an administrator establish first?
    - A. The required recovery point, restore scope/method, target location, dependencies, and validation plan
    - B. A public blob container
    - C. Owner access for all users
    - D. A DNS MX record

11. A backup policy primarily defines what?
    - A. NSG priorities
    - B. VNet address space
    - C. Container image tags
    - D. Schedule and retention behavior for protected items

12. What is the safest purpose of an Azure Site Recovery test failover?
    - A. Rotate all storage keys
    - B. Replace backup retention
    - C. Validate recovery in an isolated network without interrupting ongoing replication/production
    - D. Permanently delete the source VM

13. After a planned or unplanned failover is committed, what operation prepares replication in the reverse direction?
    - A. Tag inheritance
    - B. Reprotect
    - C. Snapshot delete
    - D. Scale in

14. **Choose two.** Which statements are correct?
    - A. Backup targets point-in-time recovery.
    - B. Site Recovery targets workload continuity and orchestration.
    - C. Site Recovery makes backup unnecessary in all cases.
    - D. A metric alert stores every guest log automatically.
    - E. A test failover should use the production network by default.

15. You need centralized visibility into backup health, jobs, and alerts. Which approach is most appropriate?
    - A. Rely only on VM tags.
    - B. Create a public IP for each vault.
    - C. Use DNS aliases as health signals.
    - D. Configure Azure Backup monitoring/reporting and alert integration for the vaults.
