-- NOVA / Camera Panel v1.1
-- LocalScript: StarterPlayer > StarterPlayerScripts.
-- Um arquivo, sem imagens remotas, sem inputs virtuais e sem pulo automatico.
-- Ajusta o giro da camera com APIs publicas, sem exigir PlayerModule/CameraInput.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
    warn("[NOVA] Use este arquivo em um LocalScript no cliente.")
    return
end

local player = Players.LocalPlayer
if not player then return end
local playerGui = player:WaitForChild("PlayerGui")
local GUI_NAME = "NovaCameraPanel"
local MIN_SENSITIVITY, MAX_SENSITIVITY, STEP = 0.25, 3, 0.05
local initialSensitivity = 1

-- Reexecutar substitui a instancia anterior e restaura sua integracao de camera.
local previous = playerGui:FindFirstChild(GUI_NAME)
if previous then
    local saved = previous:GetAttribute("Sensitivity")
    if type(saved) == "number" and saved == saved then
        initialSensitivity = math.clamp(saved, MIN_SENSITIVITY, MAX_SENSITIVITY)
    end
    local teardown = previous:FindFirstChild("Teardown")
    if teardown and teardown:IsA("BindableEvent") then teardown:Fire() end
    previous:Destroy()
end

local C = {
    background = Color3.fromRGB(19, 24, 38),
    surface = Color3.fromRGB(31, 39, 59),
    line = Color3.fromRGB(83, 102, 137),
    text = Color3.fromRGB(238, 243, 255),
    muted = Color3.fromRGB(214, 225, 244),
    cyan = Color3.fromRGB(113, 225, 244),
    purple = Color3.fromRGB(171, 151, 255),
    green = Color3.fromRGB(124, 227, 184),
    amber = Color3.fromRGB(240, 196, 128),
}
local alive, booting, opened, cameraReady = true, true, false, false
local sensitivity = initialSensitivity
local connections, activeTweens, pendingTasks = {}, {}, {}
local restoreCamera
local updateCameraBinding
local transitionId = 0
local drag, sliderPointer
local lastFloatingDrag = -math.huge

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    connections[#connections + 1] = connection
    return connection
end

local function cancelTween(object)
    local item = activeTweens[object]
    if item then
        activeTweens[object] = nil
        item.connection:Disconnect()
        item.tween:Cancel()
    end
end

local function animate(object, properties, duration, completed)
    cancelTween(object)
    if not alive then return end
    local tween = TweenService:Create(object,
        TweenInfo.new(duration or 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties)
    local item = { tween = tween }
    item.connection = tween.Completed:Connect(function(state)
        if activeTweens[object] ~= item then return end
        activeTweens[object] = nil
        item.connection:Disconnect()
        if alive and state == Enum.PlaybackState.Completed and completed then completed() end
    end)
    activeTweens[object] = item
    tween:Play()
end

local function later(seconds, callback)
    local thread
    thread = task.delay(seconds, function()
        if alive then callback() end
        pendingTasks[thread] = nil
    end)
    pendingTasks[thread] = true
    return thread
end

local function make(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do object[property] = value end
    object.Parent = parent
    return object
end

local function round(parent, radius)
    return make("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function stroke(parent, color, transparency, thickness)
    return make("UIStroke", {
        Color = color or C.line, Transparency = transparency or 0.4,
        Thickness = thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function text(parent, value, size, color, position, dimensions, font)
    return make("TextLabel", {
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Text = value, TextSize = size, TextColor3 = color or C.text,
        Font = font or Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center, Position = position,
        Size = dimensions, TextTruncate = Enum.TextTruncate.AtEnd,
    }, parent)
end

local function gradient(parent, first, last, rotation)
    -- Em CanvasGroup, UIGradient tinge o resultado inteiro, inclusive as letras.
    assert(not parent:IsA("CanvasGroup"), "Aplique o gradiente em um Frame de fundo.")
    return make("UIGradient", {
        Color = ColorSequence.new(first, last), Rotation = rotation or 0,
    }, parent)
end

local function backdrop(group, radius)
    local background = make("Frame", {
        Name = "Background", BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.26, BorderSizePixel = 0, ZIndex = 0,
        Size = UDim2.fromScale(1, 1), Active = false,
    }, group)
    round(background, radius)
    gradient(background, Color3.fromRGB(33, 43, 65), Color3.fromRGB(17, 23, 38), 65)
    return background
end

local function button(parent, name, position, size)
    return make("TextButton", {
        Name = name, Text = "", AutoButtonColor = false,
        BackgroundColor3 = C.surface, BorderSizePixel = 0,
        Position = position, Size = size,
    }, parent)
end

local function brand(parent, position, size)
    local logo = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(30, 48, 66), BorderSizePixel = 0,
        Position = position, Size = UDim2.fromOffset(size, size),
    }, parent)
    round(logo, math.floor(size * 0.3))
    gradient(logo, Color3.fromRGB(33, 67, 83), Color3.fromRGB(48, 37, 77), 45)
    stroke(logo, C.cyan, 0.65)
    local letter = text(logo, "N", math.floor(size * 0.63), C.text,
        UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Enum.Font.GothamBold)
    letter.TextXAlignment = Enum.TextXAlignment.Center
    gradient(letter, C.cyan, C.purple, 40)
    return logo
end

local gui = make("ScreenGui", {
    Name = GUI_NAME, ResetOnSpawn = false, IgnoreGuiInset = false,
    DisplayOrder = 1000, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)
gui:SetAttribute("Sensitivity", sensitivity)
local teardown = make("BindableEvent", { Name = "Teardown" }, gui)
local root = make("Frame", {
    Name = "Canvas", BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1), Active = false,
}, gui)

local function cleanup()
    if not alive then return end
    alive = false
    drag, sliderPointer = nil, nil
    for _, connection in ipairs(connections) do connection:Disconnect() end
    for object in pairs(activeTweens) do cancelTween(object) end
    for thread in pairs(pendingTasks) do
        if thread ~= coroutine.running() then pcall(task.cancel, thread) end
    end
    if restoreCamera then restoreCamera() end
    connections, pendingTasks = {}, {}
end
connect(gui.Destroying, cleanup)
connect(teardown.Event, function() cleanup(); gui:Destroy() end)
if typeof(script) == "Instance" and script:IsA("LocalScript") then
    connect(script.Destroying, function() cleanup(); gui:Destroy() end)
end

local panel = make("CanvasGroup", {
    Name = "Panel", AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C.background, BackgroundTransparency = 1,
    BorderSizePixel = 0, Size = UDim2.fromOffset(500, 394),
    GroupColor3 = Color3.new(1, 1, 1), GroupTransparency = 1, Visible = false,
}, root)
round(panel, 22)
stroke(panel, C.line, 0.2)
backdrop(panel, 22)
local panelScale = make("UIScale", { Scale = 0.96 }, panel)
local accent = make("Frame", {
    BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
    Position = UDim2.fromOffset(24, 0), Size = UDim2.new(1, -48, 0, 2),
}, panel)
local accentGradient = gradient(accent, C.cyan, C.purple)
accentGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.25, 0.1),
    NumberSequenceKeypoint.new(0.75, 0.1), NumberSequenceKeypoint.new(1, 1),
})

local header = make("Frame", {
    Name = "DragHandle", BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 74), Active = true,
}, panel)
brand(header, UDim2.fromOffset(22, 20), 36)
text(header, "NOVA", 18, C.text, UDim2.fromOffset(70, 20),
    UDim2.fromOffset(72, 22), Enum.Font.GothamBold)
