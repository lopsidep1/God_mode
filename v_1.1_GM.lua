-- 📌 FlyDebug.lua
-- Vuelo libre + no-collide para debugging
-- Colócalo en StarterPlayerScripts

local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local flying = false
local speed = 50
local direction = Vector3.zero

-- 🖼 UI de estado
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

-- 🧠 Movimiento
local function updateDirection()
    direction = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += Vector3.new(0, 0, -1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction += Vector3.new(0, 0, 1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction += Vector3.new(-1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += Vector3.new(1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction += Vector3.new(0, -1, 0) end
end

-- 🚀 Loop de vuelo
RunService.RenderStepped:Connect(function(dt)
    if flying and humanoidRootPart then
        updateDirection()
        local move = (character:GetPivot().Rotation * direction) * speed * dt
        character:PivotTo(character:GetPivot() + move)
    end
end)

-- 🧱 Desactivar colisiones
local function setNoCollide(state)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

-- ⌨️ Toggle con F
local function toggleFly(_, state)
    if state == Enum.UserInputState.Begin then
        flying = not flying
        label.Text = flying and "Fly ON" or "Fly OFF"
        setNoCollide(flying)
    end
    return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction("ToggleFly", toggleFly, false, Enum.KeyCode.F)
