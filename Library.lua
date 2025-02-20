--[[
    Modern UI Library for Roblox
    Version: 1.0.0
    Author: Your Name
    License: MIT
]]

local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function Library:CreateWindow(config)
    local Window = {}
    Window.__index = Window
    
    -- Create main GUI container
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RaveLibrary"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Try to parent to CoreGui, fallback to PlayerGui if failed
    pcall(function()
        if syn then
            syn.protect_gui(ScreenGui)
        end
        ScreenGui.Parent = CoreGui
    end)
    
    -- Create main frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.BackgroundColor3 = config.theme.background or Color3.fromRGB(31, 31, 31)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Add corner rounding
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = MainFrame
    
    -- Create tab container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 120, 1, 0)
    TabContainer.BackgroundColor3 = config.theme.foreground or Color3.fromRGB(46, 46, 46)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    -- Add corner rounding to tab container
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabContainer
    
    -- Create tab list layout
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 5)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabContainer
    
    -- Create content container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -130, 1, -10)
    ContentContainer.Position = UDim2.new(0, 125, 0, 5)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
    
    function Window:Tab(name)
        local Tab = {}
        Tab.__index = Tab
        
        -- Create tab button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name.."Tab"
        TabButton.Size = UDim2.new(0.9, 0, 0, 30)
        TabButton.BackgroundColor3 = config.theme.accent or Color3.fromRGB(0, 90, 156)
        TabButton.Text = name
        TabButton.TextColor3 = config.theme.textPrimary or Color3.fromRGB(255, 255, 255)
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 14
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer
        
        -- Add corner rounding to tab button
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = TabButton
        
        -- Create tab content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name.."Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.ScrollBarThickness = 2
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        -- Add list layout to tab content
        local ContentList = Instance.new("UIListLayout")
        ContentList.Padding = UDim.new(0, 5)
        ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ContentList.SortOrder = Enum.SortOrder.LayoutOrder
        ContentList.Parent = TabContent
        
        function Tab:Section(name)
            local Section = {}
            Section.__index = Section
            
            -- Create section frame
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = name.."Section"
            SectionFrame.Size = UDim2.new(0.95, 0, 0, 30)
            SectionFrame.BackgroundColor3 = config.theme.foreground or Color3.fromRGB(46, 46, 46)
            SectionFrame.BorderSizePixel = 0
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.Parent = TabContent
            
            -- Add corner rounding to section
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 4)
            SectionCorner.Parent = SectionFrame
            
            -- Create section content list
            local SectionList = Instance.new("UIListLayout")
            SectionList.Padding = UDim.new(0, 5)
            SectionList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            SectionList.SortOrder = Enum.SortOrder.LayoutOrder
            SectionList.Parent = SectionFrame
            
            -- Add section padding
            local SectionPadding = Instance.new("UIPadding")
            SectionPadding.PaddingTop = UDim.new(0, 5)
            SectionPadding.PaddingBottom = UDim.new(0, 5)
            SectionPadding.Parent = SectionFrame
            
            -- Section title
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.Size = UDim2.new(0.95, 0, 0, 20)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = name
            SectionTitle.TextColor3 = config.theme.textPrimary or Color3.fromRGB(255, 255, 255)
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.TextSize = 14
            SectionTitle.Parent = SectionFrame
            
            -- Section components
            function Section:Button(text, callback)
                local button = Instance.new("TextButton")
                button.Name = text.."Button"
                button.Size = UDim2.new(0.95, 0, 0, 30)
                button.BackgroundColor3 = config.theme.accent or Color3.fromRGB(0, 90, 156)
                button.Text = text
                button.TextColor3 = config.theme.textPrimary or Color3.fromRGB(255, 255, 255)
                button.Font = Enum.Font.Gotham
                button.TextSize = 14
                button.AutoButtonColor = false
                button.Parent = SectionFrame
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 4)
                buttonCorner.Parent = button
                
                button.MouseButton1Click:Connect(function()
                    callback()
                end)
                
                return button
            end
            
            -- Add other component functions (Toggle, Slider, etc.) here
            
            return Section
        end
        
        return Tab
    end
    
    return Window
end

return Library
