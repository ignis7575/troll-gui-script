-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Chat = game:GetService("Chat")

local LocalPlayer = Players.LocalPlayer

-- Variables
local TargetPlayer = nil
local FollowConnection = nil
local FlingRunning = false
local NoclipEnabled = false
local ESPBoxes = {}

local AimbotEnabled = false
local AimbotTarget = nil
local AimbotSmoothness = 0.15 -- Lower is faster

-- Helper: Find player by partial name
local function findPlayerByPartialName(part)
    part = part:lower()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Name:lower():find(part) then
            return plr
        end
    end
    return nil
end

-- Helper: Check if character is visible from camera (simple check)
local function isVisible(part)
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 500
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    if raycastResult then
        return raycastResult.Instance:IsDescendantOf(part.Parent)
    end
    return false
end

-- Helper: Get closest visible player to mouse
local function getClosestPlayerToMouse()
    local mousePos = UserInputService:GetMouseLocation()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local headPos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
            if onScreen and isVisible(plr.Character.Head) then
                local screenPos = Vector2.new(headPos.X, headPos.Y)
                local distance = (Vector2.new(mousePos.X, mousePos.Y) - screenPos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = plr
                end
            end
        end
    end

    return closestPlayer
end

-- Aimbot update function (smoothly moves camera to target)
local function updateAimbot()
    if not AimbotEnabled then return end
    if not AimbotTarget or not AimbotTarget.Character or not AimbotTarget.Character:FindFirstChild("Head") then return end

    local targetPos = AimbotTarget.Character.Head.Position
    local cameraCFrame = Camera.CFrame
    local direction = (targetPos - cameraCFrame.Position).Unit
    local newLookAt = CFrame.new(cameraCFrame.Position, cameraCFrame.Position + direction)
    
    -- Smooth lerp camera CFrame
    Camera.CFrame = cameraCFrame:Lerp(newLookAt, AimbotSmoothness)
end

-- Toggle aimbot with right mouse button
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotEnabled = not AimbotEnabled
        if AimbotEnabled then
            AimbotTarget = getClosestPlayerToMouse()
            print("Aimbot enabled. Target: "..(AimbotTarget and AimbotTarget.Name or "None"))
        else
            AimbotTarget = nil
            print("Aimbot disabled.")
        end
    end
end)

-- Update target while aimbot is enabled every frame
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        -- Update target dynamically
        AimbotTarget = getClosestPlayerToMouse()
        updateAimbot()
    end
end)

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "CoolkidTrollGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 24
Title.Text = "Coolkid Style Troll GUI + Aimbot"

-- Scrolling frame for buttons (optional for more buttons)
local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollFrame.Size = UDim2.new(1, -20, 1, -50)
ScrollFrame.Position = UDim2.new(0,10,0,40)
ScrollFrame.CanvasSize = UDim2.new(0,0,5,0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

-- Layout inside ScrollFrame
local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- Target input label and box
local TargetBoxLabel = Instance.new("TextLabel", ScrollFrame)
TargetBoxLabel.Size = UDim2.new(1,0,0,20)
TargetBoxLabel.BackgroundTransparency = 1
TargetBoxLabel.TextColor3 = Color3.new(1,1,1)
TargetBoxLabel.Font = Enum.Font.SourceSans
TargetBoxLabel.TextSize = 16
TargetBoxLabel.Text = "Target Player (partial name):"

local TargetBox = Instance.new("TextBox", ScrollFrame)
TargetBox.Size = UDim2.new(1,0,0,30)
TargetBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
TargetBox.TextColor3 = Color3.new(1,1,1)
TargetBox.Font = Enum.Font.SourceSans
TargetBox.TextSize = 18
TargetBox.ClearTextOnFocus = false
TargetBox.PlaceholderText = "Type and press Enter"

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

-- Button creator helper
local function createButton(text, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,0,0,30)
    btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = text
    btn.AutoButtonColor = true
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Teleport to target
createButton("Teleport To Target", ScrollFrame, function()
    if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
    else
        warn("Cannot teleport: Target or your character missing")
    end
end)

-- Fling target improved
createButton("Start Fling Target", ScrollFrame, function()
    if not TargetPlayer or not TargetPlayer.Character or not TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("No valid target for fling")
        return
    end
    if FlingRunning then
        warn("Fling already running")
        return
    end
    local plrHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not plrHRP then
        warn("Your HumanoidRootPart not found")
        return
    end

    local targetHRP = TargetPlayer.Character.HumanoidRootPart
    FlingRunning = true

    spawn(function()
        while FlingRunning and TargetPlayer and TargetPlayer.Character and targetHRP.Parent and plrHRP.Parent do
            plrHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1)
            plrHRP.Velocity = Vector3.new(0, 100, 0)
            wait(0.05)
        end
    end)
end)

createButton("Stop Fling", ScrollFrame, function()
    FlingRunning = false
end)

-- Follow target toggle
createButton("Toggle Follow Target", ScrollFrame, function()
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

-- Noclip toggle
createButton("Toggle Noclip", ScrollFrame, function()
    NoclipEnabled = not NoclipEnabled
    print("Noclip is now", NoclipEnabled and "ON" or "OFF")
end)

-- Noclip logic
RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- ESP implementation
local function createESPForPlayer(plr)
    if ESPBoxes[plr] then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESPBox"
    box.Adornee = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Size = Vector3.new(4,5,4)
    box.Transparency = 0.5
    box.Color3 = Color3.new(1,0,0)
    box.Parent = game.CoreGui
    ESPBoxes[plr] = box
end

local function removeESPForPlayer(plr)
    if ESPBoxes[plr] then
        ESPBoxes[plr]:Destroy()
        ESPBoxes[plr] = nil
    end
end

local function updateESP()
    for plr, box in pairs(ESPBoxes) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            box.Adornee = plr.Character.HumanoidRootPart
        else
            removeESPForPlayer(plr)
        end
    end
end

local ESPEnabled = false
createButton("Toggle ESP", ScrollFrame, function()
    ESPEnabled = not ESPEnabled
    if ESPEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                createESPForPlayer(plr)
            end
        end
        print("ESP Enabled")
    else
        for _, plr in pairs(Players:GetPlayers()) do
            removeESPForPlayer(plr)
        end
        print("ESP Disabled")
    end
end)

RunService.Heartbeat:Connect(function()
    if ESPEnabled then
        updateESP()
    end
end)

-- Chat trolling (spamming fake messages)
local ChatSpamRunning = false
local ChatSpamMessages = {
    "You got trolled!",
    "Coolkid was here!",
    "Haha, noob!",
    "Get rekt!",
    "Follow me if you can!",
    "This server is mine!"
}

createButton("Toggle Chat Spam", ScrollFrame, function()
    if ChatSpamRunning then
        ChatSpamRunning = false
        print("Chat spam stopped")
        return
    end

    ChatSpamRunning = true
    spawn(function()
        while ChatSpamRunning do
            if LocalPlayer and LocalPlayer.Character then
                local msg = ChatSpamMessages[math.random(1, #ChatSpamMessages)]
                Chat:Chat(LocalPlayer.Character.Head, msg, Enum.ChatColor.Red)
            end
            wait(2)
        end
