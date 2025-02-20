-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Library table
local Library = {
    Windows = {},
    NavigationType = {
        Sidebar = "sidebar",
        Bottom = "bottom",
        Top = "top",
        Bento = "bento"
    },
    Theme = {
        Background = Color3.fromRGB(255, 255, 255),  -- White background
        Accent = Color3.fromRGB(89, 91, 255),       -- Modern purple/blue
        LightContrast = Color3.fromRGB(247, 248, 250), -- Light gray for contrast
        DarkContrast = Color3.fromRGB(233, 234, 236),  -- Slightly darker gray
        TextColor = Color3.fromRGB(49, 51, 56),      -- Dark text
        SubTextColor = Color3.fromRGB(99, 100, 102), -- Secondary text
        BorderColor = Color3.fromRGB(233, 234, 236), -- Border color
        PlaceholderColor = Color3.fromRGB(140, 140, 140)
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
function Library:CreateWindow(title, navType)
    navType = navType or Library.NavigationType.Sidebar
    
    -- Create base window elements
    local ScreenGui = createObject("ScreenGui", {
        Name = "UILibrary",
        Parent = CoreGui,
        ResetOnSpawn = false
    })

    local MainFrame = createObject("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 900, 0, 600),
        Position = UDim2.new(0.5, -450, 0.5, -300),
        BackgroundColor3 = Library.Theme.Background,
        Parent = ScreenGui
    })

    -- Add shadow and corner radius
    createObject("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = MainFrame
    })

    local Shadow = createObject("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 47, 1, 47),
        ZIndex = 0,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        Parent = MainFrame
    })

    -- Create navigation based on type
    local Navigation, ContentFrame
    
    if navType == Library.NavigationType.Bottom then
        -- Bottom Navigation
        Navigation = createObject("Frame", {
            Name = "BottomNav",
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(0, 0, 1, -60),
            BackgroundColor3 = Library.Theme.Background,
            Parent = MainFrame
        })

        -- Add bottom nav shadow
        createObject("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Library.Theme.BorderColor,
            Parent = Navigation
        })

        ContentFrame = createObject("Frame", {
            Size = UDim2.new(1, 0, 1, -60),
            BackgroundTransparency = 1,
            Parent = MainFrame
        })

    elseif navType == Library.NavigationType.Top then
        -- Top Navigation
        Navigation = createObject("Frame", {
            Name = "TopNav",
            Size = UDim2.new(1, 0, 0, 60),
            BackgroundColor3 = Library.Theme.Background,
            Parent = MainFrame
        })

        -- Add top nav shadow
        createObject("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Library.Theme.BorderColor,
            Parent = Navigation
        })

        ContentFrame = createObject("Frame", {
            Size = UDim2.new(1, 0, 1, -60),
            Position = UDim2.new(0, 0, 0, 60),
            BackgroundTransparency = 1,
            Parent = MainFrame
        })

    elseif navType == Library.NavigationType.Bento then
        -- Bento Menu
        Navigation = createObject("Frame", {
            Name = "BentoMenu",
            Size = UDim2.new(0, 50, 1, 0),
            BackgroundColor3 = Library.Theme.LightContrast,
            Parent = MainFrame
        })

        -- Add bento button
        local BentoButton = createObject("TextButton", {
            Size = UDim2.new(0, 40, 0, 40),
            Position = UDim2.new(0, 5, 0, 5),
            BackgroundColor3 = Library.Theme.Background,
            Text = "",
            Parent = Navigation
        })

        createObject("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = BentoButton
        })

        ContentFrame = createObject("Frame", {
            Size = UDim2.new(1, -50, 1, 0),
            Position = UDim2.new(0, 50, 0, 0),
            BackgroundTransparency = 1,
            Parent = MainFrame
        })

    else -- Sidebar (default)
        Navigation = createObject("Frame", {
            Name = "Sidebar",
            Size = UDim2.new(0, 240, 1, 0),
            BackgroundColor3 = Library.Theme.LightContrast,
            Parent = MainFrame
        })

        ContentFrame = createObject("Frame", {
            Size = UDim2.new(1, -240, 1, 0),
            Position = UDim2.new(0, 240, 0, 0),
            BackgroundTransparency = 1,
            Parent = MainFrame
        })
    end

    -- Add animations
    local function createTabButtonAnimation(button)
        local hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.8
        })
        
        local leaveTween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        })
        
        button.MouseEnter:Connect(function()
            hoverTween:Play()
        end)
        
        button.MouseLeave:Connect(function()
            leaveTween:Play()
        end)
    end

    -- Create tab container based on navigation type
    local TabContainer = createObject("Frame", {
        Name = "TabContainer",
        BackgroundTransparency = 1,
        Parent = Navigation
    })

    if navType == Library.NavigationType.Bottom or navType == Library.NavigationType.Top then
        TabContainer.Size = UDim2.new(1, 0, 1, 0)
        
        -- Add horizontal layout
        createObject("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 10),
            Parent = TabContainer
        })
    else
        TabContainer.Size = UDim2.new(1, 0, 1, -60)
        TabContainer.Position = UDim2.new(0, 0, 0, 60)
    end

    -- Track tabs
    local Tabs = {}
    local SelectedTab = nil

    -- Window Dragging Logic
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

    -- Window Methods
    local Window = {}

    function Window:CreateTab(name, icon)
        local Tab = {}
        
        local TabButton = createObject("TextButton", {
            Name = name .. "Tab",
            Size = UDim2.new(1, -20, 0, 40),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundColor3 = Library.Theme.Background,
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Parent = TabContainer
        })

        -- Add icon
        local Icon = createObject("ImageLabel", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 10, 0.5, -10),
            BackgroundTransparency = 1,
            Image = icon or "", -- Use provided icon or leave empty
            ImageColor3 = Library.Theme.SubTextColor,
            Parent = TabButton
        })

        -- Add text label
        local TextLabel = createObject("TextLabel", {
            Size = UDim2.new(1, -50, 1, 0),
            Position = UDim2.new(0, 40, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Library.Theme.TextColor,
            TextSize = 14,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })

        -- Create Tab Page with better styling
        local TabPage = createObject("ScrollingFrame", {
            Name = name .. "Page",
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            Visible = false,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = TabContent
        })

        -- Add padding to tab page
        local ContentPadding = createObject("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            Parent = TabPage
        })

        -- Add UIListLayout to TabPage with better spacing
        local UIListLayout = createObject("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabPage
        })

        -- Improved Tab Selection Logic
        TabButton.MouseButton1Click:Connect(function()
            if SelectedTab == TabPage then return end
            
            -- Hide all tabs
            for _, tab in pairs(Tabs) do
                tab.Page.Visible = false
                createTween(tab.Button, {
                    BackgroundColor3 = Library.Theme.Background
                })
                createTween(tab.Button.Title, {
                    TextColor3 = Library.Theme.TextColor
                })
            end
            
            -- Show selected tab
            TabPage.Visible = true
            createTween(TabButton, {
                BackgroundColor3 = Library.Theme.Accent
            })
            createTween(TabButton.Title, {
                TextColor3 = Color3.fromRGB(255, 255, 255)
            })
            
            SelectedTab = TabPage
        end)

        -- Store tab information
        table.insert(Tabs, {
            Button = TabButton,
            Page = TabPage
        })

        -- Show first tab by default
        if #Tabs == 1 then
            TabPage.Visible = true
            createTween(TabButton, {
                BackgroundColor3 = Library.Theme.Accent
            })
            createTween(TabButton.Title, {
                TextColor3 = Color3.fromRGB(255, 255, 255)
            })
            SelectedTab = TabPage
        end

        -- Tab Methods
        function Tab:AddButton(buttonText, callback)
            local ButtonFrame = createObject("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Library.Theme.LightContrast,
                Parent = TabPage
            })

            -- Add corner to button
            createObject("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = ButtonFrame
            })

            local Button = createObject("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = buttonText,
                TextColor3 = Library.Theme.TextColor,
                TextSize = 14,
                Font = Enum.Font.Gotham,
                Parent = ButtonFrame
            })

            -- Button hover effect
            Button.MouseEnter:Connect(function()
                createTween(ButtonFrame, {BackgroundColor3 = Library.Theme.Accent})
            end)

            Button.MouseLeave:Connect(function()
                createTween(ButtonFrame, {BackgroundColor3 = Library.Theme.LightContrast})
            end)

            Button.MouseButton1Click:Connect(callback)
            return Button
        end

        function Tab:AddToggle(toggleText, default, callback)
            local ToggleFrame = createObject("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Library.Theme.LightContrast,
                Parent = TabPage
            })

            -- Add corner to toggle frame
            createObject("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = ToggleFrame
            })

            local ToggleLabel = createObject("TextLabel", {
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = toggleText,
                TextColor3 = Library.Theme.TextColor,
                TextSize = 14,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ToggleFrame
            })

            local ToggleButton = createObject("Frame", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0.5, -10),
                BackgroundColor3 = Library.Theme.Disabled,
                Parent = ToggleFrame
            })

            -- Add corner to toggle button
            createObject("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = ToggleButton
            })

            local Enabled = default or false
            
            local function UpdateToggle()
                createTween(ToggleButton, {
                    BackgroundColor3 = Enabled and Library.Theme.Accent or Library.Theme.Disabled
                })
                callback(Enabled)
            end

            -- Initialize toggle state
            UpdateToggle()

            -- Toggle interaction
            ToggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Enabled = not Enabled
                    UpdateToggle()
                end
            end)

            return ToggleFrame
        end

        return Tab
    end

    return {
        CreateTab = function(self, name, icon)
            -- Tab creation logic based on navigation type
            local Tab = {}
            
            local TabButton = createObject("TextButton", {
                Name = name .. "Tab",
                Size = UDim2.new(1, -20, 0, 40),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundColor3 = Library.Theme.Background,
                BackgroundTransparency = 1,
                AutoButtonColor = false,
                Parent = TabContainer
            })

            -- Add icon
            local Icon = createObject("ImageLabel", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 10, 0.5, -10),
                BackgroundTransparency = 1,
                Image = icon or "", -- Use provided icon or leave empty
                ImageColor3 = Library.Theme.SubTextColor,
                Parent = TabButton
            })

            -- Add text label
            local TextLabel = createObject("TextLabel", {
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 40, 0, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Library.Theme.TextColor,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TabButton
            })

            -- Create Tab Page with better styling
            local TabPage = createObject("ScrollingFrame", {
                Name = name .. "Page",
                Size = UDim2.new(1, -20, 1, -20),
                Position = UDim2.new(0, 10, 0, 10),
                BackgroundTransparency = 1,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Library.Theme.Accent,
                Visible = false,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                Parent = TabContent
            })

            -- Add padding to tab page
            local ContentPadding = createObject("UIPadding", {
                PaddingTop = UDim.new(0, 5),
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                Parent = TabPage
            })

            -- Add UIListLayout to TabPage with better spacing
            local UIListLayout = createObject("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = TabPage
            })

            -- Improved Tab Selection Logic
            TabButton.MouseButton1Click:Connect(function()
                if SelectedTab == TabPage then return end
                
                -- Hide all tabs
                for _, tab in pairs(Tabs) do
                    tab.Page.Visible = false
                    createTween(tab.Button, {
                        BackgroundColor3 = Library.Theme.Background
                    })
                    createTween(tab.Button.Title, {
                        TextColor3 = Library.Theme.TextColor
                    })
                end
                
                -- Show selected tab
                TabPage.Visible = true
                createTween(TabButton, {
                    BackgroundColor3 = Library.Theme.Accent
                })
                createTween(TabButton.Title, {
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                })
                
                SelectedTab = TabPage
            end)

            -- Store tab information
            table.insert(Tabs, {
                Button = TabButton,
                Page = TabPage
            })

            -- Show first tab by default
            if #Tabs == 1 then
                TabPage.Visible = true
                createTween(TabButton, {
                    BackgroundColor3 = Library.Theme.Accent
                })
                createTween(TabButton.Title, {
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                })
                SelectedTab = TabPage
            end

            -- Tab Methods
            function Tab:AddButton(buttonText, callback)
                local ButtonFrame = createObject("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Parent = TabPage
                })

                -- Add corner to button
                createObject("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ButtonFrame
                })

                local Button = createObject("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = buttonText,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Parent = ButtonFrame
                })

                -- Button hover effect
                Button.MouseEnter:Connect(function()
                    createTween(ButtonFrame, {BackgroundColor3 = Library.Theme.Accent})
                end)

                Button.MouseLeave:Connect(function()
                    createTween(ButtonFrame, {BackgroundColor3 = Library.Theme.LightContrast})
                end)

                Button.MouseButton1Click:Connect(callback)
                return Button
            end

            function Tab:AddToggle(toggleText, default, callback)
                local ToggleFrame = createObject("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Parent = TabPage
                })

                -- Add corner to toggle frame
                createObject("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ToggleFrame
                })

                local ToggleLabel = createObject("TextLabel", {
                    Size = UDim2.new(1, -50, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = toggleText,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame
                })

                local ToggleButton = createObject("Frame", {
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -30, 0.5, -10),
                    BackgroundColor3 = Library.Theme.Disabled,
                    Parent = ToggleFrame
                })

                -- Add corner to toggle button
                createObject("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ToggleButton
                })

                local Enabled = default or false
                
                local function UpdateToggle()
                    createTween(ToggleButton, {
                        BackgroundColor3 = Enabled and Library.Theme.Accent or Library.Theme.Disabled
                    })
                    callback(Enabled)
                end

                -- Initialize toggle state
                UpdateToggle()

                -- Toggle interaction
                ToggleFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Enabled = not Enabled
                        UpdateToggle()
                    end
                end)

                return ToggleFrame
            end

            return Tab
        end,
        GetNavigationType = function()
            return navType
        end
    }
end

return Library
