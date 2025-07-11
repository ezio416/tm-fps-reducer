// c 2024-05-05
// m 2025-07-10

const string  pluginColor = "\\$F33";
const string  pluginIcon  = Icons::University;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

void Main() {
    auto App = cast<CTrackMania>(GetApp());

    if (S_GrabAtBoot) {
        if (false
            or App.SystemConfig is null
            or App.SystemConfig.Display is null
        ) {
            const string msg = "There was a problem getting the current FPS limit. Plugin is now disabled - you may try reloading it to fix this.";
            warn(msg);
            UI::ShowNotification(pluginTitle, msg, vec4(1.0f, 0.6f, 0.0f, 0.5f), 10000);
            return;
        }

        S_NormalFPS = App.SystemConfig.Display.MaxFps;
    }

    bool wasEnabled = S_Enabled;

    while (true) {
        yield();

        if (false
            or App.SystemConfig is null
            or App.SystemConfig.Display is null
        ) {
            continue;
        }

        if (wasEnabled != S_Enabled) {
            if (wasEnabled) {
                RestoreFps();
            }

            wasEnabled = S_Enabled;

            continue;
        }

        if (!S_Enabled) {
            continue;
        }

        if (S_Unfocused and Unfocused()) {
            App.SystemConfig.Display.MaxFps = S_UnfocusedFps;
        } else if (S_Paused and Paused()) {
            App.SystemConfig.Display.MaxFps = S_PausedFps;
        } else if (S_MainMenu and MainMenu()) {
            App.SystemConfig.Display.MaxFps = S_MainMenuFps;
        } else {
            RestoreFps();
        }
    }
}

void OnDestroyed() { RestoreFps(); }
void OnDisabled()  { RestoreFps(); }

void OnSettingsChanged() {
    if (S_MainMenuFps < 11) {
        S_MainMenuFps = 11;
    }

    if (S_PausedFps < 11) {
        S_PausedFps = 11;
    }

    if (S_UnfocusedFps < 11) {
        S_UnfocusedFps = 11;
    }

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
    const bool mainmenu  = S_MainMenu  and MainMenu();
    const bool paused    = S_Paused    and Paused();
    const bool unfocused = S_Unfocused and Unfocused();

    const string caps = "\\$777    ("
        + (!mainmenu and !paused and !unfocused ? "\\$7D7" : "") + S_NormalFPS    + "\\$777 / "
        + ( mainmenu and !paused and !unfocused ? "\\$7D7" : "") + S_MainMenuFps  + "\\$777 / "
        + (               paused and !unfocused ? "\\$7D7" : "") + S_PausedFps    + "\\$777 / "
        + (                           unfocused ? "\\$7D7" : "") + S_UnfocusedFps + "\\$777)";

    if (UI::MenuItem(pluginTitle + (S_MenuLimits ? caps : ""), "", S_Enabled)) {
        S_Enabled = !S_Enabled;
    }
}
