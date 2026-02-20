-- SimpleChat (UN SOLO SCRIPT)
-- Autor: tú 😎

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CHAT_EVENT_NAME = "ChatEvent"

--------------------------------------------------
-- 🔵 SERVIDOR
--------------------------------------------------
if RunService:IsServer() then
	-- Crear RemoteEvent si no existe
	local chatEvent = ReplicatedStorage:FindFirstChild(CHAT_EVENT_NAME)
	if not chatEvent then
		chatEvent = Instance.new("RemoteEvent")
		chatEvent.Name = CHAT_EVENT_NAME
		chatEvent.Parent = ReplicatedStorage
	end

	-- Recibir mensajes y reenviarlos
	chatEvent.OnServerEvent:Connect(function(player, message)
		if typeof(message) ~= "string" or message == "" then return end
		chatEvent:FireAllClients(player.Name, message)
	end)

	-- Clonar este MISMO script al cliente
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Wait()

		local clone = script:Clone()
		clone.Name = "SimpleChatClient"
		clone.Parent = player:WaitForChild("PlayerGui")
	end)

	return
end

--------------------------------------------------
-- 🟢 CLIENTE
--------------------------------------------------

-- Esperar RemoteEvent
local chatEvent = ReplicatedStorage:WaitForChild(CHAT_EVENT_NAME)
local player = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ChatGui"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.4, 0.35)
frame.Position = UDim2.fromScale(0.3, 0.6)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local chatLog = Instance.new("TextLabel", frame)
chatLog.Size = UDim2.fromScale(1, 0.75)
chatLog.TextWrapped = true
chatLog.TextYAlignment = Top
chatLog.TextXAlignment = Left
chatLog.BackgroundTransparency = 1
chatLog.TextColor3 = Color3.new(1,1,1)
chatLog.Text = "🗨 Chat iniciado"

local box = Instance.new("TextBox", frame)
box.Size = UDim2.fromScale(0.8, 0.25)
box.Position = UDim2.fromScale(0, 0.75)
box.PlaceholderText = "Escribe un mensaje..."
box.Text = ""

local send = Instance.new("TextButton", frame)
send.Size = UDim2.fromScale(0.2, 0.25)
send.Position = UDim2.fromScale(0.8, 0.75)
send.Text = "Enviar"

-- Enviar mensaje
local function sendMessage()
	if box.Text ~= "" then
		chatEvent:FireServer(box.Text)
		box.Text = ""
	end
end

send.MouseButton1Click:Connect(sendMessage)
box.FocusLost:Connect(function(enter)
	if enter then sendMessage() end
end)

-- Recibir mensajes
chatEvent.OnClientEvent:Connect(function(name, msg)
	chatLog.Text ..= "\n[" .. name .. "]: " .. msg
end)