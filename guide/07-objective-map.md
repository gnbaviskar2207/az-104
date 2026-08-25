# AZ-104 objective map and revision plan

## Blueprint baseline

This map follows the English [official AZ-104 study guide](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-104), skills measured as of April 17, 2026:

- Manage Azure identities and governance: 20–25%
- Implement and manage storage: 15–20%
- Deploy and manage Azure compute resources: 20–25%
- Implement and manage virtual networking: 15–20%
- Monitor and maintain Azure resources: 10–15%

The percentages guide study time, not the exact number of questions in a particular exam. Microsoft notes that the bullets illustrate assessment scope and related topics can appear. Recheck the official study guide shortly before scheduling because objectives and portal/CLI behavior change.

## Complete objective-to-lab coverage

### Manage Azure identities and governance

Manage Microsoft Entra users and groups:

- Create users and groups — Lab 2
- Manage user and group properties — Lab 2
- Manage licenses in Microsoft Entra ID — Lab 2
- Manage external users — Lab 2
- Configure self-service password reset — Lab 2

Manage access to Azure resources:

- Manage built-in Azure roles — Lab 3, Lab 24
- Assign roles at different scopes — Lab 3, Lab 24
- Interpret access assignments — Lab 3, Lab 25

Manage Azure subscriptions and governance:

- Implement and manage Azure Policy — Lab 5, Lab 24
- Configure resource locks — Lab 4, Lab 24
- Apply and manage tags — Labs 1, 4, 5, and 24
- Manage resource groups — Labs 1 and 4; used throughout
- Manage subscriptions — Labs 1 and 5
- Manage costs with alerts, budgets, and Advisor — Lab 5, Lab 24
- Configure management groups — Lab 5

### Implement and manage storage

Configure access to storage:

- Configure Storage firewalls and virtual networks — Labs 9 and 12
- Create and use SAS tokens — Lab 7; timed practice in Lab 25
- Configure stored access policies — Lab 7
- Manage access keys — Lab 6
- Configure identity-based access for Azure Files — Lab 8

Configure and manage storage accounts:

- Create and configure storage accounts — Labs 6 and 24
- Configure redundancy — Labs 6 and 9
- Configure object replication — Lab 9
- Configure storage encryption — Labs 6 and 9
- Manage data with Storage Explorer and AzCopy — Lab 8

Configure Azure Files and Azure Blob Storage:

- Create/configure an Azure file share — Lab 8
- Create/configure a Blob container — Labs 6 and 7
- Configure storage tiers — Lab 7
- Configure soft delete for blobs and containers — Lab 7
- Configure snapshots and soft delete for Azure Files — Lab 8
- Configure Blob lifecycle management — Lab 7
- Configure Blob versioning — Lab 7

### Deploy and manage Azure compute resources

Automate deployment with ARM templates or Bicep:

- Interpret an ARM template or Bicep file — Lab 14
- Modify an existing ARM template — Lab 14 export/decompile exercise
- Modify an existing Bicep file — Lab 14
- Deploy with ARM/Bicep — Lab 14; capstone second pass
- Export deployment as ARM template or convert ARM to Bicep — Lab 14

Create and configure virtual machines:

- Create a VM — Labs 10, 15, and 24
- Configure encryption at host — Lab 15
- Move a VM to another resource group, subscription, or region — Lab 15
- Manage VM sizes — Lab 15
- Manage VM disks — Lab 15
- Deploy VMs to availability zones and availability sets — Lab 16
- Deploy and configure VM Scale Sets — Labs 16 and 24

Provision and manage containers in the Azure portal:

- Create/manage ACR — Lab 18
- Provision ACI — Lab 18
- Provision Container Apps — Lab 18
- Manage container sizing/scaling — Lab 18

AKS appears in Lab 19 because it was explicitly requested. It is enrichment, not a named current blueprint objective.

Create and configure App Service:

- Provision App Service plan — Lab 17
- Configure plan scaling — Lab 17
- Create App Service — Lab 17
- Configure certificates and TLS — Lab 17
- Map existing custom DNS name — Lab 17, conditional on owning a domain
- Configure App Service backup — Lab 17
- Configure App Service networking — Lab 17
- Configure deployment slots — Lab 17

