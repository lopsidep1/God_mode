-- Godmode LocalScript para Roblox Studio
-- Coloca este script en StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local godmode = false

-- Función para mostrar notificación
local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Godmode",
            Text = text,
            Duration = 4
        })
    end)
end

-- Función para activar el godmode
local function enableGodmode()
    godmode = true
    notify("Godmode ACTIVADO")
end

-- Función para desactivar el godmode
local function disableGodmode()
    godmode = false
    notify("Godmode DESACTIVADO")
end

-- Alternar godmode con la tecla "G"
game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.G then
        if godmode then
            disableGodmode()
        else
            enableGodmode()
        end
    end
end)

-- Monitorear el personaje y protegerlo
local function protectCharacter(char)
    -- Restaurar vida máxima
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Previene cualquier daño
    humanoid.HealthChanged:Connect(function(health)
        if godmode and health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)

    -- Evita muertes
    humanoid.Died:Connect(function()
        if godmode then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end

-- Detecta nuevo personaje/spawn
player.CharacterAdded:Connect(protectCharacter)
if player.Character then
    protectCharacter(player.Character)
end

-- Mensaje inicial
notify("Presiona G para activar/desactivar Godmode")
