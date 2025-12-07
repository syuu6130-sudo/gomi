-- Teleport GUI v3.0
-- By syu_u
-- 元機能 + アンチグラブ自動テレポート機能

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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

-- メインフレーム
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 35)
mainFrame.Position = UDim2.new(0.5, -110, 0.05, 0)
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

-- タイトルバー
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 150, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Teleport GUI"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 50, 0, 25)
toggleButton.Position = UDim2.new(1, -60, 0, 5)
toggleButton.Text = "▲"
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
toggleButton.TextColor3 = Color3.fromRGB(220, 220, 220)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 12
toggleButton.Parent = titleBar

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleButton

-- コンテンツフレーム（最小化可能）
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 0, 120)
contentFrame.Position = UDim2.new(0, 0, 1, 0)
contentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
contentFrame.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = contentFrame

local contentStroke = Instance.new("UIStroke")
contentStroke.Color = Color3.fromRGB(60, 60, 70)
contentStroke.Thickness = 2
contentStroke.Parent = contentFrame

-- 番号選択セクション
local numberSection = Instance.new("Frame")
numberSection.Size = UDim2.new(1, -20, 0, 40)
numberSection.Position = UDim2.new(0, 10, 0, 10)
numberSection.BackgroundTransparency = 1
numberSection.Parent = contentFrame

local numberBox = Instance.new("TextBox")
numberBox.Size = UDim2.new(0, 40, 0, 40)
numberBox.Position = UDim2.new(0, 0, 0, 0)
numberBox.Text = "1"
numberBox.TextColor3 = Color3.fromRGB(255, 255, 255)
numberBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
numberBox.ClearTextOnFocus = false
numberBox.Font = Enum.Font.GothamBold
numberBox.TextSize = 16
numberBox.Parent = numberSection

local numberBoxCorner = Instance.new("UICorner")
numberBoxCorner.CornerRadius = UDim.new(0, 6)
numberBoxCorner.Parent = numberBox

local leftArrow = Instance.new("TextButton")
leftArrow.Size = UDim2.new(0, 30, 0, 40)
leftArrow.Position = UDim2.new(0, 50, 0, 0)
leftArrow.Text = "<"
leftArrow.TextColor3 = Color3.fromRGB(220, 220, 220)
leftArrow.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
leftArrow.Font = Enum.Font.GothamBold
leftArrow.TextSize = 14
leftArrow.Parent = numberSection

local leftCorner = Instance.new("UICorner")
leftCorner.CornerRadius = UDim.new(0, 6)
leftCorner.Parent = leftArrow

local rightArrow = Instance.new("TextButton")
rightArrow.Size = UDim2.new(0, 30, 0, 40)
rightArrow.Position = UDim2.new(0, 90, 0, 0)
rightArrow.Text = ">"
rightArrow.TextColor3 = Color3.fromRGB(220, 220, 220)
rightArrow.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
rightArrow.Font = Enum.Font.GothamBold
rightArrow.TextSize = 14
rightArrow.Parent = numberSection

local rightCorner = Instance.new("UICorner")
rightCorner.CornerRadius = UDim.new(0, 6)
rightCorner.Parent = rightArrow

local savedLabel = Instance.new("TextLabel")
savedLabel.Size = UDim2.new(0, 80, 0, 40)
savedLabel.Position = UDim2.new(0, 130, 0, 0)
savedLabel.BackgroundTransparency = 1
savedLabel.Text = ""
savedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
savedLabel.Font = Enum.Font.Gotham
savedLabel.TextSize = 12
savedLabel.TextXAlignment = Enum.TextXAlignment.Left
savedLabel.Parent = numberSection

-- ボタンセクション
local buttonSection = Instance.new("Frame")
buttonSection.Size = UDim2.new(1, -20, 0, 40)
buttonSection.Position = UDim2.new(0, 10, 0, 60)
buttonSection.BackgroundTransparency = 1
buttonSection.Parent = contentFrame

local buttonLayout = Instance.new("UIGridLayout")
buttonLayout.CellPadding = UDim2.new(0, 5, 0, 0)
buttonLayout.CellSize = UDim2.new(0.33, -4, 1, 0)
buttonLayout.FillDirection = Enum.FillDirection.Horizontal
buttonLayout.Parent = buttonSection

-- ボタン作成関数
local function createButton(text, color)
    local button = Instance.new("TextButton")
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = color
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Parent = buttonSection
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    return button
end

