-- 📌 GodmodeServer.lua
-- Controla el godmode de los jugadores
-- Debe ir en ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Creamos el RemoteEvent si no existe
local toggleEvent = ReplicatedStorage:FindFirstChild("GodmodeToggle")
if not toggleEvent then
    toggleEvent = Instance.new("RemoteEvent")
    toggleEvent.Name = "GodmodeToggle"
    toggleEvent.Parent = ReplicatedStorage
end

-- Tabla para saber quién tiene godmode activado
local godmodeEnabled = {}

-- Cuando un jugador entra
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")

        humanoid.HealthChanged:Connect(function(health)
            if godmodeEnabled[player] and health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)

        humanoid.Died:Connect(function()
            if godmodeEnabled[player] then
                task.defer(function()
                    humanoid.Health = humanoid.MaxHealth
                end)
            end
        end)
    end)
end)

-- Escuchar cuando el cliente pide toggle
toggleEvent.OnServerEvent:Connect(function(player)
    godmodeEnabled[player] = not godmodeEnabled[player]
    print(player.Name .. " godmode: " .. tostring(godmodeEnabled[player]))
end)
