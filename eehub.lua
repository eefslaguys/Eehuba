-- Hacker-Style GUI by EA
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0

local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "ESP_Boxes"

local function createESP(player)
    if player == LocalPlayer then return end
    local box = Instance.new("BillboardGui", ESPFolder)
    box.Name = player.Name
    box.Adornee = player.Character and player.Character:FindFirstChild("Head")
    box.Size = UDim2.new(4, 0, 5, 0)
    box.AlwaysOnTop = true

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

RunService.RenderStepped:Connect(function()
    updateESP()
end)

-- FOV Circle
local FOV = 100
local circle = Drawing.new("Circle")
circle.Radius = FOV
circle.Color = Color3.new(1, 1, 1)
circle.Thickness = 2
circle.Filled = false
circle.Transparency = 0.6

RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)

-- Aimbot Core (basic lock to closest in FOV)
local function getClosestTarget()
    local closest = nil
    local shortestDistance = FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).magnitude
                local isDead = player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health <= 0
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

print("Hacker-style GUI loaded.")
