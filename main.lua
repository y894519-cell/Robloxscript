-- 1. Game Check
local TargetID = 14004668761
if game.PlaceId ~= TargetID and game.GameId ~= TargetID then 
    return 
end

-- 2. Configuration & State
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Sidebar = Instance.new("Frame")

local reachEnabled, reachValue = false, 0
local speedEnabled, walkSpeedValue = false, 0 
local powerBallEnabled, powerValue = false, 0
local gkReachEnabled, gkReachValue = false, 0
local selectedColor = Color3.new(1, 1, 1)
local playerVisualizer = nil 

-- GK Indicator UI (The "I'm in GK mode" badge)
local GKIndicator = Instance.new("TextLabel")
GKIndicator.Size = UDim2.new(0, 100, 0, 30)
GKIndicator.Position = UDim2.new(0.5, -50, 0, 50)
GKIndicator.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
GKIndicator.Text = "GK REACH: ON"
GKIndicator.TextColor3 = Color3.new(1, 1, 1)
GKIndicator.Font = Enum.Font.SourceSansBold
GKIndicator.TextSize = 14
GKIndicator.Visible = false
GKIndicator.Parent = ScreenGui
local GKCorner = Instance.new("UICorner", GKIndicator)
GKCorner.CornerRadius = UDim.new(0, 8)

local function KillShadow(obj)
    if obj:IsA("GuiObject") then
        obj.BorderSizePixel = 0
        if obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.SelectionImageObject = Instance.new("Frame")
            obj.SelectionImageObject.Transparency = 1
        end
    end
end

local function Round(obj, amount)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, amount or 8)
    corner.Parent = obj
end

ScreenGui.Name = "FinalExecutor_v53"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- 3. Main UI Layout
MainFrame.Size = UDim2.new(0, 480, 0, 400)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
KillShadow(MainFrame)
Round(MainFrame, 12)

-- Exit Warning
local ExitWarn = Instance.new("Frame")
ExitWarn.Size = UDim2.new(0, 280, 0, 140)
ExitWarn.Position = UDim2.new(0.5, -140, 0.5, -70)
ExitWarn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ExitWarn.ZIndex = 10
ExitWarn.Visible = false
ExitWarn.Parent = MainFrame
Round(ExitWarn, 10)

local WarnLabel = Instance.new("TextLabel")
WarnLabel.Size, WarnLabel.BackgroundTransparency = UDim2.new(1, 0, 0, 60), 1
WarnLabel.Text = "Are you sure you want to\nclose the script?"
WarnLabel.TextColor3, WarnLabel.Font, WarnLabel.TextSize = Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 18
WarnLabel.ZIndex = 11
WarnLabel.Parent = ExitWarn

local YesBtn = Instance.new("TextButton")
YesBtn.Size, YesBtn.Position = UDim2.new(0, 110, 0, 45), UDim2.new(0.08, 0, 0.55, 0)
YesBtn.BackgroundColor3, YesBtn.Text = Color3.fromRGB(46, 204, 113), "YES"
YesBtn.TextColor3, YesBtn.Font, YesBtn.TextSize = Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 22
YesBtn.ZIndex = 11
YesBtn.Parent = ExitWarn
Round(YesBtn, 8)

local NoBtn = Instance.new("TextButton")
NoBtn.Size, NoBtn.Position = UDim2.new(0, 110, 0, 45), UDim2.new(0.53, 0, 0.55, 0)
NoBtn.BackgroundColor3, NoBtn.Text = Color3.fromRGB(231, 76, 60), "NO"
NoBtn.TextColor3, NoBtn.Font, NoBtn.TextSize = Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 22
NoBtn.ZIndex = 11
NoBtn.Parent = ExitWarn
Round(NoBtn, 8)

-- Control Circles
local CloseCircle = Instance.new("TextButton")
CloseCircle.Size, CloseCircle.Position = UDim2.new(0, 18, 0, 18), UDim2.new(1, -25, 0, 10)
CloseCircle.BackgroundColor3, CloseCircle.Text, CloseCircle.Parent = Color3.fromRGB(50, 50, 50), "", MainFrame
Round(CloseCircle, 10)

local DragCircle = Instance.new("TextButton")
DragCircle.Size, DragCircle.Position = UDim2.new(0, 14, 0, 14), UDim2.new(1, -23, 0, 32)
DragCircle.BackgroundColor3, DragCircle.Text, DragCircle.Parent = Color3.fromRGB(80, 80, 80), "", MainFrame
Round(DragCircle, 10)

CloseCircle.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

Sidebar.Size, Sidebar.BackgroundColor3 = UDim2.new(0, 120, 1, 0), Color3.fromRGB(20, 20, 20)
Sidebar.Parent = MainFrame
Round(Sidebar, 12)

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding, SidebarList.HorizontalAlignment = UDim.new(0, 8), Enum.HorizontalAlignment.Center
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

local function CreatePage(name)
    local f = Instance.new("ScrollingFrame")
    f.Name = name.."Page"
    f.Size = UDim2.new(1, -135, 1, -20)
    f.Position = UDim2.new(0, 125, 0, 10)
    f.BackgroundTransparency, f.ScrollBarThickness, f.Visible = 1, 0, false
    f.Parent = MainFrame
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 15)
    return f
