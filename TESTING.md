# Testing and limitations

## Controlled routine replay, 5 November 2026

Original x86 game routines were run in an emulator using a snapshot of a loaded career. The installed game and save were not modified by those emulation runs. The final test used only this patch's pointer and constant changes, without the other experimental relaxations investigated earlier.

- Fourteen players were on the selling club's transfer list.
- A fresh round of evaluations with the original code produced no new internal shortlist entries for them.
- With multiplier 1.35, five players received ten player-club shortlist entries in total.
- Continuing through the normal bidding routine for one player produced a transfer offer. Duplicate-offer handling remained active in repeated calls.
- Twenty repeated bid-routine calls were on the same game date. They were not twenty played days. These results demonstrate a path to a bid, not a daily or weekly bid rate.
- Player contract acceptance and completed sales were not established by this particular emulation test.

## Author's career experience, reported 17 November 2026

The author reports using the same 1.35 setting across multiple transfer windows. Interest and bids increased noticeably, with a positive effect on selling players. Sometimes the number of incoming bids was high.

This is direct user-reported experience from one career. No controlled comparison across leagues, patch combinations or multiple seasons has been performed.

## Release package checks

All **13 release-checker cases passed** on 17 November 2026, covering supported unpatched and installed local executables, removal eligibility, the separate two-footed search marker, and deliberately incompatible test copies: changed recruitment code, occupied constant space, a modified installed multiplier, a changed shared constant, a different PE image base, and a non-executable file. Patch-file tampering was also rejected.

The checker left every input file unchanged. Separate patch-application and removal checks restored every byte of both local input variants, and the extra search-display patch remained unchanged. The patch itself changes exactly eleven bytes. No game executables or career snapshots are published.

## Remaining limits

- No broad market-balance study or guaranteed selling-time improvement.
- Extra bids may be undesirable for some players or clubs.
- Changes to offer valuations can affect both buyers and sellers.
- Existing saved transfers or offers are not reversed when removing the patch.
- Unsupported executable layouts and other patches affecting the recruitment routine are rejected rather than assumed compatible.
- The exact Nick's Patcher UI flow has been checked against its source; this release does not claim a new visual UI installation test.
