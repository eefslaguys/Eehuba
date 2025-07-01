local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local FOV_RADIUS = 210
local AIMBOT_ENABLED = true
local AIM_SMOOTHNESS = 0.25

-- Create ScreenGui for FOV circle
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Movable Frame (empty for toggles later)
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Movable GUI drag logic here (omitted for brevity but you can reuse previous)

-- Create FOV Circle as an ImageLabel with circular image
local FOVCircle = Instance.new("ImageLabel")
FOVCircle.Name = "FOVCircle"
FOVCircle.Size = UDim2.new(0, FOV_RADIUS*2, 0, FOV_RADIUS*2)
FOVCircle.Position = UDim2.new(0.5, -FOV_RADIUS, 0.5, -FOV_RADIUS)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Image = "rbxassetid://3926307971"  -- Roblox built-in circle image
FOVCircle.ImageColor3 = Color3.new(1,1,1)
FOVCircle.ImageTransparency = 0.4
FOVCircle.Parent = ScreenGui
FOVCircle.ZIndex = 10

-- ESP Setup (reuse your existing ESP code here, no changes)

-- Visibility check function (same as before)
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

-- Get closest valid target inside FOV
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

-- Smooth aimbot: rotate camera towards target head
RunService.RenderStepped:Connect(function(delta)
    if not AIMBOT_ENABLED then return end
    local target = getClosestTarget()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local currentCFrame = Camera.CFrame
        local targetPos = target.Character.Head.Position
        local direction = (targetPos - currentCFrame.Position).Unit
        local newLookVector = currentCFrame.LookVector:Lerp(direction, AIM_SMOOTHNESS)
        Camera.CFrame = CFrame.new(currentCFrame.Position, currentCFrame.Position + newLookVector)
    end
end)

print("Hacker GUI with FOV circle and smooth aimbot loaded.")
