# Lib: HereBeDragons

## [2.16-release](https://github.com/Nevcairiel/HereBeDragons/tree/2.16-release) (2026-01-21)
[Full Changelog](https://github.com/Nevcairiel/HereBeDragons/compare/2.15-release...2.16-release) [Previous Releases](https://github.com/Nevcairiel/HereBeDragons/releases)

- Add TBC Anniversary TOC  
- Only perform instance checks when both the instance and map are updated  
- Do not use the overriden instance for the instance zone check  
    Instance Zones are determined at load, and dynamic overrides don't help  
    here, and may in fact cause unexpected issues.  
    Fixes #21  
- Remove manual zone translation, the automated process handles this now  
- Update TOC  
- Skip minimap updates when the minimap is hidden  
- Handle instanced sub-zones on continent maps  
    This cleans up processing of sub-zones in different instances with  
    different scale, allowing full translation upwards (from zone to  
    continent and world).  
    Translating downwards is not supported (yet).  
- Incrase max map id to 3000, as Midnight crosses the 2500 boundary  
