-- NOVA / Camera Panel v1.4
-- LocalScript: StarterPlayer > StarterPlayerScripts.
-- Interface por categorias. Sem inputs virtuais e sem pulo automatico.
-- Camera propria em Scriptable, entrada direta e protecao contra deltas de lag.

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
local MIN_SENSITIVITY, MAX_SENSITIVITY, STEP = 0.1, 5, 0.1
local initialSensitivity = 1
-- Opcional: reaproveita o VideoFrame BackgroundVideo filho deste LocalScript.
-- Tambem aceita o atributo BackgroundVideoId no LocalScript (ID do Roblox).
local backgroundVideoId, backgroundVideoTime, backgroundVideoVolume = "", 0, 0
local function readBackgroundVideo(container)
    if not container then return end
    local source = container:FindFirstChild("BackgroundVideo", true)
    local asset = container:GetAttribute("BackgroundVideoId")
    if source and source:IsA("VideoFrame") then
        backgroundVideoTime, backgroundVideoVolume = source.TimePosition, source.Volume
    end
    local savedTime = container:GetAttribute("BackgroundVideoTime")
    if (not source or not source:IsA("VideoFrame") or source.Video == "")
        and type(savedTime) == "number" and savedTime >= 0 and savedTime < math.huge then
        backgroundVideoTime = savedTime
    end
    if source and source:IsA("VideoFrame") and source.Video ~= "" then
        backgroundVideoId = source.Video
    elseif type(asset) == "number" and asset > 0 and asset < math.huge then
        backgroundVideoId = "rbxassetid://" .. string.format("%.0f", asset)
    elseif type(asset) == "string" and asset:match("^rbxassetid://%d+$") then
        backgroundVideoId = asset
    elseif type(asset) == "string" and asset:match("^%d+$") then
        backgroundVideoId = "rbxassetid://" .. asset
    end
end
if typeof(script) == "Instance" then readBackgroundVideo(script) end

-- Reexecutar substitui a instancia anterior e restaura sua integracao de camera.
local previous = playerGui:FindFirstChild(GUI_NAME)
if previous then
    if backgroundVideoId == "" then readBackgroundVideo(previous) end
    local saved = previous:GetAttribute("Sensitivity")
    if type(saved) == "number" and saved == saved then
        initialSensitivity = math.clamp(saved, MIN_SENSITIVITY, MAX_SENSITIVITY)
    end
    local teardown = previous:FindFirstChild("Teardown")
    if teardown and teardown:IsA("BindableEvent") then teardown:Fire() end
    previous:Destroy()
end

local C = {
    background = Color3.fromRGB(18, 14, 23),
    surface = Color3.fromRGB(53, 43, 61),
    line = Color3.fromRGB(117, 101, 126),
    text = Color3.fromRGB(249, 244, 250),
    muted = Color3.fromRGB(204, 194, 211),
    cyan = Color3.fromRGB(232, 194, 225),
    purple = Color3.fromRGB(188, 155, 207),
    green = Color3.fromRGB(124, 227, 184),
    amber = Color3.fromRGB(240, 196, 128),
}
local alive, booting, opened, cameraReady = true, true, false, false
local sensitivity = initialSensitivity
local connections, activeTweens, pendingTasks = {}, {}, {}
local restoreCamera
local syncCameraPointer
local syncBackgroundVideo
local releaseBackgroundVideo
local displayedSensitivity
local transitionId = 0
local drag, sliderPointer
local lastFloatingDrag = -math.huge
local MONO = Font.new("rbxasset://fonts/families/PressStart2P.json", Enum.FontWeight.Regular)
local MONO_BOLD = MONO -- A fonte pixelada ja tem o desenho forte da referencia.

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
        FontFace = font or MONO, TextXAlignment = Enum.TextXAlignment.Left,
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
    gradient(background, Color3.fromRGB(34, 25, 42), Color3.fromRGB(17, 13, 22), 35)
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
        BackgroundColor3 = Color3.fromRGB(43, 31, 49), BorderSizePixel = 0,
        Position = position, Size = UDim2.fromOffset(size, size),
    }, parent)
    round(logo, math.floor(size * 0.3))
    gradient(logo, Color3.fromRGB(63, 43, 65), Color3.fromRGB(29, 22, 39), 45)
    stroke(logo, C.cyan, 0.65)
    local letter = text(logo, "N", math.floor(size * 0.63), C.text,
        UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), MONO_BOLD)
    letter.TextXAlignment = Enum.TextXAlignment.Center
    gradient(letter, C.cyan, C.purple, 40)
    return logo
end

local gui = make("ScreenGui", {
    Name = GUI_NAME, ResetOnSpawn = false, IgnoreGuiInset = false,
    DisplayOrder = 1000, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)
gui:SetAttribute("Sensitivity", sensitivity)
gui:SetAttribute("BackgroundVideoId", backgroundVideoId)
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
    if releaseBackgroundVideo then releaseBackgroundVideo() end
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
    BorderSizePixel = 0, Size = UDim2.fromOffset(560, 360),
    GroupColor3 = Color3.new(1, 1, 1), GroupTransparency = 1, Visible = false,
}, root)
round(panel, 16)
stroke(panel, C.line, 0.62)
backdrop(panel, 16)
local mediaClip = make("Frame", {
    Name = "MediaClip", BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1), ClipsDescendants = true, Active = false,
    ZIndex = 1,
}, panel)
local backgroundVideo = make("VideoFrame", {
    Name = "BackgroundVideo", BackgroundTransparency = 1, BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(1, 1), Video = "", Playing = false,
    Looped = true, Volume = backgroundVideoVolume, Active = false, Visible = false,
}, mediaClip)
local videoShade = make("Frame", {
    Name = "VideoShade", BackgroundColor3 = C.background,
    BackgroundTransparency = 0.42, BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1), ZIndex = 2, Active = false,
    Visible = backgroundVideoId ~= "",
}, panel)
round(videoShade, 16)
gradient(videoShade, Color3.fromRGB(27, 21, 34), Color3.fromRGB(48, 29, 46), 0)

