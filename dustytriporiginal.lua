--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- [[OPEN SOURCE SCRIPT]] --
local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/linhmcfake/LuaLibrary/refs/heads/main/RedzLibraryV5.lua"))()

local Window = redzlib:MakeWindow({
  Title = "Linhmc Hub: A Dusty Trip",
  SubTitle = "by linhmc_new",
  SaveFolder = "linhmc_hub_a_dusty_trip"
})
local Tab1 = Window:MakeTab({"General", Icon = "rbxassetid://10723407389"})
local Tab2 = Window:MakeTab({"Player - visual", Icon = "rbxassetid://10747373426"})
Window:AddMinimizeButton({
    Button = {
        Image = "rbxassetid://132292718620518",
        BackgroundTransparency = 0,
    },
    Corner = {
        CornerRadius = UDim.new(0, 6), 
    }
})

Window:SelectTab(Tab1)
local Section = Tab1:AddSection({ "KILL AURA" })

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = ReplicatedStorage:WaitForChild("Network")
local GunFramework_RequestDamage = Network:WaitForChild("GunFramework_RequestDamage")
local Pistol = workspace:WaitForChild("Pistol")
local LocalPlayer = Players.LocalPlayer

local autoFire = false

function fireAllNPCs()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= LocalPlayer.Character then
            GunFramework_RequestDamage:FireServer(Pistol, obj)
        end
    end
end

task.spawn(function()
    while true do
        if autoFire then
            fireAllNPCs()
        end
        task.wait(0.2)
    end
end)

Tab1:AddToggle({
    Name = "KILL AURA",
    Default = false,
    Callback = function(state)
        autoFire = state
    end
})
local Section = Tab1:AddSection({ "BRING ITEM" })

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local itemGroups = {
    ["Weapon"] = {"rpg", "Mac10", "PumpShotgun", "AK47", "ammo_crate", "pistol", "katana", "axe", "c4", "dynamite", "ropegun", "muhoboika", "Pike"},
    ["Support"] = {"beam", "skateboard", "ironboard", "brick", "stairs", "gear"},
    ["Food"] = {"bar", "burger", "banana", "apple", "bread", "pizza", "onion", "food", "peper"},
    ["Liquid"] = {"watercan", "gassbottle", "gascan", "oilcan", "radiator", "heater"},
    ["Decor - Misc"] = {"pot1", "pot2", "pot3", "pot4", "pot5", "Crisps", "blade", "comic1", "comic2", "comic3", "bowlball", "comic4", "comic5", "licenseplate1", "licenseplate2", "licenseplate3", "licenseplate4", "licenseplate5", "toilet", "weight"},
    ["Special"] = {"Wheel", "dogtag", "defibrillator", "engine", "wallet1", "wallet2", "wallet3", "wallet4", "wallet5", "specialradio", "goldingon", "bottlecap"}
}

local selectedGroup = "Food"
local isInstantGrab = false
local itemsToGrab = {}
local isGrabbing = false

