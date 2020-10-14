# phisFactionSwitcher
WoW addon which changes the "watched faction" in the reputation pane depending on different conditions (tabard/zone/last reputation gain)

## Usage
The addon automatically switches the watched faction so there is nothing you have to do. You can temporarily toggle the automatic switching with `/pfs toggle`

## File Description
- **phisFactionSwitcher.lua** contains the main code
- **phisFactionSwitcher.toc** is the standard WoW table-of-contents file containing addon information
- **phisTables.lua** contains tables to assign faction IDs to corresponding tabards and zones

## Changes
- **1.1.5**: Update for Shadowlands pre-expansion patch (9.0.1) (new interface number)
- **1.1.4**: Only changes the watched faction if the player is watching a faction
- **1.1.3**: Update for BfA Visions of N'Zoth (8.3) (new interface number)
- **1.1.2**: Update for BfA Rise of Azshara (8.2) (new interface number and new factions in table)
- **1.1.1**: Fixed a typo
- **1.1**: Tables are now stored in the "addon namespace"; also includes BfA Paragon factions
- **1.0.10**: Update Interface number for BfA Tides of Vengeance (8.1)
- **1.0.9**: Update for BfA-Prepatch, changed the commands to `/phisfactionswitcher` and `/pfs`
- **1.0.8**: Now includes Argus (Army of the Light)
- **1.0.7**: Fixed switching to the guild reputation
- **1.0.6**: Implemented a possibility to (temporarily) disable the addon
- **1.0.5**: Fixed a bug where the addon would not change the watched faction after gaining reputation if already exalted
- **1.0.4**: Now includes Vashj'ir subzones
- **1.0.3**: Exempts Legion factions from ignoring to switch when exalted (-> you can see your current Paragon progress)
- **1.0.2**: Includes "Armies of the Legionfall"
- **1.0.1**: Disabled "Already exalted with [faction name]." message
- **1.0**: Initial release

## To-Do
- [ ] Implement guild tabard
- [ ] Implementing some kind of precedence (tabard > zone > last reputation)
- [ ] Handle zones with multiple factions (random/highest rep/...?)
- [x] Include Vashj'ir subzones
- [x] Implement an useful function for the `/pfs` slash command
- [x] Include BfA Paragon factions