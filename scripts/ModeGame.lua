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
local Button = Instance.new("TextButton")
Button.AnchorPoint = Vector2.new(1,0)
Button.Size = UDim2.fromScale(0.12,0.12)
Button.Position = UDim2.fromScale(0.670,0.04)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 16
Button.BorderSizePixel = 0
Button.Parent = gui
        
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Button
        
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.Thickness = 2
Stroke.Transparency = 0.5
Stroke.Parent = Button

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
