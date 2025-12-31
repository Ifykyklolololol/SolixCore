-- Roblox UI Library
-- Single file implementation with all components

local Library = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Player
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Utility Functions
local function isMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function createTween(instance, properties, duration, style, direction)
	style = style or Enum.EasingStyle.Quad
	direction = direction or Enum.EasingDirection.Out
	duration = duration or 0.2
	
	local tweenInfo = TweenInfo.new(duration, style, direction)
	local tween = TweenService:Create(instance, tweenInfo, properties)
	return tween
end

local function createInstance(className, properties)
	local instance = Instance.new(className)
	for key, value in pairs(properties or {}) do
		if key == "Parent" then
			instance.Parent = value
		else
			instance[key] = value
		end
	end
	return instance
end

-- Theme System
local Theme = {
	Current = "PinkWhite",
	Themes = {
		PinkWhite = {
			Main = Color3.fromRGB(0, 162, 255), -- Blue accent (like in image)
			Secondary = Color3.fromRGB(255, 255, 255), -- White
			Background = Color3.fromRGB(20, 20, 20), -- Very dark background
			Surface = Color3.fromRGB(25, 25, 25), -- Dark grey sections
			SurfaceHover = Color3.fromRGB(30, 30, 30), -- Slightly lighter on hover
			Text = Color3.fromRGB(255, 255, 255), -- White text
			TextSecondary = Color3.fromRGB(200, 200, 200), -- Light grey text
			Accent = Color3.fromRGB(0, 162, 255), -- Blue
			Success = Color3.fromRGB(76, 175, 80),
			Error = Color3.fromRGB(244, 67, 54),
			Warning = Color3.fromRGB(255, 152, 0),
			Border = Color3.fromRGB(40, 40, 40), -- Subtle borders
		}
	}
}

function Theme:SetTheme(themeName)
	if self.Themes[themeName] then
		self.Current = themeName
		return true
	end
	return false
end

function Theme:GetTheme()
	return self.Themes[self.Current] or self.Themes.PinkWhite
end

function Theme:SetCustomTheme(themeTable)
	self.Themes.Custom = themeTable
	self.Current = "Custom"
end

-- Mobile Detection and Optimization
local Mobile = {
	IsMobile = isMobile(),
	Scale = isMobile() and 1.2 or 1,
	TouchSize = 44, -- Minimum touch target size
}

local function applyMobileOptimizations(instance, baseSize)
	if Mobile.IsMobile then
		if instance:IsA("TextButton") or instance:IsA("TextLabel") then
			instance.TextSize = math.max(instance.TextSize * Mobile.Scale, 12)
		end
		if baseSize then
			local currentSize = instance.Size
			instance.Size = UDim2.new(
				currentSize.X.Scale,
				math.max(currentSize.X.Offset * Mobile.Scale, baseSize),
				currentSize.Y.Scale,
				math.max(currentSize.Y.Offset * Mobile.Scale, Mobile.TouchSize)
			)
		end
	end
end

-- Config System
local Config = {
	AutoSave = false,
	AutoLoad = false,
	SilentLoad = false,
	Configs = {},
	CurrentConfig = nil,
	SaveQueue = {},
	SaveDebounce = false,
}

-- Debounced save function
local function debouncedSave()
	if Config.SaveDebounce then return end
	Config.SaveDebounce = true
	
	task.spawn(function()
		task.wait(0.5) -- Debounce saves
		for name, data in pairs(Config.SaveQueue) do
			if Config.AutoSave then
				pcall(function()
					local json = HttpService:JSONEncode(data)
					-- In real implementation, save to DataStore
				end)
			end
		end
		Config.SaveQueue = {}
		Config.SaveDebounce = false
	end)
end

function Config:Save(name, data)
	if not name then return false end
	self.Configs[name] = data or {}
	self.SaveQueue[name] = self.Configs[name]
	
	if self.AutoSave then
		debouncedSave()
	end
	
	return true
end

function Config:Load(name, silent)
	if not name then return false end
	silent = silent or self.SilentLoad
	
	-- Try to load from memory first
	if self.Configs[name] then
		if not silent then
			Notification:Create({
				Title = "Config Loaded",
				Text = "Config '" .. name .. "' loaded successfully",
				Type = "Success",
				Duration = 2
			})
		end
		self.CurrentConfig = name
		return self.Configs[name]
	end
	
	-- In real implementation, load from DataStore
	-- For now, return false if not found
	if not silent then
		Notification:Create({
			Title = "Config Not Found",
			Text = "Config '" .. name .. "' does not exist",
			Type = "Error",
			Duration = 2
		})
	end
	
	return false
end

function Config:Delete(name)
	if self.Configs[name] then
		self.Configs[name] = nil
		return true
	end
	return false
end

function Config:Share(name)
	if not self.Configs[name] then return nil end
	local json = HttpService:JSONEncode(self.Configs[name])
	return json
end

function Config:Import(configString)
	local success, data = pcall(function()
		return HttpService:JSONDecode(configString)
	end)
	return success and data or nil
end

-- Notification System
local Notification = {
	Queue = {},
	Active = {},
	MaxActive = 3,
}

