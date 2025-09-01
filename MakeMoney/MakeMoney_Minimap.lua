-- MakeMoney_Minimap.lua
local L = _G.Makemo_L or function(k) return k end

local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
local LDI = LibStub and LibStub("LibDBIcon-1.0", true)

-- caminhos dos dois estados do ícone
local ICON_ACTIVE   = "Interface\\AddOns\\MakeMoney\\media\\icon_active.tga"
local ICON_INACTIVE = "Interface\\AddOns\\MakeMoney\\media\\icon_inactive.tga"

-- expõe função para sincronizar visual conforme 'scan.active'
function MakeMoney_UpdateMinimapIcon()
  local path = (MakeMoneyDB and MakeMoneyDB.scan and MakeMoneyDB.scan.active) and ICON_ACTIVE or ICON_INACTIVE
  if LDI and LDB then
    -- LDB/LDI: basta trocar o ícone do data object
    if _G.MakeMoney_Launcher then
      _G.MakeMoney_Launcher.icon = path
    end
    -- se já estiver registrado, força atualização leve
    if LDI:IsRegistered("MakeMoney") then
      -- algumas versões têm Refresh; se não, a troca acima já resolve
      if LDI.Refresh then LDI:Refresh("MakeMoney", MakeMoneyDB.minimap.ldb) end
    end
  elseif _G.MakeMoneyMinimap then
    _G.MakeMoneyMinimap:SetNormalTexture(path)
  end
end

-- função pública para UI ligar/desligar ícone
function MakeMoney_SetMinimapShown(v)
  MakeMoneyDB.minimap.shown = v
  if LDI and LDB then
    if v then LDI:Show("MakeMoney") else LDI:Hide("MakeMoney") end
  elseif MakeMoneyMinimap then
    if v then MakeMoneyMinimap:Show() else MakeMoneyMinimap:Hide() end
  end
end

if LDI and LDB then
  -- ======== caminho "padrão de addons" (LibDBIcon) ========
  local launcher = LDB:NewDataObject("MakeMoney", {
    type = "launcher",
    icon = ICON_ACTIVE,   -- valor inicial; será atualizado por MakeMoney_UpdateMinimapIcon()
    OnClick = function(self, button)
      if button == "RightButton" then
        if MakeMoney_ToggleUI then MakeMoney_ToggleUI(true) end
      else
        if IsShiftKeyDown() then
          MakeMoneyDB.scan.active = not MakeMoneyDB.scan.active
          MakeMoney_UpdateMinimapIcon()  -- <== troca visual
          print("|cffffd700MakeMoney|r: "..(MakeMoneyDB.scan.active and "scan ON" or "scan OFF"))
        elseif IsControlKeyDown() then
          print("|cffffd700MakeMoney|r: reset flag")
        else
          MakeMoney_Ping()
        end
      end
    end,
    OnTooltipShow = function(tt)
      tt:AddLine("|cffffd700MakeMoney|r")
      tt:AddLine((L("Scan")..": ")..(MakeMoneyDB.scan.active and L("ACTIVE") or L("PAUSED")))
      tt:AddLine(" ")
      tt:AddLine(L("TT_LEFT")); tt:AddLine(L("TT_SHIFT")); tt:AddLine(L("TT_CTRL")); tt:AddLine(L("TT_RIGHT"))
    end,
  })
  _G.MakeMoney_Launcher = launcher

  C_Timer.After(0, function()
    MakeMoneyDB.minimap.ldb = MakeMoneyDB.minimap.ldb or { hide = false, minimapPos = 180 }
    LDI:Register("MakeMoney", launcher, MakeMoneyDB.minimap.ldb)
    if not MakeMoneyDB.minimap.shown then LDI:Hide("MakeMoney") end
    MakeMoney_UpdateMinimapIcon() -- <== aplica estado na carga
  end)

else
  -- ======== fallback manual ========
  local function deg2rad(d) return d * math.pi / 180 end

  local btn = CreateFrame("Button", "MakeMoneyMinimap", UIParent)
  btn:SetSize(18, 18)
  btn:SetFrameStrata("MEDIUM")
  btn:SetFrameLevel((Minimap and Minimap:GetFrameLevel() or 1) + 8)
  btn:SetClampedToScreen(true)
  btn:SetNormalTexture(ICON_ACTIVE)
  btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  local function UpdatePos()
    local a = deg2rad((MakeMoneyDB.minimap.angle or 180))
    local r = (Minimap:GetWidth()/2) - 4
    btn:ClearAllPoints()
    btn:SetPoint("CENTER", Minimap, "CENTER", math.cos(a)*r, math.sin(a)*r)
  end

  btn:RegisterForDrag("LeftButton")
  btn:SetMovable(true)
  btn:SetScript("OnDragStart", function(self)
    if not MakeMoneyDB.minimap.lock then self:StartMoving() end
  end)
  btn:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local mx, my = Minimap:GetCenter()
    local cx, cy = self:GetCenter()
    if mx and my and cx and cy then
      MakeMoneyDB.minimap.angle = math.deg(math.atan2(cy - my, cx - mx))
    end
    UpdatePos()
  end)

  btn:SetScript("OnClick", function(_, button)
    if button == "RightButton" then
      if MakeMoney_ToggleUI then MakeMoney_ToggleUI(true) end
    else
      if IsShiftKeyDown() then
        MakeMoneyDB.scan.active = not MakeMoneyDB.scan.active
        MakeMoney_UpdateMinimapIcon()  -- <== troca visual
        print("|cffffd700MakeMoney|r: "..(MakeMoneyDB.scan.active and "scan ON" or "scan OFF"))
      elseif IsControlKeyDown() then
        print("|cffffd700MakeMoney|r: reset flag")
      else
        MakeMoney_Ping()
      end
    end
  end)

  btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("|cffffd700MakeMoney|r")
    GameTooltip:AddLine((L("Scan")..": ")..(MakeMoneyDB.scan.active and L("ACTIVE") or L("PAUSED")))
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L("TT_LEFT"))
    GameTooltip:AddLine(L("TT_SHIFT"))
    GameTooltip:AddLine(L("TT_CTRL"))
    GameTooltip:AddLine(L("TT_RIGHT"))
    GameTooltip:Show()
  end)
  btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

  local f = CreateFrame("Frame")
  f:RegisterEvent("PLAYER_LOGIN")
  f:SetScript("OnEvent", function()
    if MakeMoneyDB.minimap.shown then btn:Show() else btn:Hide() end
    C_Timer.After(0.1, function() UpdatePos(); MakeMoney_UpdateMinimapIcon() end)
  end)

  -- expõe p/ UI
  function MakeMoney_SetMinimapShown(v)
    if v then btn:Show() else btn:Hide() end
  end
  _G.MakeMoneyMinimap = btn
end