local function fitBackgroundVideo()
    local resolution = backgroundVideo.Resolution
    if resolution.X > 0 and resolution.Y > 0 then
        local width, height = panel.Size.X.Offset, panel.Size.Y.Offset
        local scale = math.max(width / resolution.X, height / resolution.Y)
        backgroundVideo.Size = UDim2.fromOffset(resolution.X * scale, resolution.Y * scale)
    else
        backgroundVideo.Size = UDim2.fromScale(1, 1)
    end
end
syncBackgroundVideo = function()
    if not alive then return end
    local show = backgroundVideoId ~= "" and opened and not booting
    if show then
        if backgroundVideo.Video ~= backgroundVideoId then
            backgroundVideo.Video = backgroundVideoId
            backgroundVideo.TimePosition = backgroundVideoTime
        end
        backgroundVideo.Visible = true
        if backgroundVideo.IsLoaded then backgroundVideo:Play() end
    else
        -- Libera o decodificador enquanto o painel esta recolhido.
        if backgroundVideo.Video ~= "" then backgroundVideoTime = backgroundVideo.TimePosition end
        gui:SetAttribute("BackgroundVideoTime", backgroundVideoTime)
        backgroundVideo:Pause()
        backgroundVideo.Video = ""
        backgroundVideo.Visible = false
    end
end
releaseBackgroundVideo = function()
    backgroundVideo:Pause()
    backgroundVideo.Video = ""
end
connect(backgroundVideo.Loaded, function()
    fitBackgroundVideo()
    if alive and opened and not booting and backgroundVideo.Video ~= "" then
        backgroundVideo.TimePosition = backgroundVideoTime
        backgroundVideo:Play()
    end
end)
local panelScale = make("UIScale", { Scale = 0.96 }, panel)

local header = make("Frame", {
    Name = "DragHandle", BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 50), Active = true, ZIndex = 3,
}, panel)
for i, color in ipairs({Color3.fromRGB(238, 93, 110), Color3.fromRGB(231, 187, 92),
    Color3.fromRGB(102, 188, 129)}) do
    local dot = make("Frame", {
        Name = "WindowDot" .. i, BackgroundColor3 = color, BorderSizePixel = 0,
        Position = UDim2.fromOffset(16 + (i - 1) * 14, 21), Size = UDim2.fromOffset(7, 7),
        Active = false,
    }, header)
    round(dot, 9)
end
local title = text(header, "NOVA", 12, C.text, UDim2.fromOffset(72, 8),
    UDim2.fromOffset(62, 20), MONO_BOLD)
local credit = text(header, "by askzedd", 8, C.muted, UDim2.fromOffset(72, 29),
    UDim2.fromOffset(100, 13))
local free = text(header, "FREE", 7, C.cyan, UDim2.fromOffset(145, 11),
    UDim2.fromOffset(38, 16), MONO_BOLD)
free.BackgroundTransparency = 0.5
free.BackgroundColor3 = C.surface
free.TextXAlignment = Enum.TextXAlignment.Center
round(free, 6)
local device = text(header, "PC", 7, C.muted, UDim2.new(1, -124, 0, 14),
    UDim2.fromOffset(65, 22), MONO_BOLD)
device.BackgroundTransparency = 0.65
device.BackgroundColor3 = C.surface
device.TextXAlignment = Enum.TextXAlignment.Center
round(device, 7)
local minimize = button(header, "Recolher", UDim2.new(1, -54, 0, 3),
    UDim2.fromOffset(44, 44))
minimize.BackgroundTransparency = 0.75
round(minimize, 10)
local minus = make("Frame", {
    BackgroundColor3 = C.muted, BorderSizePixel = 0,
    Position = UDim2.fromOffset(15, 21), Size = UDim2.fromOffset(14, 2),
}, minimize)
round(minus, 1)
make("Frame", {
    BackgroundColor3 = C.line, BackgroundTransparency = 0.85, BorderSizePixel = 0,
    Position = UDim2.fromOffset(12, 50), Size = UDim2.new(1, -24, 0, 1), ZIndex = 3,
}, panel)

local sidebar = make("Frame", {
    Name = "Categories", BackgroundTransparency = 1,
    Position = UDim2.fromOffset(10, 60), Size = UDim2.new(0, 120, 1, -96),
    ZIndex = 3,
}, panel)
make("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, sidebar)
local content = make("Frame", {
    Name = "Content", BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.fromOffset(142, 60), Size = UDim2.new(1, -154, 1, -96),
    ZIndex = 3,
}, panel)
local mainPage = make("CanvasGroup", {
    Name = "MainPage", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
    GroupColor3 = Color3.new(1, 1, 1), GroupTransparency = 0,
}, content)
local body = make("ScrollingFrame", {
    Name = "Controls", BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Active = true,
    ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 2,
    ScrollBarImageColor3 = C.purple, ScrollBarImageTransparency = 0.6,
    ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
}, mainPage)
make("UIListLayout", {
    Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
}, body)
make("UIPadding", { PaddingBottom = UDim.new(0, 2), PaddingRight = UDim.new(0, 2) }, body)
local hero = make("Frame", {
    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 1,
}, body)
local headline = text(hero, "Câmera", 12, C.text,
    UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 20), MONO_BOLD)
local subtitle = text(hero, "Ajuste o seu movimento.", 11, C.muted,
    UDim2.fromOffset(0, 29), UDim2.new(1, 0, 0, 17))

