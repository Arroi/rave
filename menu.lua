    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Arroi/rave/refs/heads/main/Library.lua"))()

    -- Create main window
    local window = Library:CreateWindow("Dashboard")
    
    -- Create tabs
    local mainTab = window:AddTab("Main", "rbxassetid://ICON_ID")
    local settingsTab = window:AddTab("Settings", "rbxassetid://ICON_ID")
    
    -- Add panels to main tab
    local statsPanel = mainTab:AddPanel("Statistics")
    local configPanel = mainTab:AddPanel("Configuration")
    
    -- Add panels to settings tab
    local userPanel = settingsTab:AddPanel("User Settings")
    local themePanel = settingsTab:AddPanel("Theme")