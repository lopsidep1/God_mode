-- 📌 Godmode para Testing en Roblox Studio
-- El jugador nunca muere ni pierde vida al testear niveles
-- Colócalo en StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- 🚦 Solo se activa en Studio para testeo
if not RunService:IsStudio() then
    return
end

local player = Players.LocalPlayer

local function enableGodmode(humanoid)
    -- Siempre fuerza la vida al máximo
    humanoid.HealthChanged:Connect(function()
        humanoid.Health = humanoid.MaxHealth
    end)

    -- Evita que el personaje muera
    humanoid.Died:Connect(function()
        task.defer(function()
            humanoid.Health = humanoid.MaxHealth
        end)
    end)
end

local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        enableGodmode(humanoid)
    end
end

player.CharacterAdded:Connect(onCharacterAdded)

-- Si ya hay un personaje cargado, aplica godmode
if player.Character then
    onCharacterAdded(player.Character)
end
