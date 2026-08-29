-- luacheck: globals pending

dofile("setupTests.lua")

local CompatibilityCases = dofile("cli/mocks/BlizzardCBORCompatibilityCases.lua")
local Fixtures = dofile("cli/mocks/BlizzardCBORCompatibilityFixtures.lua")

---@param bytes string Binary string to format.
---@return string hex Lowercase hexadecimal representation.
local function _ToHex(bytes)
    local output = {}

    for i = 1, string.len(bytes) do
        output[i] = string.format("%02x", string.byte(bytes, i))
    end

    return table.concat(output)
end

---@return table<string, BlizzardCBORCompatibilityCase> casesById Cases keyed by fixture id.
local function _BuildCaseLookup()
    local casesById = {}

    for _, compatibilityCase in ipairs(CompatibilityCases.GetCases()) do
        casesById[compatibilityCase.id] = compatibilityCase
    end

    return casesById
end

---@return table[] capturedFixtures Fixture/case pairs with captured Blizzard output or error.
local function _GetCapturedFixtures()
    local capturedFixtures = {}

    for caseId, fixture in pairs(Fixtures.cases) do
        if fixture.blizzardHex ~= nil or fixture.blizzardError ~= nil then
            table.insert(capturedFixtures, {
                caseId = caseId,
                fixture = fixture,
                compatibilityCase = CompatibilityCases.GetCaseById(caseId),
            })
        end
    end

    table.sort(capturedFixtures, function(left, right)
        return left.caseId < right.caseId
    end)

    return capturedFixtures
end

---@return BlizzardCBORMock? BlizzardCBOR Loaded pure Lua serializer mock, if present.
---@return string? errorMessage Load error when the mock is unavailable.
local function _LoadBlizzardCBOR()
    local loaded, mockOrError = pcall(dofile, "cli/mocks/BlizzardCBOR.lua")
    if not loaded then
        return nil, tostring(mockOrError)
    end

    return mockOrError, nil
end

---@param value any Value returned by a depth fixture builder.
---@return number depth Number of table levels reached by following index 1.
local function _GetNestedArrayDepth(value)
    local depth = 0

    while type(value) == "table" do
        depth = depth + 1
        value = value[1]
    end

    return depth
end

describe("BlizzardCBORCompatibility", function()
    describe("case definitions", function()
        it("should expose unique fixture ids and callable builders", function()
            local seenIds = {}
            local cases = CompatibilityCases.GetCases()

            assert.is_true(#cases > 0)

            for _, compatibilityCase in ipairs(cases) do
                assert.are_same("string", type(compatibilityCase.id))
                assert.are_same("string", type(compatibilityCase.category))
                assert.are_same("string", type(compatibilityCase.description))
                assert.are_same("number", type(compatibilityCase.argumentCount))
                assert.are_same("function", type(compatibilityCase.buildArguments))
                assert.is_nil(seenIds[compatibilityCase.id])

                seenIds[compatibilityCase.id] = true

                -- Builders must be safe to call during fixture validation. The
                -- returned values may still intentionally fail serialization.
                compatibilityCase.buildArguments()
            end
        end)

        it("should keep boundary cases aligned with their fixture ids", function()
            local omittedValueCase = CompatibilityCases.GetCaseById("omitted-value")
            local sparseSmallGapCase = CompatibilityCases.GetCaseById("table-sparse-small-gap")
            local depth100Case = CompatibilityCases.GetCaseById("table-nested-depth-100")
            local depth101Case = CompatibilityCases.GetCaseById("table-nested-depth-101")
            local ignoredMapKeyCase = CompatibilityCases.GetCaseById("unsupported-function-map-key-ignored")

            assert.is_true(omittedValueCase.expectSerializeError)
            assert.is_nil(sparseSmallGapCase.mapOrderUnstable)
            assert.are_same(100, _GetNestedArrayDepth(depth100Case.buildArguments()))
            assert.are_same(101, _GetNestedArrayDepth(depth101Case.buildArguments()))
            assert.is_true(depth101Case.expectSerializeError)
            assert.is_nil(ignoredMapKeyCase.expectSerializeError)
            assert.are_same(2, ignoredMapKeyCase.argumentCount)
        end)
    end)

    describe("fixture file", function()
        it("should have the expected editable shape", function()
            local casesById = _BuildCaseLookup()

            assert.is_table(Fixtures)
            assert.is_table(Fixtures.metadata)
            assert.is_table(Fixtures.cases)

            for caseId, fixture in pairs(Fixtures.cases) do
                assert.are_same("string", type(caseId))
                assert.is_table(fixture)
                assert.is_table(casesById)
                assert.is_not_nil(casesById[caseId])
                assert.is_false(fixture.blizzardHex ~= nil and fixture.blizzardError ~= nil)

                if fixture.blizzardHex ~= nil then
                    assert.are_same("string", type(fixture.blizzardHex))
                    assert.is_true(string.match(fixture.blizzardHex, "^[0-9a-f]*$") ~= nil)
                    assert.are_same(0, string.len(fixture.blizzardHex) % 2)
                end

                if fixture.blizzardError ~= nil then
                    assert.are_same("string", type(fixture.blizzardError))
                end

                if fixture.compareLocally ~= nil then
                    assert.are_same("boolean", type(fixture.compareLocally))
                end
            end
        end)
    end)

    describe("captured Blizzard byte fixtures", function()
        it("should match the pure Lua serializer once fixtures are captured", function()
            local capturedFixtures = _GetCapturedFixtures()

            if #capturedFixtures == 0 then
                pending("No Blizzard CBOR fixtures captured yet; run /qcborcompat in-game and copy SavedVariables into the fixture file.")
                return
            end

            local BlizzardCBOR, loadError = _LoadBlizzardCBOR()
            assert.is_table(BlizzardCBOR, loadError)
            assert.is_function(BlizzardCBOR.SerializeCBOR)

            local comparedCount = 0
            local skippedForMapOrder = 0

            for _, capturedFixture in ipairs(capturedFixtures) do
                local compatibilityCase = capturedFixture.compatibilityCase
                local fixture = capturedFixture.fixture

                assert.is_table(compatibilityCase)

                if fixture.blizzardHex ~= nil then
                    if compatibilityCase.mapOrderUnstable and fixture.compareLocally ~= true then
                        skippedForMapOrder = skippedForMapOrder + 1
                    else
                        local ok, outputOrError = CompatibilityCases.CallSerialize(BlizzardCBOR.SerializeCBOR, compatibilityCase)

                        assert.is_true(ok, capturedFixture.caseId .. " errored locally: " .. tostring(outputOrError))
                        assert.are_same(fixture.blizzardHex, _ToHex(outputOrError))
                        comparedCount = comparedCount + 1
                    end
                elseif fixture.blizzardError ~= nil then
                    local ok = CompatibilityCases.CallSerialize(BlizzardCBOR.SerializeCBOR, compatibilityCase)

                    assert.is_false(ok, capturedFixture.caseId .. " was expected to error like Blizzard")
                    comparedCount = comparedCount + 1
                end
            end

            if comparedCount == 0 and skippedForMapOrder > 0 then
                pending("Captured fixtures only cover unsorted-map cases; set compareLocally=true "
                    .. "only after confirming local table iteration order matches the capture.")
            end
        end)
    end)
end)
