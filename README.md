# Null UI

A sleek, modern glassmorphism UI library for Roblox. Designed for performance, ease of use, and full customization.

## Key Features
* **Glassmorphism Design:** Translucent surfaces with blur-like effects.
* **Theme System:** 10+ built-in presets (Arctic, Sunset, Midnight, etc.) and custom theme registration.
* **Lucide Icons:** Integrated support for `Icon = "house" -- just type icon name here`.
* **Config System:** Built-in Save/Load functionality with JSON and Autoload support.
* **Adaptive Layouts:** Move tabs to Top, Bottom, Left, or Right dynamically.
* **Mobile Ready:** Responsive scaling and specialized touch-friendly toggles.

---

## Example Script with All Features

```lua
local NullLib = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ginzuss/nullui/refs/heads/main/NullUI.lua"))()

local Window = NullLib:CreateWindow({
    Name = "NullUI",
    Title = "Null UI",
    Subtitle = "yomkamadeit",
    BadgeText = "v4.7",
    Icon = "https://i.postimg.cc/QxPqrLGq/image-Photoroom.png", -- u can change it
    WatermarkIcon = "https://i.postimg.cc/QxPqrLGq/image-Photoroom.png", -- u can change it too lol
    ToggleKey = Enum.KeyCode.B,
    ConfigFolder = "NullUI",
    ConfigName = "ExampleConfig",
    TabPosition = "Bottom",
    WelcomeNotification = true
})


local RS = game:GetService("RunService")
local Player = game:GetService("Players").LocalPlayer
local fps = 60
RS.RenderStepped:Connect(function(deltaTime)
    fps = math.floor(1 / deltaTime)
    -- You can change the text, or you can use text + a new image: Window:SetWatermark("text", "link")
    Window:SetWatermark(string.format("YomkaWasHere | User: %s | FPS: %d", Player.Name, fps))
end)

local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "house",
    Description = "Some main things"
})

local MediaTab = Window:CreateTab({
    Name = "Media",
    Icon = "image",
    Description = "Some media things"
})

local ConfigTab = Window:CreateTab({
    Name = "Configs",
    Icon = "settings-2",
    Description = "Some config things"
})

local LeftSection = MainTab:CreateSection({
    Title = "Mazafaka",
    Description = "blah blah blah",
    Side = "Left" -- choose side here Left or Right
})

LeftSection:AddParagraph("Test text yomkayomkayomkayomka")

LeftSection:AddButton({
    Text = "Show Notification",
    Icon = "check-circle",
    Callback = function()
        Window:Notify({
            Title = "Success!",
            Content = "Yay!",
            Icon = "check",
            Duration = 4,
            Color = NullLib.Theme.Good
        })
    end
})

local WalkSpeed = LeftSection:AddSlider({
    Text = "WalkSpeed",
    Flag = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 32,
    Callback = function(value)
        print("WalkSpeed:", value)
    end
})

local RightSection = MainTab:CreateSection({
    Title = "ajghwshbhbvergvefe",
    Description = "blah blah blah",
    Side = "Right"
})

local AutoFarm = RightSection:AddToggle({
    Text = "Auto Farm",
    Description = "just a toggle lol",
    Flag = "AutoFarm",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
    end
})

local EspEnabled = RightSection:AddToggle({
    Text = "Enable ESP",
    Description = "example toggle for visual color",
    Flag = "EnableESP",
    Default = true,
    Callback = function(state)
        print("ESP Enabled:", state)
    end
})

local EspColor = RightSection:AddColorPicker({
    Text = "ESP Color",
    Flag = "ESPColor",
    DefaultColor = Color3.fromRGB(255, 90, 90),
    DefaultAlpha = 0.85,
    Callback = function(color, alpha)
        print("ESP Color:", color, "Alpha:", alpha)
    end
})

local EspKeybind = RightSection:AddKeybind({
    Text = "ESP Keybind",
    Flag = "ESPKeybind",
    DefaultKey = Enum.KeyCode.H,
    Mode = "Toggle",
    DefaultState = false,
    Callback = function(isEnabled, keyCode, mode)
        print("ESP Keybind:", isEnabled, keyCode and keyCode.Name or "Unknown", mode)
    end
})

local Mode = RightSection:AddDropdown({
    Text = "Target Mode",
    Flag = "TargetMode",
    Values = {"Closest", "Random", "Low HP", "Behind Wall"},
    Default = "Closest",
    Callback = function(value)
        print("Mode:", value)
    end
})

local Nickname = RightSection:AddTextbox({
    Placeholder = "Target Nickname...",
    Flag = "TargetNick",
    Default = "Yomka",
    Callback = function(text)
        print("Textbox:", text)
    end
})

local MediaSection = MediaTab:CreateSection({
    Title = "Images & Visuals",
    Description = "sup broski",
    Side = "Left"
})

MediaSection:AddImage({
    Image = "https://i.pinimg.com/736x/53/22/cc/5322cc580a42baaa36a7d76d721339c7.jpg",
    Height = 200,
    ScaleType = Enum.ScaleType.Crop, 
    Caption = "yomkawashere"
})

local ConfigSection = ConfigTab:CreateSection({
    Title = "Configs Manager",
    Description = "Configs Stuff Here",
    Side = "Left"
})

local ThemeSection = ConfigTab:CreateSection({
    Title = "Themes",
    Description = "Pick a style preset",
    Side = "Right"
})

local RawThemeNames = NullLib:ListThemes()
local ThemeDisplayToRaw = {}
local ThemeNames = {}
for _, rawName in ipairs(RawThemeNames) do
    local displayName = rawName == "Null" and "Null (Default)" or rawName
    ThemeDisplayToRaw[displayName] = rawName
    table.insert(ThemeNames, displayName)
end

local ThemeDropdown = ThemeSection:AddDropdown({
    Text = "Theme",
    Flag = "ThemePreset",
    Values = ThemeNames,
    Default = "Null (Default)",
    Callback = function(value)
        print("Theme selected:", tostring(value))
    end
})

ThemeSection:AddButton({
    Text = "Apply Theme",
    Icon = "palette",
    Callback = function()
        local selectedDisplay = tostring(ThemeDropdown:Get() or "Null (Default)")
        local rawName = ThemeDisplayToRaw[selectedDisplay] or "Null"
        Window:SetThemeByName(rawName)
    end
})

local ConfigNameBox = ConfigSection:AddTextbox({
    Placeholder = "Config name...",
    Flag = "ConfigNameInput",
    Default = Window.ConfigName or "ExampleConfig",
    Callback = function(text)
        local name = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if name ~= "" then
            Window.ConfigName = name
        end
    end
})

local function getCurrentConfigName()
    local typed = tostring(ConfigNameBox:Get() or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if typed ~= "" then Window.ConfigName = typed end
    return Window.ConfigName
end

ConfigSection:AddButton({
    Text = "Save Config",
    Icon = "save",
    Callback = function()
        Window:SaveConfig(getCurrentConfigName())
    end
})

ConfigSection:AddButton({
    Text = "Load Config",
    Icon = "download",
    Callback = function()
        Window:LoadConfig(getCurrentConfigName())
    end
})

local function getConfigValues()
    local configs = Window:RefreshConfigs()
    if #configs == 0 then configs = {"None"} end
    return configs
end

local ConfigList = ConfigSection:AddDropdown({
    Text = "Config List",
    Flag = "ConfigList",
    Values = getConfigValues(),
    Default = Window.ConfigName or getConfigValues()[1],
    Callback = function(value)
        if tostring(value) == "None" then return end
        Window.ConfigName = tostring(value)
        ConfigNameBox:Set(Window.ConfigName, true)
    end
})

local function refreshConfigList(keepSelection)
    ConfigList:SetValues(getConfigValues(), keepSelection ~= false)
end

ConfigSection:AddButton({
    Text = "Refresh Configs",
    Icon = "rotate-cw",
    Callback = function()
        refreshConfigList(true)
        Window:Notify({
            Title = "Configs",
            Content = "Updated!",
            Icon = "refresh-cw",
            Color = NullLib.Theme.AccentSoft
        })
    end
})

local refreshAutoloadStatus

ConfigSection:AddButton({
    Text = "Enable Autoload",
    Icon = "power",
    Callback = function()
        Window:SetAutoloadConfig(Window.ConfigName, true)
        if refreshAutoloadStatus then refreshAutoloadStatus() end
    end
})

ConfigSection:AddButton({
    Text = "Delete Selected Config",
    Icon = "trash-2",
    Callback = function()
        local selected = tostring(ConfigList:Get() or Window.ConfigName or "")
        selected = selected:gsub("^%s+", ""):gsub("%s+$", "")
        if selected == "" or selected == "None" then
            Window:Notify({
                Title = "Configs",
                Content = "No config selected.",
                Icon = "alert-circle",
                Color = NullLib.Theme.Bad
            })
            return
        end

        local ok = Window:DeleteConfig(selected)
        if ok then
            refreshConfigList(false)
            local values = getConfigValues()
            local nextName = values[1] and values[1] ~= "None" and values[1] or selected
            Window.ConfigName = nextName
            ConfigNameBox:Set(nextName, true)
            refreshAutoloadStatus()
        end
    end
})

local AutoloadStatusLabel = ConfigSection:AddLabel("")

refreshAutoloadStatus = function()
    local state = Window:GetAutoloadState()
    local configName = state.Config or "none"
    if state.Enabled and state.Config then
        AutoloadStatusLabel.Text = "Will autoload: " .. configName
    else
        AutoloadStatusLabel.Text = "Will autoload: none"
    end
end

ConfigSection:AddButton({
    Text = "Disable Autoload",
    Icon = "power-off",
    Callback = function()
        Window:DisableAutoload()
        refreshAutoloadStatus()
    end
})

refreshAutoloadStatus()
```

---

## Components

### Window Methods
* `Window:Toggle(bool)` - Show/Hide the UI.
* `Window:SetThemeByName(string)` - Change theme on the fly.
* `Window:Notify(options)` - Push a notification.
* `Window:SaveConfig(name)` - Save current flags to a file.
* `Window:LoadConfig(name)` - Load settings from a file.

### Section Elements
* **Label / Paragraph:** Simple text display.
* **Button:** Standard clickable action.
* **Toggle:** Boolean switch (saves to flag).
* **Slider:** Just a Slider lol.
* **Textbox:** String input.
* **Dropdown:** Selectable list of options.
* **ColorPicker:** Full RGBA support (saves as table/Hex).
* **Image:** Displays local assets, rbxassetids, or URLs.
* **KeyBind:** U can change key for anything.

---

## Themes
Available presets: `Null`, `Arctic`, `Ember`, `Forest`, `Sunset`, `Midnight`, `Mint`, `Snow`, `Blackout`, `Yoxi`.

---

## Icon Support
Use `icon-name` for any icon parameter. You can find icon names at [lucide.dev](https://lucide.dev/icons/). Example: `"shield"`, `"user"`.
