# AZ-104 Final Mock Exam 3

<!-- markdownlint-disable MD029 -->

**Questions:** 50  
**Time:** 100 minutes  
**Readiness target:** 40/50 overall and at least 70% in every domain  
**Answer book:** [Open only after submitting all answers](answers/final-mock-03-answers.md)

Unless the question says **Choose two**, select one answer.

> This mock is intentionally harder than Mock 1 and Mock 2. It includes more CLI output reading,
> ordered-decision scenarios, cross-domain questions, and trap-style wording.
> If you score below 40/50 here but scored well on Mocks 1 and 2, target the domains where you dropped points.

---

## Case study A: Northwind Traders

Northwind Traders has one Entra tenant with a production subscription and a dev subscription both under management group `mg-northwind`. The production subscription hosts a two-tier application: an App Service frontend and a VM backend in `rg-prod`. A storage account in `rg-storage` holds application data. The dev subscription is used for infrastructure testing and has no production traffic.

Requirements:
- All resources in production must carry the tag `env=production`.
- The VM backend must access Storage over a private endpoint; no public blob traffic from the VM.
- Application logs must flow to a central Log Analytics workspace in `rg-ops`.
- The VM must recover to the secondary region within 4 hours of a regional failure (RTO ≤ 4 hours).
- Developers must be able to deploy to dev but must not be able to access production resources.

---

1. Which assignment satisfies the tag requirement for new **and** existing production resources with the least manual effort?

   - A. Reader role on `mg-northwind`
   - B. A budget alert at subscription scope
   - C. Azure Policy with `modify` effect at `rg-prod` scope, plus a remediation task and the assignment managed identity granted the required tag-write role
   - D. A resource lock on `rg-prod`

2. The VM backend needs private blob access with no public traffic from the VM. Which two components are essential for the DNS resolution to work? **Choose two.**

   - A. A public IP assigned to the VM
   - B. A private endpoint for the storage account's blob subresource in the VM's VNet
   - C. The `privatelink.blob.core.windows.net` private DNS zone linked to the VM's VNet with a correct A record
   - D. A `Microsoft.Storage` service endpoint (instead of private endpoint)
   - E. RA-GRS redundancy on the storage account

3. Application logs from the App Service must reach the central workspace. Which configuration achieves this?

   - A. Enable guest diagnostics on the App Service plan VM.
   - B. Configure a diagnostic setting on the App Service resource selecting the relevant log categories and targeting the `rg-ops` Log Analytics workspace.
   - C. Install Azure Monitor Agent on the App Service.
   - D. Enable blob versioning on the storage account.

4. The VM must recover to a secondary region in under 4 hours on a regional failure. Which service should be configured?

   - A. Azure Backup with daily recovery points only.
   - B. Azure Site Recovery with replication to the secondary region and an RTO-validated recovery plan.
   - C. Geo-redundant storage for the OS disk.
   - D. Availability zones within the primary region.

5. Developers need Contributor on the dev subscription but must not access production. Which assignment structure achieves this with the least privilege?

   - A. Contributor on `mg-northwind` (parent of both subscriptions).
   - B. Contributor on the dev subscription only; no assignment on the production subscription.
   - C. Owner on both subscriptions, with a deny assignment on production.
   - D. Reader on `mg-northwind` and Contributor on every resource group in dev individually.

---

## Case study B: Fabrikam Security Audit

Fabrikam is preparing for a security audit. The auditor has flagged: (a) a storage account using account key access, (b) an NSG allow-all inbound rule at priority 100, (c) a guest user with Owner at subscription scope, (d) a VM with no backup configured, and (e) a VMSS with no autoscale upper bound.

---

6. Fabrikam wants to eliminate account key access from the storage account while keeping existing applications working. What is the recommended migration path?

   - A. Disable the storage account and recreate it.
   - B. Assign Storage Blob Data Contributor to the workload's managed identity, update the application to use Entra authentication, then disable shared key access after all clients are migrated and validated.
   - C. Rotate both keys simultaneously.
   - D. Assign Owner to the storage account.