local card = make("Frame", {
    Name = "Sensitivity", BackgroundColor3 = C.surface, BackgroundTransparency = 0.84,
    BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 156), LayoutOrder = 2,
}, body)
round(card, 12)
stroke(card, C.line, 0.85)
local cameraIcon = make("Frame", {
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.fromOffset(12, 8), Size = UDim2.fromOffset(22, 22),
}, card)
round(cameraIcon, 9)
local cameraOutline = make("Frame", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(3, 5),
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
local sensitivityTitle = text(card, "Sensibilidade", 11, C.text, UDim2.fromOffset(40, 7),
    UDim2.new(1, -126, 0, 20), MONO_BOLD)
local sensitivityDescription = text(card, "Arraste a barra.", 8, C.muted, UDim2.fromOffset(40, 27),
    UDim2.new(1, -126, 0, 13))
local valueLabel = text(card, "", 10, C.cyan, UDim2.new(1, -74, 0, 10),
    UDim2.fromOffset(62, 22), MONO_BOLD)
valueLabel.TextXAlignment = Enum.TextXAlignment.Center
valueLabel.BackgroundColor3 = C.surface
valueLabel.BackgroundTransparency = 0.7
round(valueLabel, 8)

local sliderHit = button(card, "AjustarSensibilidade", UDim2.fromOffset(18, 63),
    UDim2.new(1, -36, 0, 44))
sliderHit.BackgroundTransparency = 1
sliderHit.Active = true
local track = make("Frame", {
    BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(69, 57, 77),
    Position = UDim2.new(0, 0, 0.5, -2), Size = UDim2.new(1, 0, 0, 4),
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
    Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(12, 12),
}, track)
round(knob, 20)
stroke(knob, C.cyan, 0.25, 2)
local lowerLimit = text(card, "0,1×  ·  PRECISA", 7, C.muted, UDim2.fromOffset(18, 109),
    UDim2.new(0.5, -18, 0, 15), MONO)
local upperLimit = text(card, "RÁPIDA  ·  5×", 7, C.muted, UDim2.new(0.5, 0, 0, 109),
    UDim2.new(0.5, -18, 0, 15), MONO)
upperLimit.TextXAlignment = Enum.TextXAlignment.Right

local decrease = button(card, "Diminuir01", UDim2.fromOffset(18, 128),
    UDim2.fromOffset(54, 44))
local increase = button(card, "Aumentar01", UDim2.new(1, -72, 0, 128),
    UDim2.fromOffset(54, 44))
for _, item in ipairs({ { decrease, "−0,1" }, { increase, "+0,1" } }) do
    round(item[1], 8)
    item[1].BackgroundTransparency = 0.72
    stroke(item[1], C.line, 0.82)
    local caption = text(item[1], item[2], 9, C.cyan,
        UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), MONO_BOLD)
    caption.TextXAlignment = Enum.TextXAlignment.Center
end
local precisionHint = text(card, "Passos de 0,1×", 11, C.muted,
    UDim2.fromOffset(78, 128), UDim2.new(1, -156, 0, 44))
precisionHint.TextXAlignment = Enum.TextXAlignment.Center

local presets = {}
for i, preset in ipairs({
    { value = 0.5, title = "0,5×" }, { value = 1, title = "1×" },
    { value = 2, title = "2×" }, { value = 5, title = "5×" },
}) do
    local presetButton = button(card, "Preset" .. i,
        UDim2.new((i - 1) / 4, 18 - (i - 1) * 7, 0, 180),
        UDim2.new(1 / 4, -15, 0, 44))
    presetButton.BackgroundTransparency = 0.72
    round(presetButton, 9)
    local outline = stroke(presetButton, C.line, 0.82)
    local caption = text(presetButton, preset.title, 9, C.muted,
        UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), MONO_BOLD)
    caption.TextXAlignment = Enum.TextXAlignment.Center
    preset.button, preset.outline, preset.caption = presetButton, outline, caption
    presets[#presets + 1] = preset
end

-- As duas paginas sao criadas uma vez. Trocar a aba nao recria controles.
local miscPage = make("CanvasGroup", {
    Name = "MiscPage", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
    GroupColor3 = Color3.new(1, 1, 1), GroupTransparency = 0, Visible = false,
}, content)
local miscBody = make("ScrollingFrame", {
    Name = "MiscControls", BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y, Active = true,
    ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 2,
    ScrollBarImageColor3 = C.purple, ScrollBarImageTransparency = 0.6,
    ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
}, miscPage)
make("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, miscBody)
make("UIPadding", {PaddingRight = UDim.new(0, 2), PaddingBottom = UDim.new(0, 4)}, miscBody)
local miscHero = make("Frame", {
    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 1,
}, miscBody)
text(miscHero, "Interface", 12, C.text, UDim2.fromOffset(0, 0),
    UDim2.new(1, 0, 0, 20), MONO_BOLD)
local miscSubtitle = text(miscHero, "Seus controles de acesso.", 11, C.muted,
    UDim2.fromOffset(0, 29), UDim2.new(1, 0, 0, 17))
local function infoRow(name, label, value, order)
    local row = make("Frame", {
        Name = name, BackgroundColor3 = C.surface, BackgroundTransparency = 0.82,
        Size = UDim2.new(1, 0, 0, 52), BorderSizePixel = 0, LayoutOrder = order,
    }, miscBody)
    round(row, 10)
    text(row, label, 8, C.muted, UDim2.fromOffset(10, 6), UDim2.new(1, -20, 0, 14))
    local valueText = text(row, value, 9, C.text, UDim2.fromOffset(10, 24),
        UDim2.new(1, -20, 0, 22), MONO_BOLD)
    valueText.TextWrapped, valueText.TextTruncate = true, Enum.TextTruncate.None
    return valueText
end
local miscDevice = infoRow("InputInfo", "Entrada atual", "MOBILE", 2)
local miscShortcut = infoRow("ShortcutInfo", "Abrir / recolher", "Botão flutuante", 3)
local miscMinimize = button(miscBody, "RecolherPeloMenu", UDim2.fromOffset(0, 0),
    UDim2.new(1, 0, 0, 44))
miscMinimize.LayoutOrder, miscMinimize.BackgroundTransparency = 4, 0.72
round(miscMinimize, 10)
stroke(miscMinimize, C.line, 0.82)
local miscMinimizeLabel = text(miscMinimize, "Recolher painel", 9, C.text,
    UDim2.fromOffset(8, 0), UDim2.new(1, -16, 1, 0), MONO_BOLD)
miscMinimizeLabel.TextXAlignment = Enum.TextXAlignment.Center
local miscCredit = text(miscBody, "NOVA · FREE\nby askzedd", 8, C.muted,
    UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 44))
miscCredit.LayoutOrder = 5

-- Icones lineares locais: casa e tres cubos, sem emoji ou arquivos remotos.
local function categoryIcon(parent, kind)
    local icon = make("CanvasGroup", {
        Name = "CategoryIcon", BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -8), Size = UDim2.fromOffset(16, 16),
        GroupColor3 = C.muted, GroupTransparency = 0,
    }, parent)
    local function line(x1, y1, x2, y2)
        local dx, dy = x2 - x1, y2 - y1
        local segment = make("Frame", {
            BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset((x1 + x2) * 8 / 24, (y1 + y2) * 8 / 24),
            Size = UDim2.fromOffset(math.sqrt(dx * dx + dy * dy) * 16 / 24, 1.3),
            Rotation = math.deg((math.atan2 or math.atan)(dy, dx)),
        }, icon)
        round(segment, 2)
    end
    if kind == "home" then
        local points = {{3,11},{12,3},{21,11},{21,21},{15,21},{15,14},{9,14},{9,21},{3,21},{3,11}}
        for i = 1, #points - 1 do line(points[i][1], points[i][2], points[i+1][1], points[i+1][2]) end
    else
        local function cube(x, y)
            local points = {{x,y},{x+5,y+3},{x+5,y+9},{x,y+12},{x-5,y+9},{x-5,y+3},{x,y}}
            for i = 1, #points - 1 do line(points[i][1], points[i][2], points[i+1][1], points[i+1][2]) end
            line(x-5,y+3,x,y+6); line(x+5,y+3,x,y+6); line(x,y+6,x,y+12)
        end
        cube(12, 1); cube(6, 10); cube(18, 10)
    end
    return icon
