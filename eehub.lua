-- Hacker-Style GUI with Toggleable Aimbot by EA
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
local FOV_RADIUS = 210

-- Globals
local AimbotEnabled = false
local HoldingButton = false

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Frame (movable)
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 120)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Hacker GUI by EA"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Parent = Frame

-- Aimbot Toggle Button
local AimbotBtn = Instance.new("TextButton")
AimbotBtn.Size = UDim2.new(1, -20, 0, 40)
AimbotBtn.Position = UDim2.new(0, 10, 0, 40)
AimbotBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
AimbotBtn.TextColor3 = Color3.fromRGB(255,255,255)
AimbotBtn.Font = Enum.Font.GothamBold
AimbotBtn.TextSize = 16
AimbotBtn.Text = "Aimbot: OFF"
AimbotBtn.Parent = Frame

AimbotBtn.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimbotBtn.Text = AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)

-- ESP Setup
local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "ESP_Boxes"

local function createESP(player)
    if player == LocalPlayer then return end
    local box = Instance.new("BillboardGui")
    box.Name = player.Name
    box.Adornee = player.Character and player.Character:FindFirstChild("Head")
    box.Size = UDim2.new(4, 0, 5, 0)
    box.AlwaysOnTop = true
    box.Parent = ESPFolder

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    frame.BackgroundTransparency = 0.2
    frame.Parent = box
end

local function removeESP(name)
    local box = ESPFolder:FindFirstChild(name)
    if box then box:Destroy() end
end

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                if not ESPFolder:FindFirstChild(player.Name) then
                    createESP(player)
                else
                    ESPFolder[player.Name].Adornee = player.Character.Head
                end
            else
                removeESP(player.Name)
            end
        else
            removeESP(player.Name)
        end
    end
end

RunService.RenderStepped:Connect(updateESP)

-- FOV Circle (using Drawing API)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = FOV_RADIUS
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 0.6
FOVCircle.NumSides = 64

-- Get closest valid target inside FOV
local function GetClosestTarget()
    local closestTarget = nil
    local shortestDist = FOV_RADIUS

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health > 0 then
                local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                    -- Check line of sight
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                    local rayResult = workspace:Raycast(Camera.CFrame.Position, (player.Character.Head.Position - Camera.CFrame.Position).Unit * 500, rayParams)
                    local visible = not rayResult or rayResult.Instance:IsDescendantOf(player.Character)
                    if dist < shortestDist and visible then
                        closestTarget = player
                        shortestDist = dist
                    end
                end
            end
        end
    end
    return closestTarget
end

-- Smooth aim function
local function AimAt(target)
    if not target or not target.Character or not target.Character:FindFirstChild("Head") then return end
    local headPos = target.Character.Head.Position
    local camPos = Camera.CFrame.Position
    local targetCFrame = CFrame.new(camPos, headPos)
    -- Tween the camera to target
    TweenService:Create(Camera, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = targetCFrame}):Play()
end

-- Main loop
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    FOVCircle.Visible = AimbotEnabled

    if AimbotEnabled then
        local target = GetClosestTarget()
        if target then
            AimAt(target)
        end
    end
end)

print("Hacker-style GUI with aimbot loaded.")