local function bringModel(model)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local offset = hrp.CFrame.LookVector * 8
    local targetCFrame = hrp.CFrame + offset
    if model:IsA("Model") then
        if model.PrimaryPart then
            model:SetPrimaryPartCFrame(targetCFrame)
        else
            for _, part in ipairs(model:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CFrame = targetCFrame
                end
            end
        end
    elseif model:IsA("BasePart") then
        model.CFrame = targetCFrame
    end
end

local function isRadiatorInVan(obj)
    if obj.Name:lower() ~= "radiator" then return false end
    local parent = obj.Parent
    while parent do
        if parent == Workspace:FindFirstChild("Van") then
            local misc = parent:FindFirstChild("Misc")
            if misc then
                local details = misc:FindFirstChild("details")
                if details then
                    local other = details:FindFirstChild("other")
                    if other and other:FindFirstChild("radiator") == obj then
                        return true
                    end
                end
            end
        end
        parent = parent.Parent
    end
    return false
end

local function recursiveScan(parent)
    if parent == Workspace:FindFirstChild("NPCInstances") then
        return
    end
    
    if parent == Workspace:FindFirstChild("RoadPrefabs") then
        return
    end
    
    local itemNames = itemGroups[selectedGroup]
    if not itemNames then return end
    
    for _, obj in ipairs(parent:GetChildren()) do
        for _, name in ipairs(itemNames) do
            if obj.Name:lower() == name:lower() then
                if obj.Name:lower() == "radiator" and isRadiatorInVan(obj) then
                else
                    table.insert(itemsToGrab, obj)
                end
            end
        end
        if obj:IsA("Folder") or obj:IsA("Model") then
            recursiveScan(obj)
        end
    end
end

local function startGrabbing()
    if isGrabbing then return end
    isGrabbing = true
    itemsToGrab = {}
    recursiveScan(Workspace)
    
    if isInstantGrab then
        for _, item in ipairs(itemsToGrab) do
            if item.Parent then
                bringModel(item)
            end
        end
        isGrabbing = false
    else
        local index = 1
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if index > #itemsToGrab then
                connection:Disconnect()
                isGrabbing = false
                return
            end
            
            local item = itemsToGrab[index]
            if item.Parent then
                bringModel(item)
            end
            index = index + 1
            
            wait(0.8)
        end)
    end
end

Tab1:AddToggle({
    Name = "Instant Grab",
    Default = false,
    Callback = function(value)
        isInstantGrab = value
    end
})

Tab1:AddDropdown({
    Name = "Select Item Group",
    Options = {"Weapon", "Support", "Food", "Liquid", "Decor - Misc", "Special"},
    Default = "Food",
    Callback = function(selected)
        selectedGroup = selected
    end
})

Tab1:AddButton({
    Name = "Bring Items",
    Callback = function()
        startGrabbing()
    end
})

local Section = Tab2:AddSection({ "MOVEMENT" })

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local keepStamina = false

function setStaminaMax()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:SetAttribute("Stamina", 1)
    end
end

task.spawn(function()
    while true do
        if keepStamina then
            setStaminaMax()
        end
        task.wait(0.05)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if keepStamina then
        setStaminaMax()
    end
end)