end
local categories = {}
for i, definition in ipairs({{"Main", "home", mainPage}, {"Misc", "boxes", miscPage}}) do
    local item = button(sidebar, definition[1] .. "Category", UDim2.fromOffset(0, 0),
        UDim2.new(1, 0, 0, 44))
    item.LayoutOrder, item.BackgroundTransparency = i, 1
    local surface = make("Frame", {
        Name = "CategorySurface", BackgroundColor3 = C.surface, BackgroundTransparency = 0.96,
        BorderSizePixel = 0, Position = UDim2.new(0, 0, 0.5, -16),
        Size = UDim2.new(1, 0, 0, 32), Active = false,
    }, item)
    round(surface, 8)
    local border = stroke(surface, C.line, 0.92)
    local icon = categoryIcon(item, definition[2])
    local caption = text(item, definition[1], 11, C.muted, UDim2.fromOffset(34, 0),
        UDim2.new(1, -40, 1, 0), MONO_BOLD)
    caption.Name = "CategoryLabel"
    categories[definition[1]] = {button = item, surface = surface, icon = icon, caption = caption,
        border = border, page = definition[3]}
end
local currentCategory
local function setCategory(name, instant)
    local nextCategory = categories[name]
    if not alive or not nextCategory or currentCategory == name then return end
    sliderPointer = nil
    body.ScrollingEnabled = true
    for key, item in pairs(categories) do
        local selected = key == name
        cancelTween(item.page)
        item.page.Visible = selected
        if selected then
            -- O novo conteudo ja comeca legivel; nao ha espera de fade-out.
            item.page.GroupTransparency = instant and 0 or 0.18
            if not instant then animate(item.page, {GroupTransparency = 0}, 0.12) end
        end
        local transparency = selected and 0.48 or 0.96
        local color = selected and C.text or C.muted
        if instant then
            item.surface.BackgroundTransparency, item.caption.TextColor3 = transparency, color
            item.icon.GroupColor3, item.border.Transparency = color, selected and 0.76 or 0.92
        else
            animate(item.surface, {BackgroundTransparency = transparency}, 0.14)
            animate(item.caption, {TextColor3 = color}, 0.14)
            animate(item.icon, {GroupColor3 = color}, 0.14)
            animate(item.border, {Transparency = selected and 0.76 or 0.92}, 0.14)
        end
    end
    currentCategory = name
    gui:SetAttribute("Category", name)
end
for name, item in pairs(categories) do
    connect(item.button.Activated, function() setCategory(name) end)
end
setCategory("Main", true)

make("Frame", {
    BackgroundColor3 = C.line, BackgroundTransparency = 0.85, BorderSizePixel = 0,
    Position = UDim2.new(0, 12, 1, -26), Size = UDim2.new(1, -24, 0, 1), ZIndex = 3,
}, panel)
local statusDot = make("Frame", {
    BackgroundColor3 = C.amber, BorderSizePixel = 0,
    Position = UDim2.new(0, 13, 1, -15), Size = UDim2.fromOffset(4, 4), ZIndex = 3,
}, panel)
round(statusDot, 5)
local status = text(panel, "Preparando controles…", 7, C.muted,
    UDim2.new(0, 24, 1, -22), UDim2.new(1, -48, 0, 18))
local shortcut = text(panel, "Shift direito", 7, C.muted,
    UDim2.new(1, -202, 1, -22), UDim2.fromOffset(190, 18))
status.ZIndex, shortcut.ZIndex = 3, 3
shortcut.TextXAlignment = Enum.TextXAlignment.Right

