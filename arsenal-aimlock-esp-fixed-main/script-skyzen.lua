-- SkyZen Aimlock ESP - Mobile Friendly Version
-- Simple & Clean UI, hanya Aimlock dan ESP

local SkyZen = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = SkyZen:CreateWindow({
   Name = "SkyZen Aimlock ESP",
   LoadingTitle = "SkyZen",
   LoadingSubtitle = "Loading...",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "SkyZen",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player:WaitForChild("Character")

print("[SkyZen] Script dimulai...")

-- ========== CONFIG ==========
local CONFIG = {
    AimlockEnabled = false,
    ESPEnabled = true,
    MaxDistance = 100,
    SmoothAim = true,
    SmoothSpeed = 0.3,
    AutoSelectTarget = true,
}

-- ========== VARIABEL ==========
local AimingAt = nil
local ClosestEnemy = nil
local AimActive = false
local ESPActive = true
local ESP_Labels = {}
local TargetInfo = "Tidak ada"

-- ========== TAB AIMLOCK ==========
local TabAimlock = Window:CreateTab("🎯 AIMLOCK", 7733390712)

local SectionAimlock = TabAimlock:CreateSection("Kontrol")

local AimlockToggle = TabAimlock:CreateToggle({
   Name = "🎯 AIMLOCK",
   CurrentValue = CONFIG.AimlockEnabled,
   Flag = "AimlockToggle",
   Callback = function(Value)
      CONFIG.AimlockEnabled = Value
      AimActive = Value
      print("[SkyZen] Aimlock: " .. (Value and "ON ✅" or "OFF ❌"))
   end,
})

TabAimlock:CreateDivider()

local AutoTargetToggle = TabAimlock:CreateToggle({
   Name = "🤖 Auto Target",
   CurrentValue = CONFIG.AutoSelectTarget,
   Flag = "AutoTargetToggle",
   Callback = function(Value)
      CONFIG.AutoSelectTarget = Value
   end,
})

TabAimlock:CreateDivider()

local SectionAimSettings = TabAimlock:CreateSection("Pengaturan")

local SmoothSlider = TabAimlock:CreateSlider({
   Name = "Smooth Speed",
   Range = {0.1, 1.0},
   Increment = 0.1,
   Suffix = "x",
   CurrentValue = CONFIG.SmoothSpeed,
   Flag = "SmoothSlider",
   Callback = function(Value)
      CONFIG.SmoothSpeed = Value
   end,
})

local DistanceSlider = TabAimlock:CreateSlider({
   Name = "Max Distance",
   Range = {50, 200},
   Increment = 10,
   Suffix = "m",
   CurrentValue = CONFIG.MaxDistance,
   Flag = "DistanceSlider",
   Callback = function(Value)
      CONFIG.MaxDistance = Value
      for player, label in pairs(ESP_Labels) do
         if label then
            label.MaxDistance = Value
         end
      end
   end,
})

-- ========== TAB ESP ==========
local TabESP = Window:CreateTab("👁️ ESP", 4483362458)

local SectionESP = TabESP:CreateSection("Kontrol")

local ESPToggle = TabESP:CreateToggle({
   Name = "👁️ ESP",
   CurrentValue = CONFIG.ESPEnabled,
   Flag = "ESPToggle",
   Callback = function(Value)
      CONFIG.ESPEnabled = Value
      ESPActive = Value
      if not Value then
         for player, _ in pairs(ESP_Labels) do
            RemoveESPLabel(player)
         end
      end
      print("[SkyZen] ESP: " .. (Value and "ON ✅" or "OFF ❌"))
   end,
})

TabESP:CreateDivider()

local SectionTools = TabESP:CreateSection("Tools")

TabESP:CreateButton({
   Name = "🔄 Refresh ESP",
   Callback = function()
      for player, label in pairs(ESP_Labels) do
         RemoveESPLabel(player)
      end
      wait(0.5)
      for _, player in pairs(Players:GetPlayers()) do
         if player ~= Player and player.Character then
            CreateESPLabel(player)
         end
      end
      SkyZen:Notify({
         Title = "SkyZen",
         Content = "✅ ESP Refreshed",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

TabESP:CreateButton({
   Name = "🗑️ Clear ESP",
   Callback = function()
      for player, _ in pairs(ESP_Labels) do
         RemoveESPLabel(player)
      end
      SkyZen:Notify({
         Title = "SkyZen",
         Content = "✅ ESP Cleared",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

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
                    local playerRootPart = Character:FindFirstChild("HumanoidRootPart")
                    if playerRootPart then
                        local distance = (playerRootPart.Position - enemyPos.Position).Magnitude
                        
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
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
    TargetInfo = targetPlayer.Name
end

-- ========== FUNGSI ESP ==========
local function CreateESPLabel(player)
    if ESP_Labels[player] then return end
    
    if not player.Character then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    if not humanoidRootPart or not humanoid then return end
    
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(5, 0, 3, 0)
    bill.MaxDistance = CONFIG.MaxDistance
    bill.Parent = humanoidRootPart
    
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 14
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.BorderSizePixel = 0
    textLabel.Parent = bill
    
    local updateConnection
    updateConnection = RunService.Heartbeat:Connect(function()
        if not player or not player.Character or not humanoid then
            updateConnection:Disconnect()
            bill:Destroy()
            ESP_Labels[player] = nil
            return
        end
        
        local health = humanoid.Health
        local playerRootPart = Character:FindFirstChild("HumanoidRootPart")
        
        if playerRootPart then
            local distance = (playerRootPart.Position - humanoidRootPart.Position).Magnitude
            textLabel.Text = player.Name .. "\nHP: " .. math.floor(health) .. "\n" .. math.floor(distance) .. "m"
        end
        
        if health > 50 then
            textLabel.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        elseif health > 25 then
            textLabel.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        else
            textLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end)
    
    ESP_Labels[player] = bill
end

-- ========== FUNGSI REMOVE ESP ==========
function RemoveESPLabel(player)
    if ESP_Labels[player] then
        ESP_Labels[player]:Destroy()
        ESP_Labels[player] = nil
    end
end

-- ========== MAIN LOOP ==========
RunService.Heartbeat:Connect(function()
    if not Character or not Character.Parent then
        Character = Player.Character or Player:WaitForChild("Character")
    end
    
    if CONFIG.AimlockEnabled and AimActive then
        if CONFIG.AutoSelectTarget then
            ClosestEnemy = FindClosestEnemy()
            if ClosestEnemy then
                AimAtEnemy(ClosestEnemy)
            end
        end
    end
    
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

-- ========== PLAYER EVENTS ==========
Players.PlayerAdded:Connect(function(player)
    if ESPActive and CONFIG.ESPEnabled then
        player.CharacterAdded:Connect(function()
            wait(0.5)
            if ESPActive and CONFIG.ESPEnabled then
                CreateESPLabel(player)
            end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESPLabel(player)
    if AimingAt == player then
        AimingAt = nil
        TargetInfo = "Tidak ada"
    end
end)

SkyZen:Notify({
   Title = "SkyZen",
   Content = "✅ Loaded!",
   Duration = 3,
   Image = 4483362458,
})

print("[SkyZen] Script Ready!")
