-- Auditoría y restauración de Godmode
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local protect = true

local function protectHumanoid(hum)
    hum.Name = "ProtectedHumanoid"
    hum.MaxHealth = math.huge
    hum.Health = math.huge
    hum.BreakJointsOnDeath = false
    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
end

local function auditLoop()
    while protect do
        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then
                -- Restaurar Humanoid si fue destruido
                local newHum = Instance.new("Humanoid")
                newHum.Parent = char
                task.wait(0.1)
                protectHumanoid(newHum)
            else
                protectHumanoid(hum)
            end
        end
        task.wait(0.5)
    end
end

-- GUI persistente
local gui = Instance.new("ScreenGui")
gui.Name = "GodmodeUI"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local status = Instance.new("TextLabel", gui)
status.Size = UDim2.new(0, 200, 0, 50)
status.Position = UDim2.new(0.5, -100, 0, 20)
status.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.Font = Enum.Font.GothamBold
status.TextSize = 20
status.Text = "Godmode: ON"

-- Reaplicar en respawn
lp.CharacterAdded:Connect(function(char)
    task.wait(1)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then protectHumanoid(hum) end
end)

-- Iniciar auditoría
task.spawn(auditLoop)
