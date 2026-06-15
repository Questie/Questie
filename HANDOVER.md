# Handover: Tooltip Wrapping / UTF-8 Word Wrap Refactor

## Branch / Repository State

- Repository: Questie WoW addon (`/home/david/private/qu`)
- Current branch: `utf8-word-wrap-refactor`
- Current `HEAD`: `a992ea88b`
- Compared against `master`: `fce73c70a`
- Primary feature area: map icon tooltip description wrapping, UTF-8/CJK-safe text wrapping, tooltip width measurement.

## High-Level Goal

This branch refactors Questie's text wrapping behavior so map icon tooltip descriptions wrap more predictably, especially for Chinese/CJK text and numeric tokens. The main bug class being addressed is tooltip text moving to a new row too early or at unstable positions because wrapping was previously tied to tooltip width while the tooltip itself was still growing.

The new approach is:

1. Build tooltip content into an explicit row model instead of rendering directly.
2. Measure non-description rows first to determine a stable tooltip text width.
3. Wrap description rows after that width is known.
4. Render the tooltip once.
5. Use UTF-8-aware wrapping so Chinese/CJK characters are not split at byte boundaries.
6. Prevent numeric tokens like `50%`, `1,050`, and full-width variants from being split mid-number.

## User-Observed / Suspected Problem

User reported:

> We had some issues with the text changing row a bit too early, i think it probably has to do with Scaling and font size and so on.
>
> I know for a fact that the ingame GameTooltip's first line is a larger font than all the other lines, and i think we use line1 first hand to do most of the measurements right?

Analysis confirmed this is a plausible cause:

- Blizzard `GameTooltip` first line uses a larger header font.
- Body lines (`TextLeft2+`) use normal tooltip font.
- `TooltipLayout:_GetTooltipFontString` currently falls back from requested row to `TextLeft2`, then `TextLeft1`.
- If `TextLeft2` does not exist yet, measurement may fall back to `TextLeft1`.
- Measuring description/body text with line 1's larger font makes text appear wider to the wrapper.
- Wider measured text means row changes happen earlier than in the actual rendered body font.

Current code still has this risk in `Modules/Tooltips/TooltipLayout.lua`:

```lua
local fontString = _G[tooltipName .. textSide .. lineIndex]
    or _G[tooltipName .. textSide .. "2"]
    or _G[tooltipName .. textSide .. "1"]
```

Description font selection also still allows line 1 as emergency fallback:

```lua
local descriptionFontString = _GetTooltipFontString(tooltip, 2, "left") or _GetTooltipFontString(tooltip, 1, "left")
```

Recommended next fix: avoid using `TextLeft1` for description/body measurement unless absolutely unavoidable. Prefer `TextLeft2`, or a stable body-font template/source, for description wrapping.

## Initial Diff Against `master`

Initial command run:

```bash
git diff --name-status master...HEAD
git status --short
```

Initial changed files against master were:

```text
M	Modules/Journey/QuestieJourneyUtils.lua
M	Modules/Libs/QuestieLib.lua
A	Modules/Libs/WrappedText.lua
A	Modules/Libs/WrappedText.test.lua
A	Modules/Libs/utf8.lua
M	Modules/Tooltips/MapIconTooltip.lua
A	Modules/Tooltips/TooltipLayout.lua
A	Modules/Tooltips/TooltipLayout.test.lua
M	Questie-BCC.toc
M	Questie-Cata.toc
M	Questie-Classic.toc
M	Questie-Mists.toc
M	Questie-WOTLKC.toc
```

At that time there was also an untracked file:

```text
OBJECTIVE_ORDER_MOVES.md
```

That untracked file appears unrelated to tooltip wrapping. It documents objective ordering corrections.

Later branch state includes an additional tracked file against master:

```text
A	Modules/Libs/FontMeasure.lua
```

Current `master...HEAD` diffstat at handover time:

