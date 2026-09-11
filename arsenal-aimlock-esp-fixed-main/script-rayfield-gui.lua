-- Arsenal Aimlock ESP dengan Rayfield GUI
-- Script Profesional dengan Interface Modern

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
   Name = "Arsenal Aimlock ESP",
   LoadingTitle = "Memuat Script...",
   LoadingSubtitle = "by SkyZenScript",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "Arsenal_Aimlock_ESP",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Arsenal Aimlock ESP",
      Subtitle = "Masukkan Key",
      Note = "Tidak ada key yang diperlukan",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"1234"}
   }
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player:WaitForChild("Character")

print("[Arsenal ESP] Script dengan Rayfield dimulai...")

-- ========== KONFIGURASI ==========
local CONFIG = {
    AimlockEnabled = true,
    ESPEnabled = true,
    MaxDistance = 100,
    SmoothAim = true,
    SmoothSpeed = 0.3,
    AimlockKey = Enum.KeyCode.E,
    ESPKey = Enum.KeyCode.R
}

-- ========== VARIABEL GLOBAL ==========
local AimingAt = nil
local ClosestEnemy = nil
local AimActive = false
local ESPActive = true
local ESP_Labels = {}
local TargetInfo = "Tidak ada"

-- ========== TAB 1: HOME ==========
local Tab1 = Window:CreateTab("🏠 Home", 4483362458)

local Section1 = Tab1:CreateSection("Status Script")

Tab1:CreateLabel("Script: Arsenal Aimlock ESP")
Tab1:CreateLabel("Version: 1.0.0")
Tab1:CreateLabel("Status: Online ✅")

local StatusLabel = Tab1:CreateLabel("Target: " .. TargetInfo)

Tab1:CreateDivider()

local Section2 = Tab1:CreateSection("Informasi")

Tab1:CreateLabel("📍 Tekan E untuk Toggle Aimlock")
Tab1:CreateLabel("👁️ Tekan R untuk Toggle ESP")
Tab1:CreateLabel("🎯 Jarak Deteksi: " .. CONFIG.MaxDistance .. "m")

-- ========== TAB 2: AIMLOCK ==========
local Tab2 = Window:CreateTab("🎯 Aimlock", 7733390712)

local SectionAim = Tab2:CreateSection("Pengaturan Aimlock")

local AimlockToggle = Tab2:CreateToggle({
   Name = "Aimlock Enable",
   CurrentValue = CONFIG.AimlockEnabled,
   Flag = "AimlockToggle",
   Callback = function(Value)
      CONFIG.AimlockEnabled = Value
      print("[Arsenal ESP] Aimlock: " .. (Value and "ON" or "OFF"))
   end,
})

local AimActiveToggle = Tab2:CreateToggle({
   Name = "Aktifkan Aimlock Sekarang",
   CurrentValue = AimActive,
   Flag = "AimActiveToggle",
   Callback = function(Value)
      AimActive = Value
      print("[Arsenal ESP] Aimlock Active: " .. (Value and "ON" or "OFF"))
   end,
})

Tab2:CreateDivider()

local SectionAimSettings = Tab2:CreateSection("Pengaturan Smooth Aim")

local SmoothSlider = Tab2:CreateSlider({
   Name = "Smooth Speed",
   Range = {0.1, 1.0},
   Increment = 0.1,
   Suffix = "x",
   CurrentValue = CONFIG.SmoothSpeed,
   Flag = "SmoothSlider",
   Callback = function(Value)
      CONFIG.SmoothSpeed = Value
      print("[Arsenal ESP] Smooth Speed: " .. Value)
   end,
})

local DistanceSlider = Tab2:CreateSlider({
   Name = "Max Distance",
   Range = {50, 200},
   Increment = 10,
   Suffix = "m",
   CurrentValue = CONFIG.MaxDistance,
   Flag = "DistanceSlider",
   Callback = function(Value)
      CONFIG.MaxDistance = Value
      print("[Arsenal ESP] Max Distance: " .. Value .. "m")
   end,
})

Tab2:CreateDivider()

local SectionAimKeys = Tab2:CreateSection("Pengaturan Tombol")

Tab2:CreateKeybind({
   Name = "Tombol Aimlock",
   CurrentValue = CONFIG.AimlockKey,
   HoldToInteract = false,
   Flag = "AimlockKey",
   Callback = function(Value)
      CONFIG.AimlockKey = Value
      print("[Arsenal ESP] Aimlock Key diubah menjadi: " .. tostring(Value))
   end,
})

-- ========== TAB 3: ESP ==========
local Tab3 = Window:CreateTab("👁️ ESP", 4483362458)

local SectionESP = Tab3:CreateSection("Pengaturan ESP")

local ESPToggle = Tab3:CreateToggle({
   Name = "ESP Enable",
   CurrentValue = CONFIG.ESPEnabled,
   Flag = "ESPToggle",
   Callback = function(Value)
      CONFIG.ESPEnabled = Value
      print("[Arsenal ESP] ESP: " .. (Value and "ON" or "OFF"))
   end,
})

