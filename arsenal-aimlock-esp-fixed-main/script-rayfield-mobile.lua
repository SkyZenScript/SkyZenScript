-- Arsenal Aimlock ESP - Mobile Friendly Version dengan Auto-Aimlock
-- Rayfield GUI tanpa perlu keyboard, langsung click untuk toggle

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
   Name = "Arsenal Aimlock ESP Mobile",
   LoadingTitle = "Memuat Script...",
   LoadingSubtitle = "by SkyZenScript - Mobile Optimized",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "Arsenal_Aimlock_ESP_Mobile",
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
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player:WaitForChild("Character")

print("[Arsenal ESP Mobile] Script untuk Mobile dimulai...")

-- ========== KONFIGURASI ==========
local CONFIG = {
    AimlockEnabled = false,  -- Disabled by default untuk mobile
    ESPEnabled = true,
    MaxDistance = 100,
    SmoothAim = true,
    SmoothSpeed = 0.3,
    AutoSelectTarget = true,
    ShowFPS = true
}

-- ========== VARIABEL GLOBAL ==========
local AimingAt = nil
local ClosestEnemy = nil
local AimActive = false
local ESPActive = true
local ESP_Labels = {}
local TargetInfo = "Tidak ada"
local CurrentFPS = 0

-- ========== TAB 1: HOME ==========
local Tab1 = Window:CreateTab("🏠 Home", 4483362458)

local Section1 = Tab1:CreateSection("⚡ Status Real-Time")

local StatusLabel = Tab1:CreateLabel("Target: Tidak ada ❌")
local FPSLabel = Tab1:CreateLabel("FPS: 60")
local AimlockStatusLabel = Tab1:CreateLabel("Aimlock: OFF ❌")
local ESPStatusLabel = Tab1:CreateLabel("ESP: ON ✅")

Tab1:CreateDivider()

local Section2 = Tab1:CreateSection("🎮 Quick Start")

Tab1:CreateLabel("📱 Versi Mobile Friendly")
Tab1:CreateLabel("✅ Tanpa perlu keyboard")
Tab1:CreateLabel("✅ Toggle langsung via tombol")
Tab1:CreateLabel("✅ Auto-target musuh terdekat")

-- ========== TAB 2: AIMLOCK (MOBILE FRIENDLY) ==========
local Tab2 = Window:CreateTab("🎯 Aimlock", 7733390712)

local SectionAimToggle = Tab2:CreateSection("⚡ Kontrol Aimlock")

local AimlockMainToggle = Tab2:CreateToggle({
   Name = "🎯 AIMLOCK ON/OFF",
   CurrentValue = CONFIG.AimlockEnabled,
   Flag = "AimlockMainToggle",
   Callback = function(Value)
      CONFIG.AimlockEnabled = Value
      AimActive = Value  -- Langsung aktif ketika toggle
      if Value then
         AimlockStatusLabel:Set("Aimlock: ON ✅")
         Rayfield:Notify({
            Title = "Arsenal Aimlock",
            Content = "🎯 Aimlock AKTIF - Mulai mengarahkan ke musuh",
            Duration = 2,
            Image = 4483362458,
         })
         print("[Arsenal ESP] Aimlock AKTIF")
      else
         AimlockStatusLabel:Set("Aimlock: OFF ❌")
         Rayfield:Notify({
            Title = "Arsenal Aimlock",
            Content = "❌ Aimlock NONAKTIF",
            Duration = 2,
            Image = 4483362458,
         })
         print("[Arsenal ESP] Aimlock NONAKTIF")
         TargetInfo = "Tidak ada"
         StatusLabel:Set("Target: Tidak ada ❌")
      end
   end,
})

Tab2:CreateDivider()

local SectionAutoTarget = Tab2:CreateSection("🤖 Auto Target")

local AutoTargetToggle = Tab2:CreateToggle({
   Name = "Auto Pilih Target Terdekat",
   CurrentValue = CONFIG.AutoSelectTarget,
   Flag = "AutoTargetToggle",
   Callback = function(Value)
      CONFIG.AutoSelectTarget = Value
      print("[Arsenal ESP] Auto-select target: " .. (Value and "ON" or "OFF"))
   end,
})