### Implement and manage virtual networking

Configure and manage virtual networks:

- Create/configure VNets and subnets — Lab 10
- Create/configure VNet peering — Lab 11
- Configure public IPs — Labs 10 and 13
- Configure user-defined routes — Lab 11
- Troubleshoot network connectivity — Labs 11, 13, and 21

Configure secure access:

- Create/configure NSGs and ASGs — Lab 10
- Evaluate effective NSG rules — Labs 10 and 21
- Implement Azure Bastion — Lab 12
- Configure service endpoints for PaaS — Labs 9 and 12
- Configure private endpoints for PaaS — Lab 12; integrated in Lab 24

Configure name resolution and load balancing:

- Configure Azure DNS — Lab 11; private-link DNS in Lab 12
- Configure internal or public Load Balancer — Lab 13; public LB in Lab 24
- Troubleshoot load balancing — Lab 13 and capstone failure drills

### Monitor and maintain Azure resources

Monitor resources:

- Interpret Azure Monitor metrics — Lab 20
- Configure Azure Monitor log settings — Lab 20
- Query/analyze logs — Lab 20
- Configure alert rules, action groups, and alert processing rules — Lab 20
- Configure/interpret VM, storage, and network monitoring with Insights — Lab 21
- Use Network Watcher and Connection Monitor — Lab 21

Implement backup and recovery:

- Create a Recovery Services vault — Lab 22
- Create a Backup vault — Lab 22
- Create/configure a backup policy — Lab 22
- Perform backup and restore with Azure Backup — Lab 22
- Configure Azure Site Recovery for Azure resources — Lab 23
- Perform a failover to a secondary region — Lab 23 (sandbox-only controlled procedure)
- Configure/interpret backup reports and alerts — Lab 22

## Coverage from the supplied secondary courses

The publicly visible CloudLee and Udemy curricula reinforce hands-on areas beyond a minimal blueprint pass. This guide incorporates their useful emphases as follows:

- Entra managed identities, advanced identity concepts, RBAC role behavior, and case-study thinking — Labs 2–5 and Supplemental A
- Detailed NSG priority/stateful behavior, peering, UDR, endpoints, DNS, Bastion, Network Watcher — Labs 10–12 and 21
- VM disks, snapshots, encryption, extensions, boot diagnostics, availability, and VMSS autoscale — Labs 15–16
- Storage authorization, SAS, lifecycle, object replication, Files, Explorer, and AzCopy — Labs 6–9
- App Service deployments, slots, networking, autoscale, TLS, and backup — Lab 17
- ACR, ACI, Container Apps, container sizing/scaling — Lab 18
- Management groups, tags, locks, cost, Policy, ARM/Bicep, moves — Labs 4–5 and 14
- Backup, Site Recovery, metrics, Activity Log, Logs, alerts, and Network Watcher — Labs 20–23
- Key Vault, VPN/ExpressRoute/Virtual WAN, Application Gateway, Azure Firewall — Supplemental Labs A–C

## Eight-week learning schedule

### Week 1 — Foundation and identity

- Day 1: Lab 1; Azure hierarchy and CLI drills
- Days 2–3: Lab 2; repeat user/group/Graph tasks from memory
- Days 4–5: Lab 3; draw RBAC scope inheritance and compare control/data roles
- Weekend: 40–60 objective-focused practice questions; review every wrong option

### Week 2 — Governance and resources

- Days 1–2: Lab 4; moves, dependencies, locks, and tag queries
- Days 3–4: Lab 5; Policy effects, compliance/remediation, budget, Advisor
- Day 5: Repeat Labs 3–5 with CLI only
- Weekend: build a one-page decision sheet for RBAC versus Entra roles versus Policy versus locks

### Week 3 — Storage

- Day 1: Lab 6
- Days 2–3: Lab 7
- Day 4: Lab 8
- Day 5: Lab 9
- Weekend: recovery drill for deleted/versioned Blob and Azure Files; explain SAS types without notes

### Week 4 — Networking fundamentals and security

- Days 1–2: Lab 10
- Days 3–4: Lab 11
- Day 5: CIDR/subnet math and effective route/NSG drills
- Weekend: draw packet paths for public VM, peering, UDR, service endpoint, and private endpoint

