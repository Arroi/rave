-- Services
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Local configuration table for UI settings
local config = {
	-- Branding settings
	brandingText = "Rave Hub",
	taglineText = "DSC : discord.gg/nBXAHN77Fd",
	imageAsset = "rbxassetid://74870236034685",  -- Replace with your own asset ID
	imageSize = UDim2.new(0, 64, 0, 64),
	
	-- Key system settings
	secretKey = "secret123", -- Change this to your secret key
	maxAttempts = 3,
	
	-- UI Appearance
	mainFrameSize = UDim2.new(0, 320, 0, 300),  -- Adjust height to fit all elements
	mainFrameColor = Color3.fromRGB(31, 31, 31),  -- Dark gray (#1F1F1F)
	inputBoxColor = Color3.fromRGB(46, 46, 46),
	buttonColor = Color3.fromRGB(0, 90, 156),  -- Soft blue (#005A9C)
	font = Enum.Font.Gotham,
	boldFont = Enum.Font.Gotham,

    -- Version Control
    version = "VF1525"
}

-- Notification function using CoreGui notifications
local function sendNotification(title, text, duration)
	StarterGui:SetCore("SendNotification", {
		Title = title,
		Text = text,
		Duration = duration or 3,
	})
end

--------------------------------------------------
-- Create the ScreenGui (persistent on death)
--------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeySystemGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- Create the Main Frame with styling
--------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = config.mainFrameSize
mainFrame.Position = UDim2.new(0.5, -(config.mainFrameSize.X.Offset/2), 0.5, -(config.mainFrameSize.Y.Offset/2))
mainFrame.BackgroundColor3 = config.mainFrameColor
mainFrame.Parent = screenGui

-- Rounded corners for main frame (16px)
local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 16)
mainFrameCorner.Parent = mainFrame

-- Inner padding (10px)
local framePadding = Instance.new("UIPadding")
framePadding.PaddingTop = UDim.new(0, 10)
framePadding.PaddingBottom = UDim.new(0, 10)
framePadding.PaddingLeft = UDim.new(0, 10)
framePadding.PaddingRight = UDim.new(0, 10)
framePadding.Parent = mainFrame

-- Vertical UIListLayout for consistent spacing (5px gap)
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Vertical
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 5)
uiListLayout.Parent = mainFrame

--------------------------------------------------
-- Top Image (64×64)
--------------------------------------------------
local imageLabel = Instance.new("ImageLabel")
imageLabel.Name = "BrandingImage"
imageLabel.Size = config.imageSize
imageLabel.BackgroundTransparency = 1
imageLabel.Image = config.imageAsset
imageLabel.Parent = mainFrame

--------------------------------------------------
-- Branding TextLabel
--------------------------------------------------
local brandingLabel = Instance.new("TextLabel")
brandingLabel.Name = "BrandingLabel"
brandingLabel.Size = UDim2.new(1, 0, 0, 30)
brandingLabel.BackgroundTransparency = 1
brandingLabel.Text = config.brandingText
brandingLabel.Font = config.boldFont
brandingLabel.TextSize = 24
brandingLabel.TextColor3 = Color3.new(1, 1, 1)
brandingLabel.Parent = mainFrame

--------------------------------------------------
-- Tagline TextLabel
--------------------------------------------------
local taglineLabel = Instance.new("TextLabel")
taglineLabel.Name = "TaglineLabel"
taglineLabel.Size = UDim2.new(1, 0, 0, 20)
taglineLabel.BackgroundTransparency = 1
taglineLabel.Text = config.taglineText
taglineLabel.Font = config.font
taglineLabel.TextSize = 14
taglineLabel.TextColor3 = Color3.fromRGB(204, 204, 204)
taglineLabel.Parent = mainFrame

