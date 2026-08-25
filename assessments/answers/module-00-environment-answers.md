# Module 00 answers

1. **C.** `az account set --subscription` changes the active subscription. Confirm with `az account show`. See [environment setup](../../guide/00-environment.md).
2. **D.** `az account show` returns the selected subscription ID, name, tenant, and state.
3. **B.** Cloud Shell normally persists the home directory through an Azure Files share; compute sessions themselves are temporary.
4. **A.** An idempotent operation can be repeated to converge on the intended state without duplicating the resource.
5. **B.** `--query` applies a JMESPath expression; `-o table`, `json`, or `tsv` then controls presentation.
6. **A.** Register the resource provider, for example `az provider register -n Microsoft.Network`, and verify its registration state.
7. **A and B.** Dedicated scope plus an inventory check bounds the blast radius. Shared groups, wildcards, and subscription deletion are unsafe cleanup patterns.
8. **B.** The group has a metadata location, but its resources may be deployed to other supported regions. A resource belongs to exactly one resource group at a time.
9. **B.** Validation checks the deployment without performing a normal create/update. A what-if operation is the next useful step for inspecting changes.
10. **C.** Output suppression does not erase shell history. Remove exposure, rotate the secret, and prefer identity-based access or protected secret retrieval.
11. **A.** `az version` reports the CLI core and installed extensions.
12. **A.** ARM deployment history records deployment-level operations, inputs/outputs, and status; it is not a general audit or data-plane log.
13. **C.** The subscription ID is stable and unique even if the human-readable display name changes.
14. **B.** Budgets can evaluate actual or forecasted cost and notify contacts/action groups; they do not automatically stop resources.
15. **B.** `az logout` removes signed-in accounts from the CLI session. `az account clear` clears the local subscription cache but is not the primary sign-out action.

**Score guide:** 12–15: proceed. 10–11: repeat subscription/context, Bicep validation, and safe cleanup exercises. 0–9: repeat the complete environment module before retrying.
