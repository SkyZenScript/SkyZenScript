-- Arsenal Aimlock ESP - Script Utama (Loadstring Version)
-- Gunakan ini dengan loadstring() untuk menjalankan script

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player:WaitForChild("Character")
local Humanoid = Character:WaitForChild("Humanoid")

print("[Arsenal ESP] Script dimulai...")

-- ========== KONFIGURASI ==========
local CONFIG = {
    AimlockEnabled = true,
    ESPEnabled = true,
    AimlockKey = Enum.KeyCode.E,  -- Tombol toggle aimlock
    ESPKey = Enum.KeyCode.R,      -- Tombol toggle ESP
    MaxDistance = 100,             -- Jarak maksimal deteksi
    SmoothAim = true,
    SmoothSpeed = 0.3
}

-- ========== VARIABEL GLOBAL ==========
local AimingAt = nil
local ClosestEnemy = nil
local AimActive = false
local ESPActive = true
local ESP_Labels = {}

-- ========== FUNGSI DETEKSI MUSUH ==========
local function FindClosestEnemy()
    local closestDistance = CONFIG.MaxDistance
    local closestPlayer = nil
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local enemyCharacter = player.Character
            local enemyHumanoid = enemyCharacter:FindFirstChild("Humanoid")
            
            if enemyHumanoid and enemyHumanoid.Health > 0 then
                local enemyPos = enemyCharacter:FindFirstChild("HumanoidRootPart")
                if enemyPos then
                    local distance = (Character:FindFirstChild("HumanoidRootPart").Position - enemyPos.Position).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- ========== FUNGSI AIMLOCK ==========
local function AimAtEnemy(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    local targetCharacter = targetPlayer.Character
    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
    local targetHead = targetCharacter:FindFirstChild("Head")
    
    if not targetHumanoid or targetHumanoid.Health <= 0 or not targetHead then return end
    
    local camera = workspace.CurrentCamera
    local targetPosition = targetHead.Position
    
    if CONFIG.SmoothAim then
        local currentCFrame = camera.CFrame
        local newCFrame = CFrame.new(currentCFrame.Position, targetPosition)
        camera.CFrame = currentCFrame:Lerp(newCFrame, CONFIG.SmoothSpeed)
    else
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
    end
    
    AimingAt = targetPlayer
    print("[Arsenal ESP] Aimlock mengarah ke: " .. targetPlayer.Name)
end

-- ========== FUNGSI ESP ==========
local function CreateESPLabel(player)
    if ESP_Labels[player] then return end
    
    if not player.Character then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    if not humanoidRootPart or not humanoid then return end
    
    -- Buat GUI untuk ESP
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(4, 0, 2, 0)
    bill.MaxDistance = CONFIG.MaxDistance
    bill.Parent = humanoidRootPart
    
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 18
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Parent = bill
    
    -- Update info ESP
    local updateConnection
    updateConnection = RunService.Heartbeat:Connect(function()
        if not player or not player.Character or not humanoid then
            updateConnection:Disconnect()
            bill:Destroy()
            ESP_Labels[player] = nil
            return
        end
        
        local health = humanoid.Health
        local distance = (Character:FindFirstChild("HumanoidRootPart").Position - humanoidRootPart.Position).Magnitude
        
        textLabel.Text = player.Name .. " | HP: " .. math.floor(health) .. " | " .. math.floor(distance) .. "m"
        
        -- Ubah warna berdasarkan kesehatan
        if health > 50 then
            textLabel.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        elseif health > 25 then
            textLabel.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        else
            textLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end)
    
    ESP_Labels[player] = bill
    print("[Arsenal ESP] ESP ditambahkan untuk: " .. player.Name)
end

-- ========== FUNGSI REMOVE ESP ==========
local function RemoveESPLabel(player)
    if ESP_Labels[player] then
        ESP_Labels[player]:Destroy()
        ESP_Labels[player] = nil
        print("[Arsenal ESP] ESP dihapus untuk: " .. player.Name)
    end
end

-- ========== INPUT HANDLING ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == CONFIG.AimlockKey then
        AimActive = not AimActive
        print("[Arsenal ESP] Aimlock: " .. (AimActive and "ON" or "OFF"))
    end
    
    if input.KeyCode == CONFIG.ESPKey then
        ESPActive = not ESPActive
        print("[Arsenal ESP] ESP: " .. (ESPActive and "ON" or "OFF"))
        
        if not ESPActive then
            for player, _ in pairs(ESP_Labels) do
                RemoveESPLabel(player)
            end
        end
    end
end)

-- ========== MAIN LOOP ==========
RunService.Heartbeat:Connect(function()
    -- Update player
    if not Character or not Character.Parent then
        Character = Player.Character or Player:WaitForChild("Character")
        Humanoid = Character:WaitForChild("Humanoid")
    end
    
    -- Aimlock
    if CONFIG.AimlockEnabled and AimActive then
        ClosestEnemy = FindClosestEnemy()
        if ClosestEnemy then
            AimAtEnemy(ClosestEnemy)
        end
    end
    
    -- ESP
    if CONFIG.ESPEnabled and ESPActive then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and player.Character then
                if not ESP_Labels[player] then
                    CreateESPLabel(player)
                end
            end
        end
    end
end)

-- ========== PLAYER JOINED HANDLER ==========
Players.PlayerAdded:Connect(function(player)
    if ESPActive then
        player.CharacterAdded:Connect(function()
            wait(0.5)
            if ESPActive then
                CreateESPLabel(player)
            end
        end)
    end
end)

-- ========== PLAYER LEFT HANDLER ==========
Players.PlayerRemoving:Connect(function(player)
    RemoveESPLabel(player)
    if AimingAt == player then
        AimingAt = nil
    end
end)

print("[Arsenal ESP] ========== SCRIPT SIAP! ==========")
print("[Arsenal ESP] Tekan E untuk toggle Aimlock")
print("[Arsenal ESP] Tekan R untuk toggle ESP")
print("[Arsenal ESP] Script berhasil dimuat!")
