-- MakeMoney_UI.lua
local L = _G.Makemo_L or function(k)
    return k
end

-- ===== Janela base =====
local UI = CreateFrame("Frame", "MakeMoneyPanel", UIParent, "BackdropTemplate")
UI:SetSize(560, 420)
UI:SetPoint("CENTER")
UI:EnableMouse(true)
UI:SetMovable(true)
UI:RegisterForDrag("LeftButton")
UI:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
UI:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
UI:Hide()
UI:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = {
        left = 11,
        right = 12,
        top = 12,
        bottom = 11
    }
})
tinsert(UISpecialFrames, "MakeMoneyPanel") -- fecha com ESC

local built = false
local function line(x, y, w)
    local t = UI:CreateTexture(nil, "ARTWORK")
    t:SetColorTexture(1, 1, 1, 0.15)
    t:SetPoint("TOPLEFT", x, y)
    t:SetSize(w or 520, 1)
    return t
end

-- ===== Helpers =====
local function Header(text, x, y)
    local h = UI:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    h:SetPoint("TOPLEFT", x, y)
    h:SetText(text)
    line(x, y - 6, 520 - (x - 20))
    return h
end

local function AddCheck(label, tooltip, x, y, getter, setter)
    local c = CreateFrame("CheckButton", nil, UI, "InterfaceOptionsCheckButtonTemplate")
    c:SetPoint("TOPLEFT", x, y)
    c.Text:SetText(label)
    c.tooltipText = label
    c.tooltipRequirement = tooltip
    c:SetChecked(getter())
    c:SetScript("OnClick", function(self)
        setter(self:GetChecked())
    end)
    return c
end

local function AddSlider(label, min, max, step, x, y, get, set)
    local s = CreateFrame("Slider", nil, UI, "OptionsSliderTemplate")
    s:SetPoint("TOPLEFT", x, y)
    s:SetMinMaxValues(min, max)
    s:SetValueStep(step)
    s:SetObeyStepOnDrag(true)
    s:SetWidth(240)
    -- usar regiões do template (evita concat com GetName())
    s.Low:SetText(min)
    s.High:SetText(max)
    s.Text:SetText(label)
    s:SetValue(get())
    s:SetScript("OnValueChanged", function(self, v)
        set(math.floor(v + 0.5))
    end)
    return s
end

local function AddRadio(label, x, y, group, value, get, set)
    local r = CreateFrame("CheckButton", nil, UI, "UIRadioButtonTemplate")
    r:SetPoint("TOPLEFT", x, y)
    r.text:SetText(label)
    r:SetChecked(get() == value)
    r:SetScript("OnClick", function(self)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        set(value)
        for _, b in ipairs(group) do
            b:SetChecked(b == self)
        end
    end)
    table.insert(group, r)
    return r
end

local function setEnabledCheck(check, enabled)
    if not check then
        return
    end
    check:SetEnabled(enabled)
    local r, g, b = enabled and 1 or 0.5, enabled and 0.82 or 0.5, enabled and 0 or 0
    if check.Text then
        check.Text:SetTextColor(r, g, b)
    end
end

