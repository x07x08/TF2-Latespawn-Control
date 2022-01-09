# TF2-Latespawn-Control
This is an edited version of meng's original [CSS Late Spawn](https://forums.alliedmods.net/showthread.php?p=1194271) to make it work for TF2, with some extra features added.

# ConVars

  | ConVars                   | Description                                                                                   | Default value    |
  |---------------------------|-----------------------------------------------------------------------------------------------|------------------|
  | `sm_latespawn_enabled`    | Enable / disable the plugin. (this will not disable the [unassigned team fix](https://github.com/Mikusch/arena-latespawn-fix/blob/105d592f4534529dbe767d21e7b244a2001846a2/addons/sourcemod/scripting/arena-latespawn-fix.sp#L63))                  | `1` (enabled)    |
  | `sm_latespawn_block_time` | Time until latespawning is blocked.                                                           | `10.0` (seconds) |
  | `sm_latespawn_allow_blue` | Allow blue team to latespawn?                                                                 | `0` (disabled)   |
  | `sm_latespawn_allow_red`  | Allow red team to latespawn?                                                                  | `1` (enabled)    |
  | `sm_latespawn_block`      | Block latespawning if the time limit has passed?                                              | `1` (enabled)    |
  
  # Credits
  
  1. [CSS Late Spawn](https://forums.alliedmods.net/showthread.php?t=128136) by meng.
  2. [VSH2](https://github.com/VSH2-Devs/Vs-Saxton-Hale-2) by nergal.
  3. [Arena Late Spawn Fix](https://github.com/Mikusch/arena-latespawn-fix) by Mikusch.
  4. [Second Life](https://forums.alliedmods.net/showthread.php?p=1999451) by tooti.
