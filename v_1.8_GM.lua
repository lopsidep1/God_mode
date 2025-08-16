-- 📌 UltraDebugGodmode.lua
-- Godmode + invisibilidad total + UI + toggle + respawn
-- Colócalo en StarterPlayerScripts

local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local godmode = false

-- 🖼 UI de estado
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "UltraDebugHUD"
gui.ResetOnSpawn = false

local label = Instance.new("TextLabel", gui)
label.Size = UDim2.new(0, 160, 0, 30)
label.Position = UDim2.new(0, 20, 0, 20)
label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 18
label.Text = "Godmode OFF"

-- 🔄 Actualizar UI
local function updateUI()
    label.Text = godmode and "Godmode ON" or "Godmode OFF"
end

-- 🧱 Invisibilidad total
local function applyInvisibility()
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
        end
    end
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        humanoid.PlatformStand = true
    end
    player:SetAttribute("InvisibleToNPC", true)
end

-- 🛡 Protección reforzada
local function applyGodmode()
    if not humanoid then return end

    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if godmode and humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)

    humanoid.Died:Connect(function()
        if godmode then
            local clone = character:Clone()
            clone.Parent = workspace
            clone:SetPrimaryPartCFrame(character:GetPivot())
            player.Character = clone
            character:Destroy()
        end
    end)

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(function(hit)
                if godmode then
                    humanoid.Health = humanoid.MaxHealth
                end
            end)
        end
    end
end

-- ⌨️ Toggle con G
local function toggleGodmode(_, state)
    if state == Enum.UserInputState.Begin then
        godmode = not godmode
        updateUI()
        if godmode then
            applyInvisibility()
            applyGodmode()
        else
            humanoid.PlatformStand = false
            player:SetAttribute("InvisibleToNPC", false)
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                    part.CanCollide = true
                    part.CanTouch = true
                    part.CanQuery = true
                end
            end
        end
    end
    return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction("ToggleUltraGodmode", toggleGodmode, false, Enum.KeyCode.G)
updateUI()

-- 🔁 Compatibilidad con respawn
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
    if godmode then
        applyInvisibility()
        applyGodmode()
    end
end)
