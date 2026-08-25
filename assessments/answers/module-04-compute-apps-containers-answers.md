# Module 04 answers

1. **B.** Bicep describes desired ARM state, resolves dependencies, supports modules/parameters, and is suitable for source control.
2. **D.** What-if previews potential resource changes. Validation checks acceptability but is not the same change preview.
3. **B.** Deallocation frees the current host allocation and can expose more size choices, but it changes the VM's availability and possibly dynamic public IP behavior.
4. **D.** Temporary disks are not durable. Put paging/swap or disposable cache there, never authoritative data.
5. **B.** Redundant instances across zones address a zone failure. Availability sets address fault/update domains within a datacenter scope.
6. **D.** Autoscale combines metric thresholds, aggregation windows, cooldown, and min/default/max capacity.
7. **B.** ACR stores private OCI/container artifacts and integrates with Azure identity and compute services.
8. **D.** ACI is appropriate for simple isolated containers without managing an orchestrator.
9. **B.** Container Apps revisions allow rollback, multiple active versions, and weighted traffic depending on revision mode.
10. **B.** The plan is the compute boundary and its tier determines available capacity/scaling capabilities.
11. **A.** Slots support staged deployment and swaps. Mark secrets/connection settings as slot-specific where production values must not move.
12. **D.** DNS validation/mapping does not itself establish certificate trust. Add/bind a certificate and enforce HTTPS/current TLS.
13. **C and B.** VNet integration is outbound; private endpoints are inbound. Integration alone does not disable the public endpoint.
14. **B.** Kubernetes control-plane components schedule and reconcile workload state; nodes run the Pods.
15. **A.** Container Apps provides managed ingress, revisions, and event/HTTP-driven scaling including scale-to-zero where supported.

Remediate misses in [compute, apps, and containers](../../guide/04-compute-apps-containers.md), Labs 14–19. AKS is enrichment; prioritize named blueprint objectives first.
