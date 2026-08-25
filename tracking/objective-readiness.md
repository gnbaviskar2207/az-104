# AZ-104 objective readiness tracker

Copy the evidence block under each objective into your own working notes, or update this file as you progress.

## Rating rules

- **Green:** explain from memory, complete through Portal and CLI, troubleshoot one failure, and score at least 80% on related questions.
- **Amber:** understand the theory but need guide steps, command copying, or help diagnosing failures.
- **Red:** cannot confidently choose or implement the correct Azure control.

Evidence block:

```text
Status: Red / Amber / Green
Portal completed: No / Yes
CLI completed: No / Yes
Troubleshooting completed: No / Yes
Latest quiz score:
Last practised (YYYY-MM-DD):
Evidence/resource/lab notes:
Next action:
```

Do not schedule the exam while a named blueprint objective remains Red. Target Green for every objective and at least 70% in each final-mock domain.

## Manage Azure identities and governance

### Manage Microsoft Entra users and groups

- [ ] Create users and groups
- [ ] Manage user and group properties
- [ ] Manage licenses in Microsoft Entra ID
- [ ] Manage external users
- [ ] Configure self-service password reset

Evidence source: Lab 2, Module 01 checkpoint, break-fix Challenge 4.

### Manage access to Azure resources

- [ ] Manage built-in Azure roles
- [ ] Assign roles at different scopes
- [ ] Interpret direct, group-derived, and inherited access assignments

Evidence source: Labs 3 and 24, break-fix Challenges 1 and 4.

### Manage Azure subscriptions and governance

- [ ] Implement and manage Azure Policy definitions, initiatives, assignments, effects, compliance, and remediation
- [ ] Configure resource locks and distinguish ReadOnly from CanNotDelete
- [ ] Apply and manage tags on resources and resource groups
- [ ] Manage resource groups and resource moves/dependencies
- [ ] Manage subscriptions and provider registration/context
- [ ] Manage costs with alerts, budgets, and Advisor recommendations
- [ ] Configure management groups and inherited governance

Evidence source: Labs 1, 4, 5, and 24; break-fix Challenges 2, 3, and 5.

## Implement and manage storage

### Configure access to storage

- [ ] Configure Storage firewalls and virtual-network rules
- [ ] Create and use narrowly scoped SAS tokens
- [ ] Configure and revoke stored access policies
- [ ] Manage and safely rotate access keys
- [ ] Configure identity-based access for Azure Files

Evidence source: Labs 6–9 and 12; break-fix Challenges 6–10.

### Configure and manage storage accounts

- [ ] Create and securely configure StorageV2 accounts
- [ ] Select and configure suitable redundancy
- [ ] Configure and validate object replication
- [ ] Configure Microsoft-managed and customer-managed encryption decisions
- [ ] Manage data using Storage Explorer and AzCopy

Evidence source: Labs 6, 8, 9, and 24.

### Configure Azure Files and Blob Storage

- [ ] Create and configure an Azure file share
- [ ] Create and configure a private Blob container
- [ ] Configure hot, cool, cold/archive decisions where supported
- [ ] Configure soft delete for blobs and containers
- [ ] Configure snapshots and soft delete for Azure Files
- [ ] Configure Blob lifecycle management rules
- [ ] Configure and recover with Blob versioning

Evidence source: Labs 7 and 8; storage checkpoint.

## Deploy and manage Azure compute resources

### Automate deployment with ARM templates or Bicep

- [ ] Interpret an ARM template or Bicep file
- [ ] Modify an existing ARM template safely
- [ ] Modify an existing Bicep file and parameterization
- [ ] Validate, preview with what-if, and deploy ARM/Bicep
- [ ] Export a deployment as ARM and decompile/convert to a reviewed Bicep starting point

Evidence source: Lab 14, capstone, break-fix Challenge 20.

### Create and configure virtual machines

