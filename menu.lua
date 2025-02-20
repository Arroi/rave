    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Arroi/rave/refs/heads/main/Library.lua"))()

    local Window = Library:CreateWindow("My Window")
    local Tab = Window:CreateTab("General")
    
    Tab:AddButton("Click Me", function()
        print("Button clicked!")
    end)
    
    Tab:AddToggle("Toggle Me", false, function(enabled)
        print("Toggle state:", enabled)
    end)