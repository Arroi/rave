--[[
    Modern UI Library for Roblox
    Version: 1.0.0
    Author: Your Name
    License: MIT
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Constants
local DEFAULT_THEME = {
    primary = Color3.fromRGB(66, 135, 245),    -- Main brand color
    secondary = Color3.fromRGB(103, 58, 183),  -- Accent color
    background = Color3.fromRGB(255, 255, 255),-- Background color
    surface = Color3.fromRGB(250, 250, 250),   -- Surface elements
    text = Color3.fromRGB(33, 33, 33),         -- Primary text
    textSecondary = Color3.fromRGB(117, 117, 117), -- Secondary text
    success = Color3.fromRGB(76, 175, 80),     -- Success states
    warning = Color3.fromRGB(255, 152, 0),     -- Warning states
    error = Color3.fromRGB(244, 67, 54),       -- Error states
    
    -- Typography
    fontFamily = Enum.Font.Gotham,
    fontSize = {
        small = 12,
        medium = 14,
        large = 16,
        headline = 24
    },
    
    -- Spacing
    spacing = {
        xs = UDim.new(0, 4),
        sm = UDim.new(0, 8),
        md = UDim.new(0, 16),
        lg = UDim.new(0, 24),
        xl = UDim.new(0, 32)
    },
    
    -- Animation
    animation = {
        duration = 0.3,
        easing = Enum.EasingStyle.Quad,
        direction = Enum.EasingDirection.Out
    }
}

-- Initialize the library
function UILibrary.new(theme)
    local self = setmetatable({}, UILibrary)
    self.theme = theme or DEFAULT_THEME
    self.components = {}
    self.activeInstances = {}
    
    -- Create main container
    self.container = Instance.new("ScreenGui")
    self.container.Name = "UILibrary"
    self.container.ResetOnSpawn = false
    self.container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Initialize event system
    self.events = {}
    
    return self
end

-- Theme management
function UILibrary:setTheme(theme)
    self.theme = table.clone(self.theme)
    for key, value in pairs(theme) do
        if type(value) == "table" then
            self.theme[key] = table.clone(value)
        else
            self.theme[key] = value
        end
    end
    self:_updateAllComponents()
end

-- Event system
function UILibrary:on(eventName, callback)
    self.events[eventName] = self.events[eventName] or {}
    table.insert(self.events[eventName], callback)
end

function UILibrary:emit(eventName, ...)
    if self.events[eventName] then
        for _, callback in ipairs(self.events[eventName]) do
            task.spawn(callback, ...)
        end
    end
end

-- Component registration
function UILibrary:registerComponent(name, component)
    self.components[name] = component
end

-- Clean up
function UILibrary:destroy()
    self.container:Destroy()
    self.events = {}
    self.components = {}
    self.activeInstances = {}
end

-- Utility functions
function UILibrary:_createTween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or self.theme.animation.duration,
        style or self.theme.animation.easing,
        direction or self.theme.animation.direction
    )
    return TweenService:Create(instance, tweenInfo, properties)
end

-- Base Component class
local Component = {}
Component.__index = Component

function Component.new(library, props)
    local self = setmetatable({}, Component)
    self.library = library
    self.props = props or {}
    self.instance = nil
    self.events = {}
    return self
end

function Component:destroy()
    if self.instance then
        self.instance:Destroy()
    end
    self.events = {}
end

-- Button Component
local Button = setmetatable({}, {__index = Component})
Button.__index = Button

function Button.new(library, props)
    local self = setmetatable(Component.new(library, props), Button)
    
    -- Create button instance
    self.instance = Instance.new("TextButton")
    self.instance.Name = props.name or "Button"
    self.instance.Size = props.size or UDim2.new(0, 200, 0, 40)
    self.instance.Position = props.position or UDim2.new(0.5, -100, 0.5, -20)
    self.instance.BackgroundColor3 = props.backgroundColor or library.theme.primary
    self.instance.TextColor3 = props.textColor or library.theme.background
    self.instance.Font = props.font or library.theme.fontFamily
    self.instance.TextSize = props.fontSize or library.theme.fontSize.medium
    self.instance.Text = props.text or "Button"
    self.instance.AutoButtonColor = false
    
    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.instance
    
    -- Add hover and click effects
    self:_setupInteractions()
    
    return self
end

function Button:_setupInteractions()
    -- Hover effect
    self.instance.MouseEnter:Connect(function()
        self.library:_createTween(
            self.instance,
            {BackgroundColor3 = self.props.hoverColor or self.library.theme.secondary},
            0.2
        ):Play()
    end)
    
    self.instance.MouseLeave:Connect(function()
        self.library:_createTween(
            self.instance,
            {BackgroundColor3 = self.props.backgroundColor or self.library.theme.primary},
            0.2
        ):Play()
    end)
    
    -- Click effect
    self.instance.MouseButton1Down:Connect(function()
        self.library:_createTween(
            self.instance,
            {Size = self.instance.Size - UDim2.new(0, 4, 0, 4)},
            0.1
        ):Play()
    end)
    
    self.instance.MouseButton1Up:Connect(function()
        self.library:_createTween(
            self.instance,
            {Size = self.instance.Size + UDim2.new(0, 4, 0, 4)},
            0.1
        ):Play()
    end)
end

-- Register components
UILibrary:registerComponent("Button", Button)

-- Input Component
local Input = setmetatable({}, {__index = Component})
Input.__index = Input

function Input.new(library, props)
    local self = setmetatable(Component.new(library, props), Input)
    
    -- Create input container
    self.container = Instance.new("Frame")
    self.container.Name = props.name or "InputContainer"
    self.container.Size = props.size or UDim2.new(0, 200, 0, 40)
    self.container.Position = props.position or UDim2.new(0.5, -100, 0.5, -20)
    self.container.BackgroundTransparency = 1
    
    -- Create input box
    self.instance = Instance.new("TextBox")
    self.instance.Name = "Input"
    self.instance.Size = UDim2.new(1, 0, 1, 0)
    self.instance.BackgroundColor3 = props.backgroundColor or library.theme.surface
    self.instance.TextColor3 = props.textColor or library.theme.text
    self.instance.PlaceholderText = props.placeholder or "Enter text..."
    self.instance.PlaceholderColor3 = props.placeholderColor or library.theme.textSecondary
    self.instance.Text = props.text or ""
    self.instance.Font = props.font or library.theme.fontFamily
    self.instance.TextSize = props.fontSize or library.theme.fontSize.medium
    self.instance.ClearTextOnFocus = props.clearTextOnFocus or false
    self.instance.Parent = self.container
    
    -- Add styling
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.instance
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = library.theme.spacing.sm
    padding.PaddingRight = library.theme.spacing.sm
    padding.Parent = self.instance
    
    -- Add border
    local stroke = Instance.new("UIStroke")
    stroke.Color = props.borderColor or library.theme.textSecondary
    stroke.Thickness = 1
    stroke.Parent = self.instance
    
    -- Setup interactions
    self:_setupInteractions()
    
    return self
end

function Input:_setupInteractions()
    -- Focus effects
    self.instance.Focused:Connect(function()
        self.library:_createTween(
            self.instance,
            {BackgroundColor3 = self.props.focusColor or self.library.theme.surface},
            0.2
        ):Play()
        
        self.library:_createTween(
            self.instance:FindFirstChildOfClass("UIStroke"),
            {Color = self.library.theme.primary},
            0.2
        ):Play()
    end)
    
    self.instance.FocusLost:Connect(function(enterPressed)
        self.library:_createTween(
            self.instance,
            {BackgroundColor3 = self.props.backgroundColor or self.library.theme.surface},
            0.2
        ):Play()
        
        self.library:_createTween(
            self.instance:FindFirstChildOfClass("UIStroke"),
            {Color = self.props.borderColor or self.library.theme.textSecondary},
            0.2
        ):Play()
        
        if enterPressed then
            self.library:emit("inputSubmitted", self.instance.Text)
        end
        
        self.library:emit("inputChanged", self.instance.Text)
    end)
    
    -- Text changed event
    self.instance:GetPropertyChangedSignal("Text"):Connect(function()
        self.library:emit("inputChanged", self.instance.Text)
    end)
end

function Input:getValue()
    return self.instance.Text
end

function Input:setValue(value)
    self.instance.Text = value
end

function Input:setPlaceholder(text)
    self.instance.PlaceholderText = text
end

-- Register Input component
UILibrary:registerComponent("Input", Input)

return UILibrary