7. The NSG has `Allow-All-Inbound` at priority 100. The auditor requires restricting inbound to only TCP 443 from the Internet. What is the minimum corrective set of changes?

   - A. Delete the NSG and create a new one.
   - B. Change the priority-100 rule source to `Internet` and destination port to `443` only, and add a `Deny-All-Inbound` rule at a higher priority number.
   - C. Add an `Allow-HTTPS` rule at priority 50 (lower number, evaluated first) with source `Internet` on TCP 443, then change the existing priority-100 rule to `Deny-All-Inbound` with a higher priority number than 50.
   - D. Enable Azure Firewall and delete the NSG.

8. The guest user has Owner at subscription scope. The auditor requires the minimum role for the guest to review billing data only. What change satisfies this?

   - A. Replace Owner with Cost Management Reader at subscription scope.
   - B. Replace Owner with Global Administrator in Entra ID.
   - C. Add a second Owner assignment to reduce impact.
   - D. Remove Owner and assign Contributor.

9. The VM has no backup. The auditor requires daily backup with a 30-day retention and a recovery point accessible within 24 hours. What should be configured?

   - A. Enable geo-redundant storage on the OS disk.
   - B. Create a Recovery Services vault, create or assign a backup policy with daily schedule and 30-day retention, then enable protection on the VM with that policy and run an on-demand backup to create the first recovery point.
   - C. Configure ASR for daily snapshots.
   - D. Enable blob versioning on the boot diagnostics storage account.

10. The VMSS has no autoscale upper bound. The auditor flags uncontrolled cost risk. What is the correct fix?

    - A. Delete the VMSS and recreate it with a fixed instance count.
    - B. Set the autoscale profile maximum instances to an appropriate value and configure a budget alert for the subscription.
    - C. Assign a ReadOnly lock to the VMSS.
    - D. Disable autoscale entirely.

---

## Standalone questions

11. You run the following and receive the output shown:

    ```bash
    az network nsg rule list --resource-group rg-web --nsg-name nsg-frontend \
      --query '[].{Name:name,Priority:priority,Access:access,Direction:direction,Port:destinationPortRange}' \
      --output table
    ```

    ```text
    Name                Priority    Access    Direction    Port
    ------------------  ----------  --------  -----------  ------
    Allow-HTTPS         300         Allow     Inbound      443
    Deny-All-Inbound    100         Deny      Inbound      *
    AllowVnetInBound    65000       Allow     Inbound      *
    DenyAllInBound      65500       Deny      Inbound      *
    ```

    An internet client sends TCP 443. What is the result?

    - A. Allowed — `Allow-HTTPS` matches TCP 443.
    - B. Denied — `Deny-All-Inbound` at priority 100 evaluates before `Allow-HTTPS` at priority 300.
    - C. Allowed — specific rules always override broad deny rules.
    - D. Denied — `DenyAllInBound` at 65500 always wins.

12. You run:

    ```bash
    az vm get-instance-view --resource-group rg-prod --name vm-db \
      --query 'instanceView.statuses[].displayStatus' --output tsv
    ```

    Output:
    ```text
    ProvisioningState/succeeded
    PowerState/stopped
    ```

    What is the correct interpretation and cost implication?

    - A. The VM is deallocated; no compute charges.
    - B. The VM is stopped at the guest OS level but remains allocated; compute charges continue.
    - C. The VM has been deleted and only the disk remains.
    - D. `PowerState/stopped` always means deallocated.

13. A team must be able to start, stop, and restart VMs in `rg-compute` but must not modify networking, change disk configuration, or grant any access. Which built-in role at `rg-compute` scope is the best fit?

    - A. Contributor — it includes all resource management actions.
    - B. Owner — it includes all actions plus role management.
    - C. Virtual Machine Contributor — it allows VM power and configuration operations without networking, disk-creation, or role-assignment actions.
    - D. Reader — it allows viewing resources only.

14. You inspect effective routes on a VM NIC:

    ```bash
    az network nic show-effective-route-table \
      --resource-group rg-app --name nic-vm01 --output table
    ```

    ```text
    Source     State    AddressPrefix      NextHopType       NextHopIP
    ---------  -------  -----------------  ----------------  ----------
    Default    Active   10.0.0.0/16        VnetLocal
    Default    Active   0.0.0.0/0          Internet
    User       Active   0.0.0.0/0          VirtualAppliance  10.0.1.4
    ```

    The VM cannot reach `8.8.8.8`. What is the most likely cause?

    - A. The VNet address space does not include `8.8.8.8`.
    - B. The user-defined route for `0.0.0.0/0` overrides the default Internet route and directs all internet-bound traffic to `10.0.1.4`. If the appliance is unavailable or not forwarding, traffic fails.
    - C. `8.8.8.8` is blocked by the VNet default system route.
    - D. Longest-prefix match selects `10.0.0.0/16` for `8.8.8.8`.

