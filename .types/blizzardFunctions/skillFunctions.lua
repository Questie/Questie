---@meta
------ SKILL FUNCTIONS
---@param index number
---[Documentation](https://wowpedia.fandom.com/wiki/API_ExpandSkillHeader)
function ExpandSkillHeader(index) end

---@return number numSkills @Total number of skills
---[Documentation](https://wowpedia.fandom.com/wiki/API_GetNumSkillLines)
function GetNumSkillLines() end


---@param index number
---@return string skillName         @Name of the skill line.
---@return number isHeader          @Returns 1 if the line is a header, nil otherwise.
---@return number isExpanded        @Returns 1 if the line is a header and expanded, nil otherwise.
---@return number skillRank         @The current rank for the skill, 0 if not applicable.
---@return number numTempPoints     @Temporary points for the current skill.
---@return number skillModifier     @Skill modifier value for the current skill.
---@return number skillMaxRank      @The maximum rank for the current If this is 1 the skill is a proficiency.
---@return number isAbandonable     @Returns 1 if this skill can be unlearned, nil otherwise.
---@return number stepCost          @Returns 1 if skill can be learned, nil otherwise.
---@return number rankCost          @Returns 1 if skill can be trained, nil otherwise.
---@return number minLevel          @Minimum level required to learn this skill.
---@return number skillCostType
---@return string skillDescription  @Localized skill description text
---[Documentation](https://wowpedia.fandom.com/wiki/API_GetSkillLineInfo)
function GetSkillLineInfo(index) end
