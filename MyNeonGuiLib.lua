local MyGuiLib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Настройка цветовой палитры под твой скриншот
local Themes = {
    Dark = {
        Background = Color3.fromRGB(15, 22, 28),
        SidebarBg = Color3.fromRGB(12, 18, 23),
        ElementBg = Color3.fromRGB(20, 28, 35),
        Accent = Color3.fromRGB(0, 230, 255),
        Text = Color3.fromRGB(255, 255, 255),
        SecondaryText = Color3.fromRGB(140, 160, 170)
    }
}

function MyGuiLib:CreateWindow(Config)
    local TitleText = Config.Title or "Premium Panel"
    local SubTitleText = Config.SubTitle or "v1.0"
    local Size = Config.Size or UDim2.fromOffset(580, 480)
    local SelectedTheme = Themes[Config.Theme] or Themes.Dark

    -- Удаление старой копии при перезапуске
    if CoreGui:FindFirstChild("MyCustomNeonUI") then
        CoreGui:FindFirstChild("MyCustomNeonUI"):Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MyCustomNeonUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false

    -- Главное Окно панели
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Size
    MainFrame.Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2)
    MainFrame.BackgroundColor3 = SelectedTheme.Background
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    -- Свечение границ (Неоновый Циан)
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.Color = SelectedTheme.Accent
    UIStroke.Transparency = 0.3
    UIStroke.Parent = MainFrame

    -- Хедер / Шапка (Драг-зона)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Text = TitleText
    Title.TextColor3 = SelectedTheme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = Header

    local SubTitle = Instance.new("TextLabel")
    SubTitle.Size = UDim2.new(0.4, 0, 1, 0)
    SubTitle.Position = UDim2.new(1, -15, 0, 0)
    SubTitle.Text = SubTitleText
    SubTitle.TextColor3 = SelectedTheme.Accent
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.TextSize = 13
    SubTitle.TextXAlignment = Enum.TextXAlignment.Right
    SubTitle.BackgroundTransparency = 1
    SubTitle.Parent = Header

    -- Сайдбар для Вкладок
    local Sidebar = Instance.new("Frame")
    Sidebar.Position = UDim2.new(0, 10, 0, 55)
    Sidebar.Size = UDim2.new(0, 150, 1, -65)
    Sidebar.BackgroundColor3 = SelectedTheme.SidebarBg
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.Parent = MainFrame
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.Parent = Sidebar

    -- Основная зона контента (Скролл-контейнер)
    local ContentPage = Instance.new("Frame")
    ContentPage.Position = UDim2.new(0, 170, 0, 55)
    ContentPage.Size = UDim2.new(1, -180, 1, -65)
    ContentPage.BackgroundTransparency = 1
    ContentPage.Parent = MainFrame

    -- Логика перетаскивания (Drag)
    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Header.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Сворачивание на кнопку
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == (Config.MinimizeKey or Enum.KeyCode.LeftControl) then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    local WindowObj = {}
    local firstTab = true

    -- МЕТОД: Добавление категории (Вкладки)
    function WindowObj:AddTab(TabConfig)
        local TabName = TabConfig.Title or "Tab"
        
        local TabElementsFrame = Instance.new("ScrollingFrame")
        TabElementsFrame.Size = UDim2.new(1, 0, 1, 0)
        TabElementsFrame.BackgroundTransparency = 1
        TabElementsFrame.BorderSizePixel = 0
        TabElementsFrame.ScrollBarThickness = 2
        TabElementsFrame.ScrollBarImageColor3 = SelectedTheme.Accent
        TabElementsFrame.Visible = firstTab
        TabElementsFrame.Parent = ContentPage

        local ElementsLayout = Instance.new("UIListLayout")
        ElementsLayout.Padding = UDim.new(0, 6)
        ElementsLayout.Parent = TabElementsFrame

        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.BackgroundColor3 = firstTab and SelectedTheme.Accent or SelectedTheme.ElementBg
        TabButton.BackgroundTransparency = firstTab and 0.8 or 0.5
        TabButton.Text = "  " .. TabName
        TabButton.TextColor3 = firstTab and SelectedTheme.Accent or SelectedTheme.SecondaryText
        TabButton.TextSize = 13
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Parent = Sidebar
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

        if firstTab then firstTab = false end

        TabButton.MouseButton1Click:Connect(function()
            for _, page in ipairs(ContentPage:GetChildren()) do page.Visible = false end
            for _, btn in ipairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = SelectedTheme.ElementBg
                    btn.TextColor3 = SelectedTheme.SecondaryText
                end
            end
            TabElementsFrame.Visible = true
            TabButton.BackgroundColor3 = SelectedTheme.Accent
            TabButton.TextColor3 = SelectedTheme.Accent
        end)

        local TabObj = {}

        -- МЕТОД: Переключатель (Toggle)
        function TabObj:AddToggle(ToggleID, ToggleConfig)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -5, 0, 38)
            ToggleFrame.BackgroundColor3 = SelectedTheme.ElementBg
            ToggleFrame.Parent = TabElementsFrame
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.7, 0, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Text = ToggleConfig.Title or "Toggle"
            Label.TextColor3 = SelectedTheme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = ToggleFrame

            local Checkbox = Instance.new("TextButton")
            Checkbox.Size = UDim2.fromOffset(34, 18)
            Checkbox.Position = UDim2.new(1, -44, 0, 10)
            Checkbox.BackgroundColor3 = ToggleConfig.Default and SelectedTheme.Accent or Color3.fromRGB(50,60,70)
            Checkbox.Text = ""
            Checkbox.Parent = ToggleFrame
            Instance.new("UICorner", Checkbox).CornerRadius = UDim.new(0, 9)

            local State = { Value = ToggleConfig.Default or false }
            Checkbox.MouseButton1Click:Connect(function()
                State.Value = not State.Value
                TweenService:Create(Checkbox, TweenInfo.new(0.15), {
                    BackgroundColor3 = State.Value and SelectedTheme.Accent or Color3.fromRGB(50,60,70)
                }):Play()
                if ToggleConfig.Callback then ToggleConfig.Callback(State.Value) end
            end)
            return State
        end

        -- МЕТОД: Слайдер с автоматическим отображением числовых значений
        function TabObj:AddSlider(SliderID, SliderConfig)
            local Min = SliderConfig.Min or 0
            local Max = SliderConfig.Max or 100
            local Default = SliderConfig.Default or Min

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, -5, 0, 50)
            SliderFrame.BackgroundColor3 = SelectedTheme.ElementBg
            SliderFrame.Parent = TabElementsFrame
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5, 0, 0, 22)
            Label.Position = UDim2.new(0, 10, 0, 4)
            Label.Text = SliderConfig.Title or "Slider"
            Label.TextColor3 = SelectedTheme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = SliderFrame

            -- Фикс позиционирования текста цифр (Выровнен справа)
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 60, 0, 22)
            ValueLabel.Position = UDim2.new(1, -70, 0, 4)
            ValueLabel.Text = tostring(Default)
            ValueLabel.TextColor3 = SelectedTheme.Accent
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextSize = 13
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Parent = SliderFrame

            local SliderBar = Instance.new("TextButton")
            SliderBar.Size = UDim2.new(1, -20, 0, 5)
            SliderBar.Position = UDim2.new(0, 10, 0, 34)
            SliderBar.BackgroundColor3 = Color3.fromRGB(50, 60, 70)
            SliderBar.Text = ""
            SliderBar.Parent = SliderFrame
            Instance.new("UICorner", SliderBar)

            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
            SliderFill.BackgroundColor3 = SelectedTheme.Accent
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBar
            Instance.new("UICorner", SliderFill)

            local SliderState = { Value = Default }
            local isSliding = false

            local function UpdateSlider(input)
                local ratio = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                SliderState.Value = math.floor(Min + ratio * (Max - Min))
                ValueLabel.Text = tostring(SliderState.Value) -- Текст обновляется на лету
                SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
                if SliderConfig.Callback then SliderConfig.Callback(SliderState.Value) end
            end

            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = true; UpdateSlider(input) end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(input) end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = false end
            end)

            return SliderState
        end

        -- МЕТОД: Выпадающий список (Показывает выбранный мод)
        function TabObj:AddDropdown(DropdownID, DropdownConfig)
            local Items = DropdownConfig.Values or {}
            local TitleText = DropdownConfig.Title or "Dropdown"
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, -5, 0, 38)
            DropdownFrame.BackgroundColor3 = SelectedTheme.ElementBg
            DropdownFrame.ClipsDescendants = true
            DropdownFrame.Parent = TabElementsFrame
            Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 6)

            local DropdownBtn = Instance.new("TextButton")
            DropdownBtn.Size = UDim2.new(1, 0, 0, 38)
            DropdownBtn.BackgroundTransparency = 1
            DropdownBtn.Text = ""
            DropdownBtn.Parent = DropdownFrame

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
            TitleLabel.Position = UDim2.new(0, 10, 0, 0)
            TitleLabel.Text = TitleText
            TitleLabel.TextColor3 = SelectedTheme.Text
            TitleLabel.Font = Enum.Font.Gotham
            TitleLabel.TextSize = 13
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Parent = DropdownBtn

            -- Текст активного режима справа
            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Size = UDim2.new(0.5, 0, 1, 0)
            SelectedLabel.Position = UDim2.new(1, -15, 0, 0)
            SelectedLabel.Text = DropdownConfig.Default or "Not Selected"
            SelectedLabel.TextColor3 = SelectedTheme.Accent
            SelectedLabel.Font = Enum.Font.GothamMedium
            SelectedLabel.TextSize = 13
            SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            SelectedLabel.BackgroundTransparency = 1
            SelectedLabel.Parent = DropdownBtn

            local DropdownList = Instance.new("Frame")
            DropdownList.Size = UDim2.new(1, 0, 0, #Items * 28)
            DropdownList.Position = UDim2.new(0, 0, 0, 38)
            DropdownList.BackgroundTransparency = 1
            DropdownList.Parent = DropdownFrame
            Instance.new("UIListLayout", DropdownList)

            local IsOpen = false
            local DropdownState = { Value = DropdownConfig.Default }

            DropdownBtn.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {
                    Size = IsOpen and UDim2.new(1, -5, 0, 38 + (#Items * 28)) or UDim2.new(1, -5, 0, 38)
                }):Play()
            end)

            for _, item in ipairs(Items) do
                local ItemBtn = Instance.new("TextButton")
                ItemBtn.Size = UDim2.new(1, 0, 0, 28)
                ItemBtn.BackgroundColor3 = SelectedTheme.SidebarBg
                ItemBtn.BackgroundTransparency = 0.2
                ItemBtn.Text = "    " .. item
                ItemBtn.TextColor3 = SelectedTheme.SecondaryText
                ItemBtn.Font = Enum.Font.Gotham
                ItemBtn.TextSize = 12
                ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
                ItemBtn.Parent = DropdownList

                ItemBtn.MouseButton1Click:Connect(function()
                    DropdownState.Value = item
                    SelectedLabel.Text = item -- Меняет отображаемый мод
                    IsOpen = false
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2), { Size = UDim2.new(1, -5, 0, 38) }):Play()
                    if DropdownConfig.Callback then DropdownConfig.Callback(item) end
                end)
            end

            return DropdownState
        end

        -- МЕТОД: Работающий ColorPicker с раскрывающейся цветовой палитрой
        function TabObj:AddColorPicker(PickerID, PickerConfig)
            local DefaultColor = PickerConfig.Default or Color3.fromRGB(255, 255, 255)
            
            local PickerFrame = Instance.new("Frame")
            PickerFrame.Size = UDim2.new(1, -5, 0, 38)
            PickerFrame.BackgroundColor3 = SelectedTheme.ElementBg
            PickerFrame.ClipsDescendants = true -- Обрезает палитру, когда закрыт
            PickerFrame.Parent = TabElementsFrame
            Instance.new("UICorner", PickerFrame).CornerRadius = UDim.new(0, 6)

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 0, 38)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = PickerFrame

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Text = PickerConfig.Title or "Color Picker"
            Label.TextColor3 = SelectedTheme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = ClickBtn

            -- Квадрат текущего цвета
            local ColorBox = Instance.new("Frame")
            ColorBox.Size = UDim2.fromOffset(24, 16)
            ColorBox.Position = UDim2.new(1, -34, 0, 11)
            ColorBox.BackgroundColor3 = DefaultColor
            ColorBox.Parent = ClickBtn
            Instance.new("UICorner", ColorBox).CornerRadius = UDim.new(0, 4)

            -- Палитра-контейнер (Появляется ниже кнопки)
            local PaletteContainer = Instance.new("Frame")
            PaletteContainer.Position = UDim2.new(0, 10, 0, 42)
            PaletteContainer.Size = UDim2.fromOffset(115, 115)
            PaletteContainer.BackgroundTransparency = 1
            PaletteContainer.Parent = PickerFrame

            -- Само колесо выбора цвета (Ассет круга)
            local ColorWheel = Instance.new("ImageButton")
            ColorWheel.Size = UDim2.new(1, 0, 1, 0)
            ColorWheel.Image = "http://www.roblox.com/asset/?id=6020615135"
            ColorWheel.BackgroundTransparency = 1
            ColorWheel.Parent = PaletteContainer

            local IsOpen = false
            local CurrentColor = DefaultColor

            -- При клике раздвигаем фрейм по высоте (до 170 пикселей)
            ClickBtn.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                TweenService:Create(PickerFrame, TweenInfo.new(0.2), {
                    Size = IsOpen and UDim2.new(1, -5, 0, 170) or UDim2.new(1, -5, 0, 38)
                }):Play()
            end)

            local function UpdateColor(input)
                local r = ColorWheel.AbsoluteSize.X / 2
                local center = ColorWheel.AbsolutePosition + Vector2.new(r, r)
                local delta = input.Position - center
                local distance = delta.Magnitude

                if distance <= r then
                    local angle = math.atan2(delta.Y, delta.X)
                    local hue = (angle + math.pi) / (2 * math.pi)
                    local saturation = math.clamp(distance / r, 0, 1)
                    CurrentColor = Color3.fromHSV(hue, saturation, 1)
                    ColorBox.BackgroundColor3 = CurrentColor
                    if PickerConfig.Callback then PickerConfig.Callback(CurrentColor) end
                end
            end

            local checkingColor = false
            ColorWheel.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then checkingColor = true; UpdateColor(input) end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if checkingColor and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateColor(input) end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then checkingColor = false end
            end)
        end

        return TabObj
    end

    return WindowObj
end

return MyGuiLib