local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Arroi/rave/refs/heads/main/Library.lua"))()

-- Verify Library loaded correctly
assert(Library, "Failed to load Library")
assert(Library.NavigationType, "Failed to load NavigationType")

-- Create main window with sidebar navigation (you can change to other styles)
local Window = Library:CreateWindow("Rave Hub", Library.NavigationType.Sidebar)

-- Create tabs with icons (you can replace icon IDs with your own)
local MainTab = Window:CreateTab("Main", "rbxassetid://8875632589") -- Home icon
local VisualsTab = Window:CreateTab("Visuals", "rbxassetid://8875650667") -- Eye icon
local SettingsTab = Window:CreateTab("Settings", "rbxassetid://8875633547") -- Gear icon

-- Main Tab Elements
MainTab:AddButton("Kill All", function()
    print("Kill All activated")
end)

MainTab:AddToggle("Auto Farm", false, function(enabled)
    print("Auto Farm:", enabled)
end)

MainTab:AddToggle("God Mode", false, function(enabled)
    print("God Mode:", enabled)
end)

-- Visuals Tab Elements
VisualsTab:AddToggle("ESP", false, function(enabled)
    print("ESP:", enabled)
end)

VisualsTab:AddToggle("Tracers", false, function(enabled)
    print("Tracers:", enabled)
end)

VisualsTab:AddButton("Reset Visuals", function()
    print("Visuals Reset")
end)

-- Settings Tab Elements
SettingsTab:AddButton("Destroy UI", function()
    for _, instance in pairs(game:GetService("CoreGui"):GetChildren()) do
        if instance.Name == "UILibrary" then
            instance:Destroy()
        end
    end
end)

SettingsTab:AddToggle("Auto Save", true, function(enabled)
    print("Auto Save:", enabled)
end)

-- Example of using different navigation styles:

--[[ Bottom Navigation
local Window = Library:CreateWindow("Rave Hub", Library.NavigationType.Bottom)
]]

--[[ Top Navigation
local Window = Library:CreateWindow("Rave Hub", Library.NavigationType.Top)
]]

--[[ Bento Menu
local Window = Library:CreateWindow("Rave Hub", Library.NavigationType.Bento)
]]