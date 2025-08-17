-- Ultra⁺ Debug Suite v2 by lopsidep
-- Godmode, Invisibility, Flight, UI Tabs, Respawn-safe, Reversible

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- 🔧 State toggles
local godmode, invisible, flying = false, false, false

-- 🛡️ Protección reforzada
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
            end
        end)
    end
end

reinforceHumanoidProtection(humanoid)

RunService.Stepped:Connect(function()
    if godmode and humanoid and humanoid.Health < humanoid.MaxHealth then
        humanoid.Health = humanoid.MaxHealth
    end
end)

-- 🕵️ Invisibility
local function setInvisibility(state)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = state and 1 or 0
        end
    end
    invisible = state
end

-- 🕊️ Vuelo libre
local bv, bg = Instance.new("BodyVelocity"), Instance.new("BodyGyro")
bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
bv.Velocity = Vector3.zero

local function toggleFlight()
    flying = not flying
    if flying then
        bv.Parent = character.HumanoidRootPart
        bg.Parent = character.HumanoidRootPart
    else
        bv:Destroy()
        bg:Destroy()
    end
end

-- 🖥️ UI compacta
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "UltraDebugUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local function createButton(text, callback, yPos)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(callback)
end

createButton("Godmode", function()
    godmode = not godmode
end, 0)

createButton("Invisibility", function()
    setInvisibility(not invisible)
end, 35)

createButton("Toggle Flight (R)", function()
    toggleFlight()
end, 70)

-- ⌨️ Keybind
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.R then
        toggleFlight()
    end
end)

-- ♻️ Respawn-safe
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    reinforceHumanoidProtection(humanoid)
end)
