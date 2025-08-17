local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character, humanoid
local godmode = false

-- 🧠 Actualizar referencias
local function updateRefs()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
end

updateRefs()

player.CharacterAdded:Connect(function()
    updateRefs()
    if godmode then
        reinforce()
    end
end)

-- 🖥️ GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "GodmodeStatusUI"
gui.ResetOnSpawn = false

local label = Instance.new("TextLabel", gui)
label.Size = UDim2.new(0, 200, 0, 30)
label.Position = UDim2.new(0, 10, 0, 10)
label.BackgroundTransparency = 1
label.Font = Enum.Font.SourceSansBold
label.TextSize = 20
label.TextXAlignment = Enum.TextXAlignment.Left

local function updateLabel()
    label.Text = godmode and "Godmode: ✅ ACTIVADO" or "Godmode: ❌ DESACTIVADO"
    label.TextColor3 = godmode and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end

-- 🛡️ Protección
local function reinforce()
    if humanoid and humanoid:IsA("Humanoid") then
        humanoid.BreakJointsOnDeath = false
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        pcall(function() humanoid.TakeDamage = function() end end)
        humanoid.Died:Connect(function()
            if godmode then humanoid.Health = humanoid.MaxHealth end
        end)
    end
end

-- 🧪 Interceptar RemoteEvents
local function interceptRemotes()
    for _, r in ipairs(ReplicatedStorage:GetDescendants()) do
        if r:IsA("RemoteEvent") or r:IsA("BindableEvent") then
            pcall(function()
                r.OnClientEvent:Connect(function()
                    if godmode then return end
                end)
            end)
        end
    end
end

-- ⌨️ Activación por G
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.G then
        godmode = not godmode
        updateLabel()
        if godmode then
            reinforce()
            interceptRemotes()
        end
    end
end)

-- 🔁 Protección constante
RunService.Stepped:Connect(function()
    if godmode and humanoid and humanoid.Health < humanoid.MaxHealth then
        humanoid.Health = humanoid.MaxHealth
    end
end)

updateLabel()
