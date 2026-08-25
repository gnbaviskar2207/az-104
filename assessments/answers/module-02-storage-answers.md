# Module 02 answers

1. **C.** ZRS synchronously distributes copies across availability zones in one region. GRS adds asynchronous regional replication.
2. **D.** Minimize scope, permissions, lifetime, and protocol. Prefer user delegation SAS for Blob when feasible.
3. **C.** A stored access policy provides server-side control over associated service SAS constraints and revocation.
4. **A.** Managed identity/Entra authorization avoids distributable account secrets and supports least-privilege RBAC.
5. **C.** Management-plane Reader does not automatically grant private blob data access. Data roles contain `dataActions`.
6. **D.** A service endpoint identifies subnet-originated traffic at the public service endpoint; the storage network rule must allow the subnet.
7. **B.** A private endpoint creates a NIC with a private address for a particular service subresource.
8. **D.** Lifecycle rules can tier or delete blobs and versions based on age and filters.
9. **B.** Versioning creates recoverable prior versions after writes/deletes, subject to retention/lifecycle design.
10. **D.** Azure Files soft delete protects deleted shares within the configured retention window; snapshots provide separate point-in-time copies.
11. **C.** AzCopy is the optimized CLI transfer utility; Storage Explorer is its common graphical counterpart.
12. **A and B.** Object replication is asynchronous for eligible block blobs and depends on versioning/change feed behavior. It is not Azure Files replication or a backup replacement.
13. **A.** Customer-managed keys are normally protected in Key Vault or Managed HSM, with access granted to the storage identity.
14. **D.** Rotating an in-use shared key before consumers switch breaks their authentication. Rotate one key at a time and validate clients.
15. **C.** Private endpoint connectivity depends on name resolution returning the private IP; check the zone, VNet link, and A record.

Remediate misses in [storage](../../guide/02-storage.md), Labs 5–8.
