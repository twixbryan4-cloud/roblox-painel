-- Mouse Recovery Panel
-- Coloque este LocalScript em StarterPlayer > StarterPlayerScripts.
-- Feito para uso dentro da sua própria experiência no Roblox Studio.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
if not player then
    warn("[Mouse Recovery] Coloque este código em um LocalScript dentro de StarterPlayer > StarterPlayerScripts.")
    return
end

local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
    warn("[Mouse Recovery] PlayerGui não ficou disponível. Inicie o jogo com Play no Roblox Studio.")
    return
end

local FIX_KEY = Enum.KeyCode.F6
local PANEL_KEY = Enum.KeyCode.RightShift
local choosingKey = false
local isFixing = false

local COLORS = {
    background = Color3.fromRGB(11, 14, 23),
    panel = Color3.fromRGB(19, 23, 36),
    card = Color3.fromRGB(26, 31, 47),
    accent = Color3.fromRGB(91, 211, 255),
    accent2 = Color3.fromRGB(125, 111, 255),
    text = Color3.fromRGB(242, 246, 255),
    muted = Color3.fromRGB(145, 157, 181),
    green = Color3.fromRGB(105, 230, 176),
    red = Color3.fromRGB(255, 123, 145),
}

local function create(className, parent, properties)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function addCorner(parent, radius)
    create("UICorner", parent, {
        CornerRadius = UDim.new(0, radius),
    })
end

local function addStroke(parent, color, transparency, thickness)
    create("UIStroke", parent, {
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
    })
end

local function tween(object, duration, properties)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    )
    animation:Play()
    return animation
end

-- Tela de carregamento
local loadingGui = create("ScreenGui", playerGui, {
    Name = "MouseRecoveryLoading",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 1000,
})

local loadingBackground = create("Frame", loadingGui, {
    Name = "Background",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLORS.background,
    BorderSizePixel = 0,
})

local loadingCard = create("Frame", loadingBackground, {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(330, 205),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
})
local initialCamera = workspace.CurrentCamera
if initialCamera then
    create("UIScale", loadingCard, {
        Scale = math.min(1, initialCamera.ViewportSize.X / 360, initialCamera.ViewportSize.Y / 240),
    })
end
addCorner(loadingCard, 22)
addStroke(loadingCard, COLORS.accent2, 0.55, 1)

create("TextLabel", loadingCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 26),
    Size = UDim2.new(1, 0, 0, 34),
    Font = Enum.Font.GothamBold,
    Text = "NOVA",
    TextColor3 = COLORS.accent,
    TextSize = 26,
})

create("TextLabel", loadingCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 67),
    Size = UDim2.new(1, 0, 0, 27),
    Font = Enum.Font.GothamSemibold,
    Text = "Preparando o painel",
    TextColor3 = COLORS.text,
    TextSize = 16,
})

create("TextLabel", loadingCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 96),
    Size = UDim2.new(1, 0, 0, 22),
    Font = Enum.Font.Gotham,
    Text = "Mouse Recovery  •  inicializando",
    TextColor3 = COLORS.muted,
    TextSize = 11,
})

local loadingTrack = create("Frame", loadingCard, {
    Position = UDim2.new(0, 28, 1, -36),
    Size = UDim2.new(1, -56, 0, 5),
    BackgroundColor3 = COLORS.card,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})
addCorner(loadingTrack, 5)

local loadingFill = create("Frame", loadingTrack, {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = COLORS.accent,
    BorderSizePixel = 0,
})
addCorner(loadingFill, 5)

local loadTween = tween(loadingFill, 1.05, {
    Size = UDim2.new(1, 0, 1, 0),
})
loadTween.Completed:Wait()
task.wait(0.18)
loadingGui:Destroy()