function Notification:Create(notificationData)
	local title = notificationData.Title or "Notification"
	local text = notificationData.Text or ""
	local notifType = notificationData.Type or "Info"
	local duration = notificationData.Duration or 3
	
	local theme = Theme:GetTheme()
	
	local screenGui = createInstance("ScreenGui", {
		Name = "Notification_" .. HttpService:GenerateGUID(false),
		Parent = CoreGui,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	
	local frame = createInstance("Frame", {
		Name = "Notification",
		Parent = screenGui,
		Size = UDim2.new(0, 300, 0, 80),
		Position = UDim2.new(1, -320, 0, 20 + (#self.Active * 90)),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 100,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = frame,
	})
	
	createInstance("UIStroke", {
		Parent = frame,
		Color = theme.Main,
		Thickness = 2,
		Transparency = 0.5,
	})
	
	local titleLabel = createInstance("TextLabel", {
		Parent = frame,
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.new(0, 10, 0, 10),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 101,
	})
	
	local textLabel = createInstance("TextLabel", {
		Parent = frame,
		Size = UDim2.new(1, -20, 0, 40),
		Position = UDim2.new(0, 10, 0, 30),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = theme.TextSecondary,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		ZIndex = 101,
	})
	
	frame.Position = UDim2.new(1, 20, 0, frame.Position.Y.Offset)
	createTween(frame, {Position = UDim2.new(1, -320, 0, frame.Position.Y.Offset)}, 0.3):Play()
	
	table.insert(self.Active, screenGui)
	
	task.spawn(function()
		task.wait(duration)
		createTween(frame, {Position = UDim2.new(1, 20, 0, frame.Position.Y.Offset), BackgroundTransparency = 1}, 0.3):Play()
		createTween(titleLabel, {TextTransparency = 1}, 0.3):Play()
		createTween(textLabel, {TextTransparency = 1}, 0.3):Play()
		task.wait(0.3)
		for i, v in ipairs(self.Active) do
			if v == screenGui then
				table.remove(self.Active, i)
				break
			end
		end
		screenGui:Destroy()
	end)
end

function Library:Notify(notificationData)
	Notification:Create(notificationData)
end

-- Component Base
local Component = {}
Component.__index = Component

function Component.new(instance, data)
	local self = setmetatable({}, Component)
	self.Instance = instance
	self.Data = data or {}
	self.Visible = true
	self.Enabled = true
	return self
end

function Component:SetVisible(visible)
	self.Visible = visible
	if self.Instance then
		self.Instance.Visible = visible
	end
end

function Component:SetEnabled(enabled)
	self.Enabled = enabled
end

function Component:Destroy()
	if self.Instance then
		self.Instance:Destroy()
	end
end

-- Component modules (declared early for use in Section)
local Toggle = {}
local Button = {}
local TextLabel = {}
local Dropdown = {}
local Slider = {}
local Textbox = {}
local Keybind = {}
local ColorPicker = {}

-- Section System (declared early for use in Window:Page)
local Section = {}
Section.__index = Section

-- Window System
local Window = {}
Window.__index = Window

function Window.new(options)
	local self = setmetatable({}, Window)
	
	local title = options.Title or "Window"
	local baseSize = options.Size or UDim2.new(0, 500, 0, 400)
	local basePosition = options.Position or UDim2.new(0.5, -250, 0.5, -200)
	
	-- Mobile optimizations
	if Mobile.IsMobile then
		baseSize = UDim2.new(
			baseSize.X.Scale,
			math.min(baseSize.X.Offset * Mobile.Scale, 600),
			baseSize.Y.Scale,
			math.min(baseSize.Y.Offset * Mobile.Scale, 500)
		)
		basePosition = UDim2.new(0.5, -baseSize.X.Offset / 2, 0.5, -baseSize.Y.Offset / 2)
	end
	
	local size = baseSize
	local position = basePosition
	
	local theme = Theme:GetTheme()
	
	self.ScreenGui = createInstance("ScreenGui", {
		Name = "UIWindow_" .. HttpService:GenerateGUID(false),
		Parent = PlayerGui,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	
	self.MainFrame = createInstance("Frame", {
		Name = "MainFrame",
		Parent = self.ScreenGui,
		Size = size,
		Position = position,
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 1,
		BorderColor3 = theme.Border,
		ZIndex = 10,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = self.MainFrame,
	})
	
	self.TitleBar = createInstance("Frame", {
		Name = "TitleBar",
		Parent = self.MainFrame,
		Size = UDim2.new(1, 0, 0, 35),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 11,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = self.TitleBar,
	})
	
	local titleLabel = createInstance("TextLabel", {
		Parent = self.TitleBar,
		Size = UDim2.new(1, -80, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 14,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 12,
	})
	
	local closeButton = createInstance("TextButton", {
		Parent = self.TitleBar,
		Size = UDim2.new(0, 25, 0, 25),
		Position = UDim2.new(1, -30, 0, 5),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Text = "",
		ZIndex = 12,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = closeButton,
	})
	
	closeButton.MouseEnter:Connect(function()
		closeButton.BackgroundColor3 = theme.Error
	end)
	
	closeButton.MouseLeave:Connect(function()
		closeButton.BackgroundColor3 = theme.Surface
	end)
	
	local closeIcon = createInstance("TextLabel", {
		Parent = closeButton,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "×",
		TextColor3 = theme.Text,
		TextSize = 24,
		Font = Enum.Font.GothamBold,
		ZIndex = 13,
	})
	
	closeButton.MouseButton1Click:Connect(function()
		self:Destroy()
	end)
	
	self.PageContainer = createInstance("Frame", {
		Name = "PageContainer",
		Parent = self.MainFrame,
		Size = UDim2.new(1, 0, 1, -65),
		Position = UDim2.new(0, 0, 0, 65),
		BackgroundTransparency = 1,
		ZIndex = 11,
	})
	
	self.PageButtons = createInstance("Frame", {
		Name = "PageButtons",
		Parent = self.MainFrame,
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.new(0, 0, 0, 35),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 12,
	})
	
	createInstance("UIListLayout", {
		Parent = self.PageButtons,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 0),
	})
	
	self.Pages = {}
	self.CurrentPage = nil
	
	local dragging = false
	local dragStart = nil
	local startPos = nil
	
	local function updateDrag(input)
		if dragging and startPos then
			local delta = input.Position - dragStart
			self.MainFrame.Position = UDim2.new(
				0, startPos.X.Offset + delta.X,
				0, startPos.Y.Offset + delta.Y
			)
		end
	end
	
	titleLabel.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = self.MainFrame.Position
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging then
			updateDrag(input)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	
	return self
end

function Window:Page(options)
	local name = options.Name or "Page"
	local columns = options.Columns or 1
	
	local theme = Theme:GetTheme()
	
	local pageButtonSize = Mobile.IsMobile and 120 or 100
	local pageButton = createInstance("TextButton", {
		Name = name .. "Button",
		Parent = self.PageButtons,
		Size = UDim2.new(0, pageButtonSize, 1, 0),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Text = name,
		TextColor3 = theme.TextSecondary,
		TextSize = Mobile.IsMobile and 13 or 12,
		Font = Enum.Font.Gotham,
		ZIndex = 13,
	})
	
	pageButton.MouseEnter:Connect(function()
		if self.CurrentPage ~= page then
			pageButton.BackgroundColor3 = theme.SurfaceHover
		end
	end)
	
	pageButton.MouseLeave:Connect(function()
		if self.CurrentPage ~= page then
			pageButton.BackgroundColor3 = theme.Surface
		end
	end)
	
	local pageContent = createInstance("ScrollingFrame", {
		Name = name .. "Content",
		Parent = self.PageContainer,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme.Main,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ZIndex = 11,
	})
	
	createInstance("UIPadding", {
		Parent = pageContent,
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
	})
	
	local columnContainer = createInstance("Frame", {
		Name = "ColumnContainer",
		Parent = pageContent,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	})
	
	createInstance("UIGridLayout", {
		Parent = columnContainer,
		CellSize = UDim2.new(1 / columns, -10, 0, 0),
		CellPadding = UDim2.new(0, 10, 0, 10),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	
	local page = {
		Name = name,
		Columns = columns,
		Button = pageButton,
		Content = pageContent,
		ColumnContainer = columnContainer,
		Sections = {},
	}
	
	pageContent.Visible = false
	
	pageButton.MouseButton1Click:Connect(function()
		for _, p in pairs(self.Pages) do
			if p.Content then
				p.Content.Visible = false
			end
			if p.Button then
				p.Button.BackgroundColor3 = theme.Surface
				p.Button.TextColor3 = theme.TextSecondary
			end
		end
		
		pageContent.Visible = true
		pageButton.BackgroundColor3 = theme.Background
		pageButton.TextColor3 = theme.Main
		
		self.CurrentPage = page
	end)
	
	if not self.CurrentPage then
		pageContent.Visible = true
		pageButton.BackgroundColor3 = theme.Background
		pageButton.TextColor3 = theme.Main
		self.CurrentPage = page
	end
	
	self.Pages[name] = page
	
	local pageMethods = {}
	pageMethods.__index = pageMethods
	
	function pageMethods:Section(options)
		return Section.new(self, options)
	end
	
	setmetatable(page, pageMethods)
	
	return page
end

function Window:Destroy()
	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
end

function Section.new(page, options)
	local self = setmetatable({}, Section)
	
	local name = options.Name or "Section"
	local theme = Theme:GetTheme()
	
	local sectionFrame = createInstance("Frame", {
		Name = name,
		Parent = page.ColumnContainer,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 1,
		BorderColor3 = theme.Border,
		ZIndex = 12,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = sectionFrame,
	})
	
	local titleLabel = createInstance("TextLabel", {
		Parent = sectionFrame,
		Size = UDim2.new(1, -20, 0, 25),
		Position = UDim2.new(0, 10, 0, 5),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = theme.Text,
		TextSize = 13,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 13,
	})
	
	local contentContainer = createInstance("Frame", {
		Name = "Content",
		Parent = sectionFrame,
		Size = UDim2.new(1, -20, 1, -35),
		Position = UDim2.new(0, 10, 0, 30),
		BackgroundTransparency = 1,
		ZIndex = 13,
	})
	
	local contentLayout = createInstance("UIListLayout", {
		Parent = contentContainer,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	
	contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		sectionFrame.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y + 40)
		page.Content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 50)
	end)
	
	self.Instance = sectionFrame
	self.Content = contentContainer
	self.Page = page
	self.Name = name
	self.Components = {}
	
	local sectionMethods = {}
	sectionMethods.__index = sectionMethods
	
	function sectionMethods:Toggle(options)
		return Toggle.new(self, options)
	end
	
	function sectionMethods:Button(options)
		return Button.new(self, options)
	end
	
	function sectionMethods:Dropdown(options)
		return Dropdown.new(self, options)
	end
	
	function sectionMethods:Slider(options)
		return Slider.new(self, options)
	end
	
	function sectionMethods:Textbox(options)
		return Textbox.new(self, options)
	end
	
	function sectionMethods:TextLabel(options)
		return TextLabel.new(self, options)
	end
	
	function sectionMethods:Keybind(options)
		return Keybind.new(self, options)
	end
	
	function sectionMethods:ColorPicker(options)
		return ColorPicker.new(self, options)
	end
	
	setmetatable(self, sectionMethods)
	
	return self
end

-- Toggle Component
Toggle.__index = Toggle

function Toggle.new(section, options)
	local self = setmetatable({}, Toggle)
	
	local name = options.Name or "Toggle"
	local defaultValue = options.Default or false
	local callback = options.Callback or function() end
	local condition = options.Condition or function() return true end
	local maybeLocked = options.MaybeLocked ~= nil and options.MaybeLocked or false
	
	local theme = Theme:GetTheme()
	
	local toggleContainer = createInstance("Frame", {
		Name = name,
		Parent = section.Content,
		Size = UDim2.new(1, 0, 0, 25),
		BackgroundTransparency = 1,
		ZIndex = 14,
	})
	
	createInstance("UIListLayout", {
		Parent = toggleContainer,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Padding = UDim.new(0, 10),
	})
	
	local label = createInstance("TextLabel", {
		Parent = toggleContainer,
		Size = UDim2.new(1, -80, 1, 0),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = theme.Text,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 15,
	})
	
	local lockIcon = nil
	if not maybeLocked then
		lockIcon = createInstance("ImageLabel", {
			Parent = toggleContainer,
			Size = UDim2.new(0, 16, 0, 16),
			BackgroundTransparency = 1,
			Image = "rbxassetid://6031068421",
			ImageColor3 = theme.TextSecondary,
			ZIndex = 15,
		})
	end
	
	local toggleSize = Mobile.IsMobile and 50 or 42
	local toggleHeight = Mobile.IsMobile and 24 or 20
	local toggleFrame = createInstance("TextButton", {
		Name = "ToggleFrame",
		Parent = toggleContainer,
		Size = UDim2.new(0, toggleSize, 0, toggleHeight),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 1,
		BorderColor3 = theme.Border,
		Text = "",
		TextTransparency = 1,
		AutoButtonColor = false,
		ZIndex = 15,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 10),
		Parent = toggleFrame,
	})
	
	local toggleButtonSize = Mobile.IsMobile and 18 or 16
	local toggleButton = createInstance("Frame", {
		Parent = toggleFrame,
		Size = UDim2.new(0, toggleButtonSize, 0, toggleButtonSize),
		Position = UDim2.new(0, 2, 0, 2),
		BackgroundColor3 = theme.TextSecondary,
		BorderSizePixel = 0,
		ZIndex = 16,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = toggleButton,
	})
	
	self.Instance = toggleContainer
	self.ToggleFrame = toggleFrame
	self.ToggleButton = toggleButton
	self.Label = label
	self.LockIcon = lockIcon
	self.Value = defaultValue
	self.Callback = callback
	self.Condition = condition
	self.MaybeLocked = maybeLocked
	self.Enabled = true
	
	local buttonOffset = Mobile.IsMobile and -20 or -18
	if defaultValue then
		toggleButton.Position = UDim2.new(1, buttonOffset, 0, 2)
		toggleFrame.BackgroundColor3 = theme.Main
		toggleFrame.BorderColor3 = theme.Main
	else
		toggleButton.Position = UDim2.new(0, 2, 0, 2)
		toggleFrame.BackgroundColor3 = theme.Background
		toggleFrame.BorderColor3 = theme.Border
	end
	
	toggleFrame.MouseButton1Click:Connect(function()
		if not self.Enabled then return end
		if not condition() then return end
		
		self.Value = not self.Value
		
		local buttonOffset = Mobile.IsMobile and -20 or -18
		if self.Value then
			createTween(toggleButton, {Position = UDim2.new(1, buttonOffset, 0, 2)}, 0.2):Play()
			createTween(toggleFrame, {BackgroundColor3 = theme.Main, BorderColor3 = theme.Main}, 0.2):Play()
		else
			createTween(toggleButton, {Position = UDim2.new(0, 2, 0, 2)}, 0.2):Play()
			createTween(toggleFrame, {BackgroundColor3 = theme.Background, BorderColor3 = theme.Border}, 0.2):Play()
		end
		
		callback(self.Value)
	end)
	
	task.spawn(function()
		while toggleContainer.Parent do
			local canUse = condition()
			if not canUse and self.Enabled then
				label.TextColor3 = theme.TextSecondary
				toggleFrame.BackgroundTransparency = 0.5
			elseif canUse and self.Enabled then
				label.TextColor3 = theme.Text
				toggleFrame.BackgroundTransparency = 0
			end
			task.wait(0.1)
		end
	end)
	
	function self:GetValue()
		return self.Value
	end
	
	function self:SetValue(value)
		self.Value = value
		local buttonOffset = Mobile.IsMobile and -20 or -18
		if value then
			createTween(toggleButton, {Position = UDim2.new(1, buttonOffset, 0, 2)}, 0.2):Play()
			createTween(toggleFrame, {BackgroundColor3 = theme.Main, BorderColor3 = theme.Main}, 0.2):Play()
		else
			createTween(toggleButton, {Position = UDim2.new(0, 2, 0, 2)}, 0.2):Play()
			createTween(toggleFrame, {BackgroundColor3 = theme.Background, BorderColor3 = theme.Border}, 0.2):Play()
		end
		callback(self.Value)
	end
	
	function self:SetMaybeLocked(locked)
		self.MaybeLocked = locked
		if lockIcon then
			lockIcon.Visible = not locked
		end
	end
	
	return self
end

-- Button Component
Button.__index = Button

function Button.new(section, options)
	local self = setmetatable({}, Button)
	
	local name = options.Name or "Button"
	local callback = options.Callback or function() end
	
	local theme = Theme:GetTheme()
	
	local buttonSize = Mobile.IsMobile and 35 or 28
	local button = createInstance("TextButton", {
		Name = name,
		Parent = section.Content,
		Size = UDim2.new(1, 0, 0, buttonSize),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 1,
		BorderColor3 = theme.Border,
		Text = name,
		TextColor3 = theme.Text,
		TextSize = Mobile.IsMobile and 13 or 12,
		Font = Enum.Font.Gotham,
		ZIndex = 14,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = button,
	})
	
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = theme.SurfaceHover
		button.BorderColor3 = theme.Main
	end)
	
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = theme.Surface
		button.BorderColor3 = theme.Border
	end)
	
	self.Instance = button
	self.Callback = callback
	
	button.MouseButton1Click:Connect(function()
		local buttonHeight = Mobile.IsMobile and 38 or 33
		local finalHeight = Mobile.IsMobile and 40 or 35
		createTween(button, {Size = UDim2.new(0.95, 0, 0, buttonHeight)}, 0.1):Play()
		task.wait(0.1)
		createTween(button, {Size = UDim2.new(1, 0, 0, finalHeight)}, 0.1):Play()
		callback()
	end)
	
	
	return self
end

-- TextLabel Component
TextLabel.__index = TextLabel

function TextLabel.new(section, options)
	local self = setmetatable({}, TextLabel)
	
	local text = options.Text or ""
	local theme = Theme:GetTheme()
	
	local label = createInstance("TextLabel", {
		Name = "TextLabel",
		Parent = section.Content,
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = theme.Text,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		ZIndex = 14,
	})
	
	label:GetPropertyChangedSignal("TextBounds"):Connect(function()
		label.Size = UDim2.new(1, 0, 0, label.TextBounds.Y)
	end)
	
	self.Instance = label
	
	return self
end

-- Dropdown Component
Dropdown.__index = Dropdown

function Dropdown.new(section, options)
	local self = setmetatable({}, Dropdown)
	
	local name = options.Name or "Dropdown"
	local optionsList = options.Options or {}
	local defaultValue = options.Default or optionsList[1]
	local callback = options.Callback or function() end
	
	local theme = Theme:GetTheme()
	
	local dropdownContainer = createInstance("Frame", {
		Name = name,
		Parent = section.Content,
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundTransparency = 1,
		ZIndex = 14,
	})
	
	local dropdownSize = Mobile.IsMobile and 40 or 35
	local dropdownButton = createInstance("TextButton", {
		Name = "DropdownButton",
		Parent = dropdownContainer,
		Size = UDim2.new(1, 0, 0, dropdownSize),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 1,
		BorderColor3 = theme.Border,
		Text = defaultValue or "Select...",
		TextColor3 = theme.Text,
		TextSize = Mobile.IsMobile and 13 or 12,
		Font = Enum.Font.Gotham,
		ZIndex = 15,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = dropdownButton,
	})
	
	dropdownButton.MouseEnter:Connect(function()
		dropdownButton.BackgroundColor3 = theme.SurfaceHover
	end)
	
	dropdownButton.MouseLeave:Connect(function()
		dropdownButton.BackgroundColor3 = theme.Surface
	end)
	
	local arrow = createInstance("TextLabel", {
		Parent = dropdownButton,
		Size = UDim2.new(0, 20, 1, 0),
		Position = UDim2.new(1, -25, 0, 0),
		BackgroundTransparency = 1,
		Text = "▼",
		TextColor3 = theme.TextSecondary,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		ZIndex = 16,
	})
	
	local dropdownList = createInstance("ScrollingFrame", {
		Name = "DropdownList",
		Parent = dropdownContainer,
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, 40),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme.Main,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Visible = false,
		ZIndex = 20,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = dropdownList,
	})
	
	createInstance("UIListLayout", {
		Parent = dropdownList,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	
	local isOpen = false
	
	local function updateList()
		for i, option in ipairs(optionsList) do
			local optionButton = createInstance("TextButton", {
				Parent = dropdownList,
				Size = UDim2.new(1, -10, 0, 30),
				BackgroundColor3 = theme.Background,
				BorderSizePixel = 0,
				Text = tostring(option),
				TextColor3 = theme.Text,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				ZIndex = 21,
			})
			
			createInstance("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Parent = optionButton,
			})
			
			optionButton.MouseButton1Click:Connect(function()
				dropdownButton.Text = tostring(option)
				self.Value = option
				callback(option)
				isOpen = false
				dropdownList.Visible = false
				createTween(arrow, {Rotation = 0}, 0.2):Play()
			end)
			
			optionButton.MouseEnter:Connect(function()
				createTween(optionButton, {BackgroundColor3 = theme.Main}, 0.2):Play()
			end)
			
			optionButton.MouseLeave:Connect(function()
				createTween(optionButton, {BackgroundColor3 = theme.Background}, 0.2):Play()
			end)
		end
		
		dropdownList.CanvasSize = UDim2.new(0, 0, 0, #optionsList * 32)
		dropdownList.Size = UDim2.new(1, 0, 0, math.min(#optionsList * 32, 150))
	end
	
	updateList()
	
	dropdownButton.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		dropdownList.Visible = isOpen
		
		if isOpen then
			createTween(arrow, {Rotation = 180}, 0.2):Play()
		else
			createTween(arrow, {Rotation = 0}, 0.2):Play()
		end
	end)
	
	self.Instance = dropdownContainer
	self.Value = defaultValue
	
	function self:GetValue()
		return self.Value
	end
	
	function self:SetValue(value)
		self.Value = value
		dropdownButton.Text = tostring(value)
		callback(value)
	end
	
	return self
end

-- Slider Component
Slider.__index = Slider

function Slider.new(section, options)
	local self = setmetatable({}, Slider)
	
	local name = options.Name or "Slider"
	local min = options.Min or 0
	local max = options.Max or 100
	local defaultValue = options.Default or min
	local step = options.Step or 1
	local callback = options.Callback or function() end
	
	local theme = Theme:GetTheme()
	
	local sliderContainer = createInstance("Frame", {
		Name = name,
		Parent = section.Content,
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		ZIndex = 14,
	})
	
	local label = createInstance("TextLabel", {
		Parent = sliderContainer,
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = theme.Text,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 15,
	})
	
	local valueLabel = createInstance("TextLabel", {
		Parent = sliderContainer,
		Size = UDim2.new(0, 60, 0, 18),
		Position = UDim2.new(1, -60, 0, 0),
		BackgroundTransparency = 1,
		Text = tostring(defaultValue),
		TextColor3 = theme.Main,
		TextSize = 11,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 15,
	})
	
	local sliderTrackHeight = Mobile.IsMobile and 8 or 6
	local sliderTrack = createInstance("Frame", {
		Parent = sliderContainer,
		Size = UDim2.new(1, -70, 0, sliderTrackHeight),
		Position = UDim2.new(0, 0, 0, 25),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 1,
		BorderColor3 = theme.Border,
		ZIndex = 15,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 2),
		Parent = sliderTrack,
	})
	
	local sliderFill = createInstance("Frame", {
		Parent = sliderTrack,
		Size = UDim2.new(0, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = theme.Main,
		BorderSizePixel = 0,
		ZIndex = 16,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 3),
		Parent = sliderFill,
	})
	
	local sliderButtonSize = Mobile.IsMobile and 24 or 18
	local sliderButton = createInstance("TextButton", {
		Parent = sliderTrack,
		Size = UDim2.new(0, sliderButtonSize, 0, sliderButtonSize),
		Position = UDim2.new(0, -sliderButtonSize / 2, 0, -(sliderButtonSize - sliderTrackHeight) / 2),
		BackgroundColor3 = theme.Text,
		BorderSizePixel = 0,
		Text = "",
		ZIndex = 17,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 9),
		Parent = sliderButton,
	})
	
	createInstance("UIStroke", {
		Parent = sliderButton,
		Color = theme.Main,
		Thickness = 2,
	})
	
	local dragging = false
	
	local function updateValue(value)
		value = math.clamp(value, min, max)
		value = math.floor((value - min) / step) * step + min
		
		local percentage = (value - min) / (max - min)
		local buttonOffset = Mobile.IsMobile and -12 or -9
		local buttonYOffset = Mobile.IsMobile and -8 or -6
		sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
		sliderButton.Position = UDim2.new(percentage, buttonOffset, 0, buttonYOffset)
		valueLabel.Text = tostring(value)
		
		self.Value = value
		callback(value)
	end
	
	updateValue(defaultValue)
	
	local function onInput(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end
	
	local function onInputChanged(input)
		if dragging then
			local mousePos = UserInputService:GetMouseLocation()
			local trackPos = sliderTrack.AbsolutePosition
			local trackSize = sliderTrack.AbsoluteSize
			
			local relativeX = math.clamp(mousePos.X - trackPos.X, 0, trackSize.X)
			local percentage = relativeX / trackSize.X
			local value = min + (max - min) * percentage
			
			updateValue(value)
		end
	end
	
	local function onInputEnded(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end
	
	sliderButton.InputBegan:Connect(onInput)
	sliderTrack.InputBegan:Connect(onInput)
	UserInputService.InputChanged:Connect(onInputChanged)
	UserInputService.InputEnded:Connect(onInputEnded)
	
	self.Instance = sliderContainer
	self.Value = defaultValue
	
	function self:GetValue()
		return self.Value
	end
	
	function self:SetValue(value)
		updateValue(value)
	end
	
	return self
end

-- Textbox Component
Textbox.__index = Textbox

function Textbox.new(section, options)
	local self = setmetatable({}, Textbox)
	
	local name = options.Name or "Textbox"
	local placeholder = options.Placeholder or "Enter text..."
	local defaultValue = options.Default or ""
	local callback = options.Callback or function() end
	
	local theme = Theme:GetTheme()
	
	local textboxContainer = createInstance("Frame", {
		Name = name,
		Parent = section.Content,
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundTransparency = 1,
		ZIndex = 14,
	})
	
	local label = createInstance("TextLabel", {
		Parent = textboxContainer,
		Size = UDim2.new(1, 0, 0, 15),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = theme.Text,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 15,
	})
	
	local textboxSize = Mobile.IsMobile and 40 or 30
	local textbox = createInstance("TextBox", {
		Parent = textboxContainer,
		Size = UDim2.new(1, 0, 0, textboxSize),
		Position = UDim2.new(0, 0, 0, 18),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 1,
		BorderColor3 = theme.Border,
		Text = defaultValue,
		PlaceholderText = placeholder,
		PlaceholderColor3 = theme.TextSecondary,
		TextColor3 = theme.Text,
		TextSize = Mobile.IsMobile and 13 or 12,
		Font = Enum.Font.Gotham,
		ClearTextOnFocus = false,
		ZIndex = 15,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = textbox,
	})
	
	textbox.Focused:Connect(function()
		textbox.BorderColor3 = theme.Main
		textbox.BackgroundColor3 = theme.SurfaceHover
	end)
	
	textbox.FocusLost:Connect(function()
		textbox.BorderColor3 = theme.Border
		textbox.BackgroundColor3 = theme.Surface
		callback(textbox.Text)
	end)
	
	self.Instance = textboxContainer
	self.Textbox = textbox
	self.Value = defaultValue
	
	function self:GetValue()
		return self.Textbox.Text
	end
	
	function self:SetValue(value)
		self.Textbox.Text = tostring(value)
		self.Value = value
		callback(value)
	end
	
	return self
end

-- Keybind Component
Keybind.__index = Keybind

function Keybind.new(section, options)
	local self = setmetatable({}, Keybind)
	
	local name = options.Name or "Keybind"
	local defaultValue = options.Default or Enum.KeyCode.Unknown
	local callback = options.Callback or function() end
	
	local theme = Theme:GetTheme()
	
	local keybindContainer = createInstance("Frame", {
		Name = name,
		Parent = section.Content,
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		ZIndex = 14,
	})
	
	local label = createInstance("TextLabel", {
		Parent = keybindContainer,
		Size = UDim2.new(1, -100, 1, 0),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = theme.Text,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 15,
	})
	
	local keybindSize = Mobile.IsMobile and 100 or 90
	local keybindHeight = Mobile.IsMobile and 35 or 30
	local keybindButton = createInstance("TextButton", {
		Parent = keybindContainer,
		Size = UDim2.new(0, keybindSize, 0, keybindHeight),
		Position = UDim2.new(1, -keybindSize, 0, 0),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 1,
		BorderColor3 = theme.Border,
		Text = defaultValue.Name or "None",
		TextColor3 = theme.Text,
		TextSize = Mobile.IsMobile and 12 or 11,
		Font = Enum.Font.Gotham,
		ZIndex = 15,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = keybindButton,
	})
	
	keybindButton.MouseEnter:Connect(function()
		keybindButton.BackgroundColor3 = theme.SurfaceHover
		keybindButton.BorderColor3 = theme.Main
	end)
	
	keybindButton.MouseLeave:Connect(function()
		if not listening then
			keybindButton.BackgroundColor3 = theme.Surface
			keybindButton.BorderColor3 = theme.Border
		end
	end)
	
	local listening = false
	
	local function startListening()
		listening = true
		keybindButton.Text = "..."
		keybindButton.BackgroundColor3 = theme.Main
		keybindButton.BorderColor3 = theme.Main
		
		local connection
		connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			
			if input.UserInputType == Enum.UserInputType.Keyboard then
				self.Value = input.KeyCode
				keybindButton.Text = input.KeyCode.Name
				keybindButton.BackgroundColor3 = theme.Surface
				keybindButton.BorderColor3 = theme.Border
				listening = false
				callback(input.KeyCode)
				connection:Disconnect()
			elseif input.KeyCode == Enum.KeyCode.Escape then
				keybindButton.Text = self.Value.Name or "None"
				keybindButton.BackgroundColor3 = theme.Surface
				keybindButton.BorderColor3 = theme.Border
				listening = false
				connection:Disconnect()
			end
		end)
	end
	
	keybindButton.MouseButton1Click:Connect(function()
		if not listening then
			startListening()
		end
	end)
	
	self.Instance = keybindContainer
	self.Value = defaultValue
	
	function self:GetValue()
		return self.Value
	end
	
	function self:SetValue(keyCode)
		self.Value = keyCode
		keybindButton.Text = keyCode.Name or "None"
		callback(keyCode)
	end
	
	return self
end

-- ColorPicker Component
ColorPicker.__index = ColorPicker

function ColorPicker.new(section, options)
	local self = setmetatable({}, ColorPicker)
	
	local name = options.Name or "ColorPicker"
	local defaultValue = options.Default or Color3.fromRGB(255, 255, 255)
	local callback = options.Callback or function() end
	
	local theme = Theme:GetTheme()
	
	local colorPickerContainer = createInstance("Frame", {
		Name = name,
		Parent = section.Content,
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		ZIndex = 14,
	})
	
	local label = createInstance("TextLabel", {
		Parent = colorPickerContainer,
		Size = UDim2.new(1, -80, 1, 0),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = theme.Text,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 15,
	})
	
	local colorButton = createInstance("TextButton", {
		Parent = colorPickerContainer,
		Size = UDim2.new(0, 70, 0, 30),
		Position = UDim2.new(1, -70, 0, 0),
		BackgroundColor3 = defaultValue,
		BorderSizePixel = 0,
		Text = "",
		ZIndex = 15,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = colorButton,
	})
	
	createInstance("UIStroke", {
		Parent = colorButton,
		Color = theme.TextSecondary,
		Thickness = 2,
	})
	
	local pickerFrame = createInstance("Frame", {
		Name = "ColorPickerFrame",
		Parent = colorPickerContainer,
		Size = UDim2.new(0, 200, 0, 200),
		Position = UDim2.new(1, -200, 0, 35),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 30,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = pickerFrame,
	})
	
	createInstance("UIStroke", {
		Parent = pickerFrame,
		Color = theme.Main,
		Thickness = 2,
	})
	
	local isOpen = false
	
	local colorCanvas = createInstance("ImageLabel", {
		Parent = pickerFrame,
		Size = UDim2.new(1, -60, 1, -40),
		Position = UDim2.new(0, 10, 0, 10),
		BackgroundColor3 = Color3.fromHSV(0, 1, 1),
		BorderSizePixel = 0,
		Image = "rbxassetid://2615689015",
		ZIndex = 31,
	})
	
	local brightnessSlider = createInstance("Frame", {
		Parent = pickerFrame,
		Size = UDim2.new(0, 20, 1, -40),
		Position = UDim2.new(1, -30, 0, 10),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 31,
	})
	
	createInstance("UIGradient", {
		Parent = brightnessSlider,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
		}),
		Rotation = 90,
	})
	
	local hueSlider = createInstance("Frame", {
		Parent = pickerFrame,
		Size = UDim2.new(0, 20, 1, -40),
		Position = UDim2.new(1, -50, 0, 10),
		BackgroundColor3 = Color3.new(1, 0, 0),
		BorderSizePixel = 0,
		ZIndex = 31,
	})
	
	local hueGradient = createInstance("UIGradient", {
		Parent = hueSlider,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
		}),
		Rotation = 90,
	})
	
	local hue, sat, val = defaultValue:ToHSV()
	
	local colorIndicator = createInstance("Frame", {
		Parent = colorCanvas,
		Size = UDim2.new(0, 10, 0, 10),
		Position = UDim2.new(sat, -5, 1 - val, -5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 2,
		BorderColor3 = Color3.new(0, 0, 0),
		ZIndex = 32,
	})
	
	createInstance("UICorner", {
		CornerRadius = UDim.new(0, 5),
		Parent = colorIndicator,
	})
	
	local brightnessIndicator = createInstance("Frame", {
		Parent = brightnessSlider,
		Size = UDim2.new(1, 0, 0, 4),
		Position = UDim2.new(0, 0, val, -2),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 2,
		BorderColor3 = Color3.new(0, 0, 0),
		ZIndex = 32,
	})
	
	local hueIndicator = createInstance("Frame", {
		Parent = hueSlider,
		Size = UDim2.new(1, 0, 0, 4),
		Position = UDim2.new(0, 0, hue, -2),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 2,
		BorderColor3 = Color3.new(0, 0, 0),
		ZIndex = 32,
	})
	
	local function updateColor(newHue, newSat, newVal)
		hue = math.clamp(newHue or hue, 0, 1)
		sat = math.clamp(newSat or sat, 0, 1)
		val = math.clamp(newVal or val, 0, 1)
		
		local color = Color3.fromHSV(hue, sat, val)
		colorButton.BackgroundColor3 = color
		colorCanvas.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		self.Value = color
		
		colorIndicator.Position = UDim2.new(sat, -5, 1 - val, -5)
		brightnessIndicator.Position = UDim2.new(0, 0, val, -2)
		hueIndicator.Position = UDim2.new(0, 0, hue, -2)
		
		callback(color)
	end
	
	local function onColorCanvasInput(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local mousePos = UserInputService:GetMouseLocation()
			local canvasPos = colorCanvas.AbsolutePosition
			local canvasSize = colorCanvas.AbsoluteSize
			
			local relativeX = math.clamp((mousePos.X - canvasPos.X) / canvasSize.X, 0, 1)
			local relativeY = math.clamp((mousePos.Y - canvasPos.Y) / canvasSize.Y, 0, 1)
			
			updateColor(hue, relativeX, 1 - relativeY)
		end
	end
	
	local function onBrightnessInput(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local mousePos = UserInputService:GetMouseLocation()
			local sliderPos = brightnessSlider.AbsolutePosition
			local sliderSize = brightnessSlider.AbsoluteSize
			
			local relativeY = math.clamp((mousePos.Y - sliderPos.Y) / sliderSize.Y, 0, 1)
			updateColor(hue, sat, relativeY)
		end
	end
	
	local function onHueInput(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local mousePos = UserInputService:GetMouseLocation()
			local sliderPos = hueSlider.AbsolutePosition
			local sliderSize = hueSlider.AbsoluteSize
			
			local relativeY = math.clamp((mousePos.Y - sliderPos.Y) / sliderSize.Y, 0, 1)
			updateColor(relativeY, sat, val)
		end
	end
	
	colorCanvas.InputBegan:Connect(onColorCanvasInput)
	colorCanvas.InputChanged:Connect(onColorCanvasInput)
	
	brightnessSlider.InputBegan:Connect(onBrightnessInput)
	brightnessSlider.InputChanged:Connect(onBrightnessInput)
	
	hueSlider.InputBegan:Connect(onHueInput)
	hueSlider.InputChanged:Connect(onHueInput)
	
	colorButton.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		pickerFrame.Visible = isOpen
	end)
	
	updateColor(hue, sat, val)
	
	self.Instance = colorPickerContainer
	self.Value = defaultValue
	
	function self:GetValue()
		return self.Value
	end
	
	function self:SetValue(color)
		self.Value = color
		colorButton.BackgroundColor3 = color
		callback(color)
	end
	
	return self
end

-- Library API
function Library:Window(options)
	return Window.new(options)
end

function Library:SetTheme(themeName)
	return Theme:SetTheme(themeName)
end

function Library:SetCustomTheme(themeTable)
	Theme:SetCustomTheme(themeTable)
end

function Library:SaveConfig(name, data)
	return Config:Save(name, data)
end

function Library:LoadConfig(name, silent)
	return Config:Load(name, silent)
end

function Library:DeleteConfig(name)
	return Config:Delete(name)
end

function Library:ShareConfig(name)
	return Config:Share(name)
end

function Library:ImportConfig(configString)
	return Config:Import(configString)
end

function Library:SetAutoSave(enabled)
	Config.AutoSave = enabled
	if enabled then
		debouncedSave()
	end
end

function Library:SetAutoLoad(enabled)
	Config.AutoLoad = enabled
	if enabled and Config.CurrentConfig then
		Config:Load(Config.CurrentConfig, Config.SilentLoad)
	end
end

function Library:SetSilentLoad(enabled)
	Config.SilentLoad = enabled
end

-- Return Library
return Library

