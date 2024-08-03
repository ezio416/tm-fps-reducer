// c 2024-05-05
// m 2024-08-03

const string title = "\\$F33" + Icons::Film + "\\$G FPS Reducer";

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

        for (uint i = 0; i < settings.Length; i++)
            settings[i].Reset();
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

void Main() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (S_GrabAtBoot) {
        if (App.SystemConfig is null || App.SystemConfig.Display is null) {
            const string msg = "There was a problem getting the current FPS limit. Plugin is now disabled - you may try reloading it to fix this.";
            warn(msg);
            UI::ShowNotification(title, msg, vec4(1.0f, 0.6f, 0.0f, 0.5f), 10000);
            return;
        }

        S_NormalFPS = App.SystemConfig.Display.MaxFps;
    }

    bool wasEnabled = S_Enabled;

    while (true) {
        yield();

        if (App.SystemConfig is null || App.SystemConfig.Display is null)
            continue;

        if (wasEnabled != S_Enabled) {
            if (wasEnabled)
                RestoreFps();

            wasEnabled = S_Enabled;

            continue;
        }

        if (!S_Enabled)
            continue;

        if (S_Unfocused && Unfocused())
            App.SystemConfig.Display.MaxFps = S_UnfocusedFps;
        else if (S_Paused && Paused())
            App.SystemConfig.Display.MaxFps = S_PausedFps;
        else if (S_MainMenu && MainMenu())
            App.SystemConfig.Display.MaxFps = S_MainMenuFps;
        else
            RestoreFps();
    }
}

void OnDestroyed() { RestoreFps(); }
void OnDisabled()  { RestoreFps(); }

void OnSettingsChanged() {
    if (S_MainMenuFps < 11)
        S_MainMenuFps = 11;

    if (S_PausedFps < 11)
        S_PausedFps = 11;

    if (S_UnfocusedFps < 11)
        S_UnfocusedFps = 11;

    if (S_MainMenuFps < S_UnfocusedFps) {
        const int mainmenu = S_MainMenuFps;
        S_MainMenuFps = S_UnfocusedFps;
        S_UnfocusedFps = mainmenu;
    }

    if (S_PausedFps < S_UnfocusedFps) {
        const int paused = S_PausedFps;
        S_PausedFps = S_UnfocusedFps;
        S_UnfocusedFps = paused;
    }
}

void RenderMenu() {
    const bool mainmenu  = S_MainMenu  && MainMenu();
    const bool paused    = S_Paused    && Paused();
    const bool unfocused = S_Unfocused && Unfocused();

    const string caps = "\\$777    ("
        + (!mainmenu && !paused && !unfocused ? "\\$7D7" : "") + S_NormalFPS    + "\\$777 / "
        + ( mainmenu && !paused && !unfocused ? "\\$7D7" : "") + S_MainMenuFps  + "\\$777 / "
        + (              paused && !unfocused ? "\\$7D7" : "") + S_PausedFps    + "\\$777 / "
        + (                         unfocused ? "\\$7D7" : "") + S_UnfocusedFps + "\\$777)";

    if (UI::MenuItem(title + (S_MenuLimits ? caps : ""), "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void HoverTooltipSetting(const string &in msg) {
    UI::SameLine();
    UI::Text("\\$666" + Icons::QuestionCircle);
    if (!UI::IsItemHovered())
        return;

    UI::SetNextWindowSize(int(Math::Min(Draw::MeasureString(msg).x, 400.0f)), 0.0f);
    UI::BeginTooltip();
    UI::TextWrapped(msg);
    UI::EndTooltip();
}

const bool MainMenu() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    return App.ActiveMenus.Length > 0
        && App.ActiveMenus[0].MainFrame !is null
        && App.ActiveMenus[0].MainFrame.Id.Value == 0x40004bc1;
}

const bool Paused() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    return App.CurrentPlayground !is null
        && App.Network.PlaygroundClientScriptAPI !is null
        && App.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed;
}

void RestoreFps() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.SystemConfig is null || App.SystemConfig.Display is null)
        return;

    App.SystemConfig.Display.MaxFps = S_NormalFPS;
}

const bool Unfocused() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    return App.InputPort !is null
        && !App.InputPort.IsFocused;
}