15. **What should you do FIRST** when an alert fires indicating 95% disk usage on a production VM at 02:00?

    - A. Immediately expand the managed disk without investigation.
    - B. Delete the largest files found without identifying their purpose.
    - C. Acknowledge the alert, identify the cause of disk growth (log files, temp files, application data), and determine whether expansion or cleanup is appropriate before taking action.
    - D. Deallocate the VM to stop the workload.

16. A storage account has object replication configured from `stgsource` to `stgdest`. Blobs written to `stgsource` do not appear in `stgdest` after 30 minutes. **Choose two** most likely causes.

    - A. Blob versioning is not enabled on both accounts.
    - B. Object replication requires identical storage account names.
    - C. The replication policy is not correctly configured or the rule does not match the source container.
    - D. Object replication is synchronous and zero data loss is guaranteed within 5 minutes.
    - E. The destination account requires anonymous access.

17. You need to enforce that no storage account in a subscription uses `Allow` as the default network action. Which policy effect prevents new noncompliant storage accounts from being created?

    - A. Audit
    - B. Modify
    - C. DeployIfNotExists
    - D. Deny

18. A VM is in an availability zone. The workload requires the OS disk and data disks to be zone-redundant at the disk level independent of any backup. Which disk redundancy option supports this?

    - A. LRS (locally redundant) — default for managed disks.
    - B. Zone-redundant storage (ZRS) for managed disks, where supported in the region.
    - C. GRS — replicated to a secondary region.
    - D. No managed disk option provides zone redundancy; only backup covers zones.

19. **What should you do FIRST** when deploying a Bicep file with `what-if` and the output proposes deleting a production resource you did not intend to change?

    - A. Proceed with the deployment; `what-if` output is informational only.
    - B. Stop immediately — do not deploy. Investigate the Bicep file for naming changes, removed resource blocks, or incorrect scope before rerunning `what-if` until the plan shows no unintended changes.
    - C. Delete the resource manually first to match the `what-if` plan.
    - D. Increase the resource lock level to ReadOnly.

20. An App Service slot swap preview has been applied. The staging slot is now running with production configuration. The startup validation fails — the app cannot connect to the production database. What is the safest next step?

    - A. Complete the swap and fix the connection string in production.
    - B. Cancel the swap preview; the staging slot reverts to its original configuration automatically.
    - C. Delete the staging slot and redeploy.
    - D. Delete the production slot's database and recreate it.

21. A user delegation SAS is issued for a blob container. The issuing user's Entra permissions are later removed. What happens to existing SAS tokens issued by that user?

    - A. Existing tokens remain valid until their stated expiry.
    - B. Existing tokens are immediately revoked when the user's permissions are removed.
    - C. Existing tokens are converted to account-key SAS automatically.
    - D. Existing tokens become read-only.

22. A management group policy with effect `Deny` is assigned. A user with Owner role on a child subscription attempts to deploy a noncompliant resource. What happens?

    - A. Owner bypasses all policy assignments.
    - B. The deployment is denied; Owner role does not override Azure Policy.
    - C. The resource deploys and is automatically quarantined.
    - D. Policy evaluates only monthly and does not block real-time deployments.

23. You need to allow a partner to read a specific blob for 2 hours over HTTPS only, with no access to any other blob or container. Which option best satisfies least privilege?

    - A. Storage account key shared directly.
    - B. Account SAS with `rwdlacuptfxi` permissions on the account level.
    - C. A read-only SAS scoped to the specific blob with a 2-hour expiry, HTTPS required.
    - D. Contributor role on the storage account resource group.

24. A VM's NSG allows TCP 443 inbound from Internet. `nc -zv <vm-public-ip> 443` from an external host returns `Connection refused`. IP flow verify confirms the flow is `Allowed`. What is the most likely cause?

    - A. The NSG rule is not saved correctly.
    - B. The NSG priority is incorrect.
    - C. The application is not listening on TCP 443 inside the VM, or the guest OS firewall is blocking the port.
    - D. The public IP SKU is incompatible with NSG.

