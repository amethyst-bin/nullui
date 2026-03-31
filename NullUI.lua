--AAAAAAAAAAAAAAAA
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
        Shadow = Color3.fromRGB(0, 0, 0),
    },
    Version = "2.1"
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

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
        if key ~= "Parent" and key ~= "Anchored" then
            object[key] = value
        end
    end
    if properties.Parent then
        object.Parent = properties.Parent
    end
    return object
end

local function corner(parent, radius)
    create("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = parent})
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
    local layout = create("UIListLayout", {
        FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, spacing or 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent
    })
    return layout
end

local function tween(object, properties, duration, style, direction, override)
    if not object or not object.Parent then return nil end
    local info = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
    local existing = object:FindFirstChild("Tween_" .. tostring(#object:GetChildren()))
    if existing and not override then existing:Cancel() end
    local animation = TweenService:Create(object, info, properties)
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

local function clampRound(value)
    return math.floor(value + 0.5)
end

local LucideIcons = nil
local function getLucideIcons()
    if LucideIcons ~= nil then return LucideIcons end
    local ok, result = pcall(function()
        return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"))()
    end)
    LucideIcons = ok and type(result) == "table" and result or false
    return LucideIcons
end

local function resolveLucideIcon(source)
    if type(source) ~= "string" then return nil end
    local iconName = source:match("^lucide:(.+)$")
    if not iconName or iconName == "" then return nil end
    local icons = getLucideIcons()
    if type(icons) ~= "table" then return nil end
    return icons[string.lower(iconName)]
end

local function normalizeImage(source)
    if source == nil then return "" end
    local lucideIcon = resolveLucideIcon(source)
    if lucideIcon then return lucideIcon end
    if type(source) == "number" then return "rbxassetid://" .. tostring(source) end
    source = tostring(source)
    if source == "" then return "" end
    if string.match(source, "^%d+$") then return "rbxassetid://" .. source end
    if string.match(source, "^rbxassetid://") or string.match(source, "^rbxthumb://") or string.match(source, "^https?://") then
        return source
    end
    return source
end

local function isImageSource(source)
    if source == nil then return false end
    if type(source) == "number" then return true end
    if resolveLucideIcon(source) then return true end
    source = tostring(source)
    return string.match(source, "^%d+$") ~= nil
        or string.match(source, "^rbxassetid://") ~= nil
        or string.match(source, "^rbxthumb://") ~= nil
        or string.match(source, "^https?://") ~= nil
end

local function setImageTarget(target, source)
    if target then target.Image = normalizeImage(source) end
end

local Storage = {}
do
    local function pick(...)
        for _, candidate in ipairs({...}) do
            if type(candidate) == "function" then return candidate end
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
        Parent = holder,
        BackgroundTransparency = 1,
    })
    corner(card, 11)
    stroke(card, 0.12, 1)
    
    -- Тень
    local shadow = create("Frame", {
        BackgroundTransparency = 0.5,
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(0, 4),
        BorderSizePixel = 0,
        Parent = card,
        ZIndex = -1
    })
    corner(shadow, 11)

    local scale = create("UIScale", {Scale = 0.94, Parent = card})
    create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.72,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 26, 1, 26),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = math.max(card.ZIndex - 1, 0),
        Parent = card
    })

    local line = create("Frame", {
        BackgroundColor3 = options.Color or self.Theme.AccentSoft,
        Size = UDim2.new(0, 4, 1, 0),
        Parent = card,
        BackgroundTransparency = 1
    })
    corner(line, 999)

    local progress = create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = options.Color or self.Theme.AccentSoft,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = card,
        BackgroundTransparency = 0.18
    })

    local body = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(16, 12),
        Size = UDim2.new(1, -40, 0, 0),
        Parent = card
    })
    list(body, 10, false)

    local header = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = body
    })
    local headerLayout = list(header, 10, true)
    headerLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    local iconWrap = create("Frame", {
        BackgroundColor3 = self.Theme.SurfaceRaised,
        BackgroundTransparency = (options.Icon or options.Image) and 0 or 1,
        Size = UDim2.fromOffset(mobile and 36 or 40, mobile and 36 or 40),
        Visible = options.Icon ~= nil or options.Image ~= nil,
        Parent = header
    })
    corner(iconWrap, 9)

    create("ImageLabel", {
        BackgroundTransparency = 1,
        Image = normalizeImage(options.Icon or options.Image),
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
            Image = normalizeImage(options.ImagePreview),
            Size = UDim2.new(1, 0, 0, mobile and 120 or 140),
            ScaleType = Enum.ScaleType.Crop,
            Parent = body
        })
        corner(preview, 9)
    end

    local close = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -8, 0, 6),
        Size = UDim2.fromOffset(28, 28),
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextColor3 = self.Theme.Muted,
        TextSize = 14,
        Parent = card
    })

    -- Анимация появления
    local entrance = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Size = UDim2.new(1, 0, 0, 0)
    })
    tween(scale, {Scale = 1}, 0.28, Enum.EasingStyle.Exponential, nil, true)
    tween(line, {BackgroundTransparency = 0}, 0.25, nil, nil, true)
    tween(body, {Position = UDim2.fromOffset(16, 12)}, 0.3, Enum.EasingStyle.Exponential, nil, true)
    entrance:Play()

    local duration = options.Duration or 4.5
    tween(progress, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear, nil, true)

    local closed = false
    local function dismiss()
        if closed then return end
        closed = true
        tween(card, {BackgroundTransparency = 1}, 0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, true)
        tween(line, {BackgroundTransparency = 1}, 0.2, nil, nil, true)
        tween(progress, {BackgroundTransparency = 1}, 0.2, nil, nil, true)
        tween(scale, {Scale = 0.95}, 0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, true)
        tween(body, {Position = UDim2.fromOffset(28, 12)}, 0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, true)
        task.delay(0.22, function()
            if card and card.Parent then card:Destroy() end
        end)
    end

    close.MouseButton1Click:Connect(dismiss)
    task.delay(duration, dismiss)

    return {Dismiss = dismiss, Card = card}
