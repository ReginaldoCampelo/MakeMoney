-- locale/ptBR.lua
if GetLocale() ~= "ptBR" then
    return
end

local Lpt = {
    ["ACTIVE"] = "ativo",
    ["PAUSED"] = "pausado",
    ["ready"] = "pronto",
    ["Scan"] = "Varredura",
    ["coin buff found"] = "bônus de moedas encontrado",
    ["Queue for"] = "Entrar na fila",
    ["boss(es) looted"] = "chefe(s) saqueado(s)",

    -- Tooltip
    ["TT_LEFT"] = "Clique: dica rápida",
    ["TT_SHIFT"] = "Shift+Clique: ligar/desligar varredura",
    ["TT_CTRL"] = "Ctrl+Clique: resetar flag de achado",
    ["TT_RIGHT"] = "Botão direito: abrir configurações",

    -- Config
    ["CFG_SCAN_ACTIVE"] = "Ativar varredura",
    ["CFG_SCAN_ACTIVE_TT"] = "Checar automaticamente o bônus de moedas para os papéis selecionados.",
    ["SOUND_ON"] = "Tocar som ao achar bônus de moedas",
    ["SOUND_ON_TT"] = "Toca um som quando for encontrado bônus de moedas.",
    ["POPUP_ON"] = "Mostrar popup de fila",
    ["POPUP_ON_TT"] = "Mostrar popup de confirmação para entrar na fila.",
    ["ONLY_FIRST"] = "Somente se for recompensa de primeira-vez",
    ["ONLY_FIRST_TT"] = "Ignorar se você já recebeu a recompensa.",
    ["MINIMAP_SHOW"] = "Mostrar botão no minimapa",
    ["MINIMAP_LOCK"] = "Travar botão no minimapa",

    -- Role mode
    ["Role mode"] = "Modo de papel",
    ["ROLE_MODE_TT"] = "AUTO usa a sua função da especialização; MANUAL usa as opções abaixo.",
    ["Auto (use current spec)"] = "Auto (usar spec atual)",
    ["Manual (choose roles)"] = "Manual (escolher papéis)",
    ["Role Tank"] = "Papel Tank",
    ["ROLE_TANK_TT"] = "Considerar Tank no modo MANUAL.",
    ["Role Healer"] = "Papel Healer",
    ["ROLE_HEAL_TT"] = "Considerar Healer no modo MANUAL.",
    ["Role Damage"] = "Papel DPS",
    ["ROLE_DAMAGER_TT"] = "Considerar DPS no modo MANUAL.",
    ["Scan interval (s)"] = "Intervalo da varredura (s)",
    ["Scan now"] = "Executar varredura agora",
    ["Reset alerts"] = "Resetar alertas",
    ["Test sound"] = "Testar som",
    ["Apply & Close"] = "Aplicar e Fechar",
    ["Close"] = "Fechar",
    ["Farm mode"] = "Modo de farm",
    ["Dungeon"] = "Masmorra",
    ["Raid"] = "Raide",
    ["Both"] = "Ambos",
    ["Auto (current role)"] = "Auto (papel atual)",
    ["TAGLINE"] = "Assistente de Call to Arms • EN/PT-BR • minimapa e som",

}

local base = _G.Makemo_L or function(k)
    return k
end
_G.Makemo_L = function(k)
    return Lpt[k] or base(k)
end