-- ===== UI builder =====
local function BuildUI()
    if built then
        return
    end
    built = true

    local xL, xR = 20, 320 -- colunas
    local title = UI:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -16)
    title:SetText("|cffffd700MakeMoney|r")

    local desc = UI:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    desc:SetText(L("TAGLINE")) -- traduzível

    -- ===== Farm mode (topo, full width)
    Header(L("Farm mode"), 20, -50)
    MakeMoneyDB.scan.content = MakeMoneyDB.scan.content or "BOTH"
    local radios = {}
    AddRadio(L("Dungeon"), 20, -78, radios, "DUNGEON", function()
        return MakeMoneyDB.scan.content
    end, function(v)
        MakeMoneyDB.scan.content = v
    end)
    AddRadio(L("Raid"), 120, -78, radios, "RAID", function()
        return MakeMoneyDB.scan.content
    end, function(v)
        MakeMoneyDB.scan.content = v
    end)
    AddRadio(L("Both"), 210, -78, radios, "BOTH", function()
        return MakeMoneyDB.scan.content
    end, function(v)
        MakeMoneyDB.scan.content = v
    end)

    -- ===== Varredura (coluna esquerda)
    Header(L("Scan"), xL, -110)
    local yL = -138
    local chkScan = AddCheck(L("CFG_SCAN_ACTIVE"), L("CFG_SCAN_ACTIVE_TT"), xL, yL, function()
        return MakeMoneyDB.scan.active
    end, function(v)
        MakeMoneyDB.scan.active = v
        UI.UpdateEnableStates()
        if MakeMoney_UpdateMinimapIcon then
            MakeMoney_UpdateMinimapIcon()
        end
    end);
    yL = yL - 28

    local chkPopup = AddCheck(L("POPUP_ON"), L("POPUP_ON_TT"), xL, yL, function()
        return MakeMoneyDB.popup.enabled
    end, function(v)
        MakeMoneyDB.popup.enabled = v
    end);
    yL = yL - 28

    local chkSound = AddCheck(L("SOUND_ON"), L("SOUND_ON_TT"), xL, yL, function()
        return MakeMoneyDB.sound.enabled
    end, function(v)
        MakeMoneyDB.sound.enabled = v
    end);
    yL = yL - 34

    local sInterval = AddSlider(L("Scan interval (s)"), 5, 60, 1, xL, yL, function()
        return MakeMoneyDB.scan.interval or 10
    end, function(v)
        MakeMoneyDB.scan.interval = v
    end);
    yL = yL - 48

    -- ===== Minimap (coluna esquerda, abaixo)
    Header("Minimap", xL, yL - 10);
    yL = yL - 38
    local chkShowMini = AddCheck(L("MINIMAP_SHOW"), "", xL, yL, function()
        return MakeMoneyDB.minimap.shown
    end, function(v)
        MakeMoneyDB.minimap.shown = v
        if MakeMoney_SetMinimapShown then
            MakeMoney_SetMinimapShown(v)
        elseif MakeMoneyMinimap then
            if v then
                MakeMoneyMinimap:Show()
            else
                MakeMoneyMinimap:Hide()
            end
        end
        UI.UpdateEnableStates()
    end);
    yL = yL - 26

    -- ===== Modo de papel (coluna direita)
    Header(L("Role mode"), xR, -110)
    local hint = UI:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", xR, -138)
    hint:SetWidth(220)
    hint:SetJustifyH("LEFT")
    hint:SetText(L("ROLE_MODE_TT"))

    local dd = CreateFrame("Frame", "MakeMoneyRoleModeDD", UI, "UIDropDownMenuTemplate")
    dd:SetPoint("TOPLEFT", xR, -168)
    UIDropDownMenu_SetWidth(dd, 200)
    UIDropDownMenu_Initialize(dd, function(self, level)
        local function pick(val)
            return function(entry)
                MakeMoneyDB.ui.roleMode = val
                UIDropDownMenu_SetSelectedValue(dd, (val == "MANUAL") and 2 or 1)
                UI.UpdateEnableStates()
            end
        end
        local info = UIDropDownMenu_CreateInfo()
        info.text, info.value, info.func = L("Auto (use current spec)"), 1, pick("AUTO");
        UIDropDownMenu_AddButton(info)
        info = UIDropDownMenu_CreateInfo()
        info.text, info.value, info.func = L("Manual (choose roles)"), 2, pick("MANUAL");
        UIDropDownMenu_AddButton(info)
    end)
    UIDropDownMenu_SetSelectedValue(dd, (MakeMoneyDB.ui.roleMode == "MANUAL") and 2 or 1)

    local roleLabel = UI:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    roleLabel:SetPoint("TOPLEFT", xR, -198)
    roleLabel:SetText("")

    -- Botões de teste (sempre abaixo do dropdown)
    local yBtns = -228
    local btnScanNow = CreateFrame("Button", nil, UI, "UIPanelButtonTemplate")
    btnScanNow:SetSize(200, 22)
    btnScanNow:SetPoint("TOPLEFT", xR, yBtns)
    btnScanNow:SetText(L("Scan now"))
    btnScanNow:SetScript("OnClick", function()
        RequestLFDPlayerLockInfo()
    end)

    local btnReset = CreateFrame("Button", nil, UI, "UIPanelButtonTemplate")
    btnReset:SetSize(200, 22)
    btnReset:SetPoint("TOPLEFT", xR, yBtns - 28)
    btnReset:SetText(L("Reset alerts"))
    btnReset:SetScript("OnClick", function()
        if MakeMoney_ResetScan then
            MakeMoney_ResetScan()
        end
    end)

    local btnTestSound = CreateFrame("Button", nil, UI, "UIPanelButtonTemplate")
    btnTestSound:SetSize(200, 22)
    btnTestSound:SetPoint("TOPLEFT", xR, yBtns - 56)
    btnTestSound:SetText(L("Test sound"))
    btnTestSound:SetScript("OnClick", function()
        if MakeMoneyDB.sound.enabled and MakeMoneyDB.sound.file and MakeMoneyDB.sound.file ~= "" then
            PlaySoundFile(MakeMoneyDB.sound.file, "Master")
        end
    end)

    -- Checkboxes de papel (aparecem SOMENTE quando MANUAL)
    local chkTank = AddCheck(L("Role Tank"), L("ROLE_TANK_TT"), xR, yBtns - 90, function()
        return MakeMoneyDB.scan.roles.TANK
    end, function(v)
        MakeMoneyDB.scan.roles.TANK = v
    end)
    local chkHeal = AddCheck(L("Role Healer"), L("ROLE_HEAL_TT"), xR, yBtns - 116, function()
        return MakeMoneyDB.scan.roles.HEALER
    end, function(v)
        MakeMoneyDB.scan.roles.HEALER = v
    end)
    local chkDps = AddCheck(L("Role Damage"), L("ROLE_DAMAGER_TT"), xR, yBtns - 142, function()
        return MakeMoneyDB.scan.roles.DAMAGER
    end, function(v)
        MakeMoneyDB.scan.roles.DAMAGER = v
    end)

    -- ===== Rodapé =====
    local btnApply = CreateFrame("Button", nil, UI, "UIPanelButtonTemplate")
    btnApply:SetSize(160, 22);
    btnApply:SetPoint("BOTTOMRIGHT", -16, 14);
    btnApply:SetText(L("Close"))
    btnApply:SetScript("OnClick", function()
        UI:Hide()
    end)

    local btnReload = CreateFrame("Button", nil, UI, "UIPanelButtonTemplate")
    btnReload:SetSize(160, 22);
    btnReload:SetPoint("BOTTOMLEFT", 16, 14);
    btnReload:SetText(RELOADUI)
    btnReload:SetScript("OnClick", ReloadUI)

    -- ===== Estados dinâmicos =====
    local function getAutoRoleText()
        local spec = GetSpecialization()
        local r = spec and GetSpecializationRole(spec) or "DAMAGER"
        local map = {
            TANK = L("Role Tank"),
            HEALER = L("Role Healer"),
            DAMAGER = L("Role Damage")
        }
        return (L("Auto (current role)") .. ": " .. (map[r] or ""))
    end

    function UI.UpdateEnableStates()
        -- Varredura liga/desliga controles
        local on = MakeMoneyDB.scan.active
        setEnabledCheck(chkPopup, on)
        setEnabledCheck(chkSound, on)
        sInterval:SetEnabled(on);
        sInterval.Text:SetTextColor(on and 1 or .5, on and .82 or .5, on and 0 or 0)

        -- Minimap: se escondido, não permite travar
        setEnabledCheck(chkLockMini, MakeMoneyDB.minimap.shown)

        -- Papel: Auto oculta checkboxes; Manual mostra
        local manual = (MakeMoneyDB.ui.roleMode == "MANUAL")
        chkTank:SetShown(manual)
        chkHeal:SetShown(manual)
        chkDps:SetShown(manual)
        roleLabel:SetText(manual and "" or getAutoRoleText())
    end

    UI.UpdateEnableStates()

    -- Atualiza papel detectado ao mudar de spec
    local ef = CreateFrame("Frame")
    ef:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    ef:SetScript("OnEvent", function()
        if UI:IsShown() then
            UI.UpdateEnableStates()
        end
    end)
end

-- constrói ao logar
local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:SetScript("OnEvent", function()
    if not built then
        BuildUI()
    end
end)

-- slash abre
SLASH_MAKEMONEY1 = "/makemoney"
SlashCmdList.MAKEMONEY = function()
    if not built then
        BuildUI()
    end
    UI:Show()
end

function MakeMoney_ToggleUI(show)
    if not built then
        BuildUI()
    end
    if show then
        UI:Show()
    else
        UI:Hide()
    end
end
