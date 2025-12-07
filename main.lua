-- Teleport GUI (by.miraitakesi_2022)
-- 改良版

local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 既存のGUIを削除
local oldGui = playerGui:FindFirstChild("CustomGui")
if oldGui then
    oldGui:Destroy()
end

-- メインGUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- トップバー
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(0, 280, 0, 30) -- 少し大きく
topBar.Position = UDim2.new(0.5, -140, 0.5, -120)
topBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70) -- よりモダンな色
topBar.Active = true
topBar.Draggable = true
topBar.Parent = screenGui

-- 角丸を追加（オプション）
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 5)
UICorner.Parent = topBar

-- タイトル
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -30, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = "Teleport GUI (By miraitakesi)"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220) -- 明るい色
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = topBar

-- トグルボタン
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 30, 0, 30)
toggleButton.Position = UDim2.new(1, -30, 0, 0)
toggleButton.Text = "-"
toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
toggleButton.TextColor3 = Color3.fromRGB(220, 220, 220)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 18
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 5)
toggleCorner.Parent = toggleButton
toggleButton.Parent = topBar

-- メインフレーム
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 120) -- 高さを増加
mainFrame.Position = UDim2.new(0, 0, 1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
mainFrame.Parent = topBar

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 5)
mainCorner.Parent = mainFrame

-- 矢印ボタンと番号選択
local numberControlFrame = Instance.new("Frame")
numberControlFrame.Size = UDim2.new(1, -20, 0, 40)
numberControlFrame.Position = UDim2.new(0, 10, 0, 10)
numberControlFrame.BackgroundTransparency = 1
numberControlFrame.Parent = mainFrame

local leftArrow = Instance.new("TextButton")
leftArrow.Size = UDim2.new(0, 40, 0, 40)
leftArrow.Position = UDim2.new(0, 0, 0, 0)
leftArrow.Text = "◀"
leftArrow.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
leftArrow.TextColor3 = Color3.fromRGB(220, 220, 220)
leftArrow.Font = Enum.Font.GothamBold
leftArrow.TextSize = 20
local leftCorner = Instance.new("UICorner")
leftCorner.CornerRadius = UDim.new(0, 5)
leftCorner.Parent = leftArrow
leftArrow.Parent = numberControlFrame

local numberBox = Instance.new("TextBox")
numberBox.Size = UDim2.new(0, 80, 0, 40)
numberBox.Position = UDim2.new(0, 50, 0, 0)
numberBox.Text = "1"
numberBox.TextColor3 = Color3.fromRGB(220, 220, 220)
numberBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
numberBox.PlaceholderText = "1-10"
numberBox.ClearTextOnFocus = false
numberBox.TextScaled = true
numberBox.Font = Enum.Font.GothamBold
local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 5)
boxCorner.Parent = numberBox
numberBox.Parent = numberControlFrame

local rightArrow = Instance.new("TextButton")
rightArrow.Size = UDim2.new(0, 40, 0, 40)
rightArrow.Position = UDim2.new(0, 140, 0, 0)
rightArrow.Text = "▶"
rightArrow.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
rightArrow.TextColor3 = Color3.fromRGB(220, 220, 220)
rightArrow.Font = Enum.Font.GothamBold
rightArrow.TextSize = 20
local rightCorner = Instance.new("UICorner")
rightCorner.CornerRadius = UDim.new(0, 5)
rightCorner.Parent = rightArrow
rightArrow.Parent = numberControlFrame

local savedLabel = Instance.new("TextLabel")
savedLabel.Size = UDim2.new(0, 90, 0, 40)
savedLabel.Position = UDim2.new(0, 190, 0, 0)
savedLabel.BackgroundTransparency = 1
savedLabel.TextXAlignment = Enum.TextXAlignment.Left
savedLabel.Text = ""
savedLabel.TextColor3 = Color3.fromRGB(46, 204, 113) -- 緑色で保存状態を示す
savedLabel.Font = Enum.Font.Gotham
savedLabel.TextSize = 14
savedLabel.Parent = numberControlFrame

-- ボタンフレーム
local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(1, -20, 0, 40)
buttonFrame.Position = UDim2.new(0, 10, 0, 70)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = mainFrame

