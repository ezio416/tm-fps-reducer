const string  pluginColor = "\\$F33";
const string  pluginIcon  = Icons::Film;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

void Main() {
    if (S_GrabAtBoot) {
        try {
            S_NormalFPS = GetApp().Viewport.SystemConfig.Display.MaxFps;
        } catch {
            const string msg = "There was a problem getting the current FPS limit. Plugin is now disabled - you may try reloading it to fix this.";
            warn(msg);
            UI::ShowNotification(pluginTitle, msg, vec4(1.0f, 0.6f, 0.0f, 0.5f), 10000);
            return;
        }
    }

    bool wasEnabled = S_Enabled;

    while (true) {
        yield();

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
            SetFps(S_UnfocusedFps);
        } else if (S_Paused and Paused()) {
            SetFps(S_PausedFps);
        } else if (S_MainMenu and MainMenu()) {
            SetFps(S_MainMenuFps);
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
