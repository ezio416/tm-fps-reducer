// c 2025-07-10
// m 2025-07-10

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show FPS limits in menu item"
description="Under Openplanet's 'Plugins' menu at the top."]
bool S_MenuLimits = true;

[Setting category="General" name="Grab FPS limit from game at boot"
description="If enabled, you may have issues if your game previously crashed."]
bool S_GrabAtBoot = false;

[Setting category="General" name="Normal FPS"
description="When using this plugin, you should only set your normal maximum framerate here. Setting it elsewhere (i.e. in the normal game settings) will be ignored."]
int S_NormalFPS = 288;

[Setting category="General" name="Reduce when in main menu"]
bool S_MainMenu = true;

[Setting category="General" name="Main menu FPS"
description="Setting below 11 seems to make the setting ignored."
if="S_MainMenu"]
int S_MainMenuFps = 60;

[Setting category="General" name="Reduce when paused"]
bool S_Paused = true;

[Setting category="General" name="Paused FPS"
description="Setting below 11 seems to make the setting ignored. Only applies when in a map."
if="S_Paused"]
int S_PausedFps = 30;

[Setting category="General" name="Reduce when unfocused"]
bool S_Unfocused = true;

[Setting category="General" name="Unfocused FPS"
description="Setting below 11 seems to make the setting ignored. Can't be greater than any setting above."
if="S_Unfocused"]
int S_UnfocusedFps = 11;
