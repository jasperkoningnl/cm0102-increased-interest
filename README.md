# Increased transfer interest for CM01/02

**Version 0.1 beta, 17 November 2026.** A community patch for compatible, expanded Championship Manager 01/02 3.9.68 executables.

Makes transfer-listed players more attractive to buying clubs by increasing the game's existing recruitment-rating bonus from **5% to 35%** (multiplier **1.05 to 1.35**).

**[Download patch package (.zip)](https://github.com/jasperkoningnl/cm0102-increased-interest/archive/refs/heads/main.zip)**

This is GitHub's repository ZIP. Extract it and open the `cm0102-increased-interest-main` folder to find the patch and checker together.

## What changes

The game already gives a bonus when another club evaluates a player who is transfer-listed or has requested a transfer. This patch increases that bonus in the existing evaluation routine. It can help players become recruitment targets and receive offers through the normal transfer system.

- Applies to players at **human and AI clubs**, not only your own squad.
- Does not change player attributes, club finances, contracts, transfer windows or save-file data.
- Does not directly change the daily search schedule or guarantee an offer, sale or particular response time.
- Existing price, wage, squad, eligibility and player-willingness checks remain in place.
- Can also affect the valuations used when preparing offers. This is a transfer-market balance change, not just a display improvement.

## Practical experience

The author reports using this exact 1.35 setting over **multiple transfer windows** in an ongoing career. The increase in interest and bids was clearly noticeable and generally positive. The trade-off was **sometimes a lot of bids for players**.

That is one player's experience, not a controlled league-wide or long-term balance study. Other squads, reputations, asking prices and financial situations may produce different results. This beta offers the single tested 1.35 setting; it has no in-game intensity slider.

## Install with Nick's Patcher

1. Download the patch package using the link above (or **Code > Download ZIP**) and extract it.
2. Close CM01/02. Make a backup of the **executable you actually launch**, such as `cm0102.exe`.
3. Drag that executable onto **CheckCompatibility.cmd**. Continue only if it says **PASS INSTALL**. The checker only reads files. **ALREADY INSTALLED** means no installation is needed. If it says **NOT SUPPORTED**, do not install this beta.
4. Open [Nick's CM0102Patcher](https://github.com/nckstwrt/CM0102Patcher/releases), select the same executable, then use **Tools > Apply Patchfile** and choose **IncreasedTransferInterest.patch**.
5. Run the compatibility check again. It should now say **ALREADY INSTALLED**.
6. Start the game normally and load your career. No new game or save conversion is required for this executable-only change.

This is an **external patch file**, not a built-in Nick's Patcher option. Nick's external patch loader does not enforce the old-byte values in patch files, so the separate compatibility check matters. Do not patch a running executable. Windows may require administrator permission when your game is installed in Program Files.

## Compatibility

Requires the expanded 3.9.68 layout used by Nick's Patcher, with the expected recruitment routine and unused constant space. An unexpanded original executable is not supported. Bosman Edition and other rebuilt executables are not supported by this beta.

The checker verifies the full known recruitment routine, the relevant memory mappings, the original constant, reserved space, and both patch files. It deliberately rejects a different routine even when the difference might be harmless. A pass checks these known points; it cannot prove compatibility with every other mod or executable.

It has been byte-checked alongside the author's [two-footed search marker](https://github.com/jasperkoningnl/cm0102-two-footed-search), which uses separate locations. No claim is made for every patch combination.

## Remove

Close the game. Restoring your executable backup restores its earlier settings, including any other patches present when you made that backup.

To remove **only this beta**, first back up the current executable and drag it onto **CheckBeforeRemoval.cmd**. Continue only if it says **PASS REMOVE**, then use Nick's Patcher to apply **RemoveIncreasedTransferInterest.patch**. Run CheckCompatibility.cmd afterward; it should say **PASS INSTALL** again. Later incompatible changes to the relevant code or reserved space must be investigated before using the removal patch.

Removing the patch stops the increased bonus in future evaluations. It does not undo transfers, offers or other career events already saved while using it.

## Evidence and feedback

In a controlled replay of the original game routines using a saved career state, the unmodified code added none of 14 listed players to buying clubs' internal shortlists. This setting added five players to ten player-club shortlist combinations. The normal offer routine then generated a bid for one tested player. These were emulated routine calls, not simulated calendar days, and they do not measure bids per week. See [TESTING.md](TESTING.md).

Please use [Issues](https://github.com/jasperkoningnl/cm0102-increased-interest/issues) to report your game version, executable/patch combination, league, whether the checker passes, and what happened over a transfer window. Do not upload game executables, saves or private configuration files.

## Contents

- Installation and removal `.patch` files.
- Read-only Windows compatibility checker and two drag-and-drop launchers.
- [Technical description](TECHNICAL.md), test notes and reproducible packaging script.

No game executable, database, save, private configuration or Nick's Patcher distribution is included. Independent community beta, not an official Sports Interactive or Nick's Patcher release.
