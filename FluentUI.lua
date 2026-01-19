--[[
    FluentUI - Professional Roblox UI Library
    Single-script, high-performance with Fluent API
    Acrylic/Glassmorphism aesthetic with premium animations
]]

local FluentUI = {}
FluentUI.__index = FluentUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Theme Configuration
local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Surface = Color3.fromRGB(30, 30, 38),
    SurfaceLight = Color3.fromRGB(40, 40, 50),
    Accent = Color3.fromRGB(88, 101, 242),
    AccentDark = Color3.fromRGB(71, 82, 196),
    AccentLight = Color3.fromRGB(114, 125, 246),
    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(150, 150, 160),
    TextDark = Color3.fromRGB(100, 100, 110),
    Success = Color3.fromRGB(67, 181, 129),
    Error = Color3.fromRGB(237, 66, 69),
    Warning = Color3.fromRGB(250, 166, 26),
    Border = Color3.fromRGB(50, 50, 60),
    Shadow = Color3.fromRGB(0, 0, 0),
    Transparency = 0.05,
    AcrylicBlur = 0.15,
    CornerRadius = UDim.new(0, 8),
    CornerRadiusSmall = UDim.new(0, 6),
    CornerRadiusLarge = UDim.new(0, 12),
}

-- Animation Presets
local Tween = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Slow = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
}

-- Utility Functions
local function Create(class, properties, children)
    local instance = Instance.new(class)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = instance
        end
    end
    return instance
end

local function Tween_Property(obj, props, tweenInfo)
    local tween = TweenService:Create(obj, tweenInfo or Tween.Normal, props)
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = radius or Theme.CornerRadius,
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0.5,
        Parent = parent
    })
end

local function AddPadding(parent, padding)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, padding),
        PaddingBottom = UDim.new(0, padding),
        PaddingLeft = UDim.new(0, padding),
        PaddingRight = UDim.new(0, padding),
        Parent = parent
    })
end

local function AddShadow(parent)
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Theme.Shadow,
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        Size = UDim2.new(1, 47, 1, 47),
        Position = UDim2.new(0, -23, 0, -23),
        ZIndex = -1,
        Parent = parent
    })
    return shadow
end

-- Ripple Effect System
local function CreateRipple(parent, position)
    local ripple = Create("Frame", {
        Name = "Ripple",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        Position = UDim2.new(0, position.X, 0, position.Y),
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 999,
        Parent = parent
    })
    AddCorner(ripple, UDim.new(1, 0))
    
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.5
    
    task.spawn(function()
        Tween_Property(ripple, {
            Size = UDim2.new(0, maxSize, 0, maxSize),
            BackgroundTransparency = 1
        }, Tween.Slow)
        task.wait(0.4)
        ripple:Destroy()
    end)
end

-- Class: Window
local Window = {}
Window.__index = Window

function Window.new(library, config)
    local self = setmetatable({}, Window)
    
    self.Library = library
    self.Title = config.Title or "FluentUI"
    self.Size = config.Size or UDim2.fromOffset(650, 450)
    self.Tabs = {}
    self.ActiveTab = nil
    self.Connections = {}
    self.Minimized = false
    self.Dragging = false
    self.DragStart = nil
    self.StartPos = nil
    
    self:Build()
    return self
end

