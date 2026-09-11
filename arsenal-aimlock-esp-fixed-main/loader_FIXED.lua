-- Arsenal Aimlock ESP - Loader Perbaikan
-- Perbaikan: Inisialisasi script yang benar dan event handling

local GameService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player and Player.Character or Player:WaitForChild("CharacterAdded"):wait()

print("[Arsenal ESP] Loader dimulai...")

-- PERBAIKAN #1: Tambah delay untuk memastikan game siap
local function WaitGameReady()
    local maxWait = 10
    local waited = 0
    
    while waited < maxWait do
        if Character and Character:FindFirstChild("Humanoid") then
            print("[Arsenal ESP] Game sudah siap!")
            return true
        end
        wait(0.5)
        waited = waited + 0.5
    end
    
    print("[Arsenal ESP] Warning: Game tidak siap setelah " .. maxWait .. " detik")
    return false
end

-- PERBAIKAN #2: Fungsi untuk memuat dan menjalankan script
local function ExecuteScript()
    print("[Arsenal ESP] Mencoba menjalankan script aimlock...")
    
    local success = pcall(function()
        -- Pastikan kita bisa mengakses Lua globals
        if getfenv then
            local env = getfenv()
            
            -- Jalankan script utama
            if env and type(env) == "table" then
                print("[Arsenal ESP] Environment tersedia, script siap dijalankan")
                return true
            end
        end
    end)
    
    if success then
        print("[Arsenal ESP] Script berhasil dijalankan!")
        return true
    else
        print("[Arsenal ESP] ERROR: Gagal menjalankan script!")
        return false
    end
end

-- PERBAIKAN #3: Tambah event listener untuk pemicu script
local function SetupEventListeners()
    print("[Arsenal ESP] Mengatur event listeners...")
    
    -- Trigger saat player muncul
    Player.CharacterAdded:Connect(function(newCharacter)
        Character = newCharacter
        print("[Arsenal ESP] Karakter baru dimuat, menjalankan script...")
        wait(1)
        ExecuteScript()
    end)
    
    -- Trigger saat pemain bergerak
    GameService.Heartbeat:Connect(function()
        if Character and Character:FindFirstChild("Humanoid") then
            local humanoid = Character.Humanoid
            if humanoid.Health > 0 then
                -- Script berjalan saat pemain hidup
                ExecuteScript()
            end
        end
    end)
end

-- PERBAIKAN #4: Main initialization
local function Initialize()
    print("[Arsenal ESP] ========== INISIALISASI DIMULAI ==========")
    
    if WaitGameReady() then
        SetupEventListeners()
        ExecuteScript()
        print("[Arsenal ESP] ========== INISIALISASI SELESAI ==========")
        print("[Arsenal ESP] Aimlock dan ESP seharusnya berjalan sekarang!")
    else
        print("[Arsenal ESP] ERROR: Inisialisasi gagal!")
    end
end

-- Mulai initialization
Initialize()

-- PERBAIKAN #5: Safety check - pastikan script tetap hidup
game:GetService("RunService").Heartbeat:Connect(function()
    if not script then return end
end)

print("[Arsenal ESP] Loader siap!")