Tab2:CreateDivider()

local SectionAimSettings = Tab2:CreateSection("⚙️ Pengaturan Smooth Aim")

local SmoothSlider = Tab2:CreateSlider({
   Name = "Smooth Speed (Kecepatan Aim)",
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
   Name = "Max Distance (Jarak Jangkauan)",
   Range = {50, 200},
   Increment = 10,
   Suffix = "m",
   CurrentValue = CONFIG.MaxDistance,
   Flag = "DistanceSlider",
   Callback = function(Value)
      CONFIG.MaxDistance = Value
      print("[Arsenal ESP] Max Distance: " .. Value .. "m")
      
      -- Update semua ESP labels dengan jarak baru
      for player, label in pairs(ESP_Labels) do
         if label then
            label.MaxDistance = Value
         end
      end
   end,
})

Tab2:CreateDivider()

local SectionAimInfo = Tab2:CreateSection("ℹ️ Informasi Target")

local CurrentTargetLabel = Tab2:CreateLabel("Target Saat Ini: Tidak ada")

-- ========== TAB 3: ESP (MOBILE FRIENDLY) ==========
local Tab3 = Window:CreateTab("👁️ ESP", 4483362458)

local SectionESPToggle = Tab3:CreateSection("⚡ Kontrol ESP")

local ESPMainToggle = Tab3:CreateToggle({
   Name = "👁️ ESP ON/OFF",
   CurrentValue = CONFIG.ESPEnabled,
   Flag = "ESPMainToggle",
   Callback = function(Value)
      CONFIG.ESPEnabled = Value
      ESPActive = Value  -- Langsung aktif ketika toggle
      if Value then
         ESPStatusLabel:Set("ESP: ON ✅")
         Rayfield:Notify({
            Title = "Arsenal ESP",
            Content = "👁️ ESP AKTIF - Mulai menampilkan musuh",
            Duration = 2,
            Image = 4483362458,
         })
         print("[Arsenal ESP] ESP AKTIF")
      else
         ESPStatusLabel:Set("ESP: OFF ❌")
         Rayfield:Notify({
            Title = "Arsenal ESP",
            Content = "❌ ESP NONAKTIF",
            Duration = 2,
            Image = 4483362458,
         })
         print("[Arsenal ESP] ESP NONAKTIF")
         for player, _ in pairs(ESP_Labels) do
            RemoveESPLabel(player)
         end
      end
   end,
})

Tab3:CreateDivider()

local SectionESPStyle = Tab3:CreateSection("🎨 ESP Display")

Tab3:CreateLabel("✅ Nama Player")
Tab3:CreateLabel("✅ HP Bar & Angka")
Tab3:CreateLabel("✅ Jarak Dari Pemain")
Tab3:CreateLabel("✅ Color-Coded:")
Tab3:CreateLabel("   🟢 Hijau = HP Penuh (>50%)")
Tab3:CreateLabel("   🟠 Orange = HP Sedang (25-50%)")
Tab3:CreateLabel("   🔴 Merah = HP Rendah (<25%)")

Tab3:CreateDivider()

local SectionESPTools = Tab3:CreateSection("🛠️ Tools ESP")