Tab2:AddToggle({
    Name = "Max Stamina",
    Default = false,
    Callback = function(state)
        keepStamina = state
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local flySpeed = 16
local flyEnabled = false
local flying = false
local bodyVelocity, bodyAngularVelocity, flyConnection, stateChangedConnection

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getRootPart()
    local char = getCharacter()
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

local function waitForControlModule()
    local success, controlModule = pcall(function()
        return require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    end)
    if success then return controlModule else return nil end
end

local function preventSitting()
    local char = getCharacter()
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid and flyEnabled then
        if stateChangedConnection then stateChangedConnection:Disconnect() end
        stateChangedConnection = humanoid.StateChanged:Connect(function(old, new)
            if flyEnabled then
                if new == Enum.HumanoidStateType.Seated then
                    task.spawn(function()
                        task.wait(0.1)
                        if flyEnabled and humanoid.Parent then
                            humanoid:ChangeState(Enum.HumanoidStateType.Running)
                        end
                    end)
                elseif old == Enum.HumanoidStateType.Seated and (new == Enum.HumanoidStateType.Jumping or new == Enum.HumanoidStateType.Running or new == Enum.HumanoidStateType.Freefall) then
                    task.spawn(function()
                        task.wait(0.2)
                        if flyEnabled and humanoid.Parent then
                            humanoid.PlatformStand = true
                            if not flying then
                                startFly()
                            end
                        end
                    end)
                end
            end
        end)
    end
end

function startFly()
    local char = getCharacter()
    local root = getRootPart()
    if not char or not root or not flyEnabled then return end

    flying = true

    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyAngularVelocity then bodyAngularVelocity:Destroy() end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = root

    bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.AngularVelocity = Vector3.zero
    bodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
    bodyAngularVelocity.Parent = root

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
        task.wait(0.1)
        humanoid.PlatformStand = true
        root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(0, 0, -1))
        preventSitting()
    end

    local controlModule = waitForControlModule()

    if flyConnection then flyConnection:Disconnect() end
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyEnabled or not flying or not root or not root.Parent then 
            return 
        end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid and not humanoid.PlatformStand then
            humanoid.PlatformStand = true
        end

        local camera = workspace.CurrentCamera
        local moveVec = Vector3.zero
        if controlModule then moveVec = controlModule:GetMoveVector() end

        local targetVelocity = Vector3.zero
        if moveVec.Magnitude > 0 then
            local cameraCFrame = camera.CFrame
            local direction = cameraCFrame:VectorToWorldSpace(moveVec)
            targetVelocity = direction.Unit * flySpeed
        end

        if bodyVelocity then
            bodyVelocity.Velocity = bodyVelocity.Velocity:Lerp(targetVelocity, 0.25)
        end

        if flyEnabled and flying and bodyAngularVelocity then
            local lookDirection = camera.CFrame.LookVector
            local targetCFrame = CFrame.lookAt(root.Position, root.Position + lookDirection)
            
            root.CFrame = root.CFrame:Lerp(targetCFrame, 0.12)
            bodyAngularVelocity.AngularVelocity = Vector3.zero
        end

        if targetVelocity.Magnitude == 0 then
            if bodyVelocity then
                bodyVelocity.Velocity = Vector3.zero
            end
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

function stopFly()
    flying = false
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyAngularVelocity then bodyAngularVelocity:Destroy() bodyAngularVelocity = nil end
    if stateChangedConnection then stateChangedConnection:Disconnect() stateChangedConnection = nil end
    local char = getCharacter()
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = false end
end

function autoFlyOnRespawn()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 10)
    local humanoid = char:WaitForChild("Humanoid", 10)
    if not root or not humanoid then return end
    task.wait(3)
    if flyEnabled then
        task.wait(1)
        startFly()
    end
end

flyEnabled = false
flying = false

player.CharacterRemoving:Connect(function()
    flying = false
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyAngularVelocity then bodyAngularVelocity:Destroy() bodyAngularVelocity = nil end
    if stateChangedConnection then stateChangedConnection:Disconnect() stateChangedConnection = nil end
end)

player.CharacterAdded:Connect(function()
    if flyEnabled then
        task.spawn(autoFlyOnRespawn)
    end
end)

Tab2:AddToggle({
    Name = "Fly",
    Description = "Toggle Flying Mode (BETA)",
    Default = false,
    Callback = function(Value)
        flyEnabled = Value
        if flyEnabled then
            startFly()
        else
            stopFly()
        end
    end
})

Tab2:AddSlider({
    Name = "Fly Speed",
    Description = "Your Fly Speed",
    Min = 16,
    Max = 300,
    Increase = 1,
    Default = 300,
    Callback = function(Value)
        flySpeed = Value
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local noclipConn
local charConn
local noclipEnabled = false

local function enableNoclip()
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = nil
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

Tab2:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
        if state then
            enableNoclip()
        else
            disableNoclip()
        end
    end
})

local Section = Tab1:AddSection({ "MAP" })

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local autoTravelEnabled = false
local travelConnection = nil
local travelSpeed = 1

local function clamp(x, min, max)
    return math.max(min, math.min(x, max))
end

function getHighestRoadCollision()
    local roadCollisions = workspace.Map:FindFirstChild("RoadCollisions")
    if not roadCollisions then return nil, nil end
    local highestNum = -math.huge
    local highestObj = nil

    for _, obj in ipairs(roadCollisions:GetChildren()) do
        local num = tonumber(obj.Name)
        if num and num > highestNum then
            highestNum = num
            highestObj = obj
        end
    end

    return highestObj, highestNum
end

function teleportToHighestRoadCollision()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local obj, num = getHighestRoadCollision()
    if obj and obj.Position then
        local targetPos = obj.Position + Vector3.new(0, 5, 0)
        hrp.CFrame = CFrame.new(targetPos)
    end
end

local travelTimer = 0

