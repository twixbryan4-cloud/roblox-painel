-- Panel de demonstração inspirado na referência.
-- Use como LocalScript em StarterPlayer > StarterPlayerScripts.
-- Os botões são apenas visuais; não alteram mecânicas do jogo.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("ReferencePanelDemo")
if oldGui then oldGui:Destroy() end

-- Para usar a arte exata, coloque aqui o ID de uma imagem já enviada ao Roblox.
-- Exemplo: rbxassetid://1234567890. A captura da referência não é um asset de imagem.
local BACKGROUND_IMAGE = ""

local C = {
	ink = Color3.fromRGB(18, 15, 24),
	plum = Color3.fromRGB(39, 31, 49),
	plumLight = Color3.fromRGB(67, 53, 78),
	accent = Color3.fromRGB(200, 127, 218),
	white = Color3.fromRGB(245, 239, 248),
	muted = Color3.fromRGB(190, 180, 198),
	red = Color3.fromRGB(239, 82, 96),
	yellow = Color3.fromRGB(244, 195, 75),
	green = Color3.fromRGB(81, 190, 119),
}

local function round(instance, px)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, px)
	c.Parent = instance
	return c
end

local function outline(instance, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness
	s.Transparency = transparency
	s.Parent = instance
	return s
end

local function label(parent, text, size, color, xAlign)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = color or C.white
	t.Font = Enum.Font.Code
	t.TextSize = size
	t.TextXAlignment = xAlign or Enum.TextXAlignment.Left
	t.TextYAlignment = Enum.TextYAlignment.Center
	t.TextTruncate = Enum.TextTruncate.AtEnd
	t.Parent = parent
	return t
end

local gui = Instance.new("ScreenGui")
gui.Name = "ReferencePanelDemo"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromScale(0.92, 0.86)
panel.BackgroundColor3 = C.ink
panel.BackgroundTransparency = 1
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Parent = gui
round(panel, 22)
local border = outline(panel, Color3.fromRGB(138, 105, 179), 1.6, 0.16)

local art = Instance.new("ImageLabel")
art.Name = "BackgroundArtwork"
art.Size = UDim2.fromScale(1, 1)
art.BackgroundTransparency = 1
art.Image = BACKGROUND_IMAGE
art.ImageTransparency = 0.1
art.ScaleType = Enum.ScaleType.Crop
art.Visible = BACKGROUND_IMAGE ~= ""
art.ZIndex = 1
art.Parent = panel

local tint = Instance.new("Frame")
tint.Name = "GlassTint"
tint.Size = UDim2.fromScale(1, 1)
tint.BackgroundColor3 = C.ink
tint.BackgroundTransparency = 0.34
tint.BorderSizePixel = 0
tint.ZIndex = 2
tint.Parent = panel
local tintGradient = Instance.new("UIGradient")
tintGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(54, 40, 65)),
	ColorSequenceKeypoint.new(0.52, Color3.fromRGB(29, 24, 37)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 32, 52)),
})
tintGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.28),
	NumberSequenceKeypoint.new(0.5, 0.08),
	NumberSequenceKeypoint.new(1, 0.24),
})
tintGradient.Rotation = 12
tintGradient.Parent = tint

local header = Instance.new("Frame")
header.Name = "TitleBar"
header.Size = UDim2.new(1, 0, 0, 58)
header.BackgroundColor3 = C.ink
header.BackgroundTransparency = 0.38
header.BorderSizePixel = 0
header.ZIndex = 3
header.Parent = panel
local headerLine = Instance.new("Frame")
headerLine.Position = UDim2.new(0, 0, 1, -1)
headerLine.Size = UDim2.new(1, 0, 0, 1)
headerLine.BackgroundColor3 = C.accent
headerLine.BackgroundTransparency = 0.5
headerLine.BorderSizePixel = 0
headerLine.ZIndex = 4
headerLine.Parent = header

