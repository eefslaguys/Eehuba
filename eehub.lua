-- Hacker-Style GUI by EA v2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
local FOV = 210
local espEnabled = true
local aimbotEnabled = true

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EA_HackerGUI"
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 230, 0, 140)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "EA Hacker GUI"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

-- Toggle Buttons
local function createToggle(name, posY, initial)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0, 210, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = initial and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Text = (initial and "ON" or "OFF").." "..name

    btn.MouseButton1Click:Connect(function()
        if btn.BackgroundColor3 == Color3.fromRGB(0, 200, 0) then
            btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            btn.Text = "OFF "..name
            if name == "ESP" then espEnabled = false end
            if name == "Aimbot" then aimbotEnabled = false end
        else
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            btn.Text = "ON "..name
            if name == "ESP" then espEnabled = true end
            if name == "Aimbot" then aimbotEnabled = true end
        end
    end)
    return btn
end

local ESPToggle = createToggle("ESP", 40, espEnabled)
local AimToggle = createToggle("Aimbot", 85, aimbotEnabled)

-- ESP Folder
local ESPFolder = Instance.new("Folder", ScreenGui)
ESPFolder.Name = "ESP_Boxes"

local function createESP(player)
    if player == LocalPlayer then return end
    if ESPFolder:FindFirstChild(player.Name) then return end

    local box = Instance.new("BillboardGui", ESPFolder)
    box.Name = player.Name
    box.Adornee = player.Character and player.Character:FindFirstChild("Head")
    box.Size = UDim2.new(4, 0, 5, 0)
    box.AlwaysOnTop = true

    local frame = Instance.new("Frame", box)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    frame.BackgroundTransparency = 0.3
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
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
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

-- FOV Circle using Drawing API
local circle = Drawing.new("Circle")
circle.Radius = FOV
circle.Color = Color3.fromRGB(255, 255, 255)
circle.Thickness = 2
circle.Filled = false
circle.Transparency = 0.6

RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)

-- Aimbot
local function getClosestTarget()
    local closest = nil
    local shortestDistance = FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 and player.Team ~= LocalPlayer.Team then
                local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
                if onScreen then
                    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    local targetPos2D = Vector2.new(headPos.X, headPos.Y)
                    local dist = (targetPos2D - screenCenter).magnitude

                    local partsObscuring = Camera:GetPartsObscuringTarget({player.Character.Head.Position}, {LocalPlayer.Character})
                    local obstructed = (#partsObscuring > 0)

                    if dist <= shortestDistance and not obstructed then
                        closest = player
                        shortestDistance = dist
                    end
                end
            end
        end
    end

    return closest
end

RunService.RenderStepped:Connect(function()
    updateESP()

    if aimbotEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

print("EA Hacker GUI v2 loaded!")
