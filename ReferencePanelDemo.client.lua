--[[
    VelaWare-style panel demo
    Place this LocalScript in StarterPlayer > StarterPlayerScripts.
    The sample switches only change their own visual state; they do not
    run gameplay actions.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("ReferencePanelDemo")
if oldGui then
	oldGui:Destroy()
end

local COLORS = {
	panel = Color3.fromRGB(23, 20, 31),
	panelLight = Color3.fromRGB(38, 32, 48),
	row = Color3.fromRGB(34, 29, 43),
	rowHover = Color3.fromRGB(46, 38, 57),
	accent = Color3.fromRGB(198, 105, 214),
	accentLight = Color3.fromRGB(235, 153, 224),
	text = Color3.fromRGB(247, 240, 250),
	muted = Color3.fromRGB(177, 165, 188),
	green = Color3.fromRGB(92, 196, 125),
	red = Color3.fromRGB(239, 93, 104),
	yellow = Color3.fromRGB(242, 199, 83),
}

local function corner(parent, radius)
	local item = Instance.new("UICorner")
	item.CornerRadius = UDim.new(0, radius)
	item.Parent = parent
	return item
end

local function stroke(parent, color, thickness, transparency)
	local item = Instance.new("UIStroke")
	item.Color = color
	item.Thickness = thickness
	item.Transparency = transparency or 0
	item.Parent = parent
	return item
end

local function textLabel(parent, text, size, color, font, align)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or COLORS.text
	label.Font = font or Enum.Font.Arcade
	label.TextSize = size
	label.TextXAlignment = align or Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = parent
	return label
end

local gui = Instance.new("ScreenGui")
gui.Name = "ReferencePanelDemo"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Window"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.51)
panel.Size = UDim2.fromScale(0.84, 0.84)
panel.BackgroundColor3 = COLORS.panel
panel.BackgroundTransparency = 0.28
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Parent = gui
corner(panel, 18)
local panelStroke = stroke(panel, Color3.fromRGB(126, 93, 161), 1.5, 0.12)

local panelGradient = Instance.new("UIGradient")
panelGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(37, 29, 48)),
	ColorSequenceKeypoint.new(0.55, Color3.fromRGB(24, 21, 32)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(33, 25, 40)),
})
panelGradient.Rotation = 18
panelGradient.Parent = panel

local header = Instance.new("Frame")
header.Name = "TitleBar"
header.Size = UDim2.new(1, 0, 0, 58)
header.BackgroundColor3 = Color3.fromRGB(28, 23, 37)
header.BackgroundTransparency = 0.05
header.BorderSizePixel = 0
header.Parent = panel
local headerLine = Instance.new("Frame")
headerLine.Position = UDim2.new(0, 0, 1, -1)
headerLine.Size = UDim2.new(1, 0, 0, 1)
headerLine.BackgroundColor3 = COLORS.accent
headerLine.BackgroundTransparency = 0.55
headerLine.BorderSizePixel = 0
headerLine.Parent = header

local traffic = Instance.new("Frame")
traffic.BackgroundTransparency = 1
traffic.Position = UDim2.new(0, 16, 0, 0)
traffic.Size = UDim2.new(0, 70, 1, 0)
traffic.Parent = header
local trafficLayout = Instance.new("UIListLayout")
trafficLayout.FillDirection = Enum.FillDirection.Horizontal
trafficLayout.VerticalAlignment = Enum.VerticalAlignment.Center
trafficLayout.Padding = UDim.new(0, 7)
trafficLayout.Parent = traffic

local function trafficLight(color, name, action)
	local dot = Instance.new("TextButton")
	dot.Name = name
	dot.Size = UDim2.fromOffset(13, 13)
	dot.BackgroundColor3 = color
	dot.Text = ""
	dot.AutoButtonColor = false
	dot.Parent = traffic
	corner(dot, 20)
	if action then dot.Activated:Connect(action) end
	return dot
end

local brand = textLabel(header, "VelaWare", 16, COLORS.text, Enum.Font.Arcade, Enum.TextXAlignment.Center)
brand.AnchorPoint = Vector2.new(0.5, 0)
brand.Position = UDim2.new(0.5, 0, 0, 7)
brand.Size = UDim2.new(0.42, 0, 0, 22)
local gameName = textLabel(header, "murder mystery 2", 10, COLORS.muted, Enum.Font.Code, Enum.TextXAlignment.Center)
gameName.AnchorPoint = Vector2.new(0.5, 0)
gameName.Position = UDim2.new(0.5, 0, 0, 29)
gameName.Size = UDim2.new(0.42, 0, 0, 16)
local teamLabel = textLabel(header, "Change Team", 10, COLORS.muted, Enum.Font.Code, Enum.TextXAlignment.Right)
teamLabel.AnchorPoint = Vector2.new(1, 0.5)
teamLabel.Position = UDim2.new(1, -17, 0.5, 0)
teamLabel.Size = UDim2.new(0, 105, 0, 18)

