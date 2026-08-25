# Case Study 3 — Northwind regional recovery

**Time:** 25 minutes  
**Target:** 8/10  
**Answers:** [Open after completion](answers/03-northwind-recovery-answers.md)

## Architecture

Northwind runs two application VMs behind a Standard Load Balancer in `eastus2`. Application files use a Storage account. A Log Analytics workspace receives some telemetry. The company is introducing formal backup and disaster-recovery operations.

## Requirements

- The web tier must tolerate failure of one availability zone.
- Blob data should remain available after a primary-zone failure and have a readable copy in the paired/secondary region before account failover, where the chosen account type supports it.
- VM recovery points must be retained according to daily/monthly requirements.
- Administrators must prove a VM can be restored without overwriting production.
- Critical VMs require orchestrated regional continuity through Site Recovery.
- Disaster-recovery testing must not send traffic to production dependencies.
- Operations must be notified of failed backups and replication-health problems.
- Guest OS logs and performance data must be queryable.
- During planned maintenance, alert evaluation continues but notifications for the affected resource group are suppressed.
- Recovery evidence must include jobs, recovery points, restore validation, and test-failover cleanup.

## Current state

- Both VMs are in one availability zone.
- Storage uses LRS.
- A Recovery Services vault and daily policy exist, but the VMs are not protected.
- A resource diagnostic setting sends platform metrics to Log Analytics, but `Heartbeat` is empty.
- A CPU alert has email configured directly in an obsolete process; no tested action group exists.
- ASR replication is healthy for one VM, but the test-failover network is the production VNet.

## Questions

1. What change meets the web-tier zone-failure requirement?
   - A. Put both VMs in one availability set.
   - B. Distribute redundant VM or VMSS instances across supported availability zones and keep load balancing health-aware.
   - C. Add a ReadOnly lock to one VM.
   - D. Increase one VM's disk size.

2. Which Storage redundancy best matches primary-zone protection plus readable secondary-region access?
   - A. LRS
   - B. ZRS
   - C. RA-GZRS, where supported
   - D. Premium LRS

3. Why are there no VM recovery points even though a policy exists?
   - A. A policy defines schedule/retention but each eligible VM still must be protected/enrolled.
   - B. Recovery points require a public container.
   - C. Policies work only with Azure Files.
   - D. A load balancer blocks backup.

4. Which restore approach best satisfies the no-overwrite proof requirement?
   - A. Replace the production VM immediately.
   - B. Restore disks or create an alternate VM in an isolated validation scope from a selected recovery point.
   - C. Delete the original before choosing a recovery point.
   - D. Use the VM temporary disk.

5. Why is `Heartbeat` empty?
   - A. Platform diagnostic settings do not by themselves collect all guest telemetry; AMA, a DCR, association, and connectivity must be verified.
   - B. LRS disables Log Analytics.
   - C. The VM must be Owner.
   - D. Backup must finish first.

6. What reusable object should contain email/webhook/automation receivers for alerts?
   - A. Action group
   - B. Availability set
   - C. Network security group
   - D. Backup policy

7. What should suppress notifications only during the maintenance window while conditions still evaluate?
   - A. Delete the alert rules.
   - B. Scheduled alert processing rule scoped to the affected resource group
   - C. Stop Log Analytics ingestion.
   - D. ReadOnly lock

8. Why must the ASR test network be changed?
   - A. Test failover should use an isolated network to prevent duplicate identities, DNS registration, and production dependency traffic.
   - B. ASR works only over the public Internet.
   - C. Test failover must stop replication.
   - D. Production VNets cannot contain VMs.

9. After a real failover is validated and committed, which operation establishes replication toward the original region for later failback?
   - A. Reprotect
   - B. Test failover cleanup
   - C. Blob versioning
   - D. Scale in

10. Which evidence set best demonstrates recoverability rather than configuration alone? **Choose two.**
    - A. Successful backup jobs/recovery points plus an isolated validated restore
    - B. Healthy replication plus documented isolated test failover and cleanup
    - C. A resource tag that says `backedUp=true`
    - D. A policy definition with no protected items
    - E. A VM screenshot before backup

## Hands-on extension

1. Place a disposable two-instance workload across zones where available and validate load-balancer health.
2. Configure appropriate storage redundancy in a supported lab account and explain what it does not protect.
3. Enable VM backup, run a backup, list the recovery point, and perform an isolated alternate restore.
4. Configure AMA/DCR and prove current `Heartbeat` or selected guest telemetry.
5. Create an action group, alert, and scheduled processing rule.
6. Perform an isolated ASR test failover only if the sandbox supports it, validate, and clean it up.
7. Produce a recovery evidence packet without secrets or customer data.
