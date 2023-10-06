-- Add missing Seasons object, if not available (e.g. 1.14.0 and below is missing it)
if not C_Seasons then
    C_Seasons = {
        HasActiveSeason = function()
            return false
        end,
        GetActiveSeason = function()
            return 0
        end
    }
end

-- Specific subclass of this mixin was added in a minor version and is missing in earlier patches, functionality this makes next to no visual difference
if not TooltipBackdropTemplateMixin then
    TooltipBackdropTemplateMixin = BackdropTemplateMixin
end    
