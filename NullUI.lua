local NullLibrary = {
    Theme = {
        Background = Color3.fromRGB(10, 13, 20),
        Surface = Color3.fromRGB(16, 20, 30),
        Surface2 = Color3.fromRGB(22, 27, 40),
        Surface3 = Color3.fromRGB(29, 36, 52),
        Accent = Color3.fromRGB(0, 200, 255),
        Accent2 = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(241, 247, 255),
        Muted = Color3.fromRGB(144, 154, 180),
        Stroke = Color3.fromRGB(54, 65, 92),
    }
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local function new(className, props)
    local object = Instance.new(className)
    props = props or {}

    for key, value in pairs(props) do
        if key ~= "Parent" then
            object[key] = value
        end
    end

    object.Parent = props.Parent
    return object
end

local function corner(parent, radius)
    new("UICorner", {CornerRadius = UDim.new(0, radius), Parent = parent})
end

local function outline(parent, transparency)
    new("UIStroke", {
        Color = NullLibrary.Theme.Stroke,
        Transparency = transparency or 0,
        Parent = parent
    })
end

local function glow(parent, rotation)
    new("UIGradient", {
        Rotation = rotation or 0,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, NullLibrary.Theme.Accent),
            ColorSequenceKeypoint.new(1, NullLibrary.Theme.Accent2),
        }),
        Parent = parent
    })
end

local function pad(parent, x, y)
    new("UIPadding", {
        PaddingLeft = UDim.new(0, x),
        PaddingRight = UDim.new(0, x),
        PaddingTop = UDim.new(0, y),
        PaddingBottom = UDim.new(0, y),
        Parent = parent
    })
end

local function tween(object, properties, duration)
    TweenService:Create(
        object,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    ):Play()
end

local function dragify(handle, target)
    local dragging = false
    local dragStart
    local startPosition

    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        dragging = true
        dragStart = input.Position
        startPosition = target.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local delta = input.Position - dragStart
        target.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end)
end