local traffic = Instance.new("Frame")
traffic.BackgroundTransparency = 1
traffic.Position = UDim2.new(0, 18, 0, 0)
traffic.Size = UDim2.new(0, 66, 1, 0)
traffic.ZIndex = 5
traffic.Parent = header
local dots = Instance.new("UIListLayout")
dots.FillDirection = Enum.FillDirection.Horizontal
dots.VerticalAlignment = Enum.VerticalAlignment.Center
dots.Padding = UDim.new(0, 7)
dots.Parent = traffic

local brand = label(header, "Velaware", 13, C.white, Enum.TextXAlignment.Center)
brand.TextXAlignment = Enum.TextXAlignment.Left
brand.Position = UDim2.new(0, 106, 0, 7)
brand.Size = UDim2.new(0.28, 0, 0, 20)
brand.ZIndex = 5
local gameName = label(header, "murder mystery 2", 10, C.muted, Enum.TextXAlignment.Center)
gameName.TextXAlignment = Enum.TextXAlignment.Left
gameName.Position = UDim2.new(0, 106, 0, 29)
gameName.Size = UDim2.new(0.28, 0, 0, 16)
gameName.ZIndex = 5
local teamLabel = label(header, "Change Team", 10, C.muted, Enum.TextXAlignment.Right)
teamLabel.AnchorPoint = Vector2.new(1, 0.5)
teamLabel.Position = UDim2.new(1, -17, 0.5, 0)
teamLabel.Size = UDim2.new(0, 94, 0, 18)
teamLabel.ZIndex = 5

local body = Instance.new("Frame")
body.Name = "Body"
body.Position = UDim2.new(0, 0, 0, 59)
body.Size = UDim2.new(1, 0, 1, -59)
body.BackgroundTransparency = 1
body.ZIndex = 3
body.Parent = panel

local sidebar = Instance.new("Frame")
sidebar.Name = "Categories"
sidebar.Position = UDim2.new(0, 12, 0, 11)
sidebar.Size = UDim2.new(0.29, -15, 1, -22)
sidebar.BackgroundTransparency = 1
sidebar.ZIndex = 4
sidebar.Parent = body
local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 7)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Parent = sidebar

local content = Instance.new("Frame")
content.Name = "Options"
content.Position = UDim2.new(0.30, 2, 0, 9)
content.Size = UDim2.new(0.70, -16, 1, -18)
content.BackgroundTransparency = 1
content.ZIndex = 4
content.Parent = body

local list = Instance.new("ScrollingFrame")
list.Name = "OptionList"
list.Size = UDim2.fromScale(1, 1)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 2
list.ScrollBarImageColor3 = C.accent
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.ScrollingDirection = Enum.ScrollingDirection.Y
list.ZIndex = 4
list.Parent = content
local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0, 6)
pad.PaddingRight = UDim.new(0, 8)
pad.PaddingTop = UDim.new(0, 7)
pad.PaddingBottom = UDim.new(0, 8)
pad.Parent = list
local optionLayout = Instance.new("UIListLayout")
optionLayout.Padding = UDim.new(0, 4)
optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
optionLayout.Parent = list

local categoryButtons = {}
local pages = {
	Main = {
		{section = "Combat"},
		{title = "Botão de exemplo 01", desc = "Apenas demonstração visual"},
		{title = "Botão de exemplo 02", desc = "Apenas demonstração visual"},
		{section = "Player"},
		{title = "Botão de exemplo 03", desc = "Apenas demonstração visual"},
		{title = "Botão de exemplo 04", desc = "Apenas demonstração visual"},
	},
	Misc = {
		{section = "Misc"},
		{title = "Botão de exemplo 01", desc = "Apenas demonstração visual"},
		{title = "Botão de exemplo 02", desc = "Apenas demonstração visual"},
		{title = "Botão de exemplo 03", desc = "Apenas demonstração visual"},
	},
}

local function clearOptions()
	for _, child in ipairs(list:GetChildren()) do
		if child.Name == "SectionHeading" or child.Name == "DemoOption" or child.Name == "OptionDivider" then
			child:Destroy()
		end
	end
	list.CanvasPosition = Vector2.zero
end

