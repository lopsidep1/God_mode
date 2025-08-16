-- 📌 UltraFlyDebug.lua
-- Vuelo libre + colisión anulada total para testers
-- Colócalo en StarterPlayerScripts

local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- 🔐 Activación por perfil
local allowedUsers = {
    ["lopsidep"] = true
}
if not allowedUsers[player.Name] then return end

-- 🛡 Crear grupo de colisión ignorado
local groupName = "FlyGhost"
local existingGroups = PhysicsService:GetCollisionGroups()
local groupExists = false
for _, g in ipairs(existingGroups) do
    if g.name == groupName then
        groupExists = true
        break
    end
end
if not groupExists then
    PhysicsService:CreateCollisionGroup(groupName)
end
PhysicsService:CollisionGroupSetCollidable(groupName, groupName, false)

-- 🚀 Setup de vuelo
local flying = false
local velocity = Instance.new("BodyVelocity")
velocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
velocity.Velocity = Vector3.zero
velocity.Name = "FlyVelocity"
velocity.Parent = root

-- 🖼 UI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FlyStatus"
gui.ResetOnSpawn = false

local label = Instance.new("TextLabel", gui)
label.Size = UDim2.new(0, 140, 0, 30)
label.Position = UDim2.new(0, 20, 0, 70)
label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 18
label.Text = "Fly OFF"

-- 🔁 Aplicar no-collide y grupo
local function applyGhostMode()
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            PhysicsService:SetPartCollisionGroup(part, groupName)
        end
    end
end

-- 🧠 Dirección de movimiento
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

-- 🚀 Loop de vuelo
RunService.RenderStepped:Connect(function()
    if flying then
        applyGhostMode()
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

-- ⌨️ Toggle con G
local function toggleFly(_, state)
    if state == Enum.UserInputState.Begin then
        flying = not flying
        label.Text = flying and "Fly ON" or "Fly OFF"
        humanoid.PlatformStand = flying
        applyGhostMode()
    end
    return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction("ToggleFly", toggleFly, false, Enum.KeyCode.G)

-- 🔁 Reaplicar al respawn
player.CharacterAdded:Connect(function(char)
    character = char
    root = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    velocity.Parent = root
end)