function NullLibrary:CreateWindow(options)
    options = options or {}

    local gui = new("ScreenGui", {
        Name = options.Name or ("NullUI_" .. HttpService:GenerateGUID(false)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = PlayerGui
    })

    local root = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Theme.Background,
        Position = options.Position or UDim2.fromScale(0.5, 0.5),
        Size = options.Size or UDim2.fromOffset(700, 470),
        Parent = gui
    })
    corner(root, 24)
    outline(root, 0.15)

    local decor = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Theme.Accent,
        BackgroundTransparency = 0.85,
        Position = UDim2.fromScale(0.15, 0.1),
        Size = UDim2.fromOffset(220, 220),
        Parent = root
    })
    corner(decor, 999)

    local topbar = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 80),
        Parent = root
    })
    pad(topbar, 22, 18)

    local title = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBlack,
        Size = UDim2.new(1, -110, 0, 28),
        Text = options.Title or "Null",
        TextColor3 = self.Theme.Text,
        TextSize = 28,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar
    })

    local subtitle = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Position = UDim2.fromOffset(0, 30),
        Size = UDim2.new(1, -110, 0, 18),
        Text = options.Subtitle or "clean utility interface",
        TextColor3 = self.Theme.Muted,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar
    })

    local badge = new("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = self.Theme.Surface2,
        Position = UDim2.new(1, -22, 0, 18),
        Size = UDim2.fromOffset(96, 34),
        Parent = root
    })
    corner(badge, 14)
    outline(badge, 0.1)
    glow(badge, 0)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Size = UDim2.fromScale(1, 1),
        Text = options.BadgeText or "NULL UI",
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Parent = badge
    })

    local sidebar = new("Frame", {
        BackgroundColor3 = self.Theme.Surface,
        Position = UDim2.fromOffset(18, 92),
        Size = UDim2.new(0, 176, 1, -110),
        Parent = root
    })
    corner(sidebar, 22)
    outline(sidebar, 0.2)
    pad(sidebar, 12, 12)

    local sidebarList = new("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sidebar
    })

    local content = new("Frame", {
        BackgroundColor3 = self.Theme.Surface,
        Position = UDim2.fromOffset(206, 92),
        Size = UDim2.new(1, -224, 1, -110),
        Parent = root
    })
    corner(content, 22)
    outline(content, 0.2)

    local pages = new("Folder", {Name = "Pages", Parent = content})

    dragify(topbar, root)

    local window = setmetatable({
        Gui = gui,
        Root = root,
        Tabs = {},
        CurrentTab = nil,
        Content = content,
        Pages = pages,
        SidebarList = sidebarList,
    }, Window)

    function window:SelectTab(tab)
        if self.CurrentTab == tab then
            return
        end

        for _, object in ipairs(self.Tabs) do
            local active = object == tab
            object.Page.Visible = active
            tween(object.ButtonFrame, {
                BackgroundColor3 = active and NullLibrary.Theme.Surface3 or NullLibrary.Theme.Surface2
            })
            object.Label.TextColor3 = active and NullLibrary.Theme.Text or NullLibrary.Theme.Muted
            object.Bar.BackgroundTransparency = active and 0 or 1
        end

        self.CurrentTab = tab
    end

    function window:Toggle()
        self.Gui.Enabled = not self.Gui.Enabled
    end

    function window:Destroy()
        self.Gui:Destroy()
    end

    function window:CreateTab(name, icon)
        local button = new("TextButton", {
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            Text = "",
            Parent = sidebar
        })

        local frame = new("Frame", {
            BackgroundColor3 = NullLibrary.Theme.Surface2,
            Size = UDim2.fromScale(1, 1),
            Parent = button
        })
        corner(frame, 15)
        outline(frame, 0.18)

        local bar = new("Frame", {
            BackgroundColor3 = NullLibrary.Theme.Accent,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(4, 48),
            Parent = frame
        })
        corner(bar, 999)
        glow(bar, 90)

        new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Position = UDim2.fromOffset(16, 0),
            Size = UDim2.fromOffset(20, 48),
            Text = icon or "•",
            TextColor3 = NullLibrary.Theme.Text,
            TextSize = 17,
            Parent = frame
        })

        local label = new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Position = UDim2.fromOffset(46, 0),
            Size = UDim2.new(1, -54, 1, 0),
            Text = name or "Tab",
            TextColor3 = NullLibrary.Theme.Muted,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })

        local page = new("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(),
            Position = UDim2.fromOffset(16, 16),
            ScrollBarImageColor3 = NullLibrary.Theme.Accent,
            ScrollBarThickness = 3,
            Size = UDim2.new(1, -32, 1, -32),
            Visible = false,
            Parent = pages
        })

        new("UIListLayout", {
            Padding = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = page
        })

        local tab = setmetatable({
            Button = button,
            ButtonFrame = frame,
            Bar = bar,
            Label = label,
            Page = page
        }, Tab)

        table.insert(window.Tabs, tab)
        button.MouseButton1Click:Connect(function()
            window:SelectTab(tab)
        end)

        if not window.CurrentTab then
            window:SelectTab(tab)
        end

        return tab
    end

    UIS.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == (options.ToggleKey or Enum.KeyCode.RightControl) then
            window:Toggle()
        end
    end)

    return window
end

