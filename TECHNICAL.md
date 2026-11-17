# Technical notes

This patch changes one operand in the existing transfer-listed recruitment bonus, plus a dedicated double-precision constant. It does not add a new hook or overwrite the game's shared 1.05 constant.

| Item | Virtual address | File offset |
| --- | --- | --- |
| Existing `fmul qword ptr [...]` instruction | `0x008411C1` | `0x004411C1` |
| Original shared constant, 1.05, unchanged | `0x009689B8` | `0x005689B8` |
| New dedicated constant, 1.35 | `0x00FE6200` | `0x008DB200` |

The instruction's address operand changes from `0x009689B8` to `0x00FE6200`. The new constant is little-endian IEEE-754 binary64: `9A 99 99 99 99 99 F5 3F`. Eleven bytes differ; file length, PE headers and section layout do not change.

Equivalent change, shown as assembly pseudocode:

```asm
; Existing conditional transfer-list / transfer-request branch is retained.
; Old: fmul qword ptr [0x009689B8] ; shared 1.05
fmul qword ptr [0x00FE6200]       ; dedicated 1.35

; At 0x00FE6200 in pre-existing expanded space:
dq 1.35
```

The compatibility checker verifies the complete known recruitment routine at file offsets `[0x00440D80, 0x00441FE0)`. Its SHA-256, with only this patch's operand normalized to the original value, is:

`0a4802ef314ed8d84bbc284ecae98096063766223704aaf009c52c37be8b7387`

It also checks x86 PE32 with image base 0x00400000, the code and constant mappings, the shared original constant, 64 bytes of reserved space, installed/uninstalled states, and the exact contents of the two patch files. The checker never writes to the executable. It is a conservative compatibility screen, not a full executable audit.

The changed rating feeds candidate selection and offer valuation. The patch does not bypass the normal affordability, squad, eligibility or willingness checks. It applies to listed/requesting players at both human and AI clubs.

The removal patch reverses exactly these eleven changed bytes. Original 3.9.68 game code is not distributed in this repository.

Initial reverse-engineering references, followed by checks against the tested executable:

- [Recruitment function map](https://github.com/maxevans60/cm0102-bosman-edition/blob/main/docs/research/function-map/shortlist_manager.cpp.md)
- [Offer function map](https://github.com/maxevans60/cm0102-bosman-edition/blob/main/docs/research/function-map/transfer_offer.cpp.md)
- [Nick's Patcher source](https://github.com/nckstwrt/CM0102Patcher)

The binary patch is not intended for Bosman Edition's rebuilt executable.
