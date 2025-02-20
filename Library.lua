-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Library table
local Library = {
    Windows = {},
    Theme = {
        Background = Color3.fromRGB(25, 25, 25),
        Accent = Color3.fromRGB(0, 90, 156),
        LightContrast = Color3.fromRGB(35, 35, 35),
        DarkContrast = Color3.fromRGB(20, 20, 20),
        TextColor = Color3.fromRGB(255, 255, 255),
        Disabled = Color3.fromRGB(60, 60, 60)
    }
}

-- Utility Functions
local function createTween(instance, properties)
    local tween = TweenService:Create(instance, TWEEN_INFO, properties)
    tween:Play()
    return tween
end

local function createObject(className, properties)
    local object = Instance.new(className)
    for property, value in pairs(properties) do
        object[property] = value
    end
    return object
end

-- Main Window Creator
function Library:CreateWindow(title)
    -- Create ScreenGui
    local ScreenGui = createObject("ScreenGui", {
        Name = "UILibrary",
        Parent = CoreGui,
        ResetOnSpawn = false
    })

    -- Create Main Frame
    local MainFrame = createObject("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = Library.Theme.Background,
        Parent = ScreenGui
    })

    -- Add Corner Radius
    local Corner = createObject("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = MainFrame
    })

    -- Create Title Bar
    local TitleBar = createObject("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Library.Theme.DarkContrast,
        Parent = MainFrame
    })

    -- Add Title Text
    local TitleText = createObject("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Library.Theme.TextColor,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })

    -- Create Tab Container
    local TabContainer = createObject("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 150, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Library.Theme.LightContrast,
        Parent = MainFrame
    })

    -- Create Tab Content Area
    local TabContent = createObject("Frame", {
        Name = "TabContent",
        Size = UDim2.new(1, -150, 1, -30),
        Position = UDim2.new(0, 150, 0, 30),
        BackgroundColor3 = Library.Theme.Background,
        Parent = MainFrame
    })

    -- Window Dragging Logic
    local dragging, dragInput, dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == dragInput then
            dragging = false
        end
    end)

    -- Window Methods
    local Window = {}

    function Window:CreateTab(name)
        local Tab = {}
        
        -- Create Tab Button
        local TabButton = createObject("TextButton", {
            Name = name .. "Tab",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Library.Theme.LightContrast,
            Text = name,
            TextColor3 = Library.Theme.TextColor,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Parent = TabContainer
        })

        -- Create Tab Page
        local TabPage = createObject("ScrollingFrame", {
            Name = name .. "Page",
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            Visible = false,
            Parent = TabContent
        })

        -- Add UIListLayout to TabPage
        local UIListLayout = createObject("UIListLayout", {
            Padding = UDim.new(0, 5),
            Parent = TabPage
        })

        -- Tab Methods
        function Tab:AddButton(buttonText, callback)
            local Button = createObject("TextButton", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Library.Theme.LightContrast,
                Text = buttonText,
                TextColor3 = Library.Theme.TextColor,
                TextSize = 14,
                Font = Enum.Font.Gotham,
                Parent = TabPage
            })

            Button.MouseButton1Click:Connect(callback)
            return Button
        end

        function Tab:AddToggle(toggleText, default, callback)
            local Toggle = createObject("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Library.Theme.LightContrast,
                Parent = TabPage
            })

            -- Add implementation for toggle here
            -- This is a basic structure - expand as needed

            return Toggle
        end

        return Tab
    end

    return Window
end

return Library
