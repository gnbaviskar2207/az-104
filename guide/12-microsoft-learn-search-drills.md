# Microsoft Learn search drills

Microsoft permits access to content under `learn.microsoft.com` during eligible role-based exams, but the timer continues and Practice Assessments, Q&A, and profile access are excluded. This is for occasional fact lookup, not answering every question. Review the current [exam duration and experience guidance](https://learn.microsoft.com/en-us/credentials/support/exam-duration-exam-experience) before exam day.

## Rules

- Use only Microsoft Learn.
- Allow two minutes per drill.
- Start from the Microsoft Learn home/search experience, not a saved deep link.
- Record the exact search terms, page title, supporting heading, and elapsed time.
- Stop at two minutes. A late correct lookup still scores as missed for speed.
- Do not search for leaked exam questions or dumps.

Score each drill:

- 2 points: authoritative page and exact supporting heading within two minutes
- 1 point: correct page after two minutes or evidence is indirect
- 0 points: wrong/outdated page or unsupported conclusion

Target 24/30 before relying on Learn for occasional lookup.

## Drill 1 — Built-in role permissions

Find the official definition of Virtual Machine Contributor and determine whether it permits assigning Azure roles.

## Drill 2 — Role assignment scope

Find the documented Azure RBAC scope hierarchy and determine whether a resource-group assignment applies to child resources.

## Drill 3 — Policy remediation

Find why `modify` or `deployIfNotExists` remediation needs a managed identity and which permissions it receives/requires.

## Drill 4 — Storage redundancy

Find the official redundancy comparison and identify the option that provides zone protection in the primary region plus readable secondary-region access.

## Drill 5 — User-delegation SAS

Find how a user-delegation SAS is authorized and why it differs from a service/account SAS signed with a shared key.

## Drill 6 — Storage private endpoint DNS

Find the recommended private DNS zone name for the Blob service and verify that storage subresources have distinct zone names.

## Drill 7 — Azure Files identity access

Find the supported identity-based authentication options for Azure Files and identify which environment prerequisites apply to the chosen method.

## Drill 8 — Resource move support

Find the official move-support page for a VM and its dependencies. Determine whether the intended resource-group/subscription/region move is supported before proposing it.

## Drill 9 — VM resize behavior

Find why deallocating a VM can make additional sizes available and identify the downtime/dynamic-address implication.

## Drill 10 — App Service networking

Find the distinction between App Service VNet integration and private endpoints, specifically outbound versus inbound traffic.

## Drill 11 — Deployment slots

Find which App Service settings swap and how deployment-slot settings behave.

## Drill 12 — Load Balancer probes

Find how a Standard Load Balancer health probe affects new connections to an unhealthy backend.

## Drill 13 — Azure Monitor collection

Find the distinction between resource diagnostic settings and Azure Monitor Agent/data collection rules for guest telemetry.

## Drill 14 — Backup vault selection

Find the current vault/workload support matrix and determine whether a stated workload uses a Recovery Services vault or Backup vault.

## Drill 15 — Site Recovery operations

Find official definitions or procedures for test failover, commit, reprotect, and failback. Identify which operation should use an isolated network.

## Lookup strategy

Use service plus discriminating requirement words, for example:

```text
site:learn.microsoft.com Azure Storage redundancy RA-GZRS
site:learn.microsoft.com App Service VNet integration outbound private endpoint inbound
site:learn.microsoft.com Azure Policy modify remediation managed identity roleDefinitionIds
```

On the page:

1. Confirm the page applies to Azure and the current service.
2. Use the table of contents or page Find function.
3. Search for the requirement phrase rather than reading top-to-bottom.
4. Verify limitations/notes and applicable tier/region/feature state.
5. Return to the question and apply the fact; do not keep browsing.

## Exam-use rule

Answer known questions immediately. Mark uncertain lookups and use Learn only when a precise fact can change the answer. Microsoft currently lists 100 minutes for AZ-104, so repeated browsing can consume the entire assessment window.
