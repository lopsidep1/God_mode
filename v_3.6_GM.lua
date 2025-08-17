--[[
    Godmode v3.6 - GUI Toggle Edition
    Author: lopsidep
    Features:
    - Total protection against damage, destruction, and interference
    - Persistent GUI indicator
    - Toggleable via on-screen button (no keyboard required)
    - Compatible with respawn
]]

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local protect = false

-- GUI Setup
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "GodmodeUI"
gui.ResetOnSpawn = false

local statusLabel = Instance.new("TextLabel", gui)
statusLabel.Size = UDim2.new(0, 200, 0, 50)
statusLabel.Position = UDim2.new(0.5, -100, 0, 20)
statusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 20
statusLabel.Text = "Godmode: OFF"

local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 200, 0, 50)
toggleButton.Position = UDim2.new(0.5, -100, 0, 80)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.Gotham
toggleButton.TextSize = 18
toggleButton.Text = "Toggle Godmode"

-- Protection Logic
local function applyGodmode()
    if not char or not hum then return end
    hum.Name = "ProtectedHumanoid"
    hum.MaxHealth = math.huge
    hum.Health = math.huge
    hum.BreakJointsOnDeath = false
    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
end

local function removeGodmode()
    if not char or not hum then return end
    hum.Name = "Humanoid"
    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
end

local function updateUI()
    statusLabel.Text = "Godmode: " .. (protect and "ON" or "OFF")
    statusLabel.BackgroundColor3 = protect and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end

-- Toggle Handler
toggleButton.MouseButton1Click:Connect(function()
    protect = not protect
    if protect then
        applyGodmode()
    else
        removeGodmode()
    end
    updateUI()
end)

-- Respawn Compatibility
lp.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = newChar:WaitForChild("Humanoid")
    if protect then
        applyGodmode()
    end
end)

updateUI()
