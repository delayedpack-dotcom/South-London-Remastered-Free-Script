-- DELAYED SL - South London 2 Script Panel
-- Modern dark UI with sidebar navigation and all features

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local lplr = Players.LocalPlayer

-- State variables
local flyEnabled = false
local walkSpeedEnabled = false
local infiniteStaminaEnabled = false
local currentWalkSpeed = 32
local currentTab = "Movement"

-- Connections
local flyConn, noclipConn, walkSpeedConn, staminaConn

-- Color Scheme
local Colors = {
    Background = Color3.fromRGB(15, 15, 18),
    Card = Color3.fromRGB(15, 15, 20),
    CardHover = Color3.fromRGB(25, 25, 30),
    Sidebar = Color3.fromRGB(18, 18, 22),
    ContentBg = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(138, 80, 255),
    AccentDark = Color3.fromRGB(100, 60, 200),
    Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(160, 160, 170),
    Border = Color3.fromRGB(40, 40, 50),
    ToggleOff = Color3.fromRGB(45, 45, 55),
    ToggleKnob = Color3.fromRGB(70, 70, 80),
}

-- Locations
local locations = {
    {name = "BankLog", pos = Vector3.new(-176.02, -0.44, 167.79)},
    {name = "Swpie", pos = Vector3.new(-195.02, 5.96, 254.57)},
    {name = "Laundry", pos = Vector3.new(217.16, 4.18, 367.85)},
    {name = "London Firearms", pos = Vector3.new(40.74, 4.18, 369.31)},
    {name = "Bullet & Barrel", pos = Vector3.new(40.32, 4.28, -656.36)},
    {name = "Outkirts Of The Town", pos = Vector3.new(-565.38, 3.50954, -9.9876)},
    {name = "School", pos = Vector3.new(-337.95, 3.52999, 0.78420)},
    {name = "Near School", pos = Vector3.new(-399.46, 3.52999, 7.68115)},
    {name = "Spawn Location", pos = Vector3.new(-285.35, 3.23000, -293.59)},
    {name = "Met Station", pos = Vector3.new(-265.12, 3.47210, -145.16)},
    {name = "Near Fairbank Parking", pos = Vector3.new(-27.689, 3.37999, -488.01)},
    {name = "Illegal Gunstore", pos = Vector3.new(80.4551, 3.22999, -669.13)},
    {name = "Petrol Station", pos = Vector3.new(256.612, 3.52599, -746.32)},
    {name = "Near Football Field", pos = Vector3.new(-418.06, 3.52160, -216.62)},
    {name = "Behind Fairbank Parking", pos = Vector3.new(215.989, 3.23000, -531.05)},
    {name = "P Block", pos = Vector3.new(-373.40, 3.43209, -133.33)},
    {name = "Croydon Shipyard", pos = Vector3.new(421.010, 3.22950, 37.0479)},
    {name = "BoxedIce", pos = Vector3.new(295.283, 3.52999, -278.96)},
    {name = "Near Idea Store", pos = Vector3.new(277.346, 3.53000, -96.585)},
    {name = "Behind Idea Store", pos = Vector3.new(205.483, 3.57210, -95.507)},
    {name = "Trap Block", pos = Vector3.new(203.675, 3.74238, -14.353)},
    {name = "060 Block", pos = Vector3.new(65.9189, 3.63000, -111.94)},
    {name = "Graveyard", pos = Vector3.new(180.165, 3.52949, -178.92)},
    {name = "Near Graveyard", pos = Vector3.new(111.219, 3.52949, -275.74)},
    {name = "Suite Apartments", pos = Vector3.new(-20.374, 3.37999, -196.23)},
    {name = "Hospital", pos = Vector3.new(-442.34, 3.47160, 90.3315)},
    {name = "Residential Block", pos = Vector3.new(-99.284, 3.53386, 741.348)},
    {name = "National Park", pos = Vector3.new(-499.76, 3.52999, 309.022)},
    {name = "Blackmarket", pos = Vector3.new(236.746, 3.71305, 420.840)},
    {name = "Car Tuning", pos = Vector3.new(160.724, 3.23000, 704.394)},
}

