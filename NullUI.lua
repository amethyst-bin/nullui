local NullLibrary = {
    Theme = {
        Background = Color3.fromRGB(7, 8, 13),
        Surface = Color3.fromRGB(14, 16, 24),
        SurfaceSoft = Color3.fromRGB(18, 21, 31),
        SurfaceRaised = Color3.fromRGB(24, 28, 40),
        SurfaceAccent = Color3.fromRGB(29, 34, 49),
        Text = Color3.fromRGB(243, 246, 255),
        Muted = Color3.fromRGB(150, 158, 180),
        Stroke = Color3.fromRGB(50, 57, 78),
        AccentSoft = Color3.fromRGB(198, 208, 255),
        Good = Color3.fromRGB(108, 255, 189),
        Bad = Color3.fromRGB(255, 118, 118),
    },
    Version = "2.0"
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local function create(className, properties)
    local object = Instance.new(className)
    properties = properties or {}

    for key, value in pairs(properties) do
        if key ~= "Parent" then
            object[key] = value
        end
    end

    object.Parent = properties.Parent
    return object
end

local function corner(parent, radius)
    create("UICorner", {CornerRadius = UDim.new(0, radius), Parent = parent})
end

local function stroke(parent, transparency, thickness, color)
    create("UIStroke", {
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        Color = color or NullLibrary.Theme.Stroke,
        Parent = parent
    })
end

local function padding(parent, horizontal, vertical)
    create("UIPadding", {
        PaddingLeft = UDim.new(0, horizontal or 0),
        PaddingRight = UDim.new(0, horizontal or 0),
        PaddingTop = UDim.new(0, vertical or 0),
        PaddingBottom = UDim.new(0, vertical or 0),
        Parent = parent
    })
end

local function list(parent, spacing, horizontal)
    return create("UIListLayout", {
        FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, spacing or 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent
    })
end

local function tween(object, properties, duration, style, direction)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
        properties
    )
    animation:Play()
    return animation
end

local function viewportSize()
    Camera = workspace.CurrentCamera or Camera
    return Camera and Camera.ViewportSize or Vector2.new(1280, 720)
end

local function isTouch()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

local function autosizeText(label)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.TextWrapped = true
    return label
end

local function normalizeSetArgs(selfOrValue, maybeValue, maybeSkip)
    if type(selfOrValue) == "table" then
        return maybeValue, maybeSkip
    end

    return selfOrValue, maybeValue
end

local function shallowCopy(tbl)
    local clone = {}
    for key, value in pairs(tbl) do
        clone[key] = value
    end
    return clone
end

local Storage = {}
do
    local function pick(...)
        for _, candidate in ipairs({...}) do
            if type(candidate) == "function" then
                return candidate
            end
        end
    end

    Storage.readfile = pick(rawget(_G, "readfile"))
    Storage.writefile = pick(rawget(_G, "writefile"))
    Storage.makefolder = pick(rawget(_G, "makefolder"))
    Storage.isfolder = pick(rawget(_G, "isfolder"))
    Storage.isfile = pick(rawget(_G, "isfile"), rawget(_G, "readfile") and function(path)
        local ok = pcall(readfile, path)
        return ok
    end)
    Storage.listfiles = pick(rawget(_G, "listfiles"))
end

function NullLibrary:_storageAvailable()
    return Storage.readfile and Storage.writefile and Storage.makefolder and Storage.isfolder and Storage.isfile
end

function NullLibrary:_ensureNotificationGui()
    if self._notifyGui and self._notifyGui.Parent then
        return self._notifyGui, self._notifyHolder
    end

    local gui = create("ScreenGui", {
        Name = "NullUI_Notifications",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = PlayerGui
    })

    local area = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -16, 0, 16),
        Size = UDim2.new(0, 360, 1, -32),
        Parent = gui
    })

    local holder = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = area
    })
    list(holder, 10, false).HorizontalAlignment = Enum.HorizontalAlignment.Right

    local mobile = viewportSize().X < 760 or isTouch()
    area.AnchorPoint = mobile and Vector2.new(0.5, 0) or Vector2.new(1, 0)
    area.Position = mobile and UDim2.new(0.5, 0, 0, 12) or UDim2.new(1, -16, 0, 16)
    area.Size = mobile and UDim2.new(1, -24, 1, -24) or UDim2.new(0, 360, 1, -32)

    self._notifyGui = gui
    self._notifyHolder = holder
    return gui, holder
end