Tab3:CreateButton({
   Name = "🔄 Refresh ESP Semua Player",
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
         Content = "✅ ESP di-refresh untuk semua player",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

Tab3:CreateButton({
   Name = "🗑️ Hapus Semua ESP",
   Callback = function()
      print("[Arsenal ESP] Menghapus semua ESP labels...")
      for player, _ in pairs(ESP_Labels) do
         RemoveESPLabel(player)
      end
      Rayfield:Notify({
         Title = "Arsenal ESP",
         Content = "✅ Semua ESP label dihapus",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- ========== TAB 4: TOOLS & SETTINGS ==========
local Tab4 = Window:CreateTab("🛠️ Tools", 7733390712)

local SectionTools = Tab4:CreateSection("⚙️ Kontrol Utama")

Tab4:CreateButton({
   Name = "🔄 Restart Script",
   Callback = function()
      print("[Arsenal ESP] Script di-restart...")
      Rayfield:Notify({
         Title = "Arsenal ESP",
         Content = "✅ Script berhasil di-restart",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

Tab4:CreateButton({
   Name = "🗑️ Destroy Script (Hapus Selamanya)",
   Callback = function()
      print("[Arsenal ESP] Script dihancurkan...")
      for player, label in pairs(ESP_Labels) do
         RemoveESPLabel(player)
      end
      Rayfield:Notify({
         Title = "Arsenal ESP",
         Content = "❌ Script dihapus",
         Duration = 2,
         Image = 4483362458,
      })
      Rayfield:Destroy()
   end,
})

Tab4:CreateDivider()

local SectionVisuals = Tab4:CreateSection("👁️ Visuals")

local ShowFPSToggle = Tab4:CreateToggle({
   Name = "Tampilkan FPS Counter",
   CurrentValue = CONFIG.ShowFPS,
   Flag = "ShowFPSToggle",
   Callback = function(Value)
      CONFIG.ShowFPS = Value
      print("[Arsenal ESP] FPS Counter: " .. (Value and "ON" or "OFF"))
   end,
})

Tab4:CreateDivider()

local SectionAbout = Tab4:CreateSection("ℹ️ Tentang Script")

Tab4:CreateLabel("📱 Arsenal Aimlock ESP")
Tab4:CreateLabel("🎯 Mobile Optimized Version")
Tab4:CreateLabel("👨‍💻 Developer: SkyZenScript")
Tab4:CreateLabel("📦 Version: 2.0.0")
Tab4:CreateLabel("🔧 Last Update: 2024")
Tab4:CreateLabel("✨ Optimized untuk Mobile & PC")

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
    CurrentTargetLabel:Set("Target Saat Ini: " .. targetPlayer.Name .. " ✅")
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
    bill.Name = "ESPLabel_" .. player.Name
    
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
            textLabel.Text = player.Name .. "\nHP: " .. math.floor(health) .. "/100\n" .. math.floor(distance) .. "m"
        end
        
        -- Color-coded HP
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

-- ========== MAIN LOOP - AIMLOCK & ESP ==========
RunService.Heartbeat:Connect(function()
    -- Update character
    if not Character or not Character.Parent then
        Character = Player.Character or Player:WaitForChild("Character")
    end
    
    -- Update FPS
    CurrentFPS = math.floor(1 / RunService.Heartbeat:Wait())
    if CONFIG.ShowFPS then
        FPSLabel:Set("FPS: " .. CurrentFPS)
    end
    
    -- Update status labels
    if not AimActive then
        StatusLabel:Set("Target: Tidak ada ❌")
    end
    
    -- Aimlock - Auto target dan aim
    if CONFIG.AimlockEnabled and AimActive then
        if CONFIG.AutoSelectTarget then
            ClosestEnemy = FindClosestEnemy()
            if ClosestEnemy then
                AimAtEnemy(ClosestEnemy)
                StatusLabel:Set("Target: " .. ClosestEnemy.Name .. " ✅")
            else
                TargetInfo = "Tidak ada"
                StatusLabel:Set("Target: Tidak ada ❌")
            end
        end
    end
    
    -- ESP - Tampilkan semua musuh
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
        StatusLabel:Set("Target: Tidak ada ❌")
        CurrentTargetLabel:Set("Target Saat Ini: Tidak ada")
    end
end)

-- ========== STARTUP NOTIFICATION ==========
Rayfield:Notify({
   Title = "🎯 Arsenal Aimlock ESP",
   Content = "✅ Mobile Optimized v2.0 berhasil dimuat!\n\n📱 Untuk Mobile: Gunakan toggle tombol di GUI\n💻 Untuk PC: Gunakan GUI atau keyboard\n\n✨ Selamat menggunakan!",
   Duration = 5,
   Image = 4483362458,
})

print("[Arsenal ESP Mobile] ========== SCRIPT SIAP! ==========")
print("[Arsenal ESP Mobile] Rayfield GUI Loaded!")
print("[Arsenal ESP Mobile] Mobile Optimized Version 2.0")
print("[Arsenal ESP Mobile] Click toggles untuk ON/OFF aimlock dan ESP")
