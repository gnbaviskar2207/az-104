# AZ-104 DevOps project ideas

These projects combine Azure administration with practical DevOps workflows. They reinforce AZ-104 skills while introducing infrastructure as code, pull-request validation, CI/CD, controlled releases, monitoring, and recovery.

The projects are original learning exercises. They are not a replacement for the core labs or an attempt to turn AZ-104 into an AZ-400 course.

## Recommended first project — Secure App Service deployment platform

Build a secure web application platform and deploy it through Bicep and Azure DevOps Pipelines.

This is the recommended first project because it covers all five AZ-104 domains, has manageable complexity, and can be completed without operating a Kubernetes cluster.

### Estimated effort

- 6–10 focused sessions
- Approximately 12–20 hours, depending on prior Bicep and pipeline experience
- Deploy paid resources only while actively working, then clean them up

### Architecture

Deploy:

- Development and production resource groups
- Modular Bicep templates and `.bicepparam` files
- App Service plan, web app, and staging deployment slot
- StorageV2 account and private blob container
- Key Vault
- App Service managed identity
- Virtual network and dedicated integration/private-endpoint subnets
- App Service VNet integration
- Optional private endpoints and private DNS
- Log Analytics workspace and Application Insights
- Diagnostic settings
- Azure Monitor alert and action group
- Azure Policy, tags, RBAC, budget, and production resource lock
- Azure DevOps YAML pipeline

### Delivery workflow

```text
Pull request
  → Bicep lint and build
  → Bicep validation
  → What-if preview
  → Review and merge
  → Deploy infrastructure
  → Deploy application to staging
  → Run smoke test
  → Approve production
  → Swap staging into production
  → Validate health and monitoring
```

### Repository structure

```text
az104-secure-app/
├── app/
│   ├── src/
│   └── tests/
├── infra/
│   ├── main.bicep
│   ├── modules/
│   │   ├── app-service.bicep
│   │   ├── governance.bicep
│   │   ├── monitoring.bicep
│   │   ├── networking.bicep
│   │   └── storage.bicep
│   └── parameters/
│       ├── dev.bicepparam
│       └── prod.bicepparam
├── pipelines/
│   ├── infrastructure.yml
│   └── application.yml
├── scripts/
│   ├── smoke-test.sh
│   ├── validate.sh
│   └── cleanup.sh
└── README.md
```

### Stage 1 — Establish a Portal baseline

Create the initial development resources manually so you understand their Portal relationships:

1. Create the development resource group.
2. Create an App Service plan and web app.
3. Add a staging deployment slot.
4. Create a Log Analytics workspace and Application Insights resource.
5. Configure diagnostic settings.
6. Create a metric alert and action group.
7. Record every setting that the later Bicep deployment must reproduce.

Repeat the resource discovery and validation through Azure CLI:

```bash
az group show -n rg-az104-dev -o jsonc
az appservice plan show -g rg-az104-dev -n plan-az104-dev -o jsonc
az webapp show -g rg-az104-dev -n '<globally-unique-app-name>' -o jsonc
az webapp deployment slot list \
  -g rg-az104-dev \
  -n '<globally-unique-app-name>' \
  -o table
az monitor diagnostic-settings list --resource '<web-app-resource-id>' -o jsonc
```

### Stage 2 — Rebuild with Bicep

Create modules for networking, Storage, App Service, monitoring, and governance. Keep environment-specific values in parameter files rather than editing the templates.

Run these checks before deployment:

```bash
az bicep build --file infra/main.bicep

az deployment group validate \
  --resource-group rg-az104-dev \
  --template-file infra/main.bicep \
  --parameters infra/parameters/dev.bicepparam

az deployment group what-if \
  --resource-group rg-az104-dev \
  --template-file infra/main.bicep \
  --parameters infra/parameters/dev.bicepparam
```

Deploy only after reviewing the what-if output:

```bash
az deployment group create \
  --name az104-secure-app \
  --resource-group rg-az104-dev \
  --template-file infra/main.bicep \
  --parameters infra/parameters/dev.bicepparam
```

### Stage 3 — Create the Azure DevOps pipeline

