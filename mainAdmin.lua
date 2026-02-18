local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Settings
local Settings = {
    KillAura = {
        Enabled = false,
        Range = 15,
        HitboxSize = 30,
        ShowHitbox = false,
        Keybind = "E",
        inmune = {
        --[ADMINISTRADORES]--
            [1888426792] = true,
            [7593008940] = true,
        --[MIENBROS]--
            [803842059] = true, -- Hector
            [10407800846] = true, -- Jake
            [8417046395] = true, -- Myla
            [8235856925] = true, --Sote
            [5809969270] = true, --suki
            [5084953532] = true, --artories
            [8630263721] = true, --Hector 2
            [4198767342] = true, -- ale
            [8507262086] = true, -- kaiser
            [8363844008] = true, --miu
            [7358542303] = true, --kyu
            [7182786234] = true, --angel
            [9126487539] = true, --goddes pe
        --[BOTS Y TESTER]--
            [10521014710] = true, --BOT Hector
            [10320578945] = true, --test
        }

    },
    AntiRagdoll = {
        Enabled = false
    },
    UI = {
        Keybind = "RightShift"
    },
    Speed = {
        Enabled = false,
        Value = 16
    },
    Fly = {
        Enabled = false,
        Speed = 50
    },
    InfiniteJump = {
        Enabled = false
    },
    ESP = {
        Name = false,
        Health = false,
        Distance = 5000,
        TextSize = 14,
        NameColor = Color3.fromRGB(255, 255, 255),
        HealthColor = Color3.fromRGB(0, 255, 0),
        Chams = false,
        ChamsColor = Color3.fromRGB(255, 0, 255)
    }
}

-- Variables
local ESPObjects = {}
local ChamsObjects = {}
local KillAuraConnection
local originalHitboxSizes = {}
local hitboxVisuals = {}
local FlyConnection, FlyBV, FlyBG
local HitRemote
local AdminPermiso = false
local arrayPlayers = { "lov3lybirdy","nsndkskd18","Sylunh44","Kendraaa1023","pynkskullz","tzwgkee","Isabelloca_sando2023","jairoproaso1", "cyburgultraJake64cat", "tomatocookie13" ,"yamiiDev", "enrique1746708","KingMiata20","YDARKCRAKY"}
local onder = {
    [1888426792] = true,
    [7593008940] = true,
}
local objetiveplayer
local EnabledObjetive = false
-- Try to find Hit remote
pcall(function()
    HitRemote = game:GetService("ReplicatedStorage")
        :WaitForChild("Packages", 5)
        :WaitForChild("Knit")
        :WaitForChild("Services")
        :WaitForChild("CombatService")
        :WaitForChild("RF")
        :WaitForChild("Hit")
end)