--------------------------------------------------
-- TextBox for Key Input
--------------------------------------------------
local textBox = Instance.new("TextBox")
textBox.Name = "KeyInput"
textBox.Text = ""
textBox.Size = UDim2.new(1, 0, 0, 30)
textBox.PlaceholderText = "Enter Key..."
textBox.ClearTextOnFocus = false
textBox.Font = config.font
textBox.TextSize = 18
textBox.TextColor3 = Color3.new(1, 1, 1)
textBox.BackgroundColor3 = config.inputBoxColor
textBox.Parent = mainFrame

-- Rounded corners for TextBox (8px)
local textBoxCorner = Instance.new("UICorner")
textBoxCorner.CornerRadius = UDim.new(0, 8)
textBoxCorner.Parent = textBox

-- Subtle border for TextBox
local textBoxStroke = Instance.new("UIStroke")
textBoxStroke.Color = Color3.fromRGB(120, 120, 120)
textBoxStroke.Thickness = 1
textBoxStroke.Parent = textBox

--------------------------------------------------
-- TextButton for Submission
--------------------------------------------------
local textButton = Instance.new("TextButton")
textButton.Name = "SubmitButton"
textButton.Size = UDim2.new(1, 0, 0, 30)
textButton.Text = "Submit"
textButton.Font = config.boldFont
textButton.TextSize = 18
textButton.TextColor3 = Color3.new(1, 1, 1)
textButton.BackgroundColor3 = config.buttonColor
textButton.AutoButtonColor = false
textButton.Parent = mainFrame

-- Rounded corners for the Button (8px)
local textButtonCorner = Instance.new("UICorner")
textButtonCorner.CornerRadius = UDim.new(0, 8)
textButtonCorner.Parent = textButton

-- Subtle border for the Button
local textButtonStroke = Instance.new("UIStroke")
textButtonStroke.Color = Color3.fromRGB(200, 200, 200)
textButtonStroke.Thickness = 1
textButtonStroke.Parent = textButton

--------------------------------------------------
-- Fade-In Animation: Black overlay fades out
--------------------------------------------------
local fadeFrame = Instance.new("Frame")
fadeFrame.Name = "FadeFrame"
fadeFrame.Size = UDim2.new(1, 0, 1, 0)
fadeFrame.Position = UDim2.new(0, 0, 0, 0)
fadeFrame.BackgroundColor3 = Color3.new(0, 0, 0)
fadeFrame.BackgroundTransparency = 0  -- Fully opaque at start
fadeFrame.Parent = screenGui

local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tween = TweenService:Create(fadeFrame, tweenInfo, {BackgroundTransparency = 1})
tween:Play()
tween.Completed:Connect(function()
	fadeFrame:Destroy()
end)

-- Notify player that the script has loaded
sendNotification("Script Loaded", "Key System Activated", 3)

--------------------------------------------------
-- Function to Load the UI Library
--------------------------------------------------
local function loadUILibrary()


    sendNotification("UI Loaded", "The UI library has been activated!", 3)
end

--------------------------------------------------
-- Key System Logic
--------------------------------------------------
local attempts = 0

local function checkKey()
	local enteredKey = textBox.Text
	if enteredKey == config.secretKey then
		sendNotification("Key Accepted", "Access granted! Loading UI...", 3)
		-- Tween the mainFrame out before loading the UI library
		mainFrame:TweenPosition(UDim2.new(0.5, -160, 1, 0), "Out", "Quad", 0.5, true)
		task.wait(0.6) -- Wait for the tween to finish
		screenGui:Destroy() -- Remove the key system UI
		loadUILibrary()    -- Load the UI library
	else
		attempts = attempts + 1
		sendNotification("Incorrect Key", "Attempt " .. attempts .. " of " .. config.maxAttempts, 3)
		if attempts >= config.maxAttempts then
			player:Kick("Exceeded maximum key attempts.")
		end
	end
end

-- Connect button click and Enter key submission to the key check function
textButton.MouseButton1Click:Connect(checkKey)
textBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		checkKey()
	end
end)