function Window:Build()
    -- Screen GUI
    self.ScreenGui = Create("ScreenGui", {
        Name = "FluentUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999999999,
        IgnoreGuiInset = true,
        Parent = Player:WaitForChild("PlayerGui")
    })
    
    -- Main Container
    self.Main = Create("Frame", {
        Name = "Main",
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = Theme.Transparency,
        Size = self.Size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
        Parent = self.ScreenGui
    })
    AddCorner(self.Main, Theme.CornerRadiusLarge)
    AddStroke(self.Main, Theme.Border, 1, 0.7)
    AddShadow(self.Main)
    
    -- Acrylic Effect Layer
    self.AcrylicLayer = Create("Frame", {
        Name = "Acrylic",
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0,
        Parent = self.Main
    })
    AddCorner(self.AcrylicLayer, Theme.CornerRadiusLarge)
    
    -- Title Bar
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = self.Main
    })
    AddCorner(self.TitleBar, Theme.CornerRadiusLarge)
    
    -- Title Bar Bottom Cover (to hide bottom corners)
    Create("Frame", {
        Name = "BottomCover",
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 0, 1, -15),
        BorderSizePixel = 0,
        Parent = self.TitleBar
    })
    
    -- Title Icon
    self.TitleIcon = Create("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Image = "rbxassetid://7733960981",
        ImageColor3 = Theme.Accent,
        Parent = self.TitleBar
    })
    
    -- Title Text
    self.TitleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = self.Title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar
    })
    
    -- Window Controls Container
    self.ControlsContainer = Create("Frame", {
        Name = "Controls",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 90, 0, 30),
        Position = UDim2.new(1, -95, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = self.TitleBar
    })
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 5),
        Parent = self.ControlsContainer
    })
    
    -- Control Buttons
    local function CreateControlButton(name, icon, color, callback)
        local btn = Create("TextButton", {
            Name = name,
            BackgroundColor3 = Theme.SurfaceLight,
            BackgroundTransparency = 0.5,
            Size = UDim2.new(0, 26, 0, 26),
            Text = "",
            AutoButtonColor = false,
            Parent = self.ControlsContainer
        })
        AddCorner(btn, Theme.CornerRadiusSmall)
        
        local iconLabel = Create("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = icon,
            ImageColor3 = Theme.TextMuted,
            Parent = btn
        })
        
        btn.MouseEnter:Connect(function()
            Tween_Property(btn, {BackgroundColor3 = color, BackgroundTransparency = 0.2}, Tween.Fast)
            Tween_Property(iconLabel, {ImageColor3 = Theme.Text}, Tween.Fast)
        end)
        
        btn.MouseLeave:Connect(function()
            Tween_Property(btn, {BackgroundColor3 = Theme.SurfaceLight, BackgroundTransparency = 0.5}, Tween.Fast)
            Tween_Property(iconLabel, {ImageColor3 = Theme.TextMuted}, Tween.Fast)
        end)
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    -- Minimize Button
    CreateControlButton("Minimize", "rbxassetid://7072717857", Theme.Warning, function()
        self:Minimize()
    end)
    
    -- Maximize Button (placeholder)
    CreateControlButton("Maximize", "rbxassetid://7072718414", Theme.Success, function()
        -- Future: Toggle maximize
    end)
    
    -- Close Button
    CreateControlButton("Close", "rbxassetid://7072725342", Theme.Error, function()
        self:Close()
    end)
    
    -- Content Area
    self.ContentArea = Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        Parent = self.Main
    })
    
    -- Sidebar
    self.Sidebar = Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(0, 150, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        Parent = self.ContentArea
    })
    AddCorner(self.Sidebar, Theme.CornerRadius)
    
    -- Sidebar Tabs Container
    self.TabsContainer = Create("ScrollingFrame", {
        Name = "Tabs",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = self.Sidebar
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = self.TabsContainer
    })
    
    -- Tab Content Container
    self.TabContent = Create("Frame", {
        Name = "TabContent",
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.7,
        Size = UDim2.new(1, -165, 1, -10),
        Position = UDim2.new(0, 160, 0, 5),
        ClipsDescendants = true,
        Parent = self.ContentArea
    })
    AddCorner(self.TabContent, Theme.CornerRadius)
    
    -- Initialize Dragging
    self:SetupDragging()
    
    -- Open Animation
    self.Main.Size = UDim2.fromOffset(0, 0)
    self.Main.BackgroundTransparency = 1
    Tween_Property(self.Main, {
        Size = self.Size,
        BackgroundTransparency = Theme.Transparency
    }, Tween.Bounce)
end

function Window:SetupDragging()
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.Main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            Tween_Property(self.Main, {Position = targetPos}, Tween.Fast)
        end
    end))