```text
 Modules/Journey/QuestieJourneyUtils.lua |   4 +-
 Modules/Libs/FontMeasure.lua            | 136 +++++++++++++
 Modules/Libs/QuestieLib.lua             | 101 ----------
 Modules/Libs/WrappedText.lua            | 335 ++++++++++++++++++++++++++++++++
 Modules/Libs/WrappedText.test.lua       | 209 ++++++++++++++++++++
 Modules/Libs/utf8.lua                   |  59 ++++++
 Modules/Tooltips/MapIconTooltip.lua     |  74 +++----
 Modules/Tooltips/TooltipLayout.lua      | 288 +++++++++++++++++++++++++++
 Modules/Tooltips/TooltipLayout.test.lua | 168 ++++++++++++++++
 Questie-BCC.toc                         |   4 +
 Questie-Cata.toc                        |   4 +
 Questie-Classic.toc                     |   4 +
 Questie-Mists.toc                       |   4 +
 Questie-WOTLKC.toc                      |   4 +
 14 files changed, 1255 insertions(+), 139 deletions(-)
```

Current working tree also has unstaged changes:

```text
 M Modules/Libs/WrappedText.lua
 M Modules/Libs/utf8.lua
?? OBJECTIVE_ORDER_MOVES.md
?? HANDOVER.md
```

`HANDOVER.md` is this file.

## Main Files And Responsibilities

### `Modules/Libs/QuestieLib.lua`

Old `QuestieLib:TextWrap` was removed from `QuestieLib`.

Removed old behavior included:

- direct hidden `FontString` management inside `QuestieLib`
- byte-index-heavy wrapping logic
- old `combineTrailing = combineTrailing or true` bug, which made `false` impossible to pass intentionally
- quest-log font/object access mixed into general utility library

Reason: wrapping logic now belongs in dedicated `WrappedText` module.

### `Modules/Libs/utf8.lua`

New module for UTF-8-safe operations on Lua 5.1 strings.

Currently provides:

- `utf8.sub(s, i, j)`
  - character-indexed substring
  - prevents splitting Chinese/CJK multi-byte characters
- `utf8.strlen(s)`
  - counts UTF-8 characters/codepoints, not bytes
- `utf8.chars(s)`
  - currently unstaged addition
  - decodes whole string into array of UTF-8 characters once
  - used by current unstaged `WrappedText.lua` changes to avoid repeated `utf8.sub` calls

Important detail: file currently has no newline at EOF in unstaged diff. Fix before finalizing.

### `Modules/Libs/FontMeasure.lua`

New shared measurement abstraction around hidden WoW `FontString`.

Purpose:

- centralize hidden `FontString` creation
- centralize font matching from another `FontString`
- expose width and row-span methods used by wrapping/layout
- reduce duplicated font measurement setup in `WrappedText` and `TooltipLayout`

Public API:

- `FontMeasure.Create(config)` returns `FontMeasurer`
- `FontMeasurer:MatchFont(fontSource)`
- `FontMeasurer:SetWidth(width)`
- `FontMeasurer:SetText(text)`
- `FontMeasurer:UnboundedWidth()`
- `FontMeasurer:WrappedWidth()`
- `FontMeasurer:Overflows()`
- `FontMeasurer:RowSpan(startIndex, endIndex)`
- `FontMeasurer:MeasureWidth(text, fontSource)`
- `FontMeasurer:Show()` / `Hide()` / `IsShown()`

Potential concern:

- Needs `.toc` inclusion before `WrappedText.lua` and `TooltipLayout.lua`.
- Current `.toc` diff includes 4 lines per file, likely adding `FontMeasure.lua`, `utf8.lua`, `WrappedText.lua`, and `TooltipLayout.lua`.

### `Modules/Libs/WrappedText.lua`

New dedicated module replacing `QuestieLib:TextWrap`.

Responsibilities:

- emulate WoW quest-description wrapping
- preserve UTF-8 characters
- keep numeric tokens together
- optionally combine lone trailing word/glyph with previous line
- support optional `fontSource` so tooltip wrapping can measure with actual tooltip font instead of quest font

Current public API:

```lua
WrappedText:TextWrap(line, prefix, combineTrailing, desiredWidth, fontSource)
```

Important current behavior:

- `combineTrailing` now defaults to `false`.
- Direct callers can still pass `true` to enable old-style orphan combining.
- The hidden measuring `FontString` must be shown for WoW metric functions to work.
- It is hidden immediately after wrapping.
- Uses `FontMeasure` to manage measurement.

Current staged/HEAD-ish implementation had helper functions like:

- numeric token detection for ASCII and full-width digits
- numeric separator handling for `,`, `.`, `，`, `．`
- percent handling for `%` and `％`
- CJK/no-space fallback when row-span API does not report wrapping

Current unstaged implementation further refactors to:

- decode once via `utf8.chars(line)`
- use `_Slice(chars, from, to)` via `table.concat`
- use character index ranges throughout
- reduce repeated `utf8.sub`/`utf8.strlen` calls
- clamp numeric-token lookbehind/lookahead to current segment boundaries

Important caveat:

- This unstaged refactor should be validated carefully. It changes implementation shape significantly, though tests should still cover visible behavior.

### `Modules/Tooltips/TooltipLayout.lua`

New row-model layout module for tooltips.

Responsibilities:

1. Buffer rows via `TooltipLayout:CreateRows()`.
2. Measure non-description rows.
3. Derive stable tooltip text width.
4. Expand description rows using `WrappedText:TextWrap`.
5. Render all rows exactly once.

Current row builder API:

```lua
local rows = TooltipLayout:CreateRows()
rows:AddLine(text, ...)
rows:AddDoubleLine(leftText, rightText, ...)
rows:AddDescription(text, prefix, ...)
TooltipLayout:Render(tooltip, rows)
```

Important decision:

- `AddDescription` no longer accepts a `combineTrailing` argument.
- It always stores `combineTrailing=false`.

Current explanatory comment:

```lua
-- Keep combineTrailing disabled here. Combining can increase wrapped line width after measurement,
-- which would require recursive tooltip reflow to calculate a stable width.
```

Reason:

- If `combineTrailing=true`, wrapping can pull the final word/glyph back into previous line.
- That can make the previous line wider than the width calculated before rendering.
- Stable layout would require recursive reflow: measure, wrap, remeasure, rewrap until width converges.
- Simpler, safer behavior: tooltip descriptions never combine trailing text.

Current width logic:

- `MIN_TOOLTIP_TEXT_WIDTH = 375`
- non-description rows decide width above minimum
- `AddDoubleLine` width includes left width + right width + measured average double-line gap
- prefix width is subtracted from description wrap width

Potential current issue:

- `TooltipLayout` can still fall back to `TextLeft1` for measuring body/description text, which may be too large.
- First line font mismatch may be responsible for row changes happening too early.

### `Modules/Tooltips/MapIconTooltip.lua`

Changed from direct rendering to row-buffered rendering.

Previous pattern:

```lua
self:AddLine(...)
self:AddDoubleLine(...)
local lines = QuestieLib:TextWrap(rawLine, "  ", false, math.max(375, Tooltip:GetWidth()))
for _, line in pairs(lines) do
    self:AddLine(line, ...)
end
```

New pattern:

```lua
local tooltipRows = TooltipLayout:CreateRows()
tooltipRows:AddLine(...)
tooltipRows:AddDoubleLine(...)
tooltipRows:AddDescription(rawLine, "  ", ...)
TooltipLayout:Render(self, tooltipRows)
```

Reason:

- Directly rendering descriptions and querying `Tooltip:GetWidth()` while rendering can create width feedback.
- Description text can make tooltip wider, which changes wrap width, which changes row count/width, etc.
- New flow measures fixed rows first, then wraps descriptions against stable width.

### `Modules/Journey/QuestieJourneyUtils.lua`

Updated caller from:

```lua
QuestieLib:TextWrap(...)
```

to:

```lua
WrappedText:TextWrap(...)
```

This caller still passes `combineTrailing=true` in the seen diff:

```lua
WrappedText:TextWrap(line, '    ', true, 360)
```

That means Journey tooltip behavior can still use trailing-word combining intentionally. The forced `combineTrailing=false` decision only applies to `TooltipLayout:AddDescription`.

### `.toc` Files

All expansion `.toc` files were updated:

- `Questie-BCC.toc`
- `Questie-Cata.toc`
- `Questie-Classic.toc`
- `Questie-Mists.toc`
- `Questie-WOTLKC.toc`

Earlier diff showed additions:

```text
Modules\Libs\utf8.lua
Modules\Libs\WrappedText.lua
Modules\Tooltips\TooltipLayout.lua
```

