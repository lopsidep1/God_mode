-- 📌 NPCIgnore.lua
-- Invisibilidad total ante NPCs
-- Colócalo en StarterPlayerScripts

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function applyInvisibility()
    local character = player.Character or player.CharacterAdded:Wait()

    -- 🔁 Loop para interceptar targeting
    for _, npc in ipairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("Head") then
            local aiScript = npc:FindFirstChildWhichIsA("Script", true)
            if aiScript then
                -- Desactivar targeting si usa Player detection
                if aiScript:FindFirstChild("Target") then
                    aiScript.Target.Value = nil
                end
            end

            -- Desactivar seguimiento por distancia
            local head = npc:FindFirstChild("Head")
            if head and head:FindFirstChild("Touched") then
                head.Touched:Connect(function(hit)
                    if hit:IsDescendantOf(character) then
                        -- Ignorar contacto
                        return
                    end
                end)
            end
        end
    end

    -- 🧱 Desactivar tags de detección
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanQuery = false
            part.CanTouch = false
            part.CanCollide = false
        end
    end

    -- 🧠 Desactivar Humanoid para evitar targeting por AI
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end
end

-- Activar al cargar personaje
player.CharacterAdded:Connect(function()
    task.wait(1)
    applyInvisibility()
end)

-- Activar si ya está cargado
if player.Character then
    applyInvisibility()
end
