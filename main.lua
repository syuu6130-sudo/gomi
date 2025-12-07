-- Teleport GUI v2.0
-- By syu_u
-- コンパクトで直感的なUI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 既存のGUIを削除
local oldGui = playerGui:FindFirstChild("TeleportGUI")
if oldGui then oldGui:Destroy() end

-- メインGUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- コンパクトなメインフレーム
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 45)
mainFrame.Position = UDim2.new(0.5, -90, 0.05, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = mainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 70)
UIStroke.Thickness = 2
UIStroke.Parent = mainFrame

-- 番号表示と操作ボタン
local numberDisplay = Instance.new("TextButton")
numberDisplay.Size = UDim2.new(0, 40, 0, 40)
numberDisplay.Position = UDim2.new(0, 5, 0, 2.5)
numberDisplay.Text = "1"
numberDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
numberDisplay.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
numberDisplay.AutoButtonColor = false
numberDisplay.Font = Enum.Font.GothamBold
numberDisplay.TextSize = 18
numberDisplay.Parent = mainFrame

local numberCorner = Instance.new("UICorner")
numberCorner.CornerRadius = UDim.new(0, 6)
numberCorner.Parent = numberDisplay

local numberStroke = Instance.new("UIStroke")
numberStroke.Color = Color3.fromRGB(80, 80, 90)
numberStroke.Thickness = 1
numberStroke.Parent = numberDisplay

-- ボタン群
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(0, 125, 0, 40)
buttonContainer.Position = UDim2.new(0, 50, 0, 2.5)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

local buttonLayout = Instance.new("UIGridLayout")
buttonContainer:ClearAllChildren()
buttonLayout.CellPadding = UDim2.new(0, 5, 0, 0)
buttonLayout.CellSize = UDim2.new(0.33, -4, 1, 0)
buttonLayout.FillDirection = Enum.FillDirection.Horizontal
buttonLayout.Parent = buttonContainer

-- ボタン作成関数
local function createButton(text, color)
    local button = Instance.new("TextButton")
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = color
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.AutoButtonColor = false
    button.Parent = buttonContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color:lerp(Color3.new(0, 0, 0), 0.3)
    stroke.Thickness = 1
    stroke.Parent = button
    
    return button
end

-- ボタン作成
local saveBtn = createButton("SAVE", Color3.fromRGB(46, 204, 113))
local delBtn = createButton("DEL", Color3.fromRGB(231, 76, 60))
local tpBtn = createButton("TP", Color3.fromRGB(52, 152, 219))

-- 右クリックメニュー（番号選択用）
local rightClickMenu = Instance.new("Frame")
rightClickMenu.Size = UDim2.new(0, 160, 0, 0)
rightClickMenu.Position = UDim2.new(0, 0, 1, 5)
rightClickMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
rightClickMenu.Visible = false
rightClickMenu.Parent = numberDisplay

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 8)
menuCorner.Parent = rightClickMenu

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = Color3.fromRGB(60, 60, 70)
menuStroke.Thickness = 2
menuStroke.Parent = rightClickMenu

local menuLayout = Instance.new("UIGridLayout")
menuLayout.CellPadding = UDim2.new(0, 5, 0, 5)
menuLayout.CellSize = UDim2.new(0, 30, 0, 30)
menuLayout.FillDirection = Enum.FillDirection.Horizontal
menuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
menuLayout.Parent = rightClickMenu

-- メニューアイテム作成
local menuItems = {}
for i = 1, 10 do
    local item = Instance.new("TextButton")
    item.Text = tostring(i)
    item.Size = UDim2.new(0, 30, 0, 30)
    item.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    item.TextColor3 = Color3.fromRGB(255, 255, 255)
    item.Font = Enum.Font.GothamBold
    item.TextSize = 14
    item.Parent = rightClickMenu
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 6)
    itemCorner.Parent = item
    
    menuItems[i] = item
end

-- データ
local savedPositions = {}
local currentNumber = 1

-- アニメーション関数
local function tweenColor(obj, property, targetColor)
    local tween = TweenService:Create(obj, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        [property] = targetColor
    })
    tween:Play()
end

-- 番号表示更新
local function updateDisplay()
    numberDisplay.Text = tostring(currentNumber)
    
    if savedPositions[currentNumber] then
        numberDisplay.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- 緑
    else
        numberDisplay.BackgroundColor3 = Color3.fromRGB(50, 50, 60) -- デフォルト
    end
    
    -- メニューアイテムの色も更新
    for i, item in ipairs(menuItems) do
        if savedPositions[i] then
            item.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        else
            item.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        end
    end
end

-- 番号選択（右クリックメニュー）
numberDisplay.MouseButton2Click:Connect(function()
    rightClickMenu.Visible = not rightClickMenu.Visible
    if rightClickMenu.Visible then
        rightClickMenu.Size = UDim2.new(0, 160, 0, 80)
    end
end)