-- Kill Aura Functions
    local function StartKillAura()
        if not HitRemote then
            WindUI:Notify({
                Title = "Kill Aura Error",
                Content = "Could not find Hit Remote. This feature may not work on this game.",
                Icon = "solar:danger-bold",
                Duration = 5,
            })
            Settings.KillAura.Enabled = false
            return
        end
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    originalHitboxSizes[hrp] = hrp.Size
                    hrp.Size = Vector3.new(Settings.KillAura.HitboxSize, Settings.KillAura.HitboxSize, Settings.KillAura.HitboxSize)
                end
            end
        end
        
        KillAuraConnection = RunService.Heartbeat:Connect(function()
            if not Settings.KillAura.Enabled then return end
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
            
            local myHRP = LocalPlayer.Character.HumanoidRootPart
            local closest, closestDist = nil, Settings.KillAura.Range
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") then
                    if EnabledObjetive and p.userId == objetiveplayer.UserId and not onder[p.UserId] then
                        local hum = p.Character.Humanoid
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hum.Health > 0 and hrp then
                            local dist = (hrp.Position - myHRP.Position).Magnitude
                            if dist <= closestDist then
                                closestDist = dist
                                closest = p
                            end
                        end
                    end

                    if not Settings.KillAura.inmune[p.UserId] and not EnabledObjetive then
                        local hum = p.Character.Humanoid
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hum.Health > 0 and hrp then
                            local dist = (hrp.Position - myHRP.Position).Magnitude
                            if dist <= closestDist then
                                closestDist = dist
                                closest = p
                            end
                        end
                    end
                end
            end
            
            if closest and closest.Character and closest.Character:FindFirstChild("Humanoid") then
                local args = {
                    closest.Character.Humanoid,
                    vector.create(myHRP.Position.X, myHRP.Position.Y, myHRP.Position.Z)
                }
                pcall(function()
                    HitRemote:InvokeServer(unpack(args))
                end)
            end
        end)
    end

    local function StopKillAura()
        if KillAuraConnection then
            KillAuraConnection:Disconnect()
            KillAuraConnection = nil
        end
        
        for hrp, oldSize in pairs(originalHitboxSizes) do
            if hrp and hrp.Parent then
                hrp.Size = oldSize
            end
        end
        originalHitboxSizes = {}
        
        for _, visual in pairs(hitboxVisuals) do
            if visual and visual.Parent then
                visual:Destroy()
            end
        end
        hitboxVisuals = {}
    end

    local function UpdateHitboxVisuals()
        for _, visual in pairs(hitboxVisuals) do
            if visual and visual.Parent then
                visual:Destroy()
            end
        end
        hitboxVisuals = {}
        
        if not Settings.KillAura.ShowHitbox then return end
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local visual = Instance.new("Part")
                    visual.Name = "HitboxVisual"
                    visual.Size = Vector3.new(Settings.KillAura.HitboxSize, Settings.KillAura.HitboxSize, Settings.KillAura.HitboxSize)
                    visual.CFrame = hrp.CFrame
                    visual.Anchored = true
                    visual.CanCollide = false
                    visual.Material = Enum.Material.ForceField
                    visual.Color = Color3.fromRGB(255, 0, 0)
                    visual.Transparency = 0.7
                    visual.Parent = workspace
                    
                    hitboxVisuals[hrp] = visual
                    
                    RunService.Heartbeat:Connect(function()
                        if visual and visual.Parent and hrp and hrp.Parent then
                            visual.CFrame = hrp.CFrame
                        end
                    end)
                end
            end
        end
    end