end

function Window:Minimize()
    self.Minimized = not self.Minimized
    if self.Minimized then
        Tween_Property(self.Main, {Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, 0, 40)}, Tween.Normal)
        Tween_Property(self.ContentArea, {BackgroundTransparency = 1}, Tween.Fast)
    else
        Tween_Property(self.Main, {Size = self.Size}, Tween.Bounce)
        Tween_Property(self.ContentArea, {BackgroundTransparency = 0}, Tween.Fast)
    end
end

function Window:Close()
    Tween_Property(self.Main, {
        Size = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1
    }, Tween.Normal)
    
    task.delay(0.3, function()
        for _, conn in ipairs(self.Connections) do
            conn:Disconnect()
        end
        self.ScreenGui:Destroy()
    end)
end

function Window:CreateTab(config)
    local tab = Tab.new(self, config)
    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        tab:Select()
    end
    
    return tab
end

-- Class: Tab
Tab = {}
Tab.__index = Tab

function Tab.new(window, config)
    local self = setmetatable({}, Tab)
    
    self.Window = window
    self.Name = config.Name or "Tab"
    self.Icon = config.Icon or "rbxassetid://7733960981"
    self.Elements = {}
    self.Selected = false
    
    self:Build()
    return self
end

function Tab:Build()
    -- Tab Button in Sidebar
    self.Button = Create("TextButton", {
        Name = self.Name,
        BackgroundColor3 = Theme.SurfaceLight,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Text = "",
        AutoButtonColor = false,
        Parent = self.Window.TabsContainer
    })
    AddCorner(self.Button, Theme.CornerRadiusSmall)
    
    -- Tab Icon
    self.IconLabel = Create("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Image = self.Icon,
        ImageColor3 = Theme.TextMuted,
        Parent = self.Button
    })
    
    -- Tab Name
    self.NameLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 35, 0, 0),
        Font = Enum.Font.GothamMedium,
        Text = self.Name,
        TextColor3 = Theme.TextMuted,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Button
    })
    
    -- Selection Indicator
    self.Indicator = Create("Frame", {
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 3, 0.6, 0),
        Position = UDim2.new(0, 0, 0.2, 0),
        Parent = self.Button
    })
    AddCorner(self.Indicator, UDim.new(0, 2))
    
    -- Tab Content Page
    self.Page = Create("ScrollingFrame", {
        Name = self.Name .. "Page",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.Window.TabContent
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        Parent = self.Page
    })
    
    -- Hover Effects
    self.Button.MouseEnter:Connect(function()
        if not self.Selected then
            Tween_Property(self.Button, {BackgroundTransparency = 0.7}, Tween.Fast)
            Tween_Property(self.IconLabel, {ImageColor3 = Theme.Text}, Tween.Fast)
            Tween_Property(self.NameLabel, {TextColor3 = Theme.Text}, Tween.Fast)
        end
    end)
    
    self.Button.MouseLeave:Connect(function()
        if not self.Selected then
            Tween_Property(self.Button, {BackgroundTransparency = 1}, Tween.Fast)
            Tween_Property(self.IconLabel, {ImageColor3 = Theme.TextMuted}, Tween.Fast)
            Tween_Property(self.NameLabel, {TextColor3 = Theme.TextMuted}, Tween.Fast)
        end
    end)
    
    self.Button.MouseButton1Click:Connect(function()
        self:Select()
    end)
end

