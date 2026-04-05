local NullLibrary = {
    Theme = {
        Background = Color3.fromRGB(15, 15, 20),
        Surface = Color3.fromRGB(15, 15, 20),
        SurfaceSoft = Color3.fromRGB(12, 12, 16),
        SurfaceRaised = Color3.fromRGB(18, 18, 24),
        SurfaceAccent = Color3.fromRGB(24, 24, 32),
        Text = Color3.fromRGB(255, 255, 255),
        Muted = Color3.fromRGB(160, 168, 190),
        Stroke = Color3.fromRGB(60, 65, 85),
        AccentSoft = Color3.fromRGB(140, 160, 255),
        Good = Color3.fromRGB(80, 255, 160),
        Bad = Color3.fromRGB(255, 80, 100),
    },
    Version = "4.2"
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

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
        if key ~= "Parent" then object[key] = value end
    end
    object.Parent = properties.Parent
    return object
end

local function corner(parent, radius)
    create("UICorner", {CornerRadius = UDim.new(0, radius), Parent = parent})
end

local function stroke(parent, transparency, thickness, color)
    return create("UIStroke", {
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        Color = color or NullLibrary.Theme.Stroke,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
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

local function shallowCopy(tbl)
    local clone = {}
    for key, value in pairs(tbl) do clone[key] = value end
    return clone
end

local function cloneTheme(theme)
    local copy = {}
    for key, value in pairs(theme or {}) do copy[key] = value end
    return copy
end

local function clampRound(value)
    return math.floor(value + 0.5)
end

local function normalizeSetArgs(selfOrValue, maybeValue, maybeSkip)
    if type(selfOrValue) == "table" then return maybeValue, maybeSkip end
    return selfOrValue, maybeValue
end

local Storage = {
    writefile = writefile or (request and function(path, data) end),
    readfile = readfile,
    makefolder = makefolder,
    isfolder = isfolder,
    isfile = isfile,
    delfile = delfile,
    listfiles = listfiles,
    getcustomasset = getcustomasset or getsynasset
}

local function getUrlImage(url)
    if not url:match("^http") then return url end
    if not (Storage.writefile and Storage.getcustomasset) then return "" end
    local hash = url:gsub("[^%w]", ""):sub(-20) .. ".png"
    local folderPath = "NullUI_Images"
    local filePath = folderPath .. "/" .. hash
    if not Storage.isfolder(folderPath) then pcall(Storage.makefolder, folderPath) end
    if not Storage.isfile(filePath) then
        local success, response = pcall(function() return game:HttpGet(url) end)
        if success and response then pcall(Storage.writefile, filePath, response) else return "" end
    end
    local assetSuccess, asset = pcall(Storage.getcustomasset, filePath)
    return assetSuccess and asset or ""
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
    local iconName = source:match("^lucide:(.+)$") or source
    if not iconName or iconName == "" then return nil end
    local icons = getLucideIcons()
    if type(icons) ~= "table" then return nil end
    return icons[string.lower(iconName)]
end

local function normalizeImage(source)
    if source == nil then return "" end
    if type(source) == "number" then return "rbxassetid://" .. tostring(source) end
    source = tostring(source)
    if source == "" then return "" end
    if string.match(source, "^%d+$") then return "rbxassetid://" .. source end
    if string.match(source, "^rbxassetid://") or string.match(source, "^rbxthumb://") then return source end
    if source:match("^http") then return getUrlImage(source) end
    local lucideIcon = resolveLucideIcon(source)
    if lucideIcon then return lucideIcon end
    return source
end

local function isImageSource(source)
    if source == nil then return false end
    if type(source) == "number" then return true end
    source = tostring(source)
    if string.match(source, "^%d+$") then return true end
    if string.match(source, "^rbxassetid://") or string.match(source, "^rbxthumb://") or string.match(source, "^https?://") then return true end
    if resolveLucideIcon(source) then return true end
    return false
end

local function configNameFromPath(path)
    if type(path) ~= "string" then return nil end
    local fileName = path:match("[^/\\]+$")
    if not fileName then return nil end
    if not fileName:lower():match("%.json$") then return nil end
    return fileName:gsub("%.json$", "")
end

NullLibrary.ThemePresets = {
    Null = cloneTheme(NullLibrary.Theme),
    Arctic = {
        Background = Color3.fromRGB(17, 24, 38), Surface = Color3.fromRGB(17, 24, 38), SurfaceSoft = Color3.fromRGB(14, 20, 31),
        SurfaceRaised = Color3.fromRGB(24, 34, 52), SurfaceAccent = Color3.fromRGB(33, 46, 69), Text = Color3.fromRGB(236, 244, 255),
        Muted = Color3.fromRGB(159, 179, 205), Stroke = Color3.fromRGB(74, 95, 125), AccentSoft = Color3.fromRGB(116, 191, 255),
        Good = Color3.fromRGB(110, 226, 176), Bad = Color3.fromRGB(255, 105, 128),
    },
    Ember = {
        Background = Color3.fromRGB(30, 17, 14), Surface = Color3.fromRGB(30, 17, 14), SurfaceSoft = Color3.fromRGB(24, 13, 11),
        SurfaceRaised = Color3.fromRGB(43, 24, 19), SurfaceAccent = Color3.fromRGB(58, 33, 26), Text = Color3.fromRGB(255, 237, 230),
        Muted = Color3.fromRGB(203, 164, 151), Stroke = Color3.fromRGB(114, 72, 59), AccentSoft = Color3.fromRGB(255, 136, 92),
        Good = Color3.fromRGB(118, 233, 170), Bad = Color3.fromRGB(255, 92, 116),
    },
    Forest = {
        Background = Color3.fromRGB(16, 25, 19), Surface = Color3.fromRGB(16, 25, 19), SurfaceSoft = Color3.fromRGB(12, 20, 15),
        SurfaceRaised = Color3.fromRGB(24, 36, 28), SurfaceAccent = Color3.fromRGB(32, 50, 38), Text = Color3.fromRGB(230, 244, 234),
        Muted = Color3.fromRGB(157, 182, 165), Stroke = Color3.fromRGB(72, 99, 80), AccentSoft = Color3.fromRGB(124, 222, 153),
        Good = Color3.fromRGB(103, 240, 167), Bad = Color3.fromRGB(255, 101, 125),
    },
    Sunset = {
        Background = Color3.fromRGB(36, 18, 31), Surface = Color3.fromRGB(36, 18, 31), SurfaceSoft = Color3.fromRGB(29, 14, 24),
        SurfaceRaised = Color3.fromRGB(50, 26, 43), SurfaceAccent = Color3.fromRGB(67, 35, 58), Text = Color3.fromRGB(252, 233, 247),
        Muted = Color3.fromRGB(203, 164, 198), Stroke = Color3.fromRGB(118, 78, 112), AccentSoft = Color3.fromRGB(255, 122, 188),
        Good = Color3.fromRGB(116, 232, 188), Bad = Color3.fromRGB(255, 90, 126),
    },
    Midnight = {
        Background = Color3.fromRGB(9, 11, 18), Surface = Color3.fromRGB(9, 11, 18), SurfaceSoft = Color3.fromRGB(7, 9, 15),
        SurfaceRaised = Color3.fromRGB(16, 20, 31), SurfaceAccent = Color3.fromRGB(23, 30, 45), Text = Color3.fromRGB(233, 239, 255),
        Muted = Color3.fromRGB(145, 159, 191), Stroke = Color3.fromRGB(62, 74, 104), AccentSoft = Color3.fromRGB(123, 145, 255),
        Good = Color3.fromRGB(114, 225, 180), Bad = Color3.fromRGB(255, 89, 117),
    },
    Mint = {
        Background = Color3.fromRGB(15, 28, 26), Surface = Color3.fromRGB(15, 28, 26), SurfaceSoft = Color3.fromRGB(11, 22, 20),
        SurfaceRaised = Color3.fromRGB(23, 40, 37), SurfaceAccent = Color3.fromRGB(30, 54, 50), Text = Color3.fromRGB(228, 249, 244),
        Muted = Color3.fromRGB(152, 194, 183), Stroke = Color3.fromRGB(72, 109, 101), AccentSoft = Color3.fromRGB(93, 233, 197),
        Good = Color3.fromRGB(112, 239, 187), Bad = Color3.fromRGB(255, 104, 130),
    },
    Snow = {
        Background = Color3.fromRGB(246, 248, 252), Surface = Color3.fromRGB(246, 248, 252), SurfaceSoft = Color3.fromRGB(240, 243, 249),
        SurfaceRaised = Color3.fromRGB(232, 237, 246), SurfaceAccent = Color3.fromRGB(221, 229, 241), Text = Color3.fromRGB(20, 26, 38),
        Muted = Color3.fromRGB(96, 109, 133), Stroke = Color3.fromRGB(177, 190, 214), AccentSoft = Color3.fromRGB(74, 116, 255),
        Good = Color3.fromRGB(44, 178, 118), Bad = Color3.fromRGB(230, 78, 98),
    },
    Blackout = {
        Background = Color3.fromRGB(2, 2, 2), Surface = Color3.fromRGB(2, 2, 2), SurfaceSoft = Color3.fromRGB(4, 4, 4),
        SurfaceRaised = Color3.fromRGB(8, 8, 8), SurfaceAccent = Color3.fromRGB(14, 14, 14), Text = Color3.fromRGB(246, 246, 246),
        Muted = Color3.fromRGB(154, 154, 154), Stroke = Color3.fromRGB(38, 38, 38), AccentSoft = Color3.fromRGB(255, 255, 255),
        Good = Color3.fromRGB(119, 230, 165), Bad = Color3.fromRGB(255, 100, 120),
    },
    Yoxi = {
        Background = Color3.fromRGB(22, 8, 11), Surface = Color3.fromRGB(22, 8, 11), SurfaceSoft = Color3.fromRGB(18, 6, 9),
        SurfaceRaised = Color3.fromRGB(36, 12, 17), SurfaceAccent = Color3.fromRGB(52, 18, 25), Text = Color3.fromRGB(255, 233, 238),
        Muted = Color3.fromRGB(201, 142, 154), Stroke = Color3.fromRGB(108, 46, 60), AccentSoft = Color3.fromRGB(255, 86, 120),
        Good = Color3.fromRGB(123, 234, 172), Bad = Color3.fromRGB(255, 92, 110),
    },
}

function NullLibrary:RegisterTheme(name, themeData)
    if type(name) ~= "string" or name == "" or type(themeData) ~= "table" then return false end
    self.ThemePresets[name] = cloneTheme(themeData)
    return true
end

function NullLibrary:GetTheme(name)
    local preset = self.ThemePresets[name or "Null"] or self.ThemePresets.Null
    return preset and cloneTheme(preset) or nil
end

function NullLibrary:ListThemes()
    local names = {}
    for name in pairs(self.ThemePresets) do table.insert(names, name) end
    table.sort(names)
    if names[1] ~= "Null" then
        for index, name in ipairs(names) do
            if name == "Null" then
                table.remove(names, index)
                table.insert(names, 1, "Null")
                break
            end
        end
    end
    return names
end

function NullLibrary:_storageAvailable()
    return Storage.readfile and Storage.writefile and Storage.makefolder and Storage.isfolder and Storage.isfile
end

function NullLibrary:_ensureNotificationGui()
    if self._notifyGui and self._notifyGui.Parent then return self._notifyGui, self._notifyHolder end
    local gui = create("ScreenGui", {
        Name = "NullUI_Notifications",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (RunService:IsStudio() and PlayerGui) or CoreGui
    })
    local area = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -16, 0, 16),
        Size = UDim2.new(0, 340, 1, -32),
        Parent = gui
    })
    local holder = create("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = area})
    list(holder, 12, false).HorizontalAlignment = Enum.HorizontalAlignment.Right
    local mobile = viewportSize().X < 760 or isTouch()
    area.AnchorPoint = mobile and Vector2.new(0.5, 0) or Vector2.new(1, 0)
    area.Position = mobile and UDim2.new(0.5, 0, 0, 12) or UDim2.new(1, -16, 0, 16)
    area.Size = mobile and UDim2.new(1, -24, 1, -24) or UDim2.new(0, 340, 1, -32)
    self._notifyGui = gui
    self._notifyHolder = holder
    return gui, holder
end

function NullLibrary:Notify(options)
    options = options or {}
    local _, holder = self:_ensureNotificationGui()
    local mobile = viewportSize().X < 760 or isTouch()

    local shadow = create("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 1,
        Size = UDim2.new(1, 30, 0, 0),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = holder
    })

    local card = create("CanvasGroup", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Theme.SurfaceSoft,
        BackgroundTransparency = 0.2,
        Position = UDim2.fromOffset(50, 0),
        Size = UDim2.new(1, -30, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        GroupTransparency = 1,
        Parent = shadow
    })
    card.Position = UDim2.new(0.5, 50, 0, 0)
    corner(card, 8)
    stroke(card, 0.4, 1, self.Theme.Text)

    local progress = create("Frame", {
        BackgroundColor3 = options.Color or self.Theme.AccentSoft,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 2),
        ZIndex = 10,
        Parent = card
    })

    local body = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(16, 12),
        Size = UDim2.new(1, -40, 0, 0),
        Parent = card
    })
    list(body, 10, false)

    local header = create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Parent = body})
    list(header, 10, true).VerticalAlignment = Enum.VerticalAlignment.Top

    local iconWrap = create("Frame", {
        BackgroundColor3 = self.Theme.SurfaceRaised,
        BackgroundTransparency = (options.Icon or options.Image) and 0.4 or 1,
        Size = UDim2.fromOffset(mobile and 32 or 36, mobile and 32 or 36),
        Visible = options.Icon ~= nil or options.Image ~= nil,
        Parent = header
    })
    corner(iconWrap, 6)

    create("ImageLabel", {
        BackgroundTransparency = 1,
        Image = normalizeImage(options.Icon or options.Image),
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.new(1, -12, 1, -12),
        ScaleType = Enum.ScaleType.Fit,
        Parent = iconWrap
    })

    local textWrap = create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, iconWrap.Visible and -46 or 0, 0, 0), Parent = header})
    list(textWrap, 4, false)

    autosizeText(create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 0),
        Text = options.Title or "Notification",
        TextColor3 = self.Theme.Text,
        TextSize = mobile and 13 or 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = textWrap
    }))

    autosizeText(create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Size = UDim2.new(1, 0, 0, 0),
        Text = options.Content or options.Text or "",
        TextColor3 = self.Theme.Muted,
        TextSize = mobile and 11 or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = textWrap
    }))

    create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 8), Parent = body})

    local close = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -8, 0, 6),
        Size = UDim2.fromOffset(26, 26),
        Text = "x",
        Font = Enum.Font.GothamMedium,
        TextColor3 = self.Theme.Muted,
        TextSize = 14,
        Parent = card
    })

    RunService.RenderStepped:Wait()
    shadow.Size = UDim2.new(1, 30, 0, card.AbsoluteSize.Y + 30)
    card.Position = UDim2.new(0.5, 50, 0.5, 0)
    card.AnchorPoint = Vector2.new(0.5, 0.5)

    tween(card, {GroupTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.4, Enum.EasingStyle.Exponential)
    tween(shadow, {ImageTransparency = 0.5}, 0.4, Enum.EasingStyle.Exponential)
    tween(progress, {Size = UDim2.new(0, 0, 0, 2)}, options.Duration or 4.5, Enum.EasingStyle.Linear)

    local closed = false
    local function dismiss()
        if closed then return end
        closed = true
        tween(card, {GroupTransparency = 1, Position = UDim2.new(0.5, 50, 0.5, 0)}, 0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
        tween(shadow, {ImageTransparency = 1}, 0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
        task.delay(0.35, function() if shadow then shadow:Destroy() end end)
    end

    close.MouseButton1Click:Connect(dismiss)
    task.delay(options.Duration or 4.5, dismiss)

    return {Dismiss = dismiss, Card = card}
end

function NullLibrary:_createCardButton(parent, height)
    local button = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = self.Theme.SurfaceRaised,
        BackgroundTransparency = 0.4,
        Size = UDim2.new(1, 0, 0, height or 42),
        Text = "",
        Parent = parent
    })
    corner(button, 6)
    local s = stroke(button, 0.5, 1)
    button.MouseEnter:Connect(function() tween(button, {BackgroundTransparency = 0.1}, 0.2) end)
    button.MouseLeave:Connect(function() tween(button, {BackgroundTransparency = 0.4}, 0.2) end)
    return button, s
end

function Tab:SetLayout(mode)
    local horizontal = mode == "Bottom" or mode == "Top"
    self.Button.Size = horizontal and UDim2.fromOffset(130, 36) or UDim2.new(1, 0, 0, 48)
    self.Frame.Size = UDim2.fromScale(1, 1)
    self.Frame.BackgroundColor3 = horizontal and self.Window.Library.Theme.SurfaceRaised or self.Window.Library.Theme.Background
    self.IconWrap.BackgroundColor3 = horizontal and self.Window.Library.Theme.SurfaceAccent or self.Window.Library.Theme.Background

    local active = self.Window.CurrentTab == self

    if horizontal then
        self.IconWrap.Position = UDim2.fromOffset(6, 6)
        self.IconWrap.Size = UDim2.fromOffset(24, 24)
        self.ImageLabel.Position = UDim2.fromOffset(4, 4)
        self.ImageLabel.Size = UDim2.fromOffset(16, 16)
        self.GlyphLabel.TextSize = 13
        self.Label.Position = UDim2.fromOffset(36, 0)
        self.Label.Size = UDim2.new(1, -40, 1, 0)
        self.Label.TextSize = 12
        self.Description.Visible = false
        
        self.ActiveLine.Position = UDim2.new(0.5, 0, 1, -2)
        self.ActiveLine.AnchorPoint = Vector2.new(0.5, 0)
        self.ActiveLine.Size = active and UDim2.fromOffset(20, 2) or UDim2.fromOffset(10, 2)
    else
        self.IconWrap.Position = UDim2.fromOffset(8, 8)
        self.IconWrap.Size = UDim2.fromOffset(32, 32)
        self.ImageLabel.Position = UDim2.fromOffset(6, 6)
        self.ImageLabel.Size = UDim2.fromOffset(20, 20)
        self.GlyphLabel.TextSize = 16
        self.Label.Position = UDim2.fromOffset(48, 8)
        self.Label.Size = UDim2.new(1, -56, 0, 18)
        self.Label.TextSize = 13
        self.Description.Visible = self.Description.Text ~= ""
        
        self.ActiveLine.Position = UDim2.new(0, 0, 0.5, 0)
        self.ActiveLine.AnchorPoint = Vector2.new(0, 0.5)
        self.ActiveLine.Size = active and UDim2.fromOffset(2, 20) or UDim2.fromOffset(2, 10)
    end
end

function Tab:CreateSection(sectionOptions, maybeDescription)
    if type(sectionOptions) ~= "table" then sectionOptions = {Title = sectionOptions, Description = maybeDescription} end
    local side = sectionOptions.Side or "Left"
    local parentColumn = side == "Right" and self.RightColumn or self.LeftColumn

    local card = create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = NullLibrary.Theme.SurfaceSoft, BackgroundTransparency = 0.5, Size = UDim2.new(1, 0, 0, 0), Parent = parentColumn})
    corner(card, 6) local cardStroke = stroke(card, 0.6, 1) padding(card, 16, 16)

    local sectionTitleLabel = autosizeText(create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Size = UDim2.new(1, 0, 0, 0), Text = sectionOptions.Title or "Section", TextColor3 = NullLibrary.Theme.Text, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Parent = card}))
    local sectionDescriptionLabel = nil
    if sectionOptions.Description and sectionOptions.Description ~= "" then
        sectionDescriptionLabel = autosizeText(create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 0, 0), Text = sectionOptions.Description, TextColor3 = NullLibrary.Theme.Muted, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = card}))
    end

    local holder = create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, sectionOptions.Description and sectionOptions.Description ~= "" and 54 or 30), Size = UDim2.new(1, 0, 0, 0), Parent = card})
    list(holder, 8, false)
    local windowRef = self.Window
    local section = {Window = windowRef}

    local function register(flag, controller, defaultValue) return windowRef:_registerFlag(flag, controller, defaultValue) end
    local function bindTheme(fn) return windowRef:_bindTheme(fn) end

    bindTheme(function(theme)
        card.BackgroundColor3 = theme.SurfaceSoft
        cardStroke.Color = theme.Stroke
        sectionTitleLabel.TextColor3 = theme.Text
        if sectionDescriptionLabel then sectionDescriptionLabel.TextColor3 = theme.Muted end
    end)

    function section:AddLabel(text)
        local label = autosizeText(create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Size = UDim2.new(1, 0, 0, 0), Text = text or "Label", TextColor3 = NullLibrary.Theme.Muted, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = holder}))
        bindTheme(function(theme) label.TextColor3 = theme.Muted end)
        return label
    end

    function section:AddParagraph(titleText, bodyText)
        local paragraph = create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = NullLibrary.Theme.SurfaceRaised, BackgroundTransparency = 0.5, Size = UDim2.new(1, 0, 0, 0), Parent = holder})
        corner(paragraph, 6) padding(paragraph, 12, 10)
        local paragraphTitle = autosizeText(create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Size = UDim2.new(1, 0, 0, 0), Text = titleText or "Info", TextColor3 = NullLibrary.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = paragraph}))
        local paragraphBody = autosizeText(create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Position = UDim2.fromOffset(0, 20), Size = UDim2.new(1, 0, 0, 0), Text = bodyText or "", TextColor3 = NullLibrary.Theme.Muted, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = paragraph}))
        bindTheme(function(theme)
            paragraph.BackgroundColor3 = theme.SurfaceRaised
            paragraphTitle.TextColor3 = theme.Text
            paragraphBody.TextColor3 = theme.Muted
        end)
        return paragraph
    end

    function section:AddImage(options)
        options = options or {}
        local frame = create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = NullLibrary.Theme.SurfaceRaised, BackgroundTransparency = 0.5, Size = UDim2.new(1, 0, 0, 0), Parent = holder})
        corner(frame, 6) local frameStroke = stroke(frame, 0.6, 1) padding(frame, 8, 8)
        
        local imgSource = normalizeImage(options.Image or options.Url or options.ID)
        local baseScale = options.ScaleType or Enum.ScaleType.Crop
        local image = create("ImageLabel", {BackgroundColor3 = NullLibrary.Theme.SurfaceAccent, BackgroundTransparency = 0.5, Image = imgSource, Size = UDim2.new(1, 0, 0, options.Height or 140), ScaleType = baseScale, Parent = frame})
        corner(image, options.CornerRadius or 6)

        image:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            if image.AbsoluteSize.X < 360 then image.ScaleType = Enum.ScaleType.Fit else image.ScaleType = baseScale end
        end)
        task.spawn(function()
            RunService.RenderStepped:Wait()
            if image.AbsoluteSize.X < 360 then image.ScaleType = Enum.ScaleType.Fit end
        end)

        if imgSource == "" and type(options.Image or options.Url) == "string" and (options.Image or options.Url):match("^http") then
            task.spawn(function()
                local loadedAsset = getUrlImage(options.Image or options.Url)
                if loadedAsset ~= "" then image.Image = loadedAsset end
            end)
        end

        local captionLabel = nil
        if options.Caption and options.Caption ~= "" then captionLabel = autosizeText(create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Position = UDim2.fromOffset(0, (options.Height or 140) + 10), Size = UDim2.new(1, 0, 0, 0), Text = options.Caption, TextColor3 = NullLibrary.Theme.Muted, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center, Parent = frame})) end
        bindTheme(function(theme)
            frame.BackgroundColor3 = theme.SurfaceRaised
            frameStroke.Color = theme.Stroke
            image.BackgroundColor3 = theme.SurfaceAccent
            if captionLabel then captionLabel.TextColor3 = theme.Muted end
        end)
        return image
    end

    function section:AddButton(options)
        options = options or {}
        local buttonWrap = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, options.Height or 38), Parent = holder})
        local button, outline = NullLibrary:_createCardButton(buttonWrap, options.Height or 38)
        local showIcon = options.Icon ~= nil

        local iconLabel = create("ImageLabel", {BackgroundTransparency = 1, Image = normalizeImage(options.Icon), Position = UDim2.fromOffset(12, 9), Size = UDim2.fromOffset(20, 20), ScaleType = Enum.ScaleType.Fit, Visible = showIcon, Parent = button})
        local textLabel = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.fromOffset(showIcon and 40 or 14, 0), Size = UDim2.new(1, showIcon and -52 or -28, 1, 0), Text = options.Text or "Button", TextColor3 = NullLibrary.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Center, Parent = button})
        bindTheme(function(theme)
            button.BackgroundColor3 = theme.SurfaceRaised
            outline.Color = theme.Stroke
            textLabel.TextColor3 = theme.Text
            iconLabel.ImageColor3 = theme.Text
        end)

        button.InputBegan:Connect(function(i) 
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
                tween(button, {BackgroundColor3 = NullLibrary.Theme.AccentSoft, BackgroundTransparency = 0.6}, 0.1)
                tween(outline, {Color = NullLibrary.Theme.AccentSoft, Transparency = 0}, 0.1)
            end 
        end)
        button.InputEnded:Connect(function(i) 
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
                tween(button, {BackgroundColor3 = NullLibrary.Theme.SurfaceRaised, BackgroundTransparency = 0.4}, 0.25)
                tween(outline, {Color = NullLibrary.Theme.Stroke, Transparency = 0.5}, 0.25)
            end 
        end)
        button.MouseButton1Click:Connect(function() if options.Callback then task.spawn(options.Callback) end end)
        return button
    end

    function section:AddToggle(options)
        options = options or {}
        local flag = options.Flag or options.Text
        local state = options.Default or false

        local button = NullLibrary:_createCardButton(holder, 44)
        local titleLabel = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.fromOffset(14, 6), Size = UDim2.new(1, -78, 0, 16), Text = options.Text or "Toggle", TextColor3 = NullLibrary.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = button})
        local descLabel = nil
        if options.Description and options.Description ~= "" then descLabel = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Position = UDim2.fromOffset(14, 22), Size = UDim2.new(1, -78, 0, 14), Text = options.Description, TextColor3 = NullLibrary.Theme.Muted, TextSize = 11, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left, Parent = button}) end

        local track = create("Frame", {AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = state and NullLibrary.Theme.AccentSoft or NullLibrary.Theme.SurfaceAccent, BackgroundTransparency = 0.2, Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(42, 22), Parent = button})
        corner(track, 999)
        local knob = create("Frame", {AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = NullLibrary.Theme.Text, Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(18, 18), Parent = track})
        corner(knob, 999)

        local controller = {Window = self.Window}
        function controller:Set(s, v, sk)
            local newVal, skip = normalizeSetArgs(s, v, sk)
            state = not not newVal
            tween(track, {BackgroundColor3 = state and NullLibrary.Theme.AccentSoft or NullLibrary.Theme.SurfaceAccent}, 0.2)
            tween(knob, {Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.2)
            controller.Window.Flags[flag] = state
            if not skip and options.Callback then task.spawn(options.Callback, state) end
        end
        function controller:Get() return state end
        bindTheme(function(theme)
            button.BackgroundColor3 = theme.SurfaceRaised
            titleLabel.TextColor3 = theme.Text
            if descLabel then descLabel.TextColor3 = theme.Muted end
            track.BackgroundColor3 = state and theme.AccentSoft or theme.SurfaceAccent
            knob.BackgroundColor3 = theme.Text
        end)

        button.MouseButton1Click:Connect(function() controller:Set(not state) end)
        register(flag, controller, state) controller:Set(state, true)
        return controller
    end

    function section:AddSlider(options)
        options = options or {}
        local flag = options.Flag or options.Text
        local min, max, val, dec, step = options.Min or 0, options.Max or 100, options.Default or options.Min or 0, options.Decimals or 0, options.Step or 1
        val = math.clamp(val, min, max)

        local frame = create("Frame", {BackgroundColor3 = NullLibrary.Theme.SurfaceRaised, BackgroundTransparency = 0.5, Size = UDim2.new(1, 0, 0, 72), Parent = holder})
        corner(frame, 6) local frameStroke = stroke(frame, 0.6, 1)

        local sliderLabel = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.fromOffset(14, 10), Size = UDim2.new(1, -88, 0, 16), Text = options.Text or "Slider", TextColor3 = NullLibrary.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame})
        local number = create("TextLabel", {AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Position = UDim2.new(1, -14, 0, 10), Size = UDim2.fromOffset(64, 16), Text = tostring(val), TextColor3 = NullLibrary.Theme.AccentSoft, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Parent = frame})

        local track = create("Frame", {BackgroundColor3 = NullLibrary.Theme.SurfaceAccent, BackgroundTransparency = 0.3, Position = UDim2.fromOffset(14, 38), Size = UDim2.new(1, -28, 0, 8), Parent = frame})
        corner(track, 999)
        local fill = create("Frame", {BackgroundColor3 = NullLibrary.Theme.AccentSoft, Size = UDim2.new(0, 0, 1, 0), Parent = track})
        corner(fill, 999)
        local knob = create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = NullLibrary.Theme.Text, Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(16, 16), Parent = track})
        corner(knob, 999)

        local hitbox = create("TextButton", {AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, -8), Size = UDim2.new(1, 0, 1, 16), Text = "", Parent = track})
        local controller = {Window = self.Window}

        function controller:Set(s, v, sk)
            local newVal, skip = normalizeSetArgs(s, v, sk)
            newVal = tonumber(newVal) or min
            val = math.clamp(newVal, min, max)
            val = min + (clampRound((val - min) / math.max(step, 0.0001)) * step)
            val = math.floor(val * (10 ^ dec) + 0.5) / (10 ^ dec)
            local alpha = (val - min) / math.max(max - min, 1)
            tween(fill, {Size = UDim2.new(alpha, 0, 1, 0)}, 0.15)
            tween(knob, {Position = UDim2.new(alpha, 0, 0.5, 0)}, 0.15)
            number.Text = string.format("%." .. tostring(dec) .. "f", val)
            controller.Window.Flags[flag] = val
            if not skip and options.Callback then task.spawn(options.Callback, val) end
        end
        function controller:Get() return val end
        bindTheme(function(theme)
            frame.BackgroundColor3 = theme.SurfaceRaised
            frameStroke.Color = theme.Stroke
            sliderLabel.TextColor3 = theme.Text
            number.TextColor3 = theme.AccentSoft
            track.BackgroundColor3 = theme.SurfaceAccent
            fill.BackgroundColor3 = theme.AccentSoft
            knob.BackgroundColor3 = theme.Text
        end)

        local function update(pos) controller:Set(min + ((max - min) * ((pos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X))) end

        hitbox.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                update(i.Position) tween(knob, {Size = UDim2.fromOffset(20, 20)}, 0.1)
                local mConn, eConn
                mConn = UIS.InputChanged:Connect(function(i2) if i2.UserInputType == Enum.UserInputType.MouseMovement or i2.UserInputType == Enum.UserInputType.Touch then update(i2.Position) end end)
                eConn = UIS.InputEnded:Connect(function(i2)
                    if i2.UserInputType == Enum.UserInputType.MouseButton1 or i2.UserInputType == Enum.UserInputType.Touch then
                        tween(knob, {Size = UDim2.fromOffset(16, 16)}, 0.1)
                        if mConn then mConn:Disconnect() end if eConn then eConn:Disconnect() end
                    end
                end)
            end
        end)
        register(flag, controller, val) controller:Set(val, true)
        return controller
    end

    function section:AddTextbox(options)
        options = options or {}
        local flag = options.Flag or options.Text or options.Placeholder
        local val = options.Default or ""
        local frame = create("Frame", {BackgroundColor3 = NullLibrary.Theme.SurfaceRaised, BackgroundTransparency = 0.5, Size = UDim2.new(1, 0, 0, 42), Parent = holder})
        corner(frame, 6) local boxStroke = stroke(frame, 0.6, 1)

        local box = create("TextBox", {BackgroundTransparency = 1, ClearTextOnFocus = false, Font = Enum.Font.GothamSemibold, PlaceholderColor3 = NullLibrary.Theme.Muted, PlaceholderText = options.Placeholder or "Type here...", Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -28, 1, 0), Text = val, TextColor3 = NullLibrary.Theme.Text, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame})
        local controller = {Window = self.Window}

        function controller:Set(s, v, sk)
            local newVal, skip = normalizeSetArgs(s, v, sk)
            val = tostring(newVal or "") box.Text = val controller.Window.Flags[flag] = val
            if not skip and options.Callback then task.spawn(options.Callback, val, false) end
        end
        function controller:Get() return val end
        bindTheme(function(theme)
            frame.BackgroundColor3 = theme.SurfaceRaised
            box.TextColor3 = theme.Text
            box.PlaceholderColor3 = theme.Muted
            if not box:IsFocused() then boxStroke.Color = theme.Stroke end
        end)

        box.Focused:Connect(function() tween(boxStroke, {Color = NullLibrary.Theme.AccentSoft, Transparency = 0.2}, 0.2) end)
        box.FocusLost:Connect(function(e) tween(boxStroke, {Color = NullLibrary.Theme.Stroke, Transparency = 0.6}, 0.2) val = box.Text controller.Window.Flags[flag] = val if options.Callback then task.spawn(options.Callback, val, e) end end)
        register(flag, controller, val) return controller
    end

    function section:AddDropdown(options)
        options = options or {}
        local flag = options.Flag or options.Text
        local vals, sel = options.Values or {}, options.Default or (options.Values and options.Values[1]) or "None"
        local wrap = create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Parent = holder})
        local button = NullLibrary:_createCardButton(wrap, 42)

        local label = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -44, 1, 0), Text = string.format("%s: %s", options.Text or "Dropdown", tostring(sel)), TextColor3 = NullLibrary.Theme.Text, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left, Parent = button})
        local arrow = create("TextLabel", {AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(18, 18), Text = ">", TextColor3 = NullLibrary.Theme.Muted, TextSize = 13, Parent = button})

        local controller = {Window = self.Window}
        function controller:Set(s, v, sk)
            local newVal, skip = normalizeSetArgs(s, v, sk)
            sel = newVal label.Text = string.format("%s: %s", options.Text or "Dropdown", tostring(sel)) controller.Window.Flags[flag] = sel
            if not skip and options.Callback then task.spawn(options.Callback, sel) end
        end
        function controller:Get() return sel end
        function controller:SetValues(newValues, keepSelection)
            vals = type(newValues) == "table" and newValues or {}
            if #vals == 0 then vals = {"None"} end
            local shouldKeep = false
            if keepSelection then
                for _, value in ipairs(vals) do
                    if tostring(value) == tostring(sel) then
                        shouldKeep = true
                        break
                    end
                end
            end
            if shouldKeep then
                label.Text = string.format("%s: %s", options.Text or "Dropdown", tostring(sel))
                controller.Window.Flags[flag] = sel
            else
                controller:Set(vals[1], true, true)
            end
        end
        bindTheme(function(theme)
            button.BackgroundColor3 = theme.SurfaceRaised
            label.TextColor3 = theme.Text
            arrow.TextColor3 = theme.Muted
        end)

        local function openPopup()
            arrow.Text = "v"
            local pHeight = math.min(200, (#vals * 34) + 16)
            local popup = self.Window:_createPopup(200, pHeight, button)
            local dConn
            dConn = popup.AncestryChanged:Connect(function()
                if not popup:IsDescendantOf(game) then
                    arrow.Text = ">"
                    dConn:Disconnect()
                end
            end)
            local scroller = create("ScrollingFrame", {Active = true, AutomaticCanvasSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(), Position = UDim2.fromOffset(8, 8), ScrollBarImageColor3 = NullLibrary.Theme.AccentSoft, ScrollBarThickness = 4, Size = UDim2.new(1, -16, 1, -16), ZIndex = 51, Parent = popup})
            list(scroller, 4, false)

            for _, entry in ipairs(vals) do
                local opt = create("TextButton", {AutoButtonColor = false, BackgroundColor3 = tostring(entry) == tostring(sel) and NullLibrary.Theme.AccentSoft or NullLibrary.Theme.SurfaceAccent, BackgroundTransparency = tostring(entry) == tostring(sel) and 0.2 or 0.5, Size = UDim2.new(1, 0, 0, 32), Text = "", ZIndex = 52, Parent = scroller})
                corner(opt, 6)
                create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0), Text = tostring(entry), TextColor3 = tostring(entry) == tostring(sel) and NullLibrary.Theme.Surface or NullLibrary.Theme.Text, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 53, Parent = opt})
                opt.MouseButton1Click:Connect(function() controller:Set(entry) self.Window:_closePopup() end)
            end
        end

        button.MouseButton1Click:Connect(function() if self.Window._activePopup and self.Window._activePopupAnchor == button then self.Window:_closePopup() else self.Window:_closePopup(true) openPopup() end end)
        register(flag, controller, sel)
        controller:SetValues(vals, true)
        return controller
    end

    function section:AddColorPicker(options)
        options = options or {}
        local flag = options.Flag or options.Text or "Color"
        local color = typeof(options.Default) == "Color3" and options.Default or (typeof(options.DefaultColor) == "Color3" and options.DefaultColor or Color3.fromRGB(255, 0, 0))
        local alpha = math.clamp(tonumber(options.DefaultAlpha) or 1, 0, 1)
        local hue, sat, val = Color3.toHSV(color)

        local function encode(c, a)
            return {R = c.R, G = c.G, B = c.B, A = a}
        end

        local button = NullLibrary:_createCardButton(holder, 42)
        local pickerLabel = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -68, 1, 0), Text = options.Text or "Color", TextColor3 = NullLibrary.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = button})

        local previewWrap = create("Frame", {AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = NullLibrary.Theme.SurfaceAccent, BackgroundTransparency = 0.2, Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(36, 20), Parent = button})
        corner(previewWrap, 6) local previewStroke = stroke(previewWrap, 0.4, 1)
        local previewBg = create("Frame", {BackgroundColor3 = Color3.fromRGB(230, 230, 230), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = previewWrap})
        corner(previewBg, 6)
        create("UIGradient", {Rotation = 0, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 200, 200)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(235, 235, 235)), ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))}), Parent = previewBg})
        local previewFill = create("Frame", {BackgroundColor3 = color, BackgroundTransparency = 1 - alpha, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = previewWrap})
        corner(previewFill, 6)

        local function updatePreview()
            previewFill.BackgroundColor3 = color
            previewFill.BackgroundTransparency = 1 - alpha
        end

        bindTheme(function(theme)
            button.BackgroundColor3 = theme.SurfaceRaised
            pickerLabel.TextColor3 = theme.Text
            previewWrap.BackgroundColor3 = theme.SurfaceAccent
            previewStroke.Color = theme.Stroke
        end)

        local controller = {Window = self.Window}
        function controller:Set(s, v, sk)
            local newValue, skip = normalizeSetArgs(s, v, sk)
            if typeof(newValue) == "Color3" then
                color = newValue
                if type(v) == "number" then alpha = math.clamp(v, 0, 1) end
            elseif type(newValue) == "table" then
                local r, g, b, a = tonumber(newValue.R), tonumber(newValue.G), tonumber(newValue.B), tonumber(newValue.A)
                if r and g and b then color = Color3.new(math.clamp(r, 0, 1), math.clamp(g, 0, 1), math.clamp(b, 0, 1)) end
                if a then alpha = math.clamp(a, 0, 1) end
            end
            hue, sat, val = Color3.toHSV(color)
            updatePreview()
            controller.Window.Flags[flag] = encode(color, alpha)
            if not skip and options.Callback then task.spawn(options.Callback, color, alpha) end
        end
        function controller:Get() return encode(color, alpha) end
        function controller:GetColor() return color, alpha end

        local function openPopup()
            local popup = self.Window:_createPopup(318, 262, button, Vector2.new(12, -110))
            local content = create("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 10), Size = UDim2.new(1, -20, 1, -20), Parent = popup})
            create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 18), Text = options.PopupTitle or "Color Picker", TextColor3 = NullLibrary.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = content})

            local sv = create("Frame", {BackgroundColor3 = Color3.fromHSV(hue, 1, 1), BorderSizePixel = 0, Position = UDim2.fromOffset(0, 24), Size = UDim2.fromOffset(190, 190), Parent = content})
            corner(sv, 8) stroke(sv, 0.5, 1)
            local svWhite = create("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = sv})
            corner(svWhite, 8)
            create("UIGradient", {Rotation = 0, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}), Parent = svWhite})
            local svBlack = create("Frame", {BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = sv})
            corner(svBlack, 8)
            create("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}), Parent = svBlack})
            local svDot = create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Size = UDim2.fromOffset(12, 12), Parent = sv})
            stroke(svDot, 0, 2, Color3.new(1, 1, 1))

            local hueBar = create("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Position = UDim2.fromOffset(202, 24), Size = UDim2.fromOffset(20, 190), Parent = content})
            corner(hueBar, 8) stroke(hueBar, 0.5, 1)
            create("UIGradient", {
                Rotation = 90,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
                }),
                Parent = hueBar
            })
            local hueDot = create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Size = UDim2.fromOffset(28, 4), Parent = hueBar})
            corner(hueDot, 999)

            local alphaBar = create("Frame", {BackgroundColor3 = color, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 226), Size = UDim2.fromOffset(222, 16), Parent = content})
            corner(alphaBar, 6) stroke(alphaBar, 0.5, 1)
            local alphaBack = create("Frame", {BackgroundColor3 = Color3.fromRGB(230, 230, 230), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = alphaBar})
            corner(alphaBack, 6)
            create("UIGradient", {Rotation = 0, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 200, 200)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(235, 235, 235)), ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))}), Parent = alphaBack})
            local alphaColor = create("Frame", {BackgroundColor3 = color, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = alphaBar})
            corner(alphaColor, 6)
            create("UIGradient", {Rotation = 0, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}), Parent = alphaColor})
            local alphaDot = create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Size = UDim2.fromOffset(8, 20), Parent = alphaBar})
            corner(alphaDot, 999)

            local bigPreview = create("Frame", {BackgroundColor3 = NullLibrary.Theme.SurfaceAccent, BackgroundTransparency = 0.2, Position = UDim2.fromOffset(234, 24), Size = UDim2.fromOffset(64, 64), Parent = content})
            corner(bigPreview, 8) stroke(bigPreview, 0.5, 1)
            local bigBg = create("Frame", {BackgroundColor3 = Color3.fromRGB(230, 230, 230), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = bigPreview})
            corner(bigBg, 8)
            local bigFill = create("Frame", {BackgroundColor3 = color, BackgroundTransparency = 1 - alpha, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = bigPreview})
            corner(bigFill, 8)

            local info = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.fromOffset(234, 94), Size = UDim2.fromOffset(64, 72), Text = "", TextColor3 = NullLibrary.Theme.Text, TextSize = 11, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Parent = content})

            local draggingSV, draggingHue, draggingAlpha = false, false, false
            local function sync(skipCallback)
                color = Color3.fromHSV(hue, sat, val)
                local r, g, b = math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5)
                sv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                alphaBar.BackgroundColor3 = color
                alphaColor.BackgroundColor3 = color
                bigFill.BackgroundColor3 = color
                bigFill.BackgroundTransparency = 1 - alpha
                updatePreview()

                info.Text = string.format("RGB\n%d %d %d\n#%02X%02X%02X\nA %d%%", r, g, b, r, g, b, math.floor(alpha * 100 + 0.5))
                svDot.Position = UDim2.new(sat, 0, 1 - val, 0)
                hueDot.Position = UDim2.new(0.5, 0, 1 - hue, 0)
                alphaDot.Position = UDim2.new(alpha, 0, 0.5, 0)
                controller.Window.Flags[flag] = encode(color, alpha)
                if not skipCallback and options.Callback then task.spawn(options.Callback, color, alpha) end
            end

            local function setSVFromPos(position)
                local p, s = sv.AbsolutePosition, sv.AbsoluteSize
                sat = math.clamp((position.X - p.X) / math.max(s.X, 1), 0, 1)
                val = 1 - math.clamp((position.Y - p.Y) / math.max(s.Y, 1), 0, 1)
                sync()
            end
            local function setHueFromPos(position)
                local p, s = hueBar.AbsolutePosition, hueBar.AbsoluteSize
                hue = 1 - math.clamp((position.Y - p.Y) / math.max(s.Y, 1), 0, 1)
                sync()
            end
            local function setAlphaFromPos(position)
                local p, s = alphaBar.AbsolutePosition, alphaBar.AbsoluteSize
                alpha = math.clamp((position.X - p.X) / math.max(s.X, 1), 0, 1)
                sync()
            end

            sv.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSV = true setSVFromPos(input.Position) end end)
            hueBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingHue = true setHueFromPos(input.Position) end end)
            alphaBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingAlpha = true setAlphaFromPos(input.Position) end end)

            table.insert(self.Window._popupConnections, UIS.InputChanged:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
                if draggingSV then setSVFromPos(input.Position) end
                if draggingHue then setHueFromPos(input.Position) end
                if draggingAlpha then setAlphaFromPos(input.Position) end
            end))
            table.insert(self.Window._popupConnections, UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSV, draggingHue, draggingAlpha = false, false, false
                end
            end))

            sync(true)
        end

        button.MouseButton1Click:Connect(function()
            if self.Window._activePopup and self.Window._activePopupAnchor == button then self.Window:_closePopup() else self.Window:_closePopup(true) openPopup() end
        end)

        register(flag, controller, encode(color, alpha))
        controller:Set(encode(color, alpha), true, true)
        return controller
    end

    return section
