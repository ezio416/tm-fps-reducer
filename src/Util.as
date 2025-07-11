// c 2025-07-10
// m 2025-07-10

const bool MainMenu() {
    auto App = cast<CTrackMania>(GetApp());

    return true
        and App.ActiveMenus.Length > 0
        and App.ActiveMenus[0].MainFrame !is null
        and App.ActiveMenus[0].MainFrame.Id.Value == 0x40004bc1
    ;
}

const bool Paused() {
    auto App = cast<CTrackMania>(GetApp());

#if TMNEXT || MP4
    return true
        and App.CurrentPlayground !is null
        and App.Network.PlaygroundClientScriptAPI !is null
        and App.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed
    ;
#elif TURBO
    try {
        return App.CurrentPlayground.Interface.ManialinkPage.Childs[27].IsFocused;
    } catch {
        return false;
    }
#endif
}

void RestoreFps() {
    SetFps(S_NormalFPS);
}

void SetFps(const uint fps) {
    try {
        GetApp().Viewport.SystemConfig.Display.MaxFps = fps;
    } catch { }
}

const bool Unfocused() {
    auto App = cast<CTrackMania>(GetApp());

    return true
        and App.InputPort !is null
#if TMNEXT || MP4
        and !App.InputPort.IsFocused
#elif TURBO
        and Dev::GetOffsetUint32(App.InputPort, 0x890) == 0
#endif
    ;
}
