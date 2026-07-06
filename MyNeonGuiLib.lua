local MyGuiLib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

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

    if CoreGui:FindFirstChild("MyCustomNeonUI") then
        CoreGui:FindFirstChild("MyCustomNeonUI"):Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MyCustomNeonUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false

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

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.Color = SelectedTheme.Accent
    UIStroke.Transparency = 0.3
    UIStroke.Parent = MainFrame

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

    local ContentPage = Instance.new("Frame")
    ContentPage.Position = UDim2.new(0, 170, 0, 55)
    ContentPage.Size = UDim2.new(1, -180, 1, -65)
    ContentPage.BackgroundTransparency = 1
    ContentPage.Parent = MainFrame

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

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == (Config.MinimizeKey or Enum.KeyCode.LeftControl) then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    local WindowObj = {}
    local firstTab = true

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

        -- 1. МЕТОД: Кнопка (Button)
        function TabObj:AddButton(ButtonConfig)
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Size = UDim2.new(1, -5, 0, 38)
            ButtonFrame.BackgroundColor3 = SelectedTheme.ElementBg
            ButtonFrame.Parent = TabElementsFrame
            Instance.new("UICorner", ButtonFrame).CornerRadius = UDim.new(0, 6)

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = "  " .. (ButtonConfig.Title or "Button")
            ClickBtn.TextColor3 = SelectedTheme.Text
            ClickBtn.Font = Enum.Font.GothamMedium
            ClickBtn.TextSize = 13
            ClickBtn.TextXAlignment = Enum.TextXAlignment.Left
            ClickBtn.Parent = ButtonFrame

            local ArrowLabel = Instance.new("TextLabel")
            ArrowLabel.Size = UDim2.new(0, 30, 1, 0)
            ArrowLabel.Position = UDim2.new(1, -35, 0, 0)
            ArrowLabel.Text = ">"
            ArrowLabel.TextColor3 = SelectedTheme.SecondaryText
            ArrowLabel.Font = Enum.Font.GothamBold
            ArrowLabel.TextSize = 14
            ArrowLabel.TextXAlignment = Enum.TextXAlignment.Right
            ArrowLabel.BackgroundTransparency = 1
            ArrowLabel.Parent = ClickBtn

            ClickBtn.MouseButton1Click:Connect(function()
                if ButtonConfig.Callback then ButtonConfig.Callback() end
            end)
        end

        -- 2. МЕТОД: Переключатель (Toggle)
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

        -- 3. МЕТОД: Ползунок (Slider)
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
                ValueLabel.Text = tostring(SliderState.Value)
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

        -- 4. МЕТОД: Выпадающий список (Dropdown)
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
            TitleLabel.Size = UDim2.new(0.5, -10, 1, 0)
            TitleLabel.Position = UDim2.new(0, 10, 0, 0)
            TitleLabel.Text = TitleText
            TitleLabel.TextColor3 = SelectedTheme.Text
            TitleLabel.Font = Enum.Font.Gotham
            TitleLabel.TextSize = 13
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Parent = DropdownBtn

            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Size = UDim2.new(0.5, -15, 1, 0)
            SelectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
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
                    SelectedLabel.Text = item
                    IsOpen = false
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2), { Size = UDim2.new(1, -5, 0, 38) }):Play()
                    if DropdownConfig.Callback then DropdownConfig.Callback(item) end
                end)
            end

            return DropdownState
        end

        -- 5. МЕТОД: Поле ввода текста (Input)
        function TabObj:AddInput(InputID, InputConfig)
            local InputFrame = Instance.new("Frame")
            InputFrame.Size = UDim2.new(1, -5, 0, 38)
            InputFrame.BackgroundColor3 = SelectedTheme.ElementBg
            InputFrame.Parent = TabElementsFrame
            Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Text = InputConfig.Title or "Input"
            Label.TextColor3 = SelectedTheme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = InputFrame

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(0.35, 0, 0, 24)
            Box.Position = UDim2.new(1, -10, 0, 7)
            Box.AnchorPoint = Vector2.new(1, 0)
            Box.BackgroundColor3 = SelectedTheme.SidebarBg
            Box.Text = InputConfig.Default or ""
            Box.PlaceholderText = InputConfig.Placeholder or "Type..."
            Box.TextColor3 = SelectedTheme.Text
            Box.PlaceholderColor3 = SelectedTheme.SecondaryText
            Box.Font = Enum.Font.Gotham
            Box.TextSize = 12
            Box.ClipsDescendants = true
            Box.Parent = InputFrame
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)

            local InputState = { Value = Box.Text }
            Box.FocusLost:Connect(function(enterPressed)
                InputState.Value = Box.Text
                if InputConfig.Callback then InputConfig.Callback(Box.Text, enterPressed) end
            end)

            return InputState
        end

        -- 6. МЕТОД: Цветовая палитра (ColorPicker)
        function TabObj:AddColorPicker(PickerID, PickerConfig)
            local DefaultColor = PickerConfig.Default or Color3.fromRGB(255, 255, 255)
            
            local PickerFrame = Instance.new("Frame")
            PickerFrame.Size = UDim2.new(1, -5, 0, 38)
            PickerFrame.BackgroundColor3 = SelectedTheme.ElementBg
            PickerFrame.ClipsDescendants = true
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

            local ColorBox = Instance.new("Frame")
            ColorBox.Size = UDim2.fromOffset(24, 16)
            ColorBox.Position = UDim2.new(1, -34, 0, 11)
            ColorBox.BackgroundColor3 = DefaultColor
            ColorBox.Parent = ClickBtn
            Instance.new("UICorner", ColorBox).CornerRadius = UDim.new(0, 4)

            local PaletteContainer = Instance.new("Frame")
            PaletteContainer.Position = UDim2.new(0, 10, 0, 45)
            PaletteContainer.Size = UDim2.new(1, -20, 0, 20)
            PaletteContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            PaletteContainer.Parent = PickerFrame
            Instance.new("UICorner", PaletteContainer).CornerRadius = UDim.new(0, 4)

            local Gradient = Instance.new("UIGradient")
            Gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
            })
            Gradient.Parent = PaletteContainer

            local PickerSelect = Instance.new("Frame")
            PickerSelect.Size = UDim2.new(0, 4, 1, 4)
            PickerSelect.Position = UDim2.new(0.5, -2, 0, -2)
            PickerSelect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            PickerSelect.BorderSizePixel = 1
            PickerSelect.Parent = PaletteContainer

            local IsOpen = false
            local checkingColor = false

            ClickBtn.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                TweenService:Create(PickerFrame, TweenInfo.new(0.2), {
                    Size = IsOpen and UDim2.new(1, -5, 0, 80) or UDim2.new(1, -5, 0, 38)
                }):Play()
            end)

            local function UpdateColor(input)
                local ratio = math.clamp((input.Position.X - PaletteContainer.AbsolutePosition.X) / PaletteContainer.AbsoluteSize.X, 0, 1)
                PickerSelect.Position = UDim2.new(ratio, -2, 0, -2)
                
                local SelectedColor = Color3.fromHSV(ratio, 1, 1)
                ColorBox.BackgroundColor3 = SelectedColor
                if PickerConfig.Callback then PickerConfig.Callback(SelectedColor) end
            end

            PaletteContainer.InputBegan:Connect(function(input)
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