end

function NullLibrary:_createCardButton(parent, height)
    local button = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = self.Theme.SurfaceRaised,
        Size = UDim2.new(1, 0, 0, height or 42),
        Text = "",
        Parent = parent,
        BackgroundTransparency = 0
    })
    corner(button, 9)
    stroke(button, 0.15, 1)

    button.MouseEnter:Connect(function()
        tween(button, {BackgroundColor3 = self.Theme.SurfaceAccent}, 0.18, nil, nil, true)
    end)

    button.MouseLeave:Connect(function()
        tween(button, {BackgroundColor3 = self.Theme.SurfaceRaised}, 0.18, nil, nil, true)
    end)

    return button
end

function NullLibrary:CreateWindow(options)
    options = options or {}
    local name = options.Name or "NullUI"
    local existing = PlayerGui:FindFirstChild(name)
    if existing then existing:Destroy() end

    local screenGui = create("ScreenGui", {
        Name = name,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = PlayerGui
    })

    local popupLayer = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 20,
        Parent = screenGui
    })

    local root = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Theme.Surface,
        Position = options.Position or UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(780, 520),
        Parent = screenGui
    })
    corner(root, 12)
    stroke(root, 0.1, 1)

    -- Тень окна
    local rootShadow = create("Frame", {
        BackgroundTransparency = 0.6,
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        Size = UDim2.fromOffset(0,0),
        Position = UDim2.fromOffset(0, 6),
        BorderSizePixel = 0,
        Parent = root,
        ZIndex = -2
    })
    corner(rootShadow, 12)

    local uiScale = create("UIScale", {Scale = 1, Parent = root})

    local clip = create("Frame", {
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Size = UDim2.fromScale(1, 1),
        Parent = root
    })
    corner(clip, 12)

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
        Image = normalizeImage(options.Icon),
        Size = UDim2.fromOffset(44, 44),
        ScaleType = Enum.ScaleType.Fit,
        Visible = options.Icon ~= nil,
        Parent = leftHeader
    })
    corner(titleIcon, 9)

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
        Size = UDim2.fromOffset(152, 40),
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
    corner(badge, 9)
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

    local settingsButton = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = self.Theme.SurfaceRaised,
        Size = UDim2.fromOffset(36, 36),
        Text = "⚙",
        TextColor3 = self.Theme.Muted,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = controls
    })
    corner(settingsButton, 9)
    stroke(settingsButton, 0.12, 1)

    local hideButton = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = self.Theme.SurfaceRaised,
        Size = UDim2.fromOffset(36, 36),
        Text = "−",
        TextColor3 = self.Theme.Muted,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = controls
    })
    corner(hideButton, 9)
    stroke(hideButton, 0.12, 1)

    local sidebar = create("Frame", {
        BackgroundColor3 = self.Theme.SurfaceSoft,
        Position = UDim2.fromOffset(18, 84),
        Size = UDim2.new(0, 190, 1, -102),
        Parent = clip
    })
    corner(sidebar, 10)
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
    corner(content, 10)
    stroke(content, 0.1, 1)

    local pages = create("Folder", {Name = "Pages", Parent = content})

    local floatingTabs = create("Frame", {
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 8,
        Parent = screenGui
    })

    local floatingTabsBar = create("Frame", {
        BackgroundColor3 = self.Theme.SurfaceSoft,
        Size = UDim2.fromScale(1, 1),
        Parent = floatingTabs
    })
    corner(floatingTabsBar, 10)
    stroke(floatingTabsBar, 0.1, 1)
    padding(floatingTabsBar, 8, 8)
    create("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.7,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 26, 1, 26),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 7,
        Parent = floatingTabs
    })

    local floatingHolder = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = floatingTabsBar
    })
    local floatingLayout = list(floatingHolder, 8, true)
    floatingLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    floatingLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local settingsMenu = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = self.Theme.SurfaceSoft,
        Position = UDim2.new(1, -18, 0, 60),
        Size = UDim2.fromOffset(170, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 15,
        Parent = clip
    })
    corner(settingsMenu, 10)
    stroke(settingsMenu, 0.1, 1)
    padding(settingsMenu, 8, 8)
    list(settingsMenu, 6, false)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 16),
        Text = "Tab Position",
        TextColor3 = self.Theme.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
        Parent = settingsMenu
    })

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
        Image = normalizeImage(options.MobileToggleIcon or options.Icon),
        Position = UDim2.new(0, 12, 1, -12),
        Size = UDim2.fromOffset(56, 56),
        Visible = false,
        Parent = screenGui
    })
    corner(mobileToggle, 10)
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
        RootShadow = rootShadow,
        PopupLayer = popupLayer,
        Sidebar = sidebar,
        Content = content,
        Pages = pages,
        TabHolder = tabHolder,
        FloatingTabs = floatingTabs,
        FloatingHolder = floatingHolder,
        TabPosition = options.TabPosition or "Left",
        Tabs = {},
        CurrentTab = nil,
        MinSize = options.MinSize or Vector2.new(420, 340),
        MaxSize = options.MaxSize or Vector2.new(1200, 900),
        CurrentSize = options.Size and Vector2.new(options.Size.X.Offset, options.Size.Y.Offset) or Vector2.new(780, 520),
        UserResized = false,
        Open = true,
        StoredPosition = options.Position or UDim2.fromScale(0.5, 0.5),
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
        SettingsButton = settingsButton,
        SettingsMenu = settingsMenu,
        Topbar = topbar,
        SidebarHeader = sidebarHeader,
        FloatingLayout = floatingLayout,
        _dragging = false,
        _dragStartPos = Vector2.zero,
        _dragStartOffset = Vector2.zero,
        _resizing = false,
        _resizeStartSize = Vector2.zero,
        _resizeStartPos = Vector2.zero,
        _activePopup = nil,
        _activePopupAnchor = nil,
        _popupConnections = {},
    }, Window)

    function window:_configDirectory() return self.ConfigFolder end
    function window:_configFilePath(configName)
        return string.format("%s/%s.json", self:_configDirectory(), configName)
    end
    function window:_autoloadStatePath()
        return string.format("%s/_autoload.json", self:_configDirectory())
    end

    function window:_ensureFolders()
        if not self.Library:_storageAvailable() then return false end
        if not Storage.isfolder(self:_configDirectory()) then
            pcall(Storage.makefolder, self:_configDirectory())
        end
        return true
    end

    function window:_readJson(path)
        if not self.Library:_storageAvailable() or not Storage.isfile(path) then return nil end
        local ok, raw = pcall(Storage.readfile, path)
        if not ok or type(raw) ~= "string" or raw == "" then return nil end
        local decodeOk, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if decodeOk then return data end
        return nil
    end

    function window:_writeJson(path, data)
        if not self:_ensureFolders() then return false end
        local encodeOk, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not encodeOk then return false end
        return pcall(Storage.writefile, path, encoded)
    end

    function window:_registerFlag(flag, controller, defaultValue)
        if not flag then return controller end
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
            if controller and controller.Get then data[flag] = controller:Get() end
        end
        return data
    end

    function window:SaveConfig(configName, silent)
        configName = configName or self.ConfigName
        if not self:_ensureFolders() then
            if not silent then
                self.Library:Notify({Title = "Config Error", Content = "Файловая система недоступна.", Color = self.Library.Theme.Bad})
            end
            return false
        end
        local ok = self:_writeJson(self:_configFilePath(configName), self:_collectFlags())
        if ok and not silent then
            self.Library:Notify({Title = "Config Saved", Content = string.format("Конфиг '%s' сохранён.", configName), Color = self.Library.Theme.Good})
        end
        return ok
    end

    function window:LoadConfig(configName, silent)
        configName = configName or self.ConfigName
        local data = self:_readJson(self:_configFilePath(configName))
        if not data then
            if not silent then
                self.Library:Notify({Title = "Config Error", Content = string.format("Не удалось загрузить конфиг '%s'.", configName), Color = self.Library.Theme.Bad})
            end
            return false
        end
        self.PendingConfig = shallowCopy(data)
        for flag, value in pairs(data) do
            local controller = self.Elements[flag]
            if controller and controller.Set then controller:Set(value, true) end
        end
        if not silent then
            self.Library:Notify({Title = "Config Loaded", Content = string.format("Конфиг '%s' загружен.", configName), Color = self.Library.Theme.Good})
        end
        return true
    end

    function window:EnableAutoLoad(configName, silent)
        configName = configName or self.ConfigName
        if not self:_ensureFolders() then return false end
        local ok = self:_writeJson(self:_autoloadStatePath(), {AutoLoad = configName})
        if ok and not silent then
            self.Library:Notify({Title = "Auto Load Enabled", Content = string.format("Автозагрузка '%s' включена.", configName), Color = self.Library.Theme.Good})
        end
        return ok
    end

    function window:DisableAutoLoad(silent)
        if not self:_ensureFolders() then return false end
        local ok = self:_writeJson(self:_autoloadStatePath(), {AutoLoad = false})
        if ok and not silent then self.Library:Notify({Title = "Auto Load Disabled", Content = "Автозагрузка отключена."}) end
        return ok
    end

    function window:ListConfigs()
        if not self:_ensureFolders() or not Storage.listfiles then return {} end
        local ok, files = pcall(Storage.listfiles, self:_configDirectory())
        if not ok or type(files) ~= "table" then return {} end
        local names = {}
        for _, path in ipairs(files) do
            local configName = string.match(path, "([^/\\]+)%.json$")
            if configName and configName ~= "_autoload" then table.insert(names, configName) end
        end
        table.sort(names)
        return names
    end

    function window:_primeAutoLoad()
        if not self:_ensureFolders() then return end
        local target = options.AutoLoadConfig
        if not target then
            local state = self:_readJson(self:_autoloadStatePath())
            if state and state.AutoLoad and state.AutoLoad ~= false then target = state.AutoLoad end
        end
        if target then self:LoadConfig(target, true) end
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
        self.Root.Position = self.StoredPosition
        self.MobileToggle.Visible = mobile and not self.Open
        hideButton.Visible = not mobile
        settingsButton.Visible = not mobile
        resizeHandle.Visible = not mobile

        if mobile then
            uiScale.Scale = 0.92
            title.TextSize = 22
            subtitle.TextSize = 12
        else
            uiScale.Scale = 1
            title.TextSize = 24
            subtitle.TextSize = 13
        end

        self:_layoutChrome(mobile and "Left" or self.TabPosition)
        self:_syncFloatingTabs()
    end

    function window:_setOpen(openState, instant)
        self.Open = openState
        if openState then
            self.ScreenGui.Enabled = true
            self.MobileToggle.Visible = false
            self:_closePopup(true)
            if instant then
                self.Root.Size = UDim2.fromOffset(self.CurrentSize.X, self.CurrentSize.Y)
                self.Root.BackgroundTransparency = 0
                self.Root.Position = self.StoredPosition
                uiScale.Scale = viewportSize().X < 760 and 0.92 or 1
                self:_syncFloatingTabs()
                return
            end
            self.Root.Position = UDim2.new(self.StoredPosition.X.Scale, self.StoredPosition.X.Offset, self.StoredPosition.Y.Scale, self.StoredPosition.Y.Offset + 18)
            self.Root.Size = UDim2.fromOffset(self.CurrentSize.X - 26, self.CurrentSize.Y - 18)
            self.Root.BackgroundTransparency = 0.04
            uiScale.Scale = viewportSize().X < 760 and 0.9 or 0.975
            tween(self.Root, {Position = self.StoredPosition, Size = UDim2.fromOffset(self.CurrentSize.X, self.CurrentSize.Y), BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Exponential, nil, true)
            tween(uiScale, {Scale = viewportSize().X < 760 and 0.92 or 1}, 0.3, Enum.EasingStyle.Exponential, nil, true)
            tween(self.RootShadow, {BackgroundTransparency = 0.6}, 0.3, nil, nil, true)
        else
            self.MobileToggle.Visible = isTouch() or viewportSize().X < 760
            self:_closePopup(true)
            settingsMenu.Visible = false
            self.FloatingTabs.Visible = self.TabPosition == "Top" or self.TabPosition == "Bottom"
            if instant then
                self.ScreenGui.Enabled = false
                self.FloatingTabs.Visible = false
                return
            end
            tween(self.Root, {Position = UDim2.new(self.Root.Position.X.Scale, self.Root.Position.X.Offset, self.Root.Position.Y.Scale, self.Root.Position.Y.Offset + 16), Size = UDim2.fromOffset(self.CurrentSize.X - 30, self.CurrentSize.Y - 18), BackgroundTransparency = 0.08}, 0.22, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, true)
            tween(uiScale, {Scale = viewportSize().X < 760 and 0.88 or 0.965}, 0.22, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, true)
            tween(self.RootShadow, {BackgroundTransparency = 0}, 0.22, nil, nil, true)
            task.delay(0.22, function()
                if self.Root and not self.Open then
                    self.FloatingTabs.Visible = false
                    self.ScreenGui.Enabled = false
                end
            end)
        end
    end

    function window:Toggle(state)
        if state == nil then state = not self.Open end
        self:_setOpen(state, false)
    end

    function window:Notify(notification) return self.Library:Notify(notification) end
    function window:SetTitle(text, iconImage)
        self.TitleLabel.Text = text or self.TitleLabel.Text
        if iconImage ~= nil then
            self.TitleIcon.Image = normalizeImage(iconImage)
            self.TitleIcon.Visible = iconImage ~= ""
            self.TitleIcon.BackgroundTransparency = iconImage ~= "" and 0 or 1
        end
    end
    function window:SetSubtitle(text) self.SubtitleLabel.Text = text or self.SubtitleLabel.Text end
    function window:SetTabPosition(position) self:_layoutChrome(position) end
    function window:Destroy() self.ScreenGui:Destroy() end

    function window:_disconnectPopupConnections()
        for _, connection in ipairs(self._popupConnections) do
            if connection and connection.Disconnect then connection:Disconnect() end
        end
        table.clear(self._popupConnections)
    end

    function window:_closePopup(skipDestroy)
        self:_disconnectPopupConnections()
        if not self._activePopup then return end
        local popup = self._activePopup
        self._activePopup = nil
        self._activePopupAnchor = nil
        if skipDestroy then
            popup:Destroy()
        else
            tween(popup, {BackgroundTransparency = 1, Size = UDim2.fromOffset(popup.AbsoluteSize.X, math.max(24, popup.AbsoluteSize.Y - 12))}, 0.16, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, true)
            task.delay(0.17, function() if popup and popup.Parent then popup:Destroy() end end)
        end
    end

    function window:_createPopup(width, height, anchorGui, offset)
        self:_closePopup(true)
        local popup = create("Frame", {
            BackgroundColor3 = self.Library.Theme.SurfaceSoft,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(width, math.max(height - 12, 20)),
            ZIndex = 30,
            Parent = self.PopupLayer
        })
        corner(popup, 10)
        stroke(popup, 0.1, 1)
        popup.ClipsDescendants = true

        task.spawn(function()
            RunService.RenderStepped:Wait()
            RunService.RenderStepped:Wait()
            local anchorPos = anchorGui.AbsolutePosition
            local anchorSize = anchorGui.AbsoluteSize
            local screenSize = viewportSize()
            local resolvedOffset = offset or Vector2.new(10, 0)
            local targetX = anchorPos.X + anchorSize.X + resolvedOffset.X
            local targetY = anchorPos.Y + resolvedOffset.Y

            if targetX + width > screenSize.X - 12 then targetX = anchorPos.X - width - 10 end
            targetX = math.clamp(targetX, 12, math.max(12, screenSize.X - width - 12))
            targetY = math.clamp(targetY, 12, math.max(12, screenSize.Y - height - 12))

            popup.Position = UDim2.fromOffset(targetX - 14, targetY)
            tween(popup, {BackgroundTransparency = 0, Position = UDim2.fromOffset(targetX, targetY), Size = UDim2.fromOffset(width, height)}, 0.2, Enum.EasingStyle.Exponential, nil, true)
        end)

        self._activePopup = popup
        self._activePopupAnchor = anchorGui
        table.insert(self._popupConnections, UIS.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local pos = input.Position
            if self._activePopup then
                local insidePopup = pos.X >= self._activePopup.AbsolutePosition.X and pos.X <= self._activePopup.AbsolutePosition.X + self._activePopup.AbsoluteSize.X
                    and pos.Y >= self._activePopup.AbsolutePosition.Y and pos.Y <= self._activePopup.AbsolutePosition.Y + self._activePopup.AbsoluteSize.Y
                local insideAnchor = self._activePopupAnchor and pos.X >= self._activePopupAnchor.AbsolutePosition.X and pos.X <= self._activePopupAnchor.AbsolutePosition.X + self._activePopupAnchor.AbsoluteSize.X
                    and pos.Y >= self._activePopupAnchor.AbsolutePosition.Y and pos.Y <= self._activePopupAnchor.AbsolutePosition.Y + self._activePopupAnchor.AbsoluteSize.Y
                if not insidePopup and not insideAnchor then self:_closePopup() end
            end
        end))

        return popup
    end

    function window:_syncFloatingTabs()
        if not self.FloatingTabs.Visible then return end
        if not self.Root or not self.Root.Parent then return end
        local rootPos = self.Root.AbsolutePosition
        local rootSize = self.Root.AbsoluteSize
        local barWidth = math.max(240, rootSize.X - 120)
        local barX = rootPos.X + math.floor((rootSize.X - barWidth) * 0.5)

        if self.TabPosition == "Top" then
            self.FloatingTabs.Position = UDim2.fromOffset(barX, rootPos.Y - 48)
        else
            self.FloatingTabs.Position = UDim2.fromOffset(barX, rootPos.Y + rootSize.Y + 8)
        end
        self.FloatingTabs.Size = UDim2.fromOffset(barWidth, 40)
    end

    function window:_layoutChrome(mode)
        mode = mode or self.TabPosition or "Left"
        self.TabPosition = mode
        local mobile = viewportSize().X < 760 or isTouch()
        if mobile then mode = "Left" end

        self.FloatingTabs.Visible = false
        self.Sidebar.Visible = mode == "Left" or mode == "Right"
        self.SidebarHeader.Text = (mode == "Left" or mode == "Right") and (mobile and "UI" or (options.SidebarTitle or "Tabs")) or ""

        local top = 84
        if mode == "Left" then
            self.Sidebar.Position = UDim2.fromOffset(18, top)
            self.Sidebar.Size = mobile and UDim2.new(0, 98, 1, -102) or UDim2.new(0, 190, 1, -102)
            self.Content.Position = mobile and UDim2.fromOffset(128, top) or UDim2.fromOffset(220, top)
            self.Content.Size = mobile and UDim2.new(1, -146, 1, -102) or UDim2.new(1, -238, 1, -102)
            tabHolder.Parent = self.Sidebar
            tabHolder.Position = UDim2.fromOffset(0, 24)
            tabHolder.Size = UDim2.new(1, 0, 1, -24)
        elseif mode == "Right" then
            self.Sidebar.Position = UDim2.new(1, mobile and -110 or -202, 0, top)
            self.Sidebar.Size = mobile and UDim2.new(0, 98, 1, -102) or UDim2.new(0, 190, 1, -102)
            self.Content.Position = UDim2.fromOffset(18, top)
            self.Content.Size = mobile and UDim2.new(1, -146, 1, -102) or UDim2.new(1, -238, 1, -102)
            tabHolder.Parent = self.Sidebar
            tabHolder.Position = UDim2.fromOffset(0, 24)
            tabHolder.Size = UDim2.new(1, 0, 1, -24)
        elseif mode == "Bottom" then
            self.Content.Position = UDim2.fromOffset(18, top)
            self.Content.Size = UDim2.new(1, -36, 1, -116)
            self.FloatingTabs.Visible = true
            tabHolder.Parent = self.FloatingHolder
            tabHolder.Position = UDim2.fromOffset(0, 0)
            tabHolder.Size = UDim2.fromScale(1, 1)
        else
            self.Content.Position = UDim2.fromOffset(18, 84)
            self.Content.Size = UDim2.new(1, -36, 1, -116)
            self.FloatingTabs.Visible = true
            tabHolder.Parent = self.FloatingHolder
            tabHolder.Position = UDim2.fromOffset(0, 0)
            tabHolder.Size = UDim2.fromScale(1, 1)
        end

        local layoutObject = tabHolder:FindFirstChildOfClass("UIListLayout")
        if layoutObject then
            local horizontalTabs = mode == "Bottom" or mode == "Top"
            layoutObject.FillDirection = horizontalTabs and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
            layoutObject.HorizontalAlignment = horizontalTabs and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left
        end

        for _, tab in ipairs(self.Tabs) do tab:SetLayout(mode) end
        task.defer(function() if self.Root and self.Root.Parent then self:_syncFloatingTabs() end end)
    end

    function window:CreateTab(tabOptions, maybeIcon)
        if type(tabOptions) ~= "table" then tabOptions = {Name = tabOptions, Icon = maybeIcon} end
        local tabImageSource = tabOptions.Image or (isImageSource(tabOptions.Icon) and tabOptions.Icon or nil)

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
        corner(frame, 9)
        stroke(frame, 0.15, 1)
        create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.96,
            Size = UDim2.new(1, 0, 0, 1),
            Parent = frame
        })

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
        corner(iconWrap, 8)

        local imageLabel = create("ImageLabel", {
            BackgroundTransparency = 1,
            Image = normalizeImage(tabImageSource),
            Position = UDim2.fromOffset(6, 6),
            Size = UDim2.fromOffset(20, 20),
            ScaleType = Enum.ScaleType.Fit,
            Visible = tabImageSource ~= nil,
            Parent = iconWrap
        })

        local glyphLabel = create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Size = UDim2.fromScale(1, 1),
            Text = tabImageSource and "" or (tabOptions.Icon or "•"),
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

        local descriptionLabel = create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Position = UDim2.fromOffset(52, 27),
            Size = UDim2.new(1, -62, 0, 14),
            Text = tabOptions.Description or "",
            TextColor3 = self.Library.Theme.Muted,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = tabOptions.Description and tabOptions.Description ~= "",
            Parent = frame
        })

        local page = create("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(),
            Position = UDim2.fromOffset(16, 16),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = self.Library.Theme.AccentSoft,
            Size = UDim2.new(1, -32, 1, -32),
            Visible = false,
            Parent = pages
        })
        list(page, 12, false)

        local tab = setmetatable({
            Window = self,
            Button = button,
            Frame = frame,
            Label = label,
            Description = descriptionLabel,
            ActiveLine = activeLine,
            IconWrap = iconWrap,
            ImageLabel = imageLabel,
            GlyphLabel = glyphLabel,
            Page = page,
            _active = false
        }, Tab)
        table.insert(self.Tabs, tab)
        tab:SetLayout(self.TabPosition)

        button.MouseButton1Click:Connect(function() self:SelectTab(tab) end)
        button.MouseEnter:Connect(function()
            if not tab._active then tween(frame, {BackgroundColor3 = self.Library.Theme.SurfaceAccent}, 0.18, nil, nil, true) end
        end)
        button.MouseLeave:Connect(function()
            if not tab._active then tween(frame, {BackgroundColor3 = self.Library.Theme.SurfaceRaised}, 0.18, nil, nil, true) end
        end)

        if not self.CurrentTab then self:SelectTab(tab, true) end
        return tab
    end

    function window:SelectTab(targetTab, instant)
        if self.CurrentTab == targetTab then return end
        local prev = self.CurrentTab
        self.CurrentTab = targetTab

        for _, tab in ipairs(self.Tabs) do
            local active = tab == targetTab
            tab._active = active
            local colorActive = self.Library.Theme.SurfaceAccent
            local colorInactive = self.Library.Theme.SurfaceRaised
            local iconColorActive = self.Library.Theme.AccentSoft
            local iconColorInactive = self.Library.Theme.SurfaceAccent

            tween(tab.Frame, {BackgroundColor3 = active and colorActive or colorInactive}, instant and 0 or 0.18, nil, nil, true)
            tween(tab.IconWrap, {BackgroundColor3 = active and iconColorActive or iconColorInactive}, instant and 0 or 0.18, nil, nil, true)
            tween(tab.ActiveLine, {BackgroundTransparency = active and 0 or 1, Size = active and UDim2.fromOffset(26, 2) or UDim2.fromOffset(12, 2)}, instant and 0 or 0.18, nil, nil, true)
            tab.Label.TextColor3 = active and self.Library.Theme.Text or self.Library.Theme.Muted
            tab.GlyphLabel.TextColor3 = active and self.Library.Theme.Surface or self.Library.Theme.Text

            if active then
                tab.Page.Visible = true
                tween(tab.Page, {Position = UDim2.fromOffset(16, 16)}, instant and 0 or 0.24, Enum.EasingStyle.Exponential, nil, true)
            else
                task.delay(instant and 0 or 0.14, function()
                    if tab.Page and self.CurrentTab ~= tab then tab.Page.Visible = false end
                end)
            end
        end
    end

    local tabPositionChoices = {
        {Label = "Left", Value = "Left"},
        {Label = "Right", Value = "Right"},
        {Label = "Bottom", Value = "Bottom"},
        {Label = "Top", Value = "Top"},
    }
    for _, choice in ipairs(tabPositionChoices) do
        local optionButton = create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = self.Theme.SurfaceRaised,
            Size = UDim2.new(1, 0, 0, 32),
            Text = "",
            ZIndex = 16,
            Parent = settingsMenu
        })
        corner(optionButton, 8)
        create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Position = UDim2.fromOffset(10, 0),
            Size = UDim2.new(1, -20, 1, 0),
            Text = choice.Label,
            TextColor3 = self.Theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 17,
            Parent = optionButton
        })
        optionButton.MouseButton1Click:Connect(function()
            settingsMenu.Visible = false
            window:_layoutChrome(choice.Value)
        end)
    end

    -- Clean Drag & Resize System (NO Memory Leaks)
    local function startDrag(input)
        if window._resizing or window._dragging then return end
        window._dragging = true
        window._dragStartPos = input.Position
        window._dragStartOffset = window.StoredPosition.Offset - input.Position
    end

    local function startResize(input)
        if window._dragging or window._resizing then return end
        window._resizing = true
        window._resizeStartPos = input.Position
        window._resizeStartSize = window.CurrentSize
    end

    local function handleMove(input)
        if not window._dragging and not window._resizing then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end

        if window._dragging then
            local delta = input.Position - window._dragStartPos
            local newPos = UDim2.new(window.StoredPosition.X.Scale, window._dragStartOffset.X + input.Position.X, window.StoredPosition.Y.Scale, window._dragStartOffset.Y + input.Position.Y)
            window.StoredPosition = newPos
            window.Root.Position = newPos
            window:_syncFloatingTabs()
        elseif window._resizing then
            local delta = input.Position - window._resizeStartPos
            window.UserResized = true
            window.CurrentSize = Vector2.new(window._resizeStartSize.X + delta.X, window._resizeStartSize.Y + delta.Y)
            window:_applyRootSize()
        end
    end

    local function handleEnd()
        window._dragging = false
        window._resizing = false
    end

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then startDrag(input) end
    end)
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then startResize(input) end
    end)

    UIS.InputChanged:Connect(handleMove)
    UIS.InputEnded:Connect(handleEnd)

    root:GetPropertyChangedSignal("Position"):Connect(function() window:_syncFloatingTabs() end)
    root:GetPropertyChangedSignal("Size"):Connect(function() window:_syncFloatingTabs() end)

    hideButton.MouseButton1Click:Connect(function() window:Toggle(false) end)
    settingsButton.MouseButton1Click:Connect(function()
        window:_closePopup(true)
        settingsMenu.Visible = not settingsMenu.Visible
    end)
    mobileToggle.MouseButton1Click:Connect(function() window:Toggle(true) end)

    UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == window.ToggleKey then window:Toggle(); return end
        if settingsMenu.Visible and self._activePopup ~= settingsMenu then
            local pos = input.Position
            local insideSettings = pos.X >= settingsMenu.AbsolutePosition.X and pos.X <= settingsMenu.AbsolutePosition.X + settingsMenu.AbsoluteSize.X
                and pos.Y >= settingsMenu.AbsolutePosition.Y and pos.Y <= settingsMenu.AbsolutePosition.Y + settingsMenu.AbsoluteSize.Y
            local insideButton = pos.X >= settingsButton.AbsolutePosition.X and pos.X <= settingsButton.AbsolutePosition.X + settingsButton.AbsoluteSize.X
                and pos.Y >= settingsButton.AbsolutePosition.Y and pos.Y <= settingsButton.AbsolutePosition.Y + settingsButton.AbsoluteSize.Y
            if not insideSettings and not insideButton then settingsMenu.Visible = false end
        end
    end)

    window:_primeAutoLoad()
    window:_applyRootSize()
    window:_setOpen(true, false)

    if options.WelcomeNotification ~= false then
        task.delay(0.08, function()
            window:Notify({Title = options.Title or "Null", Content = "UI launched successfully.", Icon = options.Icon, Duration = 3})
        end)
    end

    return window