function NullLibrary:Notify(options)
    options = options or {}
    local _, holder = self:_ensureNotificationGui()
    local mobile = viewportSize().X < 760 or isTouch()

    local card = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Theme.SurfaceSoft,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = holder
    })
    corner(card, 18)
    stroke(card, 0.12, 1)

    local line = create("Frame", {
        BackgroundColor3 = options.Color or self.Theme.AccentSoft,
        Size = UDim2.new(0, 4, 1, 0),
        Parent = card
    })
    corner(line, 999)

    local body = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 12),
        Size = UDim2.new(1, -28, 0, 0),
        Parent = card
    })
    list(body, 8, false)

    local header = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = body
    })
    list(header, 10, true).VerticalAlignment = Enum.VerticalAlignment.Center

    local iconWrap = create("Frame", {
        BackgroundColor3 = self.Theme.SurfaceRaised,
        BackgroundTransparency = (options.Icon or options.Image) and 0 or 1,
        Size = UDim2.fromOffset(mobile and 36 or 40, mobile and 36 or 40),
        Visible = options.Icon ~= nil or options.Image ~= nil,
        Parent = header
    })
    corner(iconWrap, 12)

    create("ImageLabel", {
        BackgroundTransparency = 1,
        Image = options.Icon or options.Image or "",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.new(1, -12, 1, -12),
        ScaleType = Enum.ScaleType.Fit,
        Parent = iconWrap
    })

    local textWrap = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, iconWrap.Visible and -50 or 0, 0, 0),
        Parent = header
    })
    list(textWrap, 4, false)

    autosizeText(create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 0),
        Text = options.Title or "Notification",
        TextColor3 = self.Theme.Text,
        TextSize = mobile and 14 or 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = textWrap
    }))

    autosizeText(create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Size = UDim2.new(1, 0, 0, 0),
        Text = options.Content or options.Text or "",
        TextColor3 = self.Theme.Muted,
        TextSize = mobile and 12 or 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = textWrap
    }))

    if options.ImagePreview then
        local preview = create("ImageLabel", {
            BackgroundColor3 = self.Theme.SurfaceRaised,
            Image = options.ImagePreview,
            Size = UDim2.new(1, 0, 0, mobile and 120 or 140),
            ScaleType = Enum.ScaleType.Crop,
            Parent = body
        })
        corner(preview, 14)
    end

    local close = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -8, 0, 6),
        Size = UDim2.fromOffset(26, 26),
        Text = "x",
        Font = Enum.Font.GothamBold,
        TextColor3 = self.Theme.Muted,
        TextSize = 14,
        Parent = card
    })

    card.BackgroundTransparency = 1
    line.BackgroundTransparency = 1
    body.Position = body.Position + UDim2.fromOffset(0, 6)
    tween(card, {BackgroundTransparency = 0}, 0.22)
    tween(line, {BackgroundTransparency = 0}, 0.24)
    tween(body, {Position = body.Position - UDim2.fromOffset(0, 6)}, 0.24)

    local closed = false
    local function dismiss()
        if closed then
            return
        end
        closed = true
        tween(card, {BackgroundTransparency = 1}, 0.18)
        tween(line, {BackgroundTransparency = 1}, 0.18)
        task.delay(0.2, function()
            if card and card.Parent then
                card:Destroy()
            end
        end)
    end

    close.MouseButton1Click:Connect(dismiss)
    task.delay(options.Duration or 4.5, dismiss)

    return {Dismiss = dismiss, Card = card}
end

function NullLibrary:_createCardButton(parent, height)
    local button = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = self.Theme.SurfaceRaised,
        Size = UDim2.new(1, 0, 0, height or 42),
        Text = "",
        Parent = parent
    })
    corner(button, 14)
    stroke(button, 0.15, 1)

    button.MouseEnter:Connect(function()
        tween(button, {BackgroundColor3 = self.Theme.SurfaceAccent}, 0.16)
    end)

    button.MouseLeave:Connect(function()
        tween(button, {BackgroundColor3 = self.Theme.SurfaceRaised}, 0.16)
    end)

    return button
