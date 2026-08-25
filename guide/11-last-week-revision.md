# AZ-104 last-week revision handbook

Use this during the final seven days. It is a decision guide, not a substitute for the labs. For every comparison, say the requirement that makes one option correct and give one Portal or CLI proof.

## Seven-day plan

- **Day 7:** Identity, RBAC, Policy, locks, subscriptions, cost
- **Day 6:** Storage authorization, protection, redundancy, networking
- **Day 5:** VNets, NSGs, routes, endpoints, DNS, load balancing
- **Day 4:** Bicep, VMs, availability, VMSS, App Service, containers
- **Day 3:** Metrics, logs, alerts, Network Watcher, Backup, ASR
- **Day 2:** Final mock and targeted remediation; no broad rereading
- **Day 1:** Light decision review, exam logistics, sleep; no expensive new lab

## Identity and governance decisions

### Entra role vs Azure RBAC role

- Entra roles manage directory objects and tenant identity functions.
- Azure RBAC roles manage Azure resource control/data actions at management group, subscription, resource group, or resource scope.
- Global Administrator does not automatically equal subscription Owner.
- Prove Azure access with IAM **Check access** or `az role assignment list --include-inherited`.

### Owner vs Contributor vs User Access Administrator

- Owner manages resources and access.
- Contributor manages resources but cannot assign Azure roles.
- User Access Administrator manages access but is not general resource Contributor.
- Choose the narrowest role and scope that includes required actions.

### Control plane vs data plane

- Reader can inspect a storage account but cannot automatically read private blobs.
- Storage Blob Data Reader/Contributor contains Blob data actions.
- A VM role may permit VM management without guest OS sign-in; VM login roles are separate.

### RBAC vs Policy vs locks

- RBAC asks: **Who can perform which action at what scope?**
- Policy asks: **Which resource states/requests comply with organizational rules?**
- Locks ask: **Should authorized control-plane changes or deletion be blocked?**
- Deny Policy is not bypassed by Contributor/Owner.
- ReadOnly is broader than CanNotDelete and can break service operations.

### Policy effects

- Audit records noncompliance without blocking.
- Deny blocks a noncompliant request.
- Append adds supported fields during request processing.
- Modify can change supported properties and needs an authorized assignment identity for remediation.
- DeployIfNotExists deploys related configuration when conditions are met and also needs identity/roles for remediation.
- Existing noncompliant resources do not become fixed merely because an assignment exists.

### Scope inheritance

Management group → subscription → resource group → resource.

- RBAC allows normally accumulate down the hierarchy, subject to deny assignments/conditions.
- Policy assignments inherit down scope; exclusions and exemptions are explicit.
- Tags do not inherit automatically without Policy/automation.
- A resource move changes resource-group/subscription ancestry and can change inherited access/Policy.

### Budgets, quotas, and Advisor

- Budget: evaluates actual/forecast cost and notifies/triggers configured handling; not a hard spending cap.
- Quota: service/subscription limit, sometimes adjustable.
- Policy: restricts allowed configurations/SKUs/locations when defined.
- Advisor: recommendations require contextual review; it does not automatically implement every suggestion.

## Storage decisions

### Key vs SAS vs Entra identity

- Account key: broad shared secret; avoid distributing it and rotate with two-key sequencing.
- Account SAS: signed with account key and can cover multiple services/resource types.
- Service SAS: scoped to a service resource; a stored access policy can control associated service SAS constraints.
- User-delegation SAS: Blob SAS authorized through Entra; preferred over key-signed SAS when supported.
- Managed identity/data RBAC: preferred for Azure-hosted workloads; no reusable application secret.

Always minimize SAS permissions, resource scope, protocol, source restrictions where useful, and lifetime. Consider UTC skew for start time.

### Storage redundancy

- LRS: copies in one physical datacenter; lowest redundancy.
- ZRS: synchronous copies across availability zones in one region.
- GRS: LRS primary plus asynchronous secondary-region copy.
- GZRS: ZRS primary plus asynchronous secondary-region copy.
- RA-GRS/RA-GZRS: adds read access to the secondary endpoint.
- Regional replication is not the same as backup and can replicate logical corruption/deletion.