text(header, "by askzedd", 11, C.muted, UDim2.fromOffset(70, 43),
    UDim2.fromOffset(120, 14))
local free = text(header, "FREE", 9, C.purple, UDim2.fromOffset(140, 23),
    UDim2.fromOffset(40, 18), Enum.Font.GothamBold)
free.BackgroundTransparency = 0.1
free.BackgroundColor3 = Color3.fromRGB(41, 34, 65)
free.TextXAlignment = Enum.TextXAlignment.Center
round(free, 6)
local device = text(header, "PC", 9, C.muted, UDim2.new(1, -137, 0, 28),
    UDim2.fromOffset(62, 23), Enum.Font.GothamMedium)
device.BackgroundTransparency = 0.4
device.BackgroundColor3 = C.surface
device.TextXAlignment = Enum.TextXAlignment.Center
round(device, 7)
local minimize = button(header, "Recolher", UDim2.new(1, -64, 0, 17),
    UDim2.fromOffset(44, 44))
minimize.BackgroundTransparency = 0.45
round(minimize, 12)
local minus = make("Frame", {
    BackgroundColor3 = C.muted, BorderSizePixel = 0,
    Position = UDim2.fromOffset(15, 21), Size = UDim2.fromOffset(14, 2),
}, minimize)
round(minus, 1)
make("Frame", {
    BackgroundColor3 = C.line, BackgroundTransparency = 0.6, BorderSizePixel = 0,
    Position = UDim2.fromOffset(22, 74), Size = UDim2.new(1, -44, 0, 1),
}, panel)