local function createButton(name, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.32, -5, 1, 0)
    button.Position = position
    button.Text = name
    button.BackgroundColor3 = Color3.fromRGB(52, 152, 219) -- 青色
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 5)
    buttonCorner.Parent = button
    button.Parent = buttonFrame
    return button
end

local setButton = createButton("保存", UDim2.new(0, 0, 0, 0))
local deleteButton = createButton("削除", UDim2.new(0.34, 0, 0, 0))
local tpButton = createButton("テレポート", UDim2.new(0.68, 0, 0, 0))

-- データ保存
local savedPositions = {}
local currentNumber = 1

-- 番号表示の更新
local function updateNumberDisplay()
    numberBox.Text = tostring(currentNumber)
    if savedPositions[currentNumber] then
        savedLabel.Text = "✓ 保存済み"
        savedLabel.TextColor3 = Color3.fromRGB(46, 204, 113) -- 緑
    else
        savedLabel.Text = "未保存"
        savedLabel.TextColor3 = Color3.fromRGB(220, 220, 220) -- 白
    end
end

-- 有効な番号かチェック
local function isValidNumber(num)
    return num and num >= 1 and num <= 10 and math.floor(num) == num
end

-- キャラクターが有効かチェック
local function isValidCharacter()
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart") and character.Humanoid.Health > 0
end

-- 左矢印クリック
leftArrow.MouseButton1Click:Connect(function()
    currentNumber = (currentNumber == 1) and 10 or (currentNumber - 1)
    updateNumberDisplay()
end)

-- 右矢印クリック
rightArrow.MouseButton1Click:Connect(function()
    currentNumber = (currentNumber == 10) and 1 or (currentNumber + 1)
    updateNumberDisplay()
end)

-- 番号ボックス変更
numberBox.FocusLost:Connect(function(enterPressed)
    local num = tonumber(numberBox.Text)
    if isValidNumber(num) then
        currentNumber = num
    else
        currentNumber = 1
        -- エラーメッセージ表示（簡易的）
        numberBox.Text = "1-10のみ"
        task.wait(0.5)
    end
    updateNumberDisplay()
end)

-- 保存ボタン
setButton.MouseButton1Click:Connect(function()
    if isValidCharacter() then
        savedPositions[currentNumber] = player.Character.HumanoidRootPart.CFrame
        updateNumberDisplay()
        
        -- 視覚的フィードバック
        setButton.Text = "✓"
        setButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        task.wait(0.3)
        setButton.Text = "保存"
        setButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
    else
        warn("キャラクターが無効です")
    end
end)

-- 削除ボタン
deleteButton.MouseButton1Click:Connect(function()
    savedPositions[currentNumber] = nil
    updateNumberDisplay()
    
    -- 視覚的フィードバック
    deleteButton.Text = "✓"
    deleteButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    task.wait(0.3)
    deleteButton.Text = "削除"
    deleteButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
end)

-- テレポートボタン
tpButton.MouseButton1Click:Connect(function()
    if savedPositions[currentNumber] and isValidCharacter() then
        local position = savedPositions[currentNumber]
        
        -- テレポート実行
        player.Character.HumanoidRootPart.CFrame = position
        
        -- 視覚的フィードバック
        tpButton.Text = "✓"
        tpButton.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
        task.wait(0.3)
        tpButton.Text = "テレポート"
        tpButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
    else
        warn("保存された位置がないか、キャラクターが無効です")
    end
end)

-- トグルボタン
local isHidden = false
toggleButton.MouseButton1Click:Connect(function()
    isHidden = not isHidden
    mainFrame.Visible = not isHidden
    toggleButton.Text = isHidden and "+" or "-"
    
    -- トグル時のアニメーション効果
    toggleButton.BackgroundColor3 = isHidden and 
        Color3.fromRGB(90, 90, 100) or 
        Color3.fromRGB(80, 80, 90)
end)

-- 初期化
updateNumberDisplay()

-- 追加機能：キーボードショートカット（オプション）
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightBracket then
        -- 次の番号へ
        currentNumber = (currentNumber == 10) and 1 or (currentNumber + 1)
        updateNumberDisplay()
    elseif input.KeyCode == Enum.KeyCode.LeftBracket then
        -- 前の番号へ
        currentNumber = (currentNumber == 1) and 10 or (currentNumber - 1)
        updateNumberDisplay()
    end
end)

print("Teleport GUI loaded! By miraitakesi_2022")
