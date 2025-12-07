-- Teleport GUI v4.0 with Onion UI
-- By syu_u

-- Onion UIライブラリのロード
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

-- ウィンドウの作成
local Window = OrionLib:MakeWindow({
    Name = "Teleport GUI v4.0",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TeleportGUIConfig",
    IntroEnabled = true,
    IntroText = "by syu_u"
})

-- 位置保存データ
local savedPositions = {}
local currentSlot = 1
local teleportDistance = 20
local teleportCooldown = 1.0
local antiGrabEnabled = false
local floatingButton = nil
local detectionConnection = nil
local lastTeleportTime = 0
local lastCheckTime = 0
local lastPosition = Vector3.new(0, 0, 0)
local lastVelocity = Vector3.new(0, 0, 0)

-- タブの作成
local MainTab = Window:MakeTab({
    Name = "メイン",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local AntiGrabTab = Window:MakeTab({
    Name = "アンチグラブ",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local SettingsTab = Window:MakeTab({
    Name = "設定",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- メインタブの内容
MainTab:AddSection({
    Name = "位置保存システム"
})

-- スロット選択ドロップダウン
local slotOptions = {}
for i = 1, 10 do
    table.insert(slotOptions, tostring(i))
end

local slotDropdown = MainTab:AddDropdown({
    Name = "スロット選択",
    Default = "1",
    Options = slotOptions,
    Callback = function(value)
        currentSlot = tonumber(value)
        updateSlotDisplay()
    end
})

-- スロット状態表示
local slotStatusLabel = MainTab:AddLabel("スロット 1: 空き")

-- 位置保存ボタン
MainTab:AddButton({
    Name = "現在位置を保存",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            savedPositions[currentSlot] = player.Character.HumanoidRootPart.CFrame
            updateSlotDisplay()
            OrionLib:MakeNotification({
                Name = "保存完了",
                Content = "スロット " .. currentSlot .. " に位置を保存しました",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- テレポートボタン
MainTab:AddButton({
    Name = "保存位置へ移動",
    Callback = function()
        if savedPositions[currentSlot] then
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = savedPositions[currentSlot]
                OrionLib:MakeNotification({
                    Name = "移動完了",
                    Content = "スロット " .. currentSlot .. " の位置へ移動しました",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        else
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "保存された位置がありません",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- 削除ボタン
MainTab:AddButton({
    Name = "保存位置を削除",
    Callback = function()
        savedPositions[currentSlot] = nil
        updateSlotDisplay()
        OrionLib:MakeNotification({
            Name = "削除完了",
            Content = "スロット " .. currentSlot .. " の位置を削除しました",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- スロット表示更新関数
function updateSlotDisplay()
    local status = savedPositions[currentSlot] and "保存済み ✓" or "空き"
    slotStatusLabel:Set("スロット " .. currentSlot .. ": " .. status)
end

-- アンチグラブタブ
AntiGrabTab:AddSection({
    Name = "アンチグラブ設定"
})

-- アンチグラブ有効化
local antiGrabToggle = AntiGrabTab:AddToggle({
    Name = "アンチグラブシステム",
    Default = false,
    Callback = function(value)
        antiGrabEnabled = value
        if value then
            createFloatingButton()
            startAutoDetection()
            OrionLib:MakeNotification({
                Name = "アンチグラブ有効",
                Content = "システムが起動しました",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            if floatingButton then
                floatingButton:Destroy()
                floatingButton = nil
            end
            stopAutoDetection()
            OrionLib:MakeNotification({
                Name = "アンチグラブ無効",
                Content = "システムが停止しました",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- 検知感度設定
AntiGrabTab:AddSlider({
    Name = "検知感度",
    Min = 1,
    Max = 10,
    Default = 5,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "レベル",
    Callback = function(value)
        teleportDistance = 15 + (value * 2)
    end
})

-- クールダウン設定
AntiGrabTab:AddSlider({
    Name = "クールダウン時間",
    Min = 0.5,
    Max = 3,
    Default = 1.0,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.1,
    ValueName = "秒",
    Callback = function(value)
        teleportCooldown = value
    end
})

-- テストボタン
AntiGrabTab:AddButton({
    Name = "テストテレポート",
    Callback = function()
        performEmergencyTeleport()
    end
})

-- フローティングボタン作成関数
function createFloatingButton()
    if floatingButton then
        floatingButton:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AntiGrabFloatingButton"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    floatingButton = Instance.new("Frame")
    floatingButton.Size = UDim2.new(0, 100, 0, 100)
    floatingButton.Position = UDim2.new(0.5, -50, 0.8, -50)
    floatingButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    floatingButton.Active = true
    floatingButton.Draggable = true
    floatingButton.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = floatingButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(52, 152, 219)
    stroke.Thickness = 3
    stroke.Parent = floatingButton
    
    local buttonText = Instance.new("TextLabel")
    buttonText.Size = UDim2.new(1, 0, 1, 0)
    buttonText.BackgroundTransparency = 1
    buttonText.Text = "アンチグラブ\n[ON]"
    buttonText.TextColor3 = Color3.fromRGB(52, 152, 219)
    buttonText.Font = Enum.Font.GothamBold
    buttonText.TextSize = 14
    buttonText.TextWrapped = true
    buttonText.Parent = floatingButton
    
    -- クリックイベント
    floatingButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if checkIfGrabbed() then
                performEmergencyTeleport()
                buttonText.Text = "発動中！\n✓"
                buttonText.TextColor3 = Color3.fromRGB(46, 204, 113)
                stroke.Color = Color3.fromRGB(46, 204, 113)
                
                task.wait(1)
                if floatingButton then
                    buttonText.Text = "アンチグラブ\n[ON]"
                    buttonText.TextColor3 = Color3.fromRGB(52, 152, 219)
                    stroke.Color = Color3.fromRGB(52, 152, 219)
                end
            else
                buttonText.Text = "検知なし\n..."
                buttonText.TextColor3 = Color3.fromRGB(241, 196, 15)
                stroke.Color = Color3.fromRGB(241, 196, 15)
                
                task.wait(0.5)
                if floatingButton then
                    buttonText.Text = "アンチグラブ\n[ON]"
                    buttonText.TextColor3 = Color3.fromRGB(52, 152, 219)
                    stroke.Color = Color3.fromRGB(52, 152, 219)
                end
            end
        end
    end)
    
    -- マウスオーバー効果
    floatingButton.MouseEnter:Connect(function()
        stroke.Thickness = 4
    end)
    
    floatingButton.MouseLeave:Connect(function()
        stroke.Thickness = 3
    end)
end

-- 掴まれているかチェック（改良版）
function checkIfGrabbed()
    local player = game.Players.LocalPlayer
    local character = player.Character
    
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return false end
    
    -- 死亡チェック
    if humanoid.Health <= 0 then return false end
    
    -- 現在の状態を取得
    local currentTime = tick()
    local currentVelocity = rootPart.Velocity
    local currentSpeed = currentVelocity.Magnitude
    
    -- 時間チェック
    if currentTime - lastCheckTime < 0.1 then return false end
    
    -- 方法1: 急激な速度変化の検出（投げられた時の特徴）
    local velocityChange = (currentVelocity - lastVelocity).Magnitude
    
    -- 投げられた時の条件:
    -- 1. 現在速度が非常に高い（> 80）
    -- 2. 速度の急激な変化（> 70）
    -- 3. プレイヤーが空中にいる（自然な移動と区別）
    local isInAir = humanoid:GetState() ~= Enum.HumanoidStateType.Running
    
    if currentSpeed > 80 and velocityChange > 70 and isInAir then
        -- さらに、前回の位置から急激な移動があるかチェック
        local currentPos = rootPart.Position
        local posChange = (currentPos - lastPosition).Magnitude
        
        if posChange > 5 then -- 前回から5スタッド以上移動
            lastVelocity = currentVelocity
            lastPosition = currentPos
            lastCheckTime = currentTime
            return true
        end
    end
    
    -- 方法2: 外部フォースの検出（BodyVelocityなど）
    for _, constraint in pairs(rootPart:GetChildren()) do
        if constraint:IsA("BodyVelocity") then
            local velocity = constraint.Velocity
            if velocity.Magnitude > 50 then
                -- 自分の操作でないことを確認
                local moveDir = humanoid.MoveDirection
                if moveDir.Magnitude < 0.1 then -- 移動入力がない
                    return true
                end
            end
        end
    end
    
    -- 方法3: ウェルド/ジョイントの検出（他のプレイヤーに接続）
    for _, descendant in pairs(rootPart:GetDescendants()) do
        if descendant:IsA("Weld") or descendant:IsA("WeldConstraint") then
            local part0 = descendant.Part0
            local part1 = descendant.Part1
            
            if part0 and part1 then
                -- 自分のキャラクター内の接続でないことを確認
                if not (part0:IsDescendantOf(character) and part1:IsDescendantOf(character)) then
                    return true
                end
            end
        end
    end
    
    -- 状態を更新
    lastVelocity = currentVelocity
    lastPosition = rootPart.Position
    lastCheckTime = currentTime
    
    return false
end

-- 緊急テレポート関数
function performEmergencyTeleport()
    local currentTime = tick()
    if currentTime - lastTeleportTime < teleportCooldown then
        return false
    end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    
    if not character then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    -- 現在位置
    local currentPos = rootPart.Position
    
    -- ランダムな方向と距離
    local randomAngle = math.random() * 2 * math.pi
    local randomDistance = teleportDistance
    
    -- 計算
    local xOffset = math.cos(randomAngle) * randomDistance
    local zOffset = math.sin(randomAngle) * randomDistance
    local yOffset = math.random(5, 25) -- 高めにテレポート
    
    -- 新しい位置
    local newPosition = Vector3.new(
        currentPos.X + xOffset,
        currentPos.Y + yOffset,
        currentPos.Z + zOffset
    )
    
    -- 地面があるかチェック
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {character}
    
    local raycastResult = workspace:Raycast(
        newPosition + Vector3.new(0, 50, 0),
        Vector3.new(0, -100, 0),
        raycastParams
    )
    
    if raycastResult then
        newPosition = raycastResult.Position + Vector3.new(0, 5, 0)
    end
    
    -- テレポート実行
    rootPart.CFrame = CFrame.new(newPosition)
    
    -- 物理状態リセット
    rootPart.Velocity = Vector3.new(0, 0, 0)
    rootPart.RotVelocity = Vector3.new(0, 0, 0)
    
    lastTeleportTime = currentTime
    
    -- 通知
    OrionLib:MakeNotification({
        Name = "緊急テレポート発動",
        Content = "敵の攻撃から回避しました",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
    
    return true
end

-- 自動検知の開始
function startAutoDetection()
    if detectionConnection then
        detectionConnection:Disconnect()
    end
    
    detectionConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not antiGrabEnabled then return end
        
        if checkIfGrabbed() then
            performEmergencyTeleport()
            
            -- ボタンの視覚的フィードバック
            if floatingButton then
                local buttonText = floatingButton:FindFirstChildWhichIsA("TextLabel")
                local stroke = floatingButton:FindFirstChildWhichIsA("UIStroke")
                
                if buttonText and stroke then
                    buttonText.Text = "自動回避\n発動！"
                    buttonText.TextColor3 = Color3.fromRGB(155, 89, 182)
                    stroke.Color = Color3.fromRGB(155, 89, 182)
                    
                    task.wait(0.5)
                    
                    if floatingButton then
                        buttonText.Text = "アンチグラブ\n[ON]"
                        buttonText.TextColor3 = Color3.fromRGB(52, 152, 219)
                        stroke.Color = Color3.fromRGB(52, 152, 219)
                    end
                end
            end
        end
    end)
end

-- 自動検知の停止
function stopAutoDetection()
    if detectionConnection then
        detectionConnection:Disconnect()
        detectionConnection = nil
    end
end

-- 設定タブ
SettingsTab:AddSection({
    Name = "UI設定"
})

-- UIカラー設定
SettingsTab:AddColorpicker({
    Name = "メインカラー",
    Default = Color3.fromRGB(52, 152, 219),
    Callback = function(value)
        -- UIのカラーを変更
        OrionLib:MakeNotification({
            Name = "カラー設定",
            Content = "メインカラーを変更しました",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end
})

-- UIトグル
SettingsTab:AddToggle({
    Name = "UIを常に表示",
    Default = true,
    Callback = function(value)
        Window:Toggle(value)
    end
})

-- リセットボタン
SettingsTab:AddButton({
    Name = "すべての設定をリセット",
    Callback = function()
        OrionLib:Destroy()
        OrionLib:MakeNotification({
            Name = "リセット完了",
            Content = "設定をリセットしました。再起動してください。",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

-- ヘルプセクション
SettingsTab:AddSection({
    Name = "ヘルプ"
})

SettingsTab:AddParagraph("使い方", [[
【メインタブ】
• スロット選択で位置を保存/移動
• 10箇所まで保存可能

【アンチグラブタブ】
• システム有効化でフローティングボタン表示
• ボタンをドラッグして移動可能
• 敵に投げられたら自動/手動で回避

【設定タブ】
• UIカスタマイズ
• 設定リセット
]])

-- 初期化
updateSlotDisplay()

-- キャラクターリスポーン対応
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(2) -- キャラクターのロードを待つ
    
    if antiGrabEnabled and floatingButton == nil then
        createFloatingButton()
    end
end)

-- UIを起動
OrionLib:Init()

-- 起動通知
task.wait(1)
OrionLib:MakeNotification({
    Name = "Teleport GUI v4.0",
    Content = "by syu_u - 正常に起動しました",
    Image = "rbxassetid://4483345998",
    Time = 5
})