local body = make("ScrollingFrame", {
    Name = "Controls", BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.fromOffset(22, 90), Size = UDim2.new(1, -44, 1, -138),
    CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Active = true,
    ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 2,
    ScrollBarImageColor3 = C.purple, ScrollBarImageTransparency = 0.6,
    ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
}, panel)
make("UIListLayout", {
    Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder,
}, body)
make("UIPadding", { PaddingBottom = UDim.new(0, 2), PaddingRight = UDim.new(0, 2) }, body)
local hero = make("Frame", {
    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 54), LayoutOrder = 1,
}, body)
local headline = text(hero, "Sua câmera, no seu ritmo.", 23, C.text,
    UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 30), Enum.Font.GothamBold)
local subtitle = text(hero, "Encontre o movimento que combina com você.", 12, C.muted,
    UDim2.fromOffset(0, 34), UDim2.new(1, 0, 0, 18))

local card = make("Frame", {
    Name = "Sensitivity", BackgroundColor3 = C.surface, BackgroundTransparency = 0.45,
    BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 184), LayoutOrder = 2,
}, body)
round(card, 16)
stroke(card, C.line, 0.55)
local cameraIcon = make("Frame", {
    BackgroundColor3 = Color3.fromRGB(31, 52, 66), BorderSizePixel = 0,
    Position = UDim2.fromOffset(16, 16), Size = UDim2.fromOffset(28, 28),
}, card)
round(cameraIcon, 9)
local cameraOutline = make("Frame", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(6, 8),
    Size = UDim2.fromOffset(16, 12), BorderSizePixel = 0,
}, cameraIcon)
round(cameraOutline, 3)
stroke(cameraOutline, C.cyan, 0.12, 1.3)
local lens = make("Frame", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(6, 3),
    Size = UDim2.fromOffset(5, 5), BorderSizePixel = 0,
}, cameraOutline)
round(lens, 5)
stroke(lens, C.cyan, 0.12, 1.1)
text(card, "Sensibilidade", 15, C.text, UDim2.fromOffset(54, 14),
    UDim2.new(1, -145, 0, 22), Enum.Font.GothamMedium)
text(card, "Arraste para ajustar.", 11, C.muted, UDim2.fromOffset(54, 36),
    UDim2.new(1, -145, 0, 16))
local valueLabel = text(card, "", 13, C.cyan, UDim2.new(1, -82, 0, 17),
    UDim2.fromOffset(65, 28), Enum.Font.GothamBold)
valueLabel.TextXAlignment = Enum.TextXAlignment.Center
valueLabel.BackgroundColor3 = Color3.fromRGB(27, 48, 61)
valueLabel.BackgroundTransparency = 0.15
round(valueLabel, 8)

local sliderHit = button(card, "AjustarSensibilidade", UDim2.fromOffset(18, 63),
    UDim2.new(1, -36, 0, 44))
sliderHit.BackgroundTransparency = 1
sliderHit.Active = true
local track = make("Frame", {
    BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(48, 55, 76),
    Position = UDim2.new(0, 0, 0.5, -3), Size = UDim2.new(1, 0, 0, 6),
}, sliderHit)
round(track, 4)
local fill = make("Frame", {
    BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
    Size = UDim2.fromScale(0, 1),
}, track)
round(fill, 4)
gradient(fill, C.cyan, C.purple)
local knob = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = C.text, BorderSizePixel = 0,
    Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(18, 18),
}, track)
round(knob, 20)
stroke(knob, C.cyan, 0.25, 2)
text(card, "0,25×  ·  PRECISA", 9, C.muted, UDim2.fromOffset(18, 109),
    UDim2.new(0.5, -18, 0, 15), Enum.Font.GothamMedium)
local upperLimit = text(card, "RÁPIDA  ·  3×", 9, C.muted, UDim2.new(0.5, 0, 0, 109),
    UDim2.new(0.5, -18, 0, 15), Enum.Font.GothamMedium)
upperLimit.TextXAlignment = Enum.TextXAlignment.Right

