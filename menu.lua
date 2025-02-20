    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Arroi/rave/refs/heads/main/Library.lua"))()

    local window = Library:CreateWindow("My UI")

    -- Create tabs
    local mainTab = window:AddTab("Main")
    local settingsTab = window:AddTab("Settings")
    
    -- Add elements
    mainTab:AddButton("Click Me", function()
        print("Button clicked!")
    end)
    
    mainTab:AddSlider("Volume", 0, 100, 50, function(value)
        print("Volume:", value)
    end)
    
    mainTab:AddDropdown("Select Option", {"Option 1", "Option 2", "Option 3"}, function(selected)
        print("Selected:", selected)
    end)
    
    -- Create a loader
    local loader = Library:CreateLoader()
    task.wait(2)
    loader:Destroy()