end

local BallPage = CreatePage("Ball")
local PlayerPage = CreatePage("Player")
local GKPage = CreatePage("GK")

-- 4. Sidebar Nav
local navButtons = {}
local activeNavColor = Color3.fromRGB(0, 120, 255)
local idleNavColor = Color3.fromRGB(35, 35, 35)

local function UpdateNavColors(activeName)
    for name, btn in pairs(navButtons) do
        if name == "Exit" then continue end
        btn.BackgroundColor3 = (name == activeName) and activeNavColor or idleNavColor
    end
end

local function NavBtn(txt, order, cb, isExit)
    local b = Instance.new("TextButton", Sidebar)
    b.Size, b.LayoutOrder = UDim2.new(0.85, 0, 0, 35), order
    b.BackgroundColor3 = isExit and Color3.fromRGB(100, 0, 0) or idleNavColor
    b.Text, b.TextColor3, b.Font, b.TextSize = txt, Color3.new(1,1,1), Enum.Font.SourceSansBold, 14
    Round(b, 6)
    navButtons[txt] = b
    b.MouseButton1Click:Connect(function()
        cb()
        if not isExit then UpdateNavColors(txt) end
    end)
end

NavBtn("Ball", 1, function() BallPage.Visible, PlayerPage.Visible, GKPage.Visible = true, false, false end)
NavBtn("Player", 2, function() BallPage.Visible, PlayerPage.Visible, GKPage.Visible = false, true, false end)
NavBtn("GK", 3, function() BallPage.Visible, PlayerPage.Visible, GKPage.Visible = false, false, true end)
NavBtn("Exit", 4, function() ExitWarn.Visible = true end, true)

-- 5. Logic Loop
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = game.Players.LocalPlayer

RunService.Heartbeat:Connect(function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if speedEnabled then
        root.CFrame = root.CFrame + (hum.MoveDirection * (walkSpeedValue * 0.04))
    end

    local finalReach = 0
    if reachEnabled then finalReach = reachValue end
    if gkReachEnabled and gkReachValue > finalReach then finalReach = gkReachValue end

    if finalReach > 0 then
        if not playerVisualizer then
            playerVisualizer = Instance.new("Part", workspace)
            playerVisualizer.CastShadow, playerVisualizer.CanCollide, playerVisualizer.Anchored = false, false, true
            playerVisualizer.Material = Enum.Material.Neon
        end
        playerVisualizer.Transparency, playerVisualizer.Color = 0.8, selectedColor
        playerVisualizer.Size, playerVisualizer.CFrame = Vector3.new(finalReach, finalReach, finalReach), root.CFrame
        
        local parts = workspace:GetPartBoundsInBox(root.CFrame, Vector3.new(finalReach, finalReach, finalReach))
        for _, part in pairs(parts) do
            if part.Name ~= "Baseplate" and not part:IsDescendantOf(char) then
                firetouchinterest(root, part, 0)
                firetouchinterest(root, part, 1)
            end
        end
    elseif playerVisualizer then playerVisualizer.Transparency = 1 end
end)