-- メニュー外クリックで閉じる
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if rightClickMenu.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = rightClickMenu.AbsolutePosition
            local absSize = rightClickMenu.AbsoluteSize
            
            if not (mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
                   mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y) then
                rightClickMenu.Visible = false
            end
        end
    end
end)

-- メニューアイテムクリック
for i, item in ipairs(menuItems) do
    item.MouseButton1Click:Connect(function()
        currentNumber = i
        updateDisplay()
        rightClickMenu.Visible = false
    end)
end

-- ホイールで番号変更
numberDisplay.MouseWheelForward:Connect(function()
    currentNumber = (currentNumber % 10) + 1
    updateDisplay()
end)

numberDisplay.MouseWheelBackward:Connect(function()
    currentNumber = currentNumber == 1 and 10 or currentNumber - 1
    updateDisplay()
end)

-- ボタン操作
local function characterValid()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0
end

-- 保存
saveBtn.MouseEnter:Connect(function()
    tweenColor(saveBtn, "BackgroundColor3", Color3.fromRGB(56, 214, 123))
end)

saveBtn.MouseLeave:Connect(function()
    tweenColor(saveBtn, "BackgroundColor3", Color3.fromRGB(46, 204, 113))
end)

saveBtn.MouseButton1Click:Connect(function()
    if characterValid() then
        savedPositions[currentNumber] = player.Character.HumanoidRootPart.CFrame
        
        -- 視覚的フィードバック
        tweenColor(numberDisplay, "BackgroundColor3", Color3.fromRGB(86, 244, 153))
        task.wait(0.1)
        updateDisplay()
        
        -- 通知音（オプション）
        if game:GetService("SoundService").RespectFilteringEnabled then
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://3570576881" -- 保存成功音
            sound.Volume = 0.3
            sound.Parent = game.Workspace
            sound:Play()
            game.Debris:AddItem(sound, 2)
        end
    end
end)

-- 削除
delBtn.MouseEnter:Connect(function()
    tweenColor(delBtn, "BackgroundColor3", Color3.fromRGB(241, 96, 80))
end)

delBtn.MouseLeave:Connect(function()
    tweenColor(delBtn, "BackgroundColor3", Color3.fromRGB(231, 76, 60))
end)

delBtn.MouseButton1Click:Connect(function()
    savedPositions[currentNumber] = nil
    updateDisplay()
    
    -- 視覚的フィードバック
    tweenColor(numberDisplay, "BackgroundColor3", Color3.fromRGB(231, 76, 60))
    task.wait(0.1)
    updateDisplay()
end)

-- テレポート
tpBtn.MouseEnter:Connect(function()
    tweenColor(tpBtn, "BackgroundColor3", Color3.fromRGB(62, 172, 239))
end)

tpBtn.MouseLeave:Connect(function()
    tweenColor(tpBtn, "BackgroundColor3", Color3.fromRGB(52, 152, 219))
end)

tpBtn.MouseButton1Click:Connect(function()
    if savedPositions[currentNumber] and characterValid() then
        player.Character.HumanoidRootPart.CFrame = savedPositions[currentNumber]
        
        -- 視覚的フィードバック
        tweenColor(numberDisplay, "BackgroundColor3", Color3.fromRGB(142, 202, 255))
        task.wait(0.1)
        updateDisplay()
    end
end)

-- キーボードショートカット
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Q then
        currentNumber = currentNumber == 1 and 10 or currentNumber - 1
        updateDisplay()
    elseif input.KeyCode == Enum.KeyCode.E then
        currentNumber = (currentNumber % 10) + 1
        updateDisplay()
    elseif input.KeyCode == Enum.KeyCode.One then
        currentNumber = 1
        updateDisplay()
    elseif input.KeyCode == Enum.KeyCode.Two then
        currentNumber = 2
        updateDisplay()
    elseif input.KeyCode == Enum.KeyCode.Three then
        currentNumber = 3
        updateDisplay()
    elseif input.KeyCode == Enum.KeyCode.Four then
        currentNumber = 4
        updateDisplay()
    elseif input.KeyCode == Enum.KeyCode.Five then
        currentNumber = 5
        updateDisplay()
    end
end)

-- ダブルクリックでGUIを隠す/表示
local lastClickTime = 0
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local currentTime = tick()
        if currentTime - lastClickTime < 0.3 then
            mainFrame.Visible = not mainFrame.Visible
        end
        lastClickTime = currentTime
    end
end)

-- 初期化
updateDisplay()

-- 追加：マウスオーバーで影
mainFrame.MouseEnter:Connect(function()
    tweenColor(UIStroke, "Color", Color3.fromRGB(80, 80, 90))
end)

mainFrame.MouseLeave:Connect(function()
    tweenColor(UIStroke, "Color", Color3.fromRGB(60, 60, 70))
end)

print("Teleport GUI v2.0 loaded | By syu_u")
print("Controls:")
print("  Drag: Move GUI")
print("  Double-click: Hide/Show")
print("  Mouse wheel on number: Change slot")
print("  Right-click on number: Quick select")
print("  Q/E: Previous/Next slot")
print("  1-5: Quick slot select")