local floating = make("CanvasGroup", {
    Name = "Floating", BackgroundColor3 = C.background, BorderSizePixel = 0,
    Size = UDim2.fromOffset(48, 48), Position = UDim2.fromOffset(18, 160),
    GroupColor3 = Color3.new(1, 1, 1), GroupTransparency = 1, Visible = false,
}, root)
round(floating, 18)
local floatingStroke = stroke(floating, Color3.new(1, 1, 1), 0.3, 1.3)
gradient(floatingStroke, C.cyan, C.purple, 45)
local floatingScale = make("UIScale", { Scale = 0.78 }, floating)
local floatingLetter = text(floating, "N", 20, C.text,
    UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), MONO_BOLD)
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
    UDim2.new(1, 0, 0, 24), MONO_BOLD)
loaderTitle.TextXAlignment = Enum.TextXAlignment.Center
local loaderCaption = text(loader, "Preparando seus controles", 9, C.muted,
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
    local width, height = math.min(560, math.max(0, size.X - 24)),
        math.min(360, math.max(0, size.Y - 24))
    panel.Size = UDim2.fromOffset(width, height)
    local center = firstLayout and Vector2.new(size.X / 2, height / 2 + 16)
        or Vector2.new(panel.Position.X.Offset, panel.Position.Y.Offset)
    local position = clampPosition(panel, center)
    panel.Position = UDim2.fromOffset(position.X, position.Y)
    if firstLayout then floating.Position = UDim2.fromOffset(18, math.max(12, size.Y / 2 - 24)) end
    local floatingPosition = clampPosition(floating,
        Vector2.new(floating.Position.X.Offset, floating.Position.Y.Offset))
    floating.Position = UDim2.fromOffset(floatingPosition.X, floatingPosition.Y)
    loader.Size = UDim2.fromOffset(math.min(300, math.max(200, size.X - 28)), 188)
    local touch = UserInputService.TouchEnabled
        or UserInputService.PreferredInput == Enum.PreferredInput.Touch
    local buttonHeight = touch and 44 or 32
    local compactHeader = width < 400
    for i = 1, 3 do header:FindFirstChild("WindowDot" .. i).Visible = not compactHeader end
    title.Position = UDim2.fromOffset(compactHeader and 14 or 72, 8)
    credit.Position = UDim2.fromOffset(compactHeader and 14 or 72, 29)
    free.Position = UDim2.fromOffset(compactHeader and 88 or 145, 11)
    device.Position = UDim2.new(1, touch and -124 or -116, 0, 14)
    minimize.Size = UDim2.fromOffset(touch and 44 or 36, touch and 44 or 36)
    minimize.Position = UDim2.new(1, touch and -54 or -46, 0, touch and 3 or 7)
    minus.Position, minus.Size = UDim2.new(0.5, -6, 0.5, -1), UDim2.fromOffset(12, 2)
    local sidebarWidth = width < 420 and 86 or (width < 540 and 104 or 120)
    sidebar.Size = UDim2.new(0, sidebarWidth, 1, -96)
    sidebar.Position = UDim2.fromOffset(10, 60)
    local contentX = sidebarWidth + 22
    content.Position = UDim2.fromOffset(contentX, 60)
    content.Size = UDim2.new(1, -contentX - 12, 1, -96)
    local contentWidth = width - contentX - 14
    for _, category in pairs(categories) do
        category.button.Size = UDim2.new(1, 0, 0, touch and 44 or 36)
        category.caption.TextSize = width < 420 and 10 or 11
    end
    local narrow = contentWidth < 324
    sensitivityTitle.Position = UDim2.fromOffset(narrow and 12 or 40, 7)
    sensitivityTitle.Size = UDim2.new(1, narrow and -24 or -126, 0, 20)
    sensitivityTitle.TextSize = narrow and 10 or 11
    sensitivityDescription.Position = UDim2.fromOffset(narrow and 12 or 40, 27)
    sensitivityDescription.Size = UDim2.new(1, narrow and -24 or -126, 0, 13)
    cameraIcon.Visible = not narrow
    valueLabel.Position = narrow and UDim2.fromOffset(12, 46) or UDim2.new(1, -74, 0, 10)
    sliderHit.Position = UDim2.fromOffset(12, narrow and 72 or 42)
    sliderHit.Size = UDim2.new(1, -24, 0, 44)
    lowerLimit.Position = UDim2.fromOffset(12, narrow and 110 or 82)
    upperLimit.Position = UDim2.new(0.5, 0, 0, narrow and 110 or 82)
    lowerLimit.Size, upperLimit.Size = UDim2.new(0.5, -12, 0, 13), UDim2.new(0.5, -12, 0, 13)
    lowerLimit.Text = narrow and "0,1×" or "0,1× · PRECISA"
    upperLimit.Text = narrow and "5×" or "RÁPIDA · 5×"
    precisionHint.Visible = false
    local controls = {decrease, increase, presets[1].button, presets[2].button,
        presets[3].button, presets[4].button}
    local columns, gap = narrow and 3 or 6, 6
    local cellWidth = math.floor((contentWidth - 24 - gap * (columns - 1)) / columns)
    local gridTop = narrow and 130 or 100
    for i, control in ipairs(controls) do
        local column, row = (i - 1) % columns, math.floor((i - 1) / columns)
        control.Position = UDim2.fromOffset(12 + column * (cellWidth + gap), gridTop + row * (buttonHeight + gap))
        control.Size = UDim2.fromOffset(cellWidth, buttonHeight)
    end
    local rows = math.ceil(#controls / columns)
    card.Size = UDim2.new(1, 0, 0, gridTop + rows * buttonHeight + (rows - 1) * gap + 8)
    subtitle.Visible, miscSubtitle.Visible = false, false
    miscMinimize.Size = UDim2.new(1, 0, 0, buttonHeight)
    miscCredit.Size = UDim2.new(1, 0, 0, 32)
    shortcut.Visible = width >= 520 and cameraReady
    status.Size = UDim2.new(1, width >= 520 and -220 or -40, 0, 18)
    fitBackgroundVideo()
    firstLayout = false
end
connect(root:GetPropertyChangedSignal("AbsoluteSize"), reflow)
reflow()

local function updateDevice()
    local preferred = UserInputService.PreferredInput
    if preferred == Enum.PreferredInput.Touch then
        device.Text = "MOBILE"
        shortcut.Text = "Arraste o flutuante"
    elseif preferred == Enum.PreferredInput.Gamepad then
        device.Text = "CONTROLE"
        shortcut.Text = "Botão − para recolher"
    else
        device.Text = "PC"
        shortcut.Text = "Shift direito"
    end
    miscDevice.Text = device.Text
    miscShortcut.Text = preferred == Enum.PreferredInput.KeyboardAndMouse
        and "Shift direito" or "Botão flutuante"
    reflow()
end
connect(UserInputService:GetPropertyChangedSignal("PreferredInput"), updateDevice)
updateDevice()

local function setSensitivity(value, smooth)
    if not alive or type(value) ~= "number" or value ~= value then return end
    value = math.clamp(value, MIN_SENSITIVITY, MAX_SENSITIVITY)
    sensitivity = math.clamp(math.floor(value / STEP + 0.5) * STEP,
        MIN_SENSITIVITY, MAX_SENSITIVITY)
    if displayedSensitivity and math.abs(displayedSensitivity - sensitivity) < 0.00001 then return end
    displayedSensitivity = sensitivity
    gui:SetAttribute("Sensitivity", sensitivity)
    valueLabel.Text = string.format("%.1f×", sensitivity):gsub("%.", ",")
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
                BackgroundColor3 = selected and Color3.fromRGB(76, 53, 77)
                    or C.surface,
            }, 0.16)
            animate(preset.caption, { TextColor3 = selected and C.cyan or C.muted }, 0.16)
            animate(preset.outline, {
                Color = selected and C.cyan or C.line,
                Transparency = selected and 0.55 or 0.65,
            }, 0.16)
        end
    end