function Tab:Select()
    -- Deselect all other tabs
    for _, tab in ipairs(self.Window.Tabs) do
        if tab ~= self and tab.Selected then
            tab:Deselect()
        end
    end
    
    self.Selected = true
    self.Window.ActiveTab = self
    
    -- Animate selection
    Tween_Property(self.Button, {BackgroundTransparency = 0.5}, Tween.Fast)
    Tween_Property(self.IconLabel, {ImageColor3 = Theme.Accent}, Tween.Fast)
    Tween_Property(self.NameLabel, {TextColor3 = Theme.Text}, Tween.Fast)
    Tween_Property(self.Indicator, {BackgroundTransparency = 0}, Tween.Normal)
    
    -- Show page with animation
    self.Page.Visible = true
    self.Page.Position = UDim2.new(0.1, 10, 0, 10)
    self.Page.GroupTransparency = 1
    Tween_Property(self.Page, {Position = UDim2.new(0, 10, 0, 10)}, Tween.Normal)
    
    -- Fade in elements
    for _, element in ipairs(self.Page:GetChildren()) do
        if element:IsA("Frame") then
            element.BackgroundTransparency = 1
            Tween_Property(element, {BackgroundTransparency = 0.5}, Tween.Normal)
        end
    end
end

function Tab:Deselect()
    self.Selected = false
    
    Tween_Property(self.Button, {BackgroundTransparency = 1}, Tween.Fast)
    Tween_Property(self.IconLabel, {ImageColor3 = Theme.TextMuted}, Tween.Fast)
    Tween_Property(self.NameLabel, {TextColor3 = Theme.TextMuted}, Tween.Fast)
    Tween_Property(self.Indicator, {BackgroundTransparency = 1}, Tween.Normal)
    
    self.Page.Visible = false
end

function Tab:CreateSection(config)
    local section = Create("Frame", {
        Name = config.Name or "Section",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.Page
    })
    
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = config.Name or "Section",
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    })
    
    return self
end

function Tab:CreateToggle(config)
    local toggle = Toggle.new(self, config)
    table.insert(self.Elements, toggle)
    return toggle
end

function Tab:CreateSlider(config)
    local slider = Slider.new(self, config)
    table.insert(self.Elements, slider)
    return slider
end

function Tab:CreateDropdown(config)
    local dropdown = Dropdown.new(self, config)
    table.insert(self.Elements, dropdown)
    return dropdown
end

function Tab:CreateButton(config)
    local button = Button.new(self, config)
    table.insert(self.Elements, button)
    return button
end

-- Class: Toggle
Toggle = {}
Toggle.__index = Toggle

function Toggle.new(tab, config)
    local self = setmetatable({}, Toggle)
    
    self.Tab = tab
    self.Name = config.Name or "Toggle"
    self.Default = config.Default or false
    self.Callback = config.Callback or function() end
    self.Value = self.Default
    
    self:Build()
    return self
end

function Toggle:Build()
    self.Container = Create("Frame", {
        Name = self.Name,
        BackgroundColor3 = Theme.SurfaceLight,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = self.Tab.Page
    })
    AddCorner(self.Container, Theme.CornerRadiusSmall)
    
    -- Label
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Font = Enum.Font.GothamMedium,
        Text = self.Name,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Container
    })
    
    -- Toggle Switch
    self.Switch = Create("Frame", {
        Name = "Switch",
        BackgroundColor3 = self.Value and Theme.Accent or Theme.Border,
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -54, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = self.Container
    })
    AddCorner(self.Switch, UDim.new(1, 0))
    
    -- Toggle Knob
    self.Knob = Create("Frame", {
        Name = "Knob",
        BackgroundColor3 = Theme.Text,
        Size = UDim2.new(0, 18, 0, 18),
        Position = self.Value and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = self.Switch
    })
    AddCorner(self.Knob, UDim.new(1, 0))
    
    -- Shadow on knob
    Create("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Theme.Shadow,
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0.5, 0, 0.5, 2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = -1,
        Parent = self.Knob
    })
    
    -- Click Handler
    local clickBtn = Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = self.Container
    })
    
    clickBtn.MouseButton1Click:Connect(function()
        self:Toggle()
        CreateRipple(self.Switch, Vector2.new(self.Switch.AbsoluteSize.X / 2, self.Switch.AbsoluteSize.Y / 2))
    end)
    
    -- Hover Effect
    clickBtn.MouseEnter:Connect(function()
        Tween_Property(self.Container, {BackgroundTransparency = 0.3}, Tween.Fast)
    end)
    
    clickBtn.MouseLeave:Connect(function()
        Tween_Property(self.Container, {BackgroundTransparency = 0.5}, Tween.Fast)
    end)