local ESPActiveToggle = Tab3:CreateToggle({
   Name = "Aktifkan ESP Sekarang",
   CurrentValue = ESPActive,
   Flag = "ESPActiveToggle",
   Callback = function(Value)
      ESPActive = Value
      if not Value then
         for player, _ in pairs(ESP_Labels) do
            RemoveESPLabel(player)
         end
      end
      print("[Arsenal ESP] ESP Active: " .. (Value and "ON" or "OFF"))
   end,
})

Tab3:CreateDivider()

local SectionESPStyle = Tab3:CreateSection("Style ESP")

Tab3:CreateLabel("✅ HP Display Otomatis")
Tab3:CreateLabel("✅ Distance Display")
Tab3:CreateLabel("✅ Color-Coded (Hijau/Orange/Merah)")

Tab3:CreateDivider()

local SectionESPTools = Tab3:CreateSection("Tools")

Tab3:CreateButton({
   Name = "Refresh ESP Semua Player",
   Callback = function()
      print("[Arsenal ESP] Refresh semua ESP labels...")
      for player, label in pairs(ESP_Labels) do
         RemoveESPLabel(player)
      end
      wait(0.5)
      for _, player in pairs(Players:GetPlayers()) do
         if player ~= Player and player.Character then
            CreateESPLabel(player)
         end
      end
      Rayfield:Notify({
         Title = "Arsenal ESP",
         Content = "ESP di-refresh untuk semua player",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

Tab3:CreateButton({
   Name = "Hapus Semua ESP",
   Callback = function()
      print("[Arsenal ESP] Menghapus semua ESP labels...")
      for player, _ in pairs(ESP_Labels) do
         RemoveESPLabel(player)
      end
      Rayfield:Notify({
         Title = "Arsenal ESP",
         Content = "Semua ESP label dihapus",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- ========== TAB 4: TOOLS ==========
local Tab4 = Window:CreateTab("🛠️ Tools", 7733390712)

local SectionTools = Tab4:CreateSection("Kontrol Script")

Tab4:CreateButton({
   Name = "🔄 Restart Script",
   Callback = function()
      print("[Arsenal ESP] Script di-restart...")
      Rayfield:Notify({
         Title = "Arsenal ESP",
         Content = "Script berhasil di-restart",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

Tab4:CreateButton({
   Name = "🗑️ Destroy Script",
   Callback = function()
      print("[Arsenal ESP] Script dihancurkan...")
      for player, label in pairs(ESP_Labels) do
         RemoveESPLabel(player)
      end
      Rayfield:Destroy()
   end,
})

Tab4:CreateDivider()

local SectionCredits = Tab4:CreateSection("Informasi")

Tab4:CreateLabel("Developer: SkyZenScript")
Tab4:CreateLabel("Version: 1.0.0")
Tab4:CreateLabel("Last Update: 2024")

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
    bill.Size = UDim2.new(4, 0, 2, 0)
    bill.MaxDistance = CONFIG.MaxDistance
    bill.Parent = humanoidRootPart
    
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 18
    textLabel.Size = UDim2.new(1, 0, 1, 0)
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
        local distance = (Character:FindFirstChild("HumanoidRootPart").Position - humanoidRootPart.Position).Magnitude
        
        textLabel.Text = player.Name .. " | HP: " .. math.floor(health) .. " | " .. math.floor(distance) .. "m"
        
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

-- ========== INPUT HANDLING ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == CONFIG.AimlockKey then
        AimActive = not AimActive
        AimActiveToggle:Set(AimActive)
        print("[Arsenal ESP] Aimlock: " .. (AimActive and "ON" or "OFF"))
    end
    
    if input.KeyCode == CONFIG.ESPKey then
        ESPActive = not ESPActive
        ESPActiveToggle:Set(ESPActive)
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
    if not Character or not Character.Parent then
        Character = Player.Character or Player:WaitForChild("Character")
    end
    
    -- Update Status Label
    if TargetInfo == "Tidak ada" then
        StatusLabel:Set("Target: " .. TargetInfo)
    else
        StatusLabel:Set("Target: " .. TargetInfo .. " ✓")
    end
    
    if CONFIG.AimlockEnabled and AimActive then
        ClosestEnemy = FindClosestEnemy()
        if ClosestEnemy then
            AimAtEnemy(ClosestEnemy)
        else
            TargetInfo = "Tidak ada"
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
    if ESPActive then
        player.CharacterAdded:Connect(function()
            wait(0.5)
            if ESPActive then
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

Rayfield:Notify({
   Title = "Arsenal Aimlock ESP",
   Content = "Script berhasil dimuat! Tekan E untuk Aimlock, R untuk ESP",
   Duration = 4.5,
   Image = 4483362458,
})

print("[Arsenal ESP] ========== SCRIPT SIAP! ==========")
print("[Arsenal ESP] Rayfield GUI Loaded!")