local presets = {}
for i, preset in ipairs({
    { value = 0.5, title = "0,5×" }, { value = 1, title = "1×  ·  padrão" },
    { value = 2, title = "2×" },
}) do
    local presetButton = button(card, "Preset" .. i,
        UDim2.new((i - 1) / 3, 18 - (i - 1) * 10, 0, 137),
        UDim2.new(1 / 3, -20, 0, 32))
    presetButton.BackgroundTransparency = 0.3
    round(presetButton, 9)
    local outline = stroke(presetButton, C.line, 0.6)
    local caption = text(presetButton, preset.title, 11, C.muted,
        UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Enum.Font.GothamMedium)
    caption.TextXAlignment = Enum.TextXAlignment.Center
    preset.button, preset.outline, preset.caption = presetButton, outline, caption
    presets[#presets + 1] = preset
end

make("Frame", {
    BackgroundColor3 = C.line, BackgroundTransparency = 0.72, BorderSizePixel = 0,
    Position = UDim2.new(0, 22, 1, -39), Size = UDim2.new(1, -44, 0, 1),
}, panel)
local statusDot = make("Frame", {
    BackgroundColor3 = C.amber, BorderSizePixel = 0,
    Position = UDim2.new(0, 23, 1, -23), Size = UDim2.fromOffset(5, 5),
}, panel)
round(statusDot, 5)
local status = text(panel, "Preparando controles…", 10, C.muted,
    UDim2.new(0, 36, 1, -31), UDim2.new(1, -58, 0, 20))
local shortcut = text(panel, "Shift direito para recolher", 10, C.muted,
    UDim2.new(1, -221, 1, -31), UDim2.fromOffset(198, 20))
shortcut.TextXAlignment = Enum.TextXAlignment.Right

local floating = make("CanvasGroup", {
    Name = "Floating", BackgroundColor3 = C.background, BorderSizePixel = 0,
    Size = UDim2.fromOffset(56, 56), Position = UDim2.fromOffset(18, 160),
    GroupColor3 = Color3.new(1, 1, 1), GroupTransparency = 1, Visible = false,
}, root)
round(floating, 18)
local floatingStroke = stroke(floating, Color3.new(1, 1, 1), 0.3, 1.3)
gradient(floatingStroke, C.cyan, C.purple, 45)
local floatingScale = make("UIScale", { Scale = 0.78 }, floating)
local floatingLetter = text(floating, "N", 28, C.text,
    UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Enum.Font.GothamBold)
floatingLetter.TextXAlignment = Enum.TextXAlignment.Center
gradient(floatingLetter, C.cyan, C.purple, 45)
local floatingButton = button(floating, "AbrirPainel",
    UDim2.fromScale(0, 0), UDim2.fromScale(1, 1))
floatingButton.BackgroundTransparency = 1

local loader = make("CanvasGroup", {
    Name = "Initialization", AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C.background, BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.fromOffset(300, 188), Position = UDim2.fromScale(0.5, 0.5),
    GroupColor3 = Color3.new(1, 1, 1), GroupTransparency = 1,
}, root)
round(loader, 20)
stroke(loader, C.line, 0.2)
backdrop(loader, 20)
local loaderScale = make("UIScale", { Scale = 0.94 }, loader)
local loaderLogo = brand(loader, UDim2.new(0.5, -23, 0, 23), 46)
local loaderTitle = text(loader, "NOVA", 18, C.text, UDim2.fromOffset(0, 83),
    UDim2.new(1, 0, 0, 24), Enum.Font.GothamBold)
loaderTitle.TextXAlignment = Enum.TextXAlignment.Center
local loaderCaption = text(loader, "Preparando seus controles", 11, C.muted,
    UDim2.fromOffset(0, 111), UDim2.new(1, 0, 0, 18))
loaderCaption.TextXAlignment = Enum.TextXAlignment.Center
local progressTrack = make("Frame", {
    BackgroundColor3 = C.surface, BorderSizePixel = 0,
    Position = UDim2.fromOffset(32, 151), Size = UDim2.new(1, -64, 0, 4),
}, loader)
round(progressTrack, 3)
local progress = make("Frame", {
    BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
    Size = UDim2.fromScale(0, 1),
}, progressTrack)
round(progress, 3)
gradient(progress, C.cyan, C.purple)

-- A interface so usa eventos e tweens durante interacoes.
local function canvasSize()
    local size = root.AbsoluteSize
    if size.X > 0 and size.Y > 0 then return size end
    local topLeft, bottomRight = GuiService:GetGuiInset()
    local camera = workspace.CurrentCamera
    return (camera and camera.ViewportSize or Vector2.new(800, 600)) - topLeft - bottomRight
end

local function clampPosition(frame, position)
    local available = canvasSize()
    local size = Vector2.new(frame.Size.X.Offset, frame.Size.Y.Offset)
    local anchor = frame.AnchorPoint
    return Vector2.new(
        math.clamp(position.X, 10 + size.X * anchor.X,
            math.max(10 + size.X * anchor.X, available.X - 10 - size.X * (1 - anchor.X))),
        math.clamp(position.Y, 10 + size.Y * anchor.Y,
            math.max(10 + size.Y * anchor.Y, available.Y - 10 - size.Y * (1 - anchor.Y))))
end

local firstLayout = true
local function reflow()
    local size = canvasSize()
    local width, height = math.min(500, math.max(220, size.X - 28)),
        math.min(394, math.max(180, size.Y - 24))
    panel.Size = UDim2.fromOffset(width, height)
    local center = firstLayout and size / 2
        or Vector2.new(panel.Position.X.Offset, panel.Position.Y.Offset)
    local position = clampPosition(panel, center)
    panel.Position = UDim2.fromOffset(position.X, position.Y)
    if firstLayout then floating.Position = UDim2.fromOffset(18, math.max(12, size.Y / 2 - 28)) end
    local floatingPosition = clampPosition(floating,
        Vector2.new(floating.Position.X.Offset, floating.Position.Y.Offset))
    floating.Position = UDim2.fromOffset(floatingPosition.X, floatingPosition.Y)
    loader.Size = UDim2.fromOffset(math.min(300, math.max(200, size.X - 28)), 188)
    local narrow = width < 380
    free.Visible = not narrow
    headline.TextSize = narrow and 21 or 23
    headline.Text = narrow and "Sua câmera.\nNo seu ritmo." or "Sua câmera, no seu ritmo."
    headline.Size = UDim2.new(1, 0, 0, narrow and 54 or 30)
    headline.TextTruncate = Enum.TextTruncate.None
    headline.TextWrapped = true
    subtitle.Position = UDim2.fromOffset(0, narrow and 59 or 34)
    subtitle.TextSize = narrow and 11 or 12
    hero.Size = UDim2.new(1, 0, 0, narrow and 80 or 54)
    shortcut.Visible = width >= 420 and cameraReady
    status.Size = UDim2.new(1, width >= 420 and -242 or -58, 0, 20)
    firstLayout = false
end
connect(root:GetPropertyChangedSignal("AbsoluteSize"), reflow)
reflow()

local function updateDevice()
    local preferred = UserInputService.PreferredInput
    if preferred == Enum.PreferredInput.Touch then
        device.Text = "MOBILE"
        shortcut.Text = "Arraste o botão flutuante"
    elseif preferred == Enum.PreferredInput.Gamepad then
        device.Text = "CONTROLE"
        shortcut.Text = "Use o botão − para recolher"
    else
        device.Text = "PC"
        shortcut.Text = "Shift direito para recolher"
    end
end
connect(UserInputService:GetPropertyChangedSignal("PreferredInput"), updateDevice)
updateDevice()

local function setSensitivity(value, smooth)
    if not alive or type(value) ~= "number" or value ~= value then return end
    value = math.clamp(value, MIN_SENSITIVITY, MAX_SENSITIVITY)
    sensitivity = math.clamp(MIN_SENSITIVITY
        + math.floor((value - MIN_SENSITIVITY) / STEP + 0.5) * STEP,
        MIN_SENSITIVITY, MAX_SENSITIVITY)
    gui:SetAttribute("Sensitivity", sensitivity)
    valueLabel.Text = string.format("%.2f×", sensitivity):gsub("%.", ",")
    local alpha = (sensitivity - MIN_SENSITIVITY) / (MAX_SENSITIVITY - MIN_SENSITIVITY)
    if smooth then
        animate(fill, { Size = UDim2.fromScale(alpha, 1) }, 0.18)
        animate(knob, { Position = UDim2.fromScale(alpha, 0.5) }, 0.18)
    else
        cancelTween(fill); cancelTween(knob)
        fill.Size = UDim2.fromScale(alpha, 1)
        knob.Position = UDim2.fromScale(alpha, 0.5)
    end
    for _, preset in ipairs(presets) do
        local selected = math.abs(sensitivity - preset.value) < 0.001
        if preset.selected ~= selected then
            preset.selected = selected
            animate(preset.button, {
                BackgroundColor3 = selected and Color3.fromRGB(31, 50, 65)
                    or Color3.fromRGB(28, 33, 50),
            }, 0.16)
            animate(preset.caption, { TextColor3 = selected and C.cyan or C.muted }, 0.16)
            animate(preset.outline, {
                Color = selected and C.cyan or C.line,
                Transparency = selected and 0.55 or 0.65,
            }, 0.16)
        end
    end
    if updateCameraBinding then updateCameraBinding() end
end
setSensitivity(sensitivity, false)
for _, preset in ipairs(presets) do
    connect(preset.button.Activated, function()
        setSensitivity(preset.value, true)
    end)
end

local function setOpen(wantOpen)
    if not alive or booting then return end
    opened = wantOpen
    transitionId = transitionId + 1
    local token = transitionId
    drag, sliderPointer = nil, nil
    body.ScrollingEnabled = true
    panel.Visible, floating.Visible = true, true
    animate(panel, { GroupTransparency = opened and 0 or 1 }, opened and 0.28 or 0.20, function()
        if token == transitionId and not opened then panel.Visible = false end
    end)
    animate(panelScale, { Scale = opened and 1 or 0.96 }, 0.28)
    animate(floating, { GroupTransparency = opened and 1 or 0 }, 0.22, function()
        if token == transitionId and opened then floating.Visible = false end
    end)
    animate(floatingScale, { Scale = opened and 0.78 or 1 }, 0.26)
end

connect(minimize.Activated, function() setOpen(false) end)
connect(minimize.MouseEnter, function()
    animate(minimize, { BackgroundTransparency = 0.05 }, 0.15)
    animate(minus, { BackgroundColor3 = C.cyan }, 0.15)
end)
connect(minimize.MouseLeave, function()
    animate(minimize, { BackgroundTransparency = 0.45 }, 0.15)
    animate(minus, { BackgroundColor3 = C.muted }, 0.15)
end)
connect(floatingButton.Activated, function()
    if os.clock() - lastFloatingDrag > 0.2 then setOpen(true) end
end)

local function pointerPosition(input)
    local inset = GuiService:GetGuiInset()
    return Vector2.new(input.Position.X, input.Position.Y) - inset
end
local function isPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end
local function samePointer(start, input)
    return start == input or (start.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement)
end
local function beginDrag(frame, input, isFloating)
    if booting or drag or sliderPointer or not isPress(input) then return end
    drag = {
        frame = frame, input = input, origin = pointerPosition(input),
        position = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset),
        floating = isFloating, moved = false,
    }