-- Interface principal
local screenGui = create("ScreenGui", playerGui, {
    Name = "MouseRecoveryPanel",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local shade = create("Frame", screenGui, {
    Name = "Shade",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(3, 5, 10),
    BackgroundTransparency = 0.38,
    BorderSizePixel = 0,
})

local panel = create("Frame", shade, {
    Name = "Panel",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(510, 355),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
})
addCorner(panel, 22)
addStroke(panel, COLORS.accent2, 0.48, 1)

create("UISizeConstraint", panel, {
    MinSize = Vector2.new(310, 330),
    MaxSize = Vector2.new(510, 355),
})

local panelScale = create("UIScale", panel, {
    Scale = 1,
})

local cameraViewportConnection
local function updatePanelScale()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end
    panelScale.Scale = math.min(1, camera.ViewportSize.X / 550, camera.ViewportSize.Y / 390)
end

local function watchCurrentCamera()
    if cameraViewportConnection then
        cameraViewportConnection:Disconnect()
        cameraViewportConnection = nil
    end
    local camera = workspace.CurrentCamera
    if camera then
        cameraViewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updatePanelScale)
        updatePanelScale()
    end
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCurrentCamera)
watchCurrentCamera()

local header = create("Frame", panel, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(24, 21),
    Size = UDim2.new(1, -48, 0, 51),
})

local logo = create("Frame", header, {
    Size = UDim2.fromOffset(44, 44),
    BackgroundColor3 = COLORS.card,
    BorderSizePixel = 0,
})
addCorner(logo, 14)
addStroke(logo, COLORS.accent, 0.3, 1)
create("UIGradient", logo, {
    Color = ColorSequence.new(COLORS.accent, COLORS.accent2),
    Rotation = 35,
})

create("TextLabel", logo, {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Font = Enum.Font.GothamBold,
    Text = "N",
    TextColor3 = COLORS.accent,
    TextSize = 22,
})

create("TextLabel", header, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(57, 0),
    Size = UDim2.new(1, -110, 0, 24),
    Font = Enum.Font.GothamBold,
    Text = "Mouse Recovery",
    TextColor3 = COLORS.text,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
})

create("TextLabel", header, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(58, 25),
    Size = UDim2.new(1, -110, 0, 18),
    Font = Enum.Font.Gotham,
    Text = "ATALHO RÁPIDO PARA O CURSOR",
    TextColor3 = COLORS.muted,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local closeButton = create("TextButton", header, {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 2),
    Size = UDim2.fromOffset(36, 36),
    BackgroundColor3 = COLORS.card,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamSemibold,
    Text = "−",
    TextColor3 = COLORS.accent,
    TextSize = 26,
})
addCorner(closeButton, 12)

create("Frame", panel, {
    Position = UDim2.new(0, 24, 0, 86),
    Size = UDim2.new(1, -48, 0, 1),
    BackgroundColor3 = Color3.fromRGB(48, 56, 77),
    BackgroundTransparency = 0.45,
    BorderSizePixel = 0,
})

local statusCard = create("Frame", panel, {
    Position = UDim2.fromOffset(24, 105),
    Size = UDim2.new(1, -48, 0, 57),
    BackgroundColor3 = COLORS.card,
    BorderSizePixel = 0,
})
addCorner(statusCard, 15)
addStroke(statusCard, Color3.fromRGB(70, 83, 112), 0.72, 1)

local statusDot = create("Frame", statusCard, {
    Position = UDim2.fromOffset(16, 23),
    Size = UDim2.fromOffset(10, 10),
    BackgroundColor3 = COLORS.green,
    BorderSizePixel = 0,
})
addCorner(statusDot, 10)

