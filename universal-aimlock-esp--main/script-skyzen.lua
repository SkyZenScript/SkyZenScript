-- SkyZen Aimlock ESP - Mobile Friendly Version
-- Simple & Clean UI, hanya Aimlock dan ESP
-- Updated with Wall Penetration ESP, Line Tracer, dan Clean Name Display

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
    LineTracerEnabled = true,
}

-- ========== VARIABEL ==========
local AimingAt = nil
local ClosestEnemy = nil
local AimActive = false
local ESPActive = true
local ESP_Labels = {}
local ESP_Lines = {}
local TargetInfo = "Tidak ada"

-- ========== TAB AIMLOCK ==========
local TabAimlock = Window:CreateTab("🎯 AIMLOCK", 7733390712)

local SectionAimlock = TabAimlock:CreateSection("Kontrol")

local AimlockToggle = TabAimlock:CreateToggle({
   Name = "🎯 AIMLOCK + AUTO TARGET",
   CurrentValue = CONFIG.AimlockEnabled,
   Flag = "AimlockToggle",
   Callback = function(Value)
      CONFIG.AimlockEnabled = Value
      AimActive = Value
      CONFIG.AutoSelectTarget = Value
      print("[SkyZen] Aimlock + Auto Target: " .. (Value and "ON ✅" or "OFF ❌"))
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
         for _, line in pairs(ESP_Lines) do
            if line then line:Destroy() end
         end
         ESP_Lines = {}
      end
      print("[SkyZen] ESP: " .. (Value and "ON ✅" or "OFF ❌"))
   end,
})

TabESP:CreateDivider()

local LineTracerToggle = TabESP:CreateToggle({
   Name = "📍 Line Tracer (Garis Merah)",
   CurrentValue = CONFIG.LineTracerEnabled,
   Flag = "LineTracerToggle",
   Callback = function(Value)
      CONFIG.LineTracerEnabled = Value
      if not Value then
         for _, line in pairs(ESP_Lines) do
            if line then line:Destroy() end
         end
         ESP_Lines = {}
      end
      print("[SkyZen] Line Tracer: " .. (Value and "ON ✅" or "OFF ❌"))
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
      for _, line in pairs(ESP_Lines) do
         if line then line:Destroy() end
      end
      ESP_Lines = {}
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
      for _, line in pairs(ESP_Lines) do
         if line then line:Destroy() end
      end
      ESP_Lines = {}
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

-- ========== FUNGSI CREATE LINE TRACER ==========
local function CreateLineTracer(player)
    if not player or not player.Character then return end
    
    local enemyRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not enemyRootPart then return end
    
    -- Hapus line lama jika ada
    if ESP_Lines[player] then
        ESP_Lines[player]:Destroy()
    end
    
    -- Buat line baru
    local line = Instance.new("Part")
    line.Name = "LineTracer_" .. player.Name
    line.Shape = Enum.PartType.Cylinder
    line.Material = Enum.Material.Neon
    line.Color = Color3.fromRGB(255, 0, 0)
    line.CanCollide = false
    line.CFrame = CFrame.new(0, 0, 0)
    line.TopSurface = Enum.SurfaceType.Smooth
    line.BottomSurface = Enum.SurfaceType.Smooth
    line.Transparency = 0.3
    line.Parent = workspace
    
    ESP_Lines[player] = line
    
    -- Update line position setiap frame
    local lineConnection
    lineConnection = RunService.Heartbeat:Connect(function()
        if not player or not player.Character or not enemyRootPart.Parent then
            lineConnection:Disconnect()
            if ESP_Lines[player] then
                ESP_Lines[player]:Destroy()
                ESP_Lines[player] = nil
            end
            return
        end
        
        local playerRootPart = Character:FindFirstChild("HumanoidRootPart")
        if playerRootPart and enemyRootPart then
            local distance = (playerRootPart.Position - enemyRootPart.Position).Magnitude
            local midpoint = (playerRootPart.Position + enemyRootPart.Position) / 2
            
            line.Size = Vector3.new(0.1, distance, 0.1)
            line.CFrame = CFrame.new(midpoint, enemyRootPart.Position)
        end
    end)
end

-- ========== FUNGSI ESP ==========
local function CreateESPLabel(player)
    if ESP_Labels[player] then return end
    
    if not player.Character then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    local head = character:FindFirstChild("Head")
    
    if not humanoidRootPart or not humanoid or not head then return end
    
    -- Buat BillboardGui untuk nama player (tanpa box)
    local nameBill = Instance.new("BillboardGui")
    nameBill.Size = UDim2.new(4, 0, 2, 0)
    nameBill.MaxDistance = CONFIG.MaxDistance
    nameBill.Parent = head
    nameBill.Name = "NameLabel_" .. player.Name
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1  -- Transparent, no box
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 16
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = player.Name
    nameLabel.Parent = nameBill
    
    -- Buat BillboardGui untuk info HP dan jarak
    local infoBill = Instance.new("BillboardGui")
    infoBill.Size = UDim2.new(4, 0, 2, 0)
    infoBill.MaxDistance = CONFIG.MaxDistance
    infoBill.Parent = humanoidRootPart
    infoBill.Name = "InfoLabel_" .. player.Name
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.BackgroundTransparency = 0.3
    infoLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.TextSize = 12
    infoLabel.Size = UDim2.new(1, 0, 1, 0)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.BorderSizePixel = 0
    infoLabel.Parent = infoBill
    
    local updateConnection
    updateConnection = RunService.Heartbeat:Connect(function()
        if not player or not player.Character or not humanoid then
            updateConnection:Disconnect()
            nameBill:Destroy()
            infoBill:Destroy()
            ESP_Labels[player] = nil
            if ESP_Lines[player] then
                ESP_Lines[player]:Destroy()
                ESP_Lines[player] = nil
            end
            return
        end
        
        local health = humanoid.Health
        local playerRootPart = Character:FindFirstChild("HumanoidRootPart")
        
        if playerRootPart then
            local distance = (playerRootPart.Position - humanoidRootPart.Position).Magnitude
            infoLabel.Text = "HP: " .. math.floor(health) .. "\n" .. math.floor(distance) .. "m"
        end
        
        -- Color-coded HP untuk nama
        if health > 50 then
            nameLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            infoLabel.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        elseif health > 25 then
            nameLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
            infoLabel.BackgroundColor3 = Color3.fromRGB(100, 80, 0)
        else
            nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            infoLabel.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        end
    end)
    
    ESP_Labels[player] = nameBill
    
    -- Buat line tracer
    if CONFIG.LineTracerEnabled then
        CreateLineTracer(player)
    end
end

-- ========== FUNGSI REMOVE ESP ==========
function RemoveESPLabel(player)
    if ESP_Labels[player] then
        ESP_Labels[player]:Destroy()
        ESP_Labels[player] = nil
    end
    if ESP_Lines[player] then
        ESP_Lines[player]:Destroy()
        ESP_Lines[player] = nil
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
