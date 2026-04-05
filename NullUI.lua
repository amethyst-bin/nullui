local NullLibrary = {
Theme = {
Background = Color3.fromRGB(15, 15, 20),
Surface = Color3.fromRGB(20, 22, 30),
SurfaceSoft = Color3.fromRGB(28, 30, 42),
SurfaceRaised = Color3.fromRGB(36, 40, 54),
SurfaceAccent = Color3.fromRGB(48, 54, 74),
Text = Color3.fromRGB(255, 255, 255),
Muted = Color3.fromRGB(160, 168, 190),
Stroke = Color3.fromRGB(60, 65, 85),
AccentSoft = Color3.fromRGB(140, 160, 255),
Good = Color3.fromRGB(80, 255, 160),
Bad = Color3.fromRGB(255, 80, 100),
},
Version = "3.4"
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

local function clampRound(value)
return math.floor(value + 0.5)
end

local function normalizeSetArgs(selfOrValue, maybeValue, maybeSkip)
if type(selfOrValue) == "table" then
return maybeValue, maybeSkip
end
return selfOrValue, maybeValue
end

local Storage = {
writefile = writefile or (request and function(path, data) end),
readfile = readfile,
makefolder = makefolder,
isfolder = isfolder,
isfile = isfile,
listfiles = listfiles,
getcustomasset = getcustomasset or getsynasset
}

local function getUrlImage(url)
if not url:match("^http") then return url end
if not (Storage.writefile and Storage.getcustomasset) then return "" end
local hash = url:gsub("[^%w]", ""):sub(-20) .. ".png"
local folderPath = "NullUI_Images"
local filePath = folderPath .. "/" .. hash
if not Storage.isfolder(folderPath) then
pcall(Storage.makefolder, folderPath)
end
if not Storage.isfile(filePath) then
local success, response = pcall(function() return game:HttpGet(url) end)
if success and response then
pcall(Storage.writefile, filePath, response)
else
return ""
end
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
stroke(button, 0.5, 1)
button.MouseEnter:Connect(function() tween(button, {BackgroundTransparency = 0.1}, 0.2) end)
button.MouseLeave:Connect(function() tween(button, {BackgroundTransparency = 0.4}, 0.2) end)
return button
end

-- Перенесли функции Tab ВЫШЕ, чтобы не было ошибки "attempt to call a nil value"
function Tab:SetLayout(mode)
local horizontal = mode == "Bottom" or mode == "Top"
self.Button.Size = horizontal and UDim2.fromOffset(130, 36) or UDim2.new(1, 0, 0, 48)
self.Frame.Size = UDim2.fromScale(1, 1)


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
    self.ActiveLine.Position = UDim2.fromOffset(8, 24)
    self.ActiveLine.AnchorPoint = Vector2.new(0, 0)
end

end

function Tab:CreateSection(sectionOptions, maybeDescription)
if type(sectionOptions) ~= "table" then sectionOptions = {Title = sectionOptions, Description = maybeDescription} end
local card = create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = NullLibrary.Theme.SurfaceSoft, BackgroundTransparency = 0.5, Size = UDim2.new(1, 0, 0, 0), Parent = self.Page})
corner(card, 6) stroke(card, 0.6, 1) padding(card, 16, 16)


autosizeText(create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Size = UDim2.new(1, 0, 0, 0), Text = sectionOptions.Title or "Section", TextColor3 = NullLibrary.Theme.Text, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Parent = card}))
if sectionOptions.Description and sectionOptions.Description ~= "" then autosizeText(create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 0, 0), Text = sectionOptions.Description, TextColor3 = NullLibrary.Theme.Muted, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = card})) end

local holder = create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, sectionOptions.Description and sectionOptions.Description ~= "" and 54 or 30), Size = UDim2.new(1, 0, 0, 0), Parent = card})
list(holder, 8, false)
local windowRef = self.Window
local section = {Window = windowRef}

local function register(flag, controller, defaultValue) return windowRef:_registerFlag(flag, controller, defaultValue) end