- [ ] Create Linux and Windows VMs through Portal and CLI
- [ ] Configure encryption at host where supported
- [ ] Validate and perform supported VM/resource moves
- [ ] Manage VM allocation state, sizes, quotas, and resize constraints
- [ ] Create, attach, resize, snapshot, and manage VM disks
- [ ] Deploy redundant VMs across availability zones and availability sets
- [ ] Deploy/configure VM Scale Sets and autoscale

Evidence source: Labs 10, 15, 16, and 24; break-fix Challenges 16 and 17.

### Provision and manage containers in the Azure portal

- [ ] Create and manage Azure Container Registry
- [ ] Provision and validate Azure Container Instances
- [ ] Provision Azure Container Apps and revisions
- [ ] Manage sizing/scaling for ACI and Container Apps

Evidence source: Lab 18, break-fix Challenge 19. AKS Lab 19 is enrichment.

### Create and configure App Service

- [ ] Provision an App Service plan
- [ ] Configure manual and automatic plan scaling
- [ ] Create and configure an App Service app
- [ ] Configure certificates, HTTPS, and TLS
- [ ] Map and validate an existing custom DNS name
- [ ] Configure and validate App Service backup
- [ ] Configure VNet integration, private inbound access, and access restrictions as required
- [ ] Configure deployment slots, sticky settings, health validation, swaps, and rollback

Evidence source: Lab 17, DevOps Project 1, break-fix Challenge 18.

## Implement and manage virtual networking

### Configure and manage virtual networks

- [ ] Create and configure nonoverlapping VNets and subnets
- [ ] Create and configure VNet peering in both directions
- [ ] Configure Standard public IP address properties
- [ ] Configure and interpret user-defined routes
- [ ] Troubleshoot DNS, routing, filtering, listeners, and connectivity

Evidence source: Labs 10, 11, 13, and 21; break-fix Challenges 12 and 13.

### Configure secure access to virtual networks

- [ ] Create/configure NSGs and application security groups
- [ ] Evaluate effective security rules and rule priority
- [ ] Implement and validate Azure Bastion
- [ ] Configure service endpoints for supported PaaS services
- [ ] Configure private endpoints and private-link DNS for PaaS

Evidence source: Labs 9, 10, 12, 21, and 24; break-fix Challenges 8, 9, 11, and 15.

### Configure name resolution and load balancing

- [ ] Configure public and private Azure DNS zones/records/links
- [ ] Configure an internal or public Standard Load Balancer
- [ ] Troubleshoot frontend, backend pool, health probe, rule, NSG, guest firewall, and listener

Evidence source: Labs 11 and 13; break-fix Challenge 14.

## Monitor and maintain Azure resources

### Monitor resources in Azure

- [ ] Interpret Azure Monitor platform and guest metrics
- [ ] Configure diagnostic/log settings and appropriate destinations
- [ ] Query and analyze logs with KQL
- [ ] Configure/test alert rules, action groups, and alert processing rules
- [ ] Configure and interpret VM, Storage, and Network Insights
- [ ] Use Network Watcher, effective routes/rules, and Connection Monitor

Evidence source: Labs 20 and 21; break-fix Challenges 21 and 22.

### Implement backup and recovery

- [ ] Create and compare Recovery Services and Backup vaults
- [ ] Create and configure backup policies
- [ ] Enable protection, run backup, list recovery points, and perform a safe restore
- [ ] Configure Azure Site Recovery for a supported Azure workload
- [ ] Perform/interpret test failover, failover, commit, reprotect, and failback planning
- [ ] Configure and interpret backup reports, jobs, and alerts

Evidence source: Labs 22 and 23; break-fix Challenges 23–25.

## Weekly review

At the end of each week:

1. Count Green, Amber, and Red objectives.
2. Choose the three highest-weight Amber/Red objectives.
3. Repeat their Portal and CLI validation without copying.
4. Complete one related break-fix challenge.
5. Retake only after recording why the previous attempt failed.

Final gate: every objective Green, module checkpoints at least 80%, both final mocks at least 80% overall, and no domain below 70%.
