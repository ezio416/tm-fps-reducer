// c 2025-07-10
// m 2025-07-10

[Setting hidden] bool S_Enabled      = true;
[Setting hidden] bool S_MenuLimits   = true;
[Setting hidden] bool S_GrabAtBoot   = false;
[Setting hidden] int  S_NormalFPS    = 288;
[Setting hidden] bool S_MainMenu     = true;
[Setting hidden] int  S_MainMenuFps  = 60;
[Setting hidden] bool S_Paused       = true;
[Setting hidden] int  S_PausedFps    = 30;
[Setting hidden] bool S_Unfocused    = true;
[Setting hidden] int  S_UnfocusedFps = 11;

[SettingsTab name="General" icon="Cogs"]
void Settings_General() {
    if (UI::Button("Reset to default")) {
        Meta::PluginSetting@[]@ settings = Meta::ExecutingPlugin().GetSettings();

        for (uint i = 0; i < settings.Length; i++) {
            settings[i].Reset();
        }
    }

    S_Enabled = UI::Checkbox("Enabled", S_Enabled);

    S_MenuLimits = UI::Checkbox("Show FPS limits in menu item", S_MenuLimits);
    HoverTooltipSetting("Under Openplanet's 'Plugins' menu at the top.");

    S_GrabAtBoot = UI::Checkbox("Grab FPS limit from game at boot", S_GrabAtBoot);
    HoverTooltipSetting("If enabled, you may have issues if your game previously crashed.");

    S_NormalFPS = UI::InputInt("Normal FPS", S_NormalFPS);
    HoverTooltipSetting("When using this plugin, you should only set your normal maximum framerate here. Setting it elsewhere (i.e. in the normal game settings) will be ignored.");

    UI::Separator();
    S_MainMenu = UI::Checkbox("Reduce when in main menu", S_MainMenu);
    if (S_MainMenu) {
        S_MainMenuFps = UI::InputInt("Main menu FPS", S_MainMenuFps);
        HoverTooltipSetting("Setting below 11 seems to make the setting ignored.");
    }

    UI::Separator();
    S_Paused = UI::Checkbox("Reduce when paused", S_Paused);
    if (S_Paused) {
        S_PausedFps = UI::InputInt("Paused FPS", S_PausedFps);
        HoverTooltipSetting("Setting below 11 seems to make the setting ignored. Only applies when in a map.");
    }

    UI::Separator();
    S_Unfocused = UI::Checkbox("Reduce when unfocused", S_Unfocused);
    if (S_Unfocused) {
        S_UnfocusedFps = UI::InputInt("Unfocused FPS", S_UnfocusedFps);
        HoverTooltipSetting("Setting below 11 seems to make the setting ignored. Can't be greater than any setting above.");
    }
}
