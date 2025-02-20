local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- UI Settings
local settings = {
    mainColor = Color3.fromRGB(30, 30, 30),
    accentColor = Color3.fromRGB(0, 170, 255),
    textColor = Color3.fromRGB(255, 255, 255),
    fontSize = Enum.FontSize.Size14,
    font = Enum.Font.Gotham
}

function Library:CreateWindow(title)
    -- Create main window container
    local window = Instance.new("ScreenGui")
    local mainFrame = Instance.new("Frame")
    local titleBar = Instance.new("Frame")
    local titleText = Instance.new("TextLabel")
    local contentFrame = Instance.new("Frame")
    local elementList = Instance.new("UIListLayout")
    
    window.Name = "UILibrary"
    window.Parent = game.CoreGui
    
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = window
    mainFrame.BackgroundColor3 = settings.mainColor
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
    mainFrame.ClipsDescendants = true
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = mainFrame
    
    -- Title bar
    titleBar.Name = "TitleBar"
    titleBar.Parent = mainFrame
    titleBar.BackgroundColor3 = settings.accentColor
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    
    titleText.Name = "Title"
    titleText.Parent = titleBar
    titleText.BackgroundTransparency = 1
    titleText.Size = UDim2.new(1, 0, 1, 0)
    titleText.Font = settings.font
    titleText.Text = title
    titleText.TextColor3 = settings.textColor
    titleText.TextSize = 16
    
    -- Content frame
    contentFrame.Name = "Content"
    contentFrame.Parent = mainFrame
    contentFrame.BackgroundTransparency = 1
    contentFrame.Position = UDim2.new(0, 0, 0, 35)
    contentFrame.Size = UDim2.new(1, 0, 1, -35)
    
    elementList.Parent = contentFrame
    elementList.SortOrder = Enum.SortOrder.LayoutOrder
    elementList.Padding = UDim.new(0, 5)
    
    -- Make window draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Window methods
    local window_methods = {}
    
    function window_methods:CreateButton(text, callback)
        local button = Instance.new("TextButton")
        button.Name = "Button"
        button.Parent = contentFrame
        button.BackgroundColor3 = settings.accentColor
        button.Size = UDim2.new(0.9, 0, 0, 30)
        button.Position = UDim2.new(0.05, 0, 0, 0)
        button.Font = settings.font
        button.Text = text
        button.TextColor3 = settings.textColor
        button.TextSize = 14
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            if callback then
                callback()
            end
        end)
        
        return button
    end
    
    return window_methods
end

return Library
