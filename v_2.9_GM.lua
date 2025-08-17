-- Ultra⁺⁺⁺ Debug Core v6 by lopsidep
-- Godmode absoluto con notificación visual y blindaje total

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

-- ✅ Notificación visual
local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Ultra⁺⁺⁺ Debug",
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
        h.AncestryChanged:Connect(function(_, parent)
            if godmode and not parent then
                local clone = h:Clone()
                clone.Parent = character
                humanoid = clone
            end
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

-- 🧪 Interceptar RemoteEvents y Bindables
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

-- 🧱 Protección del Character
character.AncestryChanged:Connect(function(_, parent)
    if godmode and not parent then
        local clone = character:Clone()
        clone.Parent = Workspace
        player.Character = clone
    end
end)

-- 🧩 Protección del HumanoidRootPart
RunService.Heartbeat:Connect(function()
    if godmode then
        if not humanoid or humanoid.Parent ~= character then
            local newHumanoid = Instance.new("Humanoid")
            newHumanoid.Parent = character
            humanoid = newHumanoid
            reinforceHumanoidProtection(humanoid)
        end

        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then
            local newRoot = Instance.new("Part")
            newRoot.Name = "HumanoidRootPart"
            newRoot.Size = Vector3.new(2, 2, 1)
            newRoot.Anchored = false
            newRoot.CanCollide = true
            newRoot.Position = character:GetPivot().Position
            newRoot.Parent = character
        elseif root.Position.Y < -1000 then
            root.Position = Vector3.new(0, 10, 0)
        end
    end
end)

-- 🧨 Protección contra gravedad y entorno
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

-- ♻️ Respawn-safe
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    if godmode then
        reinforceHumanoidProtection(humanoid)
        applyGlobalProtections()
    end
end)

-- ⌨️ Activar con G
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.G then
        godmode = not godmode
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