local function addSection(title, order)
	local heading = label(list, title, 13, C.white)
	heading.Name = "SectionHeading"
	heading.LayoutOrder = order
	heading.Size = UDim2.new(1, -5, 0, 29)
	heading.ZIndex = 5
	local icon = Instance.new("TextLabel")
	icon.Name = "SectionIcon"
	icon.BackgroundTransparency = 1
	icon.Text = title == "Combat" and "◎" or (title == "Player" and "♙" or "✣")
	icon.TextColor3 = C.muted
	icon.Font = Enum.Font.Code
	icon.TextSize = 17
	icon.Size = UDim2.new(0, 23, 1, 0)
	icon.Position = UDim2.new(0, 0, 0, 0)
	icon.ZIndex = 5
	icon.Parent = heading
	heading.Position = UDim2.new(0, 27, 0, 0)
	return heading
end

local function addOption(item, order)
	local row = Instance.new("Frame")
	row.Name = "DemoOption"
	row.LayoutOrder = order
	row.Size = UDim2.new(1, -5, 0, 57)
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	row.ZIndex = 5
	row.Parent = list

	local title = label(row, item.title, 13, C.white)
	title.Position = UDim2.new(0, 29, 0, 4)
	title.Size = UDim2.new(1, -98, 0, 21)
	title.ZIndex = 5
	local desc = label(row, item.desc, 10, C.muted)
	desc.Position = UDim2.new(0, 29, 0, 27)
	desc.Size = UDim2.new(1, -98, 0, 18)
	desc.ZIndex = 5

	local toggle = Instance.new("TextButton")
	toggle.Name = "DemoToggle"
	toggle.AnchorPoint = Vector2.new(1, 0.5)
	toggle.Position = UDim2.new(1, -4, 0.5, 0)
	toggle.Size = UDim2.fromOffset(43, 22)
	toggle.BackgroundColor3 = Color3.fromRGB(77, 68, 86)
	toggle.BackgroundTransparency = 0.34
	toggle.BorderSizePixel = 0
	toggle.Text = ""
	toggle.AutoButtonColor = false
	toggle.ZIndex = 6
	toggle.Parent = row
	round(toggle, 20)
	local toggleStroke = outline(toggle, Color3.fromRGB(206, 190, 217), 1, 0.62)

	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.Size = UDim2.fromOffset(16, 16)
	knob.Position = UDim2.new(0, 3, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(231, 222, 236)
	knob.BorderSizePixel = 0
	knob.ZIndex = 7
	knob.Parent = toggle
	round(knob, 20)

	local enabled = false
	toggle.Activated:Connect(function()
		enabled = not enabled
		TweenService:Create(toggle, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = enabled and C.accent or Color3.fromRGB(77, 68, 86),
			BackgroundTransparency = enabled and 0.12 or 0.34,
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
			BackgroundColor3 = enabled and Color3.new(1, 1, 1) or Color3.fromRGB(231, 222, 236),
		}):Play()
		toggleStroke.Color = enabled and C.accent or Color3.fromRGB(206, 190, 217)
	end)

	local divider = Instance.new("Frame")
	divider.Name = "OptionDivider"
	divider.LayoutOrder = order + 1
	divider.Size = UDim2.new(1, -7, 0, 1)
	divider.BackgroundColor3 = C.muted
	divider.BackgroundTransparency = 0.82
	divider.BorderSizePixel = 0
	divider.ZIndex = 5
	divider.Parent = list
end

local function showCategory(name)
	clearOptions()
	for index, item in ipairs(pages[name]) do
		if item.section then
			addSection(item.section, index * 2)
		else
			addOption(item, index * 2)
		end
	end
	for category, button in pairs(categoryButtons) do
		local active = category == name
		button.BackgroundColor3 = active and C.plumLight or C.ink
		local targetColor = active and C.plumLight or C.ink
		local targetTransparency = active and 0.48 or 0.78
		TweenService:Create(button, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = targetColor,
			BackgroundTransparency = targetTransparency,
			TextColor3 = active and C.white or C.muted,
		}):Play()
		local icon = button:FindFirstChild("CategoryIcon")
		if icon then
			TweenService:Create(icon, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextColor3 = active and C.white or C.muted,
			}):Play()
		end
		local categoryName = button:FindFirstChild("CategoryName")
		if categoryName then
			TweenService:Create(categoryName, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextColor3 = active and C.white or C.muted,
			}):Play()
		end
	end
