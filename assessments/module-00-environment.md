# Module 00 checkpoint: environment and administrator workflow

**Time:** 25 minutes  
**Target:** 12/15  
**Answer book:** [Open only after finishing](answers/module-00-environment-answers.md)

1. You administer two subscriptions. Which command changes the active Azure CLI subscription?
   - A. `az group set --subscription <id>`
   - B. `az tenant set --name <id>`
   - C. `az account set --subscription <id>`
   - D. `az configure --subscription <id>`

2. Which command gives the clearest evidence of the currently selected subscription and tenant?
   - A. `az group show`
   - B. `az login --show`
   - C. `az provider list`
   - D. `az account show`

3. A learner runs Cloud Shell and wants scripts to persist between sessions. What is normally required?
   - A. A container registry
   - B. A mounted Azure Files share
   - C. A managed disk
   - D. A Recovery Services vault

4. You rerun `az group create -n rg-demo -l eastus`. The group already exists. What design property makes this safe for a repeatable lab?
   - A. Idempotence
   - B. Geo-replication
   - C. Delegation
   - D. Immutability

5. You want only resource names and types from a resource group. Which CLI feature should shape the JSON result before display?
   - A. `--subscription-name`
   - B. `--query`
   - C. `--debug`
   - D. `--only-show-errors`

6. A deployment command fails because `Microsoft.Network` is not registered. Which command family addresses the cause?
   - A. `az provider register`
   - B. `az resource lock`
   - C. `az deployment cancel`
   - D. `az feature`

7. **Choose two.** Which practices reduce the chance that cleanup deletes unrelated resources?
   - A. Use a dedicated resource group for the lab.
   - B. List and inspect the resource group contents before deletion.
   - C. Put all labs and production resources in one group.
   - D. Delete the subscription after every exercise.
   - E. Use a wildcard for the group name.

8. Which statement about Azure resource groups is correct?
   - A. A resource can belong to multiple resource groups.
   - B. A resource group stores metadata in its selected region while resources may use other regions.
   - C. Deleting a resource group preserves all child resources.
   - D. Every resource in a group must be in the same region.

9. You need to preview whether a Bicep deployment is syntactically and semantically acceptable without creating resources. Which operation is most suitable?
   - A. `az bicep uninstall`
   - B. `az deployment group validate`
   - C. `az group wait`
   - D. `az resource invoke-action`

10. A command prints a secret in terminal history. What is the best immediate lesson for future automation?
    - A. Add `--output none`; the command history is then safe.
    - B. Put secrets directly in command arguments for repeatability.
    - C. Use managed identity, Key Vault, or protected environment/input mechanisms and rotate the exposed secret.
    - D. Base64-encode the secret.

11. Which command displays installed Azure CLI and extension versions?
    - A. `az version`
    - B. `az status`
    - C. `az account version`
    - D. `az extension version`

12. A deployment name is reused for a resource-group deployment. What does the deployment history primarily track?
    - A. ARM deployment operations and outputs at that scope
    - B. All Entra sign-ins
    - C. Every data-plane request
    - D. An operating-system snapshot

13. Which identifier is globally unique and best for scripts that must not depend on a renamed subscription display name?
    - A. Azure region display name
    - B. Tag value
    - C. Subscription ID
    - D. Resource group name

14. You want a cost notification when forecasted spend crosses a threshold. Which feature should you configure first?
    - A. Availability set
    - B. Azure budget with alert conditions
    - C. Resource lock
    - D. NSG rule

15. Before leaving a shared administrator workstation, which action most directly removes the current CLI sign-in tokens from the session?
    - A. `az account clear`
    - B. `az logout`
    - C. `az group delete`
    - D. `az cache purge`
