# Case Study 2 answers

1. **B.** Private endpoint use depends on clients resolving the normal service FQDN to its private IP through the proper private zone/link/forwarding path.
2. **A.** VNet integration is primarily outbound connectivity from the app/slot. A private endpoint is private inbound access to the app.
3. **B.** Managed identity plus Storage Blob Data Reader/Contributor as required removes distributable account credentials.
4. **A.** Grant the identity a suitable Key Vault secrets data role at the narrowest practical scope; management-plane Reader is insufficient for secret values.
5. **A.** Slot-sticky settings remain with the environment during swap, preventing production from receiving staging dependency values.
6. **B.** This sequence previews infrastructure, stages the release, gates production on health/approval, and verifies the result.
7. **A.** Federation avoids a stored service-principal secret and should still use scoped RBAC.
8. **A.** Activity Log routing alone does not collect each resource's platform logs. Configure diagnostic settings on the resource.
9. **A.** The alert rule detects; the action group identifies notification/automation receivers.
10. **B.** Swapping back is a fast rollback when former production remains healthy in the other slot and settings/dependencies are safe.

Requirement words: **publicly reachable app**, **private Storage/Key Vault**, **without reusable credentials**, **outbound**, **must not move**, **before deployment**, **reversible**.
