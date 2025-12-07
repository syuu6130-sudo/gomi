-- Teleport GUI v4.0 with Rayfield UI
-- By syu_u

-- Rayfield UI ライブラリをロード
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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

-- メインタブ
local MainTab = Window:CreateTab("Main", "rbxassetid://4483345998")

-- 位置保存データ
local savedPositions = {}
local currentSlot = 1

-- スロット選択セクション
local SlotSection = MainTab:CreateSection("Position Slots")

-- スロット選択ドロップダウン
local slots = {}
for i = 1, 10 do
    table.insert(slots, "Slot " .. i)
end

local slotDropdown = MainTab:CreateDropdown({
    Name = "Select Slot",
    Options = slots,
    CurrentOption = "Slot 1",
    Callback = function(Value)
        currentSlot = tonumber(string.match(Value, "%d+"))
        updateSlotDisplay()
    end,
})

-- スロット情報表示
local slotStatusLabel = MainTab:CreateLabel("Slot 1: Empty")

-- スロット状態を更新する関数
function updateSlotDisplay()
    slotStatusLabel:Set("Slot " .. currentSlot .. ": " .. 
        (savedPositions[currentSlot] and "Saved ✓" or "Empty"))
    
    if savedPositions[currentSlot] then
        slotStatusLabel:SetTextColor(Color3.fromRGB(46, 204, 113))
    else
        slotStatusLabel:SetTextColor(Color3.fromRGB(220, 220, 220))
    end
end

-- 位置操作セクション
local PositionSection = MainTab:CreateSection("Position Controls")

-- 保存ボタン
MainTab:CreateButton({
    Name = "Save Current Position",
    Callback = function()
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            savedPositions[currentSlot] = character.HumanoidRootPart.CFrame
            updateSlotDisplay()
            Rayfield:Notify({
                Title = "Position Saved",
                Content = "Position saved to Slot " .. currentSlot,
                Duration = 2,
                Image = "rbxassetid://4483345998"
            })
        end
    end,
})

-- テレポートボタン
MainTab:CreateButton({
    Name = "Teleport to Saved Position",
    Callback = function()
        if savedPositions[currentSlot] then
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = savedPositions[currentSlot]
                Rayfield:Notify({
                    Title = "Teleported",
                    Content = "Teleported to Slot " .. currentSlot,
                    Duration = 2,
                    Image = "rbxassetid://4483345998"
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "No position saved in Slot " .. currentSlot,
                Duration = 2,
                Image = "rbxassetid://4483345998"
            })
        end
    end,
})

-- 削除ボタン
MainTab:CreateButton({
    Name = "Delete Saved Position",
    Callback = function()
        savedPositions[currentSlot] = nil
        updateSlotDisplay()
        Rayfield:Notify({
            Title = "Position Deleted",
            Content = "Position deleted from Slot " .. currentSlot,
            Duration = 2,
            Image = "rbxassetid://4483345998"
        })
    end,
})

-- アンチグラブタブ
local AntiGrabTab = Window:CreateTab("Anti-Grab", "rbxassetid://4483345998")

-- 設定セクション
local SettingsSection = AntiGrabTab:CreateSection("Anti-Grab Settings")

-- アンチグラブ有効化
local antiGrabEnabled = false
local floatingButton = nil

local antiGrabToggle = AntiGrabTab:CreateToggle({
    Name = "Enable Anti-Grab System",
    CurrentValue = false,
    Callback = function(Value)
        antiGrabEnabled = Value
        if Value then
            createFloatingButton()
        elseif floatingButton then
            floatingButton:Destroy()
            floatingButton = nil
        end
    end,
})

-- 検知感度設定
AntiGrabTab:CreateSlider({
    Name = "Detection Sensitivity",
    Range = {1, 10},
    Increment = 1,
    Suffix = "level",
    CurrentValue = 5,
    Callback = function(Value)
        detectionSensitivity = Value
    end,
})

-- テレポート距離設定
AntiGrabTab:CreateSlider({
    Name = "Teleport Distance",
    Range = {10, 50},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 20,
    Callback = function(Value)
        teleportDistance = Value
    end,
})

-- クールダウン設定
AntiGrabTab:CreateSlider({
    Name = "Cooldown Time",
    Range = {0.5, 3},
    Increment = 0.1,
    Suffix = "seconds",
    CurrentValue = 1.0,
    Callback = function(Value)
        teleportCooldown = Value
    end,
})

