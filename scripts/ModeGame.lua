local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Attribute en el Player
if player:GetAttribute("Fighting") == nil then
	player:SetAttribute("Fighting", false)
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FightingToggleGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Botón circular (más grande)
local button = Instance.new("TextButton")
button.Parent = gui
button.AnchorPoint = Vector2.new(1, 0)
button.Position = UDim2.fromScale(0.670, 0.04)
button.Size = UDim2.fromScale(0.12, 0.12) -- ⬅ MÁS GRANDE
button.TextScaled = true
button.Font = Enum.Font.GothamBlack
button.BorderSizePixel = 0
button.AutoButtonColor = false

-- Redondeado total
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = button

-- Borde brillante
local stroke = Instance.new("UIStroke")
stroke.Thickness = 4
stroke.Parent = button

-- Sombra circular
local shadow = Instance.new("Frame")
shadow.Parent = gui
shadow.AnchorPoint = Vector2.new(1, 0)
shadow.Position = UDim2.fromScale(0.965, 0.06)
shadow.Size = UDim2.fromScale(0.12, 0.12)
shadow.BackgroundColor3 = Color3.new(0, 0, 0)
shadow.BackgroundTransparency = 0.7
shadow.ZIndex = 0

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(1, 0)
shadowCorner.Parent = shadow

button.ZIndex = 1

-- Actualizar apariencia
local function updateButton()
	if player:GetAttribute("Fighting") then
		button.Text = "⚔"
		button.BackgroundColor3 = Color3.fromRGB(235, 80, 80)
		stroke.Color = Color3.fromRGB(255, 210, 210)
	else
		button.Text = "🛡"
		button.BackgroundColor3 = Color3.fromRGB(70, 200, 150)
		stroke.Color = Color3.fromRGB(210, 255, 235)
	end
end

updateButton()

-- Entrada universal
button.Activated:Connect(function()
	player:SetAttribute("Fighting", not player:GetAttribute("Fighting"))
	updateButton()
end)

local player = game.Players.LocalPlayer

local guisAocultar = {
    "ScreenGui",
    "GamepassUI"
}

for _, gui in pairs(player.PlayerGui:GetChildren()) do
    if gui:IsA("ScreenGui") and table.find(guisAocultar, gui.Name) then
        gui.Enabled = false
    end
end