end
function NullLibrary:CreateWindow(options)
    options = options or {}

    local name = options.Name or "NullUI"
    local existing = PlayerGui:FindFirstChild(name)
    if existing then
        existing:Destroy()
    end

    local screenGui = create("ScreenGui", {
        Name = name,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = PlayerGui
    })

    local blurBack = create("Frame", {
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 0.2,
        Size = UDim2.fromScale(1, 1),
        Parent = screenGui
    })

    local root = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Theme.Surface,
        Position = options.Position or UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(780, 520),
        Parent = screenGui
    })
    corner(root, 24)
    stroke(root, 0.1, 1)

    local uiScale = create("UIScale", {Scale = 1, Parent = root})

    local topGlow = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = self.Theme.AccentSoft,
        BackgroundTransparency = 0.94,
        Position = UDim2.new(0.5, 0, 0, -100),
        Size = UDim2.fromOffset(420, 220),
        Parent = root
    })
    corner(topGlow, 999)

    local clip = create("Frame", {
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Size = UDim2.fromScale(1, 1),
        Parent = root
    })
    corner(clip, 24)

    local topbar = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 76),
        Parent = clip
    })
    padding(topbar, 18, 16)

    local leftHeader = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -140, 1, 0),
        Parent = topbar
    })
    list(leftHeader, 12, true).VerticalAlignment = Enum.VerticalAlignment.Center

    local titleIcon = create("ImageLabel", {
        BackgroundColor3 = self.Theme.SurfaceRaised,
        BackgroundTransparency = options.Icon and 0 or 1,
        Image = options.Icon or "",
        Size = UDim2.fromOffset(44, 44),
        ScaleType = Enum.ScaleType.Fit,
        Visible = options.Icon ~= nil,
        Parent = leftHeader
    })
    corner(titleIcon, 14)

    local titleWrap = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, titleIcon.Visible and -56 or 0, 0, 0),
        Parent = leftHeader
    })
    list(titleWrap, 3, false)

    local title = autosizeText(create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBlack,
        Size = UDim2.new(1, 0, 0, 0),
        Text = options.Title or "Null",
        TextColor3 = self.Theme.Text,
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleWrap
    }))

    local subtitle = autosizeText(create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Size = UDim2.new(1, 0, 0, 0),
        Text = options.Subtitle or "minimal utility interface",
        TextColor3 = self.Theme.Muted,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleWrap
    }))

    local controls = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -18, 0, 16),
        Size = UDim2.fromOffset(110, 40),
        Parent = clip
    })
    local controlsLayout = list(controls, 8, true)
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local badge = create("Frame", {
        BackgroundColor3 = self.Theme.SurfaceRaised,
        Size = UDim2.fromOffset(68, 36),
        Parent = controls
    })
    corner(badge, 14)
    stroke(badge, 0.12, 1)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Size = UDim2.fromScale(1, 1),
        Text = options.BadgeText or "NULL",
        TextColor3 = self.Theme.Text,
        TextSize = 11,
        Parent = badge
    })

    local hideButton = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = self.Theme.SurfaceRaised,
        Size = UDim2.fromOffset(36, 36),
        Text = "-",
        TextColor3 = self.Theme.Muted,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = controls
    })
    corner(hideButton, 14)
    stroke(hideButton, 0.12, 1)

    local sidebar = create("Frame", {
        BackgroundColor3 = self.Theme.SurfaceSoft,
        Position = UDim2.fromOffset(18, 84),
        Size = UDim2.new(0, 190, 1, -102),
        Parent = clip
    })
    corner(sidebar, 22)
    stroke(sidebar, 0.1, 1)
    padding(sidebar, 12, 12)

    local sidebarHeader = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 18),
        Text = options.SidebarTitle or "Tabs",
        TextColor3 = self.Theme.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sidebar
    })

    local tabHolder = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 24),
        Size = UDim2.new(1, 0, 1, -24),
        Parent = sidebar
    })
    list(tabHolder, 8, false)

    local content = create("Frame", {
        BackgroundColor3 = self.Theme.SurfaceSoft,
        Position = UDim2.fromOffset(220, 84),
        Size = UDim2.new(1, -238, 1, -102),
        Parent = clip
    })
    corner(content, 22)
    stroke(content, 0.1, 1)

    local pages = create("Folder", {Name = "Pages", Parent = content})

    local resizeHandle = create("TextButton", {
        AnchorPoint = Vector2.new(1, 1),
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -8, 1, -8),
        Size = UDim2.fromOffset(24, 24),
        Text = "",
        Parent = root
    })

    for index = 0, 2 do
        local line = create("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = self.Theme.Muted,
            BackgroundTransparency = 0.25 + (index * 0.2),
            Position = UDim2.new(1, -(index * 6), 1, 0),
            Size = UDim2.fromOffset(12 - (index * 2), 2),
            Rotation = -45,
            Parent = resizeHandle
        })
        corner(line, 999)
    end

    local mobileToggle = create("ImageButton", {
        AnchorPoint = Vector2.new(0, 1),
        AutoButtonColor = false,
        BackgroundColor3 = self.Theme.SurfaceSoft,
        Image = options.MobileToggleIcon or options.Icon or "",
        Position = UDim2.new(0, 12, 1, -12),
        Size = UDim2.fromOffset(56, 56),
        Visible = false,
        Parent = screenGui
    })
    corner(mobileToggle, 18)
    stroke(mobileToggle, 0.1, 1)

    if mobileToggle.Image == "" then
        create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBlack,
            Size = UDim2.fromScale(1, 1),
            Text = "N",
            TextColor3 = self.Theme.Text,
            TextSize = 18,
            Parent = mobileToggle
        })
    end

    local window = setmetatable({
        Library = self,
        ScreenGui = screenGui,
        Root = root,
        BlurBack = blurBack,
        Sidebar = sidebar,
        Content = content,
        Pages = pages,
        TabHolder = tabHolder,
        Tabs = {},
        CurrentTab = nil,
        MinSize = options.MinSize or Vector2.new(420, 340),
        MaxSize = options.MaxSize or Vector2.new(1200, 900),
        CurrentSize = options.Size and Vector2.new(options.Size.X.Offset, options.Size.Y.Offset) or Vector2.new(780, 520),
        UserResized = false,
        Open = true,
        ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl,
        Elements = {},
        Flags = {},
        PendingConfig = nil,
        ConfigFolder = options.ConfigFolder or "NullUI",
        ConfigName = options.ConfigName or name,
        MobileToggle = mobileToggle,
        TitleLabel = title,
        SubtitleLabel = subtitle,
        TitleIcon = titleIcon,
    }, Window)

    function window:_configDirectory()
        return self.ConfigFolder
    end

    function window:_configFilePath(configName)
        return string.format("%s/%s.json", self:_configDirectory(), configName)
    end

    function window:_autoloadStatePath()
        return string.format("%s/_autoload.json", self:_configDirectory())
    end

    function window:_ensureFolders()
        if not self.Library:_storageAvailable() then
            return false
        end

        if not Storage.isfolder(self:_configDirectory()) then
            pcall(Storage.makefolder, self:_configDirectory())
        end

        return true
    end

    function window:_readJson(path)
        if not self.Library:_storageAvailable() or not Storage.isfile(path) then
            return nil
        end

        local ok, raw = pcall(Storage.readfile, path)
        if not ok or type(raw) ~= "string" or raw == "" then
            return nil
        end

        local decodeOk, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if decodeOk then
            return data
        end

        return nil
    end

    function window:_writeJson(path, data)
        if not self:_ensureFolders() then
            return false
        end

        local encodeOk, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not encodeOk then
            return false
        end

        local ok = pcall(Storage.writefile, path, encoded)
        return ok
    end

    function window:_registerFlag(flag, controller, defaultValue)
        if not flag then
            return controller
        end

        self.Elements[flag] = controller
        if defaultValue ~= nil and self.Flags[flag] == nil then
            self.Flags[flag] = defaultValue
        end

        if self.PendingConfig and self.PendingConfig[flag] ~= nil and controller and controller.Set then
            controller:Set(self.PendingConfig[flag], true)
        end

        return controller
    end

    function window:_collectFlags()
        local data = {}
        for flag, controller in pairs(self.Elements) do
            if controller and controller.Get then
                data[flag] = controller:Get()
            end
        end
        return data
    end
    function window:SaveConfig(configName, silent)
        configName = configName or self.ConfigName
        if not self:_ensureFolders() then
            if not silent then
                self.Library:Notify({
                    Title = "Config Error",
                    Content = "В этой среде нет поддержки файловых функций.",
                    Color = self.Library.Theme.Bad
                })
            end
            return false
        end

        local ok = self:_writeJson(self:_configFilePath(configName), self:_collectFlags())
        if ok and not silent then
            self.Library:Notify({
                Title = "Config Saved",
                Content = string.format("Конфиг '%s' сохранён.", configName),
                Color = self.Library.Theme.Good
            })
        end
        return ok
    end

    function window:LoadConfig(configName, silent)
        configName = configName or self.ConfigName
        local data = self:_readJson(self:_configFilePath(configName))
        if not data then
            if not silent then
                self.Library:Notify({
                    Title = "Config Error",
                    Content = string.format("Не удалось загрузить конфиг '%s'.", configName),
                    Color = self.Library.Theme.Bad
                })
            end
            return false
        end

        self.PendingConfig = shallowCopy(data)
        for flag, value in pairs(data) do
            local controller = self.Elements[flag]
            if controller and controller.Set then
                controller:Set(value, true)
            end
        end

        if not silent then
            self.Library:Notify({
                Title = "Config Loaded",
                Content = string.format("Конфиг '%s' загружен.", configName),
                Color = self.Library.Theme.Good
            })
        end

        return true
    end

    function window:EnableAutoLoad(configName, silent)
        configName = configName or self.ConfigName
        if not self:_ensureFolders() then
            return false
        end

        local ok = self:_writeJson(self:_autoloadStatePath(), {AutoLoad = configName})
        if ok and not silent then
            self.Library:Notify({
                Title = "Auto Load Enabled",
                Content = string.format("Конфиг '%s' будет загружаться автоматически.", configName),
                Color = self.Library.Theme.Good
            })
        end
        return ok
    end

    function window:DisableAutoLoad(silent)
        if not self:_ensureFolders() then
            return false
        end

        local ok = self:_writeJson(self:_autoloadStatePath(), {AutoLoad = false})
        if ok and not silent then
            self.Library:Notify({
                Title = "Auto Load Disabled",
                Content = "Автозагрузка выключена."
            })
        end
        return ok
    end

    function window:ListConfigs()
        if not self:_ensureFolders() or not Storage.listfiles then
            return {}
        end

        local ok, files = pcall(Storage.listfiles, self:_configDirectory())
        if not ok or type(files) ~= "table" then
            return {}
        end

        local names = {}
        for _, path in ipairs(files) do
            local configName = string.match(path, "([^/\\]+)%.json$")
            if configName and configName ~= "_autoload" then
                table.insert(names, configName)
            end
        end

        table.sort(names)
        return names
    end

    function window:_primeAutoLoad()
        if not self:_ensureFolders() then
            return
        end

        local target = options.AutoLoadConfig
        if not target then
            local state = self:_readJson(self:_autoloadStatePath())
            if state and state.AutoLoad and state.AutoLoad ~= false then
                target = state.AutoLoad
            end
        end

        if target then
            self:LoadConfig(target, true)
        end
    end

    function window:_applyRootSize()
        local size = viewportSize()
        local maxWidth = math.max(360, size.X - 24)
        local maxHeight = math.max(300, size.Y - 24)
        local mobile = size.X < 760 or isTouch()

        self.CurrentSize = Vector2.new(
            math.clamp(self.CurrentSize.X, self.MinSize.X, math.min(self.MaxSize.X, maxWidth)),
            math.clamp(self.CurrentSize.Y, self.MinSize.Y, math.min(self.MaxSize.Y, maxHeight))
        )

        if mobile and not self.UserResized then
            self.CurrentSize = Vector2.new(math.min(420, maxWidth), math.min(540, maxHeight))
        end

        self.Root.Size = UDim2.fromOffset(self.CurrentSize.X, self.CurrentSize.Y)
        self.MobileToggle.Visible = mobile and not self.Open
        hideButton.Visible = not mobile
        resizeHandle.Visible = not mobile

        if mobile then
            uiScale.Scale = 0.92
            sidebar.Size = UDim2.new(0, 98, 1, -102)
            content.Position = UDim2.fromOffset(128, 84)
            content.Size = UDim2.new(1, -146, 1, -102)
            sidebarHeader.Text = "UI"
            title.TextSize = 22
            subtitle.TextSize = 12
        else
            uiScale.Scale = 1
            sidebar.Size = UDim2.new(0, 190, 1, -102)
            content.Position = UDim2.fromOffset(220, 84)
            content.Size = UDim2.new(1, -238, 1, -102)
            sidebarHeader.Text = options.SidebarTitle or "Tabs"
            title.TextSize = 24
            subtitle.TextSize = 13
        end
    end

    function window:_setOpen(openState, instant)
        self.Open = openState

        if openState then
            self.ScreenGui.Enabled = true
            self.MobileToggle.Visible = false

            if instant then
                self.Root.Size = UDim2.fromOffset(self.CurrentSize.X, self.CurrentSize.Y)
                self.BlurBack.BackgroundTransparency = 0.2
                self.Root.BackgroundTransparency = 0
                return
            end

            self.Root.Size = UDim2.fromOffset(self.CurrentSize.X * 0.94, self.CurrentSize.Y * 0.92)
            self.Root.BackgroundTransparency = 0.08
            self.BlurBack.BackgroundTransparency = 1
            tween(self.Root, {Size = UDim2.fromOffset(self.CurrentSize.X, self.CurrentSize.Y), BackgroundTransparency = 0}, 0.24)
            tween(self.BlurBack, {BackgroundTransparency = 0.2}, 0.2)
        else
            self.MobileToggle.Visible = isTouch() or viewportSize().X < 760

            if instant then
                self.ScreenGui.Enabled = false
                return
            end

            tween(self.Root, {Size = UDim2.fromOffset(self.CurrentSize.X * 0.95, self.CurrentSize.Y * 0.92), BackgroundTransparency = 0.08}, 0.18)
            tween(self.BlurBack, {BackgroundTransparency = 1}, 0.18)
            task.delay(0.18, function()
                if self.Root and not self.Open then
                    self.ScreenGui.Enabled = false
                end
            end)
        end
    end

    function window:Toggle(state)
        if state == nil then
            state = not self.Open
        end
        self:_setOpen(state, false)
    end

    function window:Notify(notification)
        return self.Library:Notify(notification)
    end

    function window:SetTitle(text, iconImage)
        self.TitleLabel.Text = text or self.TitleLabel.Text
        if iconImage ~= nil then
            self.TitleIcon.Image = iconImage
            self.TitleIcon.Visible = iconImage ~= ""
            self.TitleIcon.BackgroundTransparency = iconImage ~= "" and 0 or 1
        end
    end

    function window:SetSubtitle(text)
        self.SubtitleLabel.Text = text or self.SubtitleLabel.Text
    end

    function window:Destroy()
        self.ScreenGui:Destroy()
    end

    function window:CreateTab(tabOptions, maybeIcon)
        if type(tabOptions) ~= "table" then
            tabOptions = {Name = tabOptions, Icon = maybeIcon}
        end

        local button = create("TextButton", {
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 52),
            Text = "",
            Parent = tabHolder
        })

        local frame = create("Frame", {
            BackgroundColor3 = self.Library.Theme.SurfaceRaised,
            Size = UDim2.fromScale(1, 1),
            Parent = button
        })
        corner(frame, 16)
        stroke(frame, 0.15, 1)

        local activeLine = create("Frame", {
            BackgroundColor3 = self.Library.Theme.AccentSoft,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, 25),
            Size = UDim2.fromOffset(12, 2),
            Parent = frame
        })
        corner(activeLine, 999)

        local iconWrap = create("Frame", {
            BackgroundColor3 = self.Library.Theme.SurfaceAccent,
            Position = UDim2.fromOffset(10, 10),
            Size = UDim2.fromOffset(32, 32),
            Parent = frame
        })
        corner(iconWrap, 10)

        create("ImageLabel", {
            BackgroundTransparency = 1,
            Image = tabOptions.Image or "",
            Position = UDim2.fromOffset(6, 6),
            Size = UDim2.fromOffset(20, 20),
            ScaleType = Enum.ScaleType.Fit,
            Visible = tabOptions.Image ~= nil,
            Parent = iconWrap
        })

        create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Size = UDim2.fromScale(1, 1),
            Text = tabOptions.Image and "" or (tabOptions.Icon or "•"),
            TextColor3 = self.Library.Theme.Text,
            TextSize = 16,
            Parent = iconWrap
        })

        local label = create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Position = UDim2.fromOffset(52, 9),
            Size = UDim2.new(1, -62, 0, 18),
            Text = tabOptions.Name or "Tab",
            TextColor3 = self.Library.Theme.Muted,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })

        create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Position = UDim2.fromOffset(52, 27),
            Size = UDim2.new(1, -62, 0, 14),
            Text = tabOptions.Description or "",
            TextColor3 = self.Library.Theme.Muted,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = tabOptions.Description ~= nil and tabOptions.Description ~= "",
            Parent = frame
        })

        local page = create("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(),
            Position = UDim2.fromOffset(16, 16),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = self.Library.Theme.AccentSoft,
            Size = UDim2.new(1, -32, 1, -32),
            Visible = false,
            Parent = pages
        })
        list(page, 12, false)

        local tab = setmetatable({Window = self, Button = button, Frame = frame, Label = label, ActiveLine = activeLine, IconWrap = iconWrap, Page = page}, Tab)
        table.insert(self.Tabs, tab)

        button.MouseButton1Click:Connect(function()
            self:SelectTab(tab)
        end)

        if not self.CurrentTab then
            self:SelectTab(tab, true)
        end

        return tab
    end

    function window:SelectTab(targetTab, instant)
        if self.CurrentTab == targetTab then
            return
        end

        for _, tab in ipairs(self.Tabs) do
            local active = tab == targetTab
            tab.Page.Visible = true
            tween(tab.Frame, {BackgroundColor3 = active and self.Library.Theme.SurfaceAccent or self.Library.Theme.SurfaceRaised}, instant and 0 or 0.18)
            tween(tab.IconWrap, {BackgroundColor3 = active and self.Library.Theme.AccentSoft or self.Library.Theme.SurfaceAccent}, instant and 0 or 0.18)
            tween(tab.ActiveLine, {BackgroundTransparency = active and 0 or 1, Size = active and UDim2.fromOffset(26, 2) or UDim2.fromOffset(12, 2)}, instant and 0 or 0.18)
            tab.Label.TextColor3 = active and self.Library.Theme.Text or self.Library.Theme.Muted

            if active then
                tab.Page.Position = UDim2.fromOffset(24, 16)
                tween(tab.Page, {Position = UDim2.fromOffset(16, 16)}, instant and 0 or 0.2)
            else
                task.delay(instant and 0 or 0.12, function()
                    if tab.Page and self.CurrentTab ~= tab then
                        tab.Page.Visible = false
                    end
                end)
            end
        end

        self.CurrentTab = targetTab
    end
    local dragging = false
    local dragStart
    local startPosition

    topbar.InputBegan:Connect(function(input)
        local userType = input.UserInputType
        if userType ~= Enum.UserInputType.MouseButton1 and userType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        dragStart = input.Position
        startPosition = root.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        local userType = input.UserInputType
        if userType ~= Enum.UserInputType.MouseMovement and userType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart
        root.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end)

    local resizing = false
    local resizeStart
    local resizeBase

    resizeHandle.InputBegan:Connect(function(input)
        local userType = input.UserInputType
        if userType ~= Enum.UserInputType.MouseButton1 and userType ~= Enum.UserInputType.Touch then
            return
        end

        resizing = true
        resizeStart = input.Position
        resizeBase = window.CurrentSize

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                resizing = false
            end
        end)
    end)

    UIS.InputChanged:Connect(function(input)
        if not resizing then
            return
        end

        local userType = input.UserInputType
        if userType ~= Enum.UserInputType.MouseMovement and userType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - resizeStart
        window.UserResized = true
        window.CurrentSize = Vector2.new(resizeBase.X + delta.X, resizeBase.Y + delta.Y)
        window:_applyRootSize()
    end)

    UIS.InputEnded:Connect(function(input)
        local userType = input.UserInputType
        if userType == Enum.UserInputType.MouseButton1 or userType == Enum.UserInputType.Touch then
            dragging = false
            resizing = false
        end
    end)

    hideButton.MouseButton1Click:Connect(function()
        window:Toggle(false)
    end)

    mobileToggle.MouseButton1Click:Connect(function()
        window:Toggle(true)
    end)

    UIS.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end

        if input.KeyCode == window.ToggleKey then
            window:Toggle()
        end
    end)

    window:_primeAutoLoad()
    window:_applyRootSize()
    window:_setOpen(true, false)

    if options.WelcomeNotification ~= false then
        task.delay(0.08, function()
            window:Notify({
                Title = options.Title or "Null",
                Content = "UI launched successfully.",
                Icon = options.Icon,
                Duration = 3
            })
        end)
    end

    return window
