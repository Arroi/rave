-- Aimlock System
-- Author: Cascade
-- Version: 1.2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configuration
local AimlockConfig = {
    Enabled = false,
    ToggleKey = Enum.KeyCode.X,
    MaxDistance = 1000,
    Smoothness = 0.5,
    FieldOfView = 90,
    TargetPart = "HumanoidRootPart",
    AssistStrength = 0.7,
    VisibilityCheck = true,
    TeamCheck = true
}

-- State
local CurrentTarget = nil
local IsAiming = false

-- Utility Functions
local function IsTeamMate(player)
    if not AimlockConfig.TeamCheck then return false end
    return player.Team and player.Team == LocalPlayer.Team
end

local function GetClosestPlayer()
    -- If we already have a target and they're still valid, keep targeting them
    if CurrentTarget and 
       CurrentTarget.Character and 
       CurrentTarget.Character:FindFirstChild("Humanoid") and 
       CurrentTarget.Character.Humanoid.Health > 0 and
       not IsTeamMate(CurrentTarget) then
        return CurrentTarget
    end

    local closestPlayer = nil
    local shortestDistance = AimlockConfig.MaxDistance
    local position = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(AimlockConfig.TargetPart)
    
    if not position then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and 
           player.Character and 
           player.Character:FindFirstChild(AimlockConfig.TargetPart) and
           player.Character:FindFirstChild("Humanoid") and
           player.Character.Humanoid.Health > 0 and
           not IsTeamMate(player) then
            
            local targetPos = player.Character[AimlockConfig.TargetPart].Position
            local distance = (targetPos - position.Position).Magnitude
            
            -- Check if player is within our field of view
            local _, onScreen = Camera:WorldToScreenPoint(targetPos)
            if not onScreen then continue end
            
            -- Visibility check
            if AimlockConfig.VisibilityCheck then
                local ray = Ray.new(Camera.CFrame.Position, (targetPos - Camera.CFrame.Position).Unit * distance)
                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, player.Character})
                if hit then continue end
            end
            
            if distance < shortestDistance then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end
    
    -- Update our current target
    CurrentTarget = closestPlayer
    return closestPlayer
end

-- Aim Assistance Logic
local function AimAt(targetPos)
    local currentCam = Camera.CFrame
    local lookAt = CFrame.lookAt(currentCam.Position, targetPos)
    
    -- Calculate the difference in angles
    local angle = math.acos(currentCam.LookVector:Dot(lookAt.LookVector))
    
    -- Only assist if the target is within our FOV
    if math.deg(angle) <= AimlockConfig.FieldOfView then
        -- Apply the aim assistance based on AssistStrength and Smoothness
        local targetCFrame = currentCam:Lerp(lookAt, AimlockConfig.AssistStrength * (1 - AimlockConfig.Smoothness))
        
        -- Update camera CFrame
        Camera.CFrame = targetCFrame
    end
end

-- Main Loop
local function StartAimlock()
    -- Input handling for key press
    local inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and AimlockConfig.Enabled then
            if input.KeyCode == AimlockConfig.ToggleKey then
                IsAiming = true
                -- Get initial target
                CurrentTarget = GetClosestPlayer()
            end
        end
    end)

    -- Input handling for key release
    local inputEndConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == AimlockConfig.ToggleKey then
            IsAiming = false
            CurrentTarget = nil
        end
    end)

    -- Aiming loop
    local renderConnection = RunService.RenderStepped:Connect(function()
        if AimlockConfig.Enabled and IsAiming and LocalPlayer.Character then
            local target = GetClosestPlayer()
            if target and target.Character then
                local targetPos = target.Character[AimlockConfig.TargetPart].Position
                AimAt(targetPos)
            end
        end
    end)
    
    -- Cleanup function
    return function()
        inputConnection:Disconnect()
        inputEndConnection:Disconnect()
        renderConnection:Disconnect()
        IsAiming = false
        CurrentTarget = nil
    end
end

-- Initialize
local AimlockModule = {
    Config = AimlockConfig,
    Start = StartAimlock
}

return AimlockModule