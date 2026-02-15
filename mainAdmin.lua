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
    Aimbot = {
        Enabled = false,
        FOV = 100,
        Smoothness = 0.1,
        VisibleCheck = true,
        TeamCheck = true,
        TargetPart = "Head",
        Keybind = "E"
    },
    KillAura = {
        Enabled = false,
        Range = 15,
        HitboxSize = 30,
        ShowHitbox = false,
        Keybind = "E",
        inmune = {
            [803842059] = true, -- Hector
            [10407800846] = true, -- Jake
            [8417046395] = true, -- Myla,
            [8235856925] = true, --Sote
            [5809969270] = true, --suki
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
local onder = {
    [1888426792] = true,
    [7593008940] = true,
}
local AdminPermiso = false
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

-- Aimbot Functions
local function GetClosestPlayer()
    local ClosestDistance = Settings.Aimbot.FOV
    local ClosestPlayer = nil
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local targetPart = character:FindFirstChild(Settings.Aimbot.TargetPart)
            
            if humanoid and humanoid.Health > 0 and targetPart then
                if Settings.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if distance < ClosestDistance then
                        if Settings.Aimbot.VisibleCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000)
                            local part = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
                            
                            if part and part:IsDescendantOf(character) then
                                ClosestDistance = distance
                                ClosestPlayer = player
                            end
                        else
                            ClosestDistance = distance
                            ClosestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return ClosestPlayer
end

local function AimbotLoop()
    if not Settings.Aimbot.Enabled then return end
    
    local target = GetClosestPlayer()
    if target and target.Character then
        local targetPart = target.Character:FindFirstChild(Settings.Aimbot.TargetPart)
        if targetPart then
            local targetPos = targetPart.Position
            local cameraPos = Camera.CFrame.Position
            local direction = (targetPos - cameraPos).Unit
            
            local newCFrame = CFrame.new(cameraPos, cameraPos + direction)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Settings.Aimbot.Smoothness)
        end
    end
end

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
                if not onder[p.UserId] and not Settings.KillAura.inmune[p.UserId] then
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

-- Speed Function
local function UpdateSpeed()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Settings.Speed.Enabled and Settings.Speed.Value or 16
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
    
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "HealthLabel"
    healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
    healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Settings.ESP.HealthColor
    healthLabel.TextSize = Settings.ESP.TextSize
    healthLabel.Font = Enum.Font.GothamBold
    healthLabel.TextStrokeTransparency = 0.5
    healthLabel.Parent = billboardGui
    
    ESPObjects[player] = {
        BillboardGui = billboardGui,
        NameLabel = nameLabel,
        HealthLabel = healthLabel
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
                    
                    healthLabel.Visible = Settings.ESP.Health
                    healthLabel.Text = "HP: " .. math.floor(humanoid.Health)
                    healthLabel.TextColor3 = Settings.ESP.HealthColor
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

-- Chams Functions
local function CreateChams(player)
    if ChamsObjects[player] then return end
    
    ChamsObjects[player] = {}
    
    local function UpdateChams()
        if not player.Character then return end
        
        for _, cham in pairs(ChamsObjects[player]) do
            if cham and cham.Parent then
                cham:Destroy()
            end
        end
        ChamsObjects[player] = {}
        
        if not Settings.ESP.Chams then return end
        
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Settings.ESP.ChamsColor
                highlight.OutlineColor = Settings.ESP.ChamsColor
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = part
                highlight.Parent = part
                
                table.insert(ChamsObjects[player], highlight)
            end
        end
    end
    
    player.CharacterAdded:Connect(UpdateChams)
    UpdateChams()
end

local function RemoveChams(player)
    if ChamsObjects[player] then
        for _, cham in pairs(ChamsObjects[player]) do
            if cham and cham.Parent then
                cham:Destroy()
            end
        end
        ChamsObjects[player] = nil
    end
end

local function UpdateAllChams()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.ESP.Chams then
                CreateChams(player)
            else
                RemoveChams(player)
            end
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
        if Settings.ESP.Chams then
            CreateChams(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
    RemoveChams(player)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        CreateESP(player)
        if Settings.ESP.Chams then
            CreateChams(player)
        end
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
        Button.Size = UDim2.new(0, 80, 0, 80)
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
        UDim2.new(0, 10, 0.5, 0),
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
        UDim2.new(1, -90, 0.5, -90),
        Color3.fromRGB(37, 122, 247),
        function()
            Settings.ESP.Name = not Settings.ESP.Name
            Settings.ESP.Health = Settings.ESP.Name
            
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
        onder[7593008940] = state
    end
})

