local runService = game:GetService("RunService")

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid", 5)

local fps = nil
local stateConnection = nil

local frameTimes = {}
local startTime = (runService:IsRunning() and time or os.clock())
local timeClock = runService:IsRunning() and time or os.clock

local humanoidStateTypes = {
	Enum.HumanoidStateType.Jumping;
	Enum.HumanoidStateType.Climbing;
	Enum.HumanoidStateType.Freefall;
	Enum.HumanoidStateType.Running;
	Enum.HumanoidStateType.Landed;
	Enum.HumanoidStateType.Seated;
	Enum.HumanoidStateType.Swimming;
	Enum.HumanoidStateType.GettingUp;
	Enum.HumanoidStateType.FallingDown;
}

local calculateFPS = function()
	local currentTime = timeClock()

	for i = #frameTimes, 1, -1 do
		if frameTimes[i] < currentTime - 1 then
			table.remove(frameTimes, i)
		end
	end

	table.insert(frameTimes, 1, currentTime)

	if currentTime - startTime >= 1 then
		return #frameTimes
	else
		return math.floor(#frameTimes / (currentTime - startTime))
	end
end

local onStateChanged = function(oldState, newState)
	if newState == oldState then
		return
	end

	for _, state in pairs(humanoidStateTypes) do
		if state ~= newState then
			humanoid:SetStateEnabled(state, false)
		end
	end

	task.wait((1 / 60) - (1 / fps))

	for _, state in pairs(humanoidStateTypes) do
		if state ~= newState then
			humanoid:SetStateEnabled(state, true)
		end
	end
end

runService.Heartbeat:Connect(function()
	fps = calculateFPS()

	if fps > 61 and not stateConnection then
		stateConnection = humanoid.StateChanged:Connect(onStateChanged)
	elseif stateConnection and fps <= 61 then
		stateConnection:Disconnect()
		stateConnection = nil
	end
end)
