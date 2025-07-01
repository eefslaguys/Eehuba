-- Hacker-Style GUI by EA with working aimbot, ESP, and movable GUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI Setup (movable)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "HackerGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 150)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

-- Title
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Hacker-Style GUI by EA"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold

-- ESP toggle button
local espEnabled = true
local espBtn = Instance.new("TextButton", Frame)
espBtn.Size = UDim2.new(0.9, 0, 0, 40)
espBtn.Position = UDim2.new(0.05, 0, 0, 40)
espBtn.Text = "ESP: ON"
espBtn.Font = Enum.Font.SourceSans
espBtn.TextSize = 22
espBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
espBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
espBtn.AutoButtonColor = true

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    espBtn.TextColor3 = espEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

-- Aimbot toggle button
local aimEnabled = false
local aimBtn = Instance.new("TextButton", Frame)
aimBtn.Size = UDim2.new(0.9, 0, 0, 40)
aimBtn.Position = UDim2.new(0.05, 0, 0, 90)
aimBtn.Text = "Aimbot: OFF"
aimBtn.Font = Enum.Font.SourceSans
aimBtn.TextSize = 22
aimBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
aimBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
aimBtn.AutoButtonColor = true

aimBtn.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    aimBtn.Text = "Aimbot: " .. (aimEnabled and "ON" or "OFF")
    aimBtn.TextColor3 = aimEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

-- ESP Setup
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
    frame.BackgroundTransparency = 0.6
    frame.BorderSizePixel = 0
end

local function removeESP(name)
    local box = ESPFolder:FindFirstChild(name)
    if box then box:Destroy() end
end

local function updateESP()
    if not espEnabled then
        for _, box in pairs(ESPFolder:GetChildren()) do
            box:Destroy()
        end
        return
    end

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

-- FOV Circle Setup
local FOV = 210
local circle = Drawing.new("Circle")
circle.Radius = FOV
circle.Color = Color3.fromRGB(255, 255, 255)
circle.Thickness = 2
circle.Filled = false
circle.Transparency = 0.6

RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- Aimbot Core

local function isVisible(target)
    local origin = Camera.CFrame.Position
    local targetPos = target.Character.Head.Position
    local ray = Ray.new(origin, (targetPos - origin).Unit * 500)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, target.Character}, false, true)
    if hit and hit:IsDescendantOf(target.Character) then
        return true
    end
    return false
end

local function getClosestTarget()
    local closestPlayer = nil
    local shortestDistance = FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    local sameTeam = player.Team == LocalPlayer.Team
                    if dist < shortestDistance and not sameTeam and isVisible(player) then
                        shortestDistance = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end

    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if aimEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local newCFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
            Camera.CFrame = newCFrame
        end
    end
end)

print("Hacker-style GUI loaded.")