end

function Toggle:Toggle()
    self.Value = not self.Value
    
    if self.Value then
        Tween_Property(self.Switch, {BackgroundColor3 = Theme.Accent}, Tween.Normal)
        Tween_Property(self.Knob, {Position = UDim2.new(1, -21, 0.5, 0)}, Tween.Bounce)
    else
        Tween_Property(self.Switch, {BackgroundColor3 = Theme.Border}, Tween.Normal)
        Tween_Property(self.Knob, {Position = UDim2.new(0, 3, 0.5, 0)}, Tween.Bounce)
    end
    
    task.spawn(function()
        self.Callback(self.Value)
    end)
end

function Toggle:Set(value)
    if self.Value ~= value then
        self:Toggle()
    end
    return self
end

-- Class: Slider
Slider = {}
Slider.__index = Slider

function Slider.new(tab, config)
    local self = setmetatable({}, Slider)
    
    self.Tab = tab
    self.Name = config.Name or "Slider"
    self.Min = config.Min or 0
    self.Max = config.Max or 100
    self.Default = config.Default or self.Min
    self.Increment = config.Increment or 1
    self.Callback = config.Callback or function() end
    self.Value = self.Default
    
    self:Build()
    return self
end

function Slider:Build()
    self.Container = Create("Frame", {
        Name = self.Name,
        BackgroundColor3 = Theme.SurfaceLight,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 55),
        Parent = self.Tab.Page
    })
    AddCorner(self.Container, Theme.CornerRadiusSmall)
    
    -- Header Row
    local header = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -24, 0, 25),
        Position = UDim2.new(0, 12, 0, 5),
        Parent = self.Container
    })
    
    -- Label
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, 0, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = self.Name,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    -- Value Display
    self.ValueLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.3, 0, 1, 0),
        Position = UDim2.new(0.7, 0, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = tostring(self.Value),
        TextColor3 = Theme.Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = header
    })
    
    -- Slider Track
    self.Track = Create("Frame", {
        Name = "Track",
        BackgroundColor3 = Theme.Border,
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 38),
        Parent = self.Container
    })
    AddCorner(self.Track, UDim.new(1, 0))
    
    -- Slider Fill
    local initialPercent = (self.Value - self.Min) / (self.Max - self.Min)
    self.Fill = Create("Frame", {
        Name = "Fill",
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(initialPercent, 0, 1, 0),
        Parent = self.Track
    })
    AddCorner(self.Fill, UDim.new(1, 0))
    
    -- Slider Knob
    self.Knob = Create("Frame", {
        Name = "Knob",
        BackgroundColor3 = Theme.Text,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(initialPercent, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 2,
        Parent = self.Track
    })
    AddCorner(self.Knob, UDim.new(1, 0))
    
    -- Knob Glow
    local glowFrame = Create("Frame", {
        Name = "GlowFrame",
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.7,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 1,
        Parent = self.Knob
    })
    AddCorner(glowFrame, UDim.new(1, 0))
    
    -- Interaction
    local dragging = false
    
    local function UpdateSlider(inputPos)
        local trackPos = self.Track.AbsolutePosition.X
        local trackSize = self.Track.AbsoluteSize.X
        
        local relativePos = math.clamp((inputPos - trackPos) / trackSize, 0, 1)
        local rawValue = self.Min + (self.Max - self.Min) * relativePos
        local steppedValue = math.floor(rawValue / self.Increment + 0.5) * self.Increment
        self.Value = math.clamp(steppedValue, self.Min, self.Max)
        
        local percent = (self.Value - self.Min) / (self.Max - self.Min)
        
        Tween_Property(self.Fill, {Size = UDim2.new(percent, 0, 1, 0)}, Tween.Fast)
        Tween_Property(self.Knob, {Position = UDim2.new(percent, 0, 0.5, 0)}, Tween.Fast)
        self.ValueLabel.Text = tostring(self.Value)
        
        task.spawn(function()
            self.Callback(self.Value)
        end)
    end
    
    self.Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input.Position.X)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Hover Effect
    self.Container.MouseEnter:Connect(function()
        Tween_Property(self.Container, {BackgroundTransparency = 0.3}, Tween.Fast)
        Tween_Property(self.Knob, {Size = UDim2.new(0, 18, 0, 18)}, Tween.Fast)
    end)
    
    self.Container.MouseLeave:Connect(function()
        Tween_Property(self.Container, {BackgroundTransparency = 0.5}, Tween.Fast)
        if not dragging then
            Tween_Property(self.Knob, {Size = UDim2.new(0, 16, 0, 16)}, Tween.Fast)
        end
    end)
