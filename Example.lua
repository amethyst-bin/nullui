local NullLib = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ginzuss/nullui/refs/heads/main/NullUI.lua"))()

local Window = NullLib:CreateWindow({
    Name = "NullUI_Example",
    Title = "Null",
    Subtitle = "minimal smooth utility ui",
    BadgeText = "BETA",
    Icon = "rbxassetid://7733658504",
    ToggleKey = Enum.KeyCode.RightControl,
    ConfigFolder = "NullUI",
    ConfigName = "ExampleConfig",
    TabPosition = "Left",
    WelcomeNotification = true
})

local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "lucide:home",
    Description = "core controls"
})

local MediaTab = Window:CreateTab({
    Name = "Media",
    Icon = "lucide:image",
    Description = "images and style"
})

local ConfigTab = Window:CreateTab({
    Name = "Configs",
    Icon = "lucide:settings-2",
    Description = "save and autoload"
})

local MainSection = MainTab:CreateSection({
    Title = "Starter Controls",
    Description = "Пример новой версии NullUI с анимациями, адаптивом, уведомлениями и конфигами."
})

MainSection:AddParagraph(
    "NullUI",
    "Теперь UI без затемнения, с более строгим минималистичным дизайном, отдельным popup dropdown и встроенным выбором позиции вкладок."
)

MainSection:AddButton({
    Text = "Show Notification",
    Icon = "rbxassetid://7733658504",
    Callback = function()
        Window:Notify({
            Title = "NullUI",
            Content = "Уведомления теперь адаптивные и нормально выглядят и на телефоне, и на ПК.",
            Icon = "rbxassetid://7733658504",
            Duration = 4
        })
    end
})

local AutoFarm = MainSection:AddToggle({
    Text = "Auto Farm",
    Description = "Пример тумблера с сохранением в конфиг.",
    Flag = "AutoFarm",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
    end
})

local WalkSpeed = MainSection:AddSlider({
    Text = "WalkSpeed",
    Flag = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 32,
    Callback = function(value)
        print("WalkSpeed:", value)
    end
})

local Nickname = MainSection:AddTextbox({
    Placeholder = "Nickname / key / text",
    Flag = "Nickname",
    Default = "Null User",
    Callback = function(text)
        print("Textbox:", text)
    end
})

local Mode = MainSection:AddDropdown({
    Text = "Target Mode",
    Flag = "TargetMode",
    Values = {"Closest", "Random", "Low HP", "Behind Wall"},
    Default = "Closest",
    Callback = function(value)
        print("Mode:", value)
    end
})

local MediaSection = MediaTab:CreateSection({
    Title = "Images",
    Description = "Можно ставить картинки в табы, в шапку окна и как отдельные элементы внутри секций."
})

MediaSection:AddImage({
    Image = "https://i.pinimg.com/736x/29/a0/99/29a099ff1e87f0acf4de1705a751c9d4.jpg",
    Height = 150,
    Caption = "Пример картинки по прямой ссылке."
})

MediaSection:AddImage({
    ID = 7206946128,
    Height = 120,
    Caption = "Пример картинки по Roblox asset id."
})

MediaSection:AddButton({
    Text = "Change Header Icon",
    Callback = function()
        Window:SetTitle("Null", "rbxassetid://7733779610")
        Window:Notify({
            Title = "Header Updated",
            Content = "Иконка возле названия окна обновлена.",
            Icon = "rbxassetid://7733779610"
        })
    end
})

MediaSection:AddButton({
    Text = "Test Set Methods",
    Callback = function()
        AutoFarm:Set(true)
        WalkSpeed:Set(75)
        Nickname:Set("Loaded Name")
        Mode:Set("Low HP")
    end
})

local ConfigSection = ConfigTab:CreateSection({
    Title = "Configs",
    Description = "Сохраняй, загружай и включай автозагрузку конфига."
})

ConfigSection:AddButton({
    Text = "Save Config",
    Callback = function()
        Window:SaveConfig("ExampleConfig")
    end
})

ConfigSection:AddButton({
    Text = "Load Config",
    Callback = function()
        Window:LoadConfig("ExampleConfig")
    end
})

ConfigSection:AddButton({
    Text = "Enable Auto Load",
    Callback = function()
        Window:EnableAutoLoad("ExampleConfig")
    end
})

ConfigSection:AddButton({
    Text = "Disable Auto Load",
    Callback = function()
        Window:DisableAutoLoad()
    end
})

ConfigSection:AddButton({
    Text = "Print Config Names",
    Callback = function()
        print("Configs:", table.concat(Window:ListConfigs(), ", "))
    end
})
