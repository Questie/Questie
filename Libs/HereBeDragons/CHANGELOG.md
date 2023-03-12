# Lib: HereBeDragons

## [2.09-release](https://github.com/Nevcairiel/HereBeDragons/tree/2.09-release) (2022-08-29)
[Full Changelog](https://github.com/Nevcairiel/HereBeDragons/compare/2.08-release...2.09-release) [Previous Releases](https://github.com/Nevcairiel/HereBeDragons/releases)

- Unify WoW version checks  
- Update TOC  
- Move DK starting area override into transforms  
    The instance ID overrides were meant for dynamic phasing, not  
    permanently instanced zones, which the transform was designed for  
    instead, even if the map coordinates are not transformed.  
    This should make the behavior more consistent for users.  
- Don't use expansion level checks, they may not be present in all clients  
- Fix handling of pins from phased sub maps  
- Add Wrath Classic support  
