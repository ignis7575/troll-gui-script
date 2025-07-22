local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local function getPlayerByPartial(name)
	name = name:lower()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Name:lower():sub(1, #name) == name then
			return plr
		end
	end
	return nil
end

local function notify(msg)
	print("[TrollPanel] " .. msg)
end

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "UltimateTrollPanel"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 650)
frame.Position = UDim2.new(0, 40, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Text = "😈 Troll Panel"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local dropdown = Instance.new("TextBox", frame)
dropdown.PlaceholderText = "Type player name here"
dropdown.Text = ""
dropdown.Size = UDim2.new(0.9, 0, 0, 30)
dropdown.Position = UDim2.new(0.05, 0, 0, 35)
dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdown.Font = Enum.Font.Gotham
dropdown.TextSize = 14
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local kickLabel = Instance.new("TextLabel", frame)
kickLabel.Text = "Kick Message:"
kickLabel.Size = UDim2.new(0.9, 0, 0, 20)
kickLabel.Position = UDim2.new(0.05, 0, 0, 70)
kickLabel.BackgroundTransparency = 1
kickLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
kickLabel.Font = Enum.Font.Gotham
kickLabel.TextSize = 14
kickLabel.TextXAlignment = Enum.TextXAlignment.Left

local kickMessageBox = Instance.new("TextBox", frame)
kickMessageBox.Text = "⚠️ You have been kicked from this experience for scamming.\n\nIf you believe this is a mistake, please contact support.\nThank you for understanding."
kickMessageBox.PlaceholderText = "Enter fake kick message here"
kickMessageBox.Size = UDim2.new(0.9, 0, 0, 80)
kickMessageBox.Position = UDim2.new(0.05, 0, 0, 95)
kickMessageBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
kickMessageBox.TextColor3 = Color3.fromRGB(255, 255, 255)
kickMessageBox.Font = Enum.Font.Gotham
kickMessageBox.TextSize = 14
kickMessageBox.ClearTextOnFocus = false
kickMessageBox.MultiLine = true
kickMessageBox.TextWrapped = true
Instance.new("UICorner", kickMessageBox).CornerRadius = UDim.new(0, 6)

local function makeButton(text, yPos, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0.9, 0, 0, 40)
	btn.Position = UDim2.new(0.05, 0, 0, yPos)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 16
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.MouseButton1Click:Connect(callback)
end

local followLoop = nil
local following = false
local soapLoop = nil
local espEnabled = false
local espObjects = {}

makeButton("🧼 Soap Mode", 185, function()
	if soapLoop then return end
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	soapLoop = task.spawn(function()
		while true do
			if not soapLoop or not hrp then break end
			hrp.Velocity = Vector3.new(math.random(-60,60), 0, math.random(-60,60))
			task.wait(0.1)
		end
	end)
end)

makeButton("👻 Invisify", 230, function()
	local char = LocalPlayer.Character
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") or part:IsA("Decal") then
			part.Transparency = 1
		end
	end
	notify("You are now invisible.")
end)

makeButton("🧍 Follow Target", 275, function()
	if following then
		notify("Already following someone!")
		return
	end
	local name = dropdown.Text
	if name == "" then
		notify("Please enter a player name to follow.")
		return
	end
	local target = getPlayerByPartial(name)
	if not target then
		notify("Player not found: "..name)
		return
	end
	if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
		notify("Target's character not loaded yet.")
		return
	end
	local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then
		notify("Your character is not ready.")
		return
	end

	following = true
	followLoop = RunService.Heartbeat:Connect(function()
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and myHRP then
			myHRP.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
		else
			notify("Lost target or your character. Stopping follow.")
			if followLoop then followLoop:Disconnect() end
			followLoop = nil
			following = false
		end
	end)
	notify("Started following "..target.Name)
end)

makeButton("🛑 Unfollow", 320, function()
	if followLoop then followLoop:Disconnect() end
	followLoop = nil
	following = false
	notify("Stopped following.")
end)

makeButton("🔥 Fling Target", 365, function()
	local name = dropdown.Text
	if name == "" then
		notify("Please enter a player name to fling.")
		return
	end
	local target = getPlayerByPartial(name)
	if not target then
		notify("Player not found: "..name)
		return
	end
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then
		notify("Your character is not ready.")
		return
	end
	if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
		notify("Target's character not loaded yet.")
		return
	end

	local targetRoot = target.Character.HumanoidRootPart
	local bv = Instance.new("BodyVelocity")
	bv.Velocity = Vector3.new(9999,9999,9999)
	bv.MaxForce = Vector3.new(1e5,1e5,1e5)
	bv.P = 1e5
	bv.Parent = myRoot
	for i = 1, 5 do
		myRoot.CFrame = targetRoot.CFrame * CFrame.new(0,0,-2)
		task.wait(0.05)
	end
	bv:Destroy()
	notify("Fling attempted on "..target.Name)
end)

makeButton("➡️ TP to Player", 410, function()
	local name = dropdown.Text
	if name == "" then
		notify("Please enter a player name to teleport to.")
		return
	end
	local target = getPlayerByPartial(name)
	if not target then
		notify("Player not found: "..name)
		return
	end
	local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP or not targetHRP then
		notify("Either your character or target's character is not ready.")
		return
	end
	myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
	notify("Teleported to "..target.Name)
end)

makeButton("⬇️ TP All to Me", 455, function()
	local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then
		notify("Your character is not ready.")
		return
	end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			plr.Character.HumanoidRootPart.CFrame = myHRP.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
		end
	end
	notify("Teleported all players to you.")
end)

makeButton("⬆️ TP All to Player", 500, function()
	local name = dropdown.Text
	if name == "" then
		notify("Please enter a player name to teleport all to.")
		return
	end
	local target = getPlayerByPartial(name)
	if not target then
		notify("Player not found: "..name)
		return
	end
	local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if not targetHRP then
		notify("Target's character is not ready.")
		return
	end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			plr.Character.HumanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
		end
	end
	notify("Teleported all players to "..target.Name)
end)

makeButton("🏠 TP Me to Spawn", 545, function()
	local spawn = Workspace:FindFirstChildOfClass("SpawnLocation") or Workspace:FindFirstChild("SpawnLocation")
	local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not spawn or not myHRP then
		notify("Spawn or your character is not ready.")
		return
	end
	myHRP.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
	notify("Teleported to spawn.")
end)

makeButton("💀 Fake Crash", 590, function()
	local fakeGui = Instance.new("ScreenGui", game.CoreGui)
	fakeGui.Name = "FakeCrashScreen"

	local frameCrash = Instance.new("Frame", fakeGui)
	frameCrash.Size = UDim2.new(0, 400, 0, 200)
	frameCrash.Position = UDim2.new(0.5, -200, 0.5, -100)
	frameCrash.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Instance.new("UICorner", frameCrash).CornerRadius = UDim.new(0, 10)

	local label = Instance.new("TextLabel", frameCrash)
	label.Size = UDim2.new(1, -20, 1, -20)
	label.Position = UDim2.new(0, 10, 0, 10)
	label.Text = kickMessageBox.Text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.BackgroundTransparency = 1
	label.TextSize = 18
	label.Font = Enum.Font.SourceSansBold
	label.TextWrapped = true
	label.TextYAlignment = Enum.TextYAlignment.Top

	local sound = Instance.new("Sound", frameCrash)
	sound.SoundId = "rbxassetid://9118823102"
	sound.Volume = 1
	sound:Play()
end)

makeButton("👁️ Toggle ESP", 635, function()
	espEnabled = not espEnabled
	if espEnabled then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local box = Instance.new("BoxHandleAdornment")
				box.Adornee = plr.Character.HumanoidRootPart
				box.AlwaysOnTop = true
				box.ZIndex = 10
				box.Size = plr.Character.HumanoidRootPart.Size + Vector3.new(0.5, 1, 0.5)
				box.Color3 = Color3.new(1, 0, 0)
				box.Transparency = 0.5
				box.Parent = plr.Character.HumanoidRootPart
				espObjects[plr] = box
			end
		end
	else
		for _, box in pairs(espObjects) do
			if box and box.Parent then
				box:Destroy()
			end
		end
		espObjects = {}
	end
end)