Create an Azure Resource Manager service connection using workload identity federation where available. Grant the pipeline identity only the roles and scopes it needs.

Build three logical stages:

1. **Validate** — Bicep lint/build, validation, and what-if.
2. **Deploy development** — deploy infrastructure and application automatically after merge.
3. **Deploy production** — require approval through an Azure DevOps environment before deployment or slot swap.

Do not store a client secret, Storage key, publishing password, or complete service-connection output in the repository.

Microsoft currently recommends the purpose-built `BicepDeploy@0` task for new Azure Pipelines. It supports `.bicep` and `.bicepparam` files, validation, what-if, multiple scopes, deployment stacks, and masking sensitive outputs. See [Integrate Bicep with Azure Pipelines](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/add-template-to-azure-pipelines).

### Stage 4 — Deploy a small application

Use a minimal Node.js, Python Flask, or ASP.NET application. It only needs these endpoints:

- `/` — application landing page
- `/health` — returns HTTP 200 only when the app is healthy
- `/version` — displays the deployed application version or commit identifier

The application pipeline should:

1. Build and test the application.
2. Package the deployment artifact.
3. Deploy to the staging slot.
4. Call the staging `/health` and `/version` endpoints.
5. Stop if the smoke test fails.
6. Require production approval.
7. Swap staging into production.
8. Verify production health and version.

