-- 📌 GodmodeLoader.lua
-- Script todo-en-uno para activar Godmode con tecla G + UI
-- Colócalo en StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local godmode = false

-- 🛠 Crear RemoteEvent si no existe
local toggleEvent = ReplicatedStorage:FindFirstChild("GodmodeToggle")
if not toggleEvent then
    toggleEvent = Instance.new("RemoteEvent")
    toggleEvent.Name = "GodmodeToggle"
    toggleEvent.Parent = ReplicatedStorage
end

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

-- 🔄 Actualizar UI
local function updateUI()
    if godmode then
        box.BackgroundColor3 = Color3.fromRGB(40, 200, 60)
        label.Text = "Godmode ON"
    else
        box.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        label.Text = "Godmode OFF"
    end
end

-- ⌨️ Toggle con G
local function toggle(_, state)
    if state == Enum.UserInputState.Begin then
        godmode = not godmode
        updateUI()
        toggleEvent:FireServer()
    end
    return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction("ToggleGodmode", toggle, false, Enum.KeyCode.G)
updateUI()

-- 🛡 Protección en tiempo real
local function protectCharacter(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    humanoid.HealthChanged:Connect(function(health)
        if godmode and health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)

    humanoid.Died:Connect(function()
        if godmode then
            task.defer(function()
                humanoid.Health = humanoid.MaxHealth
            end)
        end
    end)
end

-- 🔁 Aplicar protección al personaje actual y futuros
if player.Character then
    protectCharacter(player.Character)
end

player.CharacterAdded:Connect(protectCharacter)