function Tab:CreateSection(titleText, descriptionText)
    local card = new("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = NullLibrary.Theme.Surface2,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = self.Page
    })
    corner(card, 18)
    outline(card, 0.15)
    pad(card, 16, 16)

    new("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 0),
        Text = titleText or "Section",
        TextColor3 = NullLibrary.Theme.Text,
        TextSize = 17,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card
    })

    local hasDescription = descriptionText and descriptionText ~= ""
    if hasDescription then
        new("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Position = UDim2.fromOffset(0, 28),
            Size = UDim2.new(1, 0, 0, 0),
            Text = descriptionText,
            TextColor3 = NullLibrary.Theme.Muted,
            TextSize = 13,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = card
        })
    end

    local holder = new("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, hasDescription and 64 or 36),
        Size = UDim2.new(1, 0, 0, 0),
        Parent = card
    })

    new("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = holder
    })

    local section = {}

    function section:AddLabel(text)
        return new("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Size = UDim2.new(1, 0, 0, 0),
            Text = text or "Label",
            TextColor3 = NullLibrary.Theme.Muted,
            TextSize = 13,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = holder
        })
    end

    function section:AddParagraph(head, body)
        local box = new("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = NullLibrary.Theme.Surface3,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = holder
        })
        corner(box, 14)
        pad(box, 14, 12)

        new("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Size = UDim2.new(1, 0, 0, 0),
            Text = head or "Info",
            TextColor3 = NullLibrary.Theme.Text,
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = box
        })

        new("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Position = UDim2.fromOffset(0, 22),
            Size = UDim2.new(1, 0, 0, 0),
            Text = body or "",
            TextColor3 = NullLibrary.Theme.Muted,
            TextSize = 13,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = box
        })

        return box
    end

    function section:AddButton(options)
        options = options or {}

        local button = new("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = NullLibrary.Theme.Surface3,
            Size = UDim2.new(1, 0, 0, 42),
            Text = "",
            Parent = holder
        })
        corner(button, 12)
        outline(button, 0.18)

        new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Position = UDim2.fromOffset(14, 0),
            Size = UDim2.new(1, -28, 1, 0),
            Text = options.Text or "Button",
            TextColor3 = NullLibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = button
        })

        button.MouseEnter:Connect(function()
            tween(button, {BackgroundColor3 = NullLibrary.Theme.Surface2}, 0.15)
        end)

        button.MouseLeave:Connect(function()
            tween(button, {BackgroundColor3 = NullLibrary.Theme.Surface3}, 0.15)
        end)

        button.MouseButton1Click:Connect(function()
            if options.Callback then
                task.spawn(options.Callback)
            end
        end)

        return button
    end

    function section:AddToggle(options)
        options = options or {}
        local state = options.Default or false

        local button = new("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = NullLibrary.Theme.Surface3,
            Size = UDim2.new(1, 0, 0, 46),
            Text = "",
            Parent = holder
        })
        corner(button, 12)
        outline(button, 0.18)

        new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Position = UDim2.fromOffset(14, 7),
            Size = UDim2.new(1, -84, 0, 16),
            Text = options.Text or "Toggle",
            TextColor3 = NullLibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = button
        })

        new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Position = UDim2.fromOffset(14, 23),
            Size = UDim2.new(1, -84, 0, 14),
            Text = options.Description or "",
            TextColor3 = NullLibrary.Theme.Muted,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = options.Description ~= nil and options.Description ~= "",
            Parent = button
        })

        local track = new("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = state and NullLibrary.Theme.Accent or NullLibrary.Theme.Surface2,
            Position = UDim2.new(1, -14, 0.5, 0),
            Size = UDim2.fromOffset(46, 24),
            Parent = button
        })
        corner(track, 999)

        local knob = new("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Position = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.fromOffset(20, 20),
            Parent = track
        })
        corner(knob, 999)

        local function setState(value, skipCallback)
            state = value
            tween(track, {BackgroundColor3 = state and NullLibrary.Theme.Accent or NullLibrary.Theme.Surface2}, 0.18)
            tween(knob, {Position = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.18)

            if not skipCallback and options.Callback then
                task.spawn(options.Callback, state)
            end
        end

        button.MouseButton1Click:Connect(function()
            setState(not state)
        end)

        setState(state, true)

        return {
            Set = setState,
            Get = function()
                return state
            end
        }
    end

    function section:AddSlider(options)
        options = options or {}
        local min = options.Min or 0
        local max = options.Max or 100
        local value = math.clamp(options.Default or min, min, max)
        local dragging = false

        local frame = new("Frame", {
            BackgroundColor3 = NullLibrary.Theme.Surface3,
            Size = UDim2.new(1, 0, 0, 62),
            Parent = holder
        })
        corner(frame, 12)
        outline(frame, 0.18)

        new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Position = UDim2.fromOffset(14, 10),
            Size = UDim2.new(1, -80, 0, 16),
            Text = options.Text or "Slider",
            TextColor3 = NullLibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })

        local number = new("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Position = UDim2.new(1, -14, 0, 10),
            Size = UDim2.fromOffset(60, 16),
            Text = tostring(value),
            TextColor3 = NullLibrary.Theme.Accent,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = frame
        })

        local track = new("Frame", {
            BackgroundColor3 = NullLibrary.Theme.Surface2,
            Position = UDim2.fromOffset(14, 40),
            Size = UDim2.new(1, -28, 0, 8),
            Parent = frame
        })
        corner(track, 999)

        local fill = new("Frame", {
            BackgroundColor3 = NullLibrary.Theme.Accent,
            Size = UDim2.new(0, 0, 1, 0),
            Parent = track
        })
        corner(fill, 999)
        glow(fill, 0)

        local knob = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.fromOffset(16, 16),
            Parent = track
        })
        corner(knob, 999)

        local function setValue(newValue, skipCallback)
            value = math.clamp(math.floor(newValue + 0.5), min, max)
            local alpha = (value - min) / math.max(max - min, 1)
            fill.Size = UDim2.new(alpha, 0, 1, 0)
            knob.Position = UDim2.new(alpha, 0, 0.5, 0)
            number.Text = tostring(value)

            if not skipCallback and options.Callback then
                task.spawn(options.Callback, value)
            end
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                setValue(min + (max - min) * ((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X))
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                setValue(min + (max - min) * ((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X))
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        setValue(value, true)

        return {
            Set = setValue,
            Get = function()
                return value
            end
        }
    end

    function section:AddTextbox(options)
        options = options or {}

        local frame = new("Frame", {
            BackgroundColor3 = NullLibrary.Theme.Surface3,
            Size = UDim2.new(1, 0, 0, 46),
            Parent = holder
        })
        corner(frame, 12)
        outline(frame, 0.18)

        local box = new("TextBox", {
            BackgroundTransparency = 1,
            ClearTextOnFocus = false,
            Font = Enum.Font.GothamSemibold,
            PlaceholderColor3 = NullLibrary.Theme.Muted,
            PlaceholderText = options.Placeholder or "Type here...",
            Position = UDim2.fromOffset(14, 0),
            Size = UDim2.new(1, -28, 1, 0),
            Text = options.Default or "",
            TextColor3 = NullLibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })

        box.FocusLost:Connect(function(enterPressed)
            if options.Callback then
                task.spawn(options.Callback, box.Text, enterPressed)
            end
        end)

        return box
    end

    function section:AddDropdown(options)
        options = options or {}
        local values = options.Values or {}
        local value = options.Default or values[1] or "None"
        local opened = false

        local wrap = new("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = holder
        })

        local button = new("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = NullLibrary.Theme.Surface3,
            Size = UDim2.new(1, 0, 0, 42),
            Text = "",
            Parent = wrap
        })
        corner(button, 12)
        outline(button, 0.18)

        local label = new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Position = UDim2.fromOffset(14, 0),
            Size = UDim2.new(1, -44, 1, 0),
            Text = string.format("%s: %s", options.Text or "Dropdown", tostring(value)),
            TextColor3 = NullLibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = button
        })

        local arrow = new("TextLabel", {
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

        local list = new("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = NullLibrary.Theme.Surface2,
            Position = UDim2.fromOffset(0, 50),
            Size = UDim2.new(1, 0, 0, 0),
            Visible = false,
            Parent = wrap
        })
        corner(list, 12)
        outline(list, 0.18)
        pad(list, 8, 8)

        new("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = list
        })

        local function setSelected(newValue, skipCallback)
            value = newValue
            label.Text = string.format("%s: %s", options.Text or "Dropdown", tostring(value))

            if not skipCallback and options.Callback then
                task.spawn(options.Callback, value)
            end
        end

        for _, entry in ipairs(values) do
            local option = new("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = NullLibrary.Theme.Surface3,
                Size = UDim2.new(1, 0, 0, 34),
                Text = "",
                Parent = list
            })
            corner(option, 10)

            new("TextLabel", {
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
                setSelected(entry)
                opened = false
                list.Visible = false
                arrow.Text = "v"
            end)
        end

        button.MouseButton1Click:Connect(function()
            opened = not opened
            list.Visible = opened
            arrow.Text = opened and "^" or "v"
        end)

        setSelected(value, true)

        return {
            Set = setSelected,
            Get = function()
                return value
            end
        }
    end

    return section
end

return NullLibrary
