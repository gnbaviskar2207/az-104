# Final Mock Exam 1 answers

1. **C — Identity.** Contributor at resource-group scope grants resource management without role-assignment rights and limits scope.
2. **D — Storage.** This data-plane role permits blob read/write/delete without management-plane ownership or shared keys.
3. **B — Compute.** Parameters separate environment input from declarative resource logic.
4. **D — Networking.** Peering is not transitive; implement forwarding and routes through the hub design.
5. **B — Monitoring.** A correctly evaluated alert needs a working associated action group to notify or automate.
6. **D — Identity.** Cost Management Reader is narrower than resource Owner/Contributor.
7. **B — Compute.** A managed data disk is durable; temporary/local and container writable storage are disposable.
8. **B, C — Storage.** Blob and container soft delete protect the two deletion scopes.
9. **B — Networking.** Service endpoint identity plus the storage firewall VNet rule authorizes that public endpoint path.
10. **D — Identity.** RBAC Contributor does not bypass a Policy Deny.
11. **C — Compute.** A slot supports validation and controlled swap; review slot-sticky settings.
12. **B — Monitoring.** Log Analytics uses KQL for collected tables such as `Heartbeat`.
13. **A — Networking.** Lower NSG priority number wins on the first matching rule.
14. **D — Storage.** ZRS protects within-region zone failures.
15. **D, E — Identity.** Remediation executes the policy operation using an authorized assignment identity.
16. **B — Compute.** Autoscale needs capacity bounds and a metric-based scale rule.
17. **A — Networking.** Private endpoint use depends on the service name resolving to the private address.
18. **D — Identity.** This is the standard inherited Azure scope hierarchy.
19. **C — Monitoring.** Alert processing rules suppress actions on a schedule while alert evaluation remains.
20. **B — Storage.** It minimizes duration, permissions, protocol, and resource scope.
21. **A — Compute.** Decompile is a starting point; review, validation, and what-if are required before trust.
22. **D — Networking.** Bastion provides managed RDP/SSH to private-addressed VMs.
23. **C — Identity.** CanNotDelete permits modifications while blocking deletion.
24. **B — Compute.** ACI is the simplest serverless single-container fit.
25. **A — Storage.** Azure Files soft delete protects deleted shares for the configured retention.
26. **D — Identity.** Tag inheritance requires explicit Policy or automation.
27. **C — Networking.** IP flow verify returns allow/deny and the matched NSG rule.
28. **B — Monitoring.** An alternate isolated restore supports investigation with minimal production risk.
29. **A — Compute.** VNet integration supplies app outbound connectivity; a private endpoint is inbound.
30. **D — Identity.** Budgets notify/trigger configured handling but are not hard caps.
31. **C — Storage.** Lifecycle policies tier/delete eligible blobs based on rules.
32. **B, C — Networking.** Peered spaces cannot overlap and each direction has its own peering resource/settings.
33. **A — Compute.** Container Apps provides these managed application features.
34. **D — Identity.** User Access Administrator focuses on access assignment management.
35. **C — Monitoring.** Diagnostic settings select the telemetry categories and route them to destinations.
36. **B — Networking.** An application-aware probe can reject a listening but unhealthy service.
37. **A — Storage.** Versioning retains earlier blob states.
38. **D — Compute.** Durable managed disks plus backup address data protection, unlike placement constructs alone.
39. **C — Identity.** B2B collaboration represents the consultant as an external guest in the resource tenant.
40. **B — Networking.** An NVA NIC must allow forwarding in addition to guest routing/firewall configuration.
41. **A — Compute.** Deallocation releases the host allocation; storage and some networking charges can continue.
42. **D — Storage.** Object replication relies on blob versioning (and related supported configuration).
43. **C — Identity.** Reader is the standard view-only management-plane role.
44. **B — Monitoring.** Isolated test failover validates the recovery plan safely.
45. **A — Compute.** DNS mapping alone does not provide a trusted TLS certificate binding.
46. **D — Identity.** A dynamic user rule evaluates user attributes such as department.
47. **C — Networking.** Standard backend outbound connectivity must be designed explicitly.
48. **B — Storage.** Alternating keys avoids a simultaneous outage; identity-based auth is preferable long term.
49. **A — Compute.** Availability sets distribute VMs across fault/update domains; zones are separate datacenter locations.
50. **D — Monitoring.** Backup policy defines when recovery points are made and retained.

## Domain scorecard

- Identity and governance: questions 1, 6, 10, 15, 18, 23, 26, 30, 34, 39, 43, 46
- Storage: questions 2, 8, 14, 20, 25, 31, 37, 42, 48
- Compute: questions 3, 7, 11, 16, 21, 24, 29, 33, 38, 41, 45, 49
- Networking: questions 4, 9, 13, 17, 22, 27, 32, 36, 40, 47
- Monitoring and maintenance: questions 5, 12, 19, 28, 35, 44, 50

For every domain below 70%, repeat its module checkpoint and the mapped labs before taking Final Mock Exam 2.