-- 6. UI Creation
local function CreateHackSection(parent, title, sectionType)
    local container = Instance.new("Frame")
    container.Size, container.BackgroundColor3 = UDim2.new(0.95, 0, 0, 120), Color3.fromRGB(10, 10, 10)
    container.Parent = parent
    Round(container, 10)
    
    local label = Instance.new("TextLabel")
    label.Size, label.Position = UDim2.new(0.5, 0, 0, 35), UDim2.new(0.05, 0, 0, 5)
    label.BackgroundTransparency, label.TextColor3, label.Text = 1, Color3.new(1,1,1), title
    label.Font, label.TextSize, label.Parent = Enum.Font.SourceSansBold, 16, container

    local swBG = Instance.new("TextButton")
    swBG.Size, swBG.Position = UDim2.new(0, 44, 0, 22), UDim2.new(0.92, -44, 0, 12)
    swBG.BackgroundColor3, swBG.Text, swBG.Parent = Color3.fromRGB(30, 30, 30), "", container
    Round(swBG, 11)

    local swCirc = Instance.new("Frame")
    swCirc.Size, swCirc.Position = UDim2.new(0, 16, 0, 16), UDim2.new(0, 3, 0.5, -8)
    swCirc.BackgroundColor3, swCirc.Parent = Color3.new(1,1,1), swBG
    Round(swCirc, 8)

    local scrollContent = Instance.new("ScrollingFrame")
    scrollContent.Size, scrollContent.Position = UDim2.new(0.9, 0, 0, 70), UDim2.new(0.05, 0, 0, 40)
    scrollContent.BackgroundTransparency, scrollContent.ScrollBarThickness, scrollContent.Visible = 1, 2, false
    scrollContent.CanvasSize, scrollContent.Parent = UDim2.new(0, 0, 1.5, 0), container
    Instance.new("UIListLayout", scrollContent).Padding = UDim.new(0, 10)

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size, sliderFrame.BackgroundTransparency, sliderFrame.Parent = UDim2.new(1, 0, 0, 30), 1, scrollContent

    local back = Instance.new("Frame")
    back.Size, back.Position = UDim2.new(0.8, 0, 0, 4), UDim2.new(0, 0, 0.5, 0)
    back.BackgroundColor3, back.Parent = Color3.fromRGB(40, 40, 40), sliderFrame
    Round(back, 2)

    local sliBtn = Instance.new("TextButton")
    sliBtn.Size, sliBtn.Position = UDim2.new(0, 12, 0, 12), UDim2.new(0, 0, 0.5, -6)
    sliBtn.BackgroundColor3, sliBtn.Text, sliBtn.Parent = Color3.new(1,1,1), "", back
    Round(sliBtn, 6)

    local valLab = Instance.new("TextLabel")
    valLab.Size, valLab.Position = UDim2.new(0, 35, 0, 20), UDim2.new(1, 5, 0.5, -10)
    valLab.TextColor3, valLab.Text, valLab.Parent = Color3.new(1,1,1), "0", back

    if sectionType == "reach" then
        local colorFrame = Instance.new("Frame")
        colorFrame.Size, colorFrame.BackgroundTransparency, colorFrame.Parent = UDim2.new(1, 0, 0, 30), 1, scrollContent
        local colors = {Color3.new(1,1,1), Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,1,0), Color3.new(1,0,1)}
        for i, col in pairs(colors) do
            local cBtn = Instance.new("TextButton")
            cBtn.Size, cBtn.Position = UDim2.new(0, 20, 0, 20), UDim2.new(0, (i-1)*25, 0.5, -10)
            cBtn.BackgroundColor3, cBtn.Text, cBtn.Parent = col, "", colorFrame
            Round(cBtn, 4)
            cBtn.MouseButton1Click:Connect(function() selectedColor = col end)
        end
    end

    return swBG, swCirc, sliBtn, back, valLab, scrollContent
end

local Rsw, Rcirc, Rsli, Rback, Rval, Rscroll = CreateHackSection(PlayerPage, "Reach", "reach")
local Ssw, Scirc, Ssli, Sback, Sval, Sscroll = CreateHackSection(PlayerPage, "Speed Mode", "speed")
local Bsw, Bcirc, Bsli, Bback, Bval, Bscroll = CreateHackSection(BallPage, "Power Ball", "powerball")
local Gsw, Gcirc, Gsli, Gback, Gval, Gscroll = CreateHackSection(GKPage, "GK Reach", "gkreach")

-- 7. Functionality Wiring
local function HandleSlider(button, back, min, max, callback)
    local drag = false
    button.MouseButton1Down:Connect(function() drag = true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    UIS.InputChanged:Connect(function(input)
        if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - back.AbsolutePosition.X) / back.AbsoluteSize.X, 0, 1)
            button.Position = UDim2.new(rel, -6, 0.5, -6)
            local val = math.floor((min + (rel * (max - min))) * 10) / 10
            callback(val)
        end
    end)
end

local function SetupToggle(btn, circ, scroll, type)
    btn.MouseButton1Click:Connect(function()
        local active = false
        if type == "reach" then reachEnabled = not reachEnabled active = reachEnabled
        elseif type == "speed" then speedEnabled = not speedEnabled active = speedEnabled
        elseif type == "powerball" then powerBallEnabled = not powerBallEnabled active = powerBallEnabled
        elseif type == "gkreach" then 
            gkReachEnabled = not gkReachEnabled 
            active = gkReachEnabled
            GKIndicator.Visible = active -- SHOW THE NEW GK INDICATOR UI
        end
        scroll.Visible = active
        game:GetService("TweenService"):Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = active and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(30, 30, 30)}):Play()
        game:GetService("TweenService"):Create(circ, TweenInfo.new(0.2), {Position = active and UDim2.new(0, 25, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
    end)
end

SetupToggle(Rsw, Rcirc, Rscroll, "reach")
SetupToggle(Ssw, Scirc, Sscroll, "speed")
SetupToggle(Bsw, Bcirc, Bscroll, "powerball")
SetupToggle(Gsw, Gcirc, Gscroll, "gkreach")

HandleSlider(Rsli, Rback, 0, 40, function(v) reachValue = v Rval.Text = v end)
HandleSlider(Ssli, Sback, 0, 15, function(v) walkSpeedValue = v Sval.Text = v end)
HandleSlider(Bsli, Bback, 0, 100, function(v) powerValue = v Bval.Text = v end)
HandleSlider(Gsli, Gback, 0, 60, function(v) gkReachValue = v Gval.Text = v end)

-- Dragging & Logic
NoBtn.MouseButton1Click:Connect(function() ExitWarn.Visible = false end)
YesBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() if playerVisualizer then playerVisualizer:Destroy() end end)

local dragging, dragStart, startPos
DragCircle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, input.Position, MainFrame.Position end end)
UIS.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragStart MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightAlt then MainFrame.Visible = not MainFrame.Visible end
end)

UpdateNavColors("Player")
PlayerPage.Visible = true
