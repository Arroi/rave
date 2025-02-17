local repo = 'https://raw.githubusercontent.com/Arroi/rave/refs/heads/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- Load Aimlock System directly from GitHub
local Aimlock = loadstring(game:HttpGet(repo .. 'Nodes/aimlock.lua'))()

local Window = Library:CreateWindow({
    Title = 'Rave Hub',
    Center = true,
    AutoShow = true,
})

-- Create Tabs
local Tabs = {
    Combat = Window:AddTab('Combat'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Combat Tab - Aimlock Section
local AimlockBox = Tabs.Combat:AddLeftGroupbox('Aimlock')

-- Add Aimlock toggle
AimlockBox:AddToggle('AimlockEnabled', {
    Text = 'Enable Aimlock',
    Default = false,
    Tooltip = 'Enable/Disable the aimlock system',
})

-- Add Aimlock key picker
AimlockBox:AddLabel('Aimlock Key'):AddKeyPicker('AimlockKey', {
    Default = 'X',
    SyncToggleState = false,
    Mode = 'Toggle',
    Text = 'Toggle Aimlock',
    NoUI = false,
})

-- Add Team Check toggle
AimlockBox:AddToggle('TeamCheck', {
    Text = 'Team Check',
    Default = true,
    Tooltip = 'Prevents targeting teammates',
})

-- Add Smoothness slider
AimlockBox:AddSlider('Smoothness', {
    Text = 'Smoothness',
    Default = 0.5,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Tooltip = 'Higher = smoother tracking',
})

-- Add FOV slider
AimlockBox:AddSlider('FOV', {
    Text = 'Field of View',
    Default = 90,
    Min = 30,
    Max = 180,
    Rounding = 0,
    Compact = false,
    Tooltip = 'Targeting field of view in degrees',
})

-- Add Assist Strength slider
AimlockBox:AddSlider('AssistStrength', {
    Text = 'Assist Strength',
    Default = 0.7,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Tooltip = 'How strong the aim assistance is',
})

-- Setup callbacks
local function setEnabled(Value)
    Aimlock.Config.Enabled = Value
    -- Notify the player
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Aimlock",
            Text = Value and "Enabled" or "Disabled",
            Duration = 2
        })
    end
end

Toggles.AimlockEnabled:OnChanged(setEnabled)

Options.AimlockKey:OnChanged(function()
    if Options.AimlockKey.Value then
        local keyEnum = Enum.KeyCode[Options.AimlockKey.Value]
        if keyEnum then
            Aimlock.Config.ToggleKey = keyEnum
        end
    end
end)

Toggles.TeamCheck:OnChanged(function(Value)
    Aimlock.Config.TeamCheck = Value
end)

Options.Smoothness:OnChanged(function(Value)
    Aimlock.Config.Smoothness = Value
end)

Options.FOV:OnChanged(function(Value)
    Aimlock.Config.FieldOfView = Value
end)

Options.AssistStrength:OnChanged(function(Value)
    Aimlock.Config.AssistStrength = Value
end)

-- Start the aimlock system
Aimlock.Start()

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

-- I'm assuming you might have some theme stuff here
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings() 

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 

ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')

SaveManager:BuildConfigSection(Tabs['UI Settings']) 

ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- Return necessary objects
return Window, Tabs