Current branch also includes `Modules\Libs\FontMeasure.lua`, so verify all `.toc` files load modules in this order:

1. `Modules\Libs\utf8.lua`
2. `Modules\Libs\FontMeasure.lua`
3. `Modules\Libs\WrappedText.lua`
4. `Modules\Libs\QuestieLib.lua` or later unaffected libs
5. `Modules\Tooltips\TooltipLayout.lua`
6. `Modules\Tooltips\MapIconTooltip.lua`

`FontMeasure` must load before `WrappedText` and `TooltipLayout` because both import it.
`WrappedText` must load before `TooltipLayout` because `TooltipLayout` imports it.
`TooltipLayout` must load before `MapIconTooltip` because `MapIconTooltip` imports it.

## Tests Added / Updated

### `Modules/Libs/WrappedText.test.lua`

Covers:

- ASCII numbers are not split
- full-width numbers are not split
- comma-separated numbers are not split
- percent values are not split
- decimal percent values are not split
- full-width numeric separators are not split
- full-width percent values are not split
- full-width decimal percent values are not split
- normal punctuation like `1. Next` is not treated as numeric separator
- numeric suffixes can wrap independently where intended
- localized count/range unit examples
- trailing English word combining still works when `combineTrailing=true`
- single trailing Chinese glyph combining still works when `combineTrailing=true`
- single trailing ASCII character from an unbroken word is not combined
- single trailing Chinese glyph stays separate when combining disabled
- Chinese punctuation is not preferred as wrap point

Test mock:

- one UTF-8 character equals one width unit
- mock `FontString` implements width and row-span methods used by wrapper
- imports `utf8` and `FontMeasure`

### `Modules/Tooltips/TooltipLayout.test.lua`

Covers:

- `AddLine` and `AddDoubleLine` order preservation
- varargs packing preserves nil values
- descriptions wrap using non-description width minus prefix width
- `AddDescription` always passes `combineTrailing=false`
- double-line gap is included when deriving description width

Current test setup:

- mocks `UIParent:CreateFontString`
- mocks `CreateFrame` for hidden gap-measuring tooltip
- mocks tooltip font strings like `TestTooltipTextLeft1`, `TestTooltipTextLeft2`, etc.
- mocks gap measure tooltip rows 1 and 2

Potential test gap:

- No test currently verifies that description/body measurement avoids `TextLeft1` large header font.
- If fixing first-line font fallback, add a test where `TextLeft1` has larger measured width than `TextLeft2`, then assert description wrapping uses body font source/width.

## Validation History

From returned branch summary:

- `luac -p` validation was run successfully.
- `git diff --check` validation was run successfully.
- Full `busted` validation was not completed because local environment lacked dependencies.

Blocked validation:

- `busted` unavailable locally.
- Direct `lua` test run blocked by missing `bit32`.

Recommended validation when environment has dependencies:

```bash
busted Modules/Libs/WrappedText.test.lua Modules/Tooltips/TooltipLayout.test.lua
```

Then preferably:

```bash
busted -p ".test.lua" .
luacheck -q -- Database Localization Modules Public Questie.lua
```

At minimum before finalizing:

```bash
luac -p Modules/Libs/utf8.lua Modules/Libs/FontMeasure.lua Modules/Libs/WrappedText.lua Modules/Tooltips/TooltipLayout.lua Modules/Tooltips/MapIconTooltip.lua Modules/Journey/QuestieJourneyUtils.lua

git diff --check
```

## Summary Of Returned Conversation Branch

The user explored a different conversation branch before returning here. That branch's key points:

### Goal

Fix tooltip text wrapping/width behavior by simplifying `combineTrailing` handling, investigating/removing scale-matching code, and ensuring `AddDescription` always disables trailing-word combining.

### Constraints / Preferences

- Make as few changes as possible.
- Preserve simplified `AddDescription(text, prefix, ...)` call signature.
- Disable `combineTrailing` for tooltip descriptions because combined trailing words can invalidate width calculation and would require recursive tooltip reflow.
- Keep comments when they explain non-obvious behavior/failure modes.

### Completed There

- Investigated tooltip wrapping issues involving:
  - `QuestFont`
  - `GameTooltipText`
  - `UIParent`
  - `GameTooltip:GetEffectiveScale()`
  - `combineTrailing`
