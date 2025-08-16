-- 📌 Godmode de Testing (con toggle G + cuadro de estado)
-- ⚠️ Solo funciona en Studio (no en servidores públicos)
-- Colócalo en StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

if not RunService:IsStudio() then
    return
end

local player = Players.LocalPlayer
local godmode = false
local healthConn, diedConn

-- 🖼 GUI de estado
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GodmodeStatus"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local box = Instance.new("Frame")
box.Size = UDim2.new(0, 100, 0, 40)
box.Position = UDim2.new(0, 20, 0, 20)
box.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
box.BorderSizePixel = 0
box.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = box

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "Godmode OFF"
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 18
label.Parent = box

-- 🔄 Actualizar GUI
local function updateStatus()
    if godmode then
        box.BackgroundColor3 = Color3.fromRGB(40, 200, 60)
        label.Text = "Godmode ON"
    else
        box.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        label.Text = "Godmode OFF"
    end
end

-- ❌ Desconectar listeners
local function disconnect()
    if healthConn then healthConn:Disconnect() healthConn = nil end
    if diedConn then diedConn:Disconnect() diedConn = nil end
end

-- 💚 Activar protección al Humanoid
local function attach(humanoid)
    disconnect()
    if not humanoid then return end

    healthConn = humanoid.HealthChanged:Connect(function(h)
        if godmode and h < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)

    diedConn = humanoid.Died:Connect(function()
        if godmode then
            task.defer(function()
                humanoid.Health = humanoid.MaxHealth
            end)
        end
    end)
end

-- 🧍 Conectar al personaje
local function onCharacterAdded(char)
    local hum = char:WaitForChild("Humanoid", 5)
    attach(hum)
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character) end

-- ⌨️ Toggle con G
local function toggleGodmode(_, state)
    if state == Enum.UserInputState.Begin then
        godmode
