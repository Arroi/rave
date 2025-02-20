    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Arroi/rave/refs/heads/main/Library.lua"))()

    -- Create main window
    local Window = Library:CreateWindow("Example")

    -- Create tabs
    local MainTab = Window:Tab("Main")
    local SettingsTab = Window:Tab("Settings")
    
    -- Create sections
    local MainSection = MainTab:Section("Example Section")
    
    -- Create toggles
    MainSection:Toggle("Example Toggle", false, "ExampleFlag", function(value)
        print("Toggle value:", value)
    end)