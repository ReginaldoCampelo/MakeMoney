-- MakeMoney.lua (CORE)
local ADDON = ...
MakeMoneyDB = MakeMoneyDB or {}

-- =========================
-- Defaults
-- =========================
local Default = {
    version = "0.1.0",
    minimap = {
        shown = true,
        radius = 80, -- usado no fallback manual
        angle = 180,
        lock = false,
        ldb = {
            hide = false,
            minimapPos = 180
        } -- se LibDBIcon existir
    },
    scan = {
        active = true,
        roles = {
            TANK = true,
            HEALER = true,
            DAMAGER = true
        },
        onlyFirst = false,
        interval = 10, -- segundos entre refresh de info BLZ
        content = "BOTH" -- "DUNGEON" | "RAID" | "BOTH"
    },
    popup = {
        enabled = true
    },
    sound = {
        enabled = true,
        file = "Interface\\AddOns\\MakeMoney\\media\\cheer.ogg"
    },
    ui = {
        roleMode = "AUTO"
    }
}

-- locale helper
local L = _G.Makemo_L or function(k)
    return k
end

-- =========================
-- merge defaults recursivo
-- =========================
local function MergeDefaults(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then
                dst[k] = {}
            end
            MergeDefaults(dst[k], v)
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

local function SyncMinimapForLib()
    -- mantém campos esperados pelo LibDBIcon sincronizados com os nossos
    MakeMoneyDB.minimap.ldb = MakeMoneyDB.minimap.ldb or {}
    MakeMoneyDB.minimap.ldb.hide = not MakeMoneyDB.minimap.shown
    MakeMoneyDB.minimap.ldb.minimapPos = (MakeMoneyDB.minimap.angle or 180) % 360
end

-- =========================
-- Eventos principais
-- =========================
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("LFG_UPDATE_RANDOM_INFO")

local lastAlertTimeByDungeon = {} -- throttling de som por dungeon
function MakeMoney_ResetScan()
    wipe(lastAlertTimeByDungeon)
    print("|cffffd700MakeMoney|r: " .. (L("Alerts reset") or "alerts reset"))
end

local function PlayCoin(dungeonID)
    if not MakeMoneyDB.sound.enabled then
        return
    end
    local now = GetTime()
    local last = lastAlertTimeByDungeon[dungeonID] or 0
    if now - last < 30 then
        return
    end -- não tocar de novo em < 30s p/ a mesma dungeon
    lastAlertTimeByDungeon[dungeonID] = now
    if MakeMoneyDB.sound.file and MakeMoneyDB.sound.file ~= "" then
        PlaySoundFile(MakeMoneyDB.sound.file, "Master")
    end
end

local function NotifyLine(msg)
    UIErrorsFrame:AddMessage("|cffffd700MakeMoney|r: " .. msg, 0.95, 0.85, 0.25)
end

local function GetAutoRole()
    local spec = GetSpecialization()
    if not spec then
        return "DAMAGER"
    end
    return GetSpecializationRole(spec) or "DAMAGER"
end

local function ShouldAlertForRole(forTank, forHealer, forDamage)
    if MakeMoneyDB.ui.roleMode == "AUTO" then
        local r = GetAutoRole()
        return (r == "TANK" and forTank) or (r == "HEALER" and forHealer) or (r == "DAMAGER" and forDamage)
    else
        return (forTank and MakeMoneyDB.scan.roles.TANK) or (forHealer and MakeMoneyDB.scan.roles.HEALER) or
                   (forDamage and MakeMoneyDB.scan.roles.DAMAGER)
    end
end

local function ShowPopup(dungeonID, name, done, total)
    if not MakeMoneyDB.popup.enabled then
        return
    end
    StaticPopupDialogs["MAKEMONEY_QUEUE"] = {
        text = total and total > 0 and
            (L("Queue for") .. ":\n%s\n" .. (done or 0) .. "/" .. (total or 0) .. " " .. L("boss(es) looted")) or
            (L("Queue for") .. ":\n%s"),
        button1 = ACCEPT,
        button2 = CANCEL,
        OnAccept = function()
            ClearAllLFGDungeons(LE_LFG_CATEGORY_RF)
            SetLFGDungeon(LE_LFG_CATEGORY_RF, dungeonID)
            JoinSingleLFG(LE_LFG_CATEGORY_RF, dungeonID)
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        preferredIndex = 3
    }
    StaticPopup_Show("MAKEMONEY_QUEUE", name or "?")
end

local function Scan()
    if not MakeMoneyDB.scan.active then
        return
    end

    local function checkDungeon(dungeonID)
        if LFGIsIDHeader(dungeonID) then
            return
        end
        local doneonce = GetLFGDungeonRewards(dungeonID)

        local eligibleRole = false
        for i = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
            local ok, forT, forH, forD, items, money, xp = GetLFGRoleShortageRewards(dungeonID, i)
            if ok and (items ~= 0 or money ~= 0 or xp ~= 0) then
                if ShouldAlertForRole(forT, forH, forD) then
                    eligibleRole = true;
                    break
                end
            end
        end

        if eligibleRole and (not MakeMoneyDB.scan.onlyFirst or not doneonce) then
            local name = GetLFGDungeonInfo(dungeonID)
            local total, done = GetLFGDungeonNumEncounters(dungeonID)
            PlayCoin(dungeonID)
            FlashClientIcon()
            NotifyLine(L("coin buff found") .. " → " .. (name or "?"))
            ShowPopup(dungeonID, name, done, total)
        end
    end

    -- LFD (masmorras)
    if MakeMoneyDB.scan.content ~= "RAID" then
        for i = 1, GetNumRandomDungeons() do
            local id = GetLFGRandomDungeonInfo(i)
            if id then
                checkDungeon(id)
            end
        end
    end

    -- LFR (raide)
    if MakeMoneyDB.scan.content ~= "DUNGEON" then
        for i = 1, GetNumRFDungeons() do
            local id = GetRFDungeonInfo(i)
            if id and IsLFGDungeonJoinable(id) then
                checkDungeon(id)
            end
        end
    end
end -- <<< FECHA Scan() (faltava no seu arquivo)

f:SetScript("OnEvent", function(_, e, arg)
    if e == "ADDON_LOADED" and arg == ADDON then
        MergeDefaults(MakeMoneyDB, Default)
        SyncMinimapForLib()

    elseif e == "PLAYER_LOGIN" then
        -- primeiro scan após login
        C_Timer.After(0.5, function()
            RequestLFDPlayerLockInfo()
            Scan()
        end)

    elseif e == "LFG_UPDATE_RANDOM_INFO" then
        Scan()
    end
end)

-- ticker leve p/ pedir refresh periódico
local nextTick = 0
f:SetScript("OnUpdate", function(_, elapsed)
    nextTick = nextTick + elapsed
    if nextTick >= (MakeMoneyDB.scan.interval or 10) then
        nextTick = 0
        RequestLFDPlayerLockInfo()
    end
end)

-- utilidade
function MakeMoney_Ping()
    print("|cffffd700MakeMoney|r " .. (L("ready") or "ready") .. ". /makemoney")
end
