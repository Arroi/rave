local Library = {
    Flags = {},
    Theme = {
        Main = Color3.fromRGB(25, 25, 25),
        Secondary = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(60, 145, 255),
        StrongText = Color3.fromRGB(255, 255, 255),
        WeakText = Color3.fromRGB(180, 180, 180)
    }
}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

function Library:Create(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

function Library:CreateWindow(title)
    local window = {}
    
    -- Main GUI
    window.Screen = self:Create("ScreenGui", {
        Name = title,
        Parent = game:GetService("CoreGui")
    })
    
    window.Main = self:Create("Frame", {
        Name = "Main",
        Parent = window.Screen,
        BackgroundColor3 = self.Theme.Main,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400)
    })
    
    -- Make window draggable
    local dragging, dragInput, dragStart, startPos
    
    window.Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Main.Position
        end
    end)
    
    window.Main.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Title bar
    window.TitleBar = self:Create("Frame", {
        Name = "TitleBar",
        Parent = window.Main,
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30)
    })
    
    window.Title = self:Create("TextLabel", {
        Parent = window.TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.Gotham,
        Text = title,
        TextColor3 = self.Theme.StrongText,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Tab container
    window.TabContainer = self:Create("Frame", {
        Name = "TabContainer",
        Parent = window.Main,
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(0, 150, 1, -30)
    })
    
    window.TabList = self:Create("UIListLayout", {
        Parent = window.TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    
    -- Content container
    window.ContentContainer = self:Create("Frame", {
        Name = "ContentContainer",
        Parent = window.Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 30),
        Size = UDim2.new(1, -150, 1, -30)
    })
    
    function window:Tab(name)
        local tab = {}
        
        tab.Button = self:Create("TextButton", {
            Name = name,
            Parent = window.TabContainer,
            BackgroundColor3 = Library.Theme.Main,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 32),
            Font = Enum.Font.Gotham,
            Text = name,
            TextColor3 = Library.Theme.WeakText,
            TextSize = 14
        })
        
        tab.Container = self:Create("ScrollingFrame", {
            Name = name .. "Container",
            Parent = window.ContentContainer,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            Visible = false
        })
        
        -- Add padding
        self:Create("UIPadding", {
            Parent = tab.Container,
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10)
        })
        
        -- Add list layout
        local list = self:Create("UIListLayout", {
            Parent = tab.Container,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5)
        })
        
        -- Auto-size canvas
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tab.Container.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 20)
        end)
        
        -- Tab button handler
        tab.Button.MouseButton1Click:Connect(function()
            for _, otherTab in pairs(window.ContentContainer:GetChildren()) do
                if otherTab:IsA("ScrollingFrame") then
                    otherTab.Visible = false
                end
            end
            for _, otherBtn in pairs(window.TabContainer:GetChildren()) do
                if otherBtn:IsA("TextButton") then
                    TweenService:Create(otherBtn, TweenInfo.new(0.2), {
                        TextColor3 = Library.Theme.WeakText
                    }):Play()
                end
            end
            tab.Container.Visible = true
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {
                TextColor3 = Library.Theme.Accent
            }):Play()
        end)
        
        -- Section creator
        function tab:Section(name)
            local section = {}
            
            section.Container = self:Create("Frame", {
                Name = name .. "Section",
                Parent = tab.Container,
                BackgroundColor3 = Library.Theme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 32),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            section.Title = self:Create("TextLabel", {
                Parent = section.Container,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 32),
                Font = Enum.Font.GothamBold,
                Text = name,
                TextColor3 = Library.Theme.StrongText,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            section.List = self:Create("UIListLayout", {
                Parent = section.Container,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            })
            
            section.Padding = self:Create("UIPadding", {
                Parent = section.Container,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            })
            
            -- Toggle creator
            function section:Toggle(name, default, flag, callback)
                local toggle = {}
                Library.Flags[flag] = default or false
                
                toggle.Button = self:Create("TextButton", {
                    Name = name,
                    Parent = section.Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    Text = "",
                    LayoutOrder = #section.Container:GetChildren()
                })
                
                toggle.Title = self:Create("TextLabel", {
                    Parent = toggle.Button,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 32, 0, 0),
                    Size = UDim2.new(1, -32, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = Library.Theme.WeakText,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                toggle.Indicator = self:Create("Frame", {
                    Parent = toggle.Button,
                    BackgroundColor3 = Library.Theme.Secondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16)
                })
                
                self:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = toggle.Indicator
                })
                
                toggle.Button.MouseButton1Click:Connect(function()
                    Library.Flags[flag] = not Library.Flags[flag]
                    
                    TweenService:Create(toggle.Indicator, TweenInfo.new(0.2), {
                        BackgroundColor3 = Library.Flags[flag] and Library.Theme.Accent or Library.Theme.Secondary
                    }):Play()
                    
                    if callback then
                        callback(Library.Flags[flag])
                    end
                end)
                
                if default then
                    toggle.Indicator.BackgroundColor3 = Library.Theme.Accent
                end
                
                return toggle
            end
            
            return section
        end
        
        return tab
    end
    
    -- Show first tab by default
    local firstTab = window.TabContainer:FindFirstChildWhichIsA("TextButton")
    if firstTab then
        firstTab:GetPropertyChangedSignal("Parent"):Wait()
        firstTab.TextColor3 = Library.Theme.Accent
        window.ContentContainer:FindFirstChild(firstTab.Name .. "Container").Visible = true
    end
    
    return window
end

return Library