end
connect(header.InputBegan, function(input)
    -- O alvo do botao de recolher nao inicia um arraste do cabecalho.
    local position = pointerPosition(input)
    local bounds = minimize.AbsolutePosition
    local size = minimize.AbsoluteSize
    if position.X >= bounds.X and position.X <= bounds.X + size.X
        and position.Y >= bounds.Y and position.Y <= bounds.Y + size.Y then return end
    beginDrag(panel, input, false)
end)
connect(floatingButton.InputBegan, function(input) beginDrag(floating, input, true) end)

local function adjustSlider(input)
    local width = track.AbsoluteSize.X
    if width <= 0 then return end
    local alpha = math.clamp((pointerPosition(input).X - track.AbsolutePosition.X) / width, 0, 1)
    setSensitivity(MIN_SENSITIVITY + alpha * (MAX_SENSITIVITY - MIN_SENSITIVITY), false)
end
connect(sliderHit.InputBegan, function(input)
    if booting or not isPress(input) or drag or sliderPointer then return end
    sliderPointer = input
    -- O ScrollingFrame nao deve roubar o arraste horizontal do slider.
    body.ScrollingEnabled = false
    adjustSlider(input)
end)
connect(UserInputService.InputChanged, function(input)
    if sliderPointer and samePointer(sliderPointer, input) then adjustSlider(input) end
    if not drag or not samePointer(drag.input, input) then return end
    local delta = pointerPosition(input) - drag.origin
    if not drag.moved and delta.Magnitude < 6 then return end
    drag.moved = true
    if drag.floating then lastFloatingDrag = os.clock() end
    local position = clampPosition(drag.frame, drag.position + delta)
    drag.frame.Position = UDim2.fromOffset(position.X, position.Y)
end)
connect(UserInputService.InputEnded, function(input)
    if sliderPointer == input
        or (sliderPointer and input.UserInputType == Enum.UserInputType.MouseButton1
            and sliderPointer.UserInputType == Enum.UserInputType.MouseButton1) then
        sliderPointer = nil
        body.ScrollingEnabled = true
    end
    if drag and (drag.input == input
        or (input.UserInputType == Enum.UserInputType.MouseButton1
            and drag.input.UserInputType == Enum.UserInputType.MouseButton1)) then
        if drag.floating and drag.moved then lastFloatingDrag = os.clock() end
        drag = nil
    end
end)
connect(UserInputService.WindowFocusReleased, function()
    drag, sliderPointer = nil, nil
    body.ScrollingEnabled = true
end)
connect(UserInputService.InputBegan, function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift
        and not UserInputService:GetFocusedTextBox() and not GuiService.MenuIsOpen then
        setOpen(not opened)
    end
end)

