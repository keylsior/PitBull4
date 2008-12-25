if select(6, GetAddOnInfo("PitBull4_" .. (debugstack():match("[o%.][d%.][u%.]les\\(.-)\\") or ""))) ~= "MISSING" then return end

local PitBull4 = _G.PitBull4
if not PitBull4 then
	error("PitBull4_ReputationBar requires PitBull4")
end

local PitBull4_ReputationBar = PitBull4:NewModule("ReputationBar")

PitBull4_ReputationBar:SetModuleType("statusbar")
PitBull4_ReputationBar:SetName("Reputation Bar")
PitBull4_ReputationBar:SetDescription("Show a reputation bar.")
PitBull4_ReputationBar:SetDefaults({
	size = 1,
	position = 3,
})

function PitBull4_ReputationBar:GetValue(frame)
	if frame.unit ~= "player" then
		return nil
	end
	
	local repname, repreaction, repmin, repmax, repvalue = GetWatchedFactionInfo()
	if not repname then
		return nil
	end
	
	return (repvalue - repmin) / (repmax - repmin)
end

function PitBull4_ReputationBar:GetColor(frame)
	return 0, 1, 0
end

PitBull4_ReputationBar:SetValueFunction('GetValue')
PitBull4_ReputationBar:SetColorFunction('GetColor')

hooksecurefunc("ReputationWatchBar_Update", function()
	if not PitBull4_ReputationBar:IsEnabled() then
		return
	end
	PitBull4_ReputationBar:UpdateForUnitID("player")
end)