25. Which two statements about Azure Policy are correct? **Choose two.**

    - A. A Deny effect prevents deployment of noncompliant resources.
    - B. An Audit effect blocks deployment and triggers rollback.
    - C. A `DeployIfNotExists` effect can deploy a companion resource if the main resource does not have it.
    - D. Policy assignments at a parent scope are not inherited by child scopes.
    - E. Owner role at subscription scope overrides a Deny policy assigned at management-group scope.

26. A VMSS autoscale profile has minimum 2, maximum 10, default 4. A scale-out rule increases capacity by 3 when CPU > 80%. CPU has been above 80% for 10 minutes and current capacity is 9. How many instances does autoscale add?

    - A. 3 — the rule always adds its configured quantity.
    - B. 0 — autoscale only fires once per hour.
    - C. 1 — the maximum is 10, so only 1 more instance can be added before the ceiling is reached.
    - D. 10 — autoscale resets to maximum when the threshold is exceeded.

27. An Azure Files share mounted over SMB from on-premises returns `System error 53: The network path was not found`. TCP 445 is confirmed blocked by the ISP. What is the correct long-term resolution?

    - A. Use a different storage account name.
    - B. Enable blob versioning to bypass the SMB restriction.
    - C. Use Azure VPN Gateway or ExpressRoute to allow private SMB traffic, or use Azure File Sync with a local cache.
    - D. Assign a public IP to the file share.

28. You run:

    ```bash
    az backup item list --resource-group rg-vault \
      --vault-name rsv-prod --output table
    ```

    The output is empty. A VM named `vm-api` is running in `rg-prod`. What does this confirm?

    - A. The vault has no backup policies.
    - B. The VM is already backed up and recovery points are healthy.
    - C. The VM has not been enrolled in backup protection; protection must be explicitly enabled.
    - D. The vault is in a different region and cannot see the VM.

29. A Log Analytics workspace receives data from three subscriptions. A KQL query must return only events from `rg-prod` in the last 24 hours:

    ```kql
    AzureActivity
    | where TimeGenerated > ago(24h)
    | where ResourceGroup == ____
    | summarize count() by OperationNameValue
    ```

    What should replace `____`?

    - A. `"prod"`
    - B. `"rg-prod"` (case-sensitive match to the resource group name as it appears in logs)
    - C. `rg-prod` (unquoted)
    - D. `contains("rg-prod")`

30. A private endpoint for an Azure SQL database resolves correctly from `vnet-app`. A second application in `vnet-dev` (peered with `vnet-app`) cannot resolve the SQL FQDN to a private IP. The private DNS zone is linked only to `vnet-app`. What is the minimum fix?

    - A. Create a new private endpoint in `vnet-dev`.
    - B. Delete and recreate the peering.
    - C. Link the existing private DNS zone to `vnet-dev` as well.
    - D. Assign a public IP to the SQL server.

31. A ReadOnly lock is applied to a production resource group. An authorized Contributor tries to run a deployment that would **update** an existing resource's tags. What happens?

    - A. The update succeeds because tags are metadata, not resource operations.
    - B. Contributor role overrides the ReadOnly lock.
    - C. The update is blocked; ReadOnly locks prevent write operations including tag updates on locked resources.
    - D. The lock only applies to deletion operations.

32. **What is the correct order** for a safe storage account key rotation when applications still use key1?

    - A. Regenerate key1 → update all applications → validate → done.
    - B. Regenerate key2 → update all applications to use key2 → validate → regenerate key1 when needed.
    - C. Regenerate both keys simultaneously → distribute both to applications.
    - D. Publish key1 in app configuration → regenerate key2.

33. An ACI group is deployed using:

    ```bash
    az container create \
      --resource-group rg-test \
      --name mycontainer \
      --image myregistry.azurecr.io/myapp:v2 \
      --assign-identity \
      --acr-identity <identity-resource-id>
    ```

    The container fails to start with `image pull error`. The identity has `AcrPull` on the registry. What should you verify?

    - A. The `--assign-identity` flag must be removed for ACR pull.
    - B. The identity resource ID in `--acr-identity` matches the identity that holds the `AcrPull` role, and the registry name resolves correctly from the ACI service.
    - C. The container image must use the `:latest` tag.
    - D. ACI cannot pull from private ACR registries.

