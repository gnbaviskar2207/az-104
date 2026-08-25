# AZ-104 Azure Administrator Lab Curriculum

**Blueprint:** English AZ-104 skills measured from April 17, 2026  
**Primary interface:** Azure CLI; every core lab also includes the equivalent Azure Portal journey  
**Secondary reference:** Azure PowerShell commands are included for recognition and comparison  
**Audience:** Learners with Azure fundamentals and basic operating-system, IP networking, and virtualization knowledge

This is a progressive, hands-on administrator curriculum. It combines the current Microsoft exam blueprint, the official MicrosoftLearning AZ-104 labs, and the practical emphases visible in the supplied CloudLee and Udemy syllabi. It is an original guide; it does not reproduce paid lesson content.

## Start here

1. Read [00 — Lab environment and operating rules](./guide/00-environment.md).
2. Follow the modules in order. The later labs reuse skills and design decisions from earlier ones.
3. Use [Exam objective map](./guide/07-objective-map.md) to audit coverage.
4. Complete [Capstone](./guide/06-capstone.md) without copying commands during the final attempt.

Run artifact-based CLI examples from the repository root so paths such as `artifacts/lab15/...` resolve correctly.

## Learning journey

- **Stage 0 — Safe lab operations:** subscription selection, Cloud Shell/local CLI, naming, tagging, cost controls, help, output queries, cleanup.
- **Stage 1 — Identity and governance:** Entra users/groups, external identities and SSPR, RBAC, resource organization, Policy, management groups, locks, budgets, Advisor.
- **Stage 2 — Storage:** secure storage accounts, Blob and Files data protection, SAS and stored access policies, network restriction, identity authorization, replication, AzCopy.
- **Stage 3 — Networking:** VNets, subnets, NSGs/ASGs, peering, routes, DNS, Bastion, service/private endpoints, load balancing, troubleshooting.
- **Stage 4 — Compute and application platforms:** ARM/Bicep, VMs, disks, availability, VMSS, App Service, ACR, ACI, Container Apps, plus AKS enrichment.
- **Stage 5 — Operations:** Azure Monitor, Logs, alerts, Insights, Network Watcher, Backup, Site Recovery, reporting.
- **Stage 6 — Capstone:** build, secure, observe, recover, and explain a small production-style workload.
- **Stage 7 — Readiness:** break-fix incidents, case studies, spaced drills, mistake remediation, command-free practical, final mocks, and last-week review.

## Curriculum files

- [00 — Environment, conventions, cost, and safety](./guide/00-environment.md)
- [01 — Identity, RBAC, subscriptions, and governance](./guide/01-identity-governance.md)
- [02 — Storage](./guide/02-storage.md)
- [03 — Virtual networking](./guide/03-networking.md)
- [04 — Compute, App Service, and containers](./guide/04-compute-apps-containers.md)
- [05 — Monitoring, backup, and recovery](./guide/05-monitoring-recovery.md)
- [06 — Integrated capstone and mock practical](./guide/06-capstone.md)
- [07 — Exam objective coverage and revision plan](./guide/07-objective-map.md)
- [08 — Supplemental course labs: Key Vault, hybrid networking, Application Gateway, and Firewall](./guide/08-supplemental.md)
- [09 — AZ-104 DevOps project ideas](./guide/09-devops-project-ideas.md)
- [10 — Break-fix troubleshooting challenges](./guide/10-break-fix-challenges.md)
- [10b — Advanced break-fix challenges 26–35 (multi-layer)](./guide/10b-break-fix-challenges-advanced.md)
- [11 — Last-week revision handbook](./guide/11-last-week-revision.md)
- [12 — Microsoft Learn search drills](./guide/12-microsoft-learn-search-drills.md)
- [13 — Command-free practical assessment](./guide/13-command-free-practical.md)
- [14 — Exam traps and misconceptions cheat sheet](./guide/14-exam-traps-cheat-sheet.md)

## Lab inventory

