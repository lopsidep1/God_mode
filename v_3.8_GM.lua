-- Auditoría de Muerte Hostil v1.0
-- Detecta y reporta causas de muerte, destrucción o interferencia

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "AuditUI"
gui.ResetOnSpawn = false

local log = Instance.new("TextLabel", gui)
log.Size = UDim2.new(0, 400, 0, 100)
log.Position = UDim2.new(0.5, -200, 0, 20)
log.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
log.TextColor3 = Color3.fromRGB(255, 255, 255)
log.Font = Enum.Font.Code
log.TextSize = 16
log.TextWrapped = true
log.TextYAlignment = Enum.TextYAlignment.Top
log.Text = "🧠 Auditoría activa..."

-- Detectar destrucción del Character
char.AncestryChanged:Connect(function(_, parent)
    if not parent then
        log.Text = "⚠️ Character fue destruido (Parent = nil)"
    end
end)

-- Detectar eliminación del Humanoid
hum.Destroying:Connect(function()
    log.Text = "⚠️ Humanoid fue destruido"
end)

-- Detectar daño directo
hum.HealthChanged:Connect(function(h)
    if h < hum.MaxHealth then
        log.Text = "⚠️ Health cambiado: " .. tostring(h)
    end
end)

-- Detectar muerte
hum.Died:Connect(function()
    log.Text = "💀 Humanoid murió"
end)

-- Detectar RemoteEvents hostiles (si tu executor lo permite)
if getgc and typeof(getgc) == "function" then
    for _, obj in ipairs(getgc(true)) do
        if typeof(obj) == "function" and getfenv(obj).script then
            local name = getfenv(obj).script.Name
            if tostring(obj):find("TakeDamage") or tostring(obj):find("BreakJoints") then
                log.Text = "🚨 Posible Remote hostil detectado en: " .. name
            end
        end
    end
end

-- Reaplicar auditoría en respawn
lp.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = newChar:WaitForChild("Humanoid")
    log.Text = "🧠 Auditoría reactivada tras respawn"
end)