Deployment slots make it possible to validate a release before a controlled production swap. Review [App Service deployment best practices](https://learn.microsoft.com/en-us/azure/app-service/deploy-best-practices).

### Stage 5 — Add security and governance

Implement:

- App Service system-assigned or user-assigned managed identity
- Key Vault secret access through Azure RBAC
- HTTPS-only and an appropriate minimum TLS version
- Storage public-access restrictions, soft delete, and versioning
- Least-privilege pipeline and administrator role assignments
- Mandatory environment, owner, workload, and expiry tags
- Allowed-location or required-tag Policy assignment
- Subscription or resource-group budget
- CanNotDelete lock on production after deployment is validated

Use a managed identity or federated pipeline identity rather than embedding reusable credentials.

### Stage 6 — Add networking

Implement App Service VNet integration for outbound access. As an advanced extension, add private endpoints and private DNS for inbound App Service, Storage, or Key Vault connectivity.

Remember:

- App Service VNet integration is primarily for outbound traffic from the app.
- A private endpoint provides private inbound connectivity to the selected service or subresource.
- Private endpoint DNS must resolve the normal service hostname to its private IP from the intended client network.
- App Service slots have separate private-endpoint considerations.

See [Use private endpoints for Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/overview-private-endpoint).

### Stage 7 — Add monitoring, backup, and rollback

Configure:

- App Service and Storage diagnostic settings
- Application Insights availability or application monitoring
- A Log Analytics query for failed requests
- Availability, HTTP error, or response-time alert
- Action group notification
- App Service backup where the selected plan supports it
- Slot swap rollback procedure
- A short runbook for diagnosing a failed deployment

Your pipeline should retain the previous deployable artifact or identify the previous known-good commit so rollback is repeatable.

### Stage 8 — Run failure exercises

Introduce one failure at a time, predict the evidence, then troubleshoot it:

1. Remove the pipeline identity's deployment permission.
2. Supply an invalid Bicep parameter.
3. Make `/health` return HTTP 500.
4. Break private DNS resolution.
5. Incorrectly configure a slot-specific application setting.
6. Create an alert without an effective action group.
7. Remove the managed identity's Key Vault permission.
8. Apply an overly broad ReadOnly lock and observe the operational impact.

For every incident, record:

- Symptom
- Initial hypothesis
- Portal evidence
- CLI evidence
- Root cause
- Correction
- Preventive control

### Definition of done

The project is complete when:

- A pull request runs Bicep validation and produces a what-if result.
- Merging an approved change deploys development.
- Production deployment requires approval.
- Application code is deployed to staging first.
- A smoke test must pass before the slot swap.
- App Service accesses Key Vault without a stored application password.
- Logs are queryable in Log Analytics.
- A test alert reaches its configured receiver.
- A failed release can be rolled back.
- The infrastructure can be recreated from the repository.
- Portal and CLI validation evidence is documented.
- Cleanup is automated or clearly documented and tested.

## Project 2 — Azure governance pipeline

Deploy and validate a subscription-governance baseline through Bicep and Azure DevOps.

Include:

- Management-group or subscription-scope deployment
- Required tags and allowed locations
- Audit-first Policy rollout followed by controlled Deny
- Policy initiative and assignment
- Remediation identity and task
- Least-privilege RBAC assignments
- Resource locks
- Budgets and alerts
- Azure Advisor review
- Pull-request what-if and approval evidence

This is the best follow-up project for identity, governance, and enterprise administration.

## Project 3 — Container Apps delivery platform

Build and deploy a small container through ACR and Azure Container Apps.

Include:

- Docker build and vulnerability-conscious base image selection
- Private Azure Container Registry
- Managed identity for ACR image pull
- Container Apps environment and application
- Secrets referenced securely
- Revisions and weighted traffic splitting
- HTTP or event-driven scaling
- Log Analytics integration
- Health probes
- Pipeline build, push, deploy, smoke test, and rollback

Use [managed identity for Container Apps image pulls](https://learn.microsoft.com/en-us/azure/container-apps/managed-identity-image-pull) instead of registry administrator credentials.

## Project 4 — VM Scale Set automation

Deploy a load-balanced, autoscaling web tier using Bicep and a pipeline.

Include:

- Virtual network, subnets, NSGs, and application security groups
- Standard Load Balancer, health probe, and rule
- VM Scale Set across availability zones where supported
- Cloud-init or Custom Script Extension application setup
- Autoscale rules and capacity limits
- Azure Monitor Agent and data collection rule
- Central logging and alerts
- Rolling upgrade strategy
- Intentional probe, NSG, route, and guest-firewall failures

This project is more operationally complex and can incur higher compute charges than App Service.

## Project 5 — Central Azure monitoring platform

Create a shared monitoring foundation for VMs, Storage, networking, and App Service.

Include:

- Central Log Analytics workspace
- Diagnostic settings deployed through Bicep
- Azure Monitor Agent and data collection rules
- KQL queries for availability, errors, and administrative changes
- Metric and log alerts
- Reusable action groups
- Alert processing rules for maintenance windows
- VM, Storage, and Network Insights
- Network Watcher and Connection Monitor
- Workbook or documented operational dashboard

The pipeline should validate monitoring coverage and fail when a required resource lacks a diagnostic setting.

## Project 6 — Backup and recovery validation

Automate the evidence that protected Azure workloads are recoverable.

Include:

- Recovery Services vault and Backup vault comparison
- VM backup policy and protected item
- Backup job and recovery-point reporting
- Alerting for failed or overdue backups
- Isolated alternate-location restore
- Restore validation checklist
- Azure Site Recovery design or lab where subscription capability permits
- Test-failover procedure
- Reprotect and failback theory
- Cleanup that respects vault dependencies and soft delete

The goal is not merely a successful backup job; it is documented proof that a selected recovery point can produce a usable workload.

## Project 7 — Disposable AZ-104 lab environments

Create a pipeline that deploys temporary training environments and removes them after a defined lifetime.

Include:

- Parameterized lab type, owner, region, and expiry
- Dedicated resource group per lab run
- Required ownership and expiry tags
- Bicep deployment through a pipeline
- Budget/cost warning
- Optional scheduled cleanup job
- Pre-deletion inventory and safety checks
- Deployment output containing Portal and CLI validation instructions
- Protection against deleting unrecognized or production-tagged resources

This project is useful after completing several core labs because it turns the curriculum into a repeatable practice platform.

## Recommended completion order

1. Secure App Service deployment platform
2. Azure governance pipeline
3. Central Azure monitoring platform
4. Container Apps delivery platform
5. VM Scale Set automation
6. Backup and recovery validation
7. Disposable AZ-104 lab environments

Complete the first project before starting another. One finished project with reproducible deployment, evidence, documentation, failure testing, and cleanup is more useful than several partially deployed environments.
