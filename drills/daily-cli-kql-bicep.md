# Daily Azure CLI, KQL, and Bicep drills

Complete one drill per day in 15 minutes. Do not open the [reference answers](../assessments/answers/daily-drills-answers.md) until the timer ends.

## Rules

- Use a sandbox and the naming/tagging conventions from Lab 1.
- Start from the requested outcome, not a copied command.
- `az <group> <command> --help` is allowed.
- Never print secrets, access keys, connection strings, or full SAS tokens.
- Record the command/query/template, output evidence, one failure encountered, and cleanup.
- Score 1 point for correct action, 1 for narrow query/evidence, and 1 for safe handling/cleanup. Target 48/60.

## Drill 1 — Context and resource inventory

1. Select a subscription by immutable ID.
2. Show subscription name, ID, tenant, and state as a compact object.
3. List resources tagged `workload=az104` with name, type, group, and location.

## Drill 2 — Resource groups, tags, and locks

1. Create a resource group with workload, owner, environment, and expiry tags.
2. Query only the expiry tag value.
3. Add CanNotDelete, prove deletion is blocked, then remove the lock and clean up.

## Drill 3 — RBAC evidence

1. Resolve a test user's or group's object ID without relying only on display name.
2. Assign Reader at a disposable resource-group scope.
3. List direct and inherited assignments for the principal.
4. Remove only the assignment created by the drill.

## Drill 4 — Policy compliance

1. List Policy assignments that apply to the current subscription.
2. Display assignment name, scope, and enforcement mode.
3. Summarize current Policy compliance.
4. Find one noncompliant resource without changing it.

## Drill 5 — Storage authorization and protection

1. Show Storage kind, SKU, HTTPS-only, public-blob-access, minimum TLS, and network default action.
2. List private containers using Entra authentication.
3. Show versioning and soft-delete configuration without retrieving keys.

## Drill 6 — Short-lived Blob delegation

1. Create a 15-minute read-only user-delegation SAS for a test blob.
2. Use it once without printing it.
3. Unset it and verify the blob remains private without authorization.

## Drill 7 — Storage data movement

1. Authenticate AzCopy with Entra ID.
2. Upload a small directory recursively.
3. List destination objects and compare file counts.
4. Remove only the uploaded test prefix.

## Drill 8 — VNet and subnet query

1. List VNets with address spaces.
2. List one VNet's subnets with prefixes, service endpoints, delegations, and attached NSG/route table IDs.
3. Identify any overlapping planned prefix before deployment.

## Drill 9 — Effective network state

1. Show a NIC's effective route table.
2. Show its effective NSG rules.
3. Identify the route for `0.0.0.0/0` and the first applicable inbound rule for an intended management port.

## Drill 10 — DNS and private endpoint

1. List private endpoints and their connection states.
2. Find the endpoint NIC/private IP.
3. List the relevant private DNS zone links and record sets.
4. Prove the service FQDN resolves to the endpoint IP from a client VM.

## Drill 11 — VM operations

1. Show VM power state, size, zone, OS disk, NIC, and private IP.
2. List valid resize options.
3. Show boot diagnostics/instance-view evidence without changing the VM.
4. Deallocate only if the lab explicitly permits downtime, then prove allocation state.

## Drill 12 — App Service and slots

1. Show plan SKU/capacity and app HTTPS/TLS state.
2. List deployment slots.
3. List setting names and slot-sticky status without displaying secret values.
4. Display VNet integration and hostname information.

## Drill 13 — Container inventory

1. List ACR login servers and admin-user state.
2. List ACI groups or Container Apps with provisioning state.
3. Show Container App revisions and traffic weights.
4. Identify the managed identity used for registry pull.

## Drill 14 — Metrics and diagnostic settings

1. Query one supported metric for a resource over the last hour.
2. List diagnostic settings and their destinations.
3. Identify one missing telemetry category required by the operations scenario.

## Drill 15 — Backup evidence

1. List vaults, protected VM items, and recent jobs.
2. List recovery points for one protected test VM.
3. State the safest restore method for investigation without overwriting production.

## Drill 16 — KQL filtering and projection

Write a query that returns the last hour of Azure Activity records for failed operations and displays time, caller, operation, resource group, resource ID, and status. Sort newest first and limit the result.

## Drill 17 — KQL aggregation

Write a query that counts failed Azure Activity operations by operation name and resource group over 24 hours. Return the highest count first.

## Drill 18 — KQL VM availability

Write a query that shows the latest `Heartbeat` time by computer/resource ID and calculates how long it has been since each heartbeat. Explain why an empty table is a collection problem, not proof that every VM is down.

## Drill 19 — KQL application or platform errors

Choose an available App Service/Application Insights/AzureDiagnostics table. Filter failures for the last hour, summarize by result/status, and retain a query link or screenshot showing the exact table/schema used.

## Drill 20 — KQL alert design

Write a log query suitable for an alert that produces one numeric result representing failures in the last five minutes. State the threshold, evaluation frequency, window, severity, and action group.

## Drill 21 — Bicep lint and validation

1. Build `artifacts/lab14/main.bicep`.
2. Validate it at a disposable resource-group scope with a parameter override.
3. Record warnings/errors and correct only your copy when necessary.

## Drill 22 — Bicep what-if

1. Run what-if for the baseline.
2. Change a safe tag or SKU parameter.
3. Run what-if again and explain every Create, Modify, Ignore/NoChange, and Delete shown.

## Drill 23 — Bicep modules and outputs

Refactor a small resource into a module. Pass location and tags as parameters and return only a nonsensitive resource ID/endpoint as output. Validate that dependencies are derived rather than forced unnecessarily.

## Drill 24 — Bicep existing resource

Reference an existing Log Analytics workspace or VNet from a Bicep deployment without recreating it. Output its resource ID and run what-if to prove no replacement is proposed.

## Drill 25 — ARM export and Bicep decompile

Export a disposable resource group's template, decompile it, identify generated noise/hard-coded values, and create a short list of changes required before the result is maintainable IaC. Do not deploy the decompiled output unchanged.

## Drill 26 — Combined deployment evidence

Deploy a small Bicep template, then use CLI queries to prove name, location, SKU, tags, identity, networking, diagnostics, and deployment status. Save no secret output.

## Drill 27 — Failed deployment investigation

Intentionally supply an invalid allowed parameter in a disposable deployment. Find the deployment and failing operation, explain the validation error, correct the parameter, and deploy successfully.

## Drill 28 — JMESPath transformations

Produce all of these without post-processing JSON in another language:

1. Resource count grouped manually by the queried type filter.
2. Sorted list of resource name/group/location.
3. TSV containing only resource IDs for a safe read-only follow-up.
4. Filter for resources missing the `owner` tag.

## Drill 29 — Full 15-minute administrator sprint

From an empty disposable group, deploy a secure storage account with Bicep, validate it with CLI, query one metric, add a CanNotDelete lock, prove the lock, remove it, and clean up after inventory.

## Drill 30 — Closed-reference recall

Without opening this file, reproduce one command/query/template from each category:

- Subscription/context
- RBAC
- Storage data-plane access
- Effective network state
- App/VM state
- Metrics/diagnostics
- Backup evidence
- KQL aggregation
- Bicep validation and what-if

Use `--help` only after writing your first attempt. Record which command groups or concepts still require prompts.

## Retention schedule

Repeat a missed drill after 1 day, 3 days, 7 days, and 14 days. Stop repeating it only after two correct attempts without copying.
