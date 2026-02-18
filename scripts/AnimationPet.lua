--[[
    WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- ===============================================
-- 🛠️ Animation Changer Stable Version 🛠️BY SUSSYYYY
-- ===============================================
-- 1. Enable Mode Custom:
-- 2. Working anims : Ninja, Robot, Default, Levitate, Mage, Stylish, Hero, Toy, Astronaut, Bubbly, Cartoony, Elder, Ghost, Knight, Vampire, Werewolf, Zombie, Bold, Adidas, Catwalk, Walmart, Wicked, NFL, Pirate, Adidas2, Oldschool
getgenv().HybridSettings = {
    run = "Robot",
    walk = "Catwalk",
    jump = "Ninja",
    idle1 = "Stylish",
    idle2 = "Stylish",
    fall = "Ghost",
    climb = "Default",
    swim = "Pirate",
    swimidle = "Pirate"
}
-- 3. (OPTIONAL) if you want to use Single Bundle instead just set that first topic to "false"
getgenv().ChosenBundleName = "Animals" 
getgenv().EnableHybridCustom = false
print("Custom Settings defined in getgenv().")
loadstring(game:HttpGet("https://raw.githubusercontent.com/Mautiku/Animation/refs/heads/main/Animation%20Changer%20v3%20Stable"))()