local setButton = createButton("SET", Color3.fromRGB(46, 204, 113))
local deleteButton = createButton("DEL", Color3.fromRGB(231, 76, 60))
local tpButton = createButton("TP", Color3.fromRGB(52, 152, 219))

-- アンチグラブ設定セクション
local antiGrabSection = Instance.new("Frame")
antiGrabSection.Size = UDim2.new(1, -20, 0, 25)
antiGrabSection.Position = UDim2.new(0, 10, 0, 110)
antiGrabSection.BackgroundTransparency = 1
antiGrabSection.Parent = contentFrame

local antiGrabToggle = Instance.new("TextButton")
antiGrabToggle.Size = UDim2.new(0, 100, 0, 25)
antiGrabToggle.Position = UDim2.new(0, 0, 0, 0)
antiGrabToggle.Text = "ANTI-GRAB: OFF"
antiGrabToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
antiGrabToggle.BackgroundColor3 = Color3.fromRGB(192, 57, 43) -- 赤
antiGrabToggle.Font = Enum.Font.GothamBold
antiGrabToggle.TextSize = 11
antiGrabToggle.Parent = antiGrabSection

local antiGrabCorner = Instance.new("UICorner")
antiGrabCorner.CornerRadius = UDim.new(0, 6)
antiGrabCorner.Parent = antiGrabToggle

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 90, 0, 25)
statusLabel.Position = UDim2.new(0, 110, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.Parent = antiGrabSection

-- データ
local savedPositions = {}
local currentNumber = 1
local isContentVisible = true
local isAntiGrabEnabled = false
local lastTeleportTime = 0
local teleportCooldown = 0.5 -- 秒

-- グラブ検知用変数
local detectionEnabled = true
local lastPosition = Vector3.new(0, 0, 0)
local lastVelocity = Vector3.new(0, 0, 0)
local lastCheckTime = 0
local checkInterval = 0.1 -- 秒

-- 更新表示
local function updateDisplay()
    numberBox.Text = tostring(currentNumber)
    if savedPositions[currentNumber] then
        savedLabel.Text = "✓ SAVED"
        savedLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
    else
        savedLabel.Text = "EMPTY"
        savedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
    
    if isAntiGrabEnabled then
        antiGrabToggle.Text = "ANTI-GRAB: ON"
        antiGrabToggle.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- 緑
    else
        antiGrabToggle.Text = "ANTI-GRAB: OFF"
        antiGrabToggle.BackgroundColor3 = Color3.fromRGB(192, 57, 43) -- 赤
    end
end

-- 最小化/最大化
toggleButton.MouseButton1Click:Connect(function()
    isContentVisible = not isContentVisible
    contentFrame.Visible = isContentVisible
    
    if isContentVisible then
        toggleButton.Text = "▲"
        mainFrame.Size = UDim2.new(0, 220, 0, 35 + 120)
    else
        toggleButton.Text = "▼"
        mainFrame.Size = UDim2.new(0, 220, 0, 35)
    end
end)

-- 番号操作
leftArrow.MouseButton1Click:Connect(function()
    currentNumber = (currentNumber == 1) and 10 or (currentNumber - 1)
    updateDisplay()
end)

rightArrow.MouseButton1Click:Connect(function()
    currentNumber = (currentNumber == 10) and 1 or (currentNumber + 1)
    updateDisplay()
end)

numberBox.FocusLost:Connect(function()
    local num = tonumber(numberBox.Text)
    if num and num >= 1 and num <= 10 then
        currentNumber = math.floor(num)
    else
        currentNumber = 1
    end
    updateDisplay()
end)

-- キャラクターの有効性チェック
local function isCharacterValid()
    local character = player.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return false end
    if humanoid.Health <= 0 then return false end
    
    return true
end

-- 位置保存
setButton.MouseButton1Click:Connect(function()
    if isCharacterValid() then
        savedPositions[currentNumber] = player.Character.HumanoidRootPart.CFrame
        updateDisplay()
        
        -- 視覚的フィードバック
        local originalColor = setButton.BackgroundColor3
        setButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        setButton.Text = "✓"
        task.wait(0.2)
        setButton.BackgroundColor3 = originalColor
        setButton.Text = "SET"
    end
end)

-- 削除
deleteButton.MouseButton1Click:Connect(function()
    savedPositions[currentNumber] = nil
    updateDisplay()
    
    -- 視覚的フィードバック
    local originalColor = deleteButton.BackgroundColor3
    deleteButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    deleteButton.Text = "✓"
    task.wait(0.2)
    deleteButton.BackgroundColor3 = originalColor
    deleteButton.Text = "DEL"
end)

-- テレポート
tpButton.MouseButton1Click:Connect(function()
    if savedPositions[currentNumber] and isCharacterValid() then
        player.Character.HumanoidRootPart.CFrame = savedPositions[currentNumber]
        
        -- 視覚的フィードバック
        local originalColor = tpButton.BackgroundColor3
        tpButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tpButton.Text = "✓"
        task.wait(0.2)
        tpButton.BackgroundColor3 = originalColor
        tpButton.Text = "TP"
    end
end)

-- アンチグラブ機能
antiGrabToggle.MouseButton1Click:Connect(function()
    isAntiGrabEnabled = not isAntiGrabEnabled
    updateDisplay()
    
    if isAntiGrabEnabled then
        statusLabel.Text = "ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
    else
        statusLabel.Text = "INACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end)

-- ランダムテレポート関数
local function performRandomTeleport()
    local currentTime = tick()
    if currentTime - lastTeleportTime < teleportCooldown then
        return false
    end
    
    if not isCharacterValid() then
        return false
    end
    
    local rootPart = player.Character.HumanoidRootPart
    local currentPos = rootPart.Position
    
    -- ランダム角度と距離
    local angle = math.random() * 2 * math.pi
    local distance = 20 -- 20スタッド
    
    -- 水平方向のオフセット
    local xOffset = math.cos(angle) * distance
    local zOffset = math.sin(angle) * distance
    
    -- 垂直方向のオフセット（0〜20スタッド）
    local yOffset = math.random(0, 20)
    
    -- 新しい位置
    local newPosition = Vector3.new(
        currentPos.X + xOffset,
        currentPos.Y + yOffset,
        currentPos.Z + zOffset
    )
    
    -- テレポート実行
    rootPart.CFrame = CFrame.new(newPosition)
    
    lastTeleportTime = currentTime
    
    -- 視覚的フィードバック
    if isAntiGrabEnabled then
        statusLabel.Text = "ESCAPED!"
        statusLabel.TextColor3 = Color3.fromRGB(241, 196, 15) -- 黄色
        task.wait(0.5)
        statusLabel.Text = "ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
    end
    
    return true
end

-- グラブ検知システム（複数の検知方法）

-- 方法1: ウェルド/ジョイントの検知
local function checkForWelds()
    if not isCharacterValid() or not isAntiGrabEnabled then return false end
    
    local character = player.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then return false end
    
    -- ルートパートに接続されたウェルドをチェック
    for _, descendant in pairs(rootPart:GetDescendants()) do
        if descendant:IsA("Weld") or descendant:IsA("WeldConstraint") then
            -- 自分自身へのウェルドでないかチェック
            local part0 = descendant.Part0
            local part1 = descendant.Part1
            
            if part0 and part1 then
                -- 両方のパーツが自分のキャラクターのものであるかチェック
                local isSelfWeld = false
                
                for _, part in pairs({part0, part1}) do
                    if part:IsDescendantOf(character) then
                        isSelfWeld = true
                    else
                        isSelfWeld = false
                        break
                    end
                end
                
                if not isSelfWeld then
                    return true
                end
            end
        end
    end
    
    return false
end

-- 方法2: 速度/位置の急激な変化の検知
local function checkForSuddenMovement()
    if not isCharacterValid() or not isAntiGrabEnabled then return false end
    
    local currentTime = tick()
    if currentTime - lastCheckTime < checkInterval then return false end
    
    local character = player.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then return false end
    
    local currentPos = rootPart.Position
    local currentVel = rootPart.Velocity
    
    -- 前回との位置変化を計算
    local posDelta = (currentPos - lastPosition).Magnitude
    local velDelta = (currentVel - lastVelocity).Magnitude
    
    -- 急激な変化を検知
    if posDelta > 10 or velDelta > 50 then
        lastPosition = currentPos
        lastVelocity = currentVel
        lastCheckTime = currentTime
        return true
    end
    
    lastPosition = currentPos
    lastVelocity = currentVel
    lastCheckTime = currentTime
    return false
end

-- 方法3: 見えない力（BodyPosition/Force）の検知
local function checkForExternalForces()
    if not isCharacterValid() or not isAntiGrabEnabled then return false end
    
    local character = player.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then return false end
    
    -- BodyPositionやBodyVelocityの検知
    for _, constraint in pairs(rootPart:GetChildren()) do
        if constraint:IsA("BodyPosition") or 
           constraint:IsA("BodyVelocity") or 
           constraint:IsA("BodyAngularVelocity") or
           constraint:IsA("VectorForce") then
            return true
        end
    end
    
    return false
end

-- 方法4: 近くのプレイヤーツールの検知
local function checkForNearbyTools()
    if not isCharacterValid() or not isAntiGrabEnabled then return false end
    
    local character = player.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then return false end
    
    local currentPos = rootPart.Position
    
    -- 他のプレイヤーのツールをチェック
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local tool = otherPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    local distance = (handle.Position - currentPos).Magnitude
                    if distance < 15 then -- 15スタッド以内
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- 方法5: 人間の動きと実際の速度の不一致検知
local function checkForMovementDiscrepancy()
    if not isCharacterValid() or not isAntiGrabEnabled then return false end
    
    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return false end
    
    -- 人間が動こうとしている方向
    local moveDirection = humanoid.MoveDirection
    local actualVelocity = rootPart.Velocity
    
    -- 動こうとしている方向と実際の速度の不一致をチェック
    if moveDirection.Magnitude > 0.1 then
        local dotProduct = moveDirection.Unit:Dot(actualVelocity.Unit)
        if dotProduct < 0.3 and actualVelocity.Magnitude > 10 then
            return true
        end
    end
    
    return false
end

-- メイン検知ループ
local detectionLoop
detectionLoop = RunService.Heartbeat:Connect(function()
    if not isAntiGrabEnabled then return end
    if not detectionEnabled then return end
    if not isCharacterValid() then return end
    
    -- すべての検知方法をチェック
    local detected = false
    local detectionMethod = ""
    
    if checkForWelds() then
        detected = true
        detectionMethod = "Weld"
    elseif checkForExternalForces() then
        detected = true
        detectionMethod = "Force"
    elseif checkForSuddenMovement() then
        detected = true
        detectionMethod = "Movement"
    elseif checkForNearbyTools() then
        detected = true
        detectionMethod = "Tool"
    elseif checkForMovementDiscrepancy() then
        detected = true
        detectionMethod = "Discrepancy"
    end
    
    if detected then
        -- 検知したらテレポートを実行
        detectionEnabled = false
        performRandomTeleport()
        
        -- ログ表示
        if detectionMethod ~= "" then
            statusLabel.Text = "DETECTED: " .. detectionMethod
            statusLabel.TextColor3 = Color3.fromRGB(230, 126, 34) -- オレンジ
        end
        
        -- 少し待ってから検知を再開
        task.wait(1)
        detectionEnabled = true
        
        if isAntiGrabEnabled then
            statusLabel.Text = "ACTIVE"
            statusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
        end
    end
end)

-- 初期化
updateDisplay()

-- 追加のキーボードショートカット
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.PageUp then
        -- 前のスロット
        currentNumber = (currentNumber == 1) and 10 or (currentNumber - 1)
        updateDisplay()
    elseif input.KeyCode == Enum.KeyCode.PageDown then
        -- 次のスロット
        currentNumber = (currentNumber == 10) and 1 or (currentNumber + 1)
        updateDisplay()
    elseif input.KeyCode == Enum.KeyCode.Insert then
        -- アンチグラブのトグル
        isAntiGrabEnabled = not isAntiGrabEnabled
        updateDisplay()
        
        if isAntiGrabEnabled then
            statusLabel.Text = "ACTIVE"
            statusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
        else
            statusLabel.Text = "INACTIVE"
            statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
    elseif input.KeyCode == Enum.KeyCode.End then
        -- 強制テレポート（テスト用）
        if isCharacterValid() then
            performRandomTeleport()
        end
    end
end)

print("Teleport GUI v3.0 loaded | By syu_u")
print("Original Features:")
print("  - 10 Position Slots (SET/DEL/TP)")
print("  - Draggable UI")
print("  - Minimize/Maximize")
print("Anti-Grab Features:")
print("  - Weld/Constraint Detection")
print("  - External Force Detection")
print("  - Sudden Movement Detection")
print("  - Nearby Tool Detection")
print("  - Movement Discrepancy Detection")
print("Hotkeys:")
print("  PageUp/PageDown: Change slot")
print("  Insert: Toggle Anti-Grab")
print("  End: Force Teleport (test)")