1. Tooling, subscription context, resource groups, tags, and safe cleanup
2. Microsoft Entra users, groups, properties, licenses, guests, and SSPR
3. Azure RBAC scopes, inheritance, effective access, and custom-role interpretation
4. Resource groups, tags, moves, locks, and subscription organization
5. Azure Policy, management groups, compliance, remediation, budgets, and Advisor
6. Secure storage-account baseline and authorization models
7. Blob tiers, lifecycle, versioning, soft delete, SAS, and stored access policies
8. Azure Files, snapshots, soft delete, identity access, Storage Explorer, and AzCopy
9. Storage networking, private endpoints, encryption, redundancy, and object replication
10. VNets, subnets, public IPs, NSGs, ASGs, and effective rules
11. VNet peering, user-defined routes, public/private DNS, and connectivity diagnosis
12. Bastion, service endpoints, private endpoints, and private DNS
13. Standard Load Balancer, health probes, rules, and troubleshooting
14. ARM templates and Bicep: interpret, modify, validate, deploy, export, and decompile
15. Linux/Windows VMs, SSH/RDP, resizing, disks, host encryption, moves, and diagnostics
16. Availability sets/zones, VM Scale Sets, and autoscale
17. App Service plans, apps, TLS, custom DNS, networking, slots, scaling, and backup
18. ACR, ACI, and Container Apps with revisions and scaling
19. AKS fundamentals (enrichment; explicitly requested, not a named 2026 objective)
20. Azure Monitor metrics, diagnostic settings, Logs, KQL, action groups, alerts, and processing rules
21. VM/Storage/Network Insights, Network Watcher, Connection Monitor, and troubleshooting
22. Recovery Services vault, Backup vault, policies, backup, restore, reports, and alerts
23. Azure Site Recovery, test failover, failover concepts, reprotection, and cleanup
24. Integrated capstone
25. Timed mock practical and remediation pass

Supplemental A. Managed identities and Key Vault  
Supplemental B. VPN Gateway, ExpressRoute, and Virtual WAN concepts  
Supplemental C. Application Gateway WAF and Azure Firewall

## Knowledge checks and mock exams

The [assessment track](assessments/README.md) keeps questions separate from explanations so you can test honestly after each module. It includes six 15-question module checkpoints, three trap-edition variant checkpoints, three original 50-question, 100-minute final mock exams, and an advanced break-fix set. The final mocks are weighted to the current AZ-104 blueprint and mix single-choice, select-two, CLI interpretation, ordered decisions, and case-study questions.

Use this progression:

1. Finish a module's theory, Portal journey, CLI implementation, validation, and cleanup.
2. Take its standard checkpoint closed-book and target at least 12/15.
3. Open the separate answer book, explain every miss, and reproduce the related task in Azure.
4. Take the trap-edition checkpoint for networking, compute, and monitoring after passing the standard version.
5. Complete the integrated capstone and timed mock practical.
6. Take [Final Mock Exam 1](assessments/final-mock-01.md), remediate weak objectives, then take [Final Mock Exam 2](assessments/final-mock-02.md) at least 48 hours later.
7. Take [Final Mock Exam 3](assessments/final-mock-03.md) — the hardest mock, with case studies, CLI output reading, and ordered-decision questions — after scoring 40/50 on both Mocks 1 and 2.

These questions are learning material, not copied certification questions or exam dumps. Also take Microsoft's official free Practice Assessment and use the official Exam Sandbox for the live interface experience.

## Readiness and retention toolkit

Use these after completing the related guided modules:

- [Objective readiness tracker](tracking/objective-readiness.md) — evidence-based Red/Amber/Green status for every current blueprint objective
- [Mistake journal](tracking/mistake-journal.md) — root-cause analysis and 1/3/7/14-day retest schedule
- [30 daily CLI, KQL, and Bicep drills](drills/daily-cli-kql-bicep.md) — 15-minute recall exercises with a separate reference book
- [25 break-fix challenges](guide/10-break-fix-challenges.md) — deliberately broken identity, Storage, networking, compute, monitoring, backup, and recovery scenarios
- [10 advanced break-fix challenges 26–35](guide/10b-break-fix-challenges-advanced.md) — multi-layer failures crossing RBAC, networking, DNS, IaC, monitoring, and vault cleanup
- [Three case studies](case-studies/README.md) — governance migration, private application platform, and regional recovery
- [Microsoft Learn search drills](guide/12-microsoft-learn-search-drills.md) — 15 timed authoritative-documentation lookups
- [Command-free practical](guide/13-command-free-practical.md) — a four-hour outcome-based Portal/CLI/Bicep assessment
- [Last-week revision handbook](guide/11-last-week-revision.md) — high-yield decision comparisons and a seven-day plan
- [Exam traps and misconceptions cheat sheet](guide/14-exam-traps-cheat-sheet.md) — 24 specific exam traps with visual diagrams, comparison tables, and a 60-second pre-exam scan

