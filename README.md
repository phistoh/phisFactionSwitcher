# phisFactionSwitcher
WoW addon which changes the "watched faction" in the reputation pane depending on different conditions (tabard/zone/last reputation gain)

## Usage
The addon automatically switches the watched faction so there is nothing you have to do. You can temporarily toggle the automatic switching with `/pfs toggle`

## File Description
- **phisFactionSwitcher.lua** contains the main code
- **phisFactionSwitcher.toc** is the standard WoW table-of-contents file containing addon information
- **phisTables.lua** contains tables to assign faction IDs to corresponding tabards and zones

## To-Do
- [ ] Implement guild tabard
- [ ] ~~Implementing some kind of precedence (tabard > zone > last reputation)~~
- [ ] Handle zones with multiple factions (random/highest rep/...?)
- [ ] Include Dragonflight factions