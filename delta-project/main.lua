-- delta-project / reference panel / 0.3.0
-- Standalone client UI. No remote libraries, copied scripts or external media files.
local environment = _G
if type(getgenv) == "function" then
    local ok, value = pcall(getgenv)
    if ok and type(value) == "table" then environment = value end
end
local ENV_KEY = "__DELTA_PROJECT_INSTANCE"
local previous = environment[ENV_KEY]
if type(previous) == "table" and type(previous.Destroy) == "function" then previous:Destroy() end

local App = {Name = "delta-project", Version = "0.3.0", Active = true, Cleanups = {}, Actions = {}, Listeners = {}, State = {}, UI = {}, FX = {}}
environment[ENV_KEY] = App
function App:AddCleanup(callback)
    assert(self.Active and type(callback) == "function", "Invalid cleanup")
    self.Cleanups[#self.Cleanups + 1] = callback
    return callback
end
function App:Connect(signal, callback, owner)
    local connection = signal:Connect(function(...)
        if self.Active then callback(...) end
    end)
    if not owner then self:AddCleanup(function() connection:Disconnect() end) end
    return connection
end
function App:RegisterAction(name, callback)
    assert(self.Active and type(name) == "string" and type(callback) == "function", "Invalid action")
    assert(not self.Actions[name], "Action already registered: " .. name)
    self.Actions[name] = callback
end
function App:RunAction(name, ...)
    assert(self.Active and self.Actions[name], "Action unavailable: " .. tostring(name))
    return self.Actions[name](...)
end
function App:Destroy()
    if not self.Active then return end
    self.Active = false
    for index = #self.Cleanups, 1, -1 do
        local ok, err = pcall(self.Cleanups[index])
        if not ok then warn("[delta-project] Cleanup: " .. tostring(err)) end
        self.Cleanups[index] = nil
    end
    self.Actions, self.Listeners = {}, {}
    if environment[ENV_KEY] == self then environment[ENV_KEY] = nil end
end

local function start()
    local Players = game:GetService("Players")
    local Lighting = game:GetService("Lighting")
    local Input = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local HttpService = game:GetService("HttpService")
    local SoundService = game:GetService("SoundService")
    local GuiService = game:GetService("GuiService")
    local player = Players.LocalPlayer
    assert(player, "Execute no cliente, depois que o jogo carregar.")
    local UI, FX = App.UI, App.FX
    local C = {Panel = Color3.fromRGB(9, 9, 12), Card = Color3.fromRGB(12, 12, 15), Border = Color3.fromRGB(45, 45, 51), Text = Color3.fromRGB(226, 226, 231), Muted = Color3.fromRGB(116, 116, 126), Dim = Color3.fromRGB(71, 71, 80), White = Color3.fromRGB(244, 244, 247)}
    local defaults = {
        Preset = "Game", Celestial = "Game", Stars = 3000, Fog = false, FogDistance = 350,
        Bloom = false, BloomIntensity = 0.3, SunRays = false, Blur = false, BlurSize = 6,
        ColorGrade = false, Atmosphere = false, AtmosphereDensity = 0.3,
        Fullbright = false, TimeChange = false, ClockTime = 0, Ambient = false, Exposure = false, ExposureValue = 0,
        Aura = false, AuraStyle = "Ambient", AuraColor = "FF85E6", AuraGlow = 0.6, AuraRate = 65, AuraSize = 1.2, AuraLifetime = 1.5, AuraGrow = 120, AuraSpin = 35,
        Trail = false, TrailStyle = "Sparkle", TrailColor = "FF85E6", TrailLifetime = 0.9, TrailWidth = 1.5, TrailBrightness = 0.85,
        Rainbow = false, ESP = false, ESPNames = true, ESPHealth = false, ESPTeamCheck = false, ESPDistance = 500, ESPColor = "FFFFFF",
        FOVEnabled = false, FOV = 70, Crosshair = false, CrosshairSize = 6, CrosshairGap = 4,
        Tint = false, TintColor = "B7BCFF", Material = "SmoothPlastic",
        Preview = true, Silhouette = true, PreviewSpin = false, PreviewSpeed = 12,
        Watermark = true, Opacity = 0.04, MenuScale = 1, Keybind = "Insert",
        MusicId = "", MusicVolume = 0.4, MusicLoop = true, EmoteSpeed = 1,
        Quality = "Auto", ArtworkId = "", Skybox = "Game", SkyBackId = "", SkyDownId = "", SkyFrontId = "", SkyLeftId = "", SkyRightId = "", SkyUpId = "",
        AuraTarget = "Self", AuraAmbient = true, AuraAngelic = false, AuraNimb = false, AuraRadius = 1.5, AuraSpeed = 2.8,
        TrailTarget = "Self", TrailSize = 7, TrailLength = 9, TrailDensity = 140, TrailSpread = 82, TrailDrift = 100, TrailAlwaysOn = false,
        Hat = false, HatSize = 4, HatHeight = 0.65, HatSpin = 0, HatColor = "E6E9EF", Halo = false, HaloRadius = 1.8, HaloHeight = 1.4, HaloTilt = 12, HaloSpin = 35, HaloColor = "A9D6FF", CosmeticTarget = "Self",
        Glyphs = false, GlyphCount = 26, GlyphSpeed = 47, GlyphTrail = 34, GlyphLifetime = 3, GlyphWidth = 2, GlyphGlow = true, GlyphColorMode = "Single", GlyphColor = "B8D5FF",
        Circle = false, CircleStyle = "Konchal", CircleSize = 4, CircleLife = 8, CircleGrow = 220, CircleBrightness = 1, CircleSpin = 0, CircleTarget = "Self", CircleColor = "B8D5FF",
        AmbientParticles = false, AmbientRate = 25, AmbientColor = "BCD9FF",
        KillChams = false, NeonBurst = false, KillTarget = "Others", NeonColor = "B3D4FF", HitSound = false, HitSoundId = "", KillSound = false, KillSoundId = "", EffectVolume = 0.5,
    }
    local ranges = {Stars = {0, 7000}, FogDistance = {40, 3000}, BloomIntensity = {0, 2}, BlurSize = {0, 24}, AtmosphereDensity = {0, 0.8}, ClockTime = {0, 24}, ExposureValue = {-2, 2}, AuraGlow = {0, 1}, AuraRate = {0, 120}, AuraSize = {0.1, 4}, AuraLifetime = {0.3, 3}, AuraGrow = {25, 250}, AuraSpin = {0, 180}, TrailLifetime = {0.1, 3}, TrailWidth = {0.1, 4}, TrailBrightness = {0, 1}, ESPDistance = {25, 2000}, FOV = {40, 120}, CrosshairSize = {2, 15}, CrosshairGap = {0, 15}, PreviewSpeed = {0, 45}, Opacity = {0, 0.6}, MenuScale = {0.65, 1.25}, MusicVolume = {0, 1}, EmoteSpeed = {0.25, 2}}
    local choices = {Preset = {"Game", "Night", "Soft", "Cold", "Sunset"}, Celestial = {"Game", "Stars", "Hidden"}, AuraStyle = {"Ambient", "Angelic", "Flame", "Sparkles"}, TrailStyle = {"Sparkle", "Ribbon", "Smoke"}, Material = {"SmoothPlastic", "Neon", "ForceField"}, Keybind = {"Insert", "RightShift", "Home", "PageDown"}}
    for key,value in pairs({AuraRadius={0.5,4},AuraSpeed={0.2,6},TrailSize={1,12},TrailLength={1,20},TrailDensity={0,200},TrailSpread={0,100},TrailDrift={0,100},HatSize={1,8},HatHeight={-0.5,3},HatSpin={0,180},HaloRadius={0.5,4},HaloHeight={0,4},HaloTilt={-75,75},HaloSpin={0,180},GlyphCount={0,40},GlyphSpeed={0,100},GlyphTrail={0,100},GlyphLifetime={0.5,8},GlyphWidth={0.5,4},CircleSize={1,12},CircleLife={0.5,12},CircleGrow={25,300},CircleBrightness={0,1},CircleSpin={0,180},AmbientRate={0,100},EffectVolume={0,1}}) do ranges[key]=value end
    for key,value in pairs({Quality={"Auto","Low","High"},Skybox={"Game","Custom"},AuraTarget={"Self","Others"},TrailTarget={"Self","Others"},CosmeticTarget={"Self","Others"},CircleTarget={"Self","Others"},KillTarget={"Self","Others"},GlyphColorMode={"Single","Rainbow"},CircleStyle={"Konchal","Orbit","Pentagram"}}) do choices[key]=value end
    choices.AuraStyle={"Ambient","Angelic","Vortex","Flame","Sparkles"}
    choices.TrailStyle={"Sparkle","Snow","Stars","Ribbon","Smoke"}
    choices.Preset={"Game","Night","Soft","Cold","Sunset","Crimson"}
    local colorKeys = {AuraColor=true,TrailColor=true,ESPColor=true,TintColor=true,HatColor=true,HaloColor=true,GlyphColor=true,CircleColor=true,AmbientColor=true,NeonColor=true}
    for key, value in pairs(defaults) do App.State[key] = value end
    App.Defaults, App.Ranges, App.Choices = defaults, ranges, choices
    UI.Pages, UI.Tabs, UI.Cards, UI.Groups = {}, {}, {}, {}
    UI.Selected, UI.Yaw, UI.Scale, UI.Visible = "World", 0, 1, true
    FX.LightOwned, FX.SkyOwned, FX.Tints, FX.ESPObjects = {}, {}, {}, {}
    FX.Attachments, FX.EmoteTracks, FX.Post = {}, {}, {}

    function App:Normalize(key, value)
        local base = defaults[key]
        if base == nil or type(value) ~= type(base) then return nil end
        if type(value) == "number" then
            if value ~= value or math.abs(value) == math.huge then return nil end
            local range = ranges[key]
            if range then return math.clamp(value, range[1], range[2]) end
        elseif colorKeys[key] then
            value = value:gsub("#", ""):upper()
            if not value:match("^%x%x%x%x%x%x$") then return nil end
        elseif choices[key] then
            local found = false
            for _, item in ipairs(choices[key]) do if item == value then found = true break end end
            if not found then return nil end
        elseif key:match("Id$") then
            if #value > 22 or (value ~= "" and not value:match("^%d+$")) then return nil end
        end
        return value
    end
    function App:Subscribe(key, callback)
        self.Listeners[key] = self.Listeners[key] or {}
        table.insert(self.Listeners[key], callback)
        callback(self.State[key])
    end
    function App:Set(key, value, silent)
        value = self:Normalize(key, value)
        if value == nil then return false end
        if self.State[key] == value then return true end
        self.State[key] = value
        for _, callback in ipairs(self.Listeners[key] or {}) do callback(value) end
        if not silent then self:Apply(key) end
        return true
    end
    function App:ApplyAll()
        FX:World()
        FX:Character()
        FX:BuildVideo()
        FX:RefreshDeathHooks()
        FX:RefreshTint()
        FX:Camera()
        FX:RefreshESP()
        UI:RefreshPreviewStyle()
        UI:Fit()
        UI.Main.BackgroundTransparency = self.State.Opacity
        UI.PreviewPanel.BackgroundTransparency = self.State.Opacity
        UI.Watermark.Visible = self.State.Watermark
        UI.Crosshair.Visible = self.State.Crosshair
        UI:DrawCrosshair()
        UI.Artwork.Image=self.State.ArtworkId=="" and ("rbxthumb://type=Avatar&id="..player.UserId.."&w=420&h=420") or ("rbxassetid://"..self.State.ArtworkId)
        FX.Sound.Volume, FX.Sound.Looped = self.State.MusicVolume, self.State.MusicLoop
    end
    function App:Apply(key)
        if key:match("^Aura") or key:match("^Trail") or key == "Rainbow" then
            if key=="AuraStyle" then
                if self.State.AuraStyle=="Angelic" or self.State.AuraStyle=="Vortex" then self:Set("AuraAngelic",true,true) else self:Set("AuraAmbient",true,true) end
            end
            FX:ScheduleCharacter()
        elseif key:match("^Glyph") or key:match("^Hat") or key:match("^Halo") or key:match("^Circle") or key=="CosmeticTarget" or key=="AmbientParticles" or key=="AmbientRate" or key=="AmbientColor" then if not FX:UpdateVideoValues(key) then FX:ScheduleVideo() end
        elseif key=="Quality" then FX:ScheduleVideo() FX:ScheduleCharacter()
        elseif key:match("^Kill") or key:match("^HitSound") or key:match("^Neon") or key=="EffectVolume" then FX:RefreshDeathHooks()
        elseif key=="ArtworkId" then UI.Artwork.Image=self.State.ArtworkId=="" and ("rbxthumb://type=Avatar&id="..player.UserId.."&w=420&h=420") or ("rbxassetid://"..self.State.ArtworkId)
        elseif key:match("^ESP") then FX:RefreshESP()
        elseif key == "FOV" or key == "FOVEnabled" then FX:Camera()
        elseif key == "Tint" or key == "TintColor" or key == "Material" then FX:RefreshTint()
        elseif key == "Preview" or key == "Silhouette" then UI:RefreshPreviewStyle() UI:Fit()
        elseif key == "MenuScale" then UI:Fit()
        elseif key == "Opacity" then UI.Main.BackgroundTransparency = self.State.Opacity UI.PreviewPanel.BackgroundTransparency = self.State.Opacity
        elseif key == "Watermark" then UI.Watermark.Visible = self.State.Watermark
        elseif key:match("^Crosshair") then UI.Crosshair.Visible = self.State.Crosshair UI:DrawCrosshair()
        elseif key == "MusicVolume" then FX.Sound.Volume = self.State.MusicVolume
        elseif key == "MusicLoop" then FX.Sound.Looped = self.State.MusicLoop
        elseif key == "EmoteSpeed" then for _, track in ipairs(FX.EmoteTracks) do pcall(function() track:AdjustSpeed(self.State.EmoteSpeed) end) end
        elseif key ~= "MusicId" and key ~= "Keybind" and key ~= "PreviewSpin" and key ~= "PreviewSpeed" then FX:World() end
    end
    function UI:New(class, properties, parent)
        local object = Instance.new(class)
        if object:IsA("GuiObject") then object.BorderSizePixel = 0 end
        for key, value in pairs(properties or {}) do object[key] = value end
        object.Parent = parent
        return object
    end
    function UI:Corner(object, radius) self:New("UICorner", {CornerRadius = UDim.new(0, radius or 4)}, object) end
    function UI:Stroke(object, transparency) return self:New("UIStroke", {Color = C.Border, Thickness = 1, Transparency = transparency or 0.4}, object) end
    function UI:Text(parent, text, size, color, props)
        local properties = {Text = text, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = size or 11, TextColor3 = color or C.Text, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, 0, 0, 22)}
        for key, value in pairs(props or {}) do properties[key] = value end
        return self:New("TextLabel", properties, parent)
    end
    function UI:Line(parent, x1, y1, x2, y2, color, thickness)
        return self:New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2), Size = UDim2.fromOffset(math.sqrt((x2 - x1)^2 + (y2 - y1)^2), thickness or 1), Rotation = math.deg(math.atan2(y2 - y1, x2 - x1)), BackgroundColor3 = color or C.Muted}, parent)
    end
    local iconPaths = {
        globe = {{2,8,14,8},{8,2,8,14},{4,3,4,13},{12,3,12,13},{3,4,13,4},{3,12,13,12}},
        eye = {{1,8,5,4},{5,4,11,4},{11,4,15,8},{15,8,11,12},{11,12,5,12},{5,12,1,8},{8,6,8,10}},
        user = {{5,2,11,2},{11,2,11,7},{11,7,5,7},{5,7,5,2},{3,14,3,11},{3,11,6,9},{6,9,10,9},{10,9,13,11},{13,11,13,14}},
        screen = {{2,3,14,3},{14,3,14,11},{14,11,2,11},{2,11,2,3},{8,11,8,14},{5,14,11,14}},
        shirt = {{2,4,5,2},{5,2,7,4},{7,4,9,4},{9,4,11,2},{11,2,14,4},{14,4,12,7},{12,7,11,6},{11,6,11,14},{11,14,5,14},{5,14,5,6},{5,6,4,7},{4,7,2,4}},
        cube = {{2,5,8,2},{8,2,14,5},{14,5,8,8},{8,8,2,5},{2,5,2,12},{2,12,8,15},{8,15,14,12},{14,12,14,5},{8,8,8,15}},
        gear = {{5,3,11,3},{11,3,14,7},{14,7,11,13},{11,13,5,13},{5,13,2,7},{2,7,5,3},{6,6,10,6},{10,6,10,10},{10,10,6,10},{6,10,6,6}},
        music = {{6,12,6,3},{6,3,13,2},{13,2,13,11},{3,12,6,12},{3,12,3,14},{3,14,6,14},{6,14,6,12},{10,11,13,11},{10,11,10,13},{10,13,13,13}},
        sliders = {{2,4,14,4},{2,8,14,8},{2,12,14,12},{5,2,5,6},{11,6,11,10},{7,10,7,14}},
        motion = {{8,1,8,3},{4,6,8,5},{8,5,12,7},{8,5,7,10},{7,10,3,14},{7,10,12,14}},
        tool = {{3,2,3,6},{3,6,6,6},{6,6,12,13},{12,13,14,11},{14,11,7,5},{7,5,7,2}},
        search = {{3,3,10,3},{10,3,12,6},{12,6,10,10},{10,10,4,10},{4,10,2,7},{2,7,3,3},{10,10,15,15}},
    }
    function UI:Icon(parent, kind, x, y, color)
        local icon = self:New("Frame", {Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(x, y), BackgroundTransparency = 1}, parent)
        for _, path in ipairs(iconPaths[kind] or iconPaths.sliders) do self:Line(icon, path[1], path[2], path[3], path[4], color) end
        return icon
    end
    function UI:Tween(object, goal, duration)
        local tween = TweenService:Create(object, TweenInfo.new(duration or 0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
        tween:Play()
        return tween
    end
    function UI:Click(parent, text, callback, props)
        local properties = {Text = text or "", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = C.Text, BackgroundColor3 = Color3.fromRGB(19, 19, 24), AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 28)}
        for key, value in pairs(props or {}) do properties[key] = value end
        local button = self:New("TextButton", properties, parent)
        self:Corner(button, 3)
        App:Connect(button.Activated, function() local ok, err = pcall(callback) if not ok then self:Toast(tostring(err):sub(1, 100)) end end, button)
        return button
    end
    function UI:Toast(message)
        if not App.Active or not self.ToastLabel then return end
        self.ToastSerial = (self.ToastSerial or 0) + 1
        local serial = self.ToastSerial
        self.ToastLabel.Text, self.ToastLabel.Visible = tostring(message), true
        task.delay(3.5, function() if App.Active and self.ToastSerial == serial then self.ToastLabel.Visible = false end end)
    end
    function UI:Row(card, name, height)
        local row = self:New("Frame", {Name = name, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, height or 25), LayoutOrder = #card.Rows + 1}, card.Body)
        row:SetAttribute("Search", name:lower())
        table.insert(card.Rows, row)
        return row
    end
    function UI:Card(column, title)
        local container = self:New("Frame", {Name = title, BackgroundColor3 = C.Card, BackgroundTransparency = 0.4, Size = UDim2.new(1, -2, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = #self.Cards + 1}, column)
        self:Corner(container, 3)
        self:New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, container)
        local header = self:Click(container, "", function() end, {Name = "Header", LayoutOrder = 0, Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1})
        self:Text(header, title, 11, C.Text, {Position = UDim2.fromOffset(7, 0), Size = UDim2.new(1, -30, 1, 0), Font = Enum.Font.GothamMedium})
        local arrow = self:Text(header, "⌃", 12, C.Dim, {Position = UDim2.new(1, -22, 0, 0), Size = UDim2.fromOffset(17, 26), TextXAlignment = Enum.TextXAlignment.Center})
        self:New("Frame", {Position = UDim2.new(0, 7, 1, -1), Size = UDim2.new(1, -14, 0, 1), BackgroundColor3 = C.Border, BackgroundTransparency = 0.2}, header)
        local body = self:New("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1}, container)
        self:New("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7)}, body)
        self:New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)}, body)
        local card = {Frame = container, Body = body, Rows = {}, Title = title, Open = true}
        App:Connect(header.Activated, function() card.Open = not card.Open body.Visible = card.Open arrow.Text = card.Open and "⌃" or "⌄" end)
        table.insert(self.Cards, card)
        return card
    end
    function UI:Toggle(card, title, key)
        local row = self:Row(card, title, 25)
        local hit = self:Click(row, "", function() App:Set(key, not App.State[key]) end, {Name = key, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1})
        local box = self:New("Frame", {Size = UDim2.fromOffset(13, 13), Position = UDim2.fromOffset(0, 6), BackgroundColor3 = C.Card}, hit)
        self:Corner(box, 3) self:Stroke(box, 0.12)
        local tick = self:Text(box, "✓", 11, C.Panel, {Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold})
        local label = self:Text(hit, title, 11, C.Muted, {Position = UDim2.fromOffset(21, 0), Size = UDim2.new(1, -42, 1, 0)})
        self:Text(hit, "···", 13, C.Dim, {Position = UDim2.new(1, -17, 0, 0), Size = UDim2.fromOffset(17, 24), TextXAlignment = Enum.TextXAlignment.Right})
        App:Subscribe(key, function(value) box.BackgroundColor3 = value and C.White or C.Card tick.Visible = value label.TextColor3 = value and C.Text or C.Muted end)
    end
    function UI:Slider(card, title, key, step, suffix, requiredKey, multiplier)
        local row = self:Row(card, title, 35)
        if requiredKey then row:SetAttribute("Requires",requiredKey) App:Subscribe(requiredKey,function() self:Filter(self.Search.Text) end) end
        self:Text(row, title, 10, C.Muted, {Size = UDim2.new(0.65, 0, 0, 17)})
        local valueLabel = self:Text(row, "", 10, C.Text, {Position = UDim2.fromScale(0.6, 0), Size = UDim2.new(0.4, 0, 0, 17), TextXAlignment = Enum.TextXAlignment.Right})
        local track = self:New("Frame", {Position = UDim2.fromOffset(0, 23), Size = UDim2.new(1, 0, 0, 4), BackgroundColor3 = Color3.fromRGB(23, 23, 28)}, row)
        self:Corner(track, 2)
        local fill = self:New("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.White}, track) self:Corner(fill, 2)
        local hit = self:Click(row, "", function() end, {Name = key, Position = UDim2.fromOffset(0, 14), Size = UDim2.new(1, 0, 0, 21), BackgroundTransparency = 1})
        local range = ranges[key]
        local function update(position)
            if track.AbsoluteSize.X <= 0 then return end
            local ratio = math.clamp((position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local value = range[1] + ratio * (range[2] - range[1])
            value = math.floor(value / step + 0.5) * step
            App:Set(key, value)
        end
        App:Connect(hit.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if UI.Popup then UI:ClosePopup() end
                UI.Pointer = {Input = input, Move = update}
                update(input.Position)
            end
        end)
        App:Subscribe(key, function(value)
            fill.Size = UDim2.fromScale((value - range[1]) / (range[2] - range[1]), 1)
            local displayStep=step*(multiplier or 1)
            local digits = displayStep < 0.1 and 2 or (displayStep < 1 and 1 or 0)
            valueLabel.Text = string.format("%." .. digits .. "f", value*(multiplier or 1)) .. (suffix or "")
        end)
    end
    function UI:Condition(card,key,value)
        local row=card.Rows[#card.Rows]
        row:SetAttribute("Requires",key) row:SetAttribute("RequiresValue",value==nil and true or value)
        App:Subscribe(key,function() self:Filter(self.Search.Text) end)
    end
    function UI:MultiSelect(card,title,entries)
        local row=self:Row(card,title,25)
        self:Text(row,title,10,C.Muted,{Size=UDim2.new(0.3,0,1,0)})
        local button
        local function update()
            local selected={} for _,entry in ipairs(entries) do if App.State[entry[2]] then selected[#selected+1]=entry[1] end end
            button.Text=#selected>0 and table.concat(selected,", ") or "None"
        end
        button=self:Click(row,"",function()
            local popup=self:PopupAt(button,186,#entries*27+8)
            for index,entry in ipairs(entries) do
                local option
                local function label() return (App.State[entry[2]] and "✓  " or "□  ")..entry[1] end
                option=self:Click(popup,label(),function() App:Set(entry[2],not App.State[entry[2]]) option.Text=label() end,{Position=UDim2.fromOffset(5,4+(index-1)*27),Size=UDim2.new(1,-10,0,26),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=82})
            end
        end,{Position=UDim2.fromScale(0.32,0),Size=UDim2.new(0.68,0,0,22),BackgroundTransparency=0.55,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
        self:New("UIPadding",{PaddingLeft=UDim.new(0,5),PaddingRight=UDim.new(0,5)},button)
        for _,entry in ipairs(entries) do App:Subscribe(entry[2],update) end
    end

    function UI:IdField(card,title,key)
        local box
        box=self:Textbox(card,title,App.State[key],function(value) if not App:Set(key,value) then box.Text=App.State[key] self:Toast("Informe apenas o ID numerico do recurso") end end)
        App:Subscribe(key,function(value) box.Text=value end) return box
    end
    function UI:ClosePopup()
        if self.Popup then self.Popup:Destroy() self.Popup = nil end
        if self.PopupConnection then self.PopupConnection:Disconnect() self.PopupConnection = nil end
        self.Pointer = nil
    end
    function UI:PopupAt(anchor, width, height)
        self:ClosePopup()
        local blocker = self:Click(self.Gui, "", function() self:ClosePopup() end, {Name = "PopupOverlay", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 80})
        local panel = self:New("Frame", {Name = "Popup", Size = UDim2.fromOffset(width, height), BackgroundColor3 = Color3.fromRGB(13, 13, 18), ZIndex = 81}, blocker)
        self:Corner(panel, 4) self:Stroke(panel, 0.1)
        self:New("UIScale", {Scale = self.Scale}, panel)
        self.Popup = blocker
        local rootPos, rootSize = self.Gui.AbsolutePosition, self.Gui.AbsoluteSize
        local x = math.clamp(anchor.AbsolutePosition.X - rootPos.X, 4, math.max(4, rootSize.X - width * self.Scale - 4))
        local y = anchor.AbsolutePosition.Y + anchor.AbsoluteSize.Y - rootPos.Y + 3
        if y + height * self.Scale > rootSize.Y - 4 then y = anchor.AbsolutePosition.Y - rootPos.Y - height * self.Scale - 3 end
        panel.Position = UDim2.fromOffset(x, math.max(4, y))
        return panel
    end
    function UI:Dropdown(card, title, key)
        local row = self:Row(card, title, 25)
        self:Text(row, title, 10, C.Muted, {Size = UDim2.new(0.42, 0, 1, 0)})
        local button
        button = self:Click(row, "", function()
            local list = choices[key]
            local popup = self:PopupAt(button, 174, #list * 26 + 8)
            for index, value in ipairs(list) do
                self:Click(popup, value, function() App:Set(key, value) self:ClosePopup() end, {Position = UDim2.fromOffset(4, 4 + (index - 1) * 26), Size = UDim2.new(1, -8, 0, 25), BackgroundTransparency = value == App.State[key] and 0 or 1, ZIndex = 82, TextXAlignment = Enum.TextXAlignment.Left})
            end
        end, {Name = key, Position = UDim2.fromScale(0.43, 0), Size = UDim2.new(0.57, 0, 0, 22), BackgroundTransparency = 0.55, TextXAlignment = Enum.TextXAlignment.Left})
        self:New("UIPadding", {PaddingLeft = UDim.new(0, 6)}, button)
        self:Text(button, "⌄", 10, C.Dim, {Position = UDim2.new(1, -19, 0, 0), Size = UDim2.fromOffset(14, 21), TextXAlignment = Enum.TextXAlignment.Center})
        App:Subscribe(key, function(value) button.Text = value end)
    end
    function UI:Color(card, title, key)
        local row = self:Row(card, title, 26)
        self:Text(row, title, 10, C.Muted, {Size = UDim2.new(1, -41, 1, 0)})
        local swatch
        swatch = self:Click(row, "", function()
            local popup = self:PopupAt(swatch, 196, 204)
            local h, s, v = Color3.fromHex(App.State[key]):ToHSV()
            local square = self:New("TextButton", {Text = "", AutoButtonColor = false, Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(176, 130), BackgroundColor3 = Color3.fromHSV(h, 1, 1), ZIndex = 82}, popup) self:Corner(square, 3)
            local white = self:New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 83}, square)
            self:New("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})}, white)
            local black = self:New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(), ZIndex = 84}, square)
            self:New("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})}, black)
            local cursor = self:New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(s, 1-v), Size = UDim2.fromOffset(7, 7), BackgroundTransparency = 1, ZIndex = 85}, square) self:Corner(cursor, 8)
            self:New("UIStroke", {Color = C.White, Thickness = 1}, cursor)
            local hue = self:New("TextButton", {Text = "", AutoButtonColor = false, Position = UDim2.fromOffset(10, 151), Size = UDim2.fromOffset(176, 10), BackgroundColor3 = C.White, ZIndex = 82}, popup) self:Corner(hue, 4)
            self:New("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(1/6,Color3.fromHSV(1/6,1,1)),ColorSequenceKeypoint.new(2/6,Color3.fromHSV(2/6,1,1)),ColorSequenceKeypoint.new(3/6,Color3.fromHSV(3/6,1,1)),ColorSequenceKeypoint.new(4/6,Color3.fromHSV(4/6,1,1)),ColorSequenceKeypoint.new(5/6,Color3.fromHSV(5/6,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1))})}, hue)
            local hueMarker = self:New("Frame", {Position = UDim2.fromScale(h, 0), Size = UDim2.fromOffset(2, 10), BackgroundColor3 = C.White, ZIndex = 83}, hue)
            local hex = self:New("TextBox", {Text = "#" .. App.State[key], ClearTextOnFocus = false, Position = UDim2.fromOffset(10, 174), Size = UDim2.fromOffset(176, 22), Font = Enum.Font.Code, TextSize = 11, TextColor3 = C.Text, BackgroundColor3 = C.Panel, ZIndex = 82}, popup) self:Corner(hex, 3)
            local function changed() square.BackgroundColor3 = Color3.fromHSV(h,1,1) cursor.Position = UDim2.fromScale(s,1-v) hueMarker.Position = UDim2.fromScale(h,0) local value=Color3.fromHSV(h,s,v):ToHex():upper() hex.Text="#"..value App:Set(key,value) end
            local function bindDrag(object, callback)
                App:Connect(object.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then UI.Pointer={Input=input,Move=callback} callback(input.Position) end
                end, object)
            end
            bindDrag(square, function(pos) s=math.clamp((pos.X-square.AbsolutePosition.X)/math.max(1,square.AbsoluteSize.X),0,1) v=1-math.clamp((pos.Y-square.AbsolutePosition.Y)/math.max(1,square.AbsoluteSize.Y),0,1) changed() end)
            bindDrag(hue, function(pos) h=math.clamp((pos.X-hue.AbsolutePosition.X)/math.max(1,hue.AbsoluteSize.X),0,1) changed() end)
            App:Connect(hex.FocusLost, function() if App:Set(key,hex.Text) then h,s,v=Color3.fromHex(App.State[key]):ToHSV() changed() else hex.Text="#"..App.State[key] end end, hex)
        end, {Name = key, Position = UDim2.new(1, -27, 0, 5), Size = UDim2.fromOffset(27, 15)})
        App:Subscribe(key, function(value) swatch.BackgroundColor3 = Color3.fromHex(value) end)
    end
    function UI:Button(card, title, callback)
        local row = self:Row(card, title, 31)
        return self:Click(row, title, callback, {Size = UDim2.new(1, 0, 0, 27)})
    end
    function UI:Textbox(card, title, initial, callback)
        local row = self:Row(card, title, 46)
        self:Text(row, title, 10, C.Muted, {Size = UDim2.new(1,0,0,17)})
        local box = self:New("TextBox", {Text = initial, ClearTextOnFocus = false, Position = UDim2.fromOffset(0,19), Size = UDim2.new(1,0,0,24), BackgroundColor3=C.Panel, TextColor3=C.Text, Font=Enum.Font.Code, TextSize=11, PlaceholderColor3=C.Muted},row) self:Corner(box,3)
        App:Connect(box.FocusLost,function() callback(box.Text) end)
        return box
    end
    function UI:Page(name)
        local page = self:New("CanvasGroup", {Name = name, Visible = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1,1)}, self.Content)
        local columns = {}
        for index=1,2 do
            local col = self:New("ScrollingFrame", {Name="Column"..index, BackgroundTransparency=1, Position=UDim2.new((index-1)*0.5,(index-1)*4,0,0), Size=UDim2.new(0.5,-5,1,0), ScrollBarThickness=2, ScrollBarImageColor3=C.Muted, ScrollBarImageTransparency=0.65, CanvasSize=UDim2.new(), ScrollingDirection=Enum.ScrollingDirection.Y, AutomaticCanvasSize=Enum.AutomaticSize.Y, BorderSizePixel=0},page)
            self:New("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},col)
            self:New("UIPadding",{PaddingBottom=UDim.new(0,8),PaddingRight=UDim.new(0,3)},col)
            columns[index]=col
        end
        self.Pages[name] = page
        return columns[1], columns[2]
    end
    function UI:Select(name)
        if not self.Pages[name] then return end
        self:ClosePopup()
        if self.Fade then self.Fade:Cancel() end
        for title,page in pairs(self.Pages) do page.Visible = title == name end
        for title,tab in pairs(self.Tabs) do tab.Marker.Visible=title==name tab.Label.TextColor3=title==name and C.White or C.Muted tab.Button.BackgroundTransparency=title==name and 0.6 or 1 end
        self.Selected = name
        local page = self.Pages[name]
        page.GroupTransparency = 0.75
        self.Fade = self:Tween(page,{GroupTransparency=0},0.12)
        self:Filter(self.Search.Text)
    end
    function UI:Filter(query)
        query = tostring(query):lower()
        for _,card in ipairs(self.Cards) do
            local any = false
            local titleMatch = card.Title:lower():find(query,1,true) ~= nil
            for _,row in ipairs(card.Rows) do
                local matches = titleMatch or (row:GetAttribute("Search") or ""):find(query,1,true) ~= nil
                local required=row:GetAttribute("Requires")
                local expected=row:GetAttribute("RequiresValue")
                row.Visible = matches and (not required or App.State[required]==(expected==nil and true or expected) or query~="")
                any = any or row.Visible
            end
            card.Frame.Visible = any or (#card.Rows==0 and query=="")
            card.Body.Visible = query ~= "" or card.Open
        end
    end

    -- Screen and shell: 660 x 520 plus a separate 210 px avatar preview.
    UI.Gui = UI:New("ScreenGui",{Name="DeltaReferencePanel",ResetOnSpawn=false,IgnoreGuiInset=false,DisplayOrder=80,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},nil)
    App:AddCleanup(function() UI:ClosePopup() UI.Gui:Destroy() end)
    local parent = player:WaitForChild("PlayerGui",10)
    if type(gethui)=="function" then local ok, value=pcall(gethui) if ok and typeof(value)=="Instance" then parent=value end end
    assert(parent,"PlayerGui indisponivel. Tente depois que o personagem carregar.")
    local parentOk=pcall(function() UI.Gui.Parent=parent end)
    if not parentOk then UI.Gui.Parent=player:WaitForChild("PlayerGui") end
    UI.Root=UI:New("Frame",{Name="Window",BackgroundTransparency=1,Size=UDim2.fromOffset(880,520),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.48)},UI.Gui)
    UI.UIScale=UI:New("UIScale",{Scale=1},UI.Root)
    UI.Main=UI:New("Frame",{Name="Main",Size=UDim2.fromOffset(660,520),BackgroundColor3=C.Panel,BackgroundTransparency=App.State.Opacity},UI.Root) UI:Corner(UI.Main,6) UI:Stroke(UI.Main,0.22)
    UI.Sidebar=UI:New("Frame",{Name="Sidebar",Size=UDim2.fromOffset(140,520),BackgroundTransparency=1},UI.Main)
    UI:New("Frame",{Position=UDim2.fromOffset(140,10),Size=UDim2.new(0,1,1,-20),BackgroundColor3=C.Border,BackgroundTransparency=0.5},UI.Main)
    UI.Artwork=UI:New("ImageLabel",{Name="AvatarArtwork",Image="rbxthumb://type=Avatar&id="..player.UserId.."&w=420&h=420",BackgroundTransparency=1,Position=UDim2.fromOffset(15,3),Size=UDim2.fromOffset(110,142),ScaleType=Enum.ScaleType.Fit},UI.Sidebar)
    local nav=UI:New("ScrollingFrame",{Name="Categories",Position=UDim2.fromOffset(6,152),Size=UDim2.fromOffset(128,304),BackgroundTransparency=1,ScrollBarThickness=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y},UI.Sidebar)
    UI:New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,1)},nav)
    local navOrder=0
    local function group(title, entries)
        navOrder=navOrder+1
        local header=UI:Click(nav,"",function() end,{Size=UDim2.new(1,0,0,26),LayoutOrder=navOrder,BackgroundTransparency=1})
        UI:Icon(header,title=="VISUALS" and "eye" or "gear",6,5,C.Dim)
        UI:Text(header,title,10,C.Muted,{Position=UDim2.fromOffset(27,0),Size=UDim2.new(1,-44,1,0),Font=Enum.Font.GothamMedium})
        local arrow=UI:Text(header,"⌃",11,C.Dim,{Position=UDim2.new(1,-17,0,0),Size=UDim2.fromOffset(13,26)})
        local items={}
        local open=true
        for _,entry in ipairs(entries) do
            navOrder=navOrder+1
            local button=UI:Click(nav,"",function() UI:Select(entry[1]) end,{Name=entry[1],Size=UDim2.new(1,0,0,24),LayoutOrder=navOrder,BackgroundTransparency=1,BackgroundColor3=Color3.fromRGB(21,21,25)})
            UI:Icon(button,entry[2],12,4,C.Muted)
            local label=UI:Text(button,entry[1],11,C.Muted,{Position=UDim2.fromOffset(34,0),Size=UDim2.new(1,-36,1,0),Font=Enum.Font.GothamMedium})
            local marker=UI:New("Frame",{Visible=false,Position=UDim2.fromOffset(1,6),Size=UDim2.fromOffset(2,12),BackgroundColor3=C.White},button)
            UI.Tabs[entry[1]]={Button=button,Label=label,Marker=marker}
            items[#items+1]=button
        end
        App:Connect(header.Activated,function() open=not open for _,button in ipairs(items) do button.Visible=open end arrow.Text=open and "⌃" or "⌄" end)
    end
    group("VISUALS",{{"ESP","user"},{"World","globe"},{"Screen","screen"},{"Skins","shirt"},{"Models","cube"}})
    group("MISC",{{"Emotes","motion"},{"Animations","motion"},{"Helpers","tool"},{"Menu","sliders"},{"Music","music"}})
    UI.ProfileIcon=UI:New("ImageLabel",{Image="rbxthumb://type=AvatarHeadShot&id="..player.UserId.."&w=150&h=150",BackgroundColor3=C.Card,Position=UDim2.fromOffset(12,477),Size=UDim2.fromOffset(29,29)},UI.Sidebar)
    UI.ProfileName=UI:Text(UI.Sidebar,player.DisplayName,10,C.Text,{Position=UDim2.fromOffset(47,475),Size=UDim2.fromOffset(83,17),Font=Enum.Font.GothamMedium})
    UI.ProfileUser=UI:Text(UI.Sidebar,"@"..player.Name,9,C.Muted,{Position=UDim2.fromOffset(47,490),Size=UDim2.fromOffset(83,16)})
    local top=UI:New("Frame",{Name="DragBar",BackgroundTransparency=1,Active=true,Position=UDim2.fromOffset(149,0),Size=UDim2.fromOffset(435,37)},UI.Main)
    UI.Search=UI:New("TextBox",{Name="Search",Text="",PlaceholderText="Search",ClearTextOnFocus=false,BackgroundTransparency=1,Position=UDim2.fromOffset(263,4),Size=UDim2.fromOffset(142,28),Font=Enum.Font.Gotham,TextSize=10,TextColor3=C.Text,PlaceholderColor3=C.Dim,TextXAlignment=Enum.TextXAlignment.Left},top)
    UI:Icon(top,"search",414,10,C.Muted)
    UI:Click(top,"Blue look",function() App:VideoLook("Blue") end,{Name="VideoLook",Position=UDim2.fromOffset(5,5),Size=UDim2.fromOffset(73,25),BackgroundTransparency=1,TextSize=10,TextColor3=C.Muted})
    UI:New("Frame",{Position=UDim2.fromOffset(153,38),Size=UDim2.fromOffset(494,1),BackgroundColor3=C.Border,BackgroundTransparency=0.5},UI.Main)
    UI:Click(UI.Main,"−",function() UI:ToggleWindow(false) end,{Name="Minimize",Position=UDim2.fromOffset(590,5),Size=UDim2.fromOffset(27,27),TextSize=17,BackgroundTransparency=1})
    UI:Click(UI.Main,"×",function() UI:ToggleWindow(false) end,{Name="Hide",Position=UDim2.fromOffset(621,5),Size=UDim2.fromOffset(27,27),TextSize=17,BackgroundTransparency=1})
    UI.Content=UI:New("Frame",{Name="Content",Position=UDim2.fromOffset(153,47),Size=UDim2.fromOffset(495,462),BackgroundTransparency=1},UI.Main)
    UI.PreviewPanel=UI:New("Frame",{Name="AvatarPreview",Position=UDim2.fromOffset(670,0),Size=UDim2.fromOffset(210,520),BackgroundColor3=C.Panel,BackgroundTransparency=App.State.Opacity},UI.Root) UI:Corner(UI.PreviewPanel,6) UI:Stroke(UI.PreviewPanel,0.22)
    UI:Icon(UI.PreviewPanel,"user",10,9,C.Muted)
    UI:Text(UI.PreviewPanel,player.DisplayName,10,C.Text,{Position=UDim2.fromOffset(31,4),Size=UDim2.fromOffset(167,26),Font=Enum.Font.GothamMedium})
    UI:New("Frame",{Position=UDim2.fromOffset(9,33),Size=UDim2.fromOffset(192,1),BackgroundColor3=C.Border,BackgroundTransparency=0.45},UI.PreviewPanel)
    UI.Viewport=UI:New("ViewportFrame",{Name="Character",Position=UDim2.fromOffset(5,44),Size=UDim2.fromOffset(200,435),BackgroundTransparency=1,Ambient=Color3.fromRGB(230,230,230),LightColor=Color3.new(1,1,1),LightDirection=Vector3.new(-1,-0.5,-1),Active=true},UI.PreviewPanel)
    UI.PreviewWorld=UI:New("WorldModel",{},UI.Viewport)
    UI.PreviewCamera=UI:New("Camera",{FieldOfView=35},UI.Viewport) UI.Viewport.CurrentCamera=UI.PreviewCamera
    UI.PreviewHint=UI:Text(UI.PreviewPanel,"drag to rotate",9,C.Dim,{Position=UDim2.fromOffset(9,486),Size=UDim2.fromOffset(192,22),TextXAlignment=Enum.TextXAlignment.Center})
    local brackets=UI:New("Frame",{Name="Brackets",BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.55),Size=UDim2.fromOffset(140,245)},UI.PreviewPanel)
    UI.BracketScale=UI:New("UIScale",{Scale=1},brackets)
    for _,entry in ipairs({{0,0,1,1},{140,0,-1,1},{0,245,1,-1},{140,245,-1,-1}}) do UI:Line(brackets,entry[1],entry[2],entry[1]+entry[3]*18,entry[2],C.Muted) UI:Line(brackets,entry[1],entry[2],entry[1],entry[2]+entry[4]*24,C.Muted) end
    UI.Float=UI:Click(UI.Gui,"≡",function() UI:ToggleWindow(not UI.Visible) end,{Name="OpenPanel",Position=UDim2.fromOffset(12,100),Size=UDim2.fromOffset(38,38),BackgroundColor3=C.Panel,TextSize=21,ZIndex=30}) UI:Corner(UI.Float,10) UI:Stroke(UI.Float,0.15)
    UI.Watermark=UI:Text(UI.Gui,"DELTA / 0.3.0",10,C.Text,{Name="Watermark",Position=UDim2.new(1,-310,0,7),Size=UDim2.fromOffset(296,23),TextXAlignment=Enum.TextXAlignment.Right})
    UI.ToastLabel=UI:Text(UI.Gui,"",11,C.Text,{Name="Notification",Visible=false,AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-12),Size=UDim2.fromOffset(390,34),TextXAlignment=Enum.TextXAlignment.Center,BackgroundColor3=C.Card,BackgroundTransparency=0.05,ZIndex=90}) UI:Corner(UI.ToastLabel,5) UI:Stroke(UI.ToastLabel,0.25)
    UI.Crosshair=UI:New("Frame",{Name="Crosshair",Visible=false,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(1,1),BackgroundTransparency=1},UI.Gui)
    function UI:DrawCrosshair()
        self.Crosshair:ClearAllChildren()
        local length,gap=App.State.CrosshairSize,App.State.CrosshairGap
        self:Line(self.Crosshair,-gap-length,0,-gap,0,C.White) self:Line(self.Crosshair,gap,0,gap+length,0,C.White)
        self:Line(self.Crosshair,0,-gap-length,0,-gap,C.White) self:Line(self.Crosshair,0,gap,0,gap+length,C.White)
    end
    function UI:Fit()
        if not self.Gui or not self.Root then return end
        local camera=workspace.CurrentCamera
        local size=self.Gui.AbsoluteSize
        if size.X<1 or size.Y<1 then size=camera and camera.ViewportSize or Vector2.new(800,600) end
        local width=App.State.Preview and 880 or 660
        local scale=math.min(App.State.MenuScale,(size.X-22)/width)
        self.Scale=math.max(0.1,scale) self.UIScale.Scale=self.Scale
        local height=math.min(520,math.max(240,(size.Y-24)/self.Scale))
        self.Height=height
        self.Root.Size=UDim2.fromOffset(width,height) self.Main.Size=UDim2.fromOffset(660,height) self.Sidebar.Size=UDim2.fromOffset(140,height)
        nav.Size=UDim2.fromOffset(128,math.max(45,height-216))
        self.ProfileIcon.Position=UDim2.fromOffset(12,height-43) self.ProfileName.Position=UDim2.fromOffset(47,height-45) self.ProfileUser.Position=UDim2.fromOffset(47,height-30)
        self.Content.Size=UDim2.fromOffset(495,height-58) self.PreviewPanel.Size=UDim2.fromOffset(210,height) self.PreviewPanel.Visible=App.State.Preview
        self.Viewport.Size=UDim2.fromOffset(200,height-85) self.PreviewHint.Position=UDim2.fromOffset(9,height-34)
        self.BracketScale.Scale=math.min(1,(height-85)/370)
        if self.Popup then self:ClosePopup() end
        local center=self.Root.Position
        local halfW,halfH=width*self.Scale/2,height*self.Scale/2
        local x=math.clamp(size.X*center.X.Scale+center.X.Offset,halfW+8,math.max(halfW+8,size.X-halfW-8))
        local y=math.clamp(size.Y*center.Y.Scale+center.Y.Offset,halfH+8,math.max(halfH+8,size.Y-halfH-8))
        self.Root.Position=UDim2.fromOffset(x,y)
        if self.FramePreview then self:FramePreview() end
    end
    function UI:ToggleWindow(visible)
        self.Visible=visible self.Root.Visible=visible self:ClosePopup()
    end
    local function dragStart(input)
        if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
        if Input:GetFocusedTextBox() then return end
        local begin=input.Position
        local initial=UI.Root.Position
        UI.Pointer={Input=input,Move=function(pos) local delta=pos-begin UI.Root.Position=UDim2.new(initial.X.Scale,initial.X.Offset+delta.X,initial.Y.Scale,initial.Y.Offset+delta.Y) UI:Fit() end}
    end
    App:Connect(top.InputBegan,dragStart)
    App:Connect(UI.PreviewPanel.InputBegan,function(input) if input.Position.Y-UI.PreviewPanel.AbsolutePosition.Y<35 then dragStart(input) end end)
    App:Connect(UI.Viewport.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            local x,yaw=input.Position.X,UI.Yaw UI.Pointer={Input=input,Move=function(pos) UI.Yaw=yaw+(pos.X-x)*0.012 UI:RotatePreview() end}
        end
    end)
    App:Connect(Input.InputChanged,function(input)
        local pointer=UI.Pointer
        if pointer and (input==pointer.Input or (pointer.Input.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement)) then pointer.Move(input.Position) end
    end)
    App:Connect(Input.InputEnded,function(input) if UI.Pointer and input==UI.Pointer.Input then UI.Pointer=nil end end)
    App:Connect(Input.InputBegan,function(input,processed)
        if not processed and not Input:GetFocusedTextBox() and input.KeyCode==Enum.KeyCode[App.State.Keybind] then UI:ToggleWindow(not UI.Visible) end
    end)
    App:Connect(UI.Gui:GetPropertyChangedSignal("AbsoluteSize"),function() UI:Fit() end)
    App:Connect(UI.Search:GetPropertyChangedSignal("Text"),function() UI:Filter(UI.Search.Text) end)
    App:AddCleanup(function() if UI.Fade then UI.Fade:Cancel() end end)

    function UI:RotatePreview()
        if self.PreviewModel and self.PreviewModel.Parent then self.PreviewModel:PivotTo(CFrame.Angles(0,self.Yaw,0)) end
    end
    function UI:RefreshPreviewStyle()
        if not self.PreviewModel then return end
        for part,original in pairs(self.PreviewAppearance or {}) do
            if part.Parent then part.Color=App.State.Silhouette and C.White or original.Color part.Material=App.State.Silhouette and Enum.Material.SmoothPlastic or original.Material if original.TextureID then part.TextureID=App.State.Silhouette and "" or original.TextureID end end
        end
        for object,original in pairs(self.PreviewDetails or {}) do
            if original.TextureId~=nil then object.TextureId=App.State.Silhouette and "" or original.TextureId
            elseif object.Parent or original.Parent then object.Parent=App.State.Silhouette and self.PreviewHidden or original.Parent end
        end
        if self.RefreshPreviewCosmetics then self:RefreshPreviewCosmetics() end
    end
    function UI:RefreshPreview()
        if self.PreviewModel then self.PreviewModel:Destroy() self.PreviewModel=nil end
        if self.PreviewHidden then self.PreviewHidden:Destroy() end
        self.PreviewAppearance,self.PreviewDetails={},{}
        self.PreviewBox,self.PreviewSize=nil,nil
        self.PreviewHidden=self:New("Folder",{Name="HiddenAppearance"},self.Viewport)
        local character=player.Character
        if not character then self.PreviewHint.Text="aguardando personagem" return end
        local old=character.Archivable
        local ok,clone=pcall(function() character.Archivable=true return character:Clone() end)
        character.Archivable=old
        if not ok or not clone then self.PreviewHint.Text="avatar indisponivel" return end
        for _,object in ipairs(clone:GetDescendants()) do
            if object:IsA("BaseScript") or object:IsA("ModuleScript") or object:IsA("Sound") or object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("BillboardGui") or object:IsA("Highlight") then object:Destroy()
            elseif object:IsA("BasePart") then
                object.Anchored=true object.CanCollide=false object.CanTouch=false object.CanQuery=false
                self.PreviewAppearance[object]={Color=object.Color,Material=object.Material,TextureID=object:IsA("MeshPart") and object.TextureID or nil}
                if object.Name=="HumanoidRootPart" then object.Transparency=1 end
            elseif object:IsA("Decal") or object:IsA("Texture") or object:IsA("SurfaceAppearance") or object:IsA("Shirt") or object:IsA("Pants") or object:IsA("ShirtGraphic") then self.PreviewDetails[object]={Parent=object.Parent}
            elseif object:IsA("SpecialMesh") then self.PreviewDetails[object]={Parent=object.Parent,TextureId=object.TextureId} end
        end
        clone.Name="PreviewCharacter" clone.Parent=self.PreviewWorld
        self.PreviewModel=clone self.Yaw=0 self:RotatePreview() self:RefreshPreviewStyle()
        local box,size=clone:GetBoundingBox()
        self.PreviewBox,self.PreviewSize=box.Position,size
        self:FramePreview()
        self.PreviewHint.Text="drag to rotate"
    end

    function UI:FramePreview()
        if not self.PreviewBox or not self.PreviewSize then return end
        local aspect=200/math.max(100,(self.Height or 520)-85)
        local size=self.PreviewSize
        local distance=math.max(size.Y,size.X/aspect)/(2*math.tan(math.rad(35/2)))*1.16
        self.PreviewCamera.CFrame=CFrame.lookAt(self.PreviewBox+Vector3.new(0,0,-distance),self.PreviewBox)
    end

    -- Owned, reversible local effects.
    FX.Folder=UI:New("Folder",{Name="DeltaReferenceEffects"},workspace)
    FX.Sound=UI:New("Sound",{Name="DeltaReferenceMusic",Volume=App.State.MusicVolume,Looped=true},SoundService)
    App:AddCleanup(function() FX.Sound:Destroy() FX.Folder:Destroy() end)
    function FX:Light(key,value)
        if self.LightOwned[key]==nil then self.LightOwned[key]=Lighting[key] end
        Lighting[key]=value
    end
    function FX:RestoreLights()
        for key,value in pairs(self.LightOwned) do pcall(function() Lighting[key]=value end) end
        self.LightOwned={}
    end
    function FX:World()
        local S=App.State
        local desired={}
        local presets={Night={ClockTime=0.3,Brightness=1.1,Ambient=Color3.fromRGB(64,64,96),OutdoorAmbient=Color3.fromRGB(67,72,105)},Soft={Brightness=2,Ambient=Color3.fromRGB(119,116,136),OutdoorAmbient=Color3.fromRGB(145,145,160)},Cold={ClockTime=8,Brightness=1.7,Ambient=Color3.fromRGB(93,112,143),OutdoorAmbient=Color3.fromRGB(121,142,170)},Sunset={ClockTime=17.7,Brightness=1.8,Ambient=Color3.fromRGB(132,95,106),OutdoorAmbient=Color3.fromRGB(167,129,111)}}
        presets.Crimson={ClockTime=0,Brightness=0.7,Ambient=Color3.fromRGB(89,24,38),OutdoorAmbient=Color3.fromRGB(110,29,45),FogColor=Color3.fromRGB(61,8,16),FogEnd=800}
        for key,value in pairs(presets[S.Preset] or {}) do desired[key]=value end
        if S.TimeChange then desired.ClockTime=S.ClockTime end
        if S.Fullbright then desired.Brightness=2 desired.GlobalShadows=false desired.Ambient=Color3.fromRGB(180,180,180) end
        if S.Ambient then desired.Ambient=Color3.fromRGB(130,130,151) desired.OutdoorAmbient=Color3.fromRGB(150,150,170) end
        if S.Fog then desired.FogStart=0 desired.FogEnd=S.FogDistance desired.FogColor=Color3.fromRGB(91,103,133) end
        if S.Exposure then desired.ExposureCompensation=S.ExposureValue end
        local released={}
        for key,value in pairs(self.LightOwned) do if desired[key]==nil then Lighting[key]=value released[#released+1]=key end end
        for _,key in ipairs(released) do self.LightOwned[key]=nil end
        for key,value in pairs(desired) do self:Light(key,value) end
        local specs={Bloom={"BloomEffect",{Intensity=S.BloomIntensity,Size=24,Threshold=1}},SunRays={"SunRaysEffect",{Intensity=0.08,Spread=0.6}},Blur={"BlurEffect",{Size=S.BlurSize}},ColorGrade={"ColorCorrectionEffect",{Brightness=0.02,Contrast=0.12,Saturation=-0.08,TintColor=S.Preset=="Crimson" and Color3.fromRGB(255,168,185) or Color3.fromRGB(222,226,255)}}}
        for key,spec in pairs(specs) do
            if S[key] and not self.Post[key] then self.Post[key]=UI:New(spec[1],{Name="Delta"..key},Lighting) end
            local object=self.Post[key]
            if object then object.Enabled=S[key] for property,value in pairs(spec[2]) do object[property]=value end end
        end
        if S.Atmosphere then
            if not self.AtmosphereObject then
                self.AtmosphereObject=Lighting:FindFirstChildOfClass("Atmosphere")
                if self.AtmosphereObject then self.AtmosphereOriginal={Density=self.AtmosphereObject.Density,Haze=self.AtmosphereObject.Haze,Color=self.AtmosphereObject.Color}
                else self.AtmosphereObject=UI:New("Atmosphere",{Name="DeltaAtmosphere"},Lighting) self.AtmosphereCreated=true end
            end
            self.AtmosphereObject.Density=S.AtmosphereDensity self.AtmosphereObject.Haze=1.1 self.AtmosphereObject.Color=Color3.fromRGB(170,180,209)
        elseif self.AtmosphereObject then self:RestoreAtmosphere() end
        local skyProperties={SkyBackId="SkyboxBk",SkyDownId="SkyboxDn",SkyFrontId="SkyboxFt",SkyLeftId="SkyboxLf",SkyRightId="SkyboxRt",SkyUpId="SkyboxUp"}
        local ready=S.Skybox=="Custom"
        for key in pairs(skyProperties) do if S[key]=="" then ready=false end end
        if S.Celestial~="Game" or ready then
            if not self.Sky then
                self.Sky=Lighting:FindFirstChildOfClass("Sky") if not self.Sky then self.Sky=UI:New("Sky",{Name="DeltaSky"},Lighting) self.SkyCreated=true end
                self.SkyOriginal={StarCount=self.Sky.StarCount,CelestialBodiesShown=self.Sky.CelestialBodiesShown}
                for _,property in pairs(skyProperties) do self.SkyOriginal[property]=self.Sky[property] end
            end
            self.Sky.StarCount=S.Celestial=="Game" and self.SkyOriginal.StarCount or S.Stars
            if S.Celestial=="Game" then self.Sky.CelestialBodiesShown=self.SkyOriginal.CelestialBodiesShown else self.Sky.CelestialBodiesShown=S.Celestial~="Hidden" end
            for key,property in pairs(skyProperties) do self.Sky[property]=ready and ("rbxassetid://"..S[key]) or self.SkyOriginal[property] end
        else self:RestoreSky() end
    end
    function FX:RestoreAtmosphere()
        if self.AtmosphereObject then
            if self.AtmosphereCreated then self.AtmosphereObject:Destroy()
            else for key,value in pairs(self.AtmosphereOriginal or {}) do pcall(function() self.AtmosphereObject[key]=value end) end end
        end
        self.AtmosphereObject,self.AtmosphereOriginal,self.AtmosphereCreated=nil,nil,nil
    end
    function FX:RestoreSky()
        if self.Sky then
            if self.SkyCreated then self.Sky:Destroy() else for key,value in pairs(self.SkyOriginal or {}) do pcall(function() self.Sky[key]=value end) end end
        end
        self.Sky,self.SkyOriginal,self.SkyCreated=nil,nil,nil
    end
    function FX:Targets(mode)
        if mode=="Self" then return player.Character and {player.Character} or {} end
        local candidates={}
        local origin=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        for _,other in ipairs(Players:GetPlayers()) do
            local character=other.Character
            local root=character and character:FindFirstChild("HumanoidRootPart")
            if other~=player and root then candidates[#candidates+1]={Character=character,Distance=origin and (root.Position-origin.Position).Magnitude or 0} end
        end
        table.sort(candidates,function(a,b) return a.Distance<b.Distance end)
        local selected={}
        for index=1,math.min(#candidates,self:Budget(2,4)) do if candidates[index].Distance<=500 then selected[#selected+1]=candidates[index].Character end end
        return selected
    end
    function FX:ClearCharacter()
        for _,object in ipairs(self.Attachments) do pcall(function() object:Destroy() end) end
        self.Attachments,self.Orbits,self.AuraEmitters,self.TrailObjects,self.TrailEmitters,self.MotionTrails={},{},{},{},{},{}
        self.AuraEmitter,self.TrailObject,self.TrailEmitter=nil,nil,nil
    end
    function FX:Character()
        self:ClearCharacter()
        local S=App.State
        local function attachment(root,name,position)
            local object=UI:New("Attachment",{Name="Delta"..name,Position=position or Vector3.new()},root)
            self.Attachments[#self.Attachments+1]=object return object
        end
        if S.Aura then
            for _,character in ipairs(self:Targets(S.AuraTarget)) do
                local root=character:FindFirstChild("HumanoidRootPart")
                if root then
                    local style=S.AuraStyle
                    if S.AuraAmbient then
                        local emitter=UI:New("ParticleEmitter",{Name="DeltaAura",Texture=style=="Flame" and "rbxasset://textures/particles/fire_main.dds" or "rbxasset://textures/particles/sparkles_main.dds",Color=ColorSequence.new(Color3.fromHex(S.AuraColor)),Rate=math.min(S.AuraRate,self:Budget(80,120)),Lifetime=NumberRange.new(S.AuraLifetime*0.5,S.AuraLifetime),Speed=NumberRange.new(0.2,style=="Angelic" and 3 or 1.4),SpreadAngle=Vector2.new(180,180),LightEmission=S.AuraGlow,LightInfluence=0,Size=NumberSequence.new({NumberSequenceKeypoint.new(0,S.AuraSize*0.15),NumberSequenceKeypoint.new(0.4,S.AuraSize*S.AuraGrow/100),NumberSequenceKeypoint.new(1,0)}),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.25),NumberSequenceKeypoint.new(0.75,0.45),NumberSequenceKeypoint.new(1,1)}),Rotation=NumberRange.new(0,360),RotSpeed=NumberRange.new(-S.AuraSpin,S.AuraSpin),LockedToPart=style=="Sparkles"},attachment(root,"Aura",Vector3.new(0,-0.4,0)))
                        self.AuraEmitters[#self.AuraEmitters+1]=emitter
                        if style=="Flame" then emitter.Acceleration=Vector3.new(0,3,0) end
                    end
                    if S.AuraAngelic then
                        for index=1,self:Budget(2,3) do
                            local a0=attachment(root,"Swirl0") local a1=attachment(root,"Swirl1")
                            local trail=UI:New("Trail",{Name="DeltaAuraSwirl",Attachment0=a0,Attachment1=a1,FaceCamera=true,Lifetime=0.65,MinLength=0.01,LightEmission=1,LightInfluence=0,Color=ColorSequence.new(Color3.fromHex(S.AuraColor)),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.08),NumberSequenceKeypoint.new(0.65,0.35),NumberSequenceKeypoint.new(1,1)}),WidthScale=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})},a0)
                            self.Orbits[#self.Orbits+1]={A0=a0,A1=a1,Trail=trail,Phase=index*math.pi*2/3,Root=root}
                        end
                    end
                    if S.AuraNimb then
                        local emitter=UI:New("ParticleEmitter",{Name="DeltaNimb",Texture="rbxasset://textures/particles/sparkles_main.dds",Color=ColorSequence.new(Color3.fromHex(S.AuraColor)),Rate=12,Lifetime=NumberRange.new(0.3,0.7),Speed=NumberRange.new(0.5,1),SpreadAngle=Vector2.new(180,180),LightEmission=1,Size=NumberSequence.new(0.25)},attachment(root,"Nimb",Vector3.new(0,2.8,0)))
                        self.AuraEmitters[#self.AuraEmitters+1]=emitter
                    end
                end
            end
        end
        if S.Trail then
            for _,character in ipairs(self:Targets(S.TrailTarget)) do
                local root=character:FindFirstChild("HumanoidRootPart")
                if root then
                    local a0=attachment(root,"Trail0",Vector3.new(-S.TrailWidth/2,0,0.4))
                    local a1=attachment(root,"Trail1",Vector3.new(S.TrailWidth/2,0,0.4))
                    local trail=UI:New("Trail",{Name="DeltaTrail",Attachment0=a0,Attachment1=a1,Lifetime=S.TrailLifetime,MaxLength=S.TrailLength*2,FaceCamera=true,MinLength=0.05,LightEmission=S.TrailBrightness,Color=ColorSequence.new(Color3.fromHex(S.TrailColor)),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.1),NumberSequenceKeypoint.new(1,1)}),WidthScale=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})},a0)
                    self.TrailObjects[#self.TrailObjects+1]=trail
                    if S.TrailStyle~="Ribbon" then
                        local emitter=UI:New("ParticleEmitter",{Name="DeltaTrailParticles",Texture=S.TrailStyle=="Smoke" and "rbxasset://textures/particles/smoke_main.dds" or "rbxasset://textures/particles/sparkles_main.dds",Color=ColorSequence.new(Color3.fromHex(S.TrailColor)),Rate=math.min(35*S.TrailDensity/100,self:Budget(55,90)),Lifetime=NumberRange.new(0.2,S.TrailLifetime+0.3),Speed=NumberRange.new(0,0.5),LightEmission=S.TrailBrightness,VelocityInheritance=S.TrailDrift/100,Size=NumberSequence.new({NumberSequenceKeypoint.new(0,S.TrailSize*0.08),NumberSequenceKeypoint.new(1,0)}),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(1,1)}),SpreadAngle=Vector2.new(S.TrailSpread*1.8,S.TrailSpread*1.8),Rotation=NumberRange.new(0,360),RotSpeed=NumberRange.new(-20,20),Enabled=S.TrailAlwaysOn},a0)
                        if S.TrailStyle=="Snow" then
                            emitter.Acceleration=Vector3.new(0,-1.3,0) emitter.Speed=NumberRange.new(0.15,0.8) emitter.RotSpeed=NumberRange.new(-60,60)
                            emitter.Lifetime=NumberRange.new(0.4,S.TrailLifetime+0.8) emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,S.TrailSize*0.05),NumberSequenceKeypoint.new(0.6,S.TrailSize*0.07),NumberSequenceKeypoint.new(1,0)})
                        elseif S.TrailStyle=="Stars" then
                            emitter.Speed=NumberRange.new(0.3,1.8) emitter.RotSpeed=NumberRange.new(-5,5) emitter.LightEmission=1
                            emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.25,S.TrailSize*0.11),NumberSequenceKeypoint.new(1,0)})
                        end
                        self.TrailEmitters[#self.TrailEmitters+1]=emitter
                        self.MotionTrails[#self.MotionTrails+1]={Emitter=emitter,Root=root,Last=root.Position}
                    end
                end
            end
        end
        self.AuraEmitter=self.AuraEmitters[1] self.TrailObject=self.TrailObjects[1] self.TrailEmitter=self.TrailEmitters[1]
    end

    function FX:ScheduleCharacter()
        if self.PendingCharacter then return end
        self.PendingCharacter=true
        task.delay(0.1,function() self.PendingCharacter=false if App.Active then self:Character() end end)
    end
    function FX:RestoreTint()
        for part,original in pairs(self.Tints) do if part.Parent then pcall(function() part.Color=original.Color part.Material=original.Material end) end end
        self.Tints={}
    end
    function FX:RefreshTint()
        self:RestoreTint()
        if not App.State.Tint or not player.Character then return end
        for _,part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then self.Tints[part]={Color=part.Color,Material=part.Material} part.Color=Color3.fromHex(App.State.TintColor) part.Material=Enum.Material[App.State.Material] end
        end
    end
    function FX:Camera()
        local camera=workspace.CurrentCamera
        if self.FOVCamera and self.FOVCamera~=camera and self.OldFOV then pcall(function() self.FOVCamera.FieldOfView=self.OldFOV end) self.FOVCamera,self.OldFOV=nil,nil end
        if not camera then return end
        if App.State.FOVEnabled then if not self.OldFOV then self.FOVCamera,self.OldFOV=camera,camera.FieldOfView end camera.FieldOfView=App.State.FOV
        elseif self.FOVCamera then pcall(function() self.FOVCamera.FieldOfView=self.OldFOV end) self.FOVCamera,self.OldFOV=nil,nil end
    end
    function FX:ClearESP()
        for _,objects in pairs(self.ESPObjects) do for _,object in pairs(objects) do if typeof(object)=="Instance" and object~=objects.Character then object:Destroy() end end end
        self.ESPObjects={}
    end
    function FX:RefreshESP()
        local S=App.State
        if not S.ESP then self:ClearESP() return end
        local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local present={}
        for _,other in ipairs(Players:GetPlayers()) do
            local character=other.Character
            local otherRoot=character and character:FindFirstChild("HumanoidRootPart")
            local humanoid=character and character:FindFirstChildOfClass("Humanoid")
            local distance=root and otherRoot and (root.Position-otherRoot.Position).Magnitude or math.huge
            local sameTeam=player.Team~=nil and other.Team==player.Team
            if other~=player and otherRoot and humanoid and humanoid.Health>0 and distance<=S.ESPDistance and not (S.ESPTeamCheck and sameTeam) then
                present[other]=true
                local objects=self.ESPObjects[other]
                if objects and objects.Character~=character then for _,object in pairs(objects) do if typeof(object)=="Instance" and object~=objects.Character then object:Destroy() end end self.ESPObjects[other]=nil objects=nil end
                if not objects then
                    local highlight=UI:New("Highlight",{Name="DeltaHighlight",Adornee=character,FillTransparency=1,OutlineTransparency=0.15,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},self.Folder)
                    local billboard=UI:New("BillboardGui",{Name="DeltaName",Adornee=otherRoot,Size=UDim2.fromOffset(160,37),StudsOffset=Vector3.new(0,3.5,0),AlwaysOnTop=true},UI.Gui)
                    local label=UI:Text(billboard,"",10,C.Text,{Size=UDim2.fromScale(1,1),TextXAlignment=Enum.TextXAlignment.Center,TextStrokeTransparency=0.3,TextWrapped=true})
                    objects={Highlight=highlight,Billboard=billboard,Label=label,Character=character} self.ESPObjects[other]=objects
                end
                objects.Highlight.OutlineColor=Color3.fromHex(S.ESPColor)
                objects.Billboard.Enabled=S.ESPNames or S.ESPHealth
                objects.Label.Text=(S.ESPNames and (other.DisplayName.."  "..math.floor(distance).." st") or "")..(S.ESPHealth and ("\n"..math.floor(humanoid.Health).." HP") or "")
                objects.Label.TextColor3=Color3.fromHex(S.ESPColor)
            end
        end
        local remove={}
        for other,objects in pairs(self.ESPObjects) do if not present[other] then for _,object in pairs(objects) do if typeof(object)=="Instance" and object~=objects.Character then object:Destroy() end end remove[#remove+1]=other end end
        for _,other in ipairs(remove) do self.ESPObjects[other]=nil end
    end
    function FX:StopEmotes()
        self.EmoteSerial=(self.EmoteSerial or 0)+1
        for _,track in ipairs(self.EmoteTracks) do pcall(function() track:Stop(0.15) end) end self.EmoteTracks={}
    end
    function FX:Emote(name)
        local character=player.Character
        local humanoid=character and character:FindFirstChildOfClass("Humanoid")
        local animator=humanoid and humanoid:FindFirstChildOfClass("Animator")
        if not humanoid or not animator then UI:Toast("Personagem ainda indisponivel") return end
        self:StopEmotes()
        local serial=self.EmoteSerial
        local before={}
        for _,track in ipairs(animator:GetPlayingAnimationTracks()) do before[track]=true end
        local ok,played=pcall(function() return humanoid:PlayEmoteAsync(name) end)
        if not ok or not played then UI:Toast("Emote indisponivel para este avatar") return end
        for _,track in ipairs(animator:GetPlayingAnimationTracks()) do
            if not before[track] then
                if not App.Active or self.EmoteSerial~=serial then track:Stop(0.15)
                else self.EmoteTracks[#self.EmoteTracks+1]=track track:AdjustSpeed(App.State.EmoteSpeed) end
            end
        end
    end
    function FX:PlayMusic()
        local id=App.State.MusicId
        if id=="" then UI:Toast("Informe o ID de um audio permitido") return end
        if self.Sound.SoundId~="rbxassetid://"..id then self.Sound.SoundId="rbxassetid://"..id end
        self.Sound:Play()
        local soundId=self.Sound.SoundId
        task.delay(8,function() if App.Active and self.Sound.SoundId==soundId and not self.Sound.IsLoaded then UI:Toast("Audio indisponivel ou sem permissao neste jogo") end end)
    end
    App:AddCleanup(function()
        FX:ClearESP() FX:StopEmotes() FX:ClearCharacter() FX:RestoreTint() FX:RestoreLights() FX:RestoreAtmosphere() FX:RestoreSky()
        for _,object in pairs(FX.Post) do object:Destroy() end
        if FX.FOVCamera and FX.OldFOV then pcall(function() FX.FOVCamera.FieldOfView=FX.OldFOV end) end
    end)

    -- Procedural video effects use owned, non-colliding geometry only.
    FX.Random=Random.new()
    FX.VideoFolder=UI:New("Folder",{Name="VideoEffects"},FX.Folder)
    FX.Cosmetics,FX.Glyphs,FX.Circles,FX.DeathHooks,FX.EffectSounds={},{},{},{},{}
    FX.Time,FX.FrameBudget,FX.DeathTimer=0,0,0
    function FX:Budget(low,high)
        local mobile=Input.TouchEnabled
        return (App.State.Quality=="Low" or (App.State.Quality=="Auto" and mobile)) and low or high
    end
    function FX:Part(parent,name,size,color,material)
        return UI:New("Part",{Name=name,Size=size,Color=color,Material=material or Enum.Material.Neon,Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false},parent)
    end
    function FX:Model(parent,name)
        local model=UI:New("Model",{Name=name},parent)
        local origin=self:Part(model,"Origin",Vector3.new(0.01,0.01,0.01),C.White,Enum.Material.SmoothPlastic)
        origin.Transparency=1 model.PrimaryPart=origin return model
    end
    function FX:Segment(parent,a,b,width,color,glow)
        local delta=b-a
        if delta.Magnitude<0.001 then return nil end
        local part=self:Part(parent,"Line",Vector3.new(width,width,delta.Magnitude),color,glow==false and Enum.Material.SmoothPlastic or Enum.Material.Neon)
        part.CFrame=CFrame.lookAt((a+b)*0.5,b) return part
    end
    function FX:Ring(parent,radius,count,color,width,y)
        for index=1,count do
            local a=(index-1)*math.pi*2/count local b=index*math.pi*2/count
            self:Segment(parent,Vector3.new(math.cos(a)*radius,y or 0,math.sin(a)*radius),Vector3.new(math.cos(b)*radius,y or 0,math.sin(b)*radius),width,color)
        end
    end
    function FX:Triangle(parent,a,b,c,color)
        local ab,ac,bc=b-a,c-a,c-b
        if ab.Magnitude>ac.Magnitude and ab.Magnitude>bc.Magnitude then c,a=a,c
        elseif ac.Magnitude>bc.Magnitude and ac.Magnitude>ab.Magnitude then a,b=b,a end
        ab,ac,bc=b-a,c-a,c-b
        local normal=ac:Cross(ab)
        if normal.Magnitude<0.0001 or bc.Magnitude<0.0001 then return end
        local right,back=normal.Unit,bc.Unit local up=back:Cross(right).Unit
        local height=math.abs(ab:Dot(up))
        for _,spec in ipairs({{(a+b)*0.5,right,back,math.abs(ab:Dot(back))},{(a+c)*0.5,-right,-back,math.abs(ac:Dot(back))}}) do
            if spec[4]>0.001 then
                UI:New("WedgePart",{Name="ConeFace",Size=Vector3.new(0.025,height,spec[4]),CFrame=CFrame.fromMatrix(spec[1],spec[2],up,spec[3]),Color=color,Material=Enum.Material.SmoothPlastic,Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false},parent)
            end
        end
    end
    function FX:Hat(parent,color)
        local model=self:Model(parent,"KonchalHat")
        model:SetAttribute("DesignSize",App.State.HatSize) model:SetAttribute("Segments",self:Budget(14,20))
        local count=self:Budget(14,20) local radius=App.State.HatSize*0.5
        local tip=Vector3.new(0,App.State.HatSize*0.12,0)
        for index=1,count do
            local a=(index-1)*math.pi*2/count local b=index*math.pi*2/count
            self:Triangle(model,tip,Vector3.new(math.cos(a)*radius,0,math.sin(a)*radius),Vector3.new(math.cos(b)*radius,0,math.sin(b)*radius),color)
        end
        return model
    end
    function FX:Halo(parent,color)
        local model=self:Model(parent,"OrbitHalo") local radius=App.State.HaloRadius
        model:SetAttribute("DesignSize",radius) model:SetAttribute("Segments",self:Budget(20,32))
        self:Ring(model,radius,self:Budget(20,32),color,0.035,0)
        self:Ring(model,radius*0.86,self:Budget(16,26),color,0.025,0.04)
        for index=1,6 do
            local theta=index*math.pi/3
            local inside=Vector3.new(math.cos(theta)*radius*0.97,0,math.sin(theta)*radius*0.97)
            local outside=Vector3.new(math.cos(theta)*radius*1.2,0,math.sin(theta)*radius*1.2)
            self:Segment(model,inside,outside,0.035,color)
        end
        return model
    end
    function FX:ClearVideo()
        self.VideoFolder:ClearAllChildren()
        self.Cosmetics,self.Glyphs,self.Circles={},{},{} self.AmbientEmitter,self.AmbientPart=nil,nil
        self.NextCircle=nil
    end
    function FX:BuildVideo()
        self:ClearVideo()
        local S=App.State
        if S.Hat or S.Halo then
            local targets=self:Targets(S.CosmeticTarget)
            for _,character in ipairs(targets) do
                local head=character:FindFirstChild("Head")
                if head then
                    if S.Hat then local model=self:Hat(self.VideoFolder,Color3.fromHex(S.HatColor)) model:PivotTo(head.CFrame*CFrame.new(0,S.HatHeight,0)) self.Cosmetics[#self.Cosmetics+1]={Model=model,Head=head,Kind="Hat"} end
                    if S.Halo then local model=self:Halo(self.VideoFolder,Color3.fromHex(S.HaloColor)) model:PivotTo(head.CFrame*CFrame.new(0,S.HaloHeight,0)*CFrame.Angles(math.rad(S.HaloTilt),0,0)) self.Cosmetics[#self.Cosmetics+1]={Model=model,Head=head,Kind="Halo"} end
                end
            end
        end
        if S.Glyphs then
            local count=math.min(math.floor(S.GlyphCount),self:Budget(14,32))
            for index=1,count do
                local model=self:Model(self.VideoFolder,"Constellation")
                local points={}
                local size=self.Random:NextNumber(1.6,4.7)
                for point=1,5 do points[point]=Vector3.new(self.Random:NextNumber(-size,size),self.Random:NextNumber(-size,size),self.Random:NextNumber(-size*0.2,size*0.2)) end
                local lines={}
                for point=1,4 do
                    local part=self:Segment(model,points[point],points[point+1],S.GlyphWidth*0.014,Color3.fromHex(S.GlyphColor),S.GlyphGlow)
                    if part then lines[#lines+1]=part end
                end
                if index%3==0 then local part=self:Segment(model,points[1],points[4],S.GlyphWidth*0.01,Color3.fromHex(S.GlyphColor),S.GlyphGlow) if part then lines[#lines+1]=part end end
                local offset=Vector3.new(self.Random:NextNumber(-65,65),self.Random:NextNumber(-5,32),self.Random:NextNumber(-90,-18))
                if workspace.CurrentCamera then model:PivotTo(workspace.CurrentCamera.CFrame*CFrame.new(offset)) end
                self.Glyphs[#self.Glyphs+1]={Model=model,Lines=lines,Offset=offset,Phase=self.Random:NextNumber(0,math.pi*2)}
            end
        end
        if S.AmbientParticles then
            self.AmbientPart=self:Part(self.VideoFolder,"CameraParticles",Vector3.new(65,35,55),C.White) self.AmbientPart.Transparency=1
            if workspace.CurrentCamera then self.AmbientPart.CFrame=workspace.CurrentCamera.CFrame*CFrame.new(0,0,-25) end
            self.AmbientEmitter=UI:New("ParticleEmitter",{Name="AmbientParticles",Texture="rbxasset://textures/particles/sparkles_main.dds",Color=ColorSequence.new(Color3.fromHex(S.AmbientColor)),Rate=math.min(S.AmbientRate,self:Budget(45,80)),Lifetime=NumberRange.new(1.5,4),Speed=NumberRange.new(0.1,0.5),SpreadAngle=Vector2.new(180,180),Size=NumberSequence.new(0.16),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.15,0.55),NumberSequenceKeypoint.new(0.85,0.6),NumberSequenceKeypoint.new(1,1)}),LightEmission=0.7,RotSpeed=NumberRange.new(-20,20)},self.AmbientPart)
        end
        UI:RefreshPreviewCosmetics()
    end
    function FX:ScheduleVideo()
        if self.PendingVideo then return end self.PendingVideo=true
        task.delay(0.1,function() self.PendingVideo=false if App.Active then self:BuildVideo() end end)
    end
    function FX:CircleModel(parent,color)
        local model=self:Model(parent,"GroundCircle") local radius=App.State.CircleSize/2
        self:Ring(model,radius,self:Budget(24,40),color,0.025,0)
        self:Ring(model,radius*0.83,self:Budget(20,32),color,0.018,0)
        if App.State.CircleStyle~="Orbit" then
            local points={}
            for index=1,5 do local angle=index*math.pi*2/5 points[index]=Vector3.new(math.cos(angle)*radius*0.74,0,math.sin(angle)*radius*0.74) end
            for index=1,5 do self:Segment(model,points[index],points[(index+1)%5+1],0.023,color) end
        end
        return model
    end
    function FX:TestCircle()
        local targets=self:Targets(App.State.CircleTarget)
        for _,character in ipairs(targets) do
            local root=character:FindFirstChild("HumanoidRootPart")
            if root then
                while #self.Circles>=self:Budget(2,4) do local old=table.remove(self.Circles,1) old.Model:Destroy() end
                local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={character,self.Folder} params.IgnoreWater=true
                local hit=workspace:Raycast(root.Position,Vector3.new(0,-25,0),params)
                local point=hit and hit.Position or (root.Position-Vector3.new(0,3,0))
                local normal=hit and hit.Normal or Vector3.new(0,1,0)
                local right=normal:Cross(Vector3.new(0,0,1)) if right.Magnitude<0.01 then right=Vector3.new(1,0,0) else right=right.Unit end
                local place=CFrame.fromMatrix(point+normal*0.045,right,normal,right:Cross(normal))
                local model=self:CircleModel(self.VideoFolder,Color3.fromHex(App.State.CircleColor)) model:PivotTo(place)
                self.Circles[#self.Circles+1]={Model=model,Place=place,Start=self.Time,Life=App.State.CircleLife,Parts=model:GetDescendants()}
            end
        end
    end
    function UI:RefreshPreviewCosmetics()
        if not self.PreviewModel then return end
        local head=self.PreviewModel:FindFirstChild("Head") if not head then return end
        local folder=self.PreviewModel:FindFirstChild("DeltaPreviewCosmetics")
        if not folder then folder=self:New("Folder",{Name="DeltaPreviewCosmetics"},self.PreviewModel) end
        local S=App.State
        for _,kind in ipairs({"Hat","Halo"}) do
            local name=kind=="Hat" and "KonchalHat" or "OrbitHalo"
            local model=folder:FindFirstChild(name)
            local segments=kind=="Hat" and FX:Budget(14,20) or FX:Budget(20,32)
            if model and (not S[kind] or model:GetAttribute("Segments")~=segments) then model:Destroy() model=nil end
            if S[kind] then
                local color=S.Silhouette and C.White or Color3.fromHex(S[kind.."Color"])
                if not model then model=kind=="Hat" and FX:Hat(folder,color) or FX:Halo(folder,color) end
                local size=kind=="Hat" and S.HatSize or S.HaloRadius
                model:ScaleTo(size/model:GetAttribute("DesignSize"))
                for _,part in ipairs(model:GetDescendants()) do if part:IsA("BasePart") and part.Name~="Origin" then part.Color=color end end
                local height=kind=="Hat" and S.HatHeight or S.HaloHeight
                local tilt=kind=="Halo" and math.rad(S.HaloTilt) or 0
                model:PivotTo(head.CFrame*CFrame.new(0,height,0)*CFrame.Angles(tilt,0,0))
            end
        end
        local box,size=self.PreviewModel:GetBoundingBox() self.PreviewBox,self.PreviewSize=box.Position,size self:FramePreview()
    end
    function FX:UpdateVideoValues(key)
        local S=App.State
        if key:match("^Hat") or key:match("^Halo") then
            if key=="Hat" or key=="Halo" then return false end
            for _,record in ipairs(self.Cosmetics) do
                local size=record.Kind=="Hat" and S.HatSize or S.HaloRadius
                record.Model:ScaleTo(size/record.Model:GetAttribute("DesignSize"))
                local color=Color3.fromHex(S[record.Kind.."Color"])
                for _,part in ipairs(record.Model:GetDescendants()) do if part:IsA("BasePart") and part.Name~="Origin" then part.Color=color end end
            end
            UI:RefreshPreviewCosmetics() return true
        elseif key:match("^Glyph") then
            if key=="Glyphs" then return false end
            if key=="GlyphCount" then return #self.Glyphs==math.min(math.floor(S.GlyphCount),self:Budget(14,32)) end
            for _,glyph in ipairs(self.Glyphs) do
                for _,part in ipairs(glyph.Lines) do
                    if key=="GlyphColor" or key=="GlyphColorMode" then part.Color=Color3.fromHex(S.GlyphColor)
                    elseif key=="GlyphWidth" then part.Size=Vector3.new(S.GlyphWidth*0.014,S.GlyphWidth*0.014,part.Size.Z)
                    elseif key=="GlyphGlow" then part.Material=S.GlyphGlow and Enum.Material.Neon or Enum.Material.SmoothPlastic end
                end
            end return true
        elseif key=="AmbientColor" or key=="AmbientRate" then
            if self.AmbientEmitter then self.AmbientEmitter.Color=ColorSequence.new(Color3.fromHex(S.AmbientColor)) self.AmbientEmitter.Rate=math.min(S.AmbientRate,self:Budget(45,80)) end return true
        elseif key:match("^Circle") and key~="Circle" and key~="CircleSize" and key~="CircleStyle" and key~="CircleTarget" then
            for _,pulse in ipairs(self.Circles) do
                if key=="CircleLife" then pulse.Life=S.CircleLife end
                if key=="CircleColor" then for _,part in ipairs(pulse.Parts) do if part:IsA("BasePart") and part.Name~="Origin" then part.Color=Color3.fromHex(S.CircleColor) end end end
            end return true
        end
        return false
    end
    function FX:EffectSound(id)
        if id=="" then return end
        while #self.EffectSounds>=4 do local old=table.remove(self.EffectSounds,1) old:Destroy() end
        local sound=UI:New("Sound",{Name="DeltaEffectSound",SoundId="rbxassetid://"..id,Volume=App.State.EffectVolume},SoundService)
        self.EffectSounds[#self.EffectSounds+1]=sound sound:Play()
        task.delay(6,function() if sound.Parent then sound:Destroy() end for index=#self.EffectSounds,1,-1 do if self.EffectSounds[index]==sound then table.remove(self.EffectSounds,index) end end end)
    end
    function FX:DeathPulse(character)
        local root=character and character:FindFirstChild("HumanoidRootPart") if not root then return end
        local color=Color3.fromHex(App.State.NeonColor)
        if App.State.KillChams then
            local highlight=UI:New("Highlight",{Name="DeathChams",Adornee=character,FillColor=color,OutlineColor=color,FillTransparency=0.15,OutlineTransparency=0},self.VideoFolder)
            UI:Tween(highlight,{FillTransparency=1,OutlineTransparency=1},0.9)
            task.delay(1,function() if highlight.Parent then highlight:Destroy() end end)
        end
        if App.State.NeonBurst then
            local sphere=self:Part(self.VideoFolder,"NeonBurst",Vector3.new(0.2,0.2,0.2),color)
            sphere.Shape=Enum.PartType.Ball sphere.CFrame=CFrame.new(root.Position) sphere.Transparency=0.3
            UI:Tween(sphere,{Size=Vector3.new(10,10,10),Transparency=1},0.7)
            task.delay(0.8,function() if sphere.Parent then sphere:Destroy() end end)
        end
    end
    function FX:ClearDeathHooks()
        for _,record in pairs(self.DeathHooks) do record.Died:Disconnect() record.Health:Disconnect() end self.DeathHooks={}
    end
    function FX:RefreshDeathHooks()
        local S=App.State
        if not S.KillChams and not S.NeonBurst and not S.HitSound and not S.KillSound then self:ClearDeathHooks() return end
        local present={}
        for _,other in ipairs(Players:GetPlayers()) do
            local character=other.Character local humanoid=character and character:FindFirstChildOfClass("Humanoid")
            local wanted=(S.KillTarget=="Self" and other==player) or (S.KillTarget=="Others" and other~=player)
            if humanoid and wanted then
                present[other]=true
                local old=self.DeathHooks[other]
                if old and old.Humanoid~=humanoid then old.Died:Disconnect() old.Health:Disconnect() self.DeathHooks[other]=nil old=nil end
                if not old then
                    local record={Humanoid=humanoid,LastHealth=humanoid.Health}
                    record.Died=humanoid.Died:Connect(function() if App.Active then self:DeathPulse(character) if App.State.KillSound then self:EffectSound(App.State.KillSoundId) end end end)
                    record.Health=humanoid.HealthChanged:Connect(function(health) if App.Active and health<record.LastHealth and health>0 and App.State.HitSound then self:EffectSound(App.State.HitSoundId) end record.LastHealth=health end)
                    self.DeathHooks[other]=record
                end
            end
        end
        local remove={}
        for other,record in pairs(self.DeathHooks) do if not present[other] then record.Died:Disconnect() record.Health:Disconnect() remove[#remove+1]=other end end
        for _,other in ipairs(remove) do self.DeathHooks[other]=nil end
    end
    function FX:RefreshTargetSet()
        local roots={}
        local function add(enabled,mode)
            if not enabled then return end
            for _,character in ipairs(self:Targets(mode)) do local root=character:FindFirstChild("HumanoidRootPart") if root then roots[root]=true end end
        end
        add(App.State.Aura,App.State.AuraTarget) add(App.State.Trail,App.State.TrailTarget) add(App.State.Hat or App.State.Halo,App.State.CosmeticTarget)
        local changed=false
        if self.TargetSnapshot then
            for root in pairs(roots) do if not self.TargetSnapshot[root] then changed=true break end end
            if not changed then for root in pairs(self.TargetSnapshot) do if not roots[root] then changed=true break end end end
        end
        self.TargetSnapshot=roots
        if changed then self:Character() self:BuildVideo() end
    end
    function FX:VideoStep(dt)
        self.Time=self.Time+dt self.FrameBudget=self.FrameBudget+dt self.DeathTimer=self.DeathTimer+dt
        if self.DeathTimer>=1 then self.DeathTimer=0 self:RefreshDeathHooks() self:RefreshTargetSet() end
        if self.FrameBudget<1/30 then return end
        self.FrameBudget=0
        local S=App.State local t=self.Time
        for _,orbit in ipairs(self.Orbits or {}) do
            if orbit.Root.Parent then
                local angle=t*S.AuraSpeed+orbit.Phase local radius=S.AuraRadius
                local y=math.sin(angle*0.7+orbit.Phase)*1.3
                local point=Vector3.new(math.cos(angle)*radius,y,math.sin(angle)*radius)
                orbit.A0.Position=point+Vector3.new(0,S.AuraSize*0.3,0) orbit.A1.Position=point-Vector3.new(0,S.AuraSize*0.3,0)
            end
        end
        for _,motion in ipairs(self.MotionTrails or {}) do
            if motion.Root.Parent then
                local moved=(motion.Root.Position-motion.Last).Magnitude>0.025 motion.Last=motion.Root.Position
                motion.Emitter.Enabled=S.TrailAlwaysOn or moved
            end
        end
        for _,cosmetic in ipairs(self.Cosmetics) do
            if cosmetic.Head.Parent then
                local offset=cosmetic.Kind=="Hat" and S.HatHeight or S.HaloHeight
                local spin=cosmetic.Kind=="Hat" and S.HatSpin or S.HaloSpin
                local tilt=cosmetic.Kind=="Halo" and math.rad(S.HaloTilt) or 0
                cosmetic.Model:PivotTo(cosmetic.Head.CFrame*CFrame.new(0,offset,0)*CFrame.Angles(tilt,t*math.rad(spin),0))
            end
        end
        local camera=workspace.CurrentCamera
        if camera then
            for _,glyph in ipairs(self.Glyphs) do
                local point=glyph.Offset+Vector3.new(math.sin(t*0.08+glyph.Phase)*2,math.sin(t*0.12+glyph.Phase)*2,0)
                glyph.Model:PivotTo(camera.CFrame*CFrame.new(point)*CFrame.Angles(0,0,math.sin(t*S.GlyphSpeed*0.001+glyph.Phase)*0.2))
                local cycle=(t/S.GlyphLifetime+glyph.Phase)%1 local fade=0.35+math.abs(cycle-0.5)*0.9
                for _,part in ipairs(glyph.Lines) do part.Transparency=math.clamp(fade+S.GlyphTrail/300,0,0.95) if S.GlyphColorMode=="Rainbow" then part.Color=Color3.fromHSV((t*0.08+glyph.Phase/7)%1,0.4,1) end end
            end
            if self.AmbientPart then self.AmbientPart.CFrame=camera.CFrame*CFrame.new(0,0,-25) end
        end
        if S.Circle and (not self.NextCircle or t>=self.NextCircle) then self:TestCircle() self.NextCircle=t+math.max(0.6,S.CircleLife*0.7) end
        for index=#self.Circles,1,-1 do
            local pulse=self.Circles[index] local age=(t-pulse.Start)/pulse.Life
            if age>=1 then pulse.Model:Destroy() table.remove(self.Circles,index)
            else
                pulse.Model:ScaleTo(1+(S.CircleGrow/100-1)*age)
                pulse.Model:PivotTo(pulse.Place*CFrame.Angles(0,math.rad(S.CircleSpin)*(t-pulse.Start),0))
                for _,part in ipairs(pulse.Parts) do if part:IsA("BasePart") and part.Name~="Origin" then part.Transparency=math.clamp(1-S.CircleBrightness+age^3*S.CircleBrightness,0,1) end end
            end
        end
        UI:WireStep(t)
    end
    function UI:Wireframe(card)
        local row=self:Row(card,"Geometry",158)
        local frame=self:New("Frame",{Name="AnimatedGeometry",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ClipsDescendants=true},row)
        local vertices={Vector3.new(0,1.2,0),Vector3.new(0,-1.2,0),Vector3.new(-0.8,0,0),Vector3.new(0.8,0,0),Vector3.new(0,0,-0.8),Vector3.new(0,0,0.8)}
        local edges={{1,3},{1,4},{1,5},{1,6},{2,3},{2,4},{2,5},{2,6},{3,5},{5,4},{4,6},{6,3},{1,2},{3,4}}
        local lines={} for _,edge in ipairs(edges) do local line=self:Line(frame,0,0,1,1,C.Muted) line.BackgroundTransparency=0.45 lines[#lines+1]={Frame=line,A=edge[1],B=edge[2]} end
        self.Wire={Frame=frame,Vertices=vertices,Lines=lines}
    end
    function UI:WireStep(t)
        if not self.Wire or not self.Visible or self.Selected~="Menu" then return end
        local width=self.Wire.Frame.AbsoluteSize.X/math.max(self.Scale,0.1) local height=158 local points={}
        for index,v in ipairs(self.Wire.Vertices) do
            local angle=t*0.3 local x=v.X*math.cos(angle)-v.Z*math.sin(angle) local z=v.X*math.sin(angle)+v.Z*math.cos(angle)
            local perspective=1/(1+z*0.15) points[index]=Vector2.new(width/2+x*52*perspective,height/2+v.Y*50*perspective)
        end
        for _,line in ipairs(self.Wire.Lines) do local a,b=points[line.A],points[line.B] local delta=b-a line.Frame.Position=UDim2.fromOffset((a.X+b.X)/2,(a.Y+b.Y)/2) line.Frame.Size=UDim2.fromOffset(delta.Magnitude,1) line.Frame.Rotation=math.deg(math.atan2(delta.Y,delta.X)) end
    end
    function App:VideoLook(name)
        local violet=name=="Violet" local crimson=name=="Crimson"
        local color=violet and "C59CFF" or (crimson and "FF6B88" or "A9D6FF")
        local settings={Preset=crimson and "Crimson" or "Night",Celestial="Stars",Stars=3000,Bloom=true,BloomIntensity=0.5,ColorGrade=true,Ambient=true,Aura=true,AuraAmbient=true,AuraAngelic=true,AuraNimb=false,AuraStyle="Angelic",AuraColor=color,AuraGlow=1,AuraSize=1.5,AuraRate=55,AuraRadius=1.5,AuraSpeed=2.8,Trail=true,TrailStyle="Sparkle",TrailColor=color,TrailDensity=140,Halo=true,HaloColor=color,Hat=true,HatColor="E6E9EF",Glyphs=true,GlyphColor=color,GlyphCount=26,AmbientParticles=true,AmbientColor=color,AmbientRate=25,Circle=false}
        for key,value in pairs(settings) do self:Set(key,value,true) end
        self:ApplyAll() UI:Toast("Visual "..name.." aplicado")
    end
    App:AddCleanup(function() FX:ClearDeathHooks() for _,sound in ipairs(FX.EffectSounds) do sound:Destroy() end FX.EffectSounds={} FX:ClearVideo() end)

    -- Only this project's validated JSON configuration files are listed or read.
    local configName="default"
    local fileBuiltins={writefile=writefile,readfile=readfile,listfiles=listfiles,delfile=delfile,setclipboard=setclipboard}
    local function fileFunction(name) local fn=environment[name] or fileBuiltins[name] return type(fn)=="function" and fn or nil end
    local function configLabel(value) local clean=tostring(value):gsub("[^%w_-]",""):sub(1,32) return clean~="" and clean or "default" end
    App.ConfigNames,App.RemovedConfigs={},{}
    function App:ConfigPath(name) return "delta-project-"..configLabel(name or configName)..".json" end
    function App:SetConfigName(name)
        configName=configLabel(name) if UI.ConfigName then UI.ConfigName.Text=configName end
    end
    function App:ListConfigs()
        local reader,lister=fileFunction("readfile"),fileFunction("listfiles")
        if reader then
            local ok,data=pcall(function() return HttpService:JSONDecode(reader("delta-project.config-index.json")) end)
            if ok and type(data)=="table" and type(data.names)=="table" then
                for _,name in ipairs(data.names) do if type(name)=="string" and configLabel(name)==name and not self.RemovedConfigs[name] then self.ConfigNames[name]=true end end
            end
        end
        if lister then
            local ok,paths=pcall(lister,".")
            if ok and type(paths)=="table" then for _,path in ipairs(paths) do
                if type(path)=="string" then local name=path:gsub("\\","/"):match("delta%-project%-([%w_-]+)%.json$") if name and #name<=32 and not self.RemovedConfigs[name] then self.ConfigNames[name]=true end end
            end end
        end
        local names={} for name in pairs(self.ConfigNames) do if not self.RemovedConfigs[name] then names[#names+1]=name end end table.sort(names) return names
    end
    function App:SaveConfigIndex()
        local writer=fileFunction("writefile") if not writer then return end
        local names={} for name in pairs(self.ConfigNames) do if not self.RemovedConfigs[name] then names[#names+1]=name end end table.sort(names)
        pcall(function() writer("delta-project.config-index.json",HttpService:JSONEncode({names=names})) end)
    end
    function UI:RefreshConfigList()
        if not self.ConfigItems then return end
        self.ConfigItems:ClearAllChildren() self:New("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder},self.ConfigItems)
        for index,name in ipairs(App:ListConfigs()) do self:Click(self.ConfigItems,name,function() App:SetConfigName(name) self:RefreshConfigList() end,{Size=UDim2.new(1,-4,0,25),LayoutOrder=index,BackgroundTransparency=name==configName and 0 or 1,TextXAlignment=Enum.TextXAlignment.Left}) end
    end
    function App:SaveConfig()
        local writer=fileFunction("writefile")
        if not writer then UI:Toast("Salvar arquivo nao esta disponivel neste ambiente") return false end
        local ok=pcall(function() writer(self:ConfigPath(),HttpService:JSONEncode({version=1,settings=self.State})) end)
        if ok then self.ConfigNames[configName]=true self.RemovedConfigs[configName]=nil self:SaveConfigIndex() UI:RefreshConfigList() end
        UI:Toast(ok and "Configuracao salva" or "Nao foi possivel salvar a configuracao") return ok
    end
    function App:LoadConfig()
        local reader=fileFunction("readfile")
        if not reader then UI:Toast("Ler arquivo nao esta disponivel neste ambiente") return false end
        local ok,data=pcall(function() return HttpService:JSONDecode(reader(self:ConfigPath())) end)
        if not ok or type(data)~="table" or data.version~=1 or type(data.settings)~="table" then UI:Toast("Configuracao ausente ou invalida") return false end
        for key,value in pairs(defaults) do self:Set(key,value,true) end
        for key,value in pairs(data.settings) do self:Set(key,value,true) end
        if data.settings.AuraAngelic==nil and (self.State.AuraStyle=="Angelic" or self.State.AuraStyle=="Vortex") then self:Set("AuraAngelic",true,true) end
        self:ApplyAll() UI:Toast("Configuracao carregada") return true
    end
    function App:DeleteConfig()
        local deleter=fileFunction("delfile") if not deleter then UI:Toast("Excluir arquivo nao esta disponivel neste ambiente") return false end
        local ok=pcall(deleter,self:ConfigPath())
        if ok then self.ConfigNames[configName]=nil self.RemovedConfigs[configName]=true self:SaveConfigIndex() UI:RefreshConfigList() end
        UI:Toast(ok and "Configuracao excluida" or "Nao foi possivel excluir a configuracao") return ok
    end
    function App:CopyConfig()
        local clipboard=fileFunction("setclipboard") if not clipboard then UI:Toast("Copiar nao esta disponivel neste ambiente") return false end
        local ok=pcall(function() clipboard(HttpService:JSONEncode({version=1,settings=self.State})) end)
        UI:Toast(ok and "Configuracao copiada" or "Nao foi possivel copiar") return ok
    end
    function App:Reset()
        for key,value in pairs(defaults) do self:Set(key,value,true) end self:ApplyAll() FX.Sound:Stop() for _,sound in ipairs(FX.EffectSounds) do sound:Destroy() end FX.EffectSounds={} UI:Toast("Configuracao restaurada")
    end

    -- Pages use the same two-column, compact section layout as the references.
    do
        local left,right=UI:Page("World")
        local card=UI:Card(left,"Shaders")
        UI:Dropdown(card,"Preset","Preset") UI:Dropdown(card,"Skybox","Skybox") UI:Dropdown(card,"Celestial","Celestial") UI:Slider(card,"Stars","Stars",100)
        UI:Toggle(card,"Fog","Fog") UI:Slider(card,"Fog distance","FogDistance",10,nil,"Fog")
        UI:Toggle(card,"Bloom","Bloom") UI:Slider(card,"Intensity","BloomIntensity",0.05,nil,"Bloom")
        UI:Toggle(card,"Sun Rays","SunRays") UI:Toggle(card,"Blur","Blur") UI:Slider(card,"Blur size","BlurSize",1,nil,"Blur")
        UI:Toggle(card,"Color Grade","ColorGrade") UI:Toggle(card,"Atmosphere","Atmosphere") UI:Slider(card,"Density","AtmosphereDensity",0.05,nil,"Atmosphere")
        card=UI:Card(left,"Aura") UI:Toggle(card,"Aura","Aura")
        UI:MultiSelect(card,"Types",{{"Angelic","AuraAngelic"},{"Ambient","AuraAmbient"},{"Nimb","AuraNimb"}})
        UI:Dropdown(card,"Target","AuraTarget") UI:Slider(card,"Glow","AuraGlow",0.05,"%",nil,100) UI:Slider(card,"Rate","AuraRate",1) UI:Slider(card,"Size","AuraSize",0.1) UI:Color(card,"Color","AuraColor")
        card=UI:Card(left,"Kill Effects") UI:Toggle(card,"Chams","KillChams") UI:Toggle(card,"Neon Burst","NeonBurst") UI:Dropdown(card,"Target","KillTarget") UI:Color(card,"Color","NeonColor") UI:Button(card,"Test burst",function() FX:DeathPulse(player.Character) end)
        card=UI:Card(left,"Trail") UI:Toggle(card,"Enabled","Trail") UI:Dropdown(card,"Style","TrailStyle") UI:Dropdown(card,"Target","TrailTarget") UI:Color(card,"Fade Color","TrailColor") UI:Toggle(card,"Rainbow","Rainbow") UI:Slider(card,"Size","TrailSize",0.5) UI:Slider(card,"Length","TrailLength",1) UI:Slider(card,"Density","TrailDensity",5,"%") UI:Slider(card,"Brightness","TrailBrightness",0.05,"%",nil,100) UI:Slider(card,"Spread","TrailSpread",1,"%") UI:Slider(card,"Drift","TrailDrift",1,"%") UI:Slider(card,"Width","TrailWidth",0.1) UI:Slider(card,"Lifetime","TrailLifetime",0.1,"s") UI:Toggle(card,"Always On","TrailAlwaysOn")
        card=UI:Card(right,"Circle") UI:Toggle(card,"Enabled","Circle") UI:Dropdown(card,"Style","CircleStyle") UI:Slider(card,"Size","CircleSize",0.5) UI:Slider(card,"Life","CircleLife",0.5,"s") UI:Slider(card,"Grow","CircleGrow",5,"%") UI:Slider(card,"Brightness","CircleBrightness",0.05,"%",nil,100) UI:Slider(card,"Spin","CircleSpin",5) UI:Dropdown(card,"Target","CircleTarget") UI:Color(card,"Color","CircleColor") UI:Button(card,"Test Circle",function() FX:TestCircle() end)
        card=UI:Card(right,"Line Glyphs") UI:Toggle(card,"Enabled","Glyphs") UI:Dropdown(card,"Color","GlyphColorMode") UI:Color(card,"Tint","GlyphColor") UI:Slider(card,"Count","GlyphCount",1) UI:Slider(card,"Speed","GlyphSpeed",1) UI:Slider(card,"Trail","GlyphTrail",1) UI:Slider(card,"Lifetime","GlyphLifetime",0.1,"s") UI:Slider(card,"Width","GlyphWidth",0.1) UI:Toggle(card,"Glow","GlyphGlow")
        card=UI:Card(right,"Aura settings") UI:Color(card,"Color","AuraColor") UI:Dropdown(card,"Style","AuraStyle") UI:Slider(card,"Life","AuraLifetime",0.1,"s") UI:Slider(card,"Grow","AuraGrow",5,"%") UI:Slider(card,"Orbit radius","AuraRadius",0.1) UI:Slider(card,"Orbit speed","AuraSpeed",0.1) UI:Slider(card,"Spin","AuraSpin",5)
        card=UI:Card(right,"Sounds") UI:Toggle(card,"Hit Sound","HitSound") UI:IdField(card,"Hit audio ID","HitSoundId") UI:Condition(card,"HitSound",true) UI:Toggle(card,"Kill Sound","KillSound") UI:IdField(card,"Kill audio ID","KillSoundId") UI:Condition(card,"KillSound",true) UI:Slider(card,"Sound Volume","EffectVolume",0.05,"%",nil,100)
        card=UI:Card(right,"Lighting") UI:Toggle(card,"Fullbright","Fullbright") UI:Toggle(card,"Time Change","TimeChange") UI:Slider(card,"Time","ClockTime",0.5,"h") UI:Toggle(card,"Ambient","Ambient") UI:Toggle(card,"Exposure","Exposure") UI:Slider(card,"Value","ExposureValue",0.1)
        card=UI:Card(left,"Video looks") UI:Button(card,"Apply Blue look",function() App:VideoLook("Blue") end) UI:Button(card,"Apply Violet look",function() App:VideoLook("Violet") end) UI:Button(card,"Apply Crimson lighting",function() App:VideoLook("Crimson") end)
        card=UI:Card(right,"Skybox assets")
        for _,entry in ipairs({{"Back","SkyBackId"},{"Down","SkyDownId"},{"Front","SkyFrontId"},{"Left","SkyLeftId"},{"Right","SkyRightId"},{"Up","SkyUpId"}}) do
            local key=entry[2] local box=UI:Textbox(card,entry[1].." ID","",function(value) App:Set(key,value) end) UI:Condition(card,"Skybox","Custom") App:Subscribe(key,function(value) box.Text=value end)
        end
    end
    do
        local left,right=UI:Page("ESP")
        local card=UI:Card(left,"Player ESP") UI:Toggle(card,"Enabled","ESP") UI:Toggle(card,"Names / distance","ESPNames") UI:Toggle(card,"Health","ESPHealth") UI:Toggle(card,"Team check","ESPTeamCheck")
        card=UI:Card(right,"Appearance") UI:Color(card,"Outline color","ESPColor") UI:Slider(card,"Max distance","ESPDistance",25)
    end
    do
        local left,right=UI:Page("Screen")
        local card=UI:Card(left,"Camera") UI:Toggle(card,"Custom FOV","FOVEnabled") UI:Slider(card,"Field of view","FOV",1,"°")
        card=UI:Card(right,"Crosshair") UI:Toggle(card,"Enabled","Crosshair") UI:Slider(card,"Size","CrosshairSize",1) UI:Slider(card,"Gap","CrosshairGap",1)
        card=UI:Card(left,"Overlay") UI:Toggle(card,"Watermark","Watermark")
        card=UI:Card(right,"Ambient particles") UI:Toggle(card,"Enabled","AmbientParticles") UI:Color(card,"Color","AmbientColor") UI:Slider(card,"Rate","AmbientRate",1)
    end
    do
        local left,right=UI:Page("Skins")
        local card=UI:Card(left,"Local appearance") UI:Toggle(card,"Enabled","Tint") UI:Color(card,"Color","TintColor") UI:Dropdown(card,"Material","Material")
        card=UI:Card(right,"Restore") UI:Button(card,"Restore character",function() App:Set("Tint",false) end)
    end
    do
        local left,right=UI:Page("Models")
        local card=UI:Card(left,"Avatar preview") UI:Toggle(card,"Enabled","Preview") UI:Toggle(card,"White silhouette","Silhouette") UI:Button(card,"Refresh avatar",function() UI:RefreshPreview() end)
        card=UI:Card(right,"Rotation") UI:Toggle(card,"Auto rotate","PreviewSpin") UI:Slider(card,"Speed","PreviewSpeed",1) UI:Button(card,"Face forward",function() UI.Yaw=0 UI:RotatePreview() end)
        card=UI:Card(left,"Konchal Hat") UI:Toggle(card,"Enabled","Hat") UI:Color(card,"Color","HatColor") UI:Slider(card,"Size","HatSize",0.1) UI:Slider(card,"Height","HatHeight",0.1) UI:Slider(card,"Spin","HatSpin",5) UI:Dropdown(card,"Target","CosmeticTarget")
        card=UI:Card(right,"Orbit Halo") UI:Toggle(card,"Enabled","Halo") UI:Color(card,"Color","HaloColor") UI:Slider(card,"Radius","HaloRadius",0.1) UI:Slider(card,"Height","HaloHeight",0.1) UI:Slider(card,"Tilt","HaloTilt",1,"°") UI:Slider(card,"Spin","HaloSpin",5)
    end
    do
        local left,right=UI:Page("Emotes")
        local card=UI:Card(left,"Emotes")
        for _,entry in ipairs({{"Wave","wave"},{"Cheer","cheer"},{"Dance","dance"},{"Laugh","laugh"},{"Point","point"}}) do UI:Button(card,entry[1],function() FX:Emote(entry[2]) end) end
        card=UI:Card(right,"Playback") UI:Slider(card,"Speed","EmoteSpeed",0.05) UI:Button(card,"Stop emote",function() FX:StopEmotes() end)
    end
    do
        local left,right=UI:Page("Animations")
        local card=UI:Card(left,"Emote playback") UI:Slider(card,"Playback speed","EmoteSpeed",0.05) UI:Button(card,"Stop panel emotes",function() FX:StopEmotes() end)
        card=UI:Card(right,"Preview motion") UI:Toggle(card,"Rotate avatar","PreviewSpin") UI:Slider(card,"Rotation speed","PreviewSpeed",1)
    end
    do
        local left,right=UI:Page("Helpers")
        local card=UI:Card(left,"Quick actions") UI:Button(card,"Refresh avatar",function() UI:RefreshPreview() end) UI:Button(card,"Reset settings",function() App:Reset() end)
        card=UI:Card(right,"Effects") UI:Button(card,"Disable local effects",function()
            for _,key in ipairs({"Aura","Trail","ESP","Tint","Bloom","SunRays","Blur","ColorGrade","Atmosphere","Fog","Fullbright","Ambient","Exposure","TimeChange","FOVEnabled","Crosshair","Hat","Halo","Glyphs","Circle","AmbientParticles","KillChams","NeonBurst","HitSound","KillSound"}) do App:Set(key,false,true) end App:Set("Preset","Game",true) App:Set("Celestial","Game",true) App:ApplyAll() FX.Sound:Stop() UI:Toast("Efeitos locais desativados")
        end) UI:Button(card,"Unload panel",function() App:Destroy() end)
    end
    do
        local left,right=UI:Page("Menu")
        local card=UI:Card(left,"Menu") UI:Dropdown(card,"Menu keybind","Keybind") UI:Toggle(card,"Watermark","Watermark") UI:Slider(card,"Transparency","Opacity",0.02,"%",nil,100) UI:Slider(card,"Interface scale","MenuScale",0.05) UI:Dropdown(card,"Effect quality","Quality")
        local artwork=UI:Textbox(card,"Artwork ID","",function(value) App:Set("ArtworkId",value) end) App:Subscribe("ArtworkId",function(value) artwork.Text=value end)
        card=UI:Card(right,"Config") UI.ConfigName=UI:Textbox(card,"Name",configName,function(value) App:SetConfigName(value) end)
        local row=UI:Row(card,"Saved configs",125)
        UI.ConfigItems=UI:New("ScrollingFrame",{Name="SavedConfigs",BackgroundColor3=C.Panel,Size=UDim2.fromScale(1,1),ScrollBarThickness=2,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y},row)
        UI:Button(card,"Save config",function() App:SaveConfig() end) UI:Button(card,"Load config",function() App:LoadConfig() end) UI:Button(card,"Refresh list",function() UI:RefreshConfigList() end) UI:Button(card,"Copy config",function() App:CopyConfig() end) UI:Button(card,"Delete config",function() App:DeleteConfig() end) UI:Button(card,"Reset config",function() App:Reset() end)
        card=UI:Card(left,"Geometry") UI:Wireframe(card)
        card=UI:Card(left,"Session") UI:Button(card,"Hide panel",function() UI:ToggleWindow(false) end) UI:Button(card,"Unload",function() App:Destroy() end)
        UI:RefreshConfigList()
    end
    do
        local left,right=UI:Page("Music")
        local card=UI:Card(left,"Music")
        local box=UI:Textbox(card,"Audio ID","",function(value) local id=value:match("(%d+)") or "" if not App:Set("MusicId",id) then UI:Toast("ID de audio invalido") end end)
        App:Subscribe("MusicId",function(value) box.Text=value end)
        UI:Button(card,"Play",function() FX:PlayMusic() end) UI:Button(card,"Pause",function() FX.Sound:Pause() end) UI:Button(card,"Stop",function() FX.Sound:Stop() end)
        card=UI:Card(right,"Sound") UI:Slider(card,"Volume","MusicVolume",0.05) UI:Toggle(card,"Loop","MusicLoop")
    end
    App:RegisterAction("set",function(key,value) return App:Set(key,value) end)
    App:RegisterAction("selectTab",function(name) UI:Select(name) end)
    App:RegisterAction("toggleMenu",function() UI:ToggleWindow(not UI.Visible) end)
    App:RegisterAction("refreshPreview",function() UI:RefreshPreview() end)
    App:RegisterAction("reset",function() App:Reset() end)
    App:RegisterAction("videoLook",function(name) App:VideoLook(name or "Blue") end)
    App:RegisterAction("testCircle",function() FX:TestCircle() end)
    App:Connect(player.CharacterAdded,function()
        FX:ClearCharacter() FX:RestoreTint() FX:StopEmotes()
        task.delay(0.8,function() if App.Active then FX:Character() FX:BuildVideo() FX:RefreshTint() UI:RefreshPreview() end end)
    end)
    App:Connect(workspace:GetPropertyChangedSignal("CurrentCamera"),function() FX:Camera() UI:Fit() end)
    local elapsed,frames,espTime,rainbowTime=0,0,0,0
    App:Connect(RunService.RenderStepped,function(dt)
        elapsed,frames,espTime,rainbowTime=elapsed+dt,frames+1,espTime+dt,rainbowTime+dt
        FX:VideoStep(dt)
        if UI.Visible and App.State.Preview and App.State.PreviewSpin and not UI.Pointer then UI.Yaw=UI.Yaw+math.rad(App.State.PreviewSpeed)*dt UI:RotatePreview() end
        if espTime>=0.25 then espTime=0 if App.State.ESP then FX:RefreshESP() end end
        if App.State.Rainbow and rainbowTime>=0.05 then
            rainbowTime=0 local sequence=ColorSequence.new(Color3.fromHSV((os.clock()*0.13)%1,0.6,1))
            for _,emitter in ipairs(FX.AuraEmitters or {}) do emitter.Color=sequence end
            for _,trail in ipairs(FX.TrailObjects or {}) do trail.Color=sequence end
            for _,emitter in ipairs(FX.TrailEmitters or {}) do emitter.Color=sequence end
            for _,orbit in ipairs(FX.Orbits or {}) do orbit.Trail.Color=sequence end
        end
        if elapsed>=1 then
            local pingOk,ping=pcall(function() return player:GetNetworkPing() end)
            local latency=pingOk and (tostring(math.floor(ping*1000)).."ms  /  ") or ""
            UI.Watermark.Text="DELTA 0.3  /  "..player.DisplayName.."  /  "..math.floor(frames/elapsed).." fps  /  "..latency..os.date("%H:%M") elapsed,frames=0,0
        end
    end)
    App:ApplyAll() UI:RefreshPreview() UI:Select("World") UI:Fit()
    UI:Toast("v0.3 · toque Blue look para aplicar o visual do video")
    print("[delta-project] Reference panel v"..App.Version.." loaded")
    return App
end
local ok,result=xpcall(start,function(err) return debug.traceback(tostring(err),2) end)
if not ok then App:Destroy() warn("[delta-project] "..tostring(result)) error("Falha ao iniciar o painel. Veja o console para os detalhes.",0) end
return result