-- Fly Functions
local function StartFly()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    FlyBV = Instance.new("BodyVelocity")
    FlyBV.Velocity = Vector3.new(0, 0, 0)
    FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBV.Parent = humanoidRootPart
    
    FlyBG = Instance.new("BodyGyro")
    FlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBG.CFrame = humanoidRootPart.CFrame
    FlyBG.Parent = humanoidRootPart
    
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not Settings.Fly.Enabled then
            if FlyBV then FlyBV:Destroy() end
            if FlyBG then FlyBG:Destroy() end
            if FlyConnection then FlyConnection:Disconnect() end
            return
        end
        
        local moveDirection = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + (Camera.CFrame.LookVector * Settings.Fly.Speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - (Camera.CFrame.LookVector * Settings.Fly.Speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - (Camera.CFrame.RightVector * Settings.Fly.Speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + (Camera.CFrame.RightVector * Settings.Fly.Speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, Settings.Fly.Speed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, Settings.Fly.Speed, 0)
        end
        
        FlyBV.Velocity = moveDirection
        FlyBG.CFrame = Camera.CFrame
    end)
end

local function StopFly()
    if FlyBV then FlyBV:Destroy() end
    if FlyBG then FlyBG:Destroy() end
    if FlyConnection then FlyConnection:Disconnect() end
end

-- Anti-Ragdoll Function
local AntiRagdollConnection
local function StartAntiRagdoll()
    local RagdollEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RagdollState")
    
    AntiRagdollConnection = RunService.Heartbeat:Connect(function()
        if Settings.AntiRagdoll.Enabled then
            local args = {false}
            RagdollEvent:FireServer(unpack(args))
        end
    end)
end

local function StopAntiRagdoll()
    if AntiRagdollConnection then
        AntiRagdollConnection:Disconnect()
        AntiRagdollConnection = nil
    end
end

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump.Enabled then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- ESP Functions
local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ESP"
    billboardGui.AlwaysOnTop = true
    billboardGui.Size = UDim2.new(0, 100, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Settings.ESP.NameColor
    nameLabel.TextSize = Settings.ESP.TextSize
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Parent = billboardGui
    
    ESPObjects[player] = {
        BillboardGui = billboardGui,
        NameLabel = nameLabel,
    }
    
    local function UpdateESP()
        if not player.Character then
            billboardGui.Enabled = false
            return
        end
        
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChild("Humanoid")
        
        if humanoidRootPart and humanoid and humanoid.Health > 0 then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                
                if distance <= Settings.ESP.Distance then
                    billboardGui.Adornee = humanoidRootPart
                    billboardGui.Enabled = true
                    billboardGui.Parent = game.CoreGui
                    
                    nameLabel.Visible = Settings.ESP.Name
                    nameLabel.Text = player.Name
                    nameLabel.TextColor3 = Settings.ESP.NameColor
                else
                    billboardGui.Enabled = false
                end
            end
        else
            billboardGui.Enabled = false
        end
    end
    
    RunService.Heartbeat:Connect(UpdateESP)
end

local function RemoveESP(player)
    if ESPObjects[player] then
        ESPObjects[player].BillboardGui:Destroy()
        ESPObjects[player] = nil
    end
end

local function UpdateAllESP()
    for player, esp in pairs(ESPObjects) do
        if Settings.ESP.Name or Settings.ESP.Health then
            esp.BillboardGui.Parent = game.CoreGui
        else
            esp.BillboardGui.Parent = nil
        end
    end
end


-- Player Events
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(0.5)
        if Settings.ESP.Name or Settings.ESP.Health then
            CreateESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        CreateESP(player)
    end
end

-- quitar ui de roblox
local function ViewScreen(switch)

    local player = game.Players.LocalPlayer
    local gui = player.PlayerGui:FindFirstChild("ScreenGui")

    if gui then
        gui.Enabled = switch
    end

end



-- Mobile Button UI
local MobileUI = nil
if IsMobile then
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MobileButtons"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local function CreateMobileButton(text, position, color, callback)
        local Button = Instance.new("TextButton")
        Button.AnchorPoint = Vector2.new(1,0)
        Button.Size = UDim2.fromScale(0.12,0.12)
        Button.Position = position
        Button.BackgroundColor3 = color
        Button.Text = text
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.GothamBold
        Button.TextSize = 16
        Button.BorderSizePixel = 0
        Button.Parent = ScreenGui
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 12)
        Corner.Parent = Button
        
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Thickness = 2
        Stroke.Transparency = 0.5
        Stroke.Parent = Button
        
        Button.MouseButton1Click:Connect(callback)
        
        return Button
    end
    -- Kill Aura Button
    local KillAuraButton = CreateMobileButton(
        "Kill Aura\nOFF",
        UDim2.fromScale(0.950,0.04),
        Color3.fromRGB(239, 79, 29),
        function()
            Settings.KillAura.Enabled = not Settings.KillAura.Enabled
            if Settings.KillAura.Enabled then
                StartKillAura()
            else
                StopKillAura()
            end
            KillAuraButton.Text = Settings.KillAura.Enabled and "Kill Aura\nON" or "Kill Aura\nOFF"
            KillAuraButton.BackgroundColor3 = Settings.KillAura.Enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(239, 79, 29)
        end
    )
    -- ESP Button
    local ESPButton = CreateMobileButton(
        "ESP\nOFF",
        UDim2.fromScale(0.810,0.04),
        Color3.fromRGB(37, 122, 247),
        function()
            Settings.ESP.Name = not Settings.ESP.Name
            
            if Settings.ESP.Name then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        CreateESP(player)
                    end
                end
            end
            UpdateAllESP()
            
            ESPButton.Text = Settings.ESP.Name and "ESP\nON" or "ESP\nOFF"
            ESPButton.BackgroundColor3 = Settings.ESP.Name and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(37, 122, 247)
        end
    )
    
    MobileUI = ScreenGui
end

-- Create WindUI Window
local Window = WindUI:CreateWindow({
    Title = "Family HS HUB",
    Author = "by yami_DEV",
    Folder = "HsHub",
    Icon = "solar:folder-2-bold-duotone",
    OpenButton = {
        Title = "Open Script Hub",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        Scale = 0.5,
        Color = ColorSequence.new(
            Color3.fromHex("#ff7b00"),
            Color3.fromHex("#ffc0ec")
        )
    },
})

-- Set initial UI toggle key
Window:SetToggleKey(Enum.KeyCode[Settings.UI.Keybind])

-- Combat Tab
do
    local CombatTab = Window:Tab({
        Title = "Combat",
        Icon = "solar:sword-bold",
        IconColor = Color3.fromRGB(239, 79, 29),
        IconShape = "Square",
        Border = true,
    })

    CombatTab:Section({
        Title = "Kill Aura Settings",
        TextSize = 18,
    })

    CombatTab:Toggle({
        Title = "Enable Kill Aura",
        Desc = "Automatically attack nearest player",
        Value = false,
        Callback = function(state)
            Settings.KillAura.Enabled = state
            if state then
                StartKillAura()
            else
                StopKillAura()
            end
        end
    })

    CombatTab:Slider({
        Title = "Attack Range",
        Desc = "Maximum distance to attack players",
        Step = 1,
        Value = {
            Min = 5,
            Max = 50,
            Default = 15,
        },
        Callback = function(value)
            Settings.KillAura.Range = value
        end
    })

    CombatTab:Slider({
        Title = "Hitbox Expansion Size",
        Desc = "Size of expanded hitboxes (client-side only)",
        Step = 1,
        Value = {
            Min = 5,
            Max = 100,
            Default = 30,
        },
        Callback = function(value)
            Settings.KillAura.HitboxSize = value
            
            if Settings.KillAura.Enabled then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and originalHitboxSizes[hrp] then
                            hrp.Size = Vector3.new(value, value, value)
                        end
                    end
                end
            end
            
            UpdateHitboxVisuals()
        end
    })

    CombatTab:Toggle({
        Title = "Show Hitbox Visualization",
        Desc = "Display red transparent boxes showing expanded hitboxes",
        Value = false,
        Callback = function(state)
            Settings.KillAura.ShowHitbox = state
            UpdateHitboxVisuals()
        end
    })

    CombatTab:Toggle({
        Title = "unattack admin",
        Desc = "Automatically attack nearest admin",
        Value = true,
        Locked = false,
        LockedTitle = "solo para admins",
        Callback = function(state)
            Settings.KillAura.inmune[7593008940] = state
            onder[7593008940] = state
        end
    })

    local Dropdown =CombatTab:Dropdown({
        Title = "quitar inmunidad",
        Desc = "elimina la inmunidad del kill aurora aun mienbro",
        Values = arrayPlayers,
        Value = nil,
        Multi = true,
        Locked = false,
        LockedTitle = "solo moderadores",
        AllowNone = true,
        Callback = function(option)
            for _, p in pairs(Players:GetPlayers()) do
                if table.find(option,p.Name) then
                    Settings.KillAura.inmune[p.UserId] = false
                else
                    if table.find(arrayPlayers,p.Name) then
                        Settings.KillAura.inmune[p.UserId] = true
                    end
                end
                
            end
        end
    })

    local Input = CombatTab:Input({
        Title = "objetivo fijo",
        Desc = "escriba el nombre",
        Value = nil,
        Type = "Input", -- or "Textarea"
        Placeholder = "nombra un usuario",
        Callback = function(input)

            local text = input:lower()

            if text == "" then
                EnabledObjetive = false
                return
            end
            for _,p in pairs(Players:GetPlayers()) do
                if p.Name:lower():find(text) then
                    EnabledObjetive = true
                    objetiveplayer = p
                    WindUI:Notify({
                        Title = "selection player",
                        Content = "as seleccionado a: " .. objetiveplayer.Name .. " con exito",
                        Icon = "solar:check-circle-bold",
                        Duration = 5,})
                    if onder[p.UserId] then
                        WindUI:Notify({
                            Title = "selection player",
                            Content = "el jugador que deseastes seleccionar no sera afectado",
                            Icon = "solar:check-circle-bold",
                            Duration = 5,})
                    end
                end
            end
        end
    })


    CombatTab:Space()

    CombatTab:Keybind({
        Title = "Kill Aura Keybind",
        Desc = "Toggle kill aura on/off",
        Value = "E",
        Callback = function(key)
            Settings.KillAura.Keybind = key
        end
    })

    CombatTab:Space()

    CombatTab:Section({
        Title = "Anti-Ragdoll",
        TextSize = 18,
    })

    CombatTab:Toggle({
        Title = "Anti-Ragdoll",
        Desc = "Prevents you from ragdolling when hit",
        Value = false,
        Callback = function(state)
            Settings.AntiRagdoll.Enabled = state
            if state then
                StartAntiRagdoll()
                WindUI:Notify({
                    Title = "Anti-Ragdoll Enabled",
                    Content = "You will no longer ragdoll!",
                    Icon = "solar:shield-check-bold",
                    Duration = 3,
                })
            else
                StopAntiRagdoll()
                WindUI:Notify({
                    Title = "Anti-Ragdoll Disabled",
                    Content = "Ragdoll is back to normal",
                    Icon = "solar:shield-bold",
                    Duration = 3,
                })
            end
        end
    })

    CombatTab:Space()

    CombatTab:Keybind({
        Title = "cambiar de modo",
        Desc = "Toggle modo ataque/no",
        Value = "E",
        Callback = function(key)
            print(key)
        end
    })
end

-- Movement 
do
    local MovementTab = Window:Tab({
        Title = "Movement",
        Icon = "solar:running-round-bold",
        IconColor = Color3.fromRGB(16, 197, 80),
        IconShape = "Square",
        Border = true,
    })

    MovementTab:Section({
        Title = "Fly Settings",
        TextSize = 18,
    })

    MovementTab:Toggle({
        Title = "Enable Fly",
        Desc = "Use WASD + Space/Shift to fly",
        Value = false,
        Callback = function(state)
            Settings.Fly.Enabled = state
            if state then
                StartFly()
            else
                StopFly()
            end
        end
    })

    MovementTab:Slider({
        Title = "Fly Speed",
        Step = 1,
        Value = {
            Min = 10,
            Max = 200,
            Default = 50,
        },
        Callback = function(value)
            Settings.Fly.Speed = value
        end
    })

    MovementTab:Space()

    MovementTab:Section({
        Title = "Jump Settings",
        TextSize = 18,
    })

    MovementTab:Toggle({
        Title = "Infinite Jump",
        Value = false,
        Callback = function(state)
            Settings.InfiniteJump.Enabled = state
        end
    })
end

-- Visuals Tab
do
    local VisualsTab = Window:Tab({
        Title = "Visuals",
        Icon = "solar:eye-bold",
        IconColor = Color3.fromRGB(37, 122, 247),
        IconShape = "Square",
        Border = true,
    })

    VisualsTab:Section({
        Title = "ESP Settings",
        TextSize = 18,
    })

    VisualsTab:Toggle({
        Title = "Name ESP",
        Value = false,
        Callback = function(state)
            Settings.ESP.Name = state
            
            if state then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        CreateESP(player)
                    end
                end
            end
            UpdateAllESP()
        end
    })

    VisualsTab:Toggle({
        Title = "interfaz",
        Desc = "oculta o activa la interfaz",
        Value = true,
        Callback = function(state)
            local player = game.Players.LocalPlayer
            local gui = player.PlayerGui:FindFirstChild("ScreenGui")
            if gui then
                gui.Enabled = state
            end
        end
    })
end

-- Utility 
do
    local UtilityTab = Window:Tab({
        Title = "Utility",
        Icon = "solar:settings-bold",
        IconColor = Color3.fromRGB(131, 136, 158),
        IconShape = "Square",
        Border = true,
    })

    UtilityTab:Section({
        Title = "UI Settings",
        TextSize = 18,
    })

    UtilityTab:Keybind({
        Title = "UI Toggle Keybind",
        Desc = "Press to hide/show the UI",
        Value = "RightShift",
        Callback = function(key)
            Settings.UI.Keybind = key
            Window:SetToggleKey(Enum.KeyCode[key])
            WindUI:Notify({
                Title = "UI Keybind Changed",
                Content = "Press " .. key .. " to toggle UI",
                Icon = "solar:keyboard-bold",
                Duration = 3,
            })
        end
    })

    UtilityTab:Space()

    UtilityTab:Section({
        Title = "Server Functions",
        TextSize = 18,
    })

    UtilityTab:Button({
        Title = "Rejoin Server",
        Desc = "Rejoin the current server",
        Icon = "refresh-cw",
        Justify = "Center",
        Callback = function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    })

    UtilityTab:Space()

    UtilityTab:Button({
        Title = "Server Hop",
        Desc = "Join a random different server",
        Icon = "shuffle",
        Justify = "Center",
        Callback = function()
            local servers = {}
            local req = game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            local body = HttpService:JSONDecode(req)
            
            if body and body.data then
                for _, server in pairs(body.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        table.insert(servers, server.id)
                    end
                end
                
                if #servers > 0 then
                    local randomServer = servers[math.random(1, #servers)]
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, LocalPlayer)
                else
                    WindUI:Notify({
                        Title = "Server Hop Failed",
                        Content = "No available servers found!",
                        Icon = "solar:danger-bold",
                        Duration = 3,
                    })
                end
            end
        end
    })

    UtilityTab:Space()

    UtilityTab:Button({
        Title = "Server Hop (Lowest Players)",
        Desc = "Join the server with the least players",
        Icon = "users",
        Justify = "Center",
        Callback = function()
            local servers = {}
            local req = game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            local body = HttpService:JSONDecode(req)
            
            if body and body.data then
                for _, server in pairs(body.data) do
                    if server.id ~= game.JobId then
                        table.insert(servers, server)
                    end
                end
                
                table.sort(servers, function(a, b)
                    return a.playing < b.playing
                end)
                
                if #servers > 0 then
                    local lowestServer = servers[1].id
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, lowestServer, LocalPlayer)
                else
                    WindUI:Notify({
                        Title = "Server Hop Failed",
                        Content = "No available servers found!",
                        Icon = "solar:danger-bold",
                        Duration = 3,
                    })
                end
            end
        end
    })

    UtilityTab:Space()

    UtilityTab:Section({
        Title = "Character Functions",
        TextSize = 18,
    })

    UtilityTab:Button({
        Title = "Reset Character",
        Desc = "Respawn your character",
        Icon = "rotate-ccw",
        Color = Color3.fromRGB(239, 79, 29),
        Justify = "Center",
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = 0
            end
        end
    })

    UtilityTab:Space()

    UtilityTab:Section({
        Title = "Teleport to Player",
        TextSize = 18,
    })

    local function GetPlayersList()
        local playersList = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(playersList, player.Name)
            end
        end
        return playersList
    end

    local TeleportDropdown = UtilityTab:Dropdown({
        Title = "Select Player",
        Desc = "Choose a player to teleport to",
        Values = GetPlayersList(),
        Value = nil,
        AllowNone = true,
        Callback = function(selectedName) end
    })

    UtilityTab:Space()

    UtilityTab:Button({
        Title = "Teleport to Selected Player",
        Desc = "Instantly teleport to the selected player",
        Icon = "zap",
        Color = Color3.fromRGB(37, 122, 247),
        Justify = "Center",
        Callback = function()
            local selectedPlayer = nil
            
            for _, player in pairs(Players:GetPlayers()) do
                if player.Name == TeleportDropdown.Value then
                    selectedPlayer = player
                    break
                end
            end
            
            if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    
                    WindUI:Notify({
                        Title = "Teleported",
                        Content = "Teleported to " .. selectedPlayer.Name,
                        Icon = "solar:bolt-bold",
                        Duration = 3,
                    })
                else
                    WindUI:Notify({
                        Title = "Teleport Failed",
                        Content = "Your character is not loaded!",
                        Icon = "solar:danger-bold",
                        Duration = 3,
                    })
                end
            else
                WindUI:Notify({
                    Title = "Teleport Failed",
                    Content = "Player not found or character not loaded!",
                    Icon = "solar:danger-bold",
                    Duration = 3,
                })
            end
        end
    })

    UtilityTab:Space()

    UtilityTab:Button({
        Title = "Refresh Player List",
        Desc = "Update the player dropdown list",
        Icon = "refresh-cw",
        Justify = "Center",
        Callback = function()
            TeleportDropdown:Refresh(GetPlayersList())
            WindUI:Notify({
                Title = "Player List Refreshed",
                Content = "Updated player dropdown",
                Icon = "solar:check-circle-bold",
                Duration = 2,
            })
        end
    })
end

-- Scripts
do
    local ColorHector = Color3.fromHex("#ff7300")
    local ColorYami = Color3.fromHex("#d400ff")
    local ColorSuki = Color3.fromHex("#fd9d4f")

    local ScriptsTab = Window:Tab({
        Title = "Scripts",
        Icon = "solar:cursor-square-bold",
        IconColor = Color3.fromHex("#7700ff"),
        IconShape = "Square",
        Border = true,})

    ScriptsTab:Button({
        Title = "7yd7-Emote-Animation-Script",
        Desc = "Un script de emotes para todos los juegos compatibles con r15",
        Color = ColorYami,
        Icon = "",
        Callback = function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-7yd7-Emote-Animation-Script-UGC-LAG-Fixed-Delta-Console-bug-72656"))()
        end
    })

    ScriptsTab:Button({
        Title = "AK Admin",
        Desc = "un script global similar a infity yield",
        Color = ColorYami,
        Icon = "",
        Callback = function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-ANTI-VC-BAN-75240"))()
        end
    })

    ScriptsTab:Button({
        Title = "Animation Therean",
        Desc = "un paquete de animaciones tipo therean",
        Color = ColorYami,
        Icon = "",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/lunydev360/family-HS-script/refs/heads/main/scripts/AnimationPet.lua"))()
        end
    })

    ScriptsTab:Button({
        Title = "en proseso",
        Desc = "",
        Locked = true,
        LockedTitle = "proximente",
        Color = Color3.fromHex("#585858"),
        Icon = "",
        Callback = function()
            -- loadstring(game:HttpGet(""))()
        end
    })

end


--Creaditos y version
do
    local AboutTab = Window:Tab({
        Title = "About hs hub",
        Desc = "Description Example", 
        Icon = "solar:info-square-bold",
        IconColor = Color3.fromHex("#10C550"),
        IconShape = "Square",
        Border = true,
    })
    
    local AboutSection = AboutTab:Section({
        Title = "acerca",
    })
    AboutSection:Space()
    
    AboutSection:Section({
        Title = "Creditos",
        TextSize = 24,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    AboutSection:Space()
    
    AboutSection:Section({
        Title = "Hector. (Fundador)\nyami. (programadora)\nFamily HS. (dueños)",
        TextSize = 18,
        TextTransparency = .35,
        FontWeight = Enum.FontWeight.Medium,
    })
    
    AboutTab:Space({ Columns = 4 }) 

    local ActualizSeccion = AboutTab:Section({
        Title = "actualizacion",
    })

    ActualizSeccion:Space()

    ActualizSeccion:Section({
        Title = "- cambios en los iconos.\n- se removio la tecla de cambiar modo ataque.\n- killaura aumento de velocidad por defecto.\n- se añadio un nuevo script como parametro cambiar modo echo para movil.\n- se elimino en esp Chamsr. (eso fue eliminado ya que no funcionaba o ya no era nesesario)",
        TextSize = 18,
        TextTransparency = .35,
        FontWeight = Enum.FontWeight.Medium,})

    local InviteCode = "fczDncduyR"
    local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

    local Response = WindUI.cloneref(game:GetService("HttpService")):JSONDecode(WindUI.Creator.Request and WindUI.Creator.Request({
        Url = DiscordAPI,
        Method = "GET",
        Headers = {
            ["User-Agent"] = "WindUI/Example",
            ["Accept"] = "application/json"
        }
    }).Body or "{}")
    
    local DiscordTab = AboutTab:Section({
        Title = "discord",
    })
    
    if Response and Response.guild then
        DiscordTab:Section({
            Title = "Join our Discord server!",
            TextSize = 20,
        })
        local DiscordServerParagraph = DiscordTab:Paragraph({
            Title = tostring(Response.guild.name),
            Desc = tostring(Response.guild.description),
            Image = "https://cdn.discordapp.com/icons/" .. Response.guild.id .. "/" .. Response.guild.icon .. ".png?size=1024",
            Thumbnail = "https://cdn.discordapp.com/banners/1300692552005189632/35981388401406a4b7dffd6f447a64c4.png?size=512",
            ImageSize = 48,
            Buttons = {
                {
                    Title = "Copy link",
                    Icon = "link",
                    Callback = function()
                        setclipboard("https://discord.gg/" .. InviteCode)
                    end
                }
            }
        })
    elseif RunService:IsStudio() or not writefile then
        DiscordTab:Paragraph({
            Title = "Discord API is not available in Studio mode.",
            TextSize = 20,
            Justify = "Center",
            Image = "solar:info-circle-bold",
            Color = "Red",
            Buttons = {
                {
                    Title = "Get/Copy Invite Link",
                    Icon = "link",
                    Callback = function()
                        if setclipboard then 
                            setclipboard("https://discord.gg/" .. InviteCode)
                        else
                            WindUI:Notify({
                                Title = "Discord Invite Link",
                                Content = "https://discord.gg/" .. InviteCode,
                            })
                        end
                    end
                }
            }
        })
    else
        DiscordTab:Paragraph({
            Title = "Failed to fetch Discord server info.",
            TextSize = 20,
            Justify = "Center",
            Image = "solar:info-circle-bold",
            Color = "Red",
        })
    end

    AboutTab:Select()
end


-- Keybind Handler (PC Only)
if not IsMobile then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        -- Kill Aura Keybind
        if input.KeyCode.Name == Settings.KillAura.Keybind then
            Settings.KillAura.Enabled = not Settings.KillAura.Enabled
            if Settings.KillAura.Enabled then
                StartKillAura()
            else
                StopKillAura()
            end
            WindUI:Notify({
                Title = "Kill Aura " .. (Settings.KillAura.Enabled and "Enabled" or "Disabled"),
                Content = "Press " .. Settings.KillAura.Keybind .. " to toggle",
                Icon = "solar:sword-bold",
                Duration = 2,
            })
        end
    end)
end

-- Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    if Settings.Fly.Enabled then
        StopFly()
        wait(0.1)
        StartFly()
    end
    if Settings.KillAura.Enabled then
        StopKillAura()
        wait(0.001)
        StartKillAura()
    end
    if Settings.AntiRagdoll.Enabled then
        StartAntiRagdoll()
    end
end)

-- Handle new players for kill aura
Players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Connect(function(character)
        if Settings.KillAura.Enabled then
            wait(0.5)
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                originalHitboxSizes[hrp] = hrp.Size
                hrp.Size = Vector3.new(Settings.KillAura.HitboxSize, Settings.KillAura.HitboxSize, Settings.KillAura.HitboxSize)
                UpdateHitboxVisuals()
            end
        end
    end)
end)

do
    Window:Tag({
        Title = "V 2.6",
        Icon = "lucide:braces",
        Color = Color3.fromHex("#696969"),
        Border = true,
    })

    Window:Tag({
        Title = "Admin",
        Icon = "lucide:panda",
        Color = Color3.fromHex("#cc00ff"),
        Border = false,
    })
end


local Dialog = Window:Dialog({
    Icon = "lucide:shield-alert",
    Title = "acepta terminos y condiciones",
    Content = "al momento de utilizar nuestro script debes entender que este script esta echo por mi(dep0700) y no permito que un extraño o desconosido tenga acceso a este script.\npor lo tanto no comparta el script con nadien o seras baneado .\nsi quieres compartir el script con alguien debes informarme primero, ya sea en el server / MD /Roblox y es nesesario hablar con el invitado \nNota: Si no respondo a tiempo la solicitud de compartir favor de esperar y no dar el script asta yo dar el acceso.",
    Buttons = {
        {
            Title = "acepto",
            Callback = function()
                print("Confirmed!")
            end,
        }
    },
})

WindUI:Notify({
    Title = "Bienbenido",
    Content = "listo para el combate HS",
    Icon = "geist:box",
    Duration = 5,
})
loadstring(game:HttpGet("https://raw.githubusercontent.com/lunydev360/family-HS-script/refs/heads/main/verification/admin.lua"))()