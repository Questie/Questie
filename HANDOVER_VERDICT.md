 Verdict

 Net: refactor is improvement, but not ready without small fixes/tests.

 Best parts:
 - FontMeasure centralizes hidden FontString setup. Less duplication.
 - WrappedText char-array flow cleaner than repeated utf8.sub.
 - Fast path still avoids UTF-8 decode.
 - .toc load order correct.
 - Tooltip layout still keeps stable-width model.

 Big risk:
 - uncommitted WrappedText.lua rewrite changes behavior and tests barely changed.

 Must fix / decide before merge

 1. Tooltip body font bug remains
     - TooltipLayout.lua:145-156, 245
     - Description measurement can still fall back to TextLeft1 header font.
     - This matches original suspicion: line 1 larger font causes early wrapping.
     - Fix next: body-font lookup should prefer TextLeft2, avoid TextLeft1 for descriptions except emergency.

 2. RowSpan() missing API guard
     - FontMeasure.lua:108-109
     - Comment says fallback handles missing row spans, but missing method hard-errors.
     - Add:
    ```lua
      if type(fontString.CalculateScreenAreaFromCharacterSpan) ~= "function" then
          return nil
      end
    ```

 3. combineTrailing=true behavior changed
     - Current smoke:
    ```text
      TextWrap("one two three four", "", true, 7)

      utf8-word-wrap: one two |three |four
      current:        one two |three four
    ```
     - Maybe better by intent, but it is behavior change.
     - Add explicit regression test or revert uncommitted rewrite.

 4. Tests don’t prove refactor
     - WrappedText.test.lua only added FontMeasure require.
     - TooltipLayout.test.lua:54-63 stubs WrappedText, so real integration untested.
     - Need tests for:
         - CalculateScreenAreaFromCharacterSpan == nil
         - missing row-span method
         - body font vs header font
         - full-array wrapped output, not only first line + concat
         - multi-line combineTrailing=true

 Further improvements

 - FontMeasure.lua:51-80: fallback font captured once. Could go stale if font changes after first wrap. Re-read defaultFontSource:GetFont() in MatchFont(nil).
 - WrappedText.lua:311-313: reentrant call logs error but continues. Better hard-return/error.
 - WrappedText.lua:323-334: if error happens while shown, measurer stays shown. Optional pcall/finally cleanup.
 - utf8.lua: add newline at EOF.

 Validation done

 Passed:

 ```bash
   luac -p Modules/Libs/utf8.lua Modules/Libs/FontMeasure.lua Modules/Libs/WrappedText.lua Modules/Tooltips/TooltipLayout.lua Modules/Libs/WrappedText.test.lua Modules/Tooltips/TooltipLayout.test.lua
   git diff --check utf8-word-wrap --
 ```

 Blocked:

 ```text
   busted unavailable
   luacheck unavailable
 ```

 Recommendation

 Keep FontMeasure extraction. Fix body-font fallback + row-span guard. Then either add tests for uncommitted WrappedText rewrite or drop that rewrite for safer merge.