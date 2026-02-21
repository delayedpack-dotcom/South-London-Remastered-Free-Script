-- South London 2 Script Panel
-- Combined UI for all scripts with toggles and features

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

-- Connections
local flyConn, noclipConn, walkSpeedConn, staminaConn

-- Locations data
local locations = {
    {name = "Outkirts Of The Town", pos = Vector3.new(-565.38, 3.50954, -9.9876)},
    {name = "School", pos = Vector3.new(-337.95, 3.52999, 0.78420)},
    {name = "Near School", pos = Vector3.new(-399.46, 3.52999, 7.68115)},
    {name = "Spawn Location", pos = Vector3.new(-285.35, 3.23000, -293.59)},
    {name = "Met Station", pos = Vector3.new(-265.12, 3.47210, -145.16)},
    {name = "Near Fairbank Parking Garage", pos = Vector3.new(-27.689, 3.37999, -488.01)},
    {name = "Illegal Gunstore", pos = Vector3.new(80.4551, 3.22999, -669.13)},
    {name = "Petrol Station", pos = Vector3.new(256.612, 3.52599, -746.32)},
    {name = "Near The Football Field", pos = Vector3.new(-418.06, 3.52160, -216.62)},
    {name = "Behind Fairbank Parking Garage", pos = Vector3.new(215.989, 3.23000, -531.05)},
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

-- FLY FUNCTIONS
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

-- WALKSPEED FUNCTIONS
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

-- STAMINA FUNCTIONS
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

-- TELEPORT FUNCTION
local function teleportTo(position)
    pcall(function()
        local character = lplr.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(position)
        end
    end)
end

-- UI CREATION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SouthLondonPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Check if UI already exists and remove it
if lplr.PlayerGui:FindFirstChild("SouthLondonPanel") then
    lplr.PlayerGui.SouthLondonPanel:Destroy()
end

ScreenGui.Parent = lplr.PlayerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -275)
MainFrame.Size = UDim2.new(0, 500, 0, 550)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Corner
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Shadow
local Shadow = Instance.new("Frame")
Shadow.Name = "Shadow"
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.7
Shadow.BorderSizePixel = 0
Shadow.Position = UDim2.new(0, 5, 0, 5)
Shadow.Size = UDim2.new(1, 0, 1, 0)
Shadow.ZIndex = 0
Shadow.Parent = MainFrame
local ShadowCorner = Corner:Clone()
ShadowCorner.Parent = Shadow

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Title fix for bottom corners
local TitleFix = Instance.new("Frame")
TitleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Parent = TitleBar

-- Title Text
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "South London 2 Panel"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -35, 0.5, -12)
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Content Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ScrollBarThickness = 6
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
ContentFrame.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentFrame

ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
end)

-- Function to create section
local function createSection(title)
    local Section = Instance.new("Frame")
    Section.Name = title .. "Section"
    Section.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    Section.BorderSizePixel = 0
    Section.Size = UDim2.new(1, 0, 0, 40)
    Section.Parent = ContentFrame
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 8)
    SectionCorner.Parent = Section
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Position = UDim2.new(0, 12, 0, 0)
    SectionTitle.Size = UDim2.new(1, -24, 1, 0)
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.Text = title
    SectionTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
    SectionTitle.TextSize = 16
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Parent = Section
    
    return Section
end

-- Function to create toggle button
local function createToggle(name, callback)
    local Toggle = Instance.new("Frame")
    Toggle.Name = name .. "Toggle"
    Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    Toggle.BorderSizePixel = 0
    Toggle.Size = UDim2.new(1, 0, 0, 45)
    Toggle.Parent = ContentFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = Toggle
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
    ToggleLabel.Size = UDim2.new(1, -70, 1, 0)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    ToggleLabel.TextSize = 14
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = Toggle
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Button"
    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Position = UDim2.new(1, -55, 0.5, -12)
    ToggleButton.Size = UDim2.new(0, 45, 0, 24)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Text = "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    ToggleButton.TextSize = 12
    ToggleButton.Parent = Toggle
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = ToggleButton
    
    local state = false
    ToggleButton.MouseButton1Click:Connect(function()
        state = not state
        if state then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
            ToggleButton.Text = "ON"
            ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            ToggleButton.Text = "OFF"
            ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        callback(state)
    end)
    
    return Toggle
end

-- Function to create button
local function createButton(name, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name .. "Button"
    Button.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.Font = Enum.Font.GothamBold
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Parent = ContentFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

-- Create UI Elements
createSection("🚀 Movement")

createToggle("Fly + Noclip (Ctrl+F)", function(state)
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

createToggle("WalkSpeed Boost", function(state)
    walkSpeedEnabled = state
    if walkSpeedEnabled then
        startWalkSpeed()
    else
        stopWalkSpeed()
    end
end)

createToggle("Infinite Stamina", function(state)
    infiniteStaminaEnabled = state
    if infiniteStaminaEnabled then
        startInfiniteStamina()
    else
        stopInfiniteStamina()
    end
end)

createSection("📍 Teleports")

-- Create teleport buttons for each location
for i, location in ipairs(locations) do
    createButton(location.name, function()
        teleportTo(location.pos)
    end)
end

createSection("⚙️ Game Functions")

createButton("Skip Swipe Loading", function()
    pcall(function()
        game.ReplicatedStorage.UI.SwipeLog:FireServer()
    end)
end)

createButton("Claim Daily Reward", function()
    pcall(function()
        game.DailyRewards.ClaimDailyReward:FireServer()
    end)
end)

-- Key Input Handler
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

-- Character respawn handler
lplr.CharacterAdded:Connect(function()
    task.wait(1)
    if flyEnabled then
        startNoclip()
    end
    startFly()
    if walkSpeedEnabled then
        startWalkSpeed()
    end
    if infiniteStaminaEnabled then
        startInfiniteStamina()
    end
end)

-- Initial setup
if lplr.Character then
    startFly()
end

print("South London 2 Panel Loaded!")
print("Press Ctrl+F to toggle fly, or use the GUI")