end

local function makeCategory(name, iconText, order)
	local button = Instance.new("TextButton")
	button.Name = name .. "Category"
	button.LayoutOrder = order
	button.Size = UDim2.new(1, 0, 0, 52)
	button.BackgroundColor3 = C.ink
	button.BackgroundTransparency = 0.7
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = false
	button.ZIndex = 5
	button.Parent = sidebar
	round(button, 10)
	local icon = label(button, iconText, 17, C.muted, Enum.TextXAlignment.Center)
	icon.Name = "CategoryIcon"
	icon.Position = UDim2.new(0, 9, 0, 0)
	icon.Size = UDim2.new(0, 29, 1, 0)
	icon.ZIndex = 6
	local title = label(button, name, 13, C.muted)
	title.Name = "CategoryName"
	title.Position = UDim2.new(0, 43, 0, 0)
	title.Size = UDim2.new(1, -49, 1, 0)
	title.ZIndex = 6
	categoryButtons[name] = button
	button.Activated:Connect(function() showCategory(name) end)
end

makeCategory("Main", "⌂", 1)
makeCategory("Misc", "✣", 2)
showCategory("Main")

local function addDot(color, name, action)
	local dot = Instance.new("TextButton")
	dot.Name = name
	dot.Size = UDim2.fromOffset(13, 13)
	dot.BackgroundColor3 = color
	dot.BorderSizePixel = 0
	dot.Text = ""
	dot.AutoButtonColor = false
	dot.ZIndex = 6
	dot.Parent = traffic
	round(dot, 20)
	dot.Activated:Connect(action)
	return dot
end

addDot(C.red, "Close", function() gui:Destroy() end)
addDot(C.yellow, "Minimize", function()
	panel.Visible = false
	local reopen = Instance.new("TextButton")
	reopen.Name = "ReopenPanel"
	reopen.Size = UDim2.fromOffset(48, 48)
	reopen.Position = UDim2.new(0, 18, 0.5, -24)
	reopen.BackgroundColor3 = C.plum
	reopen.BackgroundTransparency = 0.28
	reopen.Text = "V"
	reopen.TextColor3 = C.accent
	reopen.Font = Enum.Font.Code
	reopen.TextSize = 19
	reopen.AutoButtonColor = false
	reopen.Parent = gui
	round(reopen, 14)
	outline(reopen, C.accent, 1.4, 0.18)
	reopen.Activated:Connect(function()
		reopen:Destroy()
		panel.Visible = true
	end)
end)
addDot(C.green, "Reset", function()
	panel.Position = UDim2.fromScale(0.5, 0.5)
	showCategory("Main")
end)

-- Arrasta pelo topo com mouse ou toque.
local dragging, dragInput, dragStart, startPosition = false, nil, nil, nil
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
	if camera.ViewportSize.X < camera.ViewportSize.Y then
		panel.Size = UDim2.fromScale(0.94, 0.70)
		sidebar.Size = UDim2.new(0.30, -15, 1, -22)
		content.Position = UDim2.new(0.31, 2, 0, 9)
		content.Size = UDim2.new(0.69, -16, 1, -18)
	else
		panel.Size = UDim2.fromScale(0.92, 0.86)
		sidebar.Size = UDim2.new(0.29, -15, 1, -22)
		content.Position = UDim2.new(0.30, 2, 0, 9)
		content.Size = UDim2.new(0.70, -16, 1, -18)
	end
end
fitToViewport()
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitToViewport)
end

-- Entrada curta e animações apenas ao interagir; sem loops contínuos.
tint.BackgroundTransparency = 1
TweenService:Create(tint, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	BackgroundTransparency = 0.34,
}):Play()
