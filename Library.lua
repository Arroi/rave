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

    -- Add Corner
    createObject("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = MainFrame
    })

    -- Create Tab Container
    local TabContainer = createObject("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = Library.Theme.LightContrast,
        Parent = MainFrame
    })

    -- Add Corner to TabContainer
    createObject("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = TabContainer
    })

    -- Create Tab Content Area
    local TabContent = createObject("Frame", {
        Name = "TabContent",
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 150, 0, 0),
        BackgroundColor3 = Library.Theme.Background,
        Parent = MainFrame
    })

    -- Add TabList Layout
    local TabList = createObject("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabContainer
    })

    -- Add Padding
    createObject("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        Parent = TabContainer
    })

    -- Window Methods
    local Window = {}
    local Tabs = {}

    function Window:CreateTab(name)
        local Tab = {}
        
        -- Create Tab Button
        local TabButton = createObject("TextButton", {
            Name = name .. "Tab",
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Library.Theme.DarkContrast,
            Text = name,
            TextColor3 = Library.Theme.TextColor,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Parent = TabContainer
        })

        -- Add Corner to TabButton
        createObject("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = TabButton
        })

        -- Create Tab Page
        local TabPage = createObject("ScrollingFrame", {
            Name = name .. "Page",
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            Visible = false,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = TabContent
        })

        -- Add UIListLayout to TabPage
        createObject("UIListLayout", {
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabPage
        })

        -- Tab Selection Logic
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Tabs) do
                tab.Page.Visible = false
                createTween(tab.Button, {BackgroundColor3 = Library.Theme.DarkContrast})
            end
            TabPage.Visible = true
            createTween(TabButton, {BackgroundColor3 = Library.Theme.Accent})
        end)

        -- Show first tab by default
        if #Tabs == 0 then
            TabPage.Visible = true
            createTween(TabButton, {BackgroundColor3 = Library.Theme.Accent})
        end

        -- Tab Methods
        function Tab:AddButton(text, callback)
            local Button = createObject("TextButton", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = Library.Theme.DarkContrast,
                Text = text,
                TextColor3 = Library.Theme.TextColor,
                TextSize = 14,
                Font = Enum.Font.Gotham,
                Parent = TabPage
            })

            createObject("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = Button
            })

            Button.MouseButton1Click:Connect(callback)
            return Button
        end

        function Tab:AddToggle(text, default, callback)
            local ToggleFrame = createObject("Frame", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = Library.Theme.DarkContrast,
                Parent = TabPage
            })

            createObject("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = ToggleFrame
            })

            local ToggleButton = createObject("Frame", {
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -32, 0.5, -12),
                BackgroundColor3 = default and Library.Theme.Accent or Library.Theme.Disabled,
                Parent = ToggleFrame
            })

            createObject("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = ToggleButton
            })

            local Label = createObject("TextLabel", {
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Library.Theme.TextColor,
                TextSize = 14,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ToggleFrame
            })

            local Enabled = default or false

            ToggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Enabled = not Enabled
                    createTween(ToggleButton, {
                        BackgroundColor3 = Enabled and Library.Theme.Accent or Library.Theme.Disabled
                    })
                    callback(Enabled)
                end
            end)

            return ToggleFrame
        end

        table.insert(Tabs, {Button = TabButton, Page = TabPage})
        return Tab
    end

    -- Make window draggable
    local dragging, dragInput, dragStart, startPos
    
    MainFrame.InputBegan:Connect(function(input)
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

    return Window
end

return Library