end

function Slider:Set(value)
    self.Value = math.clamp(value, self.Min, self.Max)
    local percent = (self.Value - self.Min) / (self.Max - self.Min)
    
    Tween_Property(self.Fill, {Size = UDim2.new(percent, 0, 1, 0)}, Tween.Normal)
    Tween_Property(self.Knob, {Position = UDim2.new(percent, 0, 0.5, 0)}, Tween.Normal)
    self.ValueLabel.Text = tostring(self.Value)
    
    return self
end

-- Class: Dropdown
Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(tab, config)
    local self = setmetatable({}, Dropdown)
    
    self.Tab = tab
    self.Name = config.Name or "Dropdown"
    self.Options = config.Options or {}
    self.Default = config.Default
    self.Callback = config.Callback or function() end
    self.Value = self.Default or (self.Options[1] or "")
    self.Open = false
    
    self:Build()
    return self
end

function Dropdown:Build()
    self.Container = Create("Frame", {
        Name = self.Name,
        BackgroundColor3 = Theme.SurfaceLight,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 40),
        ClipsDescendants = true,
        Parent = self.Tab.Page
    })
    AddCorner(self.Container, Theme.CornerRadiusSmall)
    
    -- Header
    self.Header = Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Text = "",
        Parent = self.Container
    })
    
    -- Label
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, -12, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Font = Enum.Font.GothamMedium,
        Text = self.Name,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Header
    })
    
    -- Selected Value
    self.SelectedLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, -30, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        Font = Enum.Font.GothamMedium,
        Text = self.Value,
        TextColor3 = Theme.Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = self.Header
    })
    
    -- Arrow Icon
    self.Arrow = Create("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -18, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Image = "rbxassetid://7072706796",
        ImageColor3 = Theme.TextMuted,
        Rotation = 0,
        Parent = self.Header
    })
    
    -- Options Container
    self.OptionsContainer = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 45),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.Container
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = self.OptionsContainer
    })
    
    -- Build Options
    for _, option in ipairs(self.Options) do
        self:CreateOption(option)
    end
    
    -- Toggle Dropdown
    self.Header.MouseButton1Click:Connect(function()
        self:ToggleOpen()
    end)
    
    -- Hover Effect
    self.Header.MouseEnter:Connect(function()
        Tween_Property(self.Container, {BackgroundTransparency = 0.3}, Tween.Fast)
    end)
    
    self.Header.MouseLeave:Connect(function()
        if not self.Open then
            Tween_Property(self.Container, {BackgroundTransparency = 0.5}, Tween.Fast)
        end
    end)
end

function Dropdown:CreateOption(option)
    local optBtn = Create("TextButton", {
        Name = option,
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 32),
        Font = Enum.Font.GothamMedium,
        Text = option,
        TextColor3 = option == self.Value and Theme.Accent or Theme.Text,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = self.OptionsContainer
    })
    AddCorner(optBtn, Theme.CornerRadiusSmall)
    
    optBtn.MouseEnter:Connect(function()
        Tween_Property(optBtn, {BackgroundTransparency = 0.2, TextColor3 = Theme.Accent}, Tween.Fast)
    end)
    
    optBtn.MouseLeave:Connect(function()
        local color = option == self.Value and Theme.Accent or Theme.Text
        Tween_Property(optBtn, {BackgroundTransparency = 0.5, TextColor3 = color}, Tween.Fast)
    end)
    
    optBtn.MouseButton1Click:Connect(function()
        self:Select(option)
        CreateRipple(optBtn, Vector2.new(optBtn.AbsoluteSize.X / 2, optBtn.AbsoluteSize.Y / 2))
    end)
