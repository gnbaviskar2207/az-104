# Case Study 2 — Fabrikam private application platform

**Time:** 25 minutes  
**Target:** 8/10  
**Answers:** [Open after completion](answers/02-fabrikam-private-app-answers.md)

## Architecture

Fabrikam deploys an App Service application and a Storage account into one region. Administrators access a private management VM. The application reads private blobs and a secret from Key Vault. Azure DevOps deploys Bicep and application releases.

## Requirements

- The web application remains publicly reachable over HTTPS.
- Storage Blob and Key Vault must not accept public-network traffic after validation.
- The application must not store reusable Azure credentials.
- The application needs outbound access to private endpoints in a VNet.
- Deployment first targets a staging slot and must pass `/health` before production.
- Production database and secret-reference settings must not move during a slot swap.
- Pipeline pull requests must show infrastructure changes before deployment.
- Operations requires application failures and platform logs in Log Analytics.
- Operators require notification when server errors cross the defined threshold.
- A release must be reversible without rebuilding infrastructure.

## Current state

- Storage and Key Vault private endpoints are approved.
- The client VNet is not linked to either private DNS zone.
- App Service has a system-assigned identity but uses a storage key in an app setting.
- VNet integration is not configured.
- The database setting in staging is not marked as slot-specific.
- The pipeline deploys directly to production using a client secret.
- Diagnostic settings exist only on the resource group Activity Log scope.

## Questions

1. Why do the private endpoints not yet guarantee private application connectivity?
   - A. Private endpoints require a public Load Balancer.
   - B. The service hostnames must resolve through linked private DNS/client DNS to the endpoint IPs.
   - C. App Service cannot access private endpoints.
   - D. The Storage account must allow anonymous access.

2. Which App Service feature provides outbound connectivity into the VNet?
   - A. VNet integration
   - B. App Service private endpoint only
   - C. Deployment slot swap
   - D. Custom domain validation

3. What should replace the Storage key in the application?
   - A. A longer-lived account SAS
   - B. Managed identity plus a suitable Storage Blob data role
   - C. A public container
   - D. Owner at subscription scope

4. Which authorization should allow the app to retrieve only required Key Vault secrets?
   - A. Key Vault data-plane RBAC role for the managed identity at the required scope
   - B. Global Administrator
   - C. Reader on the App Service plan only
   - D. Storage Blob Data Owner

5. How should production-specific settings behave during swap?
   - A. Mark them as deployment-slot settings and validate swap behavior.
   - B. Store them in the application source.
   - C. Allow them to move from staging by default.
   - D. Disable HTTPS.

6. Which pipeline sequence best meets the release requirements?
   - A. Deploy production → test staging → run what-if
   - B. Validate/what-if → deploy infrastructure → deploy staging → health test → approval → swap → verify
   - C. Delete production → deploy staging → create monitoring
   - D. Publish a storage key → deploy directly to production

7. How should the pipeline authenticate without a reusable client secret?
   - A. Workload identity federation through the Azure service connection, with least-privilege RBAC
   - B. Storage account key
   - C. A secret committed to YAML
   - D. Anonymous Azure Resource Manager access

8. Which configuration sends App Service platform logs to the workspace?
   - A. Resource-specific diagnostic setting selecting supported categories and Log Analytics destination
   - B. Resource group tags
   - C. Private DNS zone link
   - D. Deployment slot setting

9. The alert condition is met. Which object defines the operator notification receiver?
   - A. Action group
   - B. Application security group
   - C. App Service plan
   - D. Route table

10. What is the quickest controlled rollback immediately after a bad slot swap when the former production release remains in the other slot?
    - A. Delete the resource group.
    - B. Swap the slots back after confirming configuration/dependency safety.
    - C. Regenerate Storage keys.
    - D. Recreate the VNet.

## Hands-on extension

1. Deploy the App Service, staging slot, VNet integration, Storage account, and workspace with Bicep.
2. Run validation and what-if in a pull-request-equivalent workflow.
3. Enable managed identity and assign a Blob data role.
4. Create Blob private endpoint/private DNS and validate from a VNet-connected client/application path.
5. Make database/secret settings slot-specific.
6. Deploy a version to staging, test `/health` and `/version`, swap, and roll back.
7. Send App Service logs to Log Analytics and fire a test alert/action group.
