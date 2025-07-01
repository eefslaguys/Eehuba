-- Hacker-Style GUI by EA (with toggle buttons and smooth instant aimbot)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerGUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Movable Frame
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 130)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local function createButton(text, pos)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 20
    btn.Text = text
    btn.AutoButtonColor = true
    return btn
end

-- Toggle Buttons
local espEnabled = true
local aimbotEnabled = true

local espBtn = createButton("ESP: ON", UDim2.new(0, 10, 0, 10))
local aimBtn = createButton("Aimbot: ON", UDim2.new(0, 10, 0, 60))

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    if not espEnabled then
        for _, box in pairs(ScreenGui:FindFirstChild("ESP_Boxes"):GetChildren()) do
            box:Destroy()
        end
    end
end)

aimBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimBtn.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)

-- FOV Circle (visible)
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
    if not espEnabled then return end
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

-- Smooth aimbot aiming
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

local aimSpeed = 0.3 -- higher is faster, 1 is instant

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local currentCFrame = Camera.CFrame
            local goalCFrame = CFrame.new(currentCFrame.Position, target.Character.Head.Position)
            -- Smoothly move camera toward target
            Camera.CFrame = currentCFrame:Lerp(goalCFrame, aimSpeed)
        end
    end
end)

print("Hacker-style GUI loaded with toggles and smooth aimbot.")
