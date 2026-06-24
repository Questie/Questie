-- Stable CI entrypoint; the testable implementation lives in cli/validators/localizationLookupValidator.lua.
local LocalizationLookupValidator = require("cli.validators.localizationLookupValidator")

LocalizationLookupValidator.Validate()
