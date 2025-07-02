local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configuration
local FOV_RADIUS_DEGREES = 210
local FOV_RADIUS_PIXELS = 200

local enabled = false

-- Your weapon tool - change this to match your game's gun tool name or attacking method
local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")

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
local Drawing = Drawing
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Color = Color3.new(1, 1, 1)
fovCircle.Transparency = 0.5
fovCircle.Thickness = 2

-- Smooth aim parameters
local AIM_SMOOTHNESS = 0.2 -- Smaller is faster

local function isWallBetween(pos1, pos2)
    local ray = Ray.new(pos1, (pos2 - pos1))
    local hit, hitPos = Workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
    if hit then
        local distToHit = (hitPos - pos1).Magnitude
        local distToTarget = (pos2 - pos1).Magnitude
        return distToHit < distToTarget
    end
    return false
end

local function isTeammate(player)
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

local function getClosestTarget()
    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

    local closestTarget = nil
    local closestDistance = math.huge
    local closestWorldPos = nil

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isTeammate(player) and isAlive(player) then
            local character = player.Character
            if character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local worldPos = hrp.Position
                    local screenPos, onScreen = getScreenPosition(worldPos)
                    local delta = (screenPos - center).Magnitude
                    if delta <= FOV_RADIUS_PIXELS then
                        if not isWallBetween(Camera.CFrame.Position, worldPos) then
                            if delta < closestDistance then
                                closestDistance = delta
                                closestTarget = player
                                closestWorldPos = worldPos
                            end
                        end
                    end
                end
            end
        end
    end

    return closestTarget, closestWorldPos
end

RunService.RenderStepped:Connect(function(dt)
    if not enabled then
        fovCircle.Visible = false
        return
    end

    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

    -- Update FOV Circle visual
    fovCircle.Position = center
    fovCircle.Radius = FOV_RADIUS_PIXELS
    fovCircle.Visible = true

    local target, pos = getClosestTarget()
    if target and pos then
        -- Smoothly rotate camera toward the target
        local direction = (pos - Camera.CFrame.Position).Unit
        local currentCFrame = Camera.CFrame
        local targetCFrame = CFrame.new(Camera.CFrame.Position, pos)

        -- Smooth Lerp between current and target look vector
        Camera.CFrame = currentCFrame:Lerp(targetCFrame, AIM_SMOOTHNESS)

        -- Fire weapon if possible and equipped
        if tool and tool.Parent == LocalPlayer.Character and tool:FindFirstChild("Handle") then
            -- Trigger the tool activation if not already activated
            if tool:FindFirstChildOfClass("ClickDetector") then
                tool.ClickDetector:FireServer() -- Example, depends on weapon
            elseif tool:FindFirstChild("Fire") then  
                -- Call Fire RemoteEvent or function: adjust accordingly
                tool.Fire:FireServer()
            else
                -- Basic tool activation
                tool:Activate()
            end
        end
    end
end)