local Dropdown = CombatTab:Dropdown({
    Title = "Dropdown (Multi)",
    Desc = "Dropdown Description",
    Values = {"soto","myla","hector","suki"},
    Value = nil,
    Multi = true,
    AllowNone = true,
    Callback = function(option) 
        -- option is a table: { "Category A", "Category B" }
        print("Categories selected: " .. game:GetService("HttpService"):JSONEncode(option)) 
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

-- Movement Tab
local MovementTab = Window:Tab({
    Title = "Movement",
    Icon = "solar:running-round-bold",
    IconColor = Color3.fromRGB(16, 197, 80),
    IconShape = "Square",
    Border = true,
})

MovementTab:Section({
    Title = "Speed Settings",
    TextSize = 18,
})

MovementTab:Toggle({
    Title = "Enable Speed",
    Value = false,
    Callback = function(state)
        Settings.Speed.Enabled = state
        UpdateSpeed()
    end
})

MovementTab:Slider({
    Title = "Speed Value",
    Step = 1,
    Value = {
        Min = 16,
        Max = 200,
        Default = 16,
    },
    Callback = function(value)
        Settings.Speed.Value = value
        UpdateSpeed()
    end
})

MovementTab:Space()

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

-- Visuals Tab
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
VisualsTab:Space()

VisualsTab:Section({
    Title = "Chams Settings",
    TextSize = 18,
})

VisualsTab:Toggle({
    Title = "Enable Chams",
    Desc = "Highlight players through walls",
    Value = false,
    Callback = function(state)
        Settings.ESP.Chams = state
        UpdateAllChams()
    end
})

VisualsTab:Colorpicker({
    Title = "Chams Color",
    Default = Color3.fromRGB(255, 0, 255),
    Callback = function(color)
        Settings.ESP.ChamsColor = color
        
        for player, chams in pairs(ChamsObjects) do
            for _, cham in pairs(chams) do
                if cham and cham.Parent then
                    cham.FillColor = color
                    cham.OutlineColor = color
                end
            end
        end
    end
})

-- Utility Tab
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

--Creaditos y version
do
    local AboutTab = Window:Tab({
        Title = "About WindUI",
        Desc = "Description Example", 
        Icon = "solar:info-square-bold",
        IconColor = Color3.fromHex("#10C550"),
        IconShape = "Square",
        Border = true,
    })
    
    local AboutSection = AboutTab:Section({
        Title = "About WindUI",
    })
    
    AboutSection:Image({
        Image = "https://repository-images.githubusercontent.com/880118829/22c020eb-d1b1-4b34-ac4d-e33fd88db38d",
        AspectRatio = "16:9",
        Radius = 9,
    })
    
    AboutSection:Space({ Columns = 3 })
    
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

end


-- Main Loop
RunService.Heartbeat:Connect(function()
    AimbotLoop()
end)

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
    UpdateSpeed()
    if Settings.Fly.Enabled then
        StopFly()
        wait(0.1)
        StartFly()
    end
    if Settings.KillAura.Enabled then
        StopKillAura()
        wait(0.1)
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
        Title = "v Beta 3.4",
        Icon = "github",
        Color = Color3.fromHex("#ff9100"),
        Border = true,
    })
end


WindUI:Notify({
    Title = "Script Loaded",
    Content = IsMobile and "Mobile buttons enabled on left/right side!" or "Universal Script Hub loaded successfully!",
    Icon = "solar:check-circle-bold",
    Duration = 5,
})
loadstring(game:HttpGet("https://raw.githubusercontent.com/lunydev360/family-HS-script/refs/heads/main/verefication.lua"))()