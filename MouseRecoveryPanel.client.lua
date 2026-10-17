-- Mouse Recovery Panel
-- Coloque este LocalScript em StarterPlayer > StarterPlayerScripts.
-- Feito para uso dentro da sua própria experiência no Roblox Studio.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local AssetService = game:GetService("AssetService")

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
local opacityDragging = false
local menuTransparency = 0.48
local isFixing = false

local COLORS = {
    background = Color3.fromRGB(13, 7, 12),
    panel = Color3.fromRGB(25, 10, 17),
    card = Color3.fromRGB(34, 15, 23),
    accent = Color3.fromRGB(255, 74, 92),
    accent2 = Color3.fromRGB(255, 24, 58),
    text = Color3.fromRGB(250, 244, 246),
    muted = Color3.fromRGB(190, 164, 173),
    green = Color3.fromRGB(119, 225, 169),
    red = Color3.fromRGB(255, 109, 127),
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

local activeTweens = {}

local function tween(object, duration, properties)
    local previous = activeTweens[object]
    if previous then
        previous:Cancel()
    end

    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    )
    activeTweens[object] = animation
    animation.Completed:Connect(function()
        if activeTweens[object] == animation then
            activeTweens[object] = nil
        end
    end)
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
    Font = Enum.Font.Arcade,
    Text = "NOVA",
    TextColor3 = COLORS.accent,
    TextSize = 26,
})

create("TextLabel", loadingCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 67),
    Size = UDim2.new(1, 0, 0, 27),
    Font = Enum.Font.Code,
    Text = "Preparando o painel",
    TextColor3 = COLORS.text,
    TextSize = 16,
})

create("TextLabel", loadingCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 96),
    Size = UDim2.new(1, 0, 0, 22),
    Font = Enum.Font.Code,
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

for _, item in ipairs(loadingGui:GetDescendants()) do
    if item:IsA("TextLabel") or item:IsA("TextButton") then
        tween(item, 0.18, {
            TextTransparency = 1,
            BackgroundTransparency = 1,
        })
    elseif item:IsA("Frame") then
        tween(item, 0.18, {BackgroundTransparency = 1})
    elseif item:IsA("UIStroke") then
        tween(item, 0.18, {Transparency = 1})
    end
end

task.wait(0.2)
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
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
})

local panel = create("CanvasGroup", shade, {
    Name = "Panel",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(510, 355),
    GroupTransparency = 1,
    BackgroundColor3 = COLORS.panel,
    BackgroundTransparency = 0.48,
    BorderSizePixel = 0,
    ZIndex = 1,
})

