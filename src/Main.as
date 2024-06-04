// c 2024-05-05
// m 2024-06-04

const string title = "\\$F33" + Icons::Film + "\\$G FPS Reducer";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show FPS caps in menu item" description="Under Openplanet's 'Plugins' menu at the top."]
bool S_MenuCaps = true;

[Setting category="General" name="Normal FPS" description="When using this plugin, you should only set your normal maximum framerate here. Setting it elsewhere (i.e. in the normal game settings) will be ignored."]
int S_NormalFPS = 288;

[Setting category="General" name="Reduce when in main menu"]
bool S_MainMenu = true;

[Setting category="General" name="Main menu FPS" description="Setting below 11 seems to make the setting ignored."]
int S_MainMenuFps = 60;

[Setting category="General" name="Reduce when paused" description="Only applies when in a map."]
bool S_Paused = true;

[Setting category="General" name="Paused FPS" description="Setting below 11 seems to make the setting ignored."]
int S_PausedFps = 30;

[Setting category="General" name="Reduce when unfocused"]
bool S_Unfocused = true;

[Setting category="General" name="Unfocused FPS" description="Setting below 11 seems to make the setting ignored. Can't be greater than the 'Main menu FPS' or 'Paused FPS' above."]
int S_UnfocusedFps = 11;

void Main() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.SystemConfig is null || App.SystemConfig.Display is null) {
        const string msg = "There was a problem getting the current FPS cap. Plugin is now disabled - you may try reloading it to fix this.";
        warn(msg);
        UI::ShowNotification(title, msg, vec4(1.0f, 0.6f, 0.0f, 0.5f), 10000);
        return;
    }

    S_NormalFPS = App.SystemConfig.Display.MaxFps;

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

    if (UI::MenuItem(title + (S_MenuCaps ? caps : ""), "", S_Enabled))
        S_Enabled = !S_Enabled;
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