-- ============================================================================
-- CORE FUNCTIONS
-- ============================================================================

local flyspeed = 200
local maxdistance = 1000
local keys = {}

local function GetVelocity(pos1, pos2, StudsPerSecond)
    local distance = (pos2 - pos1)
    local mag = distance.Magnitude
    if mag == 0 then return Vector3.new() end
    return (distance / mag) * StudsPerSecond
end

local function getkey(keycode)
    local key = tostring(keycode):lower()
    local _, a = key:find("keycode.")
    return key:sub(a + 1)
end

local function disconnectFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
end

local function startFly()
    disconnectFly()
    flyConn = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not lplr.Character or not lplr.Character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = lplr.Character.HumanoidRootPart
            local camera = Workspace.CurrentCamera
            
            local frontPos = (hrp.CFrame * CFrame.new(0, 0, -maxdistance)).Position
            local backPos = (hrp.CFrame * CFrame.new(0, 0, maxdistance)).Position
            local leftPos = (hrp.CFrame * CFrame.new(-maxdistance, 0, 0)).Position
            local rightPos = (hrp.CFrame * CFrame.new(maxdistance, 0, 0)).Position
            local upPos = hrp.Position + Vector3.new(0, maxdistance, 0)
            local downPos = hrp.Position - Vector3.new(0, maxdistance, 0)
            
            local velocity = Vector3.new(0, 0, 0)
            
            if flyEnabled then
                if keys.w_active then velocity += GetVelocity(hrp.Position, frontPos, flyspeed) end
                if keys.s_active then velocity += GetVelocity(hrp.Position, backPos, flyspeed) end
                if keys.a_active then velocity += GetVelocity(hrp.Position, leftPos, flyspeed) end
                if keys.d_active then velocity += GetVelocity(hrp.Position, rightPos, flyspeed) end
                if keys.e_active then velocity += GetVelocity(hrp.Position, upPos, flyspeed) end
                if keys.q_active then velocity += GetVelocity(hrp.Position, downPos, flyspeed) end
                
                hrp.Velocity = velocity
                hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + camera.CFrame.LookVector)
                
                local moving = keys.w_active or keys.s_active or keys.a_active or keys.d_active or keys.q_active or keys.e_active
                hrp.Anchored = not moving
            end
        end)
    end)
end

local function disconnectNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    pcall(function()
        if lplr.Character then
            for _, part in ipairs(lplr.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                    part.Transparency = 0
                end
            end
        end
    end)
end

local function startNoclip()
    disconnectNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        pcall(function()
            if flyEnabled and lplr.Character then
                for _, part in ipairs(lplr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        if part.Name ~= "HumanoidRootPart" then
                            part.Transparency = 1
                        end
                    end
                end
            end
        end)
    end)
end

local function startWalkSpeed()
    if walkSpeedConn then walkSpeedConn:Disconnect() end
    walkSpeedConn = RunService.Heartbeat:Connect(function()
        pcall(function()
            if walkSpeedEnabled and lplr.Character then
                local humanoid = lplr.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = currentWalkSpeed
                end
            end
        end)
    end)
end

local function stopWalkSpeed()
    if walkSpeedConn then
        walkSpeedConn:Disconnect()
        walkSpeedConn = nil
    end
    pcall(function()
        if lplr.Character then
            local humanoid = lplr.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
    end)
end

local function startInfiniteStamina()
    if staminaConn then staminaConn:Disconnect() end
    staminaConn = RunService.Heartbeat:Connect(function()
        pcall(function()
            if infiniteStaminaEnabled and lplr:FindFirstChild("Valuestats") then
                if lplr.Valuestats:FindFirstChild("Stamina") then
                    lplr.Valuestats.Stamina.Value = 100
                end
            end
        end)
    end)
end

local function stopInfiniteStamina()
    if staminaConn then
        staminaConn:Disconnect()
        staminaConn = nil
    end
end

local function teleportToPosition(position)
    pcall(function()
        local character = lplr.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(position)
        end
    end)
end

-- ============================================================================
-- UI CREATION
-- ============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DelayedSLPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if lplr.PlayerGui:FindFirstChild("DelayedSLPanel") then
    lplr.PlayerGui.DelayedSLPanel:Destroy()
end

ScreenGui.Parent = lplr.PlayerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
MainFrame.Size = UDim2.new(0, 800, 0, 600)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.BackgroundColor3 = Colors.Card
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.BackgroundColor3 = Colors.Card
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Parent = TitleBar

-- Title accent line
local TitleAccent = Instance.new("Frame")
TitleAccent.BackgroundColor3 = Colors.Accent
TitleAccent.BorderSizePixel = 0
TitleAccent.Position = UDim2.new(0, 0, 1, -2)
TitleAccent.Size = UDim2.new(1, 0, 0, 2)
TitleAccent.Parent = TitleBar

-- Title Text
local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 20, 0, 8)
Title.Size = UDim2.new(0, 300, 0, 20)
Title.Font = Enum.Font.GothamBold
Title.Text = "DELAYED SL"
Title.TextColor3 = Colors.Text
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0, 20, 0, 28)
Subtitle.Size = UDim2.new(0, 300, 0, 16)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "South London 2"
Subtitle.TextColor3 = Colors.TextDim
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = TitleBar

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(1, -75, 0.5, -13)
MinimizeButton.Size = UDim2.new(0, 26, 0, 26)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Colors.Text
MinimizeButton.TextSize = 16
MinimizeButton.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeButton

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -40, 0.5, -13)
CloseButton.Size = UDim2.new(0, 26, 0, 26)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.BackgroundColor3 = Colors.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.Size = UDim2.new(0, 230, 1, -50)
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

