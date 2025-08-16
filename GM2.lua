-- Godmode + Cuadro de estado (todo en uno)
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local godmode = false

-- GUI
pcall(function()
    if game:GetService("CoreGui"):FindFirstChild("StatusBoxGui") then
        game:GetService("CoreGui").StatusBoxGui:Destroy()
    end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatusBoxGui"
screenGui.Parent = game:GetService("CoreGui")

local box = Instance.new("Frame")
box.Name = "StatusBox"
box.Size = UDim2.new(0, 60, 0, 60)
box.Position = UDim2.new(0, 20, 0, 20)
box.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
box.BorderSizePixel = 0
box.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = box

local label = Instance.new("TextLabel")
label.Name = "StatusLabel"
label.Size = UDim2.new(1, 0, 0, 22)
label.Position = UDim2.new(0, 0, 1, 0)
label.AnchorPoint = Vector2.new(0, 0)
label.BackgroundTransparency = 1
label.Text = "APAGADO"
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 16
label.Parent = box

local function updateStatusBox()
    if godmode then
        box.BackgroundColor3 = Color3.fromRGB(40, 200, 60)
        label.Text = "ACTIVO"
    else
        box.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        label.Text = "APAGADO"
    end
end

local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Godmode",
            Text = text,
            Duration = 4
        })
    end)
end

local currentHealthConnection
local currentDiedConnection

local function disconnectConnections()
    if currentHealthConnection then
        currentHealthConnection:Disconnect()
        currentHealthConnection = nil
    end
    if currentDiedConnection then
        currentDiedConnection:Disconnect()
        currentDiedConnection = nil
    end
end

local function protectCharacter(char)
    disconnectConnections()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        currentHealthConnection = humanoid.HealthChanged:Connect(function(health)
            if godmode and health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
        currentDiedConnection = humanoid.Died:Connect(function()
            if godmode then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end
end

Players.LocalPlayer.CharacterAdded:Connect(protectCharacter)
if Players.LocalPlayer.Character then
    protectCharacter(Players.LocalPlayer.Character)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.G then
        godmode = not godmode
        updateStatusBox()
        if godmode then
            notify("Godmode ACTIVADO")
        else
            notify("Godmode DESACTIVADO")
        end
    end
end)

updateStatusBox()
notify("Presiona G para activar/desactivar Godmode")