-- フローティングボタン作成関数
function createFloatingButton()
    if floatingButton then
        floatingButton:Destroy()
    end
    
    -- フローティングボタンのGUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AntiGrabFloatingButton"
    screenGui.Parent = game.Players.LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- メインボタン
    floatingButton = Instance.new("TextButton")
    floatingButton.Size = UDim2.new(0, 70, 0, 70)
    floatingButton.Position = UDim2.new(0.5, -35, 0.8, -35)
    floatingButton.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
    floatingButton.Text = "ANTI-GRAB\n[OFF]"
    floatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatingButton.Font = Enum.Font.GothamBold
    floatingButton.TextSize = 12
    floatingButton.TextWrapped = true
    floatingButton.Active = true
    floatingButton.Draggable = true
    floatingButton.Parent = screenGui
    
    -- ボタンの装飾
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = floatingButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Parent = floatingButton
    
    -- シャドウ効果
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Parent = floatingButton
    
    -- ボタンクリックイベント
    floatingButton.MouseButton1Click:Connect(function()
        if not antiGrabEnabled then return end
        
        -- 敵に掴まれているかをチェック
        if checkIfGrabbed() then
            performEmergencyTeleport()
            floatingButton.Text = "ANTI-GRAB\n[ACTIVE]"
            floatingButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            
            -- 3秒後に元に戻る
            task.wait(3)
            if floatingButton then
                floatingButton.Text = "ANTI-GRAB\n[READY]"
                floatingButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
            end
        else
            -- 掴まれていない場合
            floatingButton.Text = "ANTI-GRAB\n[NOT GRABBED]"
            floatingButton.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
            
            task.wait(1)
            if floatingButton then
                floatingButton.Text = "ANTI-GRAB\n[READY]"
                floatingButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
            end
        end
    end)
    
    -- マウスオーバー効果
    floatingButton.MouseEnter:Connect(function()
        if floatingButton then
            local tween = game:GetService("TweenService"):Create(
                floatingButton,
                TweenInfo.new(0.2),
                {Size = UDim2.new(0, 80, 0, 80), Position = UDim2.new(0.5, -40, 0.8, -40)}
            )
            tween:Play()
        end
    end)
    
    floatingButton.MouseLeave:Connect(function()
        if floatingButton then
            local tween = game:GetService("TweenService"):Create(
                floatingButton,
                TweenInfo.new(0.2),
                {Size = UDim2.new(0, 70, 0, 70), Position = UDim2.new(0.5, -35, 0.8, -35)}
            )
            tween:Play()
        end
    end)
    
    -- 初期状態
    floatingButton.Text = "ANTI-GRAB\n[READY]"
    floatingButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
end

-- 検知変数
local detectionSensitivity = 5
local teleportDistance = 20
local teleportCooldown = 1.0
local lastTeleportTime = 0
local lastCheckTime = 0
local lastPosition = Vector3.new(0, 0, 0)
local lastVelocity = Vector3.new(0, 0, 0)

-- 掴まれているかチェックする関数
function checkIfGrabbed()
    local player = game.Players.LocalPlayer
    local character = player.Character
    
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return false end
    
    -- 死亡チェック
    if humanoid.Health <= 0 then return false end
    
    -- 方法1: 異常な速度変化（敵に投げられた時特有の急加速）
    local currentVelocity = rootPart.Velocity
    local currentTime = tick()
    
    -- 時間経過チェック
    if currentTime - lastCheckTime < 0.1 then return false end
    
    -- 速度の大きさを計算
    local speed = currentVelocity.Magnitude
    
    -- 通常の歩行速度は約16、走っても約30程度
    -- 敵に投げられた時は50以上の速度になることが多い
    if speed > 50 then
        -- 前回の速度との変化量を計算
        local velocityChange = (currentVelocity - lastVelocity).Magnitude
        
        -- 急激な速度変化（投げられたサイン）
        if velocityChange > 100 then
            lastVelocity = currentVelocity
            lastCheckTime = currentTime
            return true
        end
    end
    
    -- 方法2: 外部フォースの検出
    for _, constraint in pairs(rootPart:GetChildren()) do
        if constraint:IsA("BodyVelocity") or 
           constraint:IsA("BodyAngularVelocity") or
           constraint:IsA("VectorForce") then
            -- 自分自身のフォースでないかチェック
            if not isPlayerAppliedForce(constraint) then
                return true
            end
        end
    end
    
    -- 方法3: ウェルド/ジョイントの検出（他のプレイヤーに接続されている場合）
    for _, descendant in pairs(rootPart:GetDescendants()) do
        if descendant:IsA("Weld") or descendant:IsA("WeldConstraint") then
            local part0 = descendant.Part0
            local part1 = descendant.Part1
            
            if part0 and part1 then
                -- 両方のパーツが自分のキャラクターのものであるかチェック
                local isSelfWeld = true
                
                for _, part in pairs({part0, part1}) do
                    if not part:IsDescendantOf(character) then
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
    
    -- 方法4: 非自然的な移動パターン
    local currentPos = rootPart.Position
    local posDelta = (currentPos - lastPosition).Magnitude
    
    -- 人間が移動していないのに位置が大きく変化している場合
    local moveDirection = humanoid.MoveDirection
    if moveDirection.Magnitude < 0.1 and posDelta > 10 then
        lastPosition = currentPos
        lastCheckTime = currentTime
        return true
    end
    
    -- 状態を更新
    lastPosition = currentPos
    lastVelocity = currentVelocity
    lastCheckTime = currentTime
    
    return false
