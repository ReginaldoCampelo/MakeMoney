-- locale/enUS.lua
local L = {
    ["ACTIVE"] = "active",
    ["PAUSED"] = "paused",
    ["ready"] = "ready",
    ["Scan"] = "Scan",
    ["coin buff found"] = "coin buff found",
    ["Queue for"] = "Queue for",
    ["boss(es) looted"] = "boss(es) looted",

    -- Tooltip texts
    ["TT_LEFT"] = "Left-click: quick tip",
    ["TT_SHIFT"] = "Shift+Left: toggle scanning",
    ["TT_CTRL"] = "Ctrl+Left: reset found-flag",
    ["TT_RIGHT"] = "Right-click: open settings",

    -- Settings
    ["CFG_SCAN_ACTIVE"] = "Enable scanning",
    ["CFG_SCAN_ACTIVE_TT"] = "Automatically check Call to Arms for the selected roles.",
    ["SOUND_ON"] = "Play sound on coin buff",
    ["SOUND_ON_TT"] = "Plays a sound when a coin buff is found.",
    ["POPUP_ON"] = "Show queue popup",
    ["POPUP_ON_TT"] = "Show a confirmation popup to queue.",
    ["ONLY_FIRST"] = "Only if first-time reward",
    ["ONLY_FIRST_TT"] = "Ignore if you already received the reward.",
    ["MINIMAP_SHOW"] = "Show minimap button",
    ["MINIMAP_LOCK"] = "Lock minimap button",

    -- Role mode
    ["Role mode"] = "Role mode",
    ["ROLE_MODE_TT"] = "AUTO uses your current specialization role; MANUAL uses the checkboxes below.",
    ["Auto (use current spec)"] = "Auto (use current spec)",
    ["Manual (choose roles)"] = "Manual (choose roles)",
    ["Role Tank"] = "Role Tank",
    ["ROLE_TANK_TT"] = "Consider Tank in MANUAL mode.",
    ["Role Healer"] = "Role Healer",
    ["ROLE_HEAL_TT"] = "Consider Healer in MANUAL mode.",
    ["Role Damage"] = "Role Damage",
    ["ROLE_DAMAGER_TT"] = "Consider Damage in MANUAL mode.",
    ["Scan interval (s)"] = "Scan interval (s)",
    ["Scan now"] = "Scan now",
    ["Reset alerts"] = "Reset alerts",
    ["Test sound"] = "Test sound",
    ["Apply & Close"] = "Apply & Close",
    ["Close"] = "Close",
    ["Farm mode"] = "Farm mode",
    ["Dungeon"] = "Dungeon",
    ["Raid"] = "Raid",
    ["Both"] = "Both",
    ["Auto (current role)"] = "Auto (current role)",
    ["TAGLINE"] = "Call to Arms helper • EN/PT-BR • minimap & sound",

}

_G.Makemo_L = function(k)
    return L[k] or k
end
