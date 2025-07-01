-- Hacker-Style GUI by EA (ESP + FOV + Smooth Aimbot with built-in crosshair)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local FOV_RADIUS = 210
local AIMBOT_ENABLED = true

-- Movable GUI Frame (empty for now, can add buttons later)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Drag to move GUI
local dragging, dragInput, dragStart, startPos
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                  startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ESP Folder
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP_Boxes"
ESPFolder.Parent = ScreenGui

local function createESP(player)
    if player == LocalPlayer then return end
    local box = Instance.new("BillboardGui")
    box.Name = player.Name
    box.Adornee = player.Character and player.Character:FindFirstChild("Head")
    box.Size = UDim2.new(4, 0, 5, 0)
    box.AlwaysOnTop = true
    box.Parent = ESPFolder

    local frame = Instance.new("Frame", box)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.new(1, 1, 1)
end

local function removeESP(name)
    local box = ESPFolder:FindFirstChild(name)
    if box then box:Destroy() end
end

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if not ESPFolder:FindFirstChild(player.Name) then
                createESP(player)
            else
                ESPFolder[player.Name].Adornee = player.Character.Head
            end
        else
            removeESP(player.Name)
        end
    end
end

-- FOV Circle (Drawing API)
local circle = Drawing.new("Circle")
circle.Radius = FOV_RADIUS
circle.Color = Color3.new(1,1,1)
circle.Thickness = 2
circle.Filled = false
circle.Transparency = 0.6

RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)

-- Check if target is visible (raycast)
local function isVisible(targetHead)
    local origin = Camera.CFrame.Position
    local direction = (targetHead.Position - origin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    if raycastResult then
        return raycastResult.Instance:IsDescendantOf(targetHead.Parent)
    else
        return true
    end
end

-- Get closest target inside FOV, alive, enemy, visible
local function getClosestTarget()
    local closestPlayer = nil
    local shortestDistance = FOV_RADIUS

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 and player.Team ~= LocalPlayer.Team then
                local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortestDistance and isVisible(player.Character.Head) then
                        closestPlayer = player
                        shortestDistance = dist
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Smoothly move camera’s look at to target’s head
local AIM_SMOOTHNESS = 0.15
RunService.RenderStepped:Connect(function(delta)
    if not AIMBOT_ENABLED then return end
    local target = getClosestTarget()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local currentLook = Camera.CFrame.LookVector
        local desiredLook = (target.Character.Head.Position - Camera.CFrame.Position).Unit
        local newLook = currentLook:Lerp(desiredLook, AIM_SMOOTHNESS)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + newLook)
    end
end)

-- Update ESP every frame
RunService.RenderStepped:Connect(updateESP)

print("Hacker GUI with smooth aimbot loaded.")