end
setSensitivity(sensitivity, false)
connect(decrease.Activated, function() setSensitivity(sensitivity - STEP, true) end)
connect(increase.Activated, function() setSensitivity(sensitivity + STEP, true) end)
for _, preset in ipairs(presets) do
    connect(preset.button.Activated, function()
        setSensitivity(preset.value, true)
    end)
end

local function setOpen(wantOpen)
    if not alive or booting then return end
    opened = wantOpen
    if syncCameraPointer then syncCameraPointer() end
    transitionId = transitionId + 1
    local token = transitionId
    drag, sliderPointer = nil, nil
    body.ScrollingEnabled = true
    panel.Visible, floating.Visible = true, true
    if opened then syncBackgroundVideo() end
    animate(panel, { GroupTransparency = opened and 0 or 1 }, opened and 0.28 or 0.20, function()
        if token == transitionId and not opened then
            panel.Visible = false
            syncBackgroundVideo()
        end
    end)
    animate(panelScale, { Scale = opened and 1 or 0.96 }, 0.28)
    animate(floating, { GroupTransparency = opened and 1 or 0 }, 0.22, function()
        if token == transitionId and opened then floating.Visible = false end
    end)
    animate(floatingScale, { Scale = opened and 0.78 or 1 }, 0.26)
end