- Added then later removed effective-scale matching code from:
  - `Modules/Libs/WrappedText.lua`
  - `Modules/Tooltips/TooltipLayout.lua`
- Removed scale-specific tests/mocks from:
  - `Modules/Libs/WrappedText.test.lua`
  - `Modules/Tooltips/TooltipLayout.test.lua`
- Updated `WrappedText` so `combineTrailing` defaults to `false`, while direct `TextWrap(..., true, ...)` still supports `true`.
- Updated `TooltipLayout:CreateRows().AddDescription` signature to `AddDescription(text, prefix, ...)`.
- Ensured `AddDescription` always calls `_AppendTooltipDescription(..., false, ...)`.
- Added explanatory comment in `TooltipLayout.lua` about keeping `combineTrailing` disabled.
- Updated stale test calls in `TooltipLayout.test.lua` to remove old `combineTrailing` argument.
- Validated with `luac -p`.
- Validated with `git diff --check`.

### Still In Progress There

- Full test suite validation with `busted`.

### Blocked There

- `busted` unavailable locally.
- Direct `lua` test run blocked by missing `bit32`.

## Important Design Decisions

### 1. `combineTrailing` default changed to false

Old code intended to allow `false`, but used:

```lua
combineTrailing = combineTrailing or true
```

That always converted `false` to `true`.

New behavior:

```lua
if (combineTrailing == nil) then
    combineTrailing = false
end
```

Why:

- Tooltip descriptions need stable width.
- Combining trailing word/glyph can increase a line beyond measured width.
- Direct callers can still opt in explicitly with `true`.

### 2. Tooltip descriptions force `combineTrailing=false`

`TooltipLayout:AddDescription` uses simplified signature:

```lua
AddDescription(text, prefix, ...)
```

No public `combineTrailing` parameter for tooltip descriptions.

Reason:

- It avoids exposing an option that can destabilize layout.
- It prevents accidental recursive reflow requirements.

### 3. Scale matching removed

Effective-scale matching was investigated but removed.

Reason from branch summary:

- User suspected `combineTrailing` was the real culprit.
- Scale code increased complexity.
- Current focus is stable measurement/font matching rather than scale matching.

Current newer suspicion:

- First-line `GameTooltip` font mismatch may be another culprit.
- This should be investigated/fixed separately and minimally.

### 4. Font measuring abstracted into `FontMeasure`

This reduces duplicated `FontString` setup and makes future measurement fixes easier.

Potential tradeoff:

- Adds one more module and `.toc` dependency ordering.
- Tests must require/mock it.

## Current Open Issue: First-Line Font Fallback

User specifically suspected line 1 font size. Current code supports that suspicion.

### Why It Matters

`GameTooltipTextLeft1` is larger than body text. If description wrapping measures with line 1 font, text appears wider during measurement than it will be during body rendering. This causes earlier line breaks.

### Current Risky Code

In `TooltipLayout.lua`:

```lua
local fontString = _G[tooltipName .. textSide .. lineIndex]
    or _G[tooltipName .. textSide .. "2"]
    or _G[tooltipName .. textSide .. "1"]
```

And:

```lua
local descriptionFontString = _GetTooltipFontString(tooltip, 2, "left") or _GetTooltipFontString(tooltip, 1, "left")
```

### Suggested Minimal Fix

Introduce a body-font lookup path that does not prefer or normally fall back to line 1.

Possible approach:

```lua
local function _GetTooltipBodyFontString(tooltip, side)
    local tooltipName = tooltip:GetName()
    if not tooltipName then
        return nil
    end

    local textSide = side == "right" and "TextRight" or "TextLeft"
    return _G[tooltipName .. textSide .. "2"]
        or (side == "right" and _G[tooltipName .. "TextLeft2"] or nil)
end
```

Then description wrapping uses body font:

```lua
local descriptionFontString = _GetTooltipBodyFontString(tooltip, "left")
```

If `TextLeft2` is unavailable, safer fallback options to consider:

1. `GameTooltipText` template-derived measurement font from `FontMeasure` with no font source.
2. create/prime a hidden tooltip with two lines and measure line 2 font.
3. only as last emergency, use `TextLeft1`.

Need test to lock behavior:

