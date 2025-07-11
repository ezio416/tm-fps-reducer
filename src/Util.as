// c 2025-07-10
// m 2025-07-10

void HoverTooltipSetting(const string&in msg) {
    UI::SameLine();
    UI::Text("\\$666" + Icons::QuestionCircle);
    if (!UI::IsItemHovered()) {
        return;
    }

    UI::SetNextWindowSize(int(Math::Min(Draw::MeasureString(msg).x, 400.0f)), 0.0f);
    UI::BeginTooltip();
    UI::TextWrapped(msg);
    UI::EndTooltip();
}

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

    return true
        and App.CurrentPlayground !is null
        and App.Network.PlaygroundClientScriptAPI !is null
        and App.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed
    ;
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
        and !App.InputPort.IsFocused
    ;
}
