-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local TargetPlayer = nil
local FollowConnection = nil
local FlingRunning = false

-- Helper to find player by partial name (case-insensitive)
local function findPlayerByPartialName(part)
    part = part:lower()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Name:lower():find(part) then
            return plr
        end
    end
    return nil
end

-- Create GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "TrollGui"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Text = "Trolling GUI"

-- Target input label and box
local TargetBoxLabel = Instance.new("TextLabel", MainFrame)
TargetBoxLabel.Size = UDim2.new(0.5, -10, 0, 25)
TargetBoxLabel.Position = UDim2.new(0,10,0,40)
TargetBoxLabel.BackgroundTransparency = 1
TargetBoxLabel.TextColor3 = Color3.new(1,1,1)
TargetBoxLabel.Font = Enum.Font.SourceSans
TargetBoxLabel.TextSize = 16
TargetBoxLabel.Text = "Target Player:"

local TargetBox = Instance.new("TextBox", MainFrame)
TargetBox.Size = UDim2.new(0.45, 0, 0, 25)
TargetBox.Position = UDim2.new(0.5, 0, 0, 40)
TargetBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
TargetBox.TextColor3 = Color3.new(1,1,1)
TargetBox.Font = Enum.Font.SourceSans
TargetBox.TextSize = 16
TargetBox.ClearTextOnFocus = false
TargetBox.PlaceholderText = "Partial name"

TargetBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local plr = findPlayerByPartialName(TargetBox.Text)
        if plr then
            TargetPlayer = plr
            TargetBox.Text = plr.Name
            print("Target set to "..plr.Name)
        else
            TargetPlayer = nil
            warn("No player found with name containing: "..TargetBox.Text)
        end
    end
end)

-- Button helper function
local function createButton(text, yPos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = text
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Teleport to target
createButton("Teleport To Target", 80, function()
    if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
    else
        warn("Cannot teleport: Target or your character missing")
    end
end)

-- Fling target control
createButton("Start Fling Target", 120, function()
    if not TargetPlayer or not TargetPlayer.Character or not TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("No valid target for fling")
        return
    end
    if FlingRunning then
        warn("Fling already running")
        return
    end
    FlingRunning = true
    local targetHRP = TargetPlayer.Character.HumanoidRootPart
    local plrHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not plrHRP then
        warn("Your HumanoidRootPart not found")
        FlingRunning = false
        return
    end
    spawn(function()
        while FlingRunning and TargetPlayer and TargetPlayer.Character and targetHRP.Parent do
            plrHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 0)
            plrHRP.Velocity = Vector3.new(0,50,0)
            wait(0.1)
        end
    end)
end)

createButton("Stop Fling", 160, function()
    FlingRunning = false
end)

-- Follow target toggle
createButton("Toggle Follow Target", 200, function()
    if FollowConnection then
        FollowConnection:Disconnect()
        FollowConnection = nil
        print("Stopped following")
        return
    end
    if not TargetPlayer or not TargetPlayer.Character or not TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("No valid target to follow")
        return
    end
    local plrHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not plrHRP then
        warn("Your HumanoidRootPart not found")
        return
    end

    FollowConnection = RunService.Heartbeat:Connect(function()
        if not TargetPlayer or not TargetPlayer.Character or not TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            FollowConnection:Disconnect()
            FollowConnection = nil
            print("Target lost, stopped following")
            return
        end
        plrHRP.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(2,0,0)
    end)
    print("Started following "..TargetPlayer.Name)
end)

-- Follow random player button
createButton("Follow Random Player", 240, function()
    local plrs = Players:GetPlayers()
    if #plrs < 2 then
        warn("Not enough players to follow random")
        return
    end
    local candidates = {}
    for _, p in pairs(plrs) do
        if p ~= LocalPlayer then
            table.insert(candidates, p)
        end
    end
    if #candidates == 0 then
        warn("No players to follow")
        return
    end
    TargetPlayer = candidates[math.random(1, #candidates)]
    TargetBox.Text = TargetPlayer.Name
    print("Randomly selected target: "..TargetPlayer.Name)

    if FollowConnection then
        FollowConnection:Disconnect()
        FollowConnection = nil
    end
    local plrHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not plrHRP then
        warn("Your HumanoidRootPart not found")
        return
    end
    FollowConnection = RunService.Heartbeat:Connect(function()
        if not TargetPlayer or not TargetPlayer.Character or not TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            FollowConnection:Disconnect()
            FollowConnection = nil
            print("Target lost, stopped following")
            return
        end
        plrHRP.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(2,0,0)
    end)
    print("Started following "..TargetPlayer.Name)
end)

-- Troll target multi-effect button
createButton("Troll Target (Multi)", 280, function()
    if not TargetPlayer or not TargetPlayer.Character then
        warn("No valid target for trolling")
        return
    end

    local hrp = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then
        warn("Target missing required parts")
        return
    end

    -- Spin target rapidly
    coroutine.wrap(function()
        for i=1,30 do
            if not TargetPlayer or not TargetPlayer.Character then break end
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(30), 0)
            wait(0.1)
        end
    end)()

    -- Change WalkSpeed repeatedly
    coroutine.wrap(function()
        for i=1,10 do
            if not humanoid then break end
            humanoid.WalkSpeed = math.random(50,150)
            wait(0.5)
        end
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end)()

    -- Random teleport nearby
    coroutine.wrap(function()
        for i=1,10 do
            if not hrp then break end
            local offset = Vector3.new(math.random(-10,10),0,math.random(-10,10))
            hrp.CFrame = hrp.CFrame + offset
            wait(0.4)
        end
    end)()
end)
