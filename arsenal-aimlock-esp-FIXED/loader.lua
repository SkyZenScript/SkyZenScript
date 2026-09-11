-- Arsenal Aimlock ESP - Fixed Loader
-- Fixed: Script initialization and proper function calling

local scriptPath = script.Parent:WaitForChild("script-skyzen-aimlock-universal.lua")
local gameLoaded = game:GetService("RunService").Loaded

-- Ensure game is fully loaded before executing
if not gameLoaded then
    game:GetService("RunService").Loaded:Connect(function()
        print("[Arsenal ESP] Game loaded, initializing script...")
    end)
end

-- FIXED: Proper script loading
local function LoadScript()
    print("[Arsenal ESP Loader] Starting initialization...")
    
    -- Method 1: loadstring (most reliable)
    local scriptContent = scriptPath.Source or ""
    
    if scriptContent ~= "" then
        local success, result = pcall(function()
            return loadstring(scriptContent)()
        end)
        
        if success then
            print("[Arsenal ESP Loader] Script executed successfully!")
            return true
        else
            print("[Arsenal ESP Loader] Error executing script: " .. tostring(result))
            return false
        end
    else
        print("[Arsenal ESP Loader] Script content is empty!")
        return false
    end
end

-- FIXED: Wait for game to be ready before loading
game:GetService("RunService").Heartbeat:Connect(function()
    local player = game.Players.LocalPlayer
    local character = player and player.Character
    
    if character and not script:GetAttribute("Loaded") then
        if LoadScript() then
            script:SetAttribute("Loaded", true)
            print("[Arsenal ESP Loader] Script loaded and initialized!")
        end
    end
end)

-- Alternative: Direct execution
if getfenv and getfenv() then
    local env = getfenv()
    if env.script then
        LoadScript()
    end
end

print("[Arsenal ESP Loader] Loader initialized and waiting for game...")