function section:AddLabel(text) return autosizeText(create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Size = UDim2.new(1, 0, 0, 0), Text = text or "Label", TextColor3 = NullLibrary.Theme.Muted, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = holder})) end

function section:AddParagraph(titleText, bodyText)
    local paragraph = create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = NullLibrary.Theme.SurfaceRaised, BackgroundTransparency = 0.5, Size = UDim2.new(1, 0, 0, 0), Parent = holder})
    corner(paragraph, 6) padding(paragraph, 12, 10)
    autosizeText(create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Size = UDim2.new(1, 0, 0, 0), Text = titleText or "Info", TextColor3 = NullLibrary.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = paragraph}))
    autosizeText(create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Position = UDim2.fromOffset(0, 20), Size = UDim2.new(1, 0, 0, 0), Text = bodyText or "", TextColor3 = NullLibrary.Theme.Muted, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = paragraph}))
    return paragraph
end

function section:AddImage(options)
    options = options or {}
    local frame = create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = NullLibrary.Theme.SurfaceRaised, BackgroundTransparency = 0.5, Size = UDim2.new(1, 0, 0, 0), Parent = holder})
    corner(frame, 6) stroke(frame, 0.6, 1) padding(frame, 8, 8)
    
    local imgSource = normalizeImage(options.Image or options.Url or options.ID)
    local image = create("ImageLabel", {BackgroundColor3 = NullLibrary.Theme.SurfaceAccent, BackgroundTransparency = 0.5, Image = imgSource, Size = UDim2.new(1, 0, 0, options.Height or 140), ScaleType = options.ScaleType or Enum.ScaleType.Crop, Parent = frame})
    corner(image, options.CornerRadius or 6)

    if imgSource == "" and type(options.Image or options.Url) == "string" and (options.Image or options.Url):match("^http") then
        task.spawn(function()
            local loadedAsset = getUrlImage(options.Image or options.Url)
            if loadedAsset ~= "" then image.Image = loadedAsset end
        end)
    end

    if options.Caption and options.Caption ~= "" then autosizeText(create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Position = UDim2.fromOffset(0, (options.Height or 140) + 10), Size = UDim2.new(1, 0, 0, 0), Text = options.Caption, TextColor3 = NullLibrary.Theme.Muted, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center, Parent = frame})) end
    return image
end

function section:AddButton(options)
    options = options or {}
    local buttonWrap = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, options.Height or 38), Parent = holder})
    local button = NullLibrary:_createCardButton(buttonWrap, options.Height or 38)
    local scale = create("UIScale", {Scale = 1, Parent = buttonWrap})
    local showIcon = options.Icon ~= nil

    create("ImageLabel", {BackgroundTransparency = 1, Image = normalizeImage(options.Icon), Position = UDim2.fromOffset(12, 9), Size = UDim2.fromOffset(20, 20), ScaleType = Enum.ScaleType.Fit, Visible = showIcon, Parent = button})
    create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.fromOffset(showIcon and 40 or 14, 0), Size = UDim2.new(1, showIcon and -52 or -28, 1, 0), Text = options.Text or "Button", TextColor3 = NullLibrary.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Center, Parent = button})

    button.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then tween(scale, {Scale = 0.96}, 0.12) end end)
    button.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then tween(scale, {Scale = 1}, 0.12) end end)
    button.MouseButton1Click:Connect(function() if options.Callback then task.spawn(options.Callback) end end)
    return button
end