34. An App Service has VNet integration configured with a subnet. The app can reach VMs in the VNet, but cannot reach a Storage private endpoint in the same VNet. The Storage FQDN resolves to the public IP from the app. What is missing?

    - A. The App Service needs a second VNet integration subnet.
    - B. The app's DNS resolution must be configured to use the VNet's DNS, and the private DNS zone for blob must be linked to the integration VNet so the app resolves the private IP.
    - C. A public IP must be assigned to the storage private endpoint.
    - D. The App Service plan must be upgraded to Premium.

35. Azure Advisor shows a recommendation to enable soft delete on a storage account. You enable it with a 14-day retention period. The next day, a container is accidentally deleted. What can you recover?

    - A. Nothing — soft delete only applies to individual blobs, not containers.
    - B. Nothing — soft delete requires 30 days minimum to activate.
    - C. The container and its blobs within the 14-day retention window, using the Portal or `az storage container restore`.
    - D. The container metadata only; blobs within it are permanently deleted.

36. A user reports they cannot assign a role on a resource even though they have `Microsoft.Authorization/roleAssignments/write`. Which additional permission is required to assign a role?

    - A. No additional permission is needed; `write` on roleAssignments is sufficient.
    - B. `Microsoft.Authorization/roleDefinitions/read` is needed to read the role being assigned.
    - C. The user must have at least the role they are assigning (or a role that includes it) at the target scope, in addition to the write permission — you cannot assign a role you do not hold at that scope.
    - D. Global Administrator in Entra ID is required for all role assignments.

37. A site-to-site VPN Gateway has been deployed to connect on-premises to Azure. A new spoke VNet is added and peered to the Hub. On-premises clients cannot reach the new spoke. What is missing?

    - A. A second VPN gateway in the spoke.
    - B. The peering between Hub and the new spoke must enable `Allow gateway transit` on the Hub side and `Use remote gateways` on the spoke side, so on-premises routes propagate to the spoke.
    - C. A public IP must be assigned to the spoke VNet.
    - D. ExpressRoute must replace the VPN for spokes to be reachable.

38. **Choose two.** Which statements about Azure managed identities are correct?

    - A. A system-assigned identity is tied to one resource's lifecycle and deleted when the resource is deleted.
    - B. A user-assigned identity is automatically deleted when detached from a resource.
    - C. A user-assigned identity can be attached to multiple resources simultaneously.
    - D. A system-assigned identity can be shared across multiple VMs.
    - E. Managed identities cannot be used with storage accounts.

39. You examine a KQL query result:

    ```kql
    requests
    | where resultCode == "500"
    | summarize count() by bin(timestamp, 1h)
    ```

    The table shows 0 rows for the past 6 hours despite confirmed 500 errors reported by users. What is the most likely explanation?

    - A. HTTP 500 errors are filtered out by Azure automatically.
    - B. The Application Insights resource is not connected to the workspace, or the `requests` table is not receiving data from the instrumented application.
    - C. KQL `summarize` hides rows with 0 count.
    - D. The time range selector overrides `bin(timestamp, 1h)`.

40. A budget at subscription scope reaches its 100% threshold action configured to send an email and call an Azure Function. The production VMs continue running. Which statement is correct?

    - A. This is unexpected — budgets automatically stop VMs at 100%.
    - B. This is correct — budgets trigger configured notifications and actions but do **not** automatically stop, delete, or cap resources. The Azure Function must contain logic to act on resources if desired.
    - C. The VMs are running because the Function failed; budgets always stop VMs otherwise.
    - D. The 100% threshold only applies to the next billing cycle.

41. A Bicep deployment fails with:

    ```text
    Code: InvalidTemplateDeployment
    Message: Deployment template validation failed: ... resource 'storageAccount'
    depends on resource 'keyVault' which is not defined in the template scope.
    ```

    What is the correct fix?

    - A. Remove the storage account from the template.
    - B. Add the Key Vault resource definition to the template, or use `existing` to reference an already-deployed Key Vault, ensuring the dependency is resolvable within the deployment scope.
    - C. Deploy to a different resource group.
    - D. Remove the `dependsOn` property from the storage account.