end

function Tab:CreateSection(sectionOptions, maybeDescription)
    if type(sectionOptions) ~= "table" then
        sectionOptions = {Title = sectionOptions, Description = maybeDescription}
    end

    local card = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = NullLibrary.Theme.SurfaceSoft,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = self.Page
    })
    corner(card, 18)
    stroke(card, 0.12, 1)
    padding(card, 16, 16)

    autosizeText(create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 0),
        Text = sectionOptions.Title or "Section",
        TextColor3 = NullLibrary.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card
    }))

    if sectionOptions.Description and sectionOptions.Description ~= "" then
        autosizeText(create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Position = UDim2.fromOffset(0, 22),
            Size = UDim2.new(1, 0, 0, 0),
            Text = sectionOptions.Description,
            TextColor3 = NullLibrary.Theme.Muted,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = card
        }))
    end

    local holder = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, sectionOptions.Description and sectionOptions.Description ~= "" and 54 or 30),
        Size = UDim2.new(1, 0, 0, 0),
        Parent = card
    })
    list(holder, 10, false)

    local section = {}
    local function register(flag, controller, defaultValue)
        return self.Window:_registerFlag(flag, controller, defaultValue)
    end

    function section:AddLabel(text)
        return autosizeText(create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Size = UDim2.new(1, 0, 0, 0),
            Text = text or "Label",
            TextColor3 = NullLibrary.Theme.Muted,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = holder
        }))
    end

    function section:AddParagraph(titleText, bodyText)
        local paragraph = create("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = NullLibrary.Theme.SurfaceRaised,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = holder
        })
        corner(paragraph, 14)
        padding(paragraph, 14, 12)

        autosizeText(create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Size = UDim2.new(1, 0, 0, 0),
            Text = titleText or "Info",
            TextColor3 = NullLibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = paragraph
        }))

        autosizeText(create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Position = UDim2.fromOffset(0, 22),
            Size = UDim2.new(1, 0, 0, 0),
            Text = bodyText or "",
            TextColor3 = NullLibrary.Theme.Muted,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = paragraph
        }))

        return paragraph
    end

    function section:AddImage(options)
        options = options or {}

        local frame = create("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = NullLibrary.Theme.SurfaceRaised,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = holder
        })
        corner(frame, 14)
        stroke(frame, 0.15, 1)
        padding(frame, 10, 10)

        local image = create("ImageLabel", {
            BackgroundColor3 = NullLibrary.Theme.SurfaceAccent,
            Image = options.Image or "",
            Size = UDim2.new(1, 0, 0, options.Height or 140),
            ScaleType = options.ScaleType or Enum.ScaleType.Crop,
            Parent = frame
        })
        corner(image, options.CornerRadius or 12)

        if options.Caption and options.Caption ~= "" then
            autosizeText(create("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Position = UDim2.fromOffset(0, (options.Height or 140) + 10),
                Size = UDim2.new(1, 0, 0, 0),
                Text = options.Caption,
                TextColor3 = NullLibrary.Theme.Muted,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame
            }))
        end

        return image
    end
    function section:AddButton(options)
        options = options or {}
        local button = NullLibrary:_createCardButton(holder, options.Height or 42)
        local showIcon = options.Icon ~= nil

        create("ImageLabel", {
            BackgroundTransparency = 1,
            Image = options.Icon or "",
            Position = UDim2.fromOffset(12, 11),
            Size = UDim2.fromOffset(20, 20),
            ScaleType = Enum.ScaleType.Fit,
            Visible = showIcon,
            Parent = button
        })

        create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Position = UDim2.fromOffset(showIcon and 40 or 14, 0),
            Size = UDim2.new(1, showIcon and -52 or -28, 1, 0),
            Text = options.Text or "Button",
            TextColor3 = NullLibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = button
        })

        button.MouseButton1Click:Connect(function()
            if options.Callback then
                task.spawn(options.Callback)
            end
        end)

        return button
    end

    function section:AddToggle(options)
        options = options or {}
        local flag = options.Flag or options.Text
        local state = options.Default or false

        local button = NullLibrary:_createCardButton(holder, 48)
        create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Position = UDim2.fromOffset(14, 7),
            Size = UDim2.new(1, -78, 0, 16),
            Text = options.Text or "Toggle",
            TextColor3 = NullLibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = button
        })

        if options.Description and options.Description ~= "" then
            create("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Position = UDim2.fromOffset(14, 24),
                Size = UDim2.new(1, -78, 0, 14),
                Text = options.Description,
                TextColor3 = NullLibrary.Theme.Muted,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = button
            })
        end

        local track = create("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = state and NullLibrary.Theme.AccentSoft or NullLibrary.Theme.SurfaceAccent,
            Position = UDim2.new(1, -14, 0.5, 0),
            Size = UDim2.fromOffset(48, 26),
            Parent = button
        })
        corner(track, 999)

        local knob = create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = NullLibrary.Theme.Surface,
            Position = state and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.fromOffset(22, 22),
            Parent = track
        })
        corner(knob, 999)

        local controller = {Window = self.Window}
        function controller:Set(selfOrValue, maybeValue, maybeSkip)
            local newValue, skipCallback = normalizeSetArgs(selfOrValue, maybeValue, maybeSkip)
            state = not not newValue
            tween(track, {BackgroundColor3 = state and NullLibrary.Theme.AccentSoft or NullLibrary.Theme.SurfaceAccent}, 0.18)
            tween(knob, {Position = state and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.18)
            self.Window.Flags[flag] = state

            if not skipCallback and options.Callback then
                task.spawn(options.Callback, state)
            end
        end

        function controller:Get()
            return state
        end

        button.MouseButton1Click:Connect(function()
            controller:Set(not state)
        end)

        register(flag, controller, state)
        controller:Set(state, true)
        return controller
    end

    function section:AddSlider(options)
        options = options or {}
        local flag = options.Flag or options.Text
        local minimum = options.Min or 0
        local maximum = options.Max or 100
        local value = math.clamp(options.Default or minimum, minimum, maximum)
        local dragging = false

        local frame = create("Frame", {
            BackgroundColor3 = NullLibrary.Theme.SurfaceRaised,
            Size = UDim2.new(1, 0, 0, 66),
            Parent = holder
        })
        corner(frame, 14)
        stroke(frame, 0.15, 1)

        create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Position = UDim2.fromOffset(14, 10),
            Size = UDim2.new(1, -88, 0, 16),
            Text = options.Text or "Slider",
            TextColor3 = NullLibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })

        local number = create("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Position = UDim2.new(1, -14, 0, 10),
            Size = UDim2.fromOffset(64, 16),
            Text = tostring(value),
            TextColor3 = NullLibrary.Theme.AccentSoft,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = frame
        })

        local track = create("Frame", {
            BackgroundColor3 = NullLibrary.Theme.SurfaceAccent,
            Position = UDim2.fromOffset(14, 42),
            Size = UDim2.new(1, -28, 0, 8),
            Parent = frame
        })
        corner(track, 999)

        local fill = create("Frame", {
            BackgroundColor3 = NullLibrary.Theme.AccentSoft,
            Size = UDim2.new(0, 0, 1, 0),
            Parent = track
        })
        corner(fill, 999)

        local knob = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = NullLibrary.Theme.Text,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(16, 16),
            Parent = track
        })
        corner(knob, 999)

        local controller = {Window = self.Window}
        function controller:Set(selfOrValue, maybeValue, maybeSkip)
            local newValue, skipCallback = normalizeSetArgs(selfOrValue, maybeValue, maybeSkip)
            newValue = tonumber(newValue) or minimum
            value = math.clamp(newValue, minimum, maximum)

            local alpha = (value - minimum) / math.max(maximum - minimum, 1)
            fill.Size = UDim2.new(alpha, 0, 1, 0)
            knob.Position = UDim2.new(alpha, 0, 0.5, 0)
            number.Text = tostring(math.floor((value * 100) + 0.5) / 100)
            self.Window.Flags[flag] = value

            if not skipCallback and options.Callback then
                task.spawn(options.Callback, value)
            end
        end

        function controller:Get()
            return value
        end

        local function updateFromPosition(position)
            local alpha = (position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            controller:Set(minimum + ((maximum - minimum) * alpha))
        end

        track.InputBegan:Connect(function(input)
            local userType = input.UserInputType
            if userType ~= Enum.UserInputType.MouseButton1 and userType ~= Enum.UserInputType.Touch then
                return
            end

            dragging = true
            updateFromPosition(input.Position)
        end)

        UIS.InputChanged:Connect(function(input)
            if not dragging then
                return
            end

            local userType = input.UserInputType
            if userType ~= Enum.UserInputType.MouseMovement and userType ~= Enum.UserInputType.Touch then
                return
            end

            updateFromPosition(input.Position)
        end)

        UIS.InputEnded:Connect(function(input)
            local userType = input.UserInputType
            if userType == Enum.UserInputType.MouseButton1 or userType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        register(flag, controller, value)
        controller:Set(value, true)
        return controller
    end

    function section:AddTextbox(options)
        options = options or {}
        local flag = options.Flag or options.Text or options.Placeholder
        local value = options.Default or ""

        local frame = create("Frame", {
            BackgroundColor3 = NullLibrary.Theme.SurfaceRaised,
            Size = UDim2.new(1, 0, 0, 46),
            Parent = holder
        })
        corner(frame, 14)
        stroke(frame, 0.15, 1)

        local box = create("TextBox", {
            BackgroundTransparency = 1,
            ClearTextOnFocus = false,
            Font = Enum.Font.GothamSemibold,
            PlaceholderColor3 = NullLibrary.Theme.Muted,
            PlaceholderText = options.Placeholder or "Type here...",
            Position = UDim2.fromOffset(14, 0),
            Size = UDim2.new(1, -28, 1, 0),
            Text = value,
            TextColor3 = NullLibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })

        local controller = {Window = self.Window}
        function controller:Set(selfOrValue, maybeValue, maybeSkip)
            local newValue, skipCallback = normalizeSetArgs(selfOrValue, maybeValue, maybeSkip)
            value = tostring(newValue or "")
            box.Text = value
            self.Window.Flags[flag] = value

            if not skipCallback and options.Callback then
                task.spawn(options.Callback, value, false)
            end
        end

        function controller:Get()
            return value
        end

        box.FocusLost:Connect(function(enterPressed)
            value = box.Text
            self.Window.Flags[flag] = value
            if options.Callback then
                task.spawn(options.Callback, value, enterPressed)
            end
        end)

        register(flag, controller, value)
        return controller
    end

    function section:AddDropdown(options)
        options = options or {}
        local flag = options.Flag or options.Text
        local values = options.Values or {}
        local selected = options.Default or values[1] or "None"
        local opened = false

        local wrap = create("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = holder
        })

        local button = NullLibrary:_createCardButton(wrap, 42)

        local label = create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Position = UDim2.fromOffset(14, 0),
            Size = UDim2.new(1, -44, 1, 0),
            Text = string.format("%s: %s", options.Text or "Dropdown", tostring(selected)),
            TextColor3 = NullLibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = button
        })

        local arrow = create("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Position = UDim2.new(1, -14, 0.5, 0),
            Size = UDim2.fromOffset(18, 18),
            Text = "v",
            TextColor3 = NullLibrary.Theme.Muted,
            TextSize = 13,
            Parent = button
        })

        local container = create("Frame", {
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Position = UDim2.fromOffset(0, 48),
            Size = UDim2.new(1, 0, 0, 0),
            Visible = false,
            Parent = wrap
        })

        local listFrame = create("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = NullLibrary.Theme.SurfaceRaised,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = container
        })
        corner(listFrame, 14)
        stroke(listFrame, 0.15, 1)
        padding(listFrame, 8, 8)
        list(listFrame, 6, false)

        local controller = {Window = self.Window}
        local function setOpen(state)
            opened = state
            arrow.Text = opened and "^" or "v"

            if opened then
                container.Visible = true
                container.Size = UDim2.new(1, 0, 0, 0)
                tween(container, {Size = UDim2.new(1, 0, 0, listFrame.AbsoluteSize.Y)}, 0.2)
            else
                tween(container, {Size = UDim2.new(1, 0, 0, 0)}, 0.18)
                task.delay(0.18, function()
                    if container and not opened then
                        container.Visible = false
                    end
                end)
            end
        end

        function controller:Set(selfOrValue, maybeValue, maybeSkip)
            local newValue, skipCallback = normalizeSetArgs(selfOrValue, maybeValue, maybeSkip)
            selected = newValue
            label.Text = string.format("%s: %s", options.Text or "Dropdown", tostring(selected))
            self.Window.Flags[flag] = selected

            if not skipCallback and options.Callback then
                task.spawn(options.Callback, selected)
            end
        end

        function controller:Get()
            return selected
        end

        for _, entry in ipairs(values) do
            local option = create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = NullLibrary.Theme.SurfaceAccent,
                Size = UDim2.new(1, 0, 0, 34),
                Text = "",
                Parent = listFrame
            })
            corner(option, 10)

            create("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamSemibold,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(1, -24, 1, 0),
                Text = tostring(entry),
                TextColor3 = NullLibrary.Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = option
            })

            option.MouseButton1Click:Connect(function()
                controller:Set(entry)
                setOpen(false)
            end)
        end

        button.MouseButton1Click:Connect(function()
            setOpen(not opened)
        end)

        register(flag, controller, selected)
        controller:Set(selected, true)
        return controller
    end

    return section
end

return NullLibrary