local statusText = create("TextLabel", statusCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(37, 10),
    Size = UDim2.new(1, -52, 0, 20),
    Font = Enum.Font.GothamSemibold,
    Text = "Cursor pronto",
    TextColor3 = COLORS.text,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local statusHint = create("TextLabel", statusCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(37, 30),
    Size = UDim2.new(1, -52, 0, 17),
    Font = Enum.Font.Gotham,
    Text = "Use a tecla escolhida se o mouse travar.",
    TextColor3 = COLORS.muted,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local fixButton = create("TextButton", panel, {
    Position = UDim2.fromOffset(24, 176),
    Size = UDim2.new(1, -48, 0, 57),
    BackgroundColor3 = COLORS.accent2,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamBold,
    Text = "LIBERAR CURSOR",
    TextColor3 = COLORS.text,
    TextSize = 14,
})
addCorner(fixButton, 15)
create("UIGradient", fixButton, {
    Color = ColorSequence.new(
        Color3.fromRGB(73, 194, 255),
        Color3.fromRGB(131, 93, 255)
    ),
    Rotation = 0,
})
addStroke(fixButton, Color3.fromRGB(181, 223, 255), 0.68, 1)

local keyCard = create("Frame", panel, {
    Position = UDim2.fromOffset(24, 246),
    Size = UDim2.new(1, -48, 0, 55),
    BackgroundColor3 = COLORS.card,
    BorderSizePixel = 0,
})
addCorner(keyCard, 15)
addStroke(keyCard, Color3.fromRGB(70, 83, 112), 0.74, 1)

create("TextLabel", keyCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(15, 8),
    Size = UDim2.new(1, -125, 0, 18),
    Font = Enum.Font.GothamSemibold,
    Text = "TECLA PARA LIBERAR",
    TextColor3 = COLORS.muted,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local keyButton = create("TextButton", keyCard, {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -10, 0.5, 0),
    Size = UDim2.fromOffset(104, 36),
    BackgroundColor3 = Color3.fromRGB(36, 44, 64),
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamBold,
    Text = FIX_KEY.Name,
    TextColor3 = COLORS.accent,
    TextSize = 12,
})
addCorner(keyButton, 11)

local keyHint = create("TextLabel", keyCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(15, 27),
    Size = UDim2.new(1, -130, 0, 17),
    Font = Enum.Font.Gotham,
    Text = "Toque aqui e pressione uma tecla",
    TextColor3 = COLORS.muted,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
})

create("TextLabel", panel, {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -13),
    Size = UDim2.new(1, -40, 0, 18),
    Font = Enum.Font.Gotham,
    Text = "RIGHT SHIFT  •  mostrar / esconder painel",
    TextColor3 = COLORS.muted,
    TextSize = 9,
})

-- Botão flutuante que continua acessível depois de minimizar o painel.
local floatingButton = create("TextButton", screenGui, {
    Name = "FloatingOpenButton",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(1, -42, 1, -145),
    Size = UDim2.fromOffset(58, 58),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Visible = false,
    ZIndex = 10,
    Text = "",
})
addCorner(floatingButton, 19)
addStroke(floatingButton, COLORS.accent, 0.12, 1.5)
create("UIGradient", floatingButton, {
    Color = ColorSequence.new(
        Color3.fromRGB(23, 37, 62),
        Color3.fromRGB(49, 32, 83)
    ),
    Rotation = 45,
})

create("TextLabel", floatingButton, {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Font = Enum.Font.GothamBold,
    Text = "N",
    TextColor3 = COLORS.accent,
    TextSize = 22,
    ZIndex = 11,
})

local floatingDot = create("Frame", floatingButton, {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -5, 0, 5),
    Size = UDim2.fromOffset(11, 11),
    BackgroundColor3 = COLORS.green,
    BorderSizePixel = 0,
    ZIndex = 12,
})
addCorner(floatingDot, 10)
addStroke(floatingDot, COLORS.panel, 0, 2)

local isOpen = true

local function setPanelOpen(open)
    isOpen = open
    if open then
        floatingButton.Visible = false
        shade.Visible = true
        panel.Size = UDim2.fromOffset(490, 340)
        tween(panel, 0.18, {Size = UDim2.fromOffset(510, 355)})
        shade.BackgroundTransparency = 1
        tween(shade, 0.18, {BackgroundTransparency = 0.38})
    else
        tween(shade, 0.16, {BackgroundTransparency = 1})
        task.delay(0.17, function()
            if not isOpen then
                shade.Visible = false
                floatingButton.Visible = true
            end
        end)
    end