### Week 5 — Secure connectivity and traffic management

- Days 1–2: Lab 12
- Days 3–4: Lab 13
- Day 5: Lab 21 troubleshooting tools preview
- Weekend: diagnose five intentionally broken paths without changing multiple variables at once

### Week 6 — Compute and application platforms

- Day 1: Lab 14
- Days 2–3: Labs 15–16
- Day 4: Lab 17
- Day 5: Lab 18
- Weekend: Lab 19 only after core objectives are on schedule

### Week 7 — Operations and recovery

- Days 1–2: Labs 20–21
- Days 3–4: Lab 22
- Day 5/weekend: Lab 23, allowing for replication time; complete a test failover and cleanup

### Week 8 — Integration and exam readiness

- Days 1–3: Lab 24 Portal pass and CLI/Bicep rebuild
- Day 4: Lab 25 timed mock
- Day 5: remediation by weak blueprint domain
- Weekend: official practice assessment, exam sandbox, light review, and adequate rest

At 10 hours/week, extend this to 10–12 weeks. Do not compress hands-on recovery or troubleshooting merely to finish a calendar.

## Repetition standard

For every core lab, reach four levels:

1. **Recognize:** explain the service, scope, dependencies, cost, and security model.
2. **Execute:** complete Portal and CLI versions with the guide.
3. **Diagnose:** fix one intentional failure using evidence.
4. **Recall:** reproduce the main workflow and explain alternatives without the guide.

Mark an objective complete only when you can justify why the wrong service/setting does not meet the scenario.

## High-yield decision points

- Entra role versus Azure RBAC role; management plane versus data plane
- Role assignment scope/inheritance; `NotActions` versus deny assignment
- Policy Audit/Deny/Modify/DeployIfNotExists; remediation identity
- `CanNotDelete` versus `ReadOnly` lock
- Storage key versus service SAS versus account SAS versus user-delegation SAS
- LRS/ZRS/GRS/GZRS and RA variants; redundancy versus object replication versus backup
- Blob soft delete/versioning/snapshot/lifecycle and Azure Files snapshot/soft delete
- Service endpoint versus private endpoint and the private DNS dependency
- NSG priority/statefulness, subnet plus NIC evaluation, ASGs, effective rules
- Peering nontransitivity, longest-prefix route, UDR/BGP/system route behavior
- Load Balancer layer 4 versus Application Gateway layer 7 (supplemental)
- Availability set versus zone versus VMSS; scale up versus scale out
- App Service plan versus app; inbound private endpoint versus outbound VNet integration
- ACI versus Container Apps versus AKS (enrichment)
- Metric versus log, diagnostic setting versus DCR, alert rule versus action group versus processing rule
- Recovery Services vault versus Backup vault; backup versus Site Recovery; RPO versus RTO
- Test failover versus planned/unplanned failover, commit, reprotect, and failback

## Exam-day preparation

- Use the official exam sandbox before test day so navigation is familiar.
- Read scenario constraints first: scope, least privilege, allowed downtime, region, cost, protocol, identity source, and required recovery objective.
- Eliminate answers that require unsupported inheritance, confuse control/data roles, expose resources unnecessarily, or fail an explicit constraint.
- When several answers work technically, favor least privilege, smallest justified scope, managed identity, private access, supported GA design, and minimal operational risk.
- Do not memorize portal pixel positions. Memorize resource relationships, decision logic, and validation evidence.

## Final readiness gate

You are ready to schedule when all of the following are true:

- Every objective above has at least one completed lab and a written explanation.
- Labs 24 and 25 score at least 80% twice with no critical security/cleanup miss.
- You can perform basic CLI tasks without searching exact commands, while comfortably using `--help` for complex groups.
- You can write and explain KQL using `where`, `project`, `summarize`, `extend`, and time filters.
- You can diagnose an access failure by separating authentication, RBAC/data role, network, Policy, lock, and service configuration.
- You can restore data/VM artifacts and complete an isolated Site Recovery test failover—not just configure policies.
- Practice-assessment weakness is remediated by objective, not by memorizing answer text.