local SidebarFix1 = Instance.new("Frame")
SidebarFix1.BackgroundColor3 = Colors.Sidebar
SidebarFix1.BorderSizePixel = 0
SidebarFix1.Position = UDim2.new(1, -10, 0, 0)
SidebarFix1.Size = UDim2.new(0, 10, 1, 0)
SidebarFix1.Parent = Sidebar

local SidebarFix2 = Instance.new("Frame")
SidebarFix2.BackgroundColor3 = Colors.Sidebar
SidebarFix2.BorderSizePixel = 0
SidebarFix2.Size = UDim2.new(1, 0, 0, 10)
SidebarFix2.Parent = Sidebar

local SidebarBorder = Instance.new("Frame")
SidebarBorder.BackgroundColor3 = Colors.Border
SidebarBorder.BorderSizePixel = 0
SidebarBorder.Position = UDim2.new(1, 0, 0, 0)
SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
SidebarBorder.Parent = Sidebar

-- Sidebar Content
local SidebarContent = Instance.new("Frame")
SidebarContent.Name = "SidebarContent"
SidebarContent.BackgroundTransparency = 1
SidebarContent.Size = UDim2.new(1, 0, 1, 0)
SidebarContent.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 8)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = SidebarContent

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 15)
SidebarPadding.PaddingLeft = UDim.new(0, 10)
SidebarPadding.PaddingRight = UDim.new(0, 10)
SidebarPadding.Parent = SidebarContent

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.BackgroundColor3 = Colors.ContentBg
ContentArea.BorderSizePixel = 0
ContentArea.Position = UDim2.new(0, 230, 0, 50)
ContentArea.Size = UDim2.new(1, -230, 1, -50)
ContentArea.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
ContentCorner.Parent = ContentArea

local ContentFix1 = Instance.new("Frame")
ContentFix1.BackgroundColor3 = Colors.ContentBg
ContentFix1.BorderSizePixel = 0
ContentFix1.Size = UDim2.new(0, 10, 1, 0)
ContentFix1.Parent = ContentArea

local ContentFix2 = Instance.new("Frame")
ContentFix2.BackgroundColor3 = Colors.ContentBg
ContentFix2.BorderSizePixel = 0
ContentFix2.Size = UDim2.new(1, 0, 0, 10)
ContentFix2.Parent = ContentArea

