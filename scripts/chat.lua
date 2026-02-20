--[[ 
 GLOBAL CHAT - SINGLE FILE
 Colocar en ServerScriptService
 Compatible con todos los juegos del mismo UniverseId
]]

-- SERVICIOS
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")
local TextService = game:GetService("TextService")

-- CONFIG
local CHANNEL = "UNIVERSE_GLOBAL_CHAT"
local MAX_LEN = 120
local COOLDOWN = 2

-- REMOTE
local Remote = Instance.new("RemoteEvent")
Remote.Name = "GlobalChatRemote"
Remote.Parent = ReplicatedStorage

-- COOLDOWN TABLE
local lastMessage = {}

-- FILTRO
local function filter(player, text)
	local ok, res = pcall(function()
		return TextService
			:FilterStringAsync(text, player.UserId)
			:GetNonChatStringForBroadcastAsync()
	end)
	return ok and res or "[Mensaje bloqueado]"
end

-- UI CREATION
local function createUI(player)
	local gui = Instance.new("ScreenGui")
	gui.Name = "GlobalChatUI"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local frame = Instance.new("Frame", gui)
	frame.Size = UDim2.fromScale(0.35, 0.35)
	frame.Position = UDim2.fromScale(0.02, 0.6)
	frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
	frame.BackgroundTransparency = 0.1
	frame.BorderSizePixel = 0

	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0,12)

	local list = Instance.new("UIListLayout", frame)
	list.Padding = UDim.new(0,6)

	local padding = Instance.new("UIPadding", frame)
	padding.PaddingAll = UDim.new(0,10)

	local input = Instance.new("TextBox", frame)
	input.Size = UDim2.new(1,0,0,32)
	input.PlaceholderText = "Mensaje global..."
	input.Text = ""
	input.TextColor3 = Color3.new(1,1,1)
	input.BackgroundColor3 = Color3.fromRGB(30,30,30)
	input.ClearTextOnFocus = false

	local ic = Instance.new("UICorner", input)
	ic.CornerRadius = UDim.new(0,8)

	input.FocusLost:Connect(function(enter)
		if enter and input.Text ~= "" then
			Remote:FireServer(input.Text)
			input.Text = ""
		end
	end)

	-- CLIENT LISTENER
	Remote.OnClientEvent:Connect(function(data)
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1,0,0,22)
		label.BackgroundTransparency = 1
		label.TextWrapped = true
		label.TextXAlignment = Left
		label.TextYAlignment = Top
		label.TextColor3 = Color3.new(1,1,1)
		label.Text = "[" .. data.Name .. "]: " .. data.Message
		label.Parent = frame
	end)
end

-- PLAYER JOIN
Players.PlayerAdded:Connect(createUI)

-- SERVER RECEIVE
Remote.OnServerEvent:Connect(function(player, text)
	if typeof(text) ~= "string" then return end
	if #text > MAX_LEN then return end

	local t = os.clock()
	if lastMessage[player] and t - lastMessage[player] < COOLDOWN then
		return
	end
	lastMessage[player] = t

	local msg = filter(player, text)

	local data = {
		Name = player.Name,
		Message = msg
	}

	pcall(function()
		MessagingService:PublishAsync(CHANNEL, data)
	end)
end)

-- GLOBAL RECEIVE
pcall(function()
	MessagingService:SubscribeAsync(CHANNEL, function(packet)
		for _, plr in ipairs(Players:GetPlayers()) do
			Remote:FireClient(plr, packet.Data)
		end
	end)
end)

print("🌍 Global Chat cargado")