end

-- プレイヤー自身が適用したフォースかどうかをチェック
function isPlayerAppliedForce(constraint)
    -- この関数はゲームの仕様に応じて調整が必要
    -- ここでは単純に常にfalseを返すが、実際にはより詳細なチェックが必要
    return false
end

-- 緊急テレポート関数
function performEmergencyTeleport()
    local currentTime = tick()
    if currentTime - lastTeleportTime < teleportCooldown then
        return false
    end
    
    local character = game.Players.LocalPlayer.Character
    if not character then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    -- 現在位置を取得
    local currentPos = rootPart.Position
    
    -- ランダムな方向と距離を計算
    local randomAngle = math.random() * 2 * math.pi
    local randomDistance = teleportDistance
    
    -- XZ平面でのオフセット
    local xOffset = math.cos(randomAngle) * randomDistance
    local zOffset = math.sin(randomAngle) * randomDistance
    
    -- 高さのオフセット（地上0〜20スタッド）
    local yOffset = math.random(0, 20)
    
    -- 新しい位置
    local newPosition = Vector3.new(
        currentPos.X + xOffset,
        currentPos.Y + yOffset,
        currentPos.Z + zOffset
    )
    
    -- 地面を探す（必要に応じて）
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
    
    -- 物理演算をリセット
    rootPart.Velocity = Vector3.new(0, 0, 0)
    rootPart.RotVelocity = Vector3.new(0, 0, 0)
    
    lastTeleportTime = currentTime
    
    -- 通知
    Rayfield:Notify({
        Title = "Emergency Teleport",
        Content = "Escaped from grab!",
        Duration = 3,
        Image = "rbxassetid://4483345998"
    })
    
    return true
end

-- 自動検知システム（オプション）
local autoDetectionToggle = AntiGrabTab:CreateToggle({
    Name = "Auto-Detection (Experimental)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            startAutoDetection()
        else
            stopAutoDetection()
        end
    end,
})

-- 自動検知ループ
local detectionConnection = nil

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
                floatingButton.Text = "ANTI-GRAB\n[AUTO-ACTIVE]"
                floatingButton.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
                
                task.wait(1)
                if floatingButton then
                    floatingButton.Text = "ANTI-GRAB\n[READY]"
                    floatingButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
                end
            end
        end
    end)
end

function stopAutoDetection()
    if detectionConnection then
        detectionConnection:Disconnect()
        detectionConnection = nil
    end
end

-- ヘルプ/情報タブ
local HelpTab = Window:CreateTab("Help", "rbxassetid://4483345998")

HelpTab:CreateSection("How to Use")

HelpTab:CreateParagraph({
    Title = "Main Features",
    Content = [[
    1. **Position Saving**: Save up to 10 different positions
    2. **Quick Teleport**: Instantly teleport to saved positions
    3. **Anti-Grab System**: Escape from enemy grabs with one click
    4. **Floating Button**: Dragable button for quick access
    ]]
})

HelpTab:CreateParagraph({
    Title = "Anti-Grab System",
    Content = [[
    • Click the floating button when grabbed by an enemy
    • Auto-detection available (experimental)
    • Teleports you 20 studs away in random direction
    • Includes vertical offset to escape combos
    ]]
})

HelpTab:CreateParagraph({
    Title = "Hotkeys",
    Content = [[
    • **Floating Button**: Click to activate anti-grab
    • **Drag**: Click and drag the floating button to move
    • **Main UI**: Use Rayfield interface for all settings
    ]]
})

-- 初期化
updateSlotDisplay()

-- ゲーム終了時のクリーンアップ
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    if antiGrabEnabled and floatingButton == nil then
        task.wait(2) -- キャラクターが完全にロードされるのを待つ
        createFloatingButton()
    end
end)

Rayfield:Notify({
    Title = "Teleport GUI Loaded",
    Content = "v4.0 by syu_u - Ready to use!",
    Duration = 5,
    Image = "rbxassetid://4483345998"
})
