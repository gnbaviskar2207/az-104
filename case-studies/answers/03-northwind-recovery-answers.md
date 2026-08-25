# Case Study 3 answers

1. **B.** Redundant instances across zones address a zone failure; an availability set is not cross-zone protection.
2. **C.** RA-GZRS combines a zone-redundant primary with geo-replication and readable secondary access, subject to support.
3. **A.** A policy is inert for a VM until protection is enabled and the VM becomes a protected item.
4. **B.** Alternate isolated restore validates the chosen recovery point without overwriting the live workload.
5. **A.** Resource diagnostic settings and guest collection are different paths; AMA/DCR configuration and connectivity produce guest tables such as `Heartbeat`.
6. **A.** Action groups are reusable notification/automation receiver collections.
7. **B.** Alert processing rules can suppress actions by schedule and scope while detection continues.
8. **A.** Isolation prevents a test copy from acting like a second production instance while source replication continues.
9. **A.** Reprotect reverses the protection direction after committed failover, enabling later planned failback.
10. **A and B.** Successful jobs alone are weaker than validated recovery. Restore and test-failover evidence prove usable procedures.

Requirement words: **availability zone**, **readable secondary**, **prove restore**, **without overwriting**, **orchestrated continuity**, **must not send production traffic**, **evaluation continues**.
