# Module 05 answers

1. **D.** Platform metrics are time-series numeric values optimized for near-real-time visualization and alerting.
2. **B.** Log Analytics stores/queryable log data; Azure Monitor Agent and data collection rules commonly collect guest data.
3. **D.** Diagnostic settings route selected resource logs/metrics to Log Analytics, Storage, Event Hubs, or supported partners.
4. **B.** `where` filters records. Common companions include `project`, `summarize`, `extend`, and `order by`.
5. **D.** Action groups hold email/SMS/push/webhook/automation endpoints and can be reused by alert rules.
6. **B.** Alert processing rules can suppress or add action groups for a scope and schedule without deleting detection logic.
7. **D.** VM insights provides curated workbooks, performance, and dependency capabilities when required agents/data collection are configured.
8. **B.** Connection Monitor repeatedly measures reachability/latency and reports topology-related test results.
9. **D.** Recovery Services vault supports Azure VM Backup and ASR. Backup vault supports a growing set of newer backup workloads; choose by protected data source.
10. **A.** Recovery is a controlled change: select the right point and method, preserve dependencies, and validate before cutover.
11. **D.** Policies define backup frequency/schedule and retention; workload/vault type determines supported options.
12. **C.** A test failover validates recovery without a production outage; isolate networking to avoid identity, DNS, or application conflicts.
13. **B.** Reprotect establishes reverse replication after failover so planned failback can later be performed.
14. **A and B.** Backup and Site Recovery solve related but different recovery goals, and critical workloads often require both.
15. **D.** Use Backup Center/vault monitoring, reports where applicable, and alert routing rather than resource metadata as operational evidence.

Remediate misses in [monitoring and recovery](../../guide/05-monitoring-recovery.md), Labs 20–23.