-- Mede o giro que a camera padrao realmente produziu e ajusta somente esse giro.
-- Nao depende de require em modulos internos, nao captura cliques e nao altera
-- CameraType, MouseBehavior ou a sensibilidade salva na conta.
local BEFORE_CAMERA, AFTER_CAMERA = GUI_NAME .. "_Before", GUI_NAME .. "_After"
local cameraTouches = {}
local mousePanning, stickMagnitude, inputMoved, focused = false, 0, false, true
local bound, sampledCamera, sampledFrame = false, nil, nil
local atan2 = math.atan2 or math.atan
local pitchLimit = math.rad(80)
local collision = RaycastParams.new()
collision.FilterType = Enum.RaycastFilterType.Exclude
collision.RespectCanCollide = true
collision.IgnoreWater = true
local function refreshCollisionFilter(character)
    collision.FilterDescendantsInstances = character and { character } or {}
end
refreshCollisionFilter(player.Character)
connect(player.CharacterAdded, refreshCollisionFilter)

local function touchCount()
    local count = 0
    for _ in pairs(cameraTouches) do count = count + 1 end
    return count
end
local function overInterface(input)
    local point = pointerPosition(input)
    for _, object in ipairs({ panel, floating, loader }) do
        if object.Visible and object.GroupTransparency < 0.95 then
            local position, size = object.AbsolutePosition, object.AbsoluteSize
            if point.X >= position.X and point.Y >= position.Y
                and point.X <= position.X + size.X and point.Y <= position.Y + size.Y then
                return true
            end
        end
    end
    return false
