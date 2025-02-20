local Library = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Constants
local TWEEN_SPEED = 0.3
local SPRING_SPEED = 400
local SPRING_DAMPING = 0.7

-- UI Settings
Library.Settings = {
    MainColor = Color3.fromRGB(30, 30, 35),
    AccentColor = Color3.fromRGB(60, 120, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.Gotham,
    FontSize = 14,
    CornerRadius = UDim.new(0, 6),
    ButtonScale = 1.02,
    SoundEnabled = true
}

-- Create effects container
local effects = Instance.new("Folder")
effects.Name = "UIEffects"
effects.Parent = game:GetService("CoreGui")

-- Sound Effects
local function createSound(id)
    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.Volume = 0.5
    sound.Parent = effects
    return sound
end

Library.Sounds = {
    Click = createSound("rbxassetid://6895079853"),
    Hover = createSound("rbxassetid://6895079733"),
    Switch = createSound("rbxassetid://6895079996")
}

-- Utility Functions
function Library:Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

function Library:Tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or TWEEN_SPEED,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Button Component
function Library:CreateButton(parent, text, callback)
    local button = self:Create("ImageButton", {
        Name = "Button",
        Parent = parent,
        BackgroundColor3 = self.Settings.MainColor,
        Size = UDim2.new(0.9, 0, 0, 40),
        Position = UDim2.new(0.05, 0, 0, 0),
        AutoButtonColor = false
    })
    
    -- Add corner radius
    self:Create("UICorner", {
        CornerRadius = self.Settings.CornerRadius,
        Parent = button
    })
    
    -- Add stroke
    local stroke = self:Create("UIStroke", {
        Parent = button,
        Color = self.Settings.AccentColor,
        Transparency = 0.5
    })
    
    -- Add text label
    local label = self:Create("TextLabel", {
        Parent = button,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = text,
        TextColor3 = self.Settings.TextColor,
        Font = self.Settings.Font,
        TextSize = self.Settings.FontSize
    })
    
    -- Hover and click effects
    button.MouseEnter:Connect(function()
        if self.Settings.SoundEnabled then
            self.Sounds.Hover:Play()
        end
        self:Tween(button, {Size = UDim2.new(0.9, 0, 0, 40) * self.Settings.ButtonScale})
        self:Tween(stroke, {Transparency = 0})
    end)
    
    button.MouseLeave:Connect(function()
        self:Tween(button, {Size = UDim2.new(0.9, 0, 0, 40)})
        self:Tween(stroke, {Transparency = 0.5})
    end)
    
    button.MouseButton1Click:Connect(function()
        if self.Settings.SoundEnabled then
            self.Sounds.Click:Play()
        end
        self:Tween(button, {Size = UDim2.new(0.9, 0, 0, 40) * 0.95}, 0.1)
        task.wait(0.1)
        self:Tween(button, {Size = UDim2.new(0.9, 0, 0, 40)}, 0.1)
        if callback then callback() end
    end)
    
    return button
end

-- Slider Component
function Library:CreateSlider(parent, text, min, max, default, callback)
    local slider = self:Create("Frame", {
        Name = "Slider",
        Parent = parent,
        BackgroundColor3 = self.Settings.MainColor,
        Size = UDim2.new(0.9, 0, 0, 50),
        Position = UDim2.new(0.05, 0, 0, 0)
    })
    
    -- Add corner radius
    self:Create("UICorner", {
        CornerRadius = self.Settings.CornerRadius,
        Parent = slider
    })
    
    -- Add text label
    local label = self:Create("TextLabel", {
        Parent = slider,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 0, 20),
        Text = text,
        TextColor3 = self.Settings.TextColor,
        Font = self.Settings.Font,
        TextSize = self.Settings.FontSize,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Add slider bar
    local sliderBar = self:Create("Frame", {
        Name = "SliderBar",
        Parent = slider,
        BackgroundColor3 = self.Settings.AccentColor,
        Position = UDim2.new(0, 10, 0, 30),
        Size = UDim2.new(1, -20, 0, 4)
    })
    
    -- Add slider thumb
    local thumb = self:Create("ImageButton", {
        Name = "Thumb",
        Parent = sliderBar,
        BackgroundColor3 = self.Settings.TextColor,
        Position = UDim2.new(0, 0, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        AnchorPoint = Vector2.new(0.5, 0.5)
    })
    
    self:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = thumb
    })
    
    -- Slider functionality
    local dragging = false
    local value = default or min
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * pos)
        self:Tween(thumb, {Position = UDim2.new(pos, 0, 0.5, -8)})
        if callback then callback(value) end
    end
    
    thumb.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    return slider
end