### Versioning, soft delete, snapshots, lifecycle, replication

- Blob versioning retains prior blob states after writes/deletes.
- Blob/container soft delete recovers deleted objects/containers within retention.
- File share snapshots are point-in-time share copies.
- Azure Files soft delete protects deleted shares.
- Lifecycle management tiers/deletes eligible blobs/versions by rules.
- Object replication asynchronously copies supported block blobs; it is not synchronous failover or a complete backup.

### Service endpoint vs private endpoint

- Service endpoint: source subnet identity reaches the PaaS public endpoint; service firewall must allow the subnet.
- Private endpoint: NIC/private IP for a specific service subresource in the VNet.
- Private endpoint normally needs private DNS so the usual service FQDN returns the private IP.
- Storage `blob`, `file`, and other subresources require distinct endpoint/DNS decisions.

### Management-plane vs network denial

When Storage access fails, identify the layer:

1. DNS answer
2. Route and network path
3. Storage firewall/private endpoint
4. Authentication credential/identity
5. Data-plane authorization
6. SAS time/scope/permission

## Networking decisions

### NSG processing

- Rules evaluate ascending numeric priority; first match wins.
- NSGs are stateful; return traffic for an allowed flow does not need a mirror rule.
- For inbound traffic with subnet and NIC NSGs, both applicable evaluations must allow it.
- Effective security rules aggregate the applicable layers.
- Application security groups label NIC configurations for NSG rules; they are not firewalls by themselves.

### Route selection

- Longest prefix wins first.
- For equal prefixes, Azure route-source preference rules apply.
- A UDR can send traffic to VirtualAppliance, VirtualNetworkGateway, Internet, or None as supported.
- NVA routing requires NIC IP forwarding, guest forwarding, firewall/NAT policy, and a return path.
- Peering is nontransitive.

### Public IP, Bastion, and private administration

- A VM does not need a public IP when managed through Bastion, VPN/ExpressRoute, or another controlled private path.
- Bastion provides managed RDP/SSH connectivity; it is not a general application reverse proxy.
- Public IP SKU/allocation/zone properties matter for attached load balancers/NICs.

### DNS record decisions

- A: hostname → IPv4 address.
- AAAA: hostname → IPv6 address.
- CNAME: alias hostname → canonical hostname; not an IP literal.
- MX: mail exchange.
- TXT: text/verification metadata.
- PTR: reverse lookup.
- Private DNS zone links are explicit; VNet peering does not automatically provide zone resolution.

### Load Balancer troubleshooting order

1. Frontend IP and reachability
2. Load-balancing rule protocol/ports
3. Backend pool membership/NIC configuration
4. Health probe protocol/port/path
5. NSG allowance for probe and client flow
6. Guest firewall and listener
7. Application-level health
8. Outbound design for Standard backend instances

A TCP probe proves a port accepts a connection, not that an HTTP application is healthy.

## Compute and application decisions

### ARM/Bicep workflow

Use: lint/build → validate → what-if → reviewed deployment → output/operation validation.

- Parameters separate environment values from template logic.
- A symbolic-name change alone does not change resource identity; name/scope/type/parent changes can.
- Decompilation is a starting point that requires review.
- `existing` references an already deployed resource without redeclaring its creation.
- Stop when what-if proposes an unexplained delete/replacement.

### VM power and sizing

- Guest shutdown can leave the VM allocated and compute-billable.
- Deallocation releases compute allocation; disks and some networking remain billable.
- Deallocation can expose more resize choices but causes downtime and can affect dynamic addressing.
- Temporary disk is nondurable; use it only for disposable data.
- OS/data managed disks persist independently according to lifecycle settings and remain billable.

### Availability set vs zone vs VMSS

- Availability set: distributes VMs across fault/update domains within a datacenter scope.
- Availability zones: physically separate datacenter locations within a supported region.
- VM Scale Set: manages a set of similar instances, upgrades, and scaling; can use zones/placement options.
- One VM is still one failure domain regardless of disk redundancy or a lock.