-- A imagem enviada foi compactada e está embutida neste próprio LocalScript.
-- Resolução e paleta reduzidas para manter o arquivo e a memória leves.
local PHOTO_WIDTH, PHOTO_HEIGHT = 256, 140
local PHOTO_INDEX_BASE64 = [[ZmZmZmZmVVVVVVj+iId3iHef3u7t7/mIiZqVRERERFyYePg0REREN/+1NERERERDMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzNERERERERERERERERERERERERERVVVVVVVVVVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZVVVVVWP6Id3d4d4/d7v/ZmIiIiMVEREREOPmGvmNEREQ22vckREREM0MzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzQ0REREREREREREREREREREREREVVVVVVVVVVVVVVVVVVVVVVVVVVVVZmZmZmZmZmZmZVVVVVVY/Ih3d3d3f9/9mHd3iId4lUREREQ23IaPg0REREOYmCRDM0NVMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERERFVVVVVVVVVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZVVVVVVVj7d3d3d3d9/Id3d3d3d3eFRERERESNh2r2NEREQ4mZQ0MzM0dDMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzNDRERERERERERERERERERERVVVVVVVVVVVVVVVVVVVVVVVVVVmZmZmZmVVVVVVVVVVSPt3d3d3d3qHd3d3d3d3eIVEREREQn/HV8hEREQniMhxQzMzJnEzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERERVVVVVVVVVVVVVVVVVVVVVVVVVZWZmZmVmZmZmd2ZlVI+3d3d3d3d3d3d3d3d3eJhURERERDbPd0j3JENCb3iLYkMzMydiMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzM0REREREREREREREREREREVVVVVVVVVVVVVVVVVVVVVVVVVmZmVomYiIiJmId1j7d3d4d3d3d3d3d3d3d86EREREREQ4+HV/9zRDNbZpeGEzMzFoEzMzMzMzMzMyIjIiMzIiIiIiIiIiIiIiMzMzMzMzMzMzMzMzMzMzMzMzMzMzM0NERERERERERERERERERVVVVVVVVVVVVVVVVVVVVVVVVVVmZWjLiIiIiIiIeP2Id3x3d3d3d3d2d3d7/4RERERERCb5dyj/YjM1lhh2pSMzMzhhMzMzMzMzIiIiIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzRERERERERERERERERERFVVVVVVVVVVVVVVVVVVVVVVVVVVV7uIiIiIiIiHjbiHjnd3d3d3d2d3do/PgkRERERENIl3J/+CMyWWB5CJMzMzB4EzMzIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiMzMzMzMzMzMzMzMzMzMzMzNERERERERERERERERFVVVVVVVVVVVVVVVVVVVVVVVVVVfpiIiIiIiId3iYd5d3d3d4dmd3dn3uyWJERDRDNDeIdo3fcTJYQXsm9wMyMklRMiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzMzMzRERERERERERERERERFVVVVVVVVVVVVVVVVVVVVVVVVVY6YiIiIiIh3d4mHd3d3iHh2d2Zmj9+51yREMzMzSN+Bbu+VMlhhfECLMjIjB3AyIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERVVVVVVVVVVVVVVVVVVVVVVVVVWMmIiIiIiHe3eJiJd3mHd3Znd2af26h/cyRDMzNbh3Ft7PcSWHB/UH9xMiMGgiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIzMzMzMzMzMzMzMzMzRERERERERERERERERFVVVVVVVVVVVVVVVVVVVVVVVVjJiIiIiIeJhnmJh2eHd2Znd3Z765mGf4YiMzQX6HYHnt+UFoYm9xX4EyIie0IiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIzMzMzMzMzMzMzMzRERERERERERERERERFVVVVVVVVVVVVVVVVVVVVVVRpuZiIiId3eHZ5h3d3d3ZmeHZoupmZh3iXZTMknbZBee3fYGiEa4A7gSIiF/YCIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIzMzMzMzMzMzMzMzM0RERERERERERERERFVVVVVVVVVVVVVVVVVVVVVUe5mYiIiIh3d3iHd3dnd2d3dnmZmZiYd3v7dnjftTJ5/d9wbcJ/YCj2EiIU1wIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIzMzMzMzMzMzMzMzRERERERERERERERERVVVVVVVVVVVVVVVVVVVVVVHuZmIiImHd3Z4d3d3d3eHdmiZmZmIyIdn7/+ZxwFXj935Jvtn9CB/cCIiCHAiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIjIzMzMzMzMzMzMzMzRERERERERERERERERVVVVVVVVVVVVVVVVVVVVVaJmZiHiIh3d3d3ZmeGeHd2eZmZmazeh3V5u4l1dnjLvt9W25xxIH+FEiIGgCIiIiIiIiIiIiIiIRIiIiIiISIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiMzMzMzMzMzMzMzMzMzNERERERERERERERFVVVVVVVVVVVVVVVVVVVGiZmZh4iId3Z3dmZ5eHZmeZmZmZv/7Il3h3ZkeHvN7dz3fd32AwbfgCIgWUEiIiIhEREiIQAAASEiIiIhIREiIiIiIhIiIiIiIiIiIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzREREREREREREREVVVVVVVVVVVVVVVVVVVVRomZmJh4h3Znd2Zoh3ZmeZy5iZuHi/ycdmh3dkV3uM7fh/zfYCBoi0EiIYYCERERERIQACVndkAAAAEhEREREREREREREREREREiIiIiIiIiIiIiIiIiIiIzMjMzMzMzMzMzMzMzM0REREREREREREREVVVVVVVVVVVVVVVVVVVUV4mZmId3dmd3Zmd3Zmd4eImZm4Ele/mJdniGd3fp3fiK7exRIGiPYCIghwIRERERECZ3jP//h2Z3YQERERERERERERERERERESIiIiIiIiIiIiIiIhEiIiATIyETMzETMzMzMzMzNERERDMzRERERERFVVVVVVVVVVVVVVVVVVVEZ4iImHd3Z4d2d2d3d2ZmZ3ibgjIVj7iGeXVYuf/u3Zv8+TEgd39wISB4AhEREREGjO/+3M3/h5iIYiASERERERERERERERERERERESIiIiIiIiIiViIiNmIiNmIzJmMzMzMzMzMzM0RDVmZURERERERVVVVVVVVVVVVVVVVVVVQ0aIiId3d2d3d2d4d3d2ZmZniFIzFc7Y94dYj/7e3el4/4IiCHb3EiMHgBEREREX/+3N3czd2Hm6iIdkABERERERERERERERERERERERESIiIiIiJ4IiSHhhKHhxJ4dxMzMzNEQzMzM0NneXNEREREREVVVVVVVVVVVVVVVVVURniIiId3d3dnd3iHd2d2ZmZnd3dRIwf9/syHif3e7vd4nvkiIIc9hQRgexEREBInzc3d3d3d3svvmHd3d2ARERERERERERERERERERERERESIiIiIhYiBnBYBXBIJXIXUjMzMyEiMzMzNDIXY0RERERERFRVVVVVVVVVVVVVVUZ4iIiIiIh3d3d3mHdmZmZmZmd3d3cRMo/NzanN7f7sqIiN3EAgdRiVBHB7IBEjQ2jd3d3d3d3d2+zcrP3v9xEREREREREREREREREREREREREREiIiJjIVUVcVYUcWcShhMzMzZmZDMzMzQ2c0REREREREVEVVVVVVVVVVVVVEaIiIiIiIh3d3dni3ZmZmZmZmZ3d4iIYBOP3d3O7fiO3vxn+/cxFmBsYFcHxCRVVXj9zd3d3d3d35vM3u3dzfcRERERERERERERERERERERERERESEhImMhZhRxVhNyZxKGEyMzN4iFMzMzNCdyRERERERERERFVVVVVVVVVVVEaId3d4iIiHd3d3d3ZmZmZmZmZmd3iIi4UDj97u7vh8+HeZmez4MHgE9wZgf2RVVH/t3d3e3d3d3sm+7c3d3sq3ABERERERERERERERERERERERERERERYiBnBoBYBYI3IoUjIzMyIiMzMzMzN2NERERERERERERVVVVVVVVVVFZ3d3d4iIiId3dndlZmZnZmZmZmd3eIiIi2Bv/e68x8yWdZ953M+G2GX3B1CPZFVGzc7d3szd3d3eze3d3d3ey6tzAREREREREREREREREREREREREREhfHIUh4cCh4cReIcTIiMyMzMzMzMzNHQ0REREREREREREVVVVVVVVREZ3Zmd3d4iHd3d2d3ZmZWdmZWZmZ3d4iYiH9wb/3r+I/2eXvI/N3ez7d/hJRJ9kVVj83d3ezO3d3d3u3d3e3d3u7vhQERERERERERERERERERERERERERJmYiFHYCEnYCInYiIiIiIzMzMzMzMzMzM0RERERERERERVVVVVVVVEZ2ZmZ3d3iId3d3d3dmZmVnZlZmZnd3iIUYZphnnu54+4BWf5vc3d3t+Ixl5VmnRUf93d3dze3M7d3N3d3ezO3d3dz5YBEREREREREREREREREREREREREQABIhACIiACIiASIiIiIiMzMzMzMzMzMzNEREREREREREVVVVVVVUVmZmZmd3d3d3Z4d2d3ZmZmdlZmZmZ3d3UQXHV4id6WiZQAf+z4j93d3r+Ab2OLdFau3d3eyt3d3d7L7d3d3d3d3d3c9gEQABERABEREREREREREREREREREhERIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzREREREREREREVVVVVVRnZmZmZ3d3d3dnd3Z3dmZmaIdmZ3eImBASIH9mZ47odn53jO3uie3d3d33B/Y4mHN/3d7d7Jze3d3d7d3d3d3d3d3t33ARAAAREAEREREREREREREREREREREREREREiIiIiIiIiIiIiIjMzMzMzMzMzM0RERERERERERFVVVURGZmZmZmZ3d3dmd3dnZ2ZmZoiYnMzMz4IiESF4h5nt+YeP/t36if3d3d34EI9xeHhI/N3N3Znd3d3eye3t3d3d3d3d679wEAAAAAAAAAARERERERERERERERERERERERIiIiIiIiIiIiIiIiMzMzMzMzMzNERERERERERERVVERFdmZmZmZnd4h2Z3d2ZnZmZmiIicy7y7twIRIQeZ/s3OuIy93em/3d3d3fYCf4RoiFn92L7svu3d3d7J7c3d3d3d3N7dmZUBAAAAAAAAABEREREREREREREREREREREREiIiIiIiIiIiIiIiIzMzMzMzMzM0REREREREREREREREZmZmZmZmVSj3Zmd3Z3dmZmaIiYm7m7mfcCESIEef/tyKeI3Mzvzd7t3fgSSP9ziXbO3c7d3d3d3d3dzszd3d3d3dzt3bhgEAAAAAAAAAABABEQAQARERERERERERERERESIiIiIiIiIiIiIjMzMzMzMzMzNERERERERERERERENmZmZmVUMzKPhmZ3dnd3ZmZ4iIiJiJroj2ASIiADZ7/uu7jN3d3N/M7d+BJt6mN/h/7O7d7t3t3d3d6c3d3d3d3d3b3d33ABAAAAAAAAAAAAABAQNQERERERERERERERERESIiIiIiIiIiIiIiMzMzMzMzMzRERERERERERERERFZmZVQzM0Mo+GZmd2d3dmZoiIiIiImcgn9yAAEiEAR8/Yn8zd3d64zt3fYH/4RH+H6N3dzMzs3e3d34n93d3d/t3dzd3c9wEAAAAAAAAAAAAAAQCGAREREREREREREREREREiIiIiIiIiIiIiMyMzMzMzMzM0RERERERERERERERFVEM0MzMyj3dmZ3Z3d2ZniIiIiLqImoeOh2MAEiIQW8i+3d3d3szt3d91ntZEfIfJ3d6Z7czem+3euP3d3eyN3d3t3e34EAAAAAAAAAAAAAAQOGARERERERERERERERERERIiIiIiIiIiIiIiIzMzMzMzMzM0RERERERERERERERERDMzMzKPd3Zndnd2ZmeIiIiL/IiYetmHiIcwERN87+3d3d3ujN3d3tvutlR8iOjd3Yn93e2d3e3ozt3v34j93d3dzN1gAAAAAAAAAAAAAAaYIAAAERERERERERERERERERIiIiIiIiIiIiIiMzMzMzMzMzREREREREREREREREREMzMzMox3Z2Z2d3Zmh3iIiM7vmIcCf4hieIcgAI/N3d3d3ciM3d3d3s+FVG/ueP3ei+3d6c/szeu+3sjtyM7d3ezOz3AQAAAAAAAAAAAEd2AAAAARERERABEREREREREREiIiIiIiIiIiIiIiMzMzMzMzM0REREREREREREREREMzMzMyiHdnd3d3dmf9d4ie7MvohxEXv/cAWJh3fd3d3d3Oyv3d3d3dz3RUf9yN7L+L7d3b7I2+3nzet83Zjt3d3e3PcBAAAAAAAAEQAldgAAAAABEREAFmYhERERERERESESIiIiIiIiIiIiIzMzMzMzMzQzREREREREREREREMzMzMzKId2d3d3dmae+2eJuZiJmHEhBov7dAZnv83d3d3Mze3u3c3d3fhUOP2I++vors3qv3f5vvef3Iy7yd3d3d3M+CAAAAAAAAAANmQAAQAAAAERADd3YgEREREREREREiEiIiIiIiIiIiIiMzMzMzMzNEREREREREREREREREMzMzMniHd3d3ZmZ/3eecmbuoj5cREQBGibiGe/7//////u/JvM7u7cz4Zp33iH3Ou///j7ePyu+Z/tj4j5r/7v/v/9UAAAAAABEEd2AAEAAAAAARBHh1AAAAAAAAARERESIiIiIiIiIiIiIiIjMzMzMzMzREREREREd3d3d3d3d3d3d3iZiIiIiHh4/e7u7+7u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fOzMvO6c7WEzMzMzMzMzN4YjMzM0Q0Qm/sdduGNEeGJ/38/+7v3O7u7u7u7e33VVaGVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVUREREREREREREREQzRmZmZmZmZs/u7rv2aZczMjMjJp75cWZ2zM3u7fhmmGd0IyNWZmZmZmZleY/LzJzpnsgzMzMzMzMzQndjM0REREREN+6Cf3c1N4M4/cZ4/thn/on+7u7tzvhVZHdWVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVRERERERERERERERERFZmZmZmZlj97u79WP72EzITRRj3QH/+ju7u7u78j7eHUjMzVmZmZmZmZoi+3erPufy2IzMzMzMzMzZVRERERERERCb7VbaGQngkj+hDb/loj8aP3u7u+8+GVVZ1VVVmZVVVVVVVVVVVVVVVVVVVVVVVVVVVREREREREREREREREVmZmZmZmZ97u7exo/PgjNHYxf4YH+8393e7u7u75Z4czMzM1ZmZmZmZmZ57O7+3s78czMzMzMzMzMzNEREREREREQn9ieHc0jFWHiER/+G/4iI/u7u7uzfdWVoZWZmZmZlVVVVVVVVVVVVVVVVVVVVVVVVVURERERERERERERERGZmZmZmZ2j97u7nr933AmczR2aI/f3d3d7d7u7Pd8yEMzMzRmZmZmZmZnme3u7sns+EMzMzMzMzNERERERERERERDb3NId1WsVodoRH/5afdr/e7u7u/N91ZVhlZmZmZmZlVVVVVVVVVVVVVVVVVVVVVVVVVEREREREREREREREZmZmZmZmZr/e7uzu7ft1IjNCRX/dzO7e7u3u7t94/4QzMzM1ZmZmZmZljJ/u7u2+zvYkMzM0REREREREREREREREUogzeHYnk2nWdUbf/9+Z3e7u7u76n2VlVnVmZmZmZlVVVVVVVVVVVVVVVVVVVVVVVVVVVVVURERERERERERWZmZmZmZmj97u3+7u3/ZkM1dkWfu72t7u3e7u7HzPgzMzMzRmZmZmZmV8zO7u7u7t+DRERERERERERERERERERERDbWNodjaFOPd2VH+868/d7u7u7OmPdVVVdlZg==]]
local PHOTO_PALETTE_BASE64 = [[///x+/rs8/Lk6+nd4uHV19bJwL6xf3t2OzU6IRkmIBYlGhIgEwgUEAQODgMOBwAG]]

local function decodeBase64(source)
    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local lookup = {}
    for i = 1, #alphabet do
        lookup[string.byte(alphabet, i)] = i - 1
    end
    local output = table.create(math.ceil(#source * 3 / 4))
    for i = 1, #source, 4 do
        local b1 = lookup[string.byte(source, i)] or 0
        local b2 = lookup[string.byte(source, i + 1)] or 0
        local c3, c4 = string.byte(source, i + 2), string.byte(source, i + 3)
        local b3, b4 = lookup[c3] or 0, lookup[c4] or 0
        local packed = b1 * 262144 + b2 * 4096 + b3 * 64 + b4
        output[#output + 1] = string.char(math.floor(packed / 65536) % 256)
        if c3 and c3 ~= 61 then
            output[#output + 1] = string.char(math.floor(packed / 256) % 256)
        end
        if c4 and c4 ~= 61 then
            output[#output + 1] = string.char(packed % 256)
        end
    end
    return table.concat(output)
end

local backgroundPhoto = create("ImageLabel", panel, {
    Name = "EmbeddedPanelArtwork",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ImageTransparency = 0.08,
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 0,
})
addCorner(backgroundPhoto, 22)

local panelTint = create("Frame", panel, {
    Name = "PanelTint",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLORS.background,
    BackgroundTransparency = menuTransparency,
    BorderSizePixel = 0,
    ZIndex = 1,
})
addCorner(panelTint, 22)

local photoLoaded, photoError = pcall(function()
    local indexBytes = decodeBase64(PHOTO_INDEX_BASE64)
    local paletteBytes = decodeBase64(PHOTO_PALETTE_BASE64)
    local editableImage = AssetService:CreateEditableImage({
        Size = Vector2.new(PHOTO_WIDTH, PHOTO_HEIGHT),
    })
    if not editableImage then
        error("Roblox não disponibilizou memória para a imagem.")
    end

    local pixels = buffer.create(PHOTO_WIDTH * PHOTO_HEIGHT * 4)
    for pixel = 0, PHOTO_WIDTH * PHOTO_HEIGHT - 1 do
        local packedIndex = string.byte(indexBytes, math.floor(pixel / 2) + 1)
        local colorIndex = (pixel % 2 == 0 and math.floor(packedIndex / 16) or packedIndex % 16) * 3
        local destination = pixel * 4
        buffer.writeu8(pixels, destination, string.byte(paletteBytes, colorIndex + 1))
        buffer.writeu8(pixels, destination + 1, string.byte(paletteBytes, colorIndex + 2))
        buffer.writeu8(pixels, destination + 2, string.byte(paletteBytes, colorIndex + 3))
        buffer.writeu8(pixels, destination + 3, 255)
    end

    editableImage:WritePixelsBuffer(Vector2.zero, Vector2.new(PHOTO_WIDTH, PHOTO_HEIGHT), pixels)
    backgroundPhoto.ImageContent = Content.fromObject(editableImage)
end)

if not photoLoaded then
    backgroundPhoto.Visible = false
    warn("[NOVA] A imagem embutida precisa das APIs de imagem editável do Roblox habilitadas. " .. tostring(photoError))
end

addCorner(panel, 22)
addStroke(panel, COLORS.accent2, 0.3, 1)

-- Aro vermelho vivo em rotação contínua ao redor do painel.
local orbitStroke = create("UIStroke", panel, {
    Color = COLORS.red,
    Transparency = 0.08,
    Thickness = 2,
})
local orbitGradient = create("UIGradient", orbitStroke, {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.accent2),
        ColorSequenceKeypoint.new(0.5, COLORS.red),
        ColorSequenceKeypoint.new(1, COLORS.accent2),
    }),
    Rotation = 0,
})
TweenService:Create(orbitGradient, TweenInfo.new(3.4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
    Rotation = 360,
}):Play()

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

-- Cabeçalho do painel
local header = create("Frame", panel, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(20, 14),
    Size = UDim2.new(1, -40, 0, 48),
})

local logo = create("Frame", header, {
    Size = UDim2.fromOffset(36, 36),
    BackgroundColor3 = COLORS.card,
    BorderSizePixel = 0,
})
addCorner(logo, 12)
addStroke(logo, COLORS.accent, 0.3, 1)
create("UIGradient", logo, {
    Color = ColorSequence.new(COLORS.accent, COLORS.accent2),
    Rotation = 35,
})
create("TextLabel", logo, {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Font = Enum.Font.Arcade,
    Text = "N",
    TextColor3 = COLORS.accent,
    TextSize = 19,
})

create("TextLabel", header, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(45, 0),
    Size = UDim2.fromOffset(69, 21),
    Font = Enum.Font.Arcade,
    Text = "NOVA",
    TextColor3 = COLORS.text,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
})

create("TextLabel", header, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(46, 20),
    Size = UDim2.fromOffset(72, 15),
    Font = Enum.Font.Code,
    Text = "by askzedd",
    TextColor3 = COLORS.muted,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local freeBadge = create("Frame", header, {
    Position = UDim2.fromOffset(119, 6),
    Size = UDim2.fromOffset(53, 24),
    BackgroundColor3 = Color3.fromRGB(45, 52, 74),
    BorderSizePixel = 0,
})
addCorner(freeBadge, 10)
create("TextLabel", freeBadge, {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Font = Enum.Font.Arcade,
    Text = "FREE",
    TextColor3 = Color3.fromRGB(211, 218, 238),
    TextSize = 10,
})

local deviceBadge = create("Frame", header, {
    Position = UDim2.fromOffset(178, 6),
    Size = UDim2.fromOffset(76, 24),
    BackgroundColor3 = Color3.fromRGB(76, 24, 38),
    BorderSizePixel = 0,
})
addCorner(deviceBadge, 10)
local deviceBadgeText = create("TextLabel", deviceBadge, {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Font = Enum.Font.Arcade,
    TextColor3 = COLORS.accent,
    TextSize = 9,
})

local function getDeviceLabel()
    if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
        return "MOBILE"
    elseif UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
        return "GAMEPAD"
    end
    return "PC"
end

deviceBadgeText.Text = getDeviceLabel()
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
    deviceBadgeText.Text = getDeviceLabel()
end)

local closeButton = create("TextButton", header, {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 1),
    Size = UDim2.fromOffset(36, 36),
    BackgroundColor3 = COLORS.card,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.Code,
    Text = "−",
    TextColor3 = COLORS.accent,
    TextSize = 25,
})
addCorner(closeButton, 12)

create("Frame", panel, {
    Position = UDim2.new(0, 20, 0, 73),
    Size = UDim2.new(1, -40, 0, 1),
    BackgroundColor3 = Color3.fromRGB(83, 32, 47),
    BackgroundTransparency = 0.45,
    BorderSizePixel = 0,
})

-- Navegação por categorias
local sidebar = create("Frame", panel, {
    Position = UDim2.fromOffset(20, 89),
    Size = UDim2.fromOffset(116, 246),
    BackgroundTransparency = 1,
})

local content = create("CanvasGroup", panel, {
    Position = UDim2.fromOffset(146, 87),
    Size = UDim2.new(1, -166, 0, 248),
    BackgroundTransparency = 1,
    GroupTransparency = 0,
    BorderSizePixel = 0,
})

local function makeCategoryButton(text, y)
    local button = create("TextButton", sidebar, {
        Position = UDim2.fromOffset(0, y),
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = COLORS.card,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.Code,
        Text = "   " .. text,
        TextColor3 = COLORS.muted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    addCorner(button, 12)
    return button
end

local infoTab = makeCategoryButton("ⓘ   INFO", 3)
local visualTab = makeCategoryButton("◉   VISUAL", 50)
local configTab = makeCategoryButton("⚙   CONFIG", 97)

local infoPage = create("Frame", content, {
    Name = "InfoPage",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = true,
})

local visualPage = create("Frame", content, {
    Name = "VisualPage",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = false,
})

local configPage = create("Frame", content, {
    Name = "ConfigPage",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = false,
})

create("TextLabel", infoPage, {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 20),
    Font = Enum.Font.Arcade,
    Text = "PLAYER INFO",
    TextColor3 = COLORS.text,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local INFO_ICONS = {
    ["Display name"] = "◉",
    ["Usuário"] = "♟",
    ["User ID"] = "#",
    ["Conta"] = "◷",
    ["Ping"] = "⌁",
    ["Dispositivo"] = "▣",
    ["Região / IP"] = "◎",
}

local function makeInfoRow(label, value, y)
    local row = create("Frame", infoPage, {
        Position = UDim2.fromOffset(0, y),
        Size = UDim2.new(1, 0, 0, 27),
        BackgroundColor3 = COLORS.card,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
    })
    addCorner(row, 9)
    create("TextLabel", row, {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.fromOffset(17, 27),
        Font = Enum.Font.Arcade,
        Text = INFO_ICONS[label] or "•",
        TextColor3 = COLORS.accent,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    create("TextLabel", row, {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(0, 75, 1, 0),
        Font = Enum.Font.Code,
        Text = label,
        TextColor3 = COLORS.muted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local valueLabel = create("TextLabel", row, {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 107, 0, 0),
        Size = UDim2.new(1, -115, 1, 0),
        Font = Enum.Font.Code,
        Text = value,
        TextColor3 = COLORS.text,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    return valueLabel
end

makeInfoRow("Display name", player.DisplayName, 23)
makeInfoRow("Usuário", "@" .. player.Name, 53)
makeInfoRow("User ID", tostring(player.UserId), 83)
makeInfoRow("Conta", tostring(player.AccountAge) .. " dias", 113)
local pingValue = makeInfoRow("Ping", "medindo...", 143)
local deviceValue = makeInfoRow("Dispositivo", getDeviceLabel(), 173)
makeInfoRow("Região / IP", "não fornecidos pelo Roblox", 203)

local pingRefreshToken = 0
local function refreshPing()
    pingRefreshToken += 1
    local token = pingRefreshToken

    local function update()
        if token ~= pingRefreshToken or not screenGui.Parent or not infoPage.Visible then
            return
        end

        local ok, pingSeconds = pcall(function()
            return player:GetNetworkPing()
        end)
        if ok and type(pingSeconds) == "number" then
            pingValue.Text = string.format("%d ms", math.floor(pingSeconds * 1000 + 0.5))
        else
            pingValue.Text = "indisponível"
        end
        deviceValue.Text = getDeviceLabel()
        task.delay(1, update)
    end

    update()
end
refreshPing()

-- Categoria Visual: mantém a recuperação do cursor e seus atalhos.
create("TextLabel", visualPage, {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 20),
    Font = Enum.Font.Arcade,
    Text = "VISUAL",
    TextColor3 = COLORS.text,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local statusCard = create("Frame", visualPage, {
    Position = UDim2.fromOffset(0, 24),
    Size = UDim2.new(1, 0, 0, 49),
    BackgroundColor3 = COLORS.card,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
})
addCorner(statusCard, 12)
addStroke(statusCard, Color3.fromRGB(103, 49, 61), 0.72, 1)

local statusDot = create("Frame", statusCard, {
    Position = UDim2.fromOffset(12, 19),
    Size = UDim2.fromOffset(10, 10),
    BackgroundColor3 = COLORS.green,
    BorderSizePixel = 0,
})
addCorner(statusDot, 10)

local statusText = create("TextLabel", statusCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(30, 5),
    Size = UDim2.new(1, -40, 0, 19),
    Font = Enum.Font.Code,
    Text = "Cursor pronto",
    TextColor3 = COLORS.text,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local statusHint = create("TextLabel", statusCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(30, 24),
    Size = UDim2.new(1, -40, 0, 17),
    Font = Enum.Font.Code,
    Text = "Use o botão abaixo se o mouse travar.",
    TextColor3 = COLORS.muted,
    TextSize = 8,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
})

local fixButton = create("TextButton", visualPage, {
    Position = UDim2.fromOffset(0, 81),
    Size = UDim2.new(1, 0, 0, 51),
    BackgroundColor3 = COLORS.accent2,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.Arcade,
    Text = "⌖  LIBERAR CURSOR",
    TextColor3 = COLORS.text,
    TextSize = 12,
})
addCorner(fixButton, 13)
create("UIGradient", fixButton, {
    Color = ColorSequence.new(Color3.fromRGB(255, 69, 91), Color3.fromRGB(255, 28, 63)),
    Rotation = 0,
})
addStroke(fixButton, Color3.fromRGB(181, 223, 255), 0.68, 1)

local keyCard = create("Frame", visualPage, {
    Position = UDim2.fromOffset(0, 140),
    Size = UDim2.new(1, 0, 0, 52),
    BackgroundColor3 = COLORS.card,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
})
addCorner(keyCard, 12)
addStroke(keyCard, Color3.fromRGB(103, 49, 61), 0.74, 1)

create("TextLabel", keyCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(10, 5),
    Size = UDim2.new(1, -115, 0, 18),
    Font = Enum.Font.Code,
    Text = "⌨  TECLA PARA LIBERAR",
    TextColor3 = COLORS.muted,
    TextSize = 8,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local keyButton = create("TextButton", keyCard, {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -8, 0.5, 0),
    Size = UDim2.fromOffset(94, 34),
    BackgroundColor3 = Color3.fromRGB(55, 23, 34),
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.Arcade,
    Text = FIX_KEY.Name,
    TextColor3 = COLORS.accent,
    TextSize = 10,
})
addCorner(keyButton, 10)

local keyHint = create("TextLabel", keyCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(10, 23),
    Size = UDim2.new(1, -115, 0, 17),
    Font = Enum.Font.Code,
    Text = "Toque e escolha uma tecla",
    TextColor3 = COLORS.muted,
    TextSize = 8,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
})

create("TextLabel", visualPage, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 203),
    Size = UDim2.new(1, 0, 0, 20),
    Font = Enum.Font.Code,
    Text = "RIGHT SHIFT  •  mostrar / esconder",
    TextColor3 = COLORS.muted,
    TextSize = 8,
    TextXAlignment = Enum.TextXAlignment.Center,
})

-- Categoria Config: controla a transparência do painel sem loops de atualização.
create("TextLabel", configPage, {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 20),
    Font = Enum.Font.Arcade,
    Text = "⚙  APARÊNCIA",
    TextColor3 = COLORS.text,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local opacityHint = create("TextLabel", configPage, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 28),
    Size = UDim2.new(1, 0, 0, 34),
    Font = Enum.Font.Code,
    Text = "Ajuste quanto do jogo aparece atrás do menu.",
    TextColor3 = COLORS.muted,
    TextSize = 9,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
})

local opacityValue = create("TextLabel", configPage, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 72),
    Size = UDim2.new(1, 0, 0, 20),
    Font = Enum.Font.Code,
    Text = "Transparência: 48%",
    TextColor3 = COLORS.text,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local opacityTrack = create("TextButton", configPage, {
    Name = "TransparencySlider",
    Position = UDim2.fromOffset(0, 101),
    Size = UDim2.new(1, 0, 0, 26),
    BackgroundColor3 = COLORS.card,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "",
})
addCorner(opacityTrack, 13)
addStroke(opacityTrack, Color3.fromRGB(103, 49, 61), 0.72, 1)

local opacityFill = create("Frame", opacityTrack, {
    Name = "Fill",
    Position = UDim2.fromOffset(3, 3),
    Size = UDim2.new(0, 0, 1, -6),
    BackgroundColor3 = COLORS.accent2,
    BorderSizePixel = 0,
})
addCorner(opacityFill, 10)
create("UIGradient", opacityFill, {
    Color = ColorSequence.new(COLORS.accent, COLORS.accent2),
    Rotation = 0,
})

local opacityKnob = create("Frame", opacityTrack, {
    Name = "Knob",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0, 13, 0.5, 0),
    Size = UDim2.fromOffset(16, 16),
    BackgroundColor3 = COLORS.text,
    BorderSizePixel = 0,
})
addCorner(opacityKnob, 10)
addStroke(opacityKnob, COLORS.accent, 0.15, 1)

local function setTransparencyFromX(x)
    local width = opacityTrack.AbsoluteSize.X
    if width <= 0 then
        return
    end
    local fraction = math.clamp((x - opacityTrack.AbsolutePosition.X) / width, 0, 1)
    menuTransparency = 0.2 + fraction * 0.6
    local center = 10 + fraction * (width - 20)
    opacityKnob.Position = UDim2.new(0, center, 0.5, 0)
    opacityFill.Size = UDim2.new(0, math.max(0, center - 10), 1, -6)
    opacityValue.Text = "Transparência: " .. tostring(math.floor(fraction * 60 + 20 + 0.5)) .. "%"
    panelTint.BackgroundTransparency = menuTransparency
end

opacityTrack.Activated:Connect(function()
    local mouse = UserInputService:GetMouseLocation()
    setTransparencyFromX(mouse.X)
end)
opacityTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        opacityDragging = true
        setTransparencyFromX(input.Position.X)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        opacityDragging = false
    end
end)

local selectedTab = infoTab
local activePage = infoPage
local categoryTransition = 0

local function setCategory(category)
    local nextPage = category == "Info" and infoPage or (category == "Visual" and visualPage or configPage)
    local nextTab = category == "Info" and infoTab or (category == "Visual" and visualTab or configTab)
    if activePage == nextPage then
        return
    end

    categoryTransition += 1
    local transitionId = categoryTransition
    selectedTab = nextTab
    activePage = nextPage

    tween(infoTab, 0.15, {
        BackgroundTransparency = nextTab == infoTab and 0.16 or 0.4,
        TextColor3 = nextTab == infoTab and COLORS.text or COLORS.muted,
    })
    tween(visualTab, 0.15, {
        BackgroundTransparency = nextTab == visualTab and 0.16 or 0.4,
        TextColor3 = nextTab == visualTab and COLORS.text or COLORS.muted,
    })
    tween(configTab, 0.15, {
        BackgroundTransparency = nextTab == configTab and 0.16 or 0.4,
        TextColor3 = nextTab == configTab and COLORS.text or COLORS.muted,
    })

    local fadeOut = tween(content, 0.1, {GroupTransparency = 1})
    fadeOut.Completed:Connect(function(playbackState)
        if playbackState ~= Enum.PlaybackState.Completed or transitionId ~= categoryTransition then
            return
        end
        infoPage.Visible = nextPage == infoPage
        visualPage.Visible = nextPage == visualPage
        configPage.Visible = nextPage == configPage
        if nextPage == infoPage then
            refreshPing()
        else
            pingRefreshToken += 1
        end
        tween(content, 0.13, {GroupTransparency = 0})
    end)
end

infoTab.Activated:Connect(function()
    setCategory("Info")
end)
visualTab.Activated:Connect(function()
    setCategory("Visual")
end)
configTab.Activated:Connect(function()
    setCategory("Config")
end)
infoTab.BackgroundTransparency = 0.16
infoTab.TextColor3 = COLORS.text
visualTab.BackgroundTransparency = 0.4
visualTab.TextColor3 = COLORS.muted
configTab.BackgroundTransparency = 0.4
configTab.TextColor3 = COLORS.muted

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
local floatingScale = create("UIScale", floatingButton, {
    Scale = 1,
})
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
    Font = Enum.Font.Arcade,
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
task.defer(function()
    if screenGui.Parent then
        tween(panel, 0.3, {GroupTransparency = 0})
        tween(shade, 0.3, {BackgroundTransparency = 1})
    end
end)

local function setPanelOpen(open)
    if isOpen == open then
        return
    end

    isOpen = open
    if open then
        shade.Visible = true
        shade.BackgroundTransparency = 1
        panel.GroupTransparency = 1
        tween(panel, 0.24, {GroupTransparency = 0})
        tween(shade, 0.24, {BackgroundTransparency = 1})

        if floatingButton.Visible then
            tween(floatingScale, 0.14, {Scale = 0.72})
            task.delay(0.14, function()
                if isOpen then
                    floatingButton.Visible = false
                    floatingScale.Scale = 1
                end
            end)
        end
    else
        tween(panel, 0.2, {GroupTransparency = 1})
        tween(shade, 0.2, {BackgroundTransparency = 1})
        task.delay(0.21, function()
            if not isOpen then
                shade.Visible = false
                floatingButton.Visible = true
                floatingScale.Scale = 0.76
                tween(floatingScale, 0.2, {Scale = 1})
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

local dragging = false
local dragMoved = false
local dragInput
local dragStart
local buttonStart

floatingButton.Activated:Connect(function()
    if dragMoved then
        dragMoved = false
        return
    end
    setPanelOpen(true)
end)

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
    if opacityDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        setTransparencyFromX(input.Position.X)
    end

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
