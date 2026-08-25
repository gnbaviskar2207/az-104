# Module 01 checkpoint: identity and governance

**Time:** 25 minutes  
**Target:** 12/15  
**Answer book:** [Open only after finishing](answers/module-01-identity-governance-answers.md)

1. A team membership must update automatically when a user's department becomes Finance. What should you create?
   - A. Dynamic user security group with a department rule
   - B. Microsoft 365 group with manual owners
   - C. Administrative unit with a resource lock
   - D. Assigned security group

2. You invite a supplier to collaborate in your tenant. Which identity type normally represents the supplier?
   - A. Service principal owned by Microsoft
   - B. Managed identity
   - C. External guest user
   - D. Device identity

3. SSPR must be piloted with 20 users. What is the least disruptive configuration?
   - A. Enable SSPR for a selected group containing the pilot users.
   - B. Assign Owner at subscription scope.
   - C. Create an Azure Policy assignment.
   - D. Enable SSPR for all users.

4. An operator must start and stop VMs but must not change networking or grant access. Which built-in role is the best fit?
   - A. User Access Administrator
   - B. Owner
   - C. Contributor
   - D. Virtual Machine Contributor

5. A user receives Reader at subscription scope and Contributor on one resource group. What is the effective access in that group, assuming no deny assignment?
   - A. Contributor capabilities plus inherited Reader
   - B. Owner
   - C. No access because assignments conflict
   - D. Reader only

6. **Choose two.** Which scopes can hold an Azure RBAC role assignment?
   - A. Management group
   - B. Resource
   - C. Availability zone
   - D. Azure region
   - E. DNS label

7. You need to prevent accidental deletion of a production resource group while still allowing resource configuration changes. Which lock is appropriate?
   - A. CanNotDelete
   - B. DenyAction
   - C. Archive
   - D. ReadOnly

8. A policy with a Deny effect is assigned at management-group scope. A child subscription owner tries to deploy a noncompliant resource. What happens?
   - A. Policy affects only existing resources.
   - B. Owner bypasses Policy.
   - C. The request is denied unless an applicable exemption or exclusion exists.
   - D. The resource deploys and is automatically deleted.

9. Existing resources show noncompliant with a `modify` policy. What is normally needed to correct them at scale?
   - A. A ReadOnly lock
   - B. A guest invitation
   - C. An NSG flow log
   - D. A remediation task and a policy-assignment managed identity with required permissions

10. A tag is applied to a resource group. What happens to existing resources by default?
    - A. They inherit the tag immediately.
    - B. They do not inherit it automatically.
    - C. They are moved to another group.
    - D. They become compliant with every policy.

11. Which hierarchy is correct from broadest to narrowest?
    - A. Management group, subscription, resource group, resource
    - B. Tenant, resource group, management group, subscription
    - C. Resource group, tenant, subscription, resource
    - D. Subscription, management group, resource group, resource

12. A budget reaches 100%. What is the default result?
    - A. The subscription is deleted.
    - B. A ReadOnly lock is applied.
    - C. Azure shuts down every resource.
    - D. Azure sends configured notifications or triggers configured actions; spending is not automatically capped.

13. Which Azure service recommends cost, security, reliability, performance, and operational-excellence improvements based on deployed resources?
    - A. Azure Bastion
    - B. Azure Advisor
    - C. Azure DNS
    - D. Microsoft Sentinel only

14. You must allow a user to create role assignments but not manage all resources. Which built-in role is most directly suited?
    - A. Reader
    - B. User Access Administrator
    - C. Billing Reader
    - D. Virtual Machine User Login

15. You need to move a resource between subscriptions. Which prerequisite is essential?
    - A. Both subscriptions must have identical display names.
    - B. The resource must be globally replicated.
    - C. Every resource type supports all moves.
    - D. Source and destination subscriptions must use the same Microsoft Entra tenant for a supported move.
