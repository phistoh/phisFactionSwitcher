# phisFactionSwitcher
WoW addon which changes the "watched faction" in the reputation pane depending on different conditions (tabard/zone/last reputation gain)

## Usage
The addon automatically switches the watched faction so there is nothing you have to do. For now.

## File Description
- **phisFactionSwitcher.lua** contains the main code
- **phisFactionSwitcher.toc** is the standard WoW table-of-contents file containing addon information
- **phisTables.lua** contains tables to assign faction IDs to corresponding tabards and zones

## Changes
- **1.0.3**: Exempts Legion factions from ignoring to switch when exalted (-> you can see your current Paragon progress)
- **1.0.2**: Includes "Armies of the Legionfall"
- **1.0.1**: Disabled "Already exalted with [faction name]." message when wearing a tabard
- **1.0**: Initial release

## To-Do
- [ ] Implementing some kind of precedence (tabard > zone > last reputation)
- [ ] Handle zones with multiple factions (random/highest rep/...?)
- [ ] Include Vashj'ir subzones
- [ ] Implement an useful function for the `/preps` slash command