42. An AKS cluster's node pool VMs are in a subnet with an NSG. Pod-to-pod traffic within the cluster is failing. The NSG has no explicit rules. What is the likely cause?

    - A. AKS requires all NSGs to be deleted.
    - B. Restrictive NSG rules or misconfigured rules may be blocking cluster-internal traffic. AKS requires specific ports to be open for control plane communication and pod networking. The NSG must allow AKS required inbound/outbound flows.
    - C. AKS pods communicate only via public IPs.
    - D. The node pool must use a different availability zone.

43. An administrator needs to confirm that a specific user has no access path to `vm-prod` — neither directly nor through group membership. Which tool provides the most complete view?

    - A. `az ad group list`
    - B. Azure RBAC **Check access** on the VM resource for the specific user identity, which evaluates direct and group-inherited assignments.
    - C. Azure Policy compliance report.
    - D. Network Watcher IP flow verify.

44. **What should you do FIRST** when a VM's application log shows database connection timeouts starting 20 minutes ago, and you suspect a recent NSG change?

    - A. Reboot the VM.
    - B. Check the NSG Activity Log for changes in the last 30 minutes, then use IP flow verify to test connectivity from the VM to the database endpoint, before making any changes.
    - C. Delete and recreate the NSG.
    - D. Add an allow-all inbound NSG rule immediately.

45. A team is decommissioning a VM. **Choose two** resources that are **not** automatically deleted when you delete the VM through the Portal unless you explicitly select them.

    - A. The OS disk (managed disk)
    - B. The VM configuration (compute resource)
    - C. The NIC attached to the VM
    - D. The VM's guest OS
    - E. The public IP address associated with the NIC

46. An alert processing rule suppresses notifications for `rg-legacy` every weekday between 22:00 and 06:00. It is currently 23:00 on a Tuesday. An alert fires for a resource in `rg-legacy`. An alert fires for a resource in `rg-prod`. What is the expected behavior?

    - A. Both alerts are suppressed because the rule applies subscription-wide.
    - B. The `rg-legacy` alert is suppressed; the `rg-prod` alert triggers its action group normally.
    - C. Both alerts trigger action groups because alert processing rules do not apply during business-critical times.
    - D. The `rg-prod` alert is also suppressed because it shares the same action group.

47. You need to prevent a specific subscription from deploying resources outside `eastus` and `westeurope`. Which is the most scalable and enforceable control?

    - A. Train administrators to deploy only to those regions.
    - B. Assign a Deny policy with an `allowedLocations` parameter set to `["eastus","westeurope"]` at the subscription scope.
    - C. Apply a ReadOnly lock to all resource groups.
    - D. Assign Reader to all users at subscription scope.

48. A container image is in `myregistry.azurecr.io`. An Azure Container App must pull it. The Container App uses a system-assigned managed identity. The identity has `AcrPull` at the registry scope. The Container App's registry configuration references the registry but uses the admin user credentials. What should be changed?

    - A. Remove the registry entry from the Container App entirely.
    - B. Disable the system-assigned identity and use admin credentials only.
    - C. Update the Container App registry configuration to use the system-assigned managed identity for authentication instead of the admin user credentials, then disable the ACR admin user.
    - D. Grant Owner to the system-assigned identity on the ACR.

49. A Recovery Services vault uses geo-redundant storage (GRS). The primary region becomes unavailable. Which statement is correct about backup data accessibility?

    - A. Recovery points are immediately accessible from the secondary region without any configuration.
    - B. Cross-region restore can be enabled on the vault to allow recovery point access from the paired region; it is not enabled by default.
    - C. GRS automatically fails over the vault to the secondary region.
    - D. Backup data in a GRS vault cannot be recovered during a primary region outage.

50. **Choose two.** Which statements correctly describe how RBAC deny assignments differ from role assignments?

    - A. Deny assignments are created automatically by Azure Blueprints and some managed services; they cannot be directly created by most users like role assignments.
    - B. A deny assignment can block actions even for users who have an explicit allow role at the same or broader scope.
    - C. Deny assignments can be freely created by any Contributor.
    - D. A deny assignment at a resource always overrides a role assignment at management-group scope.
    - E. Deny assignments and role assignments use separate evaluation engines with no interaction.
