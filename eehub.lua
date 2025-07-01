-- Hacker-Style GUI by EA (Movable + Crosshair + Mobile support)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerGUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Active = true -- Important for dragging
Frame.Draggable = true

-- Crosshair Setup
local Crosshair = Instance.new("Frame", ScreenGui)
Crosshair.Size = UDim2.new(0, 20, 0, 20)
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
Crosshair.BackgroundColor3 = Color3.new(1, 1, 1)
Crosshair.BackgroundTransparency = 0
Crosshair.BorderSizePixel = 0

-- Crosshair lines
local horizontal = Instance.new("Frame", Crosshair)
horizontal.Size = UDim2.new(1, 0, 0, 2)
horizontal.Position = UDim2.new(0, 0, 0.5, -1)
horizontal.BackgroundColor3 = Color3.new(1, 0, 0)

local vertical = Instance.new("Frame", Crosshair)
vertical.Size = UDim2.new(0, 2, 1, 0)
vertical.Position = UDim2.new(0.5, -1, 0, 0)
vertical.BackgroundColor3 = Color3.new(1, 0, 0)

-- ESP Setup
local ESPFolder = Instance.new("Folder", ScreenGui)
ESPFolder.Name = "ESP_Boxes"

local function createESP(player)
    if player == LocalPlayer then return end
    if ESPFolder:FindFirstChild(player.Name) then return end
    local box = Instance.new("BillboardGui")
    box.Name = player.Name
    box.Adornee = player.Character and player.Character:FindFirstChild("Head")
    box.Size = UDim2.new(4, 0, 5, 0)
    box.AlwaysOnTop = true
    box.Parent = ESPFolder

    local frame = Instance.new("Frame", box)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    frame.BackgroundTransparency = 0.2
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
                ESPFolder[player.Name].Adornee = player.Character:FindFirstChild("Head")
            end
        else
            removeESP(player.Name)
        end
    end
end

RunService.RenderStepped:Connect(updateESP)

-- FOV and Aimbot
local FOV = 100
local circle = Drawing and Drawing.new and Drawing.new("Circle") or nil
if circle then
    circle.Radius = FOV
    circle.Color = Color3.new(1, 1, 1)
    circle.Thickness = 2
    circle.Filled = false
    circle.Transparency = 0.6
end

RunService.RenderStepped:Connect(function()
    if circle then
        circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
end)

local function getClosestTarget()
    local closest = nil
    local shortestDistance = FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).magnitude
                local humanoid = player.Character:FindFirstChild("Humanoid")
                local isDead = humanoid and humanoid.Health <= 0
                local isSameTeam = player.Team == LocalPlayer.Team
                local isObstructed = #Camera:GetPartsObscuringTarget({player.Character.Head.Position}, {LocalPlayer.Character}) > 0

                if dist < shortestDistance and not isDead and not isSameTeam and not isObstructed then
                    closest = player
                    shortestDistance = dist
                end
            end
        end
    end

    return closest
end

local aimEnabled = true
RunService.RenderStepped:Connect(function()
    if aimEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

print("Hacker-style GUI loaded (movable + mobile crosshair).")