- Mock `TextLeft1` font to measure wider than `TextLeft2`.
- Ensure description wraps using `TextLeft2` or default body font, not `TextLeft1`.

### Avoid Over-Fixing

User prefers few changes. Best next patch should be narrow:

- Fix description/body font selection only.
- Add one focused test.
- Avoid reintroducing scale-matching unless proven necessary.

## Current Unstaged Changes In `WrappedText.lua` / `utf8.lua`

At handover time, two files have unstaged changes relative to current `HEAD`:

```text
 M Modules/Libs/WrappedText.lua
 M Modules/Libs/utf8.lua
```

### `utf8.lua` unstaged change

Adds:

```lua
function utf8.chars(s)
  local chars = {}
  for c in s:gmatch(_CHARPAT) do
    chars[#chars + 1] = c
  end
  return chars
end
```

Purpose: decode once and allow O(1) character indexing.

### `WrappedText.lua` unstaged change

Refactors wrapping internals to operate on decoded character arrays and segment ranges.

Key new helpers:

- `_Slice(chars, from, to)`
- `_HasSpaceIn(chars, from, to)`
- `_LastSpaceIn(chars, from, to)`
- `_FirstOverflowIndex(textMeasurer, chars, from)`
- `_ChooseBreak(chars, from, overflowIndex)`
- `_ShouldCombineTrailing(chars, charCount, nextStartIndex, brokeAtSpace, trailingFitsOneRow)`
- `_SplitIntoSegments(textMeasurer, chars, combineTrailing)`

Expected benefit:

- cleaner index model
- fewer repeated UTF-8 substring/length operations
- less risk of restoring measurer text incorrectly
- numeric lookaround constrained to current segment

Risk:

- Large internal rewrite compared with previous implementation.
- Needs test validation.
- Ensure EOF newline in `utf8.lua`.

## Suggested Next Steps

1. Decide whether to keep the unstaged `WrappedText.lua` / `utf8.lua` refactor.
   - If keeping: run all targeted tests when dependencies exist.
   - If minimizing change: consider reverting these unstaged internal refactors before fixing font fallback.

2. Fix first-line font fallback in `TooltipLayout.lua`.
   - Ensure description/body text measurement does not use `TextLeft1` unless no body font source exists.
   - Add focused test for line 1 larger than line 2.

3. Verify `.toc` ordering includes `FontMeasure.lua` before importers.

4. Run syntax checks:

```bash
luac -p Modules/Libs/utf8.lua Modules/Libs/FontMeasure.lua Modules/Libs/WrappedText.lua Modules/Tooltips/TooltipLayout.lua Modules/Tooltips/MapIconTooltip.lua Modules/Journey/QuestieJourneyUtils.lua
```

5. Run whitespace check:

```bash
git diff --check
```

6. Run targeted tests when environment supports it:

```bash
busted Modules/Libs/WrappedText.test.lua Modules/Tooltips/TooltipLayout.test.lua
```

7. If possible, run full test/lint:

```bash
busted -p ".test.lua" .
luacheck -q -- Database Localization Modules Public Questie.lua
```

## Non-Goals / Things Not To Do Without More Evidence

- Do not reintroduce effective-scale matching unless a clear scale mismatch is reproduced.
- Do not make tooltip descriptions use `combineTrailing=true` again without implementing stable recursive reflow.
- Do not move wrapping logic back into `QuestieLib`.
- Do not rely on byte-based string slicing for CJK text.
- Do not treat all punctuation as numeric separators.
- Do not include `OBJECTIVE_ORDER_MOVES.md` in this tooltip-wrapping work unless explicitly requested; it appears unrelated.

## Quick Mental Model For Future Agent

- `WrappedText` answers: "Given text, font, and width, where should lines break?"
- `TooltipLayout` answers: "What width should tooltip descriptions use, and in what order should rows render?"
- `MapIconTooltip` answers: "What rows should this specific tooltip contain?"
- `FontMeasure` answers: "How do we ask WoW's renderer for text metrics consistently?"
- `utf8` answers: "How do we avoid splitting multibyte characters in Lua 5.1?"

Most likely next bug source: measuring body text with line 1 header font.
Most important current invariant: tooltip descriptions must wrap after stable width is known and with `combineTrailing=false`.
