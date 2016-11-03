# phisFactionSwitcher
WoW addon which changes the "watched faction" in the reputation pane depending on different conditions (tabard/zone/last reputation gain)

## Usage
The addon automatically switches the watched faction so there is nothing you have to do. For now.

## File Description
- **phisFactionSwitcher.lua** contains the main code
- **phisFactionSwitcher.toc** is the standard WoW table-of-contents file containing addon information
- **phisTables.lua** contains tables to assign faction IDs to corresponding tabards and zones

## Changes
- **1.0**: Initial release

## To-Do
- [ ] Tabard takes precedence over zone rep
- [ ] Handle zones with multiple factions (random/highest rep/...?)
- [ ] Include Vashj'ir subzones
- [ ] Implement an useful function for the `/preps` slash command