end
local function beforeCamera()
    sampledCamera, sampledFrame = nil, nil
    local moved = inputMoved or stickMagnitude > 0.05
    inputMoved = false
    if not moved or not focused or GuiService.MenuIsOpen
        or UserInputService:GetFocusedTextBox() then return end
    if touchCount() > 1 then return end -- Deixa o gesto de zoom com dois dedos em paz.
    local camera = workspace.CurrentCamera
    if not camera or camera.CameraType == Enum.CameraType.Scriptable then return end
    sampledCamera, sampledFrame = camera, camera.CFrame
end
local function afterCamera()
    local camera, previousFrame = sampledCamera, sampledFrame
    sampledCamera, sampledFrame = nil, nil
    if not camera or camera ~= workspace.CurrentCamera or not previousFrame
        or camera.CameraType == Enum.CameraType.Scriptable then return end
    if math.abs(sensitivity - 1) < 0.001 then return end
    local current = camera.CFrame
    local beforeLook, afterLook = previousFrame.LookVector, current.LookVector
    local oldYaw = atan2(-beforeLook.X, -beforeLook.Z)
    local newYaw = atan2(-afterLook.X, -afterLook.Z)
    local oldPitch = math.asin(math.clamp(beforeLook.Y, -1, 1))
    local newPitch = math.asin(math.clamp(afterLook.Y, -1, 1))
    local yawDelta = atan2(math.sin(newYaw - oldYaw), math.cos(newYaw - oldYaw))
    local pitchDelta = newPitch - oldPitch
    if math.abs(yawDelta) + math.abs(pitchDelta) < 0.000001 then return end
    -- Trocas abruptas de camera/cenas nao devem receber o multiplicador.
    if math.abs(yawDelta) > math.rad(85) or math.abs(pitchDelta) > math.rad(85) then return end
    local rotation = CFrame.fromOrientation(
        math.clamp(oldPitch + pitchDelta * sensitivity, -pitchLimit, pitchLimit),
        oldYaw + yawDelta * sensitivity, 0)
    local adjustment = rotation * current.Rotation:Inverse()
    local pivot = camera.Focus.Position
    local offset = adjustment:VectorToWorldSpace(current.Position - pivot)
    local distance = offset.Magnitude
    if distance > 0.75 then
        local hit = workspace:Raycast(pivot, offset, collision)
        if hit and hit.Distance < distance then
            offset = offset * (math.max(0.1, hit.Distance - 0.2) / distance)
        end
    end
    camera.CFrame = CFrame.new(pivot + offset) * rotation