local body = Instance.new("Frame")
body.Name = "Body"
body.Position = UDim2.new(0, 0, 0, 59)
body.Size = UDim2.new(1, 0, 1, -59)
body.BackgroundTransparency = 1
body.Parent = panel

local sidebar = Instance.new("Frame")
sidebar.Name = "Categories"
sidebar.Position = UDim2.new(0, 10, 0, 12)
sidebar.Size = UDim2.new(0.25, -15, 1, -24)
sidebar.BackgroundTransparency = 1
sidebar.Parent = body
local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 7)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Parent = sidebar

local content = Instance.new("Frame")
content.Name = "Content"
content.Position = UDim2.new(0.25, 3, 0, 10)
content.Size = UDim2.new(0.75, -17, 1, -20)
content.BackgroundTransparency = 1
content.Parent = body

local list = Instance.new("ScrollingFrame")
list.Name = "DemoOptions"
list.Position = UDim2.new(0, 0, 0, 0)
list.Size = UDim2.new(1, 0, 1, 0)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.ScrollBarImageColor3 = COLORS.accent
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.ScrollingDirection = Enum.ScrollingDirection.Y
list.Parent = content
local listPadding = Instance.new("UIPadding")
listPadding.PaddingLeft = UDim.new(0, 3)
listPadding.PaddingRight = UDim.new(0, 4)
listPadding.PaddingTop = UDim.new(0, 4)
listPadding.PaddingBottom = UDim.new(0, 5)
listPadding.Parent = list
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 7)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = list

local currentCategory = "Main"
local categoryButtons = {}

local function clearOptions()
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
end

local function addSection(title, order)
	local heading = textLabel(list, title, 12, COLORS.accentLight, Enum.Font.Arcade)
	heading.Name = "Section_" .. title
	heading.LayoutOrder = order
	heading.Size = UDim2.new(1, -6, 0, 25)
	return heading
end

local function addDemoToggle(title, description, order)
	local row = Instance.new("Frame")
	row.Name = "DemoOption"
	row.LayoutOrder = order
	row.Size = UDim2.new(1, -6, 0, 56)
	row.BackgroundColor3 = COLORS.row
	row.BackgroundTransparency = 0.08
	row.BorderSizePixel = 0
	row.Parent = list
	corner(row, 9)

	local rowLine = stroke(row, Color3.fromRGB(126, 102, 148), 1, 0.76)
	local titleLabel = textLabel(row, title, 12, COLORS.text, Enum.Font.Arcade)
	titleLabel.Position = UDim2.new(0, 12, 0, 7)
	titleLabel.Size = UDim2.new(1, -108, 0, 19)
	local descLabel = textLabel(row, description, 10, COLORS.muted, Enum.Font.Code)
	descLabel.Position = UDim2.new(0, 12, 0, 29)
	descLabel.Size = UDim2.new(1, -108, 0, 17)

	local toggle = Instance.new("TextButton")
	toggle.Name = "DemoToggle"
	toggle.AnchorPoint = Vector2.new(1, 0.5)
	toggle.Position = UDim2.new(1, -10, 0.5, 0)
	toggle.Size = UDim2.fromOffset(70, 28)
	toggle.BackgroundColor3 = Color3.fromRGB(68, 61, 77)
	toggle.Text = "OFF"
	toggle.TextColor3 = COLORS.text
	toggle.Font = Enum.Font.Code
	toggle.TextSize = 11
	toggle.AutoButtonColor = false
	toggle.Parent = row
	corner(toggle, 16)
	local toggleStroke = stroke(toggle, Color3.fromRGB(181, 164, 193), 1, 0.66)

	local enabled = false
	toggle.Activated:Connect(function()
		enabled = not enabled
		toggle.Text = enabled and "ON" or "OFF"
		local target = enabled and COLORS.accent or Color3.fromRGB(68, 61, 77)
		TweenService:Create(toggle, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = target,
		}):Play()
		toggleStroke.Color = enabled and COLORS.accentLight or Color3.fromRGB(181, 164, 193)
	end)

	row.MouseEnter:Connect(function()
		TweenService:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = COLORS.rowHover }):Play()
	end)
	row.MouseLeave:Connect(function()
		TweenService:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = COLORS.row }):Play()
	end)
	return row
end

