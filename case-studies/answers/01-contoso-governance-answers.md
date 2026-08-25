# Case Study 1 answers

1. **B.** Management groups centralize inheritance; child group/subscription assignments can add stricter controls. A tenant per subscription is unnecessary and fragments governance.
2. **A.** A shared assignment reduces drift; use a controlled exclusion/exemption for the approved DR scope. Policy, not NSGs or budgets, governs resource locations.
3. **A and B.** Existing-resource correction requires remediation executed through an assignment identity with the roles declared/required by the policy.
4. **C.** Contributor at the application resource group provides resource management but not role-assignment authority and avoids subscription-wide scope.
5. **B.** User Access Administrator manages Azure access. Assign it at the smallest common scope the central team must administer.
6. **B.** Reader covers management-plane configuration; Storage Blob Data Reader adds read-only Blob data actions. Keys/public access violate least privilege.
7. **B.** CanNotDelete blocks deletion but normally permits updates. ReadOnly is broader and caused the stated operational issue.
8. **B.** Group-based assignment centralizes authorization. Removing membership removes group-derived access after propagation.
9. **A.** Multiple thresholds improve early response. Budgets notify or invoke configured handling but do not automatically cap Azure usage.
10. **A and B.** Policy compliance plus scoped Resource Graph/inventory evidence covers rule state and deployed resources across subscriptions.

Requirement words: **centralizes**, **existing**, **must not grant access**, **read-only configuration and private Blob evidence**, **without blocking routine changes**, **one group-membership change**.