function travelToHighestRoadCollision()
    if travelConnection then travelConnection:Disconnect() end
    travelTimer = 0
    travelConnection = RunService.Heartbeat:Connect(function(dt)
        if not autoTravelEnabled then return end
        travelTimer = travelTimer + dt
        if travelTimer >= travelSpeed then
            teleportToHighestRoadCollision()
            travelTimer = 0
        end
    end)
end

function stopTravel()
    if travelConnection then travelConnection:Disconnect() travelConnection = nil end
end

Tab1:AddTextBox({
    Name = "Travel Delay",
    Default = "1",
    PlaceholderText = "Number/sec",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            travelSpeed = num
        end
    end
})

Tab1:AddToggle({
    Name = "Auto LoadMap",
    Default = false,
    Callback = function(Value)
        autoTravelEnabled = Value
        if Value then
            travelToHighestRoadCollision()
        else
            stopTravel()
        end
    end
})

local Section = Tab2:AddSection({ "VISUAL" })

Tab2:AddButton({
    Name = "Full Bright",
    Callback = function()
    local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

if _G.brightLoop then
    _G.brightLoop:Disconnect()
end

local function brightFunc()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end

_G.brightLoop = RunService.RenderStepped:Connect(brightFunc)
end
})

Tab2:AddButton({
    Name = "No Fog",
    Callback = function()
local Lighting = game:GetService("Lighting")

Lighting.FogEnd = 100000

for _, v in pairs(Lighting:GetDescendants()) do
    if v:IsA("Atmosphere") then
        v:Destroy()
    end
  end
end
})

local Section = Tab2:AddSection({ "TELEPORT" })

Tab2:AddButton({
    Name = "Spawn",
    Callback = function()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local spawnZone = workspace:WaitForChild("SpawnZone")

if spawnZone:IsA("BasePart") then
	hrp.CFrame = spawnZone.CFrame + Vector3.new(0, 2, 0)
end
end
})

Tab2:AddButton({
    Name = "RandomShop",
    Callback = function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        local target = workspace.RoadPrefabs.ScrapRecycler:WaitForChild("RandomShop")

        if target:IsA("Model") then
            local firstPart = nil
            for _,v in pairs(target:GetDescendants()) do
                if v:IsA("BasePart") then
                    firstPart = v
                    break
                end
            end

            if firstPart then
                hrp.CFrame = firstPart.CFrame + Vector3.new(0, 0, 0)
            end
        elseif target:IsA("BasePart") then
            hrp.CFrame = target.CFrame + Vector3.new(0, 0, 0)
        end
    end
})

Tab2:AddButton({
    Name = "Autoshop Repairs",
    Callback = function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        local target = workspace:WaitForChild("RoadPrefabs")
            :WaitForChild("AutoshopRepairs")
            :WaitForChild("AutoshopRepairs")

        if target:IsA("Model") then
            local firstPart = nil
            for _,v in pairs(target:GetDescendants()) do
                if v:IsA("BasePart") then
                    firstPart = v
                    break
                end
            end

            if firstPart then
                hrp.CFrame = firstPart.CFrame + Vector3.new(0, -3, 0)
            end
        elseif target:IsA("BasePart") then
            hrp.CFrame = target.CFrame + Vector3.new(0, -3, 0)
        end
    end
})

Tab2:AddButton({
    Name = "RustyDepot",
    Callback = function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        local target = workspace:WaitForChild("RoadPrefabs"):WaitForChild("RustyDepot")

        local targetCFrame = nil

        if target:IsA("BasePart") then
            targetCFrame = target.CFrame
        elseif target:IsA("Model") then
            if target.PrimaryPart then
                targetCFrame = target.PrimaryPart.CFrame
            else
                for _,v in pairs(target:GetDescendants()) do
                    if v:IsA("BasePart") then
                        targetCFrame = v.CFrame
                        break
                    end
                end
            end
        end

        if targetCFrame then
            hrp.CFrame = targetCFrame + Vector3.new(0, 5, 0)
        end
    end
})
