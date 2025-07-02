local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configuration
local FOV_RADIUS_DEGREES = 210 -- As per request
-- Convert 210 degrees to a 2D radius in pixels on screen based on the camera’s FOV and screen size
-- We'll draw a circle with a radius in pixels on the screen, approximate 210° in view angle:
-- Full circle 360°, 210° is about 58% of a circle, but for circle on screen, let's consider pixels:
-- We can pick a pixel radius that covers roughly this angular range on screen.
-- Let's just pick 200 pixels for radius which is visually large

local FOV_RADIUS_PIXELS = 200

local enabled = false

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FOVToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 100, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Text = "FOV: OFF"
toggleButton.Parent = screenGui

toggleButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggleButton.Text = enabled and "FOV: ON" or "FOV: OFF"
end)

-- Draw FOV circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Color = Color3.new(1, 1, 1)
fovCircle.Transparency = 0.5
fovCircle.Thickness = 2

-- Crosshair parts (assumes crosshair is centered, let's create a custom one)
local crosshair = Drawing.new("Circle")
crosshair.Color = Color3.new(1, 0, 0)
crosshair.Thickness = 2
crosshair.NumSides = 6
crosshair.Radius = 5
crosshair.Visible = false

-- Helper functions
local function isWallBetween(pos1, pos2)
    local ray = Ray.new(pos1, (pos2 - pos1))
    local hit, hitPos = Workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
    if hit then
        -- hit something between pos1 and pos2, check distance
        local distToHit = (hitPos - pos1).Magnitude
        local distToTarget = (pos2 - pos1).Magnitude
        return distToHit < distToTarget
    end
    return false
end

local function isTeammate(player)
    -- Basic team check, assumes teams service or player.Team property
    return player.Team == LocalPlayer.Team
end

local function isAlive(player)
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        return character.Humanoid.Health > 0
    end
    return false
end

local function getScreenPosition(worldPos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
    if onScreen then
        return Vector2.new(screenPos.X, screenPos.Y), true
    else
        return Vector2.new(screenPos.X, screenPos.Y), false
    end
end

-- Track enemies in FOV
RunService.RenderStepped:Connect(function()
    if not enabled then
        fovCircle.Visible = false
        crosshair.Visible = false
        return
    end

    -- Update FOV circle position (centered on screen)
    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

    fovCircle.Position = center
    fovCircle.Radius = FOV_RADIUS_PIXELS
    fovCircle.Visible = true

    -- We find closest eligible enemy inside FOV
    local targetPos = nil
    local closestDist = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isTeammate(player) and isAlive(player) then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local enemyPos3D = character.HumanoidRootPart.Position
                local screenPos, onScreen = getScreenPosition(enemyPos3D)
                
                if onScreen then
                    local screenVector = screenPos - center
                    local distance = screenVector.Magnitude
                    
                    if distance <= FOV_RADIUS_PIXELS then
                        -- Check if visible (not behind wall)
                        if not isWallBetween(Camera.CFrame.Position, enemyPos3D) then
                            if distance < closestDist then
                                closestDist = distance
                                targetPos = screenPos
                            end
                        end
                    end
                end
            end
        end
    end

    if targetPos then
        crosshair.Position = targetPos
        crosshair.Visible = true
    else
        crosshair.Position = center
        crosshair.Visible = false
    end
end)
