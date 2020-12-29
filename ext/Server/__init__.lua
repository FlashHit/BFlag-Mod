ServerUtils:SetCustomGameModeName('BFLAG') 	
local timerStarted = false
local elapsedTime = 0

local cpEntityA = nil
local cpEntityC = nil

local updateEvent = nil

Events:Subscribe('Level:Loaded', function()
	if SharedUtils:GetLevelName() == "Levels/MP_001/MP_001" and SharedUtils:GetCurrentGameMode() == "ConquestSmall0" then
		if ServerUtils:GetCustomGameModeName() == nil then
			ServerUtils:SetCustomGameModeName('BFLAG') 	
		elseif ServerUtils:GetCustomGameModeName() ~= 'BFLAG' then
			ServerUtils:SetCustomGameModeName('BFLAG') 	
		end
		countingDown = false
		
		CaptureFlags()
		timerStarted = true
		updateEvent = Events:Subscribe('Engine:Update', OnUpdate)
	elseif ServerUtils:GetCustomGameModeName() ~= nil and ServerUtils:GetCustomGameModeName() == 'BFLAG' then
		ServerUtils:ClearCustomGameModeName()
	end
end)

function OnUpdate(dt)

	if timerStarted then

		elapsedTime = elapsedTime + dt

		if elapsedTime > 2 and cpEntityA ~= nil and cpEntityC ~= nil then

			cpEntityA:FireEvent("Disable")
			cpEntityC:FireEvent("Disable")
			updateEvent:Unsubscribe()
		end
	end
end

function CaptureFlags()

	local cpIterator = EntityManager:GetIterator("ServerCapturePointEntity")

	local cpEntity = cpIterator:Next()
	while cpEntity do

		cpEntity = CapturePointEntity(cpEntity)

		if cpEntity.name == "ID_H_US_A" then

			cpEntityA = cpEntity
			cpEntityA.team = TeamId.Team1
			cpEntityA.isControlled = true

		elseif cpEntity.name == "ID_H_US_C" then

			cpEntityC = cpEntity
			cpEntityC.team = TeamId.Team2
			cpEntityC.isControlled = true
		end

		cpEntity = cpIterator:Next()
	end
end

Events:Subscribe('Level:Destroy', function()

	timerStarted = false
	elapsedTime = 0
	cpEntityA = nil
	cpEntityC = nil
	updateEvent = nil
end)