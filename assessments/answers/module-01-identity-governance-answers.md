# Module 01 answers

1. **A.** A dynamic user group evaluates user attributes and updates membership. Assigned groups require manual or automated membership changes.
2. **C.** B2B collaboration normally creates an external guest object in the resource tenant.
3. **A.** Group-scoped SSPR supports a controlled pilot before an all-user rollout.
4. **D.** Virtual Machine Contributor manages VMs without granting role-assignment authority; verify exact required network actions before production assignment.
5. **A.** Allow assignments are additive across inherited and direct scopes. The narrower Contributor assignment provides write actions in that group.
6. **A and B.** RBAC scopes include management group, subscription, resource group, and individual resource—not regions or zones.
7. **A.** CanNotDelete permits updates but blocks deletion. ReadOnly also blocks changes and often disrupts service operations.
8. **C.** Azure Policy evaluates authorization requests independently of an Owner role; ownership is not a Policy bypass.
9. **D.** `modify` and `deployIfNotExists` remediation commonly require a managed identity and the role definitions specified by the policy.
10. **B.** Tags do not inherit from resource groups by default. Use Policy or automation when inheritance is required.
11. **A.** Management group → subscription → resource group → resource is the Azure governance/RBAC scope hierarchy below the tenant.
12. **D.** A budget is an alerting/governance mechanism, not a hard spending cap.
13. **B.** Advisor analyzes resources and produces contextual recommendations across the five pillars.
14. **B.** User Access Administrator manages user access to Azure resources without general Contributor permissions.
15. **D.** Supported cross-subscription moves require compatible tenants/providers/quotas and resource-specific dependencies. Support must be checked per resource type.

Remediate all misses in [identity and governance](../../guide/01-identity-governance.md), especially Labs 1–4.
