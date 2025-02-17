-- Aimlock System
-- Author: Cascade
-- Version: 2.0

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
    TeamCheck = false,
    RaycastDistance = 2000
}

-- State
local CurrentTarget = nil
local IsAiming = false
local IsToggled = false

-- Utility Functions
local function IsTeamMate(player)
    if not AimlockConfig.TeamCheck then return false end
    return player.Team and player.Team == LocalPlayer.Team
end

local function GetTargetFromRaycast()
    local mousePos = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * AimlockConfig.RaycastDistance, raycastParams)
    
    if raycastResult then
        local hitPart = raycastResult.Instance
        local model = hitPart:FindFirstAncestorWhichIsA("Model")
        
        if model then
            local player = Players:GetPlayerFromCharacter(model)
            if player and player ~= LocalPlayer and not IsTeamMate(player) then
                local humanoid = model:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    return player
                end
            end
        end
    end
    
    return nil
end

local function GetClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and 
           player.Character and 
           player.Character:FindFirstChild(AimlockConfig.TargetPart) and
           player.Character:FindFirstChild("Humanoid") and
           player.Character.Humanoid.Health > 0 and
           not IsTeamMate(player) then
            
            local targetPos = player.Character[AimlockConfig.TargetPart].Position
            local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
            
            if onScreen then
                local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                
                if distance < shortestDistance and distance <= AimlockConfig.FieldOfView then
                    -- Visibility check
                    if AimlockConfig.VisibilityCheck then
                        local ray = Ray.new(Camera.CFrame.Position, (targetPos - Camera.CFrame.Position).Unit * AimlockConfig.MaxDistance)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, player.Character})
                        if hit then continue end
                    end
                    
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    
    return closestPlayer
end

-- Aim Assistance Logic
local function AimAt(targetPos)
    if not AimlockConfig.Enabled or not IsToggled then return end
    
    local currentCam = Camera.CFrame
    local lookAt = CFrame.lookAt(currentCam.Position, targetPos)
    
    -- Calculate the difference in angles
    local angle = math.acos(currentCam.LookVector:Dot(lookAt.LookVector))
    
    -- Only assist if the target is within our FOV
    if math.deg(angle) <= AimlockConfig.FieldOfView then
        -- Apply the aim assistance based on AssistStrength and Smoothness
        local targetCFrame = currentCam:Lerp(lookAt, AimlockConfig.AssistStrength * (1 - AimlockConfig.Smoothness))
        Camera.CFrame = targetCFrame
    end
end

-- Main Loop
local function StartAimlock()
    local function UpdateAiming()
        if AimlockConfig.Enabled and IsToggled then
            if not CurrentTarget or not CurrentTarget.Character then
                -- Try to acquire new target
                CurrentTarget = GetTargetFromRaycast() or GetClosestPlayerToMouse()
            elseif CurrentTarget.Character then
                local targetPart = CurrentTarget.Character:FindFirstChild(AimlockConfig.TargetPart)
                if targetPart and CurrentTarget.Character:FindFirstChild("Humanoid") and 
                   CurrentTarget.Character.Humanoid.Health > 0 then
                    AimAt(targetPart.Position)
                else
                    CurrentTarget = nil
                end
            end
        end
    end

    -- Input handling
    local function OnInput(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == AimlockConfig.ToggleKey and 
           input.UserInputType == Enum.UserInputType.Keyboard and
           input.UserInputState == Enum.UserInputState.Begin then
            IsToggled = not IsToggled
            
            if IsToggled then
                -- Attempt to acquire target when toggling on
                CurrentTarget = GetTargetFromRaycast() or GetClosestPlayerToMouse()
            else
                -- Clear target when toggling off
                CurrentTarget = nil
            end
            
            -- Notify the player
            if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Aimlock",
                    Text = IsToggled and "Locked" or "Unlocked",
                    Duration = 1
                })
            end
        end
    end

    -- Connect events
    local inputConnection = UserInputService.InputBegan:Connect(OnInput)
    local renderConnection = RunService.RenderStepped:Connect(UpdateAiming)
    
    -- Return cleanup function
    return function()
        inputConnection:Disconnect()
        renderConnection:Disconnect()
        IsToggled = false
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