end

function Tab:SetLayout(mode)
    local horizontal = mode == "Bottom" or mode == "Top"
    self.Button.Size = horizontal and UDim2.fromOffset(170, 40) or UDim2.new(1, 0, 0, 52)
    self.Frame.Size = UDim2.fromScale(1, 1)

    if horizontal then
        self.IconWrap.Position = UDim2.fromOffset(8, 8)
        self.IconWrap.Size = UDim2.fromOffset(24, 24)
        self.ImageLabel.Position = UDim2.fromOffset(4, 4)
        self.ImageLabel.Size = UDim2.fromOffset(16, 16)
        self.GlyphLabel.TextSize = 13
        self.Label.Position = UDim2.fromOffset(40, 0)
        self.Label.Size = UDim2.new(1, -50, 1, 0)
        self.Label.TextSize = 13
        self.Description.Visible = false
        self.ActiveLine.Position = UDim2.new(0.5, 0, 1, -4)
        self.ActiveLine.AnchorPoint = Vector2.new(0.5, 0)
    else
        self.IconWrap.Position = UDim2.fromOffset(10, 10)
        self.IconWrap.Size = UDim2.fromOffset(32, 32)
        self.ImageLabel.Position = UDim2.fromOffset(6, 6)
        self.ImageLabel.Size = UDim2.fromOffset(20, 20)
        self.GlyphLabel.TextSize = 16
        self.Label.Position = UDim2.fromOffset(52, 9)
        self.Label.Size = UDim2.new(1, -62, 0, 18)
        self.Label.TextSize = 14
        self.Description.Visible = self.Description and self.Description.Text ~= ""
        self.ActiveLine.Position = UDim2.fromOffset(10, 25)
        self.ActiveLine.AnchorPoint = Vector2.new(0, 0)
    end