-- Tabs Container
local TabsContainer = Instance.new("Frame")
TabsContainer.BackgroundTransparency = 1
TabsContainer.Size = UDim2.new(1, 0, 1, 0)
TabsContainer.Parent = ContentArea

-- ============================================================================
-- UI COMPONENTS
-- ============================================================================

local function createSidebarButton(text, icon, order, tabName)
    local Button = Instance.new("TextButton")
    Button.BackgroundColor3 = Colors.Card
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, 0, 0, 45)
    Button.Text = ""
    Button.LayoutOrder = order
    Button.AutoButtonColor = false
    Button.Parent = SidebarContent
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button
    
    local Icon = Instance.new("TextLabel")
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0, 12, 0, 0)
    Icon.Size = UDim2.new(0, 30, 1, 0)
    Icon.Font = Enum.Font.GothamBold
    Icon.Text = icon
    Icon.TextColor3 = Colors.TextDim
    Icon.TextSize = 18
    Icon.Parent = Button
    
    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 46, 0, 0)
    Label.Size = UDim2.new(1, -46, 1, 0)
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = text
    Label.TextColor3 = Colors.TextDim
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button
    
    local Indicator = Instance.new("Frame")
    Indicator.BackgroundColor3 = Colors.Accent
    Indicator.BorderSizePixel = 0
    Indicator.Position = UDim2.new(0, 0, 0.5, -12)
    Indicator.Size = UDim2.new(0, 4, 0, 24)
    Indicator.Visible = false
    Indicator.Parent = Button
    
    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(0, 2)
    IndCorner.Parent = Indicator
    
    Button.MouseEnter:Connect(function()
        if currentTab ~= tabName then
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.CardHover}):Play()
        end
    end)
    
    Button.MouseLeave:Connect(function()
        if currentTab ~= tabName then
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Card}):Play()
        end
    end)
    
    return Button, Indicator, Icon, Label
end

local function createTabFrame(name)
    local Tab = Instance.new("ScrollingFrame")
    Tab.BackgroundTransparency = 1
    Tab.BorderSizePixel = 0
    Tab.Size = UDim2.new(1, 0, 1, 0)
    Tab.CanvasSize = UDim2.new(0, 0, 0, 0)
    Tab.ScrollBarThickness = 4
    Tab.ScrollBarImageColor3 = Colors.Accent
    Tab.Visible = false
    Tab.Parent = TabsContainer
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 12)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Tab
    
    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 15)
    Padding.PaddingBottom = UDim.new(0, 15)
    Padding.PaddingLeft = UDim.new(0, 15)
    Padding.PaddingRight = UDim.new(0, 15)
    Padding.Parent = Tab
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Tab.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 30)
    end)
    
    return Tab
end

local function createCard(parent, title, height)
    local Card = Instance.new("Frame")
    Card.BackgroundColor3 = Colors.Card
    Card.BorderSizePixel = 0
    Card.Size = UDim2.new(1, 0, 0, height or 100)
    Card.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Card
    
    local Border = Instance.new("UIStroke")
    Border.Color = Colors.Border
    Border.Thickness = 1
    Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Border.Parent = Card
    
    if title then
        local CardTitle = Instance.new("TextLabel")
        CardTitle.BackgroundTransparency = 1
        CardTitle.Position = UDim2.new(0, 18, 0, 15)
        CardTitle.Size = UDim2.new(1, -36, 0, 22)
        CardTitle.Font = Enum.Font.GothamBold
        CardTitle.Text = title
        CardTitle.TextColor3 = Colors.Text
        CardTitle.TextSize = 15
        CardTitle.TextXAlignment = Enum.TextXAlignment.Left
        CardTitle.Parent = Card
    end
    
    return Card
end