Recommended final sequence:

1. Make every objective at least Amber; complete all module checkpoints.
2. Complete daily drills and break-fix challenges; update the mistake journal.
3. Score at least 8/10 on each case study.
4. Pass the command-free practical at 80/100 with no critical failure.
5. Take Final Mock 1, remediate, then Final Mock 2 at least 48 hours later.
6. Move every objective to Green and use the last-week handbook for targeted recall.

## Source review and design decisions

- The [official Microsoft AZ-104 course](https://learn.microsoft.com/en-us/training/courses/az-104t00) defines the administrator role across subscriptions, identities, infrastructure, networking, storage, compute, applications, containers, backup, and monitoring.
- The [current official AZ-104 study guide](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-104) is the authority for scope and weight: identity/governance 20–25%, storage 15–20%, compute 20–25%, networking 15–20%, and monitoring/maintenance 10–15%.
- The [official MicrosoftLearning AZ-104 lab repository](https://github.com/MicrosoftLearning/AZ-104-MicrosoftAzureAdministrator) informed task sequencing and realistic scenarios. This guide expands those portal-centric labs with CLI-first equivalents and additional objective coverage.
- The supplied [CloudLee syllabus](https://learn.cloudlee.io/p/az-104-microsoft-azure-administrator) emphasizes case studies and detailed demonstrations across Entra, IAM, networking, VM, storage, application/container hosting, governance, protection, and monitoring. Its public page stated an April 18, 2025 exam update when reviewed.
- The supplied [Udemy syllabus](https://www.udemy.com/course/microsoft-certified-azure-administrator/) was publicly listed as updated April 2026. Its useful practical emphasis includes VM troubleshooting, disks and encryption, NSG behavior, Storage Explorer/SAS, CLI, ARM/Bicep, and a modular infrastructure project.
- Paid lesson bodies were not available without enrollment. Only publicly visible course descriptions and curricula were reviewed; Microsoft documentation remains the technical source of truth.

## How each lab is structured

Every core lab contains:

- **Theory checkpoint** — the decisions the exam expects you to understand.
- **Scenario and outcome** — what an administrator is solving.
- **Portal journey** — numbered click path and settings.
- **Azure CLI implementation** — the preferred repeatable path.
- **PowerShell reference** — short equivalents for recognition, never the main workflow.
- **Validation and troubleshooting** — evidence that the result works.
- **Production notes and exam tips** — security, reliability, cost, and likely decision points.
- **Cleanup** — explicit removal or cost-safe stopping instructions.

Portal labels change more often than concepts. If a label moves, use the portal search box for the named service, then match the resource property and outcome stated in the lab.

## Cost warning

Many labs are low-cost, but Bastion, Application Gateway, Standard Load Balancer data processing, VM Scale Sets, Log Analytics ingestion, Backup, Site Recovery, App Service paid tiers, Container Apps, ACR, AKS, private endpoints, public IPs, and running VMs can incur charges. Use a sandbox subscription, create budgets before expensive labs, deploy only for the exercise, and run cleanup immediately. Deleting a resource group is the normal lab cleanup, but inspect its contents first.

## Version policy

Use the latest generally available Azure CLI and extensions. Begin every session with `az version`, `az upgrade` when appropriate, and `az extension update --name <extension>`. Commands intentionally favor stable GA parameters. When a command differs in your installed version, use `az <group> <command> --help` and the linked current Microsoft documentation rather than copying an old syntax blindly.
