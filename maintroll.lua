-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- GUI setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "TrollGui"

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

local ScrollingFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.BackgroundTransparency = 1

-- Button function helper
local function createButton(text, func)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 0, 30)
	button.Position = UDim2.new(0, 5, 0, #ScrollingFrame:GetChildren() * 35)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.TextColor3 = Color3.new(1,1,1)
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 18
	button.Text = text
	button.Parent = ScrollingFrame
	button.MouseButton1Click:Connect(func)
end

-- Invisibility
local invisActive = false
local function invis()
	local char = LocalPlayer.Character
	if not char then return end
	invisActive = true
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
		elseif part:IsA("Decal") then
			part.Transparency = 1
		end
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
end

-- Fling all
local flingActive = false
local function flingAll()
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	flingActive = true
	task.spawn(function()
		while flingActive do
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					hrp.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0,2,0)
					task.wait(0.1)
				end
			end
		end
	end)
end

-- ESP
local espActive = false
local espList = {}
local function toggleESP()
	espActive = not espActive
	if espActive then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
				local bill = Instance.new("BillboardGui", plr.Character.Head)
				bill.Name = "ESPTag"
				bill.Size = UDim2.new(0, 100, 0, 20)
				bill.StudsOffset = Vector3.new(0, 3, 0)
				bill.AlwaysOnTop = true
				local label = Instance.new("TextLabel", bill)
				label.Text = plr.Name
				label.TextColor3 = Color3.new(1, 0, 0)
				label.TextStrokeTransparency = 0
				label.BackgroundTransparency = 1
				label.Size = UDim2.new(1, 0, 1, 0)
			end
		end
	else
		for _, plr in pairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChild("Head") then
				local esp = plr.Character.Head:FindFirstChild("ESPTag")
				if esp then esp:Destroy() end
			end
		end
	end
end

-- Noclip
local noclip = false
RunService.Stepped:Connect(function()
	if noclip and LocalPlayer.Character then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- Teleport
local function tpToPlayer()
	local name = game:GetService("StarterGui"):PromptInput("Enter partial username:")
	if not name or name == "" then return end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Name:lower():sub(1, #name) == name:lower() and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character:MoveTo(plr.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
			break
		end
	end
end

local function tpAllToMe()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			plr.Character.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(math.random(-5,5), 2, math.random(-5,5))
		end
	end
end

-- Stop All
local function stopAll()
	invisActive = false
	flingActive = false
	noclip = false
	toggleESP() -- call once to disable
	toggleESP() -- reset to off state
	local char = LocalPlayer.Character
	if not char then return end
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 0
			part.CanCollide = true
		elseif part:IsA("Decal") then
			part.Transparency = 0
		end
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	end
end

-- Buttons
createButton("Invisibility", invis)
createButton("Fling All", flingAll)
createButton("ESP Toggle", toggleESP)
createButton("Noclip Toggle", function() noclip = not noclip end)
createButton("TP to Player", tpToPlayer)
createButton("TP All to Me", tpAllToMe)
createButton("Stop All", stopAll)
