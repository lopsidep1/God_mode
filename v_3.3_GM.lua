-- Ultra⁺⁺⁺⁺ Debug Core FINAL by lopsidep
-- Godmode funcional, GUI persistente, protección total

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local godmode = false

-- 🖥️ GUI de estado
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GodmodeStatusUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 200, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 10)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 20
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = screenGui

local function updateStatusLabel()
    if godmode then
        statusLabel.Text = "Godmode: ✅ ACTIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        statusLabel.Text = "Godmode: ❌ DESACTIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end

-- ✅ Notificación visual
local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Ultra⁺⁺⁺⁺ Debug",
            Text = text,
            Duration = 3
        })
    end)
end

-- 🛡️ Protección del Humanoid
local function reinforceHumanoidProtection(h)
    if h and h:IsA("Humanoid") then
        h.BreakJointsOnDeath = false
        h:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        pcall(function() h.TakeDamage = function() end end)
        h.Died:Connect(function()
            if godmode then h.Health = h.MaxHealth end
        end)
    end
end

-- 🧯 Protección global
local function applyGlobalProtections()
    pcall(function()
        StarterGui:SetCore("ResetButtonCallback", false)
        character.BreakJoints = function() end
        character.Destroy = function() end
    end)
end

-- 🧪 Interceptar RemoteEvents
local function interceptRemotes()
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("BindableEvent") then
            pcall(function()
                remote.OnClientEvent:Connect(function(...)
                    if godmode then return end
                end)
            end)
        end
    end
end

-- ♻️ Respawn-safe
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    if godmode then
        reinforceHumanoidProtection(humanoid)
        applyGlobalProtections()
    end
end)

-- ⌨️ Activación por tecla G
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G then
        godmode = not godmode
        updateStatusLabel()
        if godmode then
            reinforceHumanoidProtection(humanoid)
            interceptRemotes()
            applyGlobalProtections()
            notify("Godmode ACTIVADO ✅")
        else
            notify("Godmode DESACTIVADO ❌")
        end
    end
end)

-- 🔁 Protección constante
RunService.Stepped:Connect(function()
    if godmode then
        if humanoid and humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
        if Workspace.Gravity ~= 196.2 then
            Workspace.Gravity = 196.2
        end
    end
end)

-- Inicializar GUI
updateStatusLabel()
