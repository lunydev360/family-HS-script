-- UNIVERSAL CHAT - UN SOLO SCRIPT
-- Funciona en TODOS los juegos

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EVENT_NAME = "__UNIVERSAL_CHAT_EVENT__"

------------------------------------------------
-- 🔵 SERVIDOR
------------------------------------------------
if RunService:IsServer() then
	-- Crear RemoteEvent global
	local event = ReplicatedStorage:FindFirstChild(EVENT_NAME)
	if not event then
		event = Instance.new("RemoteEvent")
		event.Name = EVENT_NAME
		event.Parent = ReplicatedStorage
	end

	-- Recibir mensajes
	event.OnServerEvent:Connect(function(player, text)
		if typeof(text) ~= "string" then return end
		if text:gsub("%s+", "") == "" then return end

		event:FireAllClients(player.Name, text)
	end)

	-- Inyectar el MISMO script al cliente
	Players.PlayerAdded:Connect(function(player)
		local clone = script:Clone()
		clone.Name = "UniversalChatClient"
		clone.Parent = player:WaitForChild("PlayerGui")
	end)

	return
end

------------------------------------------------
-- 🟢 CLIENTE
------------------------------------------------

local event = ReplicatedStorage:WaitForChild(EVENT_NAME)
local player = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "UniversalChatGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5, 1)
frame.Position = UDim2.fromScale(0.5, 0.95)
frame.Size = UDim2.fromScale(0.45, 0.35)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0

local messages = Instance.new("TextLabel", frame)
messages.Size = UDim2.fromScale(1, 0.75)
messages.TextWrapped = true
messages.TextYAlignment = Top
messages.TextXAlignment = Left
messages.TextColor3 = Color3.new(1,1,1)
messages.BackgroundTransparency = 1
messages.Text = "💬 Chat universal activo"

local box = Instance.new("TextBox", frame)
box.Size = UDim2.fromScale(0.8, 0.25)
box.Position = UDim2.fromScale(0, 0.75)
box.PlaceholderText = "Escribe aquí..."
box.Text = ""

local send = Instance.new("TextButton", frame)
send.Size = UDim2.fromScale(0.2, 0.25)
send.Position = UDim2.fromScale(0.8, 0.75)
send.Text = "Enviar"

-- Enviar
local function sendMsg()
	if box.Text ~= "" then
		event:FireServer(box.Text)
		box.Text = ""
	end
end

send.MouseButton1Click:Connect(sendMsg)
box.FocusLost:Connect(function(enter)
	if enter then sendMsg() end
end)

-- Recibir
event.OnClientEvent:Connect(function(name, msg)
	messages.Text ..= "\n[" .. name .. "]: " .. msg
end)