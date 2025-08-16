-- 📌 UltraDebugSuite.lua
-- Godmode + invisibilidad total + vuelo libre + UI + toggle + suelo
-- Colócalo en StarterPlayerScripts

local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local godmode = false
local flying = false
local velocity = Instance.new("BodyVelocity")
velocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
velocity.Velocity = Vector3.zero
velocity.Name = "FlyVelocity"
velocity.Parent = root

-- 🖼 UI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "UltraDebugHUD"
gui.ResetOnSpawn = false

local label = Instance.new("TextLabel", gui)
label.Size = UDim2.new(0, 200, 0, 30)
label.Position = UDim2.new(0, 20, 0, 20)
label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 18
label.Text = "Modo: Normal"

local function updateUI()
    local mode = ""
    if godmode then mode = "Godmode" end
    if flying then mode = mode ~= "" and mode .. " + Vuelo" or "Vuelo" end
    label.Text = mode ~= "" and ("Modo: " .. mode) or "Modo: Normal"
end

-- 🧱 Invisibilidad total ante NPCs
local function applyInvisibility()
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanTouch = false
            part.CanQuery = false
            -- Mantener colisión con el suelo
            if part.Name == "HumanoidRootPart" or part.Position.Y <= character:GetPivot().Position.Y then
                part.CanCollide = true
            else
                part.CanCollide = false
            end
        end
    end
    humanoid.PlatformStand = true
    player:SetAttribute("InvisibleToNPC", true)
end

-- 🛡 Protección reforzada
local function applyGodmode()
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

-- 🚀 Vuelo libre
local function getDirection()
    local dir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Vector3.new(0, 0, -1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir += Vector3.new(0, 0, 1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir += Vector3.new(-1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Vector3.new(1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir += Vector3.new(0, -1, 0) end
    return dir
end

RunService.RenderStepped:Connect(function()
    if flying then
        local cam = workspace.CurrentCamera
        local dir = getDirection()
        if dir.Magnitude > 0 then
            dir = (cam.CFrame:VectorToWorldSpace(dir)).Unit
        end
        velocity.Velocity = dir * 60
    else
        velocity.Velocity = Vector3.zero
    end
end)

-- ⌨️ Toggle Godmode con G
local function toggleGodmode(_, state)
    if state == Enum.UserInputState.Begin then
        godmode = not godmode
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
        updateUI()
    end
    return Enum.ContextActionResult.Sink
end

-- ⌨️ Toggle vuelo libre con E
local function toggleFly(_, state)
    if state == Enum.UserInputState.Begin then
        flying = not flying
        humanoid.PlatformStand = flying
        updateUI()
    end
    return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction("ToggleUltraGodmode", toggleGodmode, false, Enum.KeyCode.G)
ContextActionService:BindAction("ToggleUltraFly", toggleFly, false, Enum.KeyCode.E)
updateUI()

-- 🔁 Respawn compatible
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
    velocity.Parent = root
    if godmode then
        applyInvisibility()
        applyGodmode()
    end
    updateUI()
end)