end

function NullLibrary:CreateWindow(options)
    options = options or {}
    local name = options.Name or "NullUI"
    local container = RunService:IsStudio() and PlayerGui or CoreGui
    local existing = container:FindFirstChild(name)
    if existing then existing:Destroy() end
    local existingWatermark = container:FindFirstChild(name .. "_Watermark")
    if existingWatermark then existingWatermark:Destroy() end

    local screenGui = create("ScreenGui", {
        Name = name,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = container
    })
    local watermarkGui = create("ScreenGui", {
        Name = name .. "_Watermark",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = (screenGui.DisplayOrder or 0) + 1,
        Parent = container
    })

    local popupLayer = create("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 50, Parent = screenGui})

    local root = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 0.2,
        Position = options.Position or UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(780, 520),
        Parent = screenGui
    })
    corner(root, 8)
    stroke(root, 0.3, 1, self.Theme.Text)

    create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.3,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 60, 1, 60),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 0,
        Parent = root
    })

    local uiScale = create("UIScale", {Scale = 1, Parent = root})
    local clip = create("Frame", {BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.fromScale(1, 1), Parent = root})
    corner(clip, 8)

    local topbar = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 76), Parent = clip})
    padding(topbar, 18, 16)

    local leftHeader = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, -140, 1, 0), Parent = topbar})
    list(leftHeader, 12, true).VerticalAlignment = Enum.VerticalAlignment.Center

    local titleIcon = create("ImageLabel", {
        BackgroundColor3 = self.Theme.SurfaceRaised,
        BackgroundTransparency = options.Icon and 0.5 or 1,
        Image = normalizeImage(options.Icon),
        Size = UDim2.fromOffset(40, 40),
        ScaleType = Enum.ScaleType.Fit,
        Visible = options.Icon ~= nil,
        Parent = leftHeader
    })
    corner(titleIcon, 6)

    local titleWrap = create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, titleIcon.Visible and -56 or 0, 0, 0), Parent = leftHeader})
    list(titleWrap, 2, false)

    local title = autosizeText(create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, Size = UDim2.new(1, 0, 0, 0), Text = options.Title or "Null", TextColor3 = self.Theme.Text, TextSize = 22, TextXAlignment = Enum.TextXAlignment.Left, Parent = titleWrap}))
    local subtitle = autosizeText(create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Size = UDim2.new(1, 0, 0, 0), Text = options.Subtitle or "glassmorphism ui", TextColor3 = self.Theme.Muted, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = titleWrap}))

    local controls = create("Frame", {AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Position = UDim2.new(1, -18, 0, 16), Size = UDim2.fromOffset(152, 40), Parent = clip})
    local controlsLayout = list(controls, 8, true)
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local badge = create("Frame", {BackgroundColor3 = self.Theme.SurfaceRaised, BackgroundTransparency = 0.5, Size = UDim2.fromOffset(68, 32), Parent = controls})
    corner(badge, 6) stroke(badge, 0.6, 1)
    local badgeLabel = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Size = UDim2.fromScale(1, 1), Text = options.BadgeText or "NULL", TextColor3 = self.Theme.Text, TextSize = 11, Parent = badge})

    local settingsButton = create("TextButton", {AutoButtonColor = false, BackgroundColor3 = self.Theme.SurfaceRaised, BackgroundTransparency=0.5, Size = UDim2.fromOffset(32, 32), Text = "", Parent = controls})
    corner(settingsButton, 6) stroke(settingsButton, 0.6, 1)
    local settingsIcon = create("ImageLabel", {BackgroundTransparency = 1, Image = normalizeImage("lucide:settings-2"), ImageColor3 = self.Theme.Muted, Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(16, 16), ScaleType = Enum.ScaleType.Fit, Parent = settingsButton})

    local hideButton = create("TextButton", {AutoButtonColor = false, BackgroundColor3 = self.Theme.SurfaceRaised, BackgroundTransparency=0.5, Size = UDim2.fromOffset(32, 32), Text = "", Parent = controls})
    corner(hideButton, 6) stroke(hideButton, 0.6, 1)
    local hideIcon = create("ImageLabel", {BackgroundTransparency = 1, Image = normalizeImage("lucide:minus"), ImageColor3 = self.Theme.Muted, Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(16, 16), ScaleType = Enum.ScaleType.Fit, Parent = hideButton})

    local sidebar = create("Frame", {BackgroundColor3 = self.Theme.Background, BackgroundTransparency = 0.2, Position = UDim2.fromOffset(18, 84), Size = UDim2.new(0, 190, 1, -102), Parent = clip})
    corner(sidebar, 8) stroke(sidebar, 1, 1) padding(sidebar, 12, 12)

    local sidebarHeader = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Size = UDim2.new(1, 0, 0, 0), Text = "", TextColor3 = self.Theme.Muted, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = sidebar})
    local tabHolder = create("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 1, 0), Parent = sidebar})
    list(tabHolder, 6, false)

    local content = create("Frame", {BackgroundColor3 = self.Theme.SurfaceSoft, BackgroundTransparency = 0.3, Position = UDim2.fromOffset(220, 84), Size = UDim2.new(1, -238, 1, -102), Parent = clip})
    content.BackgroundColor3 = self.Theme.Background
    content.BackgroundTransparency = 1
    corner(content, 8) stroke(content, 1, 1)
    local pages = create("Folder", {Name = "Pages", Parent = content})

    local floatingTabs = create("Frame", {BackgroundTransparency = 1, Visible = false, ZIndex = 5, Parent = root})
    local floatingTabsBar = create("CanvasGroup", {BackgroundColor3 = self.Theme.Background, BackgroundTransparency = 0.2, Size = UDim2.fromScale(1, 1), GroupTransparency = 0, Parent = floatingTabs})
    corner(floatingTabsBar, 8) stroke(floatingTabsBar, 1, 1) padding(floatingTabsBar, 6, 6)

    local floatingHolder = create("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = floatingTabsBar})
    local floatingLayout = list(floatingHolder, 6, true)
    floatingLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    floatingLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local settingsMenu = create("Frame", {AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = self.Theme.SurfaceSoft, BackgroundTransparency=0.1, Position = UDim2.new(1, -18, 0, 60), Size = UDim2.fromOffset(188, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, ZIndex = 15, Parent = clip})
    local settingsMenuStroke = stroke(settingsMenu, 0.5, 1)
    corner(settingsMenu, 8) padding(settingsMenu, 8, 8)
    list(settingsMenu, 6, false)

    local settingsTitleLabel = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Size = UDim2.new(1, 0, 0, 16), Text = "Tab Position", TextColor3 = self.Theme.Muted, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 16, Parent = settingsMenu})

    local resizeHandle = create("TextButton", {AnchorPoint = Vector2.new(1, 1), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.new(1, -8, 1, -8), Size = UDim2.fromOffset(24, 24), Text = "", Parent = root})
    for index = 0, 2 do
        local line = create("Frame", {AnchorPoint = Vector2.new(1, 1), BackgroundColor3 = self.Theme.Muted, BackgroundTransparency = 0.25 + (index * 0.2), Position = UDim2.new(1, -(index * 6), 1, 0), Size = UDim2.fromOffset(12 - (index * 2), 2), Rotation = -45, Parent = resizeHandle})
        corner(line, 999)
    end

    local mobileToggle = create("ImageButton", {AnchorPoint = Vector2.new(0, 1), AutoButtonColor = false, BackgroundColor3 = self.Theme.SurfaceSoft, Image = normalizeImage(options.MobileToggleIcon or options.Icon), Position = UDim2.new(0, 12, 1, -12), Size = UDim2.fromOffset(56, 56), Visible = false, Parent = screenGui})
    corner(mobileToggle, 8) stroke(mobileToggle, 0.4, 1)

    -- NEW WATERMARK SYSTEM (WITH BLUR SHADOW)
    local wmIconSource = normalizeImage(options.WatermarkIcon or options.Icon or "rbxassetid://7733779610")
    
    local watermarkContainer = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 1, -16), 
        AnchorPoint = Vector2.new(0, 1),
        Size = UDim2.new(0, 0, 0, 36),
        AutomaticSize = Enum.AutomaticSize.X,
        Visible = true,
        ZIndex = 100, 
        Parent = watermarkGui
    })

    local watermarkBg = create("Frame", {
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 0.2,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 100,
        Parent = watermarkContainer
    })
    corner(watermarkBg, 6) stroke(watermarkBg, 0.4, 1, self.Theme.Text)

    local wmShadow = create("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.35,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 30, 1, 30),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 99,
        Parent = watermarkContainer
    })

    local wmContent = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 101,
        Parent = watermarkContainer
    })
    padding(wmContent, 14, 0)
    local wmLayout = list(wmContent, 8, true)
    wmLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    
    local wmIcon = create("ImageLabel", {
        BackgroundTransparency = 1,
        Image = wmIconSource,
        Size = UDim2.fromOffset(20, 20),
        Visible = wmIconSource ~= "",
        ScaleType = Enum.ScaleType.Fit,
        Parent = wmContent
    })

    local watermarkTextLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        TextWrapped = false,
        Text = string.format("%s | %s", options.Title or "Null", options.Subtitle or "Watermark"),
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Parent = wmContent
    })

    local window = setmetatable({
        Library = self, ScreenGui = screenGui, Root = root, PopupLayer = popupLayer, Sidebar = sidebar, Content = content, Pages = pages, TabHolder = tabHolder, FloatingTabs = floatingTabs, FloatingTabsBar = floatingTabsBar, FloatingHolder = floatingHolder,
        TabPosition = options.TabPosition or "Left", Tabs = {}, CurrentTab = nil,
        MinSize = options.MinSize or Vector2.new(420, 340), MaxSize = options.MaxSize or Vector2.new(1200, 900), CurrentSize = options.Size and Vector2.new(options.Size.X.Offset, options.Size.Y.Offset) or Vector2.new(780, 520),
        UserResized = false, Open = true, StoredPosition = options.Position or UDim2.fromScale(0.5, 0.5), ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl, Elements = {}, Flags = {}, PendingConfig = nil, ConfigFolder = options.ConfigFolder or "NullUI", ConfigName = options.ConfigName or name,
        ThemeName = options.ThemeName or "Null",
        MobileToggle = mobileToggle, TitleLabel = title, SubtitleLabel = subtitle, TitleIcon = titleIcon, SettingsButton = settingsButton, HideButton = hideButton, SettingsMenu = settingsMenu, Topbar = topbar, SidebarHeader = sidebarHeader, FloatingLayout = floatingLayout,
        Watermark = watermarkContainer, WatermarkText = watermarkTextLabel, WatermarkIcon = wmIcon, WatermarkBg = watermarkBg, WatermarkGui = watermarkGui, WatermarkEnabled = true,
        Badge = badge, BadgeLabel = badgeLabel, SettingsIcon = settingsIcon, HideIcon = hideIcon,
        _activePopup = nil, _activePopupAnchor = nil, _popupConnections = {}, _themeBindings = {},
    }, Window)

    function window:_configDirectory() return self.ConfigFolder end
    function window:_configFilePath(configName) return string.format("%s/%s.json", self:_configDirectory(), configName) end
    function window:_autoloadStatePath() return string.format("%s/_autoload.json", self:_configDirectory()) end

    function window:_ensureFolders()
        if not self.Library:_storageAvailable() then return false end
        if not Storage.isfolder(self:_configDirectory()) then pcall(Storage.makefolder, self:_configDirectory()) end
        return true
    end

    function window:_readJson(path)
        if not self.Library:_storageAvailable() or not Storage.isfile(path) then return nil end
        local ok, raw = pcall(Storage.readfile, path)
        if not ok or type(raw) ~= "string" or raw == "" then return nil end
        local decodeOk, data = pcall(HttpService.JSONDecode, HttpService, raw)
        return decodeOk and data or nil
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
        if defaultValue ~= nil and self.Flags[flag] == nil then self.Flags[flag] = defaultValue end
        if self.PendingConfig and self.PendingConfig[flag] ~= nil and controller and controller.Set then controller:Set(self.PendingConfig[flag], true) end
        return controller
    end

    function window:_bindTheme(applyFn)
        if type(applyFn) ~= "function" then return end
        table.insert(self._themeBindings, applyFn)
        local ok = pcall(applyFn, self.Library.Theme)
        if not ok then return end
    end

    function window:_collectFlags()
        local data = {}
        for flag, controller in pairs(self.Elements) do if controller and controller.Get then data[flag] = controller:Get() end end
        data["_UISize"] = {X = self.CurrentSize.X, Y = self.CurrentSize.Y}
        data["_Theme"] = self.ThemeName or "Null"
        return data
    end

    function window:SaveConfig(configName, silent)
        configName = configName or self.ConfigName
        if not self:_ensureFolders() then
            if not silent then self.Library:Notify({Title = "Error", Content = "Storage missing.", Color = self.Library.Theme.Bad}) end
            return false
        end
        local ok = self:_writeJson(self:_configFilePath(configName), self:_collectFlags())
        if ok then self.ConfigName = configName end
        if ok and not silent then self.Library:Notify({Title = "Saved", Content = "Config saved.", Color = self.Library.Theme.Good}) end
        return ok
    end

    function window:LoadConfig(configName, silent)
        configName = configName or self.ConfigName
        local data = self:_readJson(self:_configFilePath(configName))
        if not data then return false end
        self.PendingConfig = shallowCopy(data)
        
        for flag, value in pairs(data) do
            if flag == "_UISize" and type(value) == "table" then
                self.CurrentSize = Vector2.new(tonumber(value.X) or self.CurrentSize.X, tonumber(value.Y) or self.CurrentSize.Y)
                self:_applyRootSize()
            elseif flag == "_Theme" and type(value) == "string" and value ~= "" then
                self:SetThemeByName(value, true)
            else
                local controller = self.Elements[flag]
                if controller and controller.Set then controller:Set(value, true) end
            end
        end
        
        self.ConfigName = configName
        if not silent then self.Library:Notify({Title = "Loaded", Content = "Config loaded.", Color = self.Library.Theme.Good}) end
        return true
    end

    function window:DeleteConfig(configName, silent)
        configName = configName or self.ConfigName
        if type(configName) ~= "string" or configName == "" then return false end
        if not (Storage.isfile and Storage.delfile) then
            if not silent then self.Library:Notify({Title = "Configs", Content = "Delete is not supported.", Color = self.Library.Theme.Bad}) end
            return false
        end
        local path = self:_configFilePath(configName)
        if not Storage.isfile(path) then
            if not silent then self.Library:Notify({Title = "Configs", Content = "Config not found.", Color = self.Library.Theme.Bad}) end
            return false
        end
        local ok = pcall(Storage.delfile, path)
        if not ok then
            if not silent then self.Library:Notify({Title = "Configs", Content = "Failed to delete config.", Color = self.Library.Theme.Bad}) end
            return false
        end
        local autoload = self:GetAutoloadState()
        if autoload.Enabled and autoload.Config == configName then
            self:DisableAutoload(true)
        end
        if self.ConfigName == configName then
            local remaining = self:RefreshConfigs()
            self.ConfigName = remaining[1] or self.ConfigName
        end
        if not silent then self.Library:Notify({Title = "Configs", Content = string.format("Deleted: %s", configName), Color = self.Library.Theme.Good}) end
        return true
    end

    function window:ListConfigs()
        if not self:_ensureFolders() then return {} end
        local names = {}
        if Storage.listfiles then
            local ok, files = pcall(Storage.listfiles, self:_configDirectory())
            if ok and type(files) == "table" then
                for _, path in ipairs(files) do
                    local name = configNameFromPath(path)
                    if name and name ~= "_autoload" then names[name] = true end
                end
            end
        end
        if not next(names) and Storage.isfile(self:_configFilePath(self.ConfigName)) then names[self.ConfigName] = true end
        local result = {}
        for name in pairs(names) do table.insert(result, name) end
        table.sort(result)
        return result
    end

    function window:RefreshConfigs() return self:ListConfigs() end

    function window:GetAutoloadState()
        local data = self:_readJson(self:_autoloadStatePath())
        if type(data) ~= "table" then return {Enabled = false, Config = nil} end
        return {
            Enabled = data.Enabled == true and type(data.Config) == "string" and data.Config ~= "",
            Config = type(data.Config) == "string" and data.Config ~= "" and data.Config or nil
        }
    end

    function window:SetAutoloadConfig(configName, enabled, silent)
        enabled = enabled == nil and true or not not enabled
        if not enabled then
            local ok = self:_writeJson(self:_autoloadStatePath(), {Enabled = false, Config = nil})
            if ok and not silent then self.Library:Notify({Title = "Autoload", Content = "Autoload disabled.", Color = self.Library.Theme.Muted}) end
            return ok
        end
        configName = configName or self.ConfigName
        if type(configName) ~= "string" or configName == "" then return false end
        local ok = self:_writeJson(self:_autoloadStatePath(), {Enabled = true, Config = configName})
        if ok and not silent then self.Library:Notify({Title = "Autoload", Content = string.format("Autoload: %s", configName), Color = self.Library.Theme.Good}) end
        return ok
    end

    function window:DisableAutoload(silent) return self:SetAutoloadConfig(nil, false, silent) end
    function window:LoadAutoload(silent)
        local state = self:GetAutoloadState()
        if not state.Enabled or not state.Config then return false end
        local ok = self:LoadConfig(state.Config, true)
        if ok and not silent then self.Library:Notify({Title = "Autoload", Content = string.format("Loaded: %s", state.Config), Color = self.Library.Theme.Good}) end
        return ok
    end

    function window:_applyRootSize()
        local size = viewportSize()
        local maxWidth = math.max(360, size.X - 24)
        local maxHeight = math.max(300, size.Y - 24)
        local mobile = size.X < 760 or isTouch()
        self.CurrentSize = Vector2.new(math.clamp(self.CurrentSize.X, self.MinSize.X, math.min(self.MaxSize.X, maxWidth)), math.clamp(self.CurrentSize.Y, self.MinSize.Y, math.min(self.MaxSize.Y, maxHeight)))
        if mobile and not self.UserResized then self.CurrentSize = Vector2.new(math.min(420, maxWidth), math.min(540, maxHeight)) end

        tween(self.Root, {Size = UDim2.fromOffset(self.CurrentSize.X, self.CurrentSize.Y)}, 0.25, Enum.EasingStyle.Exponential)
        self.Root.Position = self.StoredPosition
        self.MobileToggle.Visible = mobile and not self.Open
        hideButton.Visible = not mobile
        settingsButton.Visible = not mobile
        resizeHandle.Visible = not mobile

        self:_layoutChrome(mobile and "Left" or self.TabPosition)
        self:_syncFloatingTabs()
    end

    function window:_setOpen(openState, instant)
        self.Open = openState
        if openState then
            self.ScreenGui.Enabled = true
            self.MobileToggle.Visible = false
            self:_closePopup(true)
            if self.TabPosition == "Top" or self.TabPosition == "Bottom" then
                self.FloatingTabs.Visible = true
                tween(self.FloatingTabsBar, {GroupTransparency = 0}, instant and 0 or 0.35, Enum.EasingStyle.Exponential)
            end
            if instant then
                self.Root.Size = UDim2.fromOffset(self.CurrentSize.X, self.CurrentSize.Y)
                self.Root.BackgroundTransparency = 0.2
                self.Root.Position = self.StoredPosition
                uiScale.Scale = viewportSize().X < 760 and 0.92 or 1
                return
            end
            local targetPosition = self.StoredPosition
            self.Root.Position = UDim2.new(targetPosition.X.Scale, targetPosition.X.Offset, targetPosition.Y.Scale, targetPosition.Y.Offset + 18)
            self.Root.Size = UDim2.fromOffset(self.CurrentSize.X - 26, self.CurrentSize.Y - 18)
            self.Root.BackgroundTransparency = 1
            uiScale.Scale = (viewportSize().X < 760 and 0.9 or 0.975)
            tween(self.Root, {Position = targetPosition, Size = UDim2.fromOffset(self.CurrentSize.X, self.CurrentSize.Y), BackgroundTransparency = 0.2}, 0.35, Enum.EasingStyle.Exponential)
            tween(uiScale, {Scale = viewportSize().X < 760 and 0.92 or 1}, 0.35, Enum.EasingStyle.Exponential)
        else
            self.MobileToggle.Visible = isTouch() or viewportSize().X < 760
            self:_closePopup(true)
            settingsMenu.Visible = false
            if instant then
                self.ScreenGui.Enabled = false
                self.FloatingTabs.Visible = false
                return
            end
            if self.TabPosition == "Top" or self.TabPosition == "Bottom" then
                tween(self.FloatingTabsBar, {GroupTransparency = 1}, 0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
            end
            tween(self.Root, {Position = UDim2.new(self.Root.Position.X.Scale, self.Root.Position.X.Offset, self.Root.Position.Y.Scale, self.Root.Position.Y.Offset + 16), Size = UDim2.fromOffset(self.CurrentSize.X - 30, self.CurrentSize.Y - 18), BackgroundTransparency = 1}, 0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
            tween(uiScale, {Scale = viewportSize().X < 760 and 0.88 or 0.965}, 0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
            task.delay(0.25, function() if self.Root and not self.Open then self.FloatingTabs.Visible = false self.ScreenGui.Enabled = false end end)
        end
    end

    function window:Toggle(state)
        if state == nil then state = not self.Open end
        self:_setOpen(state, false)
    end

    function window:Notify(notification) return self.Library:Notify(notification) end
    function window:SetTitle(text, iconImage)
        self.TitleLabel.Text = text or self.TitleLabel.Text
        if iconImage ~= nil then self.TitleIcon.Image = normalizeImage(iconImage) self.TitleIcon.Visible = iconImage ~= "" self.TitleIcon.BackgroundTransparency = iconImage ~= "" and 0.5 or 1 end
    end
    function window:SetSubtitle(text) self.SubtitleLabel.Text = text or self.SubtitleLabel.Text end
    function window:SetTabPosition(position) self:_layoutChrome(position) end
    function window:_applyThemeToWindow()
        local t = self.Library.Theme
        if not t then return end
        self.Root.BackgroundColor3 = t.Background
        self.Sidebar.BackgroundColor3 = t.Background
        self.Content.BackgroundColor3 = t.Background
        self.FloatingTabsBar.BackgroundColor3 = t.Background
        self.SettingsMenu.BackgroundColor3 = t.SurfaceSoft
        self.MobileToggle.BackgroundColor3 = t.SurfaceSoft
        self.TitleLabel.TextColor3 = t.Text
        self.SubtitleLabel.TextColor3 = t.Muted
        self.SidebarHeader.TextColor3 = t.Muted
        self.Badge.BackgroundColor3 = t.SurfaceRaised
        self.BadgeLabel.TextColor3 = t.Text
        self.SettingsButton.BackgroundColor3 = t.SurfaceRaised
        self.HideButton.BackgroundColor3 = t.SurfaceRaised
        self.SettingsIcon.ImageColor3 = t.Muted
        self.HideIcon.ImageColor3 = t.Muted
        self.WatermarkBg.BackgroundColor3 = t.Background
        self.WatermarkText.TextColor3 = t.Text
        for _, tab in ipairs(self.Tabs) do
            tab.Frame.BackgroundColor3 = (self.TabPosition == "Top" or self.TabPosition == "Bottom") and t.SurfaceRaised or t.Background
            tab.IconWrap.BackgroundColor3 = (self.TabPosition == "Top" or self.TabPosition == "Bottom") and t.SurfaceAccent or t.Background
            tab.Label.TextColor3 = tab == self.CurrentTab and t.Text or t.Muted
            tab.Description.TextColor3 = t.Muted
            tab.GlyphLabel.TextColor3 = tab == self.CurrentTab and t.AccentSoft or t.Text
            tab.ImageLabel.ImageColor3 = tab == self.CurrentTab and t.AccentSoft or t.Text
            tab.ActiveLine.BackgroundColor3 = t.AccentSoft
        end
        for _, applyFn in ipairs(self._themeBindings) do
            pcall(applyFn, t)
        end
        if self.CurrentTab then self:SelectTab(self.CurrentTab, true) end
    end
    function window:SetTheme(themeData, silent, themeName)
        if type(themeData) ~= "table" then return false end
        for key, value in pairs(themeData) do
            if typeof(value) == "Color3" then
                self.Library.Theme[key] = value
            end
        end
        if type(themeName) == "string" and themeName ~= "" then
            self.ThemeName = themeName
        end
        self:_applyThemeToWindow()
        if not silent then self:Notify({Title = "Theme", Content = "Theme applied.", Color = self.Library.Theme.Good}) end
        return true
    end
    function window:SetThemeByName(themeName, silent)
        themeName = type(themeName) == "string" and themeName or "Null"
        local theme = self.Library:GetTheme(themeName)
        if not theme then return false end
        return self:SetTheme(theme, silent, themeName)
    end
    function window:Destroy()
        if self.ScreenGui then self.ScreenGui:Destroy() end
        if self.WatermarkGui then self.WatermarkGui:Destroy() end
    end
    
    function window:SetWatermark(text, icon) 
        if text then self.WatermarkText.Text = text end
        if icon ~= nil then
            local img = normalizeImage(icon)
            self.WatermarkIcon.Image = img
            self.WatermarkIcon.Visible = img ~= ""
        end
    end
    function window:SetWatermarkVisible(enabled)
        self.WatermarkEnabled = enabled ~= false
        self.Watermark.Visible = self.WatermarkEnabled
    end

    function window:_disconnectPopupConnections()
        for _, connection in ipairs(self._popupConnections) do if connection and connection.Disconnect then connection:Disconnect() end end
        table.clear(self._popupConnections)
    end

    function window:_closePopup(skipDestroy)
        self:_disconnectPopupConnections()
        if self._activePopup then
            local popup = self._activePopup
            self._activePopup = nil
            self._activePopupAnchor = nil
            if skipDestroy then popup:Destroy() else
                tween(popup, {BackgroundTransparency = 1, Size = UDim2.fromOffset(popup.AbsoluteSize.X, math.max(24, popup.AbsoluteSize.Y - 12))}, 0.16, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
                task.delay(0.17, function() if popup and popup.Parent then popup:Destroy() end end)
            end
        end
    end

    function window:_createPopup(width, height, anchorGui, offset)
        self:_closePopup(true)
        local popup = create("Frame", {BackgroundColor3 = self.Library.Theme.SurfaceSoft, BackgroundTransparency = 1, Size = UDim2.fromOffset(width, math.max(height - 12, 20)), ZIndex = 50, Parent = self.PopupLayer})
        corner(popup, 8) stroke(popup, 0.4, 1) popup.ClipsDescendants = true
        local anchorPosition = anchorGui.AbsolutePosition
        local anchorSize = anchorGui.AbsoluteSize
        local screenSize = viewportSize()
        local resolvedOffset = offset or Vector2.new(10, 0)
        local targetX = anchorPosition.X + anchorSize.X + resolvedOffset.X
        local targetY = anchorPosition.Y + resolvedOffset.Y
        if targetX + width > screenSize.X - 12 then targetX = anchorPosition.X - width - 10 end
        targetX = math.clamp(targetX, 12, math.max(12, screenSize.X - width - 12))
        targetY = math.clamp(targetY, 12, math.max(12, screenSize.Y - height - 12))
        popup.Position = UDim2.fromOffset(targetX - 14, targetY)
        tween(popup, {BackgroundTransparency = 0.1, Position = UDim2.fromOffset(targetX, targetY), Size = UDim2.fromOffset(width, height)}, 0.25, Enum.EasingStyle.Exponential)
        self._activePopup = popup
        self._activePopupAnchor = anchorGui
        table.insert(self._popupConnections, UIS.InputBegan:Connect(function(input, processed)
            if processed and input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local pos = input.Position
                local insidePopup = pos.X >= popup.AbsolutePosition.X and pos.X <= popup.AbsolutePosition.X + popup.AbsoluteSize.X and pos.Y >= popup.AbsolutePosition.Y and pos.Y <= popup.AbsolutePosition.Y + popup.AbsoluteSize.Y
                local insideAnchor = pos.X >= anchorGui.AbsolutePosition.X and pos.X <= anchorGui.AbsolutePosition.X + anchorGui.AbsoluteSize.X and pos.Y >= anchorGui.AbsolutePosition.Y and pos.Y <= anchorGui.AbsolutePosition.Y + anchorGui.AbsoluteSize.Y
                if not insidePopup and not insideAnchor then self:_closePopup() end
            end
        end))
        return popup
    end

    function window:_syncFloatingTabs()
        if self.TabPosition ~= "Bottom" and self.TabPosition ~= "Top" then return end
        local count = #self.Tabs
        if count == 0 then return end
        local totalWidth = (count * 130) + ((count - 1) * 6) + 12
        local barWidth = math.max(200, totalWidth)
        self.FloatingTabs.Size = UDim2.fromOffset(barWidth, 48)
        self.FloatingTabs.Position = self.TabPosition == "Top" and UDim2.new(0.5, 0, 0, -12) or UDim2.new(0.5, 0, 1, 12)
        self.FloatingTabs.AnchorPoint = self.TabPosition == "Top" and Vector2.new(0.5, 1) or Vector2.new(0.5, 0)
        self.FloatingTabs.Visible = true
        if self.Open then self.FloatingTabsBar.GroupTransparency = 0 end
    end

    function window:_layoutChrome(mode)
        mode = mode or self.TabPosition or "Left"
        self.TabPosition = mode
        local mobile = viewportSize().X < 760 or isTouch()
        if mobile then mode = "Left" end

        self.FloatingTabs.Visible = false
        self.Sidebar.Visible = mode == "Left" or mode == "Right"
        self.SidebarHeader.Text = ""

        local top = 84
        if mode == "Left" then
            self.Sidebar.Position = UDim2.fromOffset(18, top)
            self.Sidebar.Size = mobile and UDim2.new(0, 98, 1, -102) or UDim2.new(0, 190, 1, -102)
            self.Content.Position = mobile and UDim2.fromOffset(128, top) or UDim2.fromOffset(220, top)
            self.Content.Size = mobile and UDim2.new(1, -146, 1, -102) or UDim2.new(1, -238, 1, -102)
            tabHolder.Position = UDim2.new(0, 0, 0, 0)
            tabHolder.Size = UDim2.new(1, 0, 1, 0)
            tabHolder.Parent = self.Sidebar
        elseif mode == "Right" then
            self.Sidebar.Position = UDim2.new(1, mobile and -110 or -202, 0, top)
            self.Sidebar.Size = mobile and UDim2.new(0, 98, 1, -102) or UDim2.new(0, 190, 1, -102)
            self.Content.Position = UDim2.fromOffset(18, top)
            self.Content.Size = mobile and UDim2.new(1, -146, 1, -102) or UDim2.new(1, -238, 1, -102)
            tabHolder.Position = UDim2.new(0, 0, 0, 0)
            tabHolder.Size = UDim2.new(1, 0, 1, 0)
            tabHolder.Parent = self.Sidebar
        elseif mode == "Bottom" or mode == "Top" then
            self.Content.Position = UDim2.fromOffset(18, top)
            self.Content.Size = UDim2.new(1, -36, 1, -102)
            tabHolder.Position = UDim2.new(0, 0, 0, 0)
            tabHolder.Size = UDim2.new(1, 0, 1, 0)
            tabHolder.Parent = self.FloatingHolder
            self:_syncFloatingTabs()
        end

        local layoutObject = tabHolder:FindFirstChildOfClass("UIListLayout")
        if layoutObject then
            local horizontalTabs = mode == "Bottom" or mode == "Top"
            layoutObject.FillDirection = horizontalTabs and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
            layoutObject.HorizontalAlignment = horizontalTabs and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left
            layoutObject.VerticalAlignment = horizontalTabs and Enum.VerticalAlignment.Center or Enum.VerticalAlignment.Top
        end
        for _, tab in ipairs(self.Tabs) do tab:SetLayout(mode) end
    end

    function window:CreateTab(tabOptions, maybeIcon)
        if type(tabOptions) ~= "table" then tabOptions = {Name = tabOptions, Icon = maybeIcon} end
        local tabImageSource = tabOptions.Image or (isImageSource(tabOptions.Icon) and tabOptions.Icon or nil)

        local button = create("TextButton", {AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48), Text = "", Parent = tabHolder})
        local frame = create("Frame", {BackgroundColor3 = self.Library.Theme.SurfaceRaised, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = button})
        corner(frame, 6) stroke(frame, 0.6, 1)

        local activeLine = create("Frame", {BackgroundColor3 = self.Library.Theme.AccentSoft, BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 24), Size = UDim2.fromOffset(10, 2), Parent = frame})
        corner(activeLine, 999)

        local iconWrap = create("Frame", {BackgroundColor3 = self.Library.Theme.SurfaceAccent, BackgroundTransparency=1, Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(32, 32), Parent = frame})
        corner(iconWrap, 6)

        local imageLabel = create("ImageLabel", {BackgroundTransparency = 1, Image = normalizeImage(tabImageSource), Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(20, 20), ScaleType = Enum.ScaleType.Fit, Visible = tabImageSource ~= nil, Parent = iconWrap})
        local glyphLabel = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Size = UDim2.fromScale(1, 1), Text = tabImageSource and "" or (tabOptions.Icon or "•"), TextColor3 = self.Library.Theme.Text, TextSize = 16, Parent = iconWrap})
        local label = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.fromOffset(48, 8), Size = UDim2.new(1, -56, 0, 18), Text = tabOptions.Name or "Tab", TextColor3 = self.Library.Theme.Muted, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame})
        local descriptionLabel = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Position = UDim2.fromOffset(48, 26), Size = UDim2.new(1, -56, 0, 14), Text = tabOptions.Description or "", TextColor3 = self.Library.Theme.Muted, TextSize = 11, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left, Visible = tabOptions.Description ~= nil and tabOptions.Description ~= "", Parent = frame})
        
        -- СИСТЕМА ДВУХ КОЛОНОК (ИСПРАВЛЕННЫЙ PADDING)
        local page = create("ScrollingFrame", {AutomaticCanvasSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(), Position = UDim2.fromOffset(16, 16), ScrollBarThickness = 2, ScrollBarImageColor3 = self.Library.Theme.AccentSoft, Size = UDim2.new(1, -32, 1, -32), Visible = false, Parent = pages})
        local pageLayout = create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), Parent = page})
        
        local leftCol = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = page})
        local rightCol = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = page})
        list(leftCol, 10, false)
        list(rightCol, 10, false)

        -- Адаптивность колонок при сужении
        page:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            if page.AbsoluteSize.X < 380 then
                pageLayout.FillDirection = Enum.FillDirection.Vertical
                leftCol.Size = UDim2.new(1, 0, 0, 0)
                rightCol.Size = UDim2.new(1, 0, 0, 0)
            else
                pageLayout.FillDirection = Enum.FillDirection.Horizontal
                leftCol.Size = UDim2.new(0.5, -5, 0, 0)
                rightCol.Size = UDim2.new(0.5, -5, 0, 0)
            end
        end)

        local tab = setmetatable({Window = self, Button = button, Frame = frame, Label = label, Description = descriptionLabel, ActiveLine = activeLine, IconWrap = iconWrap, ImageLabel = imageLabel, GlyphLabel = glyphLabel, Page = page, LeftColumn = leftCol, RightColumn = rightCol}, Tab)
        table.insert(self.Tabs, tab)
        tab:SetLayout(self.TabPosition)

        button.MouseButton1Click:Connect(function() self:SelectTab(tab) end)
        if not self.CurrentTab then self:SelectTab(tab, true) end
        return tab
    end

    function window:SelectTab(targetTab, instant)
        if self.CurrentTab == targetTab then return end
        self.CurrentTab = targetTab
        local horizontalMode = self.TabPosition == "Top" or self.TabPosition == "Bottom"

        for _, tab in ipairs(self.Tabs) do
            local active = tab == targetTab
            local frameTransparency = horizontalMode and 1 or (active and 0.25 or 0.45)
            local iconTransparency = horizontalMode and 1 or (active and 0.15 or 0.35)
            tab.Page.Visible = active and true or false
            tween(tab.Frame, {BackgroundTransparency = frameTransparency}, instant and 0 or 0.2)
            tween(tab.IconWrap, {BackgroundTransparency = iconTransparency}, instant and 0 or 0.2)
            
            local activeSize = horizontalMode and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 20)
            local inactiveSize = horizontalMode and UDim2.fromOffset(10, 2) or UDim2.fromOffset(2, 10)
            
            tween(tab.ActiveLine, {BackgroundTransparency = active and 0 or 1, Size = active and activeSize or inactiveSize}, instant and 0 or 0.2)
            tab.Label.TextColor3 = active and self.Library.Theme.Text or self.Library.Theme.Muted
            tab.GlyphLabel.TextColor3 = active and self.Library.Theme.AccentSoft or self.Library.Theme.Text
            tab.ImageLabel.ImageColor3 = active and self.Library.Theme.AccentSoft or self.Library.Theme.Text
            if active then
                tab.Page.Position = UDim2.fromOffset(32, 16)
                tween(tab.Page, {Position = UDim2.fromOffset(16, 16)}, instant and 0 or 0.3, Enum.EasingStyle.Exponential)
            end
        end
    end

    local tabPositionChoices = {
        {Label = "Left", Value = "Left", Icon = "lucide:panel-left"},
        {Label = "Right", Value = "Right", Icon = "lucide:panel-right"},
        {Label = "Bottom", Value = "Bottom", Icon = "lucide:panel-bottom"},
        {Label = "Top", Value = "Top", Icon = "lucide:panel-top"}
    }
    local tabPositionRows = {}
    for _, choice in ipairs(tabPositionChoices) do
        local optionButton = create("TextButton", {AutoButtonColor = false, BackgroundColor3 = self.Theme.SurfaceRaised, BackgroundTransparency=0.5, Size = UDim2.new(1, 0, 0, 32), Text = "", ZIndex = 16, Parent = settingsMenu})
        corner(optionButton, 6)
        local optionIcon = create("ImageLabel", {BackgroundTransparency = 1, Image = normalizeImage(choice.Icon), ImageColor3 = self.Theme.Muted, Position = UDim2.fromOffset(10, 8), Size = UDim2.fromOffset(16, 16), ScaleType = Enum.ScaleType.Fit, ZIndex = 17, Parent = optionButton})
        local optionLabel = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.fromOffset(34, 0), Size = UDim2.new(1, -44, 1, 0), Text = choice.Label, TextColor3 = self.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 17, Parent = optionButton})
        table.insert(tabPositionRows, {Button = optionButton, Icon = optionIcon, Label = optionLabel})
        optionButton.MouseButton1Click:Connect(function() settingsMenu.Visible = false window:_layoutChrome(choice.Value) end)
    end
    
    -- НАСТОЯЩИЙ TOGGLE В НАСТРОЙКАХ
    create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,4), ZIndex=16, Parent=settingsMenu})
    local wmToggleBtn = create("TextButton", {AutoButtonColor = false, BackgroundColor3 = self.Theme.SurfaceRaised, BackgroundTransparency=0.5, Size = UDim2.new(1, 0, 0, 36), Text = "", ZIndex = 16, Parent = settingsMenu})
    corner(wmToggleBtn, 6)
    local wmToggleIcon = create("ImageLabel", {BackgroundTransparency = 1, Image = normalizeImage("lucide:badge"), ImageColor3 = self.Theme.Muted, Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(14, 14), ScaleType = Enum.ScaleType.Fit, ZIndex = 17, Parent = wmToggleBtn})
    local wmToggleLabel = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.fromOffset(30, 0), Size = UDim2.new(1, -60, 1, 0), Text = "Watermark", TextColor3 = self.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 17, Parent = wmToggleBtn})
    local wmTrack = create("Frame", {AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = self.Theme.AccentSoft, BackgroundTransparency = 0.2, Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(32, 16), ZIndex=17, Parent = wmToggleBtn})
    corner(wmTrack, 999)
    local wmKnob = create("Frame", {AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = self.Theme.Text, Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.fromOffset(14, 14), ZIndex=18, Parent = wmTrack})
    corner(wmKnob, 999)

    local wmState = true
    window:_bindTheme(function(theme)
        settingsMenu.BackgroundColor3 = theme.SurfaceSoft
        settingsMenuStroke.Color = theme.Stroke
        settingsTitleLabel.TextColor3 = theme.Muted
        for _, row in ipairs(tabPositionRows) do
            row.Button.BackgroundColor3 = theme.SurfaceRaised
            row.Icon.ImageColor3 = theme.Muted
            row.Label.TextColor3 = theme.Text
        end
        wmToggleBtn.BackgroundColor3 = theme.SurfaceRaised
        wmToggleIcon.ImageColor3 = theme.Muted
        wmToggleLabel.TextColor3 = theme.Text
        wmTrack.BackgroundColor3 = wmState and theme.AccentSoft or theme.SurfaceAccent
        wmKnob.BackgroundColor3 = theme.Text
    end)
    wmToggleBtn.MouseButton1Click:Connect(function()
        wmState = not wmState
        tween(wmTrack, {BackgroundColor3 = wmState and self.Theme.AccentSoft or self.Theme.SurfaceAccent}, 0.2)
        tween(wmKnob, {Position = wmState and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.2)
        window:SetWatermarkVisible(wmState)
        settingsMenu.Visible = false
    end)

    local isDragging = false
    local isResizing = false
    local targetPos = root.Position
    local targetSize = window.CurrentSize

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            local dragStart = input.Position
            local startPos = root.Position
            targetPos = startPos 

            local dragConn, dropConn
            dragConn = UIS.InputChanged:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch then
                    local delta = input2.Position - dragStart
                    targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            dropConn = UIS.InputEnded:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                    window.StoredPosition = targetPos
                    if dragConn then dragConn:Disconnect() end
                    if dropConn then dropConn:Disconnect() end
                end
            end)
        end
    end)

    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isResizing = true
            local resizeStart = input.Position
            local resizeBase = window.CurrentSize

            local resizeConn, dropConn
            resizeConn = UIS.InputChanged:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch then
                    local delta = input2.Position - resizeStart
                    targetSize = Vector2.new(resizeBase.X + delta.X, resizeBase.Y + delta.Y)
                    window.UserResized = true
                end
            end)
            dropConn = UIS.InputEnded:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
                    isResizing = false
                    if resizeConn then resizeConn:Disconnect() end
                    if dropConn then dropConn:Disconnect() end
                end
            end)
        end
    end)

    root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if window.TabPosition == "Top" or window.TabPosition == "Bottom" then window:_syncFloatingTabs() end
    end)

    RunService.RenderStepped:Connect(function(dt)
        if isDragging then root.Position = root.Position:Lerp(targetPos, math.clamp(dt * 18, 0, 1)) end
        if isResizing then window.CurrentSize = window.CurrentSize:Lerp(targetSize, math.clamp(dt * 18, 0, 1)) window:_applyRootSize() end
    end)

    hideButton.MouseButton1Click:Connect(function() window:Toggle(false) end)
    mobileToggle.MouseButton1Click:Connect(function() window:Toggle(true) end)
    settingsButton.MouseButton1Click:Connect(function() window:_closePopup(true) settingsMenu.Visible = not settingsMenu.Visible end)

    UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == window.ToggleKey then window:Toggle() return end
    end)

    window:SetThemeByName(window.ThemeName, true)
    window:LoadAutoload(true)
    window:_applyRootSize()
    window:_setOpen(true, false)
    
    task.defer(function()
        window:_layoutChrome(window.TabPosition)
        local baseSize = window.CurrentSize
        window.CurrentSize = Vector2.new(baseSize.X + 2, baseSize.Y + 1)
        window:_applyRootSize()
        task.delay(0.06, function()
            if not window.Root or not window.Root.Parent then return end
            window.CurrentSize = baseSize
            window:_applyRootSize()
        end)
    end)

    if options.WelcomeNotification ~= false then task.delay(0.08, function() window:Notify({Title = options.Title or "Null", Content = "UI launched successfully.", Icon = options.Icon, Duration = 3, Color = self.Theme.Good}) end) end
    return window
end

return NullLibrary