end

function Dropdown:ToggleOpen()
    self.Open = not self.Open
    
    local optionCount = #self.Options
    local targetHeight = self.Open and (40 + 10 + (optionCount * 36)) or 40
    
    Tween_Property(self.Container, {Size = UDim2.new(1, 0, 0, targetHeight)}, Tween.Normal)
    Tween_Property(self.Arrow, {Rotation = self.Open and 180 or 0}, Tween.Normal)
    
    if self.Open then
        Tween_Property(self.Container, {BackgroundTransparency = 0.3}, Tween.Fast)
    end
end

function Dropdown:Select(option)
    self.Value = option
    self.SelectedLabel.Text = option
    
    -- Update option colors
    for _, optBtn in ipairs(self.OptionsContainer:GetChildren()) do
        if optBtn:IsA("TextButton") then
            local color = optBtn.Name == option and Theme.Accent or Theme.Text
            Tween_Property(optBtn, {TextColor3 = color}, Tween.Fast)
        end
    end
    
    self:ToggleOpen()
    
    task.spawn(function()
        self.Callback(option)
    end)
end

function Dropdown:Set(option)
    if table.find(self.Options, option) then
        self.Value = option
        self.SelectedLabel.Text = option
    end
    return self
end

-- Class: Button
Button = {}
Button.__index = Button

function Button.new(tab, config)
    local self = setmetatable({}, Button)
    
    self.Tab = tab
    self.Name = config.Name or "Button"
    self.Callback = config.Callback or function() end
    
    self:Build()
    return self
end

function Button:Build()
    self.Container = Create("TextButton", {
        Name = self.Name,
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.1,
        Size = UDim2.new(1, 0, 0, 40),
        Font = Enum.Font.GothamBold,
        Text = self.Name,
        TextColor3 = Theme.Text,
        TextSize = 14,
        AutoButtonColor = false,
        ClipsDescendants = true,
        Parent = self.Tab.Page
    })
    AddCorner(self.Container, Theme.CornerRadiusSmall)
    
    -- Hover Effects
    self.Container.MouseEnter:Connect(function()
        Tween_Property(self.Container, {
            BackgroundColor3 = Theme.AccentLight,
            Size = UDim2.new(1, 0, 0, 42)
        }, Tween.Fast)
    end)
    
    self.Container.MouseLeave:Connect(function()
        Tween_Property(self.Container, {
            BackgroundColor3 = Theme.Accent,
            Size = UDim2.new(1, 0, 0, 40)
        }, Tween.Fast)
    end)
    
    -- Click Handler with Ripple
    self.Container.MouseButton1Click:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        local relativePos = mousePos - self.Container.AbsolutePosition
        CreateRipple(self.Container, relativePos)
        
        -- Press animation
        Tween_Property(self.Container, {BackgroundColor3 = Theme.AccentDark}, Tween.Fast)
        task.delay(0.1, function()
            Tween_Property(self.Container, {BackgroundColor3 = Theme.AccentLight}, Tween.Fast)
        end)
        
        task.spawn(function()
            self.Callback()
        end)
    end)
end

-- Library Entry Point
function FluentUI:CreateWindow(config)
    return Window.new(self, config or {})
end

-- Theme Customization
function FluentUI:SetTheme(customTheme)
    for key, value in pairs(customTheme) do
        if Theme[key] then
            Theme[key] = value
        end
    end
    return self
end

function FluentUI:GetTheme()
    return Theme
end

return FluentUI
