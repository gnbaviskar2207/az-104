# Final Mock Exam 2 answers

1. **D — Identity.** Policy can enforce/modify supported properties; remediation plus an authorized identity handles existing resources.
2. **B, C — Networking.** The endpoint supplies the private address and the linked zone supplies correct service-name resolution.
3. **D — Storage.** Managed identity plus a blob data role removes shared secrets and applies data-plane least privilege.
4. **B — Compute.** Slots provide staged validation and controlled promotion by swap.
5. **D — Monitoring.** Diagnostic settings route selected platform categories to the workspace.
6. **B — Identity.** Management-group assignments inherit to existing and future child subscriptions.
7. **D — Storage.** A user delegation SAS is signed using a user delegation key obtained through Entra authorization.
8. **B — Compute.** What-if previews potential deployment changes without a normal deployment.
9. **D — Networking.** Route selection uses longest-prefix match, so `/16` beats `/0`.
10. **C — Identity.** Effective allows are additive at the VM scope, but policies/denies/conditions can still constrain actions.
11. **B — Compute.** Guest shutdown can leave the Azure allocation billable; deallocate through Azure when safe.
12. **A — Networking.** Both subnet and NIC NSG layers must allow the inbound flow.
13. **D — Monitoring.** AMA and data collection rules define guest collection and destinations.
14. **C — Storage.** The `RA-` variants expose a readable secondary endpoint; select GRS/GZRS based on zone needs/support.
15. **B — Identity.** An initiative groups policy definitions for coordinated assignment/compliance.
16. **A — Compute.** Move support and dependency grouping vary by resource type; validate before changing scope.
17. **D — Networking.** The probe gates new load-balanced flows to backend instances.
18. **C — Identity.** ReadOnly blocks control-plane writes and can interfere with service operations; CanNotDelete is narrower.
19. **B — Storage.** Lifecycle deletion is real deletion after protection/retention behavior; align rules with recovery objectives.
20. **A — Compute.** Use an identity granted `AcrPull` (or current least-privilege equivalent), not registry admin secrets.
21. **D — Networking.** The load-balancing rule maps frontend protocol/port to the pool/backend port and uses a probe.
22. **C — Monitoring.** Job evidence plus alert routing creates actionable operational response.
23. **B — Identity.** A system-assigned identity is created/deleted with its Azure resource; a user-assigned identity is independent.
24. **A — Compute.** Deallocation can move the VM off its current cluster, expanding valid resize options.
25. **D — Storage.** Direct SMB uses TCP 445; private connectivity/tunneling may solve networks that block it.
26. **C — Networking.** Storage services have distinct private-link subresources and DNS zones.
27. **B — Identity.** Contributor manages resources but does not include `roleAssignments/write`.
28. **A — Compute.** This sequence stages, validates, protects environment-specific values, promotes, and observes.
29. **D — Monitoring.** Reprotect reverses replication direction after committed failover.
30. **C — Storage.** AzCopy is optimized for large, parallel, restartable Storage transfers.
31. **B — Identity.** Allow permissions accumulate; the direct Contributor role supplies write capability at that resource.
32. **A — Networking.** The effective default route selects the NVA; its failure breaks that path.
33. **D — Compute.** Container Apps meets these managed workload requirements without direct cluster administration.
34. **C — Identity.** Locks apply even to highly privileged resource users until an authorized user removes the lock.
35. **C, D — Storage.** Limit validity, resource scope, and permissions; HTTPS-only is also recommended.
36. **A — Networking.** Peering moves packets; DNS server/zone forwarding and links remain separate design tasks.
37. **D — Monitoring.** Scope plus schedule suppresses only the intended resource group's actions.
38. **C — Compute.** AKS is managed but still follows a shared-responsibility model.
39. **B — Identity.** Audit records compliance state without denying or remediating the request.
40. **A — Storage.** Treat the key as compromised, rotate safely, and reduce future key dependence.
41. **B, C — Networking.** Azure effective rules and in-guest filtering/listening are both common failure points.
42. **C — Compute.** Encryption at host extends encryption to supported host-side cache/temp paths.
43. **B — Identity.** Selected-group scope enables only members of that group (subject to the full SSPR configuration).
44. **A — Monitoring.** ASR test networks should be isolated to avoid production conflicts while validating recovery.
45. **D — Compute.** Autoscale cannot exceed the configured maximum of 8.
46. **B, C — Identity.** Remove authorization paths and disable/delete the guest object according to retention/governance needs.
47. **B — Networking.** The effective route table command reports routes learned/applied to the NIC.
48. **A — Storage.** CMK availability and authorization are data availability dependencies; protect keys from accidental deletion and access loss.
49. **D — Compute.** Redundant instances across zones address a zone failure; one instance does not.
50. **C — Monitoring.** Metrics suit numeric time-series monitoring; logs support rich record queries and log alerts.

## Domain scorecard

- Identity and governance: questions 1, 6, 10, 15, 18, 23, 27, 31, 34, 39, 43, 46
- Storage: questions 3, 7, 14, 19, 25, 30, 35, 40, 48
- Compute: questions 4, 8, 11, 16, 20, 24, 28, 33, 38, 42, 45, 49
- Networking: questions 2, 9, 12, 17, 21, 26, 32, 36, 41, 47
- Monitoring and maintenance: questions 5, 13, 22, 29, 37, 44, 50

If any domain is below 70%, do not average it away. Reproduce each missed behavior in the Portal and CLI, repeat that module checkpoint after 24 hours, and take a fresh final simulation later.
