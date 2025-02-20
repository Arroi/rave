local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Arroi/rave/refs/heads/main/Library.lua"))()

-- Create main window
local Window = Library:CreateWindow("Rave Hub")

-- Create tabs
local MainTab = Window:CreateTab("Main")
local VisualsTab = Window:CreateTab("Visuals")
local SettingsTab = Window:CreateTab("Settings")

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