### App Service networking

- VNet integration: primarily outbound access from app/slot into a VNet.
- Private endpoint: private inbound access to an app/slot.
- Access restrictions: control inbound source access to the app endpoint.
- Custom DNS mapping does not itself create a trusted TLS binding.
- Deployment slots may have separate networking/configuration considerations.

### App Service slots

- Deploy and validate in staging, protect slot-specific settings, then swap.
- Non-sticky settings move according to swap behavior.
- Verify `/health`, configuration, dependencies, TLS, and version before/after swap.
- Rollback can be another swap when the previous production content remains in the source slot.

### ACR, ACI, Container Apps, AKS

- ACR: private container registry; it does not run the application.
- ACI: simple isolated container execution without orchestrator management.
- Container Apps: managed ingress, revisions, traffic splitting, secrets, and HTTP/event-driven scaling.
- AKS: Kubernetes orchestration with shared responsibility; enrichment for this curriculum rather than a named current AZ-104 objective.
- Prefer managed identity with `AcrPull` over registry admin credentials.

## Monitoring and recovery decisions

### Metrics vs logs vs Activity Log

- Metrics: numeric time series, near-real-time charts/alerts.
- Logs: structured records in Log Analytics queried with KQL.
- Activity Log: subscription control-plane events.
- Diagnostic settings route supported resource/platform logs and metrics; they do not replace guest-agent collection.
- Azure Monitor Agent plus data collection rules handles selected guest telemetry.

### Alert rule vs action group vs processing rule

- Alert rule: condition, scope, evaluation, severity.
- Action group: notification/automation receivers.
- Alert processing rule: adds/suppresses actions by scope and schedule without deleting detection rules.
- If the alert fired, troubleshoot the action path rather than changing the condition first.

### Network Watcher tools

- IP flow verify: example packet allowed/denied and matched NSG rule.
- Effective security rules: aggregate NSG rules on a NIC.
- Effective routes/next hop: routing decision.
- Connection troubleshoot/Connection Monitor: point-in-time or continuous connectivity evidence.
- Packet capture: packet-level evidence when authorized and appropriately scoped.

### Backup vs Site Recovery

- Backup: point-in-time recovery and retention.
- Site Recovery: replication, orchestration, and workload continuity.
- Critical systems can need both.
- Creating a backup policy does not protect an item until protection is enabled.
- A successful backup job is incomplete evidence until restore is tested.

### ASR operation order

- Test failover: isolated validation without stopping normal replication.
- Planned/unplanned failover: transition to recovery location according to scenario.
- Commit: accept the selected recovery point/failover result.
- Reprotect: establish reverse replication after failover.
- Failback: planned return using the reversed protection path.
- Clean up test failovers and keep test networks isolated.

## Requirement words that change answers

- **Least privilege:** narrowest role, permissions, scope, and duration.
- **Minimum administrative effort:** managed service/automation that still satisfies requirements.
- **Without secrets:** managed identity or workload identity federation.
- **Without public IP:** Bastion/private connectivity, not an open NSG.
- **Zone failure:** zone-redundant design, not only regional replication terminology.
- **Regional failure:** secondary-region design, not only availability zones.
- **Existing resources:** consider remediation/migration, not only future-request enforcement.
- **Inbound vs outbound:** private endpoint versus VNet integration is a common distinction.
- **Recover vs continue operating:** Backup versus Site Recovery.
- **Read secondary:** select an `RA-` storage redundancy option.

## Final recall test

Without opening another file, explain and give one CLI/Portal proof for all of these:

1. Effective RBAC at a resource
2. Policy noncompliance and remediation
3. Storage data-plane authorization
4. Private endpoint DNS
5. NSG first-match behavior
6. Effective route/next hop
7. Load-balancer backend health
8. Bicep what-if
9. VM allocation state and resizing
10. App Service slot safety
11. Container registry identity pull
12. Diagnostic collection path
13. Alert detection-to-action path
14. Backup recovery point and restore choice
15. ASR test failover and reprotect

Any item you cannot explain in two minutes becomes the next targeted remediation task.