local function createToggle(parent, name, yPos, callback)
    local Frame = Instance.new("Frame")
    Frame.BackgroundTransparency = 1
    Frame.Position = UDim2.new(0, 18, 0, yPos)
    Frame.Size = UDim2.new(1, -36, 0, 38)
    Frame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, -65, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = name
    Label.TextColor3 = Colors.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local ToggleBg = Instance.new("Frame")
    ToggleBg.BackgroundColor3 = Colors.ToggleOff
    ToggleBg.BorderSizePixel = 0
    ToggleBg.Position = UDim2.new(1, -52, 0.5, -11)
    ToggleBg.Size = UDim2.new(0, 52, 0, 22)
    ToggleBg.Parent = Frame
    
    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(1, 0)
    BgCorner.Parent = ToggleBg
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.BackgroundColor3 = Colors.ToggleKnob
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Position = UDim2.new(0, 3, 0.5, -8)
    ToggleBtn.Size = UDim2.new(0, 16, 0, 16)
    ToggleBtn.Text = ""
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = ToggleBg
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(1, 0)
    BtnCorner.Parent = ToggleBtn
    
    local state = false
    
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        
        if state then
            TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Accent}):Play()
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -19, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ToggleOff}):Play()
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = Colors.ToggleKnob
            }):Play()
        end
        
        callback(state)
    end)
    
    return Frame
end

local function createButton(parent, name, yPos, callback)
    local Button = Instance.new("TextButton")
    Button.BackgroundColor3 = Colors.Accent
    Button.BorderSizePixel = 0
    Button.Position = UDim2.new(0, 18, 0, yPos)
    Button.Size = UDim2.new(1, -36, 0, 36)
    Button.Font = Enum.Font.GothamSemibold
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    Button.AutoButtonColor = false
    Button.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.AccentDark}):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Accent}):Play()
    end)
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

local function createSmallButton(parent, name, callback)
    local Button = Instance.new("TextButton")
    Button.BackgroundColor3 = Colors.Card
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, 0, 0, 32)
    Button.Font = Enum.Font.Gotham
    Button.Text = name
    Button.TextColor3 = Colors.Text
    Button.TextSize = 12
    Button.AutoButtonColor = false
    Button.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button
    
    local Border = Instance.new("UIStroke")
    Border.Color = Colors.Border
    Border.Thickness = 1
    Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Border.Parent = Button
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.CardHover}):Play()
        TweenService:Create(Border, TweenInfo.new(0.2), {Color = Colors.Accent}):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Card}):Play()
        TweenService:Create(Border, TweenInfo.new(0.2), {Color = Colors.Border}):Play()
    end)
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

-- ============================================================================
-- CREATE TABS
-- ============================================================================

-- Movement Tab
local MovementTab = createTabFrame("Movement")
local MovementCard = createCard(MovementTab, "Movement Controls", 240)

createToggle(MovementCard, "Fly + Noclip (Ctrl+F)", 50, function(state)
    flyEnabled = state
    if flyEnabled then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        startNoclip()
        startFly()
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        disconnectNoclip()
        disconnectFly()
        if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
            lplr.Character.HumanoidRootPart.Anchored = false
        end
    end
end)

createToggle(MovementCard, "WalkSpeed Boost (x2)", 93, function(state)
    walkSpeedEnabled = state
    if walkSpeedEnabled then
        startWalkSpeed()
    else
        stopWalkSpeed()
    end
end)

createToggle(MovementCard, "Infinite Stamina", 136, function(state)
    infiniteStaminaEnabled = state
    if infiniteStaminaEnabled then
        startInfiniteStamina()
    else
        stopInfiniteStamina()
    end
end)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.BackgroundTransparency = 1
InfoLabel.Position = UDim2.new(0, 18, 0, 185)
InfoLabel.Size = UDim2.new(1, -36, 0, 45)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Text = "Use WASD to move, Q/E for up/down\nCtrl+F to toggle fly on/off"
InfoLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
InfoLabel.TextSize = 12
InfoLabel.TextWrapped = true
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.Parent = MovementCard

-- Teleport Tab
local TeleportTab = createTabFrame("Teleport")

for i, location in ipairs(locations) do
    createSmallButton(TeleportTab, location.name, function()
        teleportToPosition(location.pos)
    end)
end

-- Game Tab
local GameTab = createTabFrame("Game")
local GameCard = createCard(GameTab, "Quick Actions", 170)

