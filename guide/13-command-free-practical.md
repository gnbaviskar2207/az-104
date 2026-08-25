# AZ-104 command-free practical assessment

This assessment provides outcomes, constraints, and acceptance evidence but no implementation commands. Complete it after the guided capstone and break-fix pack.

## Rules

- Use a sandbox subscription only.
- Allow four hours, including validation and cleanup planning.
- Do not copy commands from this repository during the timed attempt.
- Azure Portal, Azure CLI `--help`, and Microsoft Learn are allowed.
- Perform the required state through the Portal first for Missions 1–4, remove it when safe, then reproduce it through CLI/Bicep where specified.
- PowerShell is not required.
- Never print secrets or use Owner as a troubleshooting shortcut.
- Record evidence after every mission.
- Stop before any destructive change whose scope you cannot prove.

## Scenario

You administer a new internal order-tracking workload. It needs governed development resources, private data access, a highly available application tier, centralized monitoring, and tested recovery. The environment must be reproducible and removable.

Use a unique prefix and these logical groups:

- Governance/operations resource group
- Network resource group
- Application resource group
- Recovery resource group when regional separation requires it

Apply `workload=az104-practical`, `environment=assessment`, `owner`, and `expires` tags wherever supported.

## Mission 1 — Governance and access

Create and prove:

1. A test group with Reader on the network resource group.
2. Contributor for the same group only on the application resource group.
3. No ability for that group to assign Azure roles.
4. A required-tag or allowed-location Policy in Audit before stronger enforcement.
5. One compliant and one noncompliant test resource with compliance evidence.
6. A CanNotDelete lock that blocks deletion but permits a harmless update.
7. A small budget with at least two notification thresholds.

**Acceptance evidence:** scope IDs, effective access, Policy assignment/compliance, lock behavior, budget thresholds, and proof that no broad Owner assignment was used.

## Mission 2 — Secure Storage

Create and prove:

1. A secure StorageV2 account with HTTPS-only, current minimum TLS choice, disabled anonymous Blob access, and appropriate redundancy for the sandbox scenario.
2. A private Blob container with versioning, Blob/container soft delete, and a lifecycle rule.
3. A file share with snapshot and soft-delete understanding/evidence.
4. Entra data-plane access for the intended test principal.
5. A 15-minute read-only user-delegation SAS used without exposure.
6. A Blob private endpoint and correct private DNS resolution from the chosen client VNet.
7. Public network access restricted only after the private path validates.

**Acceptance evidence:** management configuration, data authorization, protected object recovery demonstration, DNS answer/private IP, allowed/disallowed path tests, and token cleanup.

## Mission 3 — Networking and compute

Create and prove:

1. Hub and application VNets with nonoverlapping address spaces.
2. Required subnets with documented purpose and no overlap.
3. Peering and effective routes.
4. NSG and ASG rules that allow only the required application/administration flows.
5. Two application instances across zones where subscription/region capability permits, or a documented availability-set fallback.
6. A Standard Load Balancer with health probe and rule.
7. Private administration without a public IP on each backend.
8. A deliberate NSG or probe failure diagnosed through effective state and repaired.

**Acceptance evidence:** topology, address plan, peering state, effective routes/rules, healthy backends, application response, private administration path, and before/after failure evidence.

## Mission 4 — App Service and containers

Create and prove:

1. An App Service plan, app, staging slot, HTTPS/TLS settings, and VNet integration.
2. A slot-specific environment setting.
3. A staging release with `/health` and `/version` validation.
4. A controlled swap and rollback.
5. A private ACR with admin user disabled.
6. ACI or Container App pulling an image through managed identity.
7. For Container Apps, revision and scaling evidence.

**Acceptance evidence:** plan/app/slot state, sticky setting behavior, health/version before and after swap, rollback result, ACR identity authorization, and running container logs.

## Mission 5 — Infrastructure as code

Recreate a selected safe subset of Missions 2–4 with modular Bicep:

1. Separate environment parameters from template logic.
2. Reference one shared existing resource without recreating it.
3. Produce only nonsensitive outputs.
4. Run lint/build, validation, and what-if.
5. Explain every proposed change.
6. Deploy with a named deployment and inspect operations.
7. Change one safe parameter, rerun what-if, and redeploy.

**Acceptance evidence:** repository structure, successful validation, reviewed what-if, deployment operations, idempotent second deployment, and no secret output.

## Mission 6 — Monitoring and recovery

Create and prove:

1. Central Log Analytics workspace.
2. Resource diagnostic settings for selected platform logs/metrics.
3. AMA/DCR guest collection for one VM where supported.
4. KQL queries for recent failures and latest heartbeat.
5. An action group, alert rule, and scheduled alert processing rule.
6. A Recovery Services vault, backup policy, protected VM, successful backup, and recovery point.
7. An isolated alternate restore or restore plan executed as far as sandbox/time safely permits.
8. ASR test-failover design and, where supported, isolated execution/cleanup.

**Acceptance evidence:** data flow to workspace, query results, tested notification path, backup job/recovery point, restore validation, and recovery cleanup record.

## Mission 7 — Failure investigation

Randomly select three without reading the solution book:

- Wrong RBAC scope
- Missing data-plane role
- Storage firewall/service-endpoint mismatch
- Broken private endpoint DNS link
- NSG priority conflict
- UDR to an NVA without forwarding
- Load-balancer probe/listener mismatch
- App Service non-sticky environment setting
- Missing ACR pull role
- Diagnostic setting mistaken for guest collection
- Fired alert with no effective action
- Backup policy with no protected item

For each, capture symptom → hypotheses → Portal evidence → CLI evidence → root cause → correction → validation → prevention.

## Cleanup mission

1. Inventory every resource by assessment tag and resource group.
2. Identify locks, backup/ASR protection, soft-deleted/retained data, private endpoints, and cross-group dependencies.
3. Remove protection/dependencies in service-safe order.
4. Remove locks only after confirming exact scope.
5. Delete only the assessment groups.
6. Prove no tagged resource, public IP, VM, Bastion, load balancer, private endpoint, vault, or container service remains.
7. Review Cost Management after asynchronous deletion settles.

## Scoring rubric

- **20 — Identity/governance:** least privilege, effective access, Policy evidence, lock and budget behavior
- **15 — Storage:** authorization, protection, private path, safe delegation
- **15 — Networking:** correct routing/filtering/DNS/load-balancer evidence
- **15 — Compute/apps/containers:** availability, slot safety, identity-based image pull
- **15 — IaC:** parameterized modules, validation, what-if, idempotence, safe outputs
- **15 — Monitoring/recovery:** collection, KQL, alert action, backup/restore evidence
- **5 — Safety/cleanup:** no secret exposure, bounded changes, complete cost-safe cleanup

Critical failures override the numeric score:

- Unbounded destructive command
- Secret committed or displayed in retained evidence
- Public anonymous data exposure left enabled
- Any/Any administrative ingress left open
- Owner assigned as a troubleshooting shortcut
- Paid resource left running without an explicit continuation plan

Pass at 80/100 with no critical failure. Repeat after at least seven days and pass again using different names/address spaces before declaring practical readiness.