connect(minimize.Activated, function() setOpen(false) end)
connect(miscMinimize.Activated, function() setOpen(false) end)
connect(minimize.MouseEnter, function()
    animate(minimize, { BackgroundTransparency = 0.45 }, 0.15)
    animate(minus, { BackgroundColor3 = C.cyan }, 0.15)
end)
connect(minimize.MouseLeave, function()
    animate(minimize, { BackgroundTransparency = 0.75 }, 0.15)
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
    if booting or not mainPage.Visible or not isPress(input) or drag or sliderPointer then return end
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

-- Um unico controlador: entrada direta, sem ler o giro produzido por outros scripts.
-- Scriptable desliga a camera padrao; a prioridade final aplica a orientacao NOVA.
local CAMERA_BINDING = GUI_NAME .. "_Controller"
local LAG_FRAME, STALE_INPUT = 0.1, 0.12
local MAX_TURN_SPEED, MOUSE_SCALE = math.rad(720), math.rad(0.18)
local PITCH_LIMIT = math.rad(80)
local atan2 = math.atan2 or math.atan
local originalMouse = UserInputService.MouseBehavior
local originalIcon = UserInputService.MouseIconEnabled
local savedTypes = setmetatable({}, { __mode = "k" })
local previousCameraFlag = player:GetAttribute("NovaCameraActive")
player:SetAttribute("NovaCameraActive", true)
local initialCamera = workspace.CurrentCamera
local initialFrame = initialCamera and initialCamera.CFrame or CFrame.new(0, 3, 12)
local lastFocus = initialCamera and initialCamera.Focus.Position or Vector3.new(0, 2, 0)
local initialLook = initialFrame.LookVector
local yaw = atan2(-initialLook.X, -initialLook.Z)
local pitch = math.clamp(math.asin(math.clamp(initialLook.Y, -1, 1)), -PITCH_LIMIT, PITCH_LIMIT)
local rotation = CFrame.fromOrientation(pitch, yaw, 0)
local minZoom = math.max(0.5, player.CameraMinZoomDistance)
local maxZoom = math.max(minZoom, math.min(128, player.CameraMaxZoomDistance))
local zoom = math.clamp((initialFrame.Position - lastFocus).Magnitude, minZoom, maxZoom)
local actualZoom, safeZoom = zoom, zoom
local pendingYaw, pendingPitch, inputStamp = 0, 0, 0
local cameraTouches, touchTotal, lastPinch = {}, 0, nil
local mousePanning, focused = false, true
local shiftLocked = originalMouse == Enum.MouseBehavior.LockCenter
local firstPerson, characterHidden = false, false
local stickX, stickY = 0, 0
local character, rootPart, headPart, humanoid
local subjectConnections, hiddenParts = {}, {}
local touchScaleX, touchScaleY
local castElapsed, lastFrameFocus = 1, nil
local heightOffset = Vector3.new(0, 1.5, 0)
local collision = RaycastParams.new()
collision.FilterType = Enum.RaycastFilterType.Exclude
collision.RespectCanCollide = true
collision.IgnoreWater = true

local function clearMotion()
    pendingYaw, pendingPitch, stickX, stickY = 0, 0, 0, 0
end
local function refreshTouchScale()
    local size = canvasSize()
    touchScaleX = math.pi / math.max(320, size.X)
    touchScaleY = (math.pi * 0.75) / math.max(240, size.Y)
end
refreshTouchScale()
connect(root:GetPropertyChangedSignal("AbsoluteSize"), refreshTouchScale)

local function restoreVisibility()
    for part, previousValue in pairs(hiddenParts) do
        if part.Parent and part.LocalTransparencyModifier == 1 then
            part.LocalTransparencyModifier = previousValue
        end
    end
    hiddenParts = {}
end
local function hidePart(part)
    if not part:IsA("BasePart") or hiddenParts[part] ~= nil then return end
    local ancestor = part.Parent
    while ancestor and ancestor ~= character do
        if ancestor:IsA("Tool") then return end
        ancestor = ancestor.Parent
    end
    hiddenParts[part] = part.LocalTransparencyModifier
    part.LocalTransparencyModifier = 1
end
local function setCharacterHidden(hide)
    if hide == characterHidden then return end
    characterHidden = hide
    if hide and character then
        for _, part in ipairs(character:GetDescendants()) do hidePart(part) end
    else
        restoreVisibility()
    end
end
local function cacheCharacter(nextCharacter)
    restoreVisibility()
    characterHidden = false
    for _, connection in ipairs(subjectConnections) do connection:Disconnect() end
    subjectConnections = {}
    character, rootPart, headPart, humanoid = nextCharacter, nil, nil, nil
    collision.FilterDescendantsInstances = character and { character } or {}
    lastFrameFocus, castElapsed = nil, 1
    if not character then return end
    local function resolve()
        rootPart = character:FindFirstChild("HumanoidRootPart")
        headPart = character:FindFirstChild("Head")
        humanoid = character:FindFirstChildOfClass("Humanoid")
    end
    resolve()
    subjectConnections[1] = character.ChildAdded:Connect(resolve)
    subjectConnections[2] = character.DescendantAdded:Connect(function(part)
        if characterHidden then hidePart(part) end
    end)
end
cacheCharacter(player.Character)
connect(player.CharacterAdded, cacheCharacter)
connect(player.CharacterRemoving, function() clearMotion(); cacheCharacter(nil) end)

local function claimCamera()
    local camera = workspace.CurrentCamera
    if camera then
        if savedTypes[camera] == nil then savedTypes[camera] = camera.CameraType end
        if camera.CameraType ~= Enum.CameraType.Scriptable then
            camera.CameraType = Enum.CameraType.Scriptable
        end
    end
    return camera
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
syncCameraPointer = function()
    local behavior = Enum.MouseBehavior.Default
    local hideIcon = false
    if focused and not booting and not GuiService.MenuIsOpen
        and not UserInputService:GetFocusedTextBox()
        and UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse then
        if mousePanning then
            behavior = Enum.MouseBehavior.LockCurrentPosition
        elseif not opened and (firstPerson or shiftLocked) then
            behavior, hideIcon = Enum.MouseBehavior.LockCenter, true
        end
    end
    if UserInputService.MouseBehavior ~= behavior then UserInputService.MouseBehavior = behavior end
    local icon = originalIcon
    if hideIcon then icon = false end
    if UserInputService.MouseIconEnabled ~= icon then UserInputService.MouseIconEnabled = icon end
end
local function queueMotion(dx, dy, scaleX, scaleY)
    if not focused or GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then return end
    pendingYaw = pendingYaw - dx * scaleX
    pendingPitch = pendingPitch - dy * scaleY
    inputStamp = os.clock()
end
local function clampZoom(value)
    zoom = math.clamp(value, minZoom, maxZoom)
end
local function pinchDistance()
    local first, second
    for _, touch in pairs(cameraTouches) do
        if first then second = touch; break else first = touch end
    end
    if not second then return nil end
    local dx, dy = first.x - second.x, first.y - second.y
    return math.sqrt(dx * dx + dy * dy)
end
connect(UserInputService.InputBegan, function(input, processed)
    if booting or processed or GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.LeftShift and player.DevEnableMouseLock then
        shiftLocked = not shiftLocked
        syncCameraPointer()
        return
    end
    if input.UserInputType ~= Enum.UserInputType.Touch
        and input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
    if overInterface(input) then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        local point, size = pointerPosition(input), canvasSize()
        if point.X < size.X * 0.4 and point.Y > size.Y * 0.5 then return end
        if not cameraTouches[input] then
            cameraTouches[input] = { x = input.Position.X, y = input.Position.Y }
            touchTotal = touchTotal + 1
        end
        if touchTotal > 1 then
            pendingYaw, pendingPitch = 0, 0
            lastPinch = pinchDistance()
        end
    else
        mousePanning = true
        syncCameraPointer()
    end
end)
connect(UserInputService.InputChanged, function(input, processed)
    local touch = cameraTouches[input]
    if touch then
        local dx, dy = input.Position.X - touch.x, input.Position.Y - touch.y
        touch.x, touch.y = input.Position.X, input.Position.Y
        if touchTotal == 1 then
            queueMotion(dx, dy, touchScaleX, touchScaleY)
        else
            local current = pinchDistance()
            if lastPinch and current and lastPinch > 4 and current > 4 then
                clampZoom(zoom * lastPinch / current)
            end
            lastPinch = current
        end
    elseif input.UserInputType == Enum.UserInputType.MouseMovement then
        if not drag and not sliderPointer and (mousePanning
            or (not opened and (firstPerson or shiftLocked))) then
            queueMotion(input.Delta.X, input.Delta.Y, MOUSE_SCALE, MOUSE_SCALE)
        end
    elseif input.UserInputType == Enum.UserInputType.MouseWheel then
        if not processed and not overInterface(input) then
            clampZoom(zoom - input.Position.Z * math.max(0.5, zoom * 0.15))
        end
    elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
        stickX, stickY = 0, 0
        if not processed then
            stickX = math.abs(input.Position.X) > 0.12 and input.Position.X or 0
            stickY = math.abs(input.Position.Y) > 0.12 and input.Position.Y or 0
        end
    end
end)
connect(UserInputService.InputEnded, function(input)
    if cameraTouches[input] then
        cameraTouches[input] = nil
        touchTotal = math.max(0, touchTotal - 1)
        pendingYaw, pendingPitch, lastPinch = 0, 0, nil
        for object, touch in pairs(cameraTouches) do
            touch.x, touch.y = object.Position.X, object.Position.Y
        end
    end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        mousePanning = false
        syncCameraPointer()
    elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
        stickX, stickY = 0, 0
    end
end)
connect(UserInputService.WindowFocusReleased, function()
    focused, mousePanning, cameraTouches, touchTotal, lastPinch = false, false, {}, 0, nil
    clearMotion()
    syncCameraPointer()
end)
connect(UserInputService.WindowFocused, function() focused = true; syncCameraPointer() end)

local function stepCamera(dt)
    local camera = claimCamera()
    if not camera then clearMotion(); return end
    local now = os.clock()
    local accepting = focused and not booting and not GuiService.MenuIsOpen
        and not UserInputService:GetFocusedTextBox()
    local inputIsFresh = now - inputStamp <= STALE_INPUT
    local dx, dy = 0, 0
    if accepting and dt <= LAG_FRAME then
        if inputIsFresh then dx, dy = pendingYaw, pendingPitch end
        local gamepadScale = math.rad(180) * math.min(dt, 1 / 30)
        dx = (dx - stickX * gamepadScale) * sensitivity
        dy = (dy + stickY * gamepadScale) * sensitivity
        local magnitude = math.sqrt(dx * dx + dy * dy)
        local limit = MAX_TURN_SPEED * math.min(dt, 1 / 30)
        if magnitude > limit and magnitude > 0 then
            dx, dy = dx * limit / magnitude, dy * limit / magnitude
        end
    end
    -- O excedente e descartado, nunca fica numa fila girando depois da travada.
    pendingYaw, pendingPitch = 0, 0
    local turned = math.abs(dx) + math.abs(dy) > 0.000001
    if turned then
        yaw = atan2(math.sin(yaw + dx), math.cos(yaw + dx))
        pitch = math.clamp(pitch + dy, -PITCH_LIMIT, PITCH_LIMIT)
        rotation = CFrame.fromOrientation(pitch, yaw, 0)
    end
    local pivot = lastFocus
    if rootPart and rootPart.Parent then
        pivot = rootPart.Position + heightOffset
        if humanoid then pivot = pivot + humanoid.CameraOffset end
    elseif headPart and headPart.Parent then
        pivot = headPart.Position
    end
    lastFocus = pivot
    local requested = player.CameraMode == Enum.CameraMode.LockFirstPerson and 0.5 or zoom
    local moved = not lastFrameFocus or (pivot - lastFrameFocus).Magnitude > 0.02
    lastFrameFocus = pivot
    castElapsed = castElapsed + math.min(dt, LAG_FRAME)
    local interval = (turned or moved or math.abs(actualZoom - requested) > 0.05) and 0.05 or 0.25
    if requested <= 0.75 then
        safeZoom = requested
    elseif castElapsed >= interval then
        castElapsed = 0
        local offset = rotation.LookVector * -requested
        local hit = workspace:Raycast(pivot, offset, collision)
        safeZoom = hit and math.max(0.35, hit.Distance - 0.25) or requested
        safeZoom = math.min(requested, safeZoom)
    end
    local target = math.min(requested, safeZoom)
    if target < actualZoom then
        actualZoom = target
    else
        actualZoom = actualZoom + (target - actualZoom) * (1 - math.exp(-12 * math.min(dt, 0.05)))
    end
    firstPerson = actualZoom < 1
    setCharacterHidden(firstPerson)
    syncCameraPointer()
    camera.CFrame = CFrame.new(pivot - rotation.LookVector * actualZoom) * rotation
    camera.Focus = CFrame.new(pivot)
end
restoreCamera = function()
    RunService:UnbindFromRenderStep(CAMERA_BINDING)
    clearMotion()
    cameraTouches, touchTotal = {}, 0
    for _, connection in ipairs(subjectConnections) do connection:Disconnect() end
    restoreVisibility()
    for camera, cameraType in pairs(savedTypes) do
        if camera.Parent and camera.CameraType == Enum.CameraType.Scriptable then
            camera.CameraType = cameraType
        end
    end
    UserInputService.MouseBehavior = originalMouse
    UserInputService.MouseIconEnabled = originalIcon
    player:SetAttribute("NovaCameraActive", previousCameraFlag)
end
claimCamera()
RunService:BindToRenderStep(CAMERA_BINDING, Enum.RenderPriority.Last.Value + 1, stepCamera)
cameraReady = true
status.Text, statusDot.BackgroundColor3 = "Câmera NOVA ativa", C.green
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
    SetCategory = setCategory,
    GetCategory = function() return currentCategory end,
    Destroy = function() cleanup(); gui:Destroy() end,
}
