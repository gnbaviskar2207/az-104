# Microsoft Learn search drill targets

Page titles and URLs can change. Credit the current authoritative page that directly supports the conclusion; these are target starting points, not text to memorize.

1. **Azure built-in roles / Virtual Machine Contributor:** it manages VMs but does not grant Azure RBAC role-assignment authority. Start at [Azure built-in roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles).
2. **Scope hierarchy:** management group, subscription, resource group, resource. Start at [Understand scope for Azure RBAC](https://learn.microsoft.com/en-us/azure/role-based-access-control/scope-overview).
3. **Policy remediation identity:** review [Remediate non-compliant resources](https://learn.microsoft.com/en-us/azure/governance/policy/how-to/remediate-resources).
4. **Readable secondary plus primary-zone protection:** RA-GZRS where supported. Review [Azure Storage redundancy](https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy).
5. **User delegation:** authorized using Entra credentials/user delegation key. Review [Create a user delegation SAS](https://learn.microsoft.com/en-us/rest/api/storageservices/create-user-delegation-sas).
6. **Blob private DNS:** `privatelink.blob.core.windows.net`; inspect the service table in [Azure Private Endpoint DNS configuration](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns).
7. **Azure Files identity:** answer depends on the chosen SMB/NFS and identity environment. Start at [Azure Files identity-based authentication overview](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-active-directory-overview).
8. **Moves:** validate the specific resource/dependency in [Move operation support](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/move-support-resources).
9. **Resize:** start at [Resize a virtual machine](https://learn.microsoft.com/en-us/azure/virtual-machines/resize-vm).
10. **App Service:** VNet integration is outbound; private endpoint is inbound. Start at [App Service networking features](https://learn.microsoft.com/en-us/azure/app-service/networking-features).
11. **Slots:** review [Set up staging environments in Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/deploy-staging-slots).
12. **Load Balancer probes:** unhealthy backends stop receiving new flows according to documented behavior. Review [Azure Load Balancer health probes](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-custom-probe-overview).
13. **Monitor collection:** diagnostic settings route supported platform telemetry; AMA/DCR collect selected guest data. Start at [Diagnostic settings](https://learn.microsoft.com/en-us/azure/azure-monitor/platform/diagnostic-settings) and [Data collection rules](https://learn.microsoft.com/en-us/azure/azure-monitor/data-collection/data-collection-rule-overview).
14. **Vault selection:** consult the current [Azure Backup support matrices](https://learn.microsoft.com/en-us/azure/backup/backup-support-matrix).
15. **ASR:** test failover should use an isolated network. Start at [Test failover to Azure](https://learn.microsoft.com/en-us/azure/site-recovery/site-recovery-test-failover-to-azure).

Retake any lookup that exceeded two minutes with different search terms after 48 hours.