end

function Tab:CreateSection(sectionOptions, maybeDescription)
    if type(sectionOptions) ~= "table" then sectionOptions = {Title = sectionOptions, Description = maybeDescription} end

    local card = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = NullLibrary.Theme.SurfaceSoft,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = self.Page
    })
    corner(card, 10)
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
            Position = UDim2.fromOffset(0, 24),
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
        Position = UDim2.fromOffset(0, (sectionOptions.Description and sectionOptions.Description ~= "") and 56 or 32),
        Size = UDim2.new(1, 0, 0, 0),
        Parent = card
    })
    list(holder, 10, false)

    local windowRef = self.Window
    local section = {Window = windowRef}
    local function register(flag, controller, defaultValue)
        return windowRef:_registerFlag(flag, controller, defaultValue)
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
        corner(paragraph, 9)
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
        if bodyText and bodyText ~= "" then
            autosizeText(create("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Position = UDim2.fromOffset(0, 24),
                Size = UDim2.new(1, 0, 0, 0),
                Text = bodyText,
                TextColor3 = NullLibrary.Theme.Muted,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = paragraph
            }))
        end
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
        corner(frame, 9)
        stroke(frame, 0.15, 1)
        padding(frame, 10, 10)

        local imgHeight = options.Height or 140
        local image = create("ImageLabel", {
            BackgroundColor3 = NullLibrary.Theme.SurfaceAccent,
            Image = normalizeImage(options.Image or options.Url or options.ID),
            Size = UDim2.new(1, 0, 0, imgHeight),
            ScaleType = options.ScaleType or Enum.ScaleType.Crop,
            Parent = frame
        })
        corner(image, options.CornerRadius or 8)

        if options.Caption and options.Caption ~= "" then
            autosizeText(create("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Position = UDim2.fromOffset(0, imgHeight + 10),
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
            Image = normalizeImage(options.Icon),
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
            if options.Callback then task.spawn(options.Callback) end
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
            tween(track, {BackgroundColor3 = state and NullLibrary.Theme.AccentSoft or NullLibrary.Theme.SurfaceAccent}, 0.18, nil, nil, true)
            tween(knob, {Position = state and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.18, nil, nil, true)
            controller.Window.Flags[flag] = state
            if not skipCallback and options.Callback then task.spawn(options.Callback, state) end
        end
        function controller:Get() return state end
        button.MouseButton1Click:Connect(function() controller:Set(not state) end)
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
        local decimals = options.Decimals or 0
        local step = options.Step or 1

        local frame = create("Frame", {
            BackgroundColor3 = NullLibrary.Theme.SurfaceRaised,
            Size = UDim2.new(1, 0, 0, 82),
            Parent = holder
        })
        corner(frame, 9)
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
            Text = string.format("%."..decimals.."f", value),
            TextColor3 = NullLibrary.Theme.AccentSoft,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = frame
        })
        local track = create("Frame", {
            BackgroundColor3 = NullLibrary.Theme.SurfaceAccent,
            Position = UDim2.fromOffset(14, 42),
            Size = UDim2.new(1, -28, 0, 12),
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
            Size = UDim2.fromOffset(20, 20),
            Parent = track
        })
        corner(knob, 999)
        local hitbox = create("TextButton", {
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, -8),
            Size = UDim2.new(1, 0, 1, 16),
            Text = "",
            Parent = track
        })
        local plusButton = create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = NullLibrary.Theme.SurfaceAccent,
            Position = UDim2.new(1, -78, 0, 56),
            Size = UDim2.fromOffset(30, 18),
            Text = "+",
            TextColor3 = NullLibrary.Theme.Text,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            Parent = frame
        })
        corner(plusButton, 6)
        local minusButton = create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = NullLibrary.Theme.SurfaceAccent,
            Position = UDim2.new(1, -114, 0, 56),
            Size = UDim2.fromOffset(30, 18),
            Text = "-",
            TextColor3 = NullLibrary.Theme.Text,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            Parent = frame
        })
        corner(minusButton, 6)

        local dragging = false
        local controller = {Window = self.Window}
        function controller:Set(selfOrValue, maybeValue, maybeSkip)
            local newValue, skipCallback = normalizeSetArgs(selfOrValue, maybeValue, maybeSkip)
            newValue = tonumber(newValue) or minimum
            value = math.clamp(newValue, minimum, maximum)
            value = minimum + (clampRound((value - minimum) / math.max(step, 0.0001)) * step)
            value = math.clamp(value, minimum, maximum)
            local multiplier = 10 ^ decimals
            value = math.floor(value * multiplier + 0.5) / multiplier
            local alpha = (value - minimum) / math.max(maximum - minimum, 1)
            tween(fill, {Size = UDim2.new(alpha, 0, 1, 0)}, 0.12, nil, nil, true)
            tween(knob, {Position = UDim2.new(alpha, 0, 0.5, 0)}, 0.12, nil, nil, true)
            number.Text = string.format("%."..decimals.."f", value)
            controller.Window.Flags[flag] = value
            if not skipCallback and options.Callback then task.spawn(options.Callback, value) end
        end
        function controller:Get() return value end

        local function updateFromPosition(position)
            local alpha = (position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            controller:Set(minimum + ((maximum - minimum) * alpha), true)
        end

        hitbox.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            dragging = true
            updateFromPosition(input.Position)
        end)
        UIS.InputChanged:Connect(function(input)
            if not dragging or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then return end
            updateFromPosition(input.Position)
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                if sliding then controller:Set(value) end
            end
        end)
        plusButton.MouseButton1Click:Connect(function() controller:Set(value + step) end)
        minusButton.MouseButton1Click:Connect(function() controller:Set(value - step) end)

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
        corner(frame, 9)
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
            controller.Window.Flags[flag] = value
            if not skipCallback and options.Callback then task.spawn(options.Callback, value, false) end
        end
        function controller:Get() return value end
        box.FocusLost:Connect(function(enterPressed)
            value = box.Text
            controller.Window.Flags[flag] = value
            if options.Callback then task.spawn(options.Callback, value, enterPressed) end
        end)
        register(flag, controller, value)
        return controller
    end

    function section:AddDropdown(options)
        options = options or {}
        local flag = options.Flag or options.Text
        local values = options.Values or {}
        local selected = options.Default or values[1] or "None"
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
            Text = "▼",
            TextColor3 = NullLibrary.Theme.Muted,
            TextSize = 13,
            Parent = button
        })
        local controller = {Window = self.Window}
        function controller:Set(selfOrValue, maybeValue, maybeSkip)
            local newValue, skipCallback = normalizeSetArgs(selfOrValue, maybeValue, maybeSkip)
            selected = newValue
            label.Text = string.format("%s: %s", options.Text or "Dropdown", tostring(selected))
            controller.Window.Flags[flag] = selected
            if not skipCallback and options.Callback then task.spawn(options.Callback, selected) end
        end
        function controller:Get() return selected end

        local function openPopup()
            local popupHeight = math.min(220, (#values * 36) + 16)
            local popup = self.Window:_createPopup(220, popupHeight, button)
            local scroller = create("ScrollingFrame", {
                Active = true,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                Position = UDim2.fromOffset(8, 8),
                ScrollBarImageColor3 = NullLibrary.Theme.AccentSoft,
                ScrollBarThickness = 6,
                Size = UDim2.new(1, -16, 1, -16),
                ZIndex = 31,
                Parent = popup
            })
            list(scroller, 6, false)
            for _, entry in ipairs(values) do
                local option = create("TextButton", {
                    AutoButtonColor = false,
                    BackgroundColor3 = tostring(entry) == tostring(selected) and NullLibrary.Theme.AccentSoft or NullLibrary.Theme.SurfaceAccent,
                    Size = UDim2.new(1, 0, 0, 34),
                    Text = "",
                    ZIndex = 32,
                    Parent = scroller
                })
                corner(option, 8)
                create("TextLabel", {
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamSemibold,
                    Position = UDim2.fromOffset(12, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    Text = tostring(entry),
                    TextColor3 = tostring(entry) == tostring(selected) and NullLibrary.Theme.Surface or NullLibrary.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 33,
                    Parent = option
                })
                option.MouseButton1Click:Connect(function()
                    controller:Set(entry)
                    self.Window:_closePopup()
                end)
            end
        end
        button.MouseButton1Click:Connect(function()
            if self.Window._activePopup and self.Window._activePopupAnchor == button then
                self.Window:_closePopup()
            else
                self.Window:_closePopup(true)
                arrow.Text = "▲"
                arrow.TextColor3 = NullLibrary.Theme.AccentSoft
                openPopup()
            end
        end)
        popup.Destroying:Connect(function() arrow.Text = "▼"; arrow.TextColor3 = NullLibrary.Theme.Muted end)
        register(flag, controller, selected)
        controller:Set(selected, true)
        return controller
    end
    return section
end

return NullLibrary
