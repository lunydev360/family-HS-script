local GmmUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/MermiXO/GMM-Ui-Lib/refs/heads/main/src.lua?t=" .. tick()))()

local ui = GmmUI.new({ Title = "MY MENU" })

local home = ui:NewMenu("HOME")
local player = ui:NewMenu("PLAYER")

home:Submenu("Player Options", "Options that affect your player.", player)

player:Button("Heal Player", "Restores your health to 100%.", function()
	print("Player Healed!")
end)

player:Toggle("God Mode", "Makes the player invincible.", false, function(on)
	print("God Mode:", on)
end)

ui:PushMenu(home)
