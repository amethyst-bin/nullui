local NullLib = loadstring(game:HttpGetAsync("TTU_LINK_HERE"))()

local Window = NullLib:CreateWindow({
    Name = "NullUI_Example",
    Title = "Null",
    Subtitle = "slick roblox interface demo",
    BadgeText = "BETA",
    ToggleKey = Enum.KeyCode.RightControl
})

local MainTab = Window:CreateTab("Main", "N")
local VisualTab = Window:CreateTab("Visuals", "V")

local MainSection = MainTab:CreateSection("Starter Controls", "Базовый пример того, как будет выглядеть и работать твой UI.")

MainSection:AddParagraph(
    "NullUI",
    "Загружается через loadstring(game:HttpGetAsync(...))() и возвращает библиотеку в конце файла через return NullLibrary."
)

MainSection:AddButton({
    Text = "Print Hello",
    Callback = function()
        print("NullUI says hello")
    end
})

local Toggle = MainSection:AddToggle({
    Text = "Auto Farm",
    Description = "Пример тумблера с callback",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
    end
})

local Slider = MainSection:AddSlider({
    Text = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 32,
    Callback = function(value)
        print("WalkSpeed value:", value)
    end
})

MainSection:AddTextbox({
    Placeholder = "Nickname / key / text",
    Callback = function(text, enterPressed)
        print("Textbox:", text, "Enter:", enterPressed)
    end
})

MainSection:AddDropdown({
    Text = "Target Mode",
    Values = {"Closest", "Random", "Low HP", "Behind Wall"},
    Default = "Closest",
    Callback = function(value)
        print("Selected mode:", value)
    end
})

local VisualSection = VisualTab:CreateSection("Visual Settings", "Ещё один таб для демонстрации структуры.")

VisualSection:AddLabel("Нажми RightControl, чтобы скрыть или показать окно.")

VisualSection:AddButton({
    Text = "Set Toggle True",
    Callback = function()
        Toggle:Set(true)
    end
})

VisualSection:AddButton({
    Text = "Set Slider 75",
    Callback = function()
        Slider:Set(75)
    end
})

VisualSection:AddParagraph(
    "GitHub Ready",
    "Можешь закинуть NullUI.lua в репозиторий и подставить raw-ссылку в Example.lua вместо TTU_LINK_HERE."
)
