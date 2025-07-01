-- Hacker-Style GUI by EA (No crosshair, FOV 210, movable frame)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerGUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Movable Frame (for settings or whatever you want)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

-- FOV Circle as GUI (radius 210)
local FOV = 210

local FOVCircle = Instance.new("Frame", ScreenGui)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Size = UDim2.new(0, FOV * 2, 0, FOV * 2)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 0

local circleOutline = Instance.new("UICorner", FOVCircle)
circleOutline.CornerRadius = UDim.new(1, 0)

local circleStroke = Instance.new("UIStroke", FOVCircle)
circleStroke.Color = Color3.new(1, 1, 1)
circleStroke.Thickness = 2
circleStroke.Transparency = 0.4

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

-- Aimbot using GUI-based FOV circle radius
local function getClosestTarget()
    local closest = nil
    local shortestDistance = FOV -- Use GUI circle radius

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

print("Hacker-style GUI loaded with FOV radius 210 and no crosshair.")