createButton(GameCard, "Skip Swipe Loading", 50, function()
    pcall(function()
        game.ReplicatedStorage.UI.SwipeLog:FireServer()
    end)
end)

createButton(GameCard, "Claim Daily Reward", 94, function()
    pcall(function()
        game.DailyRewards.ClaimDailyReward:FireServer()
    end)
end)

createButton(GameCard, "Rejoin Server", 138, function()
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, lplr)
    end)
end)

-- ============================================================================
-- TAB SWITCHING
-- ============================================================================

local tabs = {
    {name = "Movement", icon = "🚀", frame = MovementTab},
    {name = "Teleport", icon = "📍", frame = TeleportTab},
    {name = "Game", icon = "⚙️", frame = GameTab},
}

local sidebarButtons = {}

for i, tab in ipairs(tabs) do
    local btn, indicator, icon, label = createSidebarButton(tab.name, tab.icon, i, tab.name)
    
    sidebarButtons[tab.name] = {
        button = btn,
        indicator = indicator,
        icon = icon,
        label = label
    }
    
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabs) do
            t.frame.Visible = false
        end
        
        for _, sb in pairs(sidebarButtons) do
            sb.indicator.Visible = false
            TweenService:Create(sb.button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Card}):Play()
            TweenService:Create(sb.icon, TweenInfo.new(0.2), {TextColor3 = Colors.TextDim}):Play()
            TweenService:Create(sb.label, TweenInfo.new(0.2), {TextColor3 = Colors.TextDim}):Play()
        end
        
        currentTab = tab.name
        tab.frame.Visible = true
        sidebarButtons[tab.name].indicator.Visible = true
        TweenService:Create(sidebarButtons[tab.name].button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.CardHover}):Play()
        TweenService:Create(sidebarButtons[tab.name].icon, TweenInfo.new(0.2), {TextColor3 = Colors.Accent}):Play()
        TweenService:Create(sidebarButtons[tab.name].label, TweenInfo.new(0.2), {TextColor3 = Colors.Text}):Play()
    end)
end

-- Activate first tab
MovementTab.Visible = true
sidebarButtons["Movement"].indicator.Visible = true
sidebarButtons["Movement"].button.BackgroundColor3 = Colors.CardHover
sidebarButtons["Movement"].icon.TextColor3 = Colors.Accent
sidebarButtons["Movement"].label.TextColor3 = Colors.Text

-- ============================================================================
-- MINIMIZE & CLOSE
-- ============================================================================

local minimized = false
local originalSize = MainFrame.Size
local originalPos = MainFrame.Position

MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    
    if minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 300, 0, 50),
            Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 1, -70)
        }):Play()
        
        Sidebar.Visible = false
        ContentArea.Visible = false
        MinimizeButton.Text = "□"
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = originalSize,
            Position = originalPos
        }):Play()
        
        task.wait(0.15)
        Sidebar.Visible = true
        ContentArea.Visible = true
        MinimizeButton.Text = "_"
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ============================================================================
-- INPUT HANDLING
-- ============================================================================

UserInputService.InputBegan:Connect(function(key, processed)
    if processed then return end
    local keyStr = getkey(key.KeyCode)
    keys[keyStr .. "_active"] = true
    
    if key.KeyCode == Enum.KeyCode.F and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        flyEnabled = not flyEnabled
        if lplr.Character then
            if flyEnabled then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                startNoclip()
                startFly()
            else
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                disconnectNoclip()
                disconnectFly()
                if lplr.Character:FindFirstChild("HumanoidRootPart") then
                    lplr.Character.HumanoidRootPart.Anchored = false
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(key)
    keys[getkey(key.KeyCode) .. "_active"] = false
end)

lplr.CharacterAdded:Connect(function()
    task.wait(1)
    if flyEnabled then startNoclip() end
    startFly()
    if walkSpeedEnabled then startWalkSpeed() end
    if infiniteStaminaEnabled then startInfiniteStamina() end
end)

if lplr.Character then
    startFly()
end

print("✓ Delayed SL Panel Loaded!")
print("✓ Press Ctrl+F to toggle fly")