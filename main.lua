-- Teleport GUI v4.0 with Rayfield UI
-- By syu_u

-- Rayfield UI ライブラリのロード
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua'))()
end)

if not success or not Rayfield then
    warn("Rayfield UI の読み込みに失敗しました。標準UIを使用します。")
    -- 代替の標準UIコードをここに実装
    return
end

-- Rayfield ウィンドウの作成
local Window = Rayfield:CreateWindow({
    Name = "Teleport GUI v4.0",
    LoadingTitle = "Teleport System",
    LoadingSubtitle = "by syu_u",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TeleportGUI",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
})

-- 位置保存データ
local savedPositions = {}
local currentSlot = 1

-- メインタブ
local MainTab = Window:CreateTab("メイン", 4483345998)

-- スロット選択セクション
MainTab:CreateSection("位置保存スロット")

-- スロット選択ドロップダウン
local slotOptions = {}
for i = 1, 10 do
    table.insert(slotOptions, "スロット " .. i)
end

local slotDropdown = MainTab:CreateDropdown({
    Name = "スロット選択",
    Options = slotOptions,
    CurrentOption = "スロット 1",
    Callback = function(Value)
        currentSlot = tonumber(string.match(Value, "%d+"))
        updateSlotDisplay()
    end,
})

-- スロット状態表示ラベル
local slotStatusLabel = MainTab:CreateLabel("スロット 1: 空き")

-- スロット表示更新関数
local function updateSlotDisplay()
    local status = savedPositions[currentSlot] and "保存済み ✓" or "空き"
    slotStatusLabel:Set("スロット " .. currentSlot .. ": " .. status)
    
    if savedPositions[currentSlot] then
        slotStatusLabel:SetTextColor(Color3.fromRGB(46, 204, 113))
    else
        slotStatusLabel:SetTextColor(Color3.fromRGB(220, 220, 220))
    end
end

-- 位置操作セクション
MainTab:CreateSection("位置操作")

-- 保存ボタン
MainTab:CreateButton({
    Name = "現在位置を保存",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            savedPositions[currentSlot] = player.Character.HumanoidRootPart.CFrame
            updateSlotDisplay()
            Rayfield:Notify({
                Title = "位置保存完了",
                Content = "スロット " .. currentSlot .. " に位置を保存しました",
                Duration = 2,
                Image = 4483345998
            })
        else
            Rayfield:Notify({
                Title = "エラー",
                Content = "キャラクターが見つかりません",
                Duration = 2,
                Image = 4483345998
            })
        end
    end,
})

-- テレポートボタン
MainTab:CreateButton({
    Name = "保存位置へ移動",
    Callback = function()
        if savedPositions[currentSlot] then
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = savedPositions[currentSlot]
                Rayfield:Notify({
                    Title = "移動完了",
                    Content = "スロット " .. currentSlot .. " の位置へ移動しました",
                    Duration = 2,
                    Image = 4483345998
                })
            end
        else
            Rayfield:Notify({
                Title = "エラー",
                Content = "保存された位置がありません",
                Duration = 2,
                Image = 4483345998
            })
        end
    end,
})

-- 削除ボタン
MainTab:CreateButton({
    Name = "保存位置を削除",
    Callback = function()
        savedPositions[currentSlot] = nil
        updateSlotDisplay()
        Rayfield:Notify({
            Title = "削除完了",
            Content = "スロット " .. currentSlot .. " の位置を削除しました",
            Duration = 2,
            Image = 4483345998
        })
    end,
})

-- アンチグラブタブ
local AntiGrabTab = Window:CreateTab("アンチグラブ", 4483345998)

-- 設定セクション
AntiGrabTab:CreateSection("アンチグラブ設定")

-- アンチグラブ有効化
local antiGrabEnabled = false
local floatingButton = nil
local detectionConnection = nil

local antiGrabToggle = AntiGrabTab:CreateToggle({
    Name = "アンチグラブシステムを有効化",
    CurrentValue = false,
    Callback = function(Value)
        antiGrabEnabled = Value
        
        if Value then
            createFloatingButton()
            startAutoDetection()
            Rayfield:Notify({
                Title = "アンチグラブ有効",
                Content = "システムが起動しました",
                Duration = 2,
                Image = 4483345998
            })
        else
            if floatingButton then
                floatingButton:Destroy()
                floatingButton = nil
            end
            stopAutoDetection()
            Rayfield:Notify({
                Title = "アンチグラブ無効",
                Content = "システムが停止しました",
                Duration = 2,
                Image = 4483345998
            })
        end
    end,
})

-- フローティングボタン作成関数
local function createFloatingButton()
    if floatingButton then
        floatingButton:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AntiGrabFloatingButton"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    floatingButton = Instance.new("TextButton")
    floatingButton.Size = UDim2.new(0, 80, 0, 80)
    floatingButton.Position = UDim2.new(0.5, -40, 0.8, -40)
    floatingButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
    floatingButton.Text = "アンチ\nグラブ"
    floatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatingButton.Font = Enum.Font.GothamBold
    floatingButton.TextSize = 14
    floatingButton.TextWrapped = true
    floatingButton.Active = true
    floatingButton.Draggable = true
    floatingButton.Parent = screenGui
    
    -- UI装飾
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = floatingButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Parent = floatingButton
    
    -- マウス操作イベント
    floatingButton.MouseButton1Click:Connect(function()
        if not antiGrabEnabled then return end
        
        if checkIfGrabbed() then
            performEmergencyTeleport()
            floatingButton.Text = "発動中\n✓"
            floatingButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            
            task.wait(1)
            if floatingButton then
                floatingButton.Text = "アンチ\nグラブ"
                floatingButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
            end
        end
    end)