function section:AddToggle(options)
    options = options or {}
    local flag = options.Flag or options.Text
    local state = options.Default or false

    local button = NullLibrary:_createCardButton(holder, 44)
    create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.fromOffset(14, 6), Size = UDim2.new(1, -78, 0, 16), Text = options.Text or "Toggle", TextColor3 = NullLibrary.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = button})
    if options.Description and options.Description ~= "" then create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Position = UDim2.fromOffset(14, 22), Size = UDim2.new(1, -78, 0, 14), Text = options.Description, TextColor3 = NullLibrary.Theme.Muted, TextSize = 11, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left, Parent = button}) end

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
    corner(frame, 6) stroke(frame, 0.6, 1)

    create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.fromOffset(14, 10), Size = UDim2.new(1, -88, 0, 16), Text = options.Text or "Slider", TextColor3 = NullLibrary.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame})
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

    local function openPopup()
        arrow.Text = "v"
        local pHeight = math.min(200, (#vals * 34) + 16)
        local popup = self.Window:_createPopup(200, pHeight, button)
        local dConn dConn = popup.AncestryChanged:Connect(function() if not popup:IsDescendantOf(game) then arrow.Text = ">" dConn:Disconnect() end end)
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

return section

end

function NullLibrary:CreateWindow(options)
options = options or {}
local name = options.Name or "NullUI"
local container = RunService:IsStudio() and PlayerGui or CoreGui
local existing = container:FindFirstChild(name)
if existing then existing:Destroy() end


local screenGui = create("ScreenGui", {
    Name = name,
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
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
create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Size = UDim2.fromScale(1, 1), Text = options.BadgeText or "NULL", TextColor3 = self.Theme.Text, TextSize = 11, Parent = badge})

local settingsButton = create("TextButton", {AutoButtonColor = false, BackgroundColor3 = self.Theme.SurfaceRaised, BackgroundTransparency=0.5, Size = UDim2.fromOffset(32, 32), Text = "⚙", TextColor3 = self.Theme.Muted, TextSize = 16, Font = Enum.Font.GothamBold, Parent = controls})
corner(settingsButton, 6) stroke(settingsButton, 0.6, 1)

local hideButton = create("TextButton", {AutoButtonColor = false, BackgroundColor3 = self.Theme.SurfaceRaised, BackgroundTransparency=0.5, Size = UDim2.fromOffset(32, 32), Text = "-", TextColor3 = self.Theme.Muted, TextSize = 18, Font = Enum.Font.GothamBold, Parent = controls})
corner(hideButton, 6) stroke(hideButton, 0.6, 1)

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

local settingsMenu = create("Frame", {AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = self.Theme.SurfaceSoft, BackgroundTransparency=0.1, Position = UDim2.new(1, -18, 0, 60), Size = UDim2.fromOffset(170, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, ZIndex = 15, Parent = clip})
corner(settingsMenu, 8) stroke(settingsMenu, 0.5, 1) padding(settingsMenu, 8, 8)
list(settingsMenu, 6, false)

create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Size = UDim2.new(1, 0, 0, 16), Text = "Tab Position", TextColor3 = self.Theme.Muted, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 16, Parent = settingsMenu})

local resizeHandle = create("TextButton", {AnchorPoint = Vector2.new(1, 1), AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.new(1, -8, 1, -8), Size = UDim2.fromOffset(24, 24), Text = "", Parent = root})
for index = 0, 2 do
    local line = create("Frame", {AnchorPoint = Vector2.new(1, 1), BackgroundColor3 = self.Theme.Muted, BackgroundTransparency = 0.25 + (index * 0.2), Position = UDim2.new(1, -(index * 6), 1, 0), Size = UDim2.fromOffset(12 - (index * 2), 2), Rotation = -45, Parent = resizeHandle})
    corner(line, 999)
end

local mobileToggle = create("ImageButton", {AnchorPoint = Vector2.new(0, 1), AutoButtonColor = false, BackgroundColor3 = self.Theme.SurfaceSoft, Image = normalizeImage(options.MobileToggleIcon or options.Icon), Position = UDim2.new(0, 12, 1, -12), Size = UDim2.fromOffset(56, 56), Visible = false, Parent = screenGui})
corner(mobileToggle, 8) stroke(mobileToggle, 0.4, 1)

local window = setmetatable({
    Library = self, ScreenGui = screenGui, Root = root, PopupLayer = popupLayer, Sidebar = sidebar, Content = content, Pages = pages, TabHolder = tabHolder, FloatingTabs = floatingTabs, FloatingTabsBar = floatingTabsBar, FloatingHolder = floatingHolder,
    TabPosition = options.TabPosition or "Left", Tabs = {}, CurrentTab = nil,
    MinSize = options.MinSize or Vector2.new(420, 340), MaxSize = options.MaxSize or Vector2.new(1200, 900), CurrentSize = options.Size and Vector2.new(options.Size.X.Offset, options.Size.Y.Offset) or Vector2.new(780, 520),
    UserResized = false, Open = true, StoredPosition = options.Position or UDim2.fromScale(0.5, 0.5), ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl, Elements = {}, Flags = {}, PendingConfig = nil, ConfigFolder = options.ConfigFolder or "NullUI", ConfigName = options.ConfigName or name,
    MobileToggle = mobileToggle, TitleLabel = title, SubtitleLabel = subtitle, TitleIcon = titleIcon, SettingsButton = settingsButton, SettingsMenu = settingsMenu, Topbar = topbar, SidebarHeader = sidebarHeader, FloatingLayout = floatingLayout,
    _activePopup = nil, _activePopupAnchor = nil, _popupConnections = {},
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

function window:_collectFlags()
    local data = {}
    for flag, controller in pairs(self.Elements) do if controller and controller.Get then data[flag] = controller:Get() end end
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
        local controller = self.Elements[flag]
        if controller and controller.Set then controller:Set(value, true) end
    end
    self.ConfigName = configName
    if not silent then self.Library:Notify({Title = "Loaded", Content = "Config loaded.", Color = self.Library.Theme.Good}) end
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
                if name and name ~= "_autoload" then
                    names[name] = true
                end
            end
        end
    end
    if not next(names) and Storage.isfile(self:_configFilePath(self.ConfigName)) then
        names[self.ConfigName] = true
    end
    local result = {}
    for name in pairs(names) do
        table.insert(result, name)
    end
    table.sort(result)
    return result
end

function window:RefreshConfigs()
    return self:ListConfigs()
end

function window:GetAutoloadState()
    local data = self:_readJson(self:_autoloadStatePath())
    if type(data) ~= "table" then
        return {Enabled = false, Config = nil}
    end
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

function window:DisableAutoload(silent)
    return self:SetAutoloadConfig(nil, false, silent)
end

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
function window:Destroy() self.ScreenGui:Destroy() end

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
    if not self.FloatingTabs.Visible then return end
    local layoutObject = self.TabHolder and self.TabHolder:FindFirstChildOfClass("UIListLayout")
    local spacing = layoutObject and layoutObject.Padding.Offset or 6
    local totalWidth = 12
    for _, tab in ipairs(self.Tabs) do
        local width = tab.Button.AbsoluteSize.X > 0 and tab.Button.AbsoluteSize.X or tab.Button.Size.X.Offset
        totalWidth = totalWidth + width
    end
    if #self.Tabs > 1 then
        totalWidth = totalWidth + (spacing * (#self.Tabs - 1))
    end
    local barWidth = math.max(200, totalWidth)
    self.FloatingTabs.Size = UDim2.fromOffset(barWidth, 48)
    self.FloatingTabs.Position = self.TabPosition == "Top" and UDim2.new(0.5, 0, 0, -12) or UDim2.new(0.5, 0, 1, 12)
    self.FloatingTabs.AnchorPoint = self.TabPosition == "Top" and Vector2.new(0.5, 1) or Vector2.new(0.5, 0)
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
        self.FloatingTabs.Visible = true
        self.FloatingTabsBar.GroupTransparency = self.Open and 0 or 1
        tabHolder.Position = UDim2.new(0, 0, 0, 0)
        tabHolder.Size = UDim2.new(1, 0, 1, 0)
        tabHolder.Parent = self.FloatingHolder
    end

    local layoutObject = tabHolder:FindFirstChildOfClass("UIListLayout")
    if layoutObject then
        local horizontalTabs = mode == "Bottom" or mode == "Top"
        layoutObject.FillDirection = horizontalTabs and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
        layoutObject.HorizontalAlignment = horizontalTabs and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left
        layoutObject.VerticalAlignment = horizontalTabs and Enum.VerticalAlignment.Center or Enum.VerticalAlignment.Top
    end
    for _, tab in ipairs(self.Tabs) do tab:SetLayout(mode) end
    self:_syncFloatingTabs()
    task.defer(function()
        if not self.Root or not self.Root.Parent then return end
        for _, tab in ipairs(self.Tabs) do tab:SetLayout(mode) end
        self:_syncFloatingTabs()
    end)
    task.delay(0.05, function()
        if not self.Root or not self.Root.Parent then return end
        self:_syncFloatingTabs()
    end)
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
    
    local page = create("ScrollingFrame", {AutomaticCanvasSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(), Position = UDim2.fromOffset(16, 16), ScrollBarThickness = 2, ScrollBarImageColor3 = self.Library.Theme.AccentSoft, Size = UDim2.new(1, -32, 1, -32), Visible = false, Parent = pages})
    list(page, 10, false)

    local tab = setmetatable({Window = self, Button = button, Frame = frame, Label = label, Description = descriptionLabel, ActiveLine = activeLine, IconWrap = iconWrap, ImageLabel = imageLabel, GlyphLabel = glyphLabel, Page = page}, Tab)
    table.insert(self.Tabs, tab)
    tab:SetLayout(self.TabPosition)

    button.MouseButton1Click:Connect(function() self:SelectTab(tab) end)
    if not self.CurrentTab then self:SelectTab(tab, true) end
    return tab
end

function window:SelectTab(targetTab, instant)
    if self.CurrentTab == targetTab then return end
    self.CurrentTab = targetTab
    for _, tab in ipairs(self.Tabs) do
        local active = tab == targetTab
        tab.Page.Visible = active and true or false
        tween(tab.Frame, {BackgroundTransparency = 1}, instant and 0 or 0.2)
        tween(tab.IconWrap, {BackgroundTransparency = 1}, instant and 0 or 0.2)
        tween(tab.ActiveLine, {BackgroundTransparency = active and 0 or 1, Size = active and UDim2.fromOffset(20, 2) or UDim2.fromOffset(10, 2)}, instant and 0 or 0.2)
        tab.Label.TextColor3 = active and self.Library.Theme.Text or self.Library.Theme.Muted
        tab.GlyphLabel.TextColor3 = active and self.Library.Theme.AccentSoft or self.Library.Theme.Text
        tab.ImageLabel.ImageColor3 = active and self.Library.Theme.AccentSoft or self.Library.Theme.Text
        if active then
            tab.Page.Position = UDim2.fromOffset(32, 16)
            tween(tab.Page, {Position = UDim2.fromOffset(16, 16)}, instant and 0 or 0.3, Enum.EasingStyle.Exponential)
        end
    end
end

local tabPositionChoices = {{Label = "Left", Value = "Left"}, {Label = "Right", Value = "Right"}, {Label = "Bottom", Value = "Bottom"}, {Label = "Top", Value = "Top"}}
for _, choice in ipairs(tabPositionChoices) do
    local optionButton = create("TextButton", {AutoButtonColor = false, BackgroundColor3 = self.Theme.SurfaceRaised, BackgroundTransparency=0.5, Size = UDim2.new(1, 0, 0, 32), Text = "", ZIndex = 16, Parent = settingsMenu})
    corner(optionButton, 6)
    create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0), Text = choice.Label, TextColor3 = self.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 17, Parent = optionButton})
    optionButton.MouseButton1Click:Connect(function() settingsMenu.Visible = false window:_layoutChrome(choice.Value) end)
end

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
    if window.TabPosition == "Top" or window.TabPosition == "Bottom" then
        window:_syncFloatingTabs()
    end
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

window:LoadAutoload(true)
window:_applyRootSize()
window:_setOpen(true, false)
if options.WelcomeNotification ~= false then task.delay(0.08, function() window:Notify({Title = options.Title or "Null", Content = "UI launched successfully.", Icon = options.Icon, Duration = 3, Color = self.Theme.Good}) end) end
return window

end

return NullLibrary
