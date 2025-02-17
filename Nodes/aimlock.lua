local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Get MainCamera module
local MainCamera = nil
for _, module in pairs(getgc(true)) do
    if type(module) == "table" and rawget(module, "SetMenuEnabled") and rawget(module, "GetUpVector") then
        MainCamera = module
        break
    end
end

-- Notification System
local Notifications = {
    Active = {},
    MaxNotifications = 5,
    Duration = 3
}

function Notifications:Create(text, duration)
    duration = duration or self.Duration
    
    local notification = Drawing.new("Text")
    notification.Text = text
    notification.Size = 18
    notification.Center = false
    notification.Outline = true
    notification.Color = Color3.new(1, 1, 1)
    notification.Font = 2
    notification.Visible = true
    
    -- Position notification
    local yOffset = 30
    for _, active in pairs(self.Active) do
        yOffset = yOffset + 25
    end
    notification.Position = Vector2.new(10, yOffset)
    
    -- Add to active notifications
    table.insert(self.Active, {
        Drawing = notification,
        EndTime = tick() + duration
    })
    
    -- Remove old notifications if exceeding max
    while #self.Active > self.MaxNotifications do
        local oldest = table.remove(self.Active, 1)
        oldest.Drawing:Remove()
    end
    
    -- Schedule removal
    task.delay(duration, function()
        for i, active in pairs(self.Active) do
            if active.Drawing == notification then
                table.remove(self.Active, i)
                notification:Remove()
                break
            end
        end
    end)
end

-- Update notification positions
RunService.RenderStepped:Connect(function()
    local yOffset = 30
    for _, notification in pairs(Notifications.Active) do
        notification.Drawing.Position = Vector2.new(10, yOffset)
        yOffset = yOffset + 25
    end
end)

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Aimlock Configuration
local Settings = {
    Enabled = false,
    Key = Enum.KeyCode.Q,
    Prediction = 0.135,
    AimPart = "Head",
    Smoothness = 0.5,
    TeamCheck = true,
    Sensitivity = 0.5
}

local FOVSettings = {
    Visible = true,
    Radius = 120
}

-- Variables
local Target = nil

-- FOV Circle Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = FOVSettings.Visible
FOVCircle.Radius = FOVSettings.Radius
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- Function to check if player is on different team
local function IsEnemy(player)
    if not Settings.TeamCheck then return true end
    
    local playerTeam = player.Team
    local localTeam = LocalPlayer.Team
    
    if not playerTeam or not localTeam then return true end
    return playerTeam ~= localTeam
end

-- Function to get character from player in PF
local function GetCharacter(player)
    -- First try normal character
    local character = player.Character
    if not character then
        -- Try finding in workspace
        for _, model in pairs(workspace:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("Head") and model:FindFirstChild("Torso") then
                local humanoid = model:FindFirstChild("Humanoid")
                if humanoid and humanoid:FindFirstChild("Player") and humanoid.Player.Value == player then
                    return model
                end
            end
        end
        return nil
    end
    return character
end

-- Function to get nearest player
local function GetNearestPlayer()
    local MaxDistance = FOVSettings.Radius
    local Target = nil
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) then
            local char = GetCharacter(player)
            if char then
                local head = char:FindFirstChild(Settings.AimPart)
                local humanoid = char:FindFirstChild("Humanoid")
                
                if head and humanoid and humanoid.Health > 0 then
                    local screenPoint, onScreen = Camera:WorldToScreenPoint(head.Position)
                    
                    if onScreen then
                        local vectorDistance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                        
                        if vectorDistance < MaxDistance then
                            MaxDistance = vectorDistance
                            Target = player
                        end
                    end
                end
            end
        end
    end
    
    return Target
end

-- Update FOV Circle
RunService.RenderStepped:Connect(function()
    if Settings.Enabled then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    end
end)

-- Camera angle manipulation using MainCamera
local function AdjustCameraAngles(targetPos)
    if not MainCamera then 
        Notifications:Create("MainCamera module not found!", 3)
        return 
    end
    
    local currentAngle = MainCamera.angles
    local cameraPos = Camera.CFrame.Position
    
    -- Calculate target angles
    local targetCFrame = CFrame.new(cameraPos, targetPos)
    local targetX, targetY = targetCFrame:ToOrientation()
    
    -- Smooth interpolation
    local newX = currentAngle.x + (targetX - currentAngle.x) * Settings.Smoothness
    local newY = currentAngle.y + (targetY - currentAngle.y) * Settings.Smoothness
    
    -- Update camera angles
    MainCamera.angles = Vector3.new(newX, newY, 0)
end

-- Aimlock Logic
UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == Settings.Key then
        Settings.Enabled = not Settings.Enabled
        FOVCircle.Visible = Settings.Enabled
        
        if Settings.Enabled then
            Notifications:Create("Aimlock Enabled", 2)
            Target = GetNearestPlayer()
            if Target then
                Notifications:Create("Target Acquired: " .. Target.Name, 2)
            else
                Notifications:Create("No target found", 2)
            end
        else
            Notifications:Create("Aimlock Disabled", 2)
            Target = nil
        end
    end
end)

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    if Settings.Enabled and Target then
        local char = GetCharacter(Target)
        if char and char:FindFirstChild(Settings.AimPart) then
            local targetPart = char[Settings.AimPart]
            local targetPos = targetPart.Position
            local targetVel = targetPart.Velocity
            
            -- Prediction
            local predictionOffset = targetVel * Settings.Prediction
            local finalPos = targetPos + predictionOffset
            
            -- Adjust camera angles
            AdjustCameraAngles(finalPos)
        else
            Target = GetNearestPlayer()
        end
    end
end)

return {
    ToggleAimlock = function()
        Settings.Enabled = not Settings.Enabled
        FOVCircle.Visible = Settings.Enabled
    end,
    UpdateSettings = function(newSettings)
        for key, value in pairs(newSettings) do
            Settings[key] = value
            Notifications:Create("Updated " .. key .. " to " .. tostring(value), 2)
        end
    end,
    Settings = Settings,
    FOVSettings = FOVSettings
}