end

-- 検知変数
local teleportDistance = 20
local teleportCooldown = 1.0
local lastTeleportTime = 0
local lastCheckTime = 0
local lastPosition = Vector3.new(0, 0, 0)
local lastVelocity = Vector3.new(0, 0, 0)

-- 掴まれているかチェック
local function checkIfGrabbed()
    local player = game.Players.LocalPlayer
    local character = player.Character
    
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return false end
    if humanoid.Health <= 0 then return false end
    
    -- 現在の状態を取得
    local currentTime = tick()
    local currentVelocity = rootPart.Velocity
    local currentSpeed = currentVelocity.Magnitude
    
    -- 時間チェック
    if currentTime - lastCheckTime < 0.1 then return false end
    
    -- 投げられた時の特徴的な速度パターンを検出
    if currentSpeed > 100 then -- 非常に高速な移動
        -- 速度の急激な変化をチェック
        local velocityChange = (currentVelocity - lastVelocity).Magnitude
        
        if velocityChange > 80 then -- 急激な速度変化
            -- 空中での急激な加速かチェック（自然なジャンプと区別）
            local isInAir = not humanoid:GetState() == Enum.HumanoidStateType.Running
            if isInAir then
                lastVelocity = currentVelocity
                lastCheckTime = currentTime
                return true
            end
        end
    end
    
    -- 外部フォースの検出
    for _, constraint in pairs(rootPart:GetChildren()) do
        if constraint:IsA("BodyVelocity") then
            -- 自分自身の操作でないことを確認
            local velocity = constraint.Velocity
            if velocity.Magnitude > 50 then
                return true
            end
        end
    end
    
    -- 状態を更新
    lastVelocity = currentVelocity
    lastCheckTime = currentTime
    
    return false
end

-- 緊急テレポート関数
local function performEmergencyTeleport()
    local currentTime = tick()
    if currentTime - lastTeleportTime < teleportCooldown then
        return false
    end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    
    if not character then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    -- 現在位置
    local currentPos = rootPart.Position
    
    -- ランダムな方向と距離
    local randomAngle = math.random() * 2 * math.pi
    local randomDistance = teleportDistance
    
    -- 計算
    local xOffset = math.cos(randomAngle) * randomDistance
    local zOffset = math.sin(randomAngle) * randomDistance
    local yOffset = math.random(5, 25) -- 少し高めに
    
    -- 新しい位置
    local newPosition = Vector3.new(
        currentPos.X + xOffset,
        currentPos.Y + yOffset,
        currentPos.Z + zOffset
    )
    
    -- テレポート実行
    rootPart.CFrame = CFrame.new(newPosition)
    
    -- 物理状態リセット
    rootPart.Velocity = Vector3.new(0, 0, 0)
    rootPart.RotVelocity = Vector3.new(0, 0, 0)
    
    lastTeleportTime = currentTime
    
    -- 通知
    Rayfield:Notify({
        Title = "緊急テレポート発動",
        Content = "敵の攻撃から回避しました",
        Duration = 3,
        Image = 4483345998
    })
    
    return true
end

-- 自動検知の開始・停止
local function startAutoDetection()
    if detectionConnection then
        detectionConnection:Disconnect()
    end
    
    detectionConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not antiGrabEnabled then return end
        
        if checkIfGrabbed() then
            performEmergencyTeleport()
            
            -- ボタン視覚効果
            if floatingButton then
                floatingButton.Text = "自動\n回避 ✓"
                floatingButton.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
                
                task.wait(0.5)
                if floatingButton then
                    floatingButton.Text = "アンチ\nグラブ"
                    floatingButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
                end
            end
        end
    end)
end

local function stopAutoDetection()
    if detectionConnection then
        detectionConnection:Disconnect()
        detectionConnection = nil
    end
end

-- 感度設定
AntiGrabTab:CreateSlider({
    Name = "検知感度",
    Range = {1, 10},
    Increment = 1,
    Suffix = "レベル",
    CurrentValue = 6,
    Callback = function(Value)
        -- 感度設定はcheckIfGrabbed関数内の数値に影響
        teleportDistance = 15 + (Value * 2)
    end,
})

-- クールダウン設定
AntiGrabTab:CreateSlider({
    Name = "クールダウン時間",
    Range = {0.5, 3},
    Increment = 0.1,
    Suffix = "秒",
    CurrentValue = 1.0,
    Callback = function(Value)
        teleportCooldown = Value
    end,
})

-- ヘルプタブ
local HelpTab = Window:CreateTab("ヘルプ", 4483345998)

HelpTab:CreateSection("使い方")

HelpTab:CreateParagraph({
    Title = "基本機能",
    Content = "メインタブで最大10箇所の位置を保存・移動できます。"
})

HelpTab:CreateParagraph({
    Title = "アンチグラブ機能",
    Content = "アンチグラブタブでシステムを有効化すると、画面にフローティングボタンが表示されます。敵に投げられた時はこのボタンをクリックするか、自動検知で回避できます。"
})

HelpTab:CreateParagraph({
    Title = "フローティングボタン",
    Content = "• ドラッグで自由に移動可能\n• クリックで手動発動\n• 自動検知も同時に作動"
})

-- 初期化
updateSlotDisplay()

-- ゲーム内通知
task.wait(1)
Rayfield:Notify({
    Title = "Teleport GUI v4.0",
    Content = "by syu_u - 正常に起動しました",
    Duration = 5,
    Image = 4483345998
})

-- キャラクターリスポーン対応
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2) -- キャラクターのロード待ち
    
    if antiGrabEnabled then
        createFloatingButton()
    end
end)
