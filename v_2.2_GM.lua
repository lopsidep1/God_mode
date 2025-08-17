-- Ultra⁺ Debug Suite by lopsidep
-- Godmode, Invisibility, Flight, UI Tabs, Respawn-safe, Reversible

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- 🔧 State toggles
local godmode, invisible, flying = false, false, false

-- 🛡️ Godmode: Reinforced
humanoid.BreakJointsOnDeath = false
humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
humanoid.Died:Connect(function()
    if godmode then
        humanoid.Health = humanoid.MaxHealth
    end
end)
humanoid.AncestryChanged:Connect(function(_, parent)
    if godmode and not parent then
        local clone = humanoid:Clone()
        clone.Parent = character
    end
end)
humanoid.TakeDamage = function() end

RunService.Stepped:Connect(function()
    if godmode then
        humanoid.Health = humanoid.MaxHealth
    end
end)

-- 🕵️ Invisibility: Hide from NPCs
local function setInvisibility(state)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = state and 1 or 0
        end
    end
    invisible = state
end

-- 🕊️ Flight: Toggle with R
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

-- 🖥️ UI: Tabs, compact, ergonomic
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

-- ⌨️ Keybind for flight
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.R then
        toggleFlight()
    end
end)

-- ♻️ Respawn compatibility
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    humanoid.BreakJointsOnDeath = false
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    humanoid.TakeDamage = function() end
end)