local pages = {
	Main = {
		{kind="section", title="Combat"},
		{kind="toggle", title="Botão de exemplo 01", description="Apenas demonstração visual"},
		{kind="toggle", title="Botão de exemplo 02", description="Apenas demonstração visual"},
		{kind="section", title="Player"},
		{kind="toggle", title="Botão de exemplo 03", description="Apenas demonstração visual"},
		{kind="toggle", title="Botão de exemplo 04", description="Apenas demonstração visual"},
	},
	Misc = {
		{kind="section", title="Misc"},
		{kind="toggle", title="Botão de exemplo 01", description="Apenas demonstração visual"},
		{kind="toggle", title="Botão de exemplo 02", description="Apenas demonstração visual"},
		{kind="toggle", title="Botão de exemplo 03", description="Apenas demonstração visual"},
	},
}

local function showCategory(name)
	currentCategory = name
	clearOptions()
	for index, item in ipairs(pages[name]) do
		if item.kind == "section" then
			addSection(item.title, index)
		else
			addDemoToggle(item.title, item.description, index)
		end
	end
	for category, button in pairs(categoryButtons) do
		local active = category == name
		button.BackgroundColor3 = active and Color3.fromRGB(60, 46, 71) or Color3.fromRGB(33, 29, 39)
		button.BackgroundTransparency = active and 0.05 or 0.35
		button.TextColor3 = active and COLORS.text or COLORS.muted
	end
end

local function makeCategory(name, icon, order)
	local button = Instance.new("TextButton")
	button.Name = name .. "Category"
	button.LayoutOrder = order
	button.Size = UDim2.new(1, 0, 0, 55)
	button.BackgroundColor3 = Color3.fromRGB(33, 29, 39)
	button.BackgroundTransparency = 0.35
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = sidebar
	corner(button, 9)
	local iconLabel = textLabel(button, icon, 20, COLORS.text, Enum.Font.Code, Enum.TextXAlignment.Center)
	iconLabel.Position = UDim2.new(0, 8, 0, 0)
	iconLabel.Size = UDim2.new(0, 31, 1, 0)
	local nameLabel = textLabel(button, name, 12, COLORS.muted, Enum.Font.Arcade)
	nameLabel.Position = UDim2.new(0, 43, 0, 0)
	nameLabel.Size = UDim2.new(1, -48, 1, 0)
	categoryButtons[name] = button
	button.Activated:Connect(function() showCategory(name) end)
	return button
end

makeCategory("Main", "⌂", 1)
makeCategory("Misc", "✿", 2)
showCategory(currentCategory)

trafficLight(COLORS.red, "Close", function()
	gui:Destroy()
end)
trafficLight(COLORS.yellow, "Hide", function()
	panel.Visible = false
	local reopen = Instance.new("TextButton")
	reopen.Name = "ReopenPanel"
	reopen.Size = UDim2.fromOffset(48, 48)
	reopen.Position = UDim2.new(0, 18, 0.5, -24)
	reopen.BackgroundColor3 = COLORS.panelLight
	reopen.Text = "V"
	reopen.TextColor3 = COLORS.accentLight
	reopen.Font = Enum.Font.Arcade
	reopen.TextSize = 20
	reopen.AutoButtonColor = false
	reopen.Parent = gui
	corner(reopen, 14)
	stroke(reopen, COLORS.accent, 1.5, 0.15)
	reopen.Activated:Connect(function()
		reopen:Destroy()
		panel.Visible = true
	end)
end)
trafficLight(COLORS.green, "Reset", function()
	panel.Position = UDim2.fromScale(0.5, 0.51)
	showCategory("Main")
end)

-- Drag by the title bar on mouse or touch.
local dragging = false
local dragInput
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPosition = panel.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		local delta = input.Position - dragStart
		panel.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
			startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
	end
end)

local function fitToViewport()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local viewport = camera.ViewportSize
	if viewport.X < viewport.Y then
		panel.Size = UDim2.fromScale(0.94, 0.68)
		sidebar.Size = UDim2.new(0.27, -14, 1, -24)
		content.Position = UDim2.new(0.27, 3, 0, 10)
		content.Size = UDim2.new(0.73, -17, 1, -20)
	else
		panel.Size = UDim2.fromScale(0.84, 0.84)
		sidebar.Size = UDim2.new(0.25, -15, 1, -24)
		content.Position = UDim2.new(0.25, 3, 0, 10)
		content.Size = UDim2.new(0.75, -17, 1, -20)
	end
end

fitToViewport()
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitToViewport)
end

-- Small entrance fade; no perpetual animation loops.
panel.BackgroundTransparency = 1
panelStroke.Transparency = 1
TweenService:Create(panel, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	BackgroundTransparency = 0.28,
}):Play()
TweenService:Create(panelStroke, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	Transparency = 0.12,
}):Play()
