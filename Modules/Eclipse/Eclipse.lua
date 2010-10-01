if select(6, GetAddOnInfo("PitBull4_" .. (debugstack():match("[o%.][d%.][u%.]les\\(.-)\\") or ""))) ~= "MISSING" then return end

local PitBull4 = _G.PitBull4
if not PitBull4 then
  error("PitBull4_Eclipse requires PitBull4")
end

if select(2, UnitClass("player")) ~= "DRUID" or not PowerBarColor["ECLIPSE"] then
  return
end

-- CONSTANTS ----------------------------------------------------------------

-----------------------------------------------------------------------------

local L = PitBull4.L

local PitBull4_Eclipse= PitBull4:NewModule("Eclipse", "AceEvent-3.0")

PitBull4_Eclipse:SetModuleType("indicator")
PitBull4_Eclipse:SetName(L["Eclipse"])
PitBull4_Eclipse:SetDescription(L["Show Druid Eclipse Bar."])
PitBull4_Eclipse:SetDefaults({
  attach_to = "root",
  location = "out_top",
  position = 1,
})


function PitBull4_Eclipse:UpdateFrame(frame)

  if frame.unit ~= "player" then
    return self:ClearFrame(frame)
  else
    local form = GetShapeshiftFormID()
    if (form and form ~= MOONKIN_FORM) or GetPrimaryTalentTree() ~= 1 then
      return self:ClearFrame(frame)
    end
  end

  local eclipse = frame.Eclipse
  if not eclipse then
    eclipse = PitBull4.Controls.MakeEclipse(frame)
    frame.Eclipse = eclipse
    eclipse:SetFrameLevel(frame:GetFrameLevel() + 13)
    eclipse:SetSize(140,38)

    -- Check for buffs on creation
    self:UNIT_AURA("UNIT_AURA","player")
  end

  eclipse:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
  eclipse:SetLunarColor(unpack(PitBull4.PowerColors.BALANCE_NEGATIVE_ENERGY))
  eclipse:SetSolarColor(unpack(PitBull4.PowerColors.BALANCE_POSITIVE_ENERGY))
  eclipse:Show()

  return true
end

function PitBull4_Eclipse:ClearFrame(frame)
  local eclipse = frame.Eclipse
  if not eclipse then
    return false
  end
  frame.Eclipse = eclipse:Delete()

  return true
end

function PitBull4_Eclipse:UPDATE_SHAPESHIFT_FORM()
  for frame in PitBull4:IterateFramesForUnitID("player") do
    self:Update(frame)
  end
end
PitBull4_Eclipse.PLAYER_TALENT_UPDATE = PitBull4_Eclipse.UPDATE_SHAPESHIFT_FORM
PitBull4_Eclipse.MASTERY_UPDATE = PitBull4_Eclipse.UPDATE_SHAPESHIFT_FORM

function PitBull4_Eclipse:CheckForBuffs()
  local has_lunar, has_solar = false, false
  local i = 1
  while true do
    local name, _, _, _, _, _, _, _, _, _, spellID = UnitBuff("player", i)
    if not name then break end
    if spellID == ECLIPSE_BAR_SOLAR_BUFF_ID then
      has_solar = true
    elseif spellID == ECLIPSE_BAR_LUNAR_BUFF_ID then
      has_lunar = true
    end
    i = i + 1
  end
  return has_lunar, has_solar
end


function PitBull4_Eclipse:UNIT_AURA(event, unit)
  if unit == "player" then
    local has_lunar, has_solar = self:CheckForBuffs()
    for frame in PitBull4:IterateFramesForUnitID(unit) do
      local eclipse = frame.Eclipse
      if eclipse then
        eclipse:UpdateIcons(has_lunar, has_solar)
      end
    end
  end
end


function PitBull4_Eclipse:OnEnable()
  self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
  self:RegisterEvent("PLAYER_TALENT_UPDATE")
  self:RegisterEvent("MASTERY_UPDATE")
  self:RegisterEvent("UNIT_AURA")
end