end

local function releaseCursor()
    if isFixing then
        return
    end

    isFixing = true
    statusDot.BackgroundColor3 = COLORS.accent
    statusText.Text = "Tentando liberar o cursor..."
    statusHint.Text = "Restaurando o comportamento padrão do mouse."

    local function applyDefaultMouse()
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    end

    applyDefaultMouse()

    -- Reaplica por um instante caso a câmera do jogo tente travar o mouse de novo.
    for _, delaySeconds in ipairs({0.08, 0.2, 0.4, 0.7}) do
        task.delay(delaySeconds, applyDefaultMouse)
    end

    task.delay(0.75, function()
        statusDot.BackgroundColor3 = COLORS.green
        statusText.Text = "Comando enviado"
        statusHint.Text = "Se continuar travado, a câmera do jogo pode estar forçando o bloqueio."
        task.wait(1.8)
        if screenGui.Parent then
            statusText.Text = "Cursor pronto"
            statusHint.Text = "Use a tecla escolhida se o mouse travar."
        end
        isFixing = false
    end)
end

fixButton.Activated:Connect(releaseCursor)

keyButton.Activated:Connect(function()
    choosingKey = true
    keyButton.Text = "PRESSIONE..."
    keyButton.TextColor3 = COLORS.green
    keyHint.Text = "Esc cancela  •  Right Shift é reservado"
end)

closeButton.Activated:Connect(function()
    setPanelOpen(false)
end)

floatingButton.Activated:Connect(function()
    if dragMoved then
        dragMoved = false
        return
    end
    setPanelOpen(true)
end)

local dragging = false
local dragMoved = false
local dragInput
local dragStart
local buttonStart

floatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragMoved = false
        dragInput = input
        dragStart = input.Position
        buttonStart = floatingButton.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                task.delay(0.2, function()
                    dragMoved = false
                end)
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    local isMouseDrag = dragInput
        and dragInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement
    local isTouchDrag = input == dragInput

    if dragging and (isMouseDrag or isTouchDrag) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 7 then
            dragMoved = true
        end

        local camera = workspace.CurrentCamera
        if camera then
            local viewport = camera.ViewportSize
            local startX = buttonStart.X.Scale * viewport.X + buttonStart.X.Offset
            local startY = buttonStart.Y.Scale * viewport.Y + buttonStart.Y.Offset
            local halfSize = floatingButton.AbsoluteSize / 2
            local x = math.clamp(startX + delta.X, halfSize.X, viewport.X - halfSize.X)
            local y = math.clamp(startY + delta.Y, halfSize.Y, viewport.Y - halfSize.Y)
            floatingButton.Position = UDim2.fromOffset(x, y)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if choosingKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Escape then
                choosingKey = false
                keyButton.Text = FIX_KEY.Name
                keyButton.TextColor3 = COLORS.accent
                keyHint.Text = "Toque aqui e pressione uma tecla"
                return
            end

            if input.KeyCode == PANEL_KEY then
                keyHint.Text = "Right Shift fica reservado para o painel"
                return
            end

            FIX_KEY = input.KeyCode
            choosingKey = false
            keyButton.Text = FIX_KEY.Name
            keyButton.TextColor3 = COLORS.accent
            keyHint.Text = "Atalho atualizado"
            statusText.Text = "Atalho salvo: " .. FIX_KEY.Name
            statusHint.Text = "Use essa tecla para liberar o cursor."
        end
        return
    end

    if input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end

    if input.KeyCode == PANEL_KEY then
        setPanelOpen(not isOpen)
        return
    end

    if input.KeyCode == FIX_KEY then
        releaseCursor()
    end
end)