end
updateCameraBinding = function()
    local locked = UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default
    local needed = alive and focused and math.abs(sensitivity - 1) >= 0.001
        and (touchCount() == 1 or mousePanning or locked or stickMagnitude > 0.05)
    if needed == bound then return end
    bound = needed
    sampledCamera, sampledFrame, inputMoved = nil, nil, false
    if needed then
        RunService:BindToRenderStep(BEFORE_CAMERA, Enum.RenderPriority.Camera.Value - 1, beforeCamera)
        RunService:BindToRenderStep(AFTER_CAMERA, Enum.RenderPriority.Camera.Value + 1, afterCamera)
    else
        RunService:UnbindFromRenderStep(BEFORE_CAMERA)
        RunService:UnbindFromRenderStep(AFTER_CAMERA)
    end
end
connect(UserInputService.InputBegan, function(input, processed)
    if input.UserInputType ~= Enum.UserInputType.Touch
        and input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
    if processed or booting or GuiService.MenuIsOpen or overInterface(input) then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        local point, size = pointerPosition(input), canvasSize()
        -- Evita a area usual do joystick, mesmo quando ele nao marca o toque como processado.
        if point.X < size.X * 0.4 and point.Y > size.Y * 0.5 then return end
        cameraTouches[input] = Vector2.new(input.Position.X, input.Position.Y)
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        mousePanning = true
    end
    updateCameraBinding()
end)
connect(UserInputService.InputChanged, function(input, processed)
    local last = cameraTouches[input]
    if last then
        local point = Vector2.new(input.Position.X, input.Position.Y)
        if touchCount() == 1 and (point - last).Magnitude > 0 then inputMoved = true end
        cameraTouches[input] = point
    elseif input.UserInputType == Enum.UserInputType.MouseMovement then
        if not drag and not sliderPointer and (mousePanning
            or UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default) then
            inputMoved = true
        end
    elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
        stickMagnitude = processed and 0 or input.Position.Magnitude
        updateCameraBinding()
    end
end)
connect(UserInputService.InputEnded, function(input)
    cameraTouches[input] = nil
    if input.UserInputType == Enum.UserInputType.MouseButton2 then mousePanning = false end
    if input.KeyCode == Enum.KeyCode.Thumbstick2 then stickMagnitude = 0 end
    updateCameraBinding()
end)
connect(UserInputService:GetPropertyChangedSignal("MouseBehavior"), updateCameraBinding)
connect(UserInputService.WindowFocusReleased, function()
    cameraTouches, mousePanning, stickMagnitude, focused = {}, false, 0, false
    updateCameraBinding()
end)
connect(UserInputService.WindowFocused, function()
    focused = true
    updateCameraBinding()
end)
restoreCamera = function()
    RunService:UnbindFromRenderStep(BEFORE_CAMERA)
    RunService:UnbindFromRenderStep(AFTER_CAMERA)
    cameraTouches, sampledCamera, sampledFrame, bound = {}, nil, nil, false
end
cameraReady = true
status.Text, statusDot.BackgroundColor3 = "Sensibilidade pronta", C.green
updateCameraBinding()
reflow()

-- A abertura e curta; o resto da interface fica pronto antes de ser mostrado.
animate(loader, { GroupTransparency = 0 }, 0.20)
animate(loaderScale, { Scale = 1 }, 0.30)
animate(progress, { Size = UDim2.fromScale(0.72, 1) }, 0.45)
later(0.48, function()
    loaderCaption.Text = cameraReady and "Tudo pronto. Do seu jeito." or "Interface pronta"
    animate(progress, { Size = UDim2.fromScale(1, 1) }, 0.22, function()
        animate(loaderScale, { Scale = 0.97 }, 0.18)
        animate(loader, { GroupTransparency = 1 }, 0.18, function()
            loader.Visible = false
            booting = false
            setOpen(true)
        end)
    end)
end)

-- O retorno e opcional: LocalScripts ignoram; facilita integracao no seu jogo.
return {
    SetSensitivity = function(value) setSensitivity(value, true) end,
    GetSensitivity = function() return sensitivity end,
    SetOpen = setOpen,
    Destroy = function() cleanup(); gui:Destroy() end,
}
