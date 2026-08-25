# Case Study 1 — Contoso governance migration

**Time:** 25 minutes  
**Target:** 8/10  
**Answers:** [Open after completion](answers/01-contoso-governance-answers.md)

## Organization

Contoso has one Microsoft Entra tenant and three subscriptions:

- `Production` contains customer-facing workloads.
- `Development` contains shared developer environments.
- `Sandbox` contains disposable individual experiments.

The subscriptions are currently attached directly to the tenant root management group. The Cloud Platform team manages shared governance. Application teams manage their own resource groups but must not grant Azure access.

## Requirements

- All subscriptions must allow resources only in `eastus2` and `centralus`, except a documented disaster-recovery resource group in `westus2`.
- Production resources require `environment`, `owner`, `costCenter`, and `dataClassification` tags.
- Existing Production resources missing tags must be remediated where technically supported.
- Production application teams can manage resources only in their own resource groups.
- The central access team manages role assignments.
- A third-party auditor requires read-only Azure resource configuration and private Blob evidence for 30 days.
- Sandbox owners must receive notifications at 50%, 80%, and 100% of monthly budget.
- Accidental Production deletion must be prevented without blocking routine configuration changes.
- A supplier's access must be removable through one group-membership change.
- The platform team needs compliance evidence across all subscriptions.

## Current state

- The Production application group has Owner at subscription scope.
- Required tags exist only on the Production resource group.
- A Deny allowed-locations policy is assigned directly to every subscription.
- The DR resource group is excluded in only one assignment.
- A ReadOnly lock is applied to the Production subscription.
- The auditor has Reader on Production but cannot read a private evidence container.
- Sandbox has a budget at 100% only.

## Questions

1. Which hierarchy best centralizes shared Policy while allowing stricter Production controls?
   - A. Put every resource in one resource group.
   - B. Create a common landing-zone management group with Production and nonproduction child groups/subscriptions.
   - C. Create a separate tenant for every subscription.
   - D. Assign every policy to individual resources.

2. How should the allowed-locations requirement and DR exception be implemented most maintainably?
   - A. One inherited Policy assignment at the common scope with a documented exclusion/exemption for the DR scope.
   - B. Reader role assignments at each region.
   - C. NSG rules denying other regions.
   - D. A budget for each location.

3. What is required to update supported existing resources with missing tags using a `modify` policy? **Choose two.**
   - A. Remediation task
   - B. Policy-assignment managed identity with required role
   - C. Public IP
   - D. ReadOnly lock
   - E. Storage account key

4. Which role/scope best fits an application team that manages resources in `rg-payments` but cannot grant access?
   - A. Owner on Production
   - B. User Access Administrator on `rg-payments`
   - C. Contributor on `rg-payments`
   - D. Global Administrator

5. Which role should the central access team receive at the smallest shared scope needed to manage Azure role assignments without general resource changes?
   - A. Reader
   - B. User Access Administrator
   - C. Virtual Machine Contributor
   - D. Storage Blob Data Reader

6. What additional assignment lets the auditor read private blobs while retaining read-only resource configuration?
   - A. Contributor on Production
   - B. Storage Blob Data Reader at the evidence container/account scope
   - C. Storage account key by email
   - D. Public anonymous container access

7. Which lock meets the Production deletion requirement with less operational impact than the current lock?
   - A. ReadOnly
   - B. CanNotDelete
   - C. No lock and Owner for everyone
   - D. An NSG Deny rule

8. How should the supplier's authorization be structured for one-action removal?
   - A. Assign every role directly to the guest.
   - B. Add the guest to a governed group and assign required Azure roles to the group.
   - C. Share an administrator account.
   - D. Create a public SAS with no expiry.

9. What should be changed in Sandbox cost management?
   - A. Configure budget thresholds at 50%, 80%, and 100% with intended recipients/actions, while recognizing the budget is not a hard cap.
   - B. Expect the current 100% budget to delete resources.
   - C. Apply a ReadOnly lock at 50% automatically without review.
   - D. Remove all budget notifications.

10. Which combination provides centralized governance evidence? **Choose two.**
    - A. Azure Policy compliance at management-group/subscription scopes
    - B. Azure Resource Graph/resource inventory queries by scope/tag
    - C. Only screenshots from one resource group
    - D. A public Load Balancer
    - E. VM temporary disks

## Hands-on extension

In a sandbox hierarchy or subscription-safe approximation:

1. Create a required-tag Policy assignment in Audit first.
2. Deploy one compliant and one noncompliant resource.
3. Inspect compliance and assignment identity requirements.
4. Change to a remediation-capable design only after review.
5. Assign Contributor to a test group at one resource group and prove it cannot assign roles.
6. Apply CanNotDelete, prove update succeeds and deletion fails, then remove it for cleanup.
7. Create three budget thresholds and document why they do not stop spending by themselves.