-- Dropdown Component
function Library:CreateDropdown(parent, text, options, callback)
    local dropdown = self:Create("Frame", {
        Name = "Dropdown",
        Parent = parent,
        BackgroundColor3 = self.Settings.MainColor,
        Size = UDim2.new(0.9, 0, 0, 40),
        Position = UDim2.new(0.05, 0, 0, 0),
        ClipsDescendants = true
    })
    
    -- Add corner radius
    self:Create("UICorner", {
        CornerRadius = self.Settings.CornerRadius,
        Parent = dropdown
    })
    
    -- Add header
    local header = self:Create("TextButton", {
        Name = "Header",
        Parent = dropdown,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Text = text,
        TextColor3 = self.Settings.TextColor,
        Font = self.Settings.Font,
        TextSize = self.Settings.FontSize
    })
    
    -- Add options container
    local container = self:Create("ScrollingFrame", {
        Name = "Container",
        Parent = dropdown,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 0, 0),
        ScrollBarThickness = 2,
        Visible = false
    })
    
    -- Add options
    local function createOption(optionText)
        local option = self:Create("TextButton", {
            Parent = container,
            BackgroundColor3 = self.Settings.MainColor,
            Size = UDim2.new(1, 0, 0, 30),
            Text = optionText,
            TextColor3 = self.Settings.TextColor,
            Font = self.Settings.Font,
            TextSize = self.Settings.FontSize
        })
        
        option.MouseButton1Click:Connect(function()
            if callback then callback(optionText) end
            header.Text = text .. ": " .. optionText
            self:Tween(dropdown, {Size = UDim2.new(0.9, 0, 0, 40)})
            container.Visible = false
        end)
        
        return option
    end
    
    -- Add options
    for _, option in ipairs(options) do
        createOption(option)
    end
    
    -- Toggle dropdown
    local open = false
    header.MouseButton1Click:Connect(function()
        open = not open
        if open then
            container.Visible = true
            self:Tween(dropdown, {Size = UDim2.new(0.9, 0, 0, 40 + math.min(#options * 30, 150))})
        else
            self:Tween(dropdown, {Size = UDim2.new(0.9, 0, 0, 40)})
            task.wait(TWEEN_SPEED)
            container.Visible = false
        end
    end)
    
    return dropdown
end

-- Loader Component
function Library:CreateLoader()
    local loader = self:Create("Frame", {
        Name = "Loader",
        Parent = game:GetService("CoreGui"),
        BackgroundColor3 = self.Settings.MainColor,
        Position = UDim2.new(0.5, -50, 0.5, -50),
        Size = UDim2.new(0, 100, 0, 100),
        AnchorPoint = Vector2.new(0.5, 0.5)
    })
    
    -- Add corner radius
    self:Create("UICorner", {
        CornerRadius = self.Settings.CornerRadius,
        Parent = loader
    })
    
    -- Add spinning image
    local spinner = self:Create("ImageLabel", {
        Parent = loader,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0.6, 0, 0.6, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://4612286995"
    })
    
    -- Create spinning animation
    local spinInfo = TweenInfo.new(
        1,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut,
        -1
    )
    
    local spin = TweenService:Create(spinner, spinInfo, {Rotation = 360})
    spin:Play()
    
    -- Add methods
    function loader:Destroy()
        spin:Cancel()
        loader:Destroy()
    end
    
    return loader
end

function Library:CreateWindow(title)
    local window = {}
    
    -- Create main GUI elements
    window.ScreenGui = self:Create("ScreenGui", {
        Name = "UILibrary",
        Parent = game:GetService("CoreGui"),
        ResetOnSpawn = false
    })
    
    window.Main = self:Create("Frame", {
        Name = "Main",
        Parent = window.ScreenGui,
        BackgroundColor3 = self.Settings.MainColor,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        ClipsDescendants = true
    })
    
    -- Add corner radius
    self:Create("UICorner", {
        CornerRadius = self.Settings.CornerRadius,
        Parent = window.Main
    })
    
    -- Title bar
    local titleBar = self:Create("Frame", {
        Name = "TitleBar",
        Parent = window.Main,
        BackgroundColor3 = self.Settings.AccentColor,
        Size = UDim2.new(1, 0, 0, 40)
    })
    
    self:Create("TextLabel", {
        Parent = titleBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = title,
        TextColor3 = self.Settings.TextColor,
        Font = self.Settings.Font,
        TextSize = self.Settings.FontSize
    })
    
    -- Make window draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Main.Position
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
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Create tab container
    window.TabContainer = self:Create("Frame", {
        Name = "TabContainer",
        Parent = window.Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 150, 1, -40)
    })
    
    -- Create content container
    window.ContentContainer = self:Create("Frame", {
        Name = "ContentContainer",
        Parent = window.Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 40),
        Size = UDim2.new(1, -150, 1, -40)
    })
    
    -- Tab system
    local tabs = {}
    local currentTab = nil
    
    function window:AddTab(name)
        local tab = {
            Button = Library:Create("TextButton", {
                Name = name,
                Parent = window.TabContainer,
                BackgroundColor3 = Library.Settings.MainColor,
                Size = UDim2.new(1, 0, 0, 40),
                Text = name,
                TextColor3 = Library.Settings.TextColor,
                Font = Library.Settings.Font,
                TextSize = Library.Settings.FontSize
            }),
            Content = Library:Create("ScrollingFrame", {
                Name = name .. "Content",
                Parent = window.ContentContainer,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ScrollBarThickness = 2,
                Visible = false
            })
        }
        
        -- Add UIListLayout to content
        Library:Create("UIListLayout", {
            Parent = tab.Content,
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        -- Tab button click handler
        tab.Button.MouseButton1Click:Connect(function()
            if currentTab then
                currentTab.Content.Visible = false
                Library:Tween(currentTab.Button, {BackgroundColor3 = Library.Settings.MainColor})
            end
            currentTab = tab
            tab.Content.Visible = true
            Library:Tween(tab.Button, {BackgroundColor3 = Library.Settings.AccentColor})
            if Library.Settings.SoundEnabled then
                Library.Sounds.Switch:Play()
            end
        end)
        
        -- Add methods to tab
        function tab:AddButton(text, callback)
            return Library:CreateButton(self.Content, text, callback)
        end
        
        function tab:AddSlider(text, min, max, default, callback)
            return Library:CreateSlider(self.Content, text, min, max, default, callback)
        end
        
        function tab:AddDropdown(text, options, callback)
            return Library:CreateDropdown(self.Content, text, options, callback)
        end
        
        -- Set as current tab if first
        if #tabs == 0 then
            currentTab = tab
            tab.Content.Visible = true
            tab.Button.BackgroundColor3 = Library.Settings.AccentColor
        end
        
        table.insert(tabs, tab)
        return tab
    end
    
    return window
end

return Library