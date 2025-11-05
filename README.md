# Monster Hunter Freedom DX

<img src="/assets/FreedomDXTitle.png" width="480px"/>

All-in-One patch that includes the following:
  - ### Event Quest Loader
    > Read event quests from an external file. By SilverJolteon
  - ### Input Drop Fix
    > Fixes issue where button inputs are ignored. By YuzucchiNyan
  - ### Instant supply box collection
    > Removed delay when taking items from supply box. Ported by SilverJolteon from IncognitoMan's FUC
  - ### Hold to Gather
    > Allows you to simply press and hold the gather button when crouched. By YuzucchiNyan
  - ### True Raw
    > Displays the non-bloated "true" raw attack value of weapons. EUR version by YuzucchiNyan, ported to JPN and USA by SilverJolteon
  - ### Early Kill Lao-Shan Lung
    > Disables the HP threshold that prevents killing Lao-Shan Lung before reaching the final area. Ported by SilverJolteon from IncognitoMan's FUC
  - ### Minimap Scale
    > Sets the scale for the minimap. Ported by SilverJolteon from IncognitoMan's FUC
  - ### Sword & Shield Debuff
    > Changes Sword & Shield sharpness and damage from 1.5 to 1.2 to match MH Dos. By YuzucchiNyan
  - ### File Replacer
    > Enables the ability to load custom files from `ms0:/PSP/SAVEDATA/FDXDAT/NATIVEPSP/<GAMEID>/`. These files are in the name format of four numbers (IE: "4960"). The original files can be extracted using [mhff](https://github.com/svanheulen/mhff/tree/master/psp). By SilverJolteon
    
    > Included are english dialogue files for Portable.
  - ### Visible Felyne Skills
    > Shows which skillsets each Felyne has. By SilverJolteon
  - ### Gathering Hall Drink Buff
    > Pressing Circle while sitting in the Gathering Hall now provides a quick buff to HP and Stamina. The amount depends on how many chefs you have. `HP = +10 per active Chefs`, `Stamina = +25 for 1 to 4 Chefs or +50 for 5 Chefs`. It will not activate any Felyne Skills, and cannot be used alongside a meal, it is **either or**. Ported by SilverJolteon from IncognitoMan's FUC
  - ### English Menu Patch (Portable)
    > Translates Menus, Items, Equipment, Skills, etc. into English. By YuzucchiNyan
  - ### English Quest Patch (Portable)
    > Translates non-event quests into English. By SilverJolteon


## Usage
Place the `FDXDAT` folder in `ms0:/PSP/SAVEDATA/` and apply the ISO patch with [DeltaPatcher](https://www.romhacking.net/utilities/704/) to your respective version.

Unlike my EventQuestLoader, event quests are now stored in `FDXDAT/EVENT.BIN`.

## Config Editor
Use [this](https://silverjolteon.github.io/FreedomDX/config_editor.html) online tool to make edits to your CONFIG.BIN.

## Credits

- Special thanks to [IncognitoMan](https://github.com/IncognitoMan) and [Kurogami2134](https://github.com/Kurogami2134) for tips and their own ASM as a groundwork.
- Special thanks as well to [Immortalcripple](https://github.com/Immortalcripple) and Barry1990 for helping out with testing.
- Freedom Enhanced by [YuzucchiNyan](https://github.com/GReinoso96)
- English quests translated by [GrenderG](https://github.com/GrenderG)
