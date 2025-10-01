local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Consistt/Ui/main/UnLeaked"))()

library.title = "Street Wars 2"

local RunService = game:GetService("RunService")
local Wm = library:Watermark("Street Wars 2")
local FpsWm = Wm:AddWatermark("FPS: " .. library.fps)

coroutine.wrap(function()
    while task.wait(0.9) do
        FpsWm:Text("FPS: " .. library.fps)
    end
end)()

local Notif = library:InitNotifications()
Notif:Notify("[Street Wars 2] Loading Script Beta!", 5, "information")
library:Introduction()
wait(1)

local Init = library:Init()
local tab = Init:NewTab("Extra")
local sectionOptions = tab:NewSection("Extra Features")

local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local isJumpBypassActive = false
local jumpBypassTask
local isHungerBypassActive = false
local foodConnection
local waterConnection
local isStreamerModeActive = false
local originalUsername = localPlayer.Name
local originalDisplayName = localPlayer.DisplayName

local function bypassAntiCheat(state)
    if state then
        local getInfo = getinfo or debug.getinfo
        local hooks = {}
        local detectedFunc, killFunc

        setthreadidentity(2)

        for _, obj in getgc(true) do
            if typeof(obj) == "table" then
                local detected = rawget(obj, "Detected")
                local kill = rawget(obj, "Kill")

                if typeof(detected) == "function" and not detectedFunc then
                    detectedFunc = detected
                    hookfunction(detected, function(action, info)
                        return action == "_" and true
                    end)
                    table.insert(hooks, detected)
                end

                if rawget(obj, "Variables") and rawget(obj, "Process") and typeof(kill) == "function" and not killFunc then
                    killFunc = kill
                    hookfunction(kill, function() end)
                    table.insert(hooks, kill)
                end
            end
        end

        hookfunction(getrenv().debug.info, newcclosure(function(...)
            local args, func = ...
            if detectedFunc and args == detectedFunc then
                return coroutine.yield(coroutine.running())
            end
            return hookfunction(getrenv().debug.info, ...)(...)
        end))

        setthreadidentity(7)
        Notif:Notify("AntiCheat Bypassed", 4, "success")
    else
        Notif:Notify("AntiCheat Bypass Disabled", 4, "success")
    end
end

local function toggleJumpCooldown(state)
    if state then
        local playerGui = localPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            local jumpCooldownScript = playerGui:FindFirstChild("JumpCooldown")
            if jumpCooldownScript and jumpCooldownScript:IsA("LocalScript") then
                jumpCooldownScript.Disabled = true
            end
        end
        isJumpBypassActive = true
        jumpBypassTask = task.spawn(function()
            while isJumpBypassActive do
                pcall(function()
                    if humanoid and not humanoid.Jump then
                        humanoid.Jump = true
                    end
                end)
                task.wait(0.01)
            end
        end)
        Notif:Notify("Jump Cooldown Enabled", 4, "success")
    else
        isJumpBypassActive = false
        if jumpBypassTask then
            task.cancel(jumpBypassTask)
            jumpBypassTask = nil
        end
        local playerGui = localPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            local jumpCooldownScript = playerGui:FindFirstChild("JumpCooldown")
            if jumpCooldownScript and jumpCooldownScript:IsA("LocalScript") then
                jumpCooldownScript.Disabled = false
            end
        end
        Notif:Notify("Jump Cooldown Disabled", 4, "success")
    end
end

local function toggleHungerBypass(state)
    if state then
        repeat
            task.wait()
        until localPlayer:GetAttribute("Food") and localPlayer:GetAttribute("Water")

        localPlayer:SetAttribute("Food", 100)
        localPlayer:SetAttribute("Water", 100)

        foodConnection = localPlayer:GetAttributeChangedSignal("Food"):Connect(function()
            if localPlayer:GetAttribute("Food") < 100 then
                localPlayer:SetAttribute("Food", 100)
            end
        end)

        waterConnection = localPlayer:GetAttributeChangedSignal("Water"):Connect(function()
            if localPlayer:GetAttribute("Water") < 100 then
                localPlayer:SetAttribute("Water", 100)
            end
        end)

        isHungerBypassActive = true
        Notif:Notify("Hunger Bypass Enabled", 4, "success")
    else
        if foodConnection then
            foodConnection:Disconnect()
            foodConnection = nil
        end
        if waterConnection then
            waterConnection:Disconnect()
            waterConnection = nil
        end
        isHungerBypassActive = false
        Notif:Notify("Hunger Bypass Disabled", 4, "success")
    end
end

local function toggleStreamerMode(state)
    local statsGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Stats")
    local function modifyMainFrame(main, isActive)
        local firstLastName = main:FindFirstChild("FirstLastName")
        if firstLastName and firstLastName:IsA("TextLabel") then
            firstLastName.Text = isActive and "Street Wars 2" or originalDisplayName
        end

        local username = main:FindFirstChild("Username")
        if username and username:IsA("TextLabel") then
            username.Text = isActive and "Street Wars 2" or originalUsername
        end

        local playerIcon = main:FindFirstChild("PlayerIcon")
        if isActive and playerIcon then
            playerIcon:Destroy()
        elseif not isActive and not playerIcon then
            local newIcon = Instance.new("ImageLabel")
            newIcon.Name = "PlayerIcon"
            newIcon.Parent = main
            newIcon.Image = players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end
    end

    for _, child in pairs(statsGui:GetChildren()) do
        if child.Name == "Main" and child:IsA("Frame") then
            modifyMainFrame(child, state)
        end
    end

    isStreamerModeActive = state
    Notif:Notify(state and "Streamer Mode Enabled" or "Streamer Mode Disabled", 4, "success")
end

tab:NewToggle("AntiCheat Bypass", false, bypassAntiCheat)
tab:NewToggle("Jump Cooldown", false, toggleJumpCooldown)
tab:NewToggle("Hunger Bypass", false, toggleHungerBypass)
tab:NewToggle("Streamer Mode", false, toggleStreamerMode)

local Tab2 = Init:NewTab("Self")
local Section1 = Tab2:NewSection("Self Features")

local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local isNoclipEnabled = false
local spinEnabled = false
local spinInstance
local spinSpeed = 1
local currentSliderValue = 16

local function setSpeed(value)
    if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        localPlayer.Character.Humanoid.WalkSpeed = value
        currentSliderValue = value
    end
end

local function setNoclip(enabled)
    if localPlayer.Character then
        for _, part in pairs(localPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not enabled
            end
        end
    else
        Notif:Notify("Noclip: Character Not Found", 4, "error")
    end
end

local function updateSpin()
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        Notif:Notify("Spin: Character Not Found", 4, "error")
        return
    end
    if spinInstance then spinInstance:Destroy() spinInstance = nil end
    if spinEnabled then
        spinInstance = Instance.new("BodyAngularVelocity")
        spinInstance.MaxTorque = Vector3.new(0, math.huge, 0)
        spinInstance.AngularVelocity = Vector3.new(0, math.rad(spinSpeed), 0)
        spinInstance.Parent = character.HumanoidRootPart
    end
end

local function toggleSpin(value)
    spinEnabled = value
    updateSpin()
    Notif:Notify("Spin " .. (value and "Enabled" or "Disabled"), 4, "success")
end

local function toggleNoclip(value)
    isNoclipEnabled = value
    setNoclip(value)
    Notif:Notify("Noclip " .. (value and "Enabled" or "Disabled"), 4, "success")
end

if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
    localPlayer.Character.Humanoid.WalkSpeed = 16
    currentSliderValue = 16
end

localPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.WalkSpeed = 16
        currentSliderValue = 16
    end
    setNoclip(isNoclipEnabled)
    updateSpin()
end)

if localPlayer.Character then
    setNoclip(isNoclipEnabled)
end

coroutine.wrap(function()
    while true do
        task.wait(0.1)
        if isNoclipEnabled then
            setNoclip(true)
        end
    end
end)()

Tab2:NewSlider("Speed", "", true, "/", {min = 16, max = 65, default = 16}, setSpeed)
Tab2:NewToggle("Noclip", false, toggleNoclip)
Tab2:NewToggle("Spin", false, toggleSpin)
Tab2:NewSlider("Spin Speed", "", false, "", {min = 1, max = 5000, default = 1}, function(value)
    spinSpeed = value
    updateSpin()
end)

local Tab3 = Init:NewTab("Visual")
local Section1 = Tab3:NewSection("Visual Features")

local tabTeleport = Init:NewTab("Teleport")
local sectionTeleport = tabTeleport:NewSection("Teleport Options")

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local savedPosition = nil
local locations = {"None", "Apartment1", "Apartment2", "Bank", "GunShop", "Jewelry", "Laundry", "PoliceMet", "Station", "TerraceClub", "Club"}
local isFirstCall = true

local function teleportToApartment(apartmentName)
    local character = localPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local targetPart = Workspace:FindFirstChild("Teleports") and 
                          Workspace.Teleports:FindFirstChild(apartmentName) and 
                          Workspace.Teleports[apartmentName]:FindFirstChild("TeleportPart2")
        if targetPart then
            character.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
            Notif:Notify("Teleported to " .. apartmentName, 3, "success")
        else
            Notif:Notify("Location " .. apartmentName .. " not found", 3, "error")
        end
    else
        Notif:Notify("Character not found", 3, "error")
    end
end

tabTeleport:NewSelector("Select Location", "None", locations, function(selectedApartment)
    if isFirstCall then
        isFirstCall = false
        return
    end
    if selectedApartment ~= "None" then
        teleportToApartment(selectedApartment)
    end
end)

tabTeleport:NewButton("Random Teleport", function()
    local randomLocation = locations[math.random(2, #locations)]
    teleportToApartment(randomLocation)
end)

tabTeleport:NewButton("Save Position", function()
    local character = localPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        savedPosition = character.HumanoidRootPart.CFrame
        Notif:Notify("Position saved", 3, "success")
    else
        Notif:Notify("Character not found", 3, "error")
    end
end)

tabTeleport:NewButton("Teleport to Saved Position", function()
    local character = localPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        if savedPosition then
            character.HumanoidRootPart.CFrame = savedPosition
            Notif:Notify("Teleported to saved position", 3, "success")
        else
            Notif:Notify("No saved position found", 3, "error")
        end
    else
        Notif:Notify("Character not found", 3, "error")
    end
end)

local Tab4 = Init:NewTab("AutoFarm")
local sectionAutoFarm = Tab4:NewSection("AutoFarm Features")

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local isAutoCleanActive = false
local autoCleanConnection
local equipCheckConnection
local isAutoCartonActive = false
local autoCartonConnection
local isAutoCollectActive = false
local autoCollectConnection
local originalPosition
local START_POSITION = Vector3.new(-125.18, 4.22, 303.18)
local END_POSITION = Vector3.new(-109.59, 3.97, 146.16)
local MAX_DISTANCE = 20
local TOOL_NAME = "Box"

local function getCleanParts()
    local cleanParts = {}
    local cleanFolder = Workspace:FindFirstChild("CleanPart")
    if cleanFolder then
        for _, part in ipairs(cleanFolder:GetChildren()) do
            if part:IsA("BasePart") and part.Name:match("^CleanPart") then
                table.insert(cleanParts, part)
            end
        end
    end
    return cleanParts
end

local function setPromptsToInstant()
    local cleanFolder = Workspace:FindFirstChild("CleanPart")
    if cleanFolder then
        for _, part in ipairs(cleanFolder:GetChildren()) do
            if part:IsA("BasePart") and part.Name:match("^CleanPart") then
                for _, descendant in ipairs(part:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") then
                        descendant.HoldDuration = 0
                    end
                end
            end
        end
    end
end

local function interactWithPart(part)
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
        task.wait(0.1)
        for _, descendant in ipairs(part:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                fireproximityprompt(descendant)
                task.wait(0.1)
            end
        end
    end
end

local function equipMop()
    local mop = localPlayer.Backpack:FindFirstChild("Mop")
    if mop and humanoid then
        humanoid:EquipTool(mop)
    end
end

local function teleportToPosition(position)
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
    end
end

local function getNearestDetector()
    if character and character:FindFirstChild("HumanoidRootPart") then
        local rootPart = character.HumanoidRootPart
        local closestDetector = nil
        local shortestDistance = MAX_DISTANCE

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ClickDetector") and obj.Parent and obj.Parent.Name == "BOX1" then
                local part = obj.Parent
                if part:IsA("BasePart") then
                    local distance = (part.Position - rootPart.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestDetector = obj
                    end
                end
            end
        end

        return closestDetector
    end
    return nil
end

local function equipTool(toolName)
    local tool = localPlayer.Backpack:FindFirstChild(toolName)
    if tool and humanoid then
        humanoid:EquipTool(tool)
        return true
    else
        local newTool = localPlayer.Backpack:WaitForChild(toolName, 5)
        if newTool and humanoid then
            humanoid:EquipTool(newTool)
            return true
        end
        return false
    end
end

local function autoSequence()
    if not isAutoCartonActive then return end
    teleportToPosition(START_POSITION)
    task.wait(1)
    local detector = getNearestDetector()
    if detector then
        fireclickdetector(detector)
        task.wait(0.5)
        local equipped = equipTool(TOOL_NAME)
        if equipped then
            task.wait(0.5)
            teleportToPosition(END_POSITION)
        end
    end
end

local function getMoneyItems()
    local moneyItems = {}
    local droppedLootMoney = Workspace:FindFirstChild("DroppedLootMoney")
    if droppedLootMoney then
        for _, item in ipairs(droppedLootMoney:GetChildren()) do
            if item.Name:match("^£") then
                table.insert(moneyItems, item)
            end
        end
    end
    return moneyItems
end

local function equipAndUseItem(itemName)
    if character and character:FindFirstChild("Humanoid") then
        local tool = localPlayer.Backpack:FindFirstChild(itemName)
        if tool then
            humanoid:EquipTool(tool)
            task.wait(0.1)
            if tool:IsA("Tool") then
                tool:Activate()
                task.wait(0.1)
            end
        end
    end
end

local function collectItem(item)
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(item.Position + Vector3.new(0, 3, 0))
        task.wait(0.1)
        for _, descendant in ipairs(item:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                fireproximityprompt(descendant)
                task.wait(0.1)
                equipAndUseItem(item.Name)
            end
        end
    end
end

localPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    if isAutoCleanActive then
        equipMop()
        setPromptsToInstant()
    end
    if isAutoCartonActive then
        task.wait(1)
        autoSequence()
    end
    if isAutoCollectActive and character and character:FindFirstChild("HumanoidRootPart") then
        originalPosition = character.HumanoidRootPart.CFrame
    end
end)

Tab4:NewToggle("AutoClean", false, function(value)
    local mop = localPlayer.Backpack:FindFirstChild("Mop")
    if value and not mop then
        Notif:Notify("You don't have Paki job or Mop item", 5, "error")
        sectionAutoFarm:FindFirstChild("AutoClean"):Set(false)
        return
    end
    isAutoCleanActive = value
    if value then
        setPromptsToInstant()
        equipMop()
        equipCheckConnection = task.spawn(function()
            while isAutoCleanActive do
                if humanoid and not humanoid:FindFirstChild("Mop") then
                    equipMop()
                end
                task.wait(0.5)
            end
        end)
        autoCleanConnection = task.spawn(function()
            while isAutoCleanActive do
                local cleanParts = getCleanParts()
                if #cleanParts > 0 then
                    for _, part in ipairs(cleanParts) do
                        if not isAutoCleanActive then break end
                        interactWithPart(part)
                    end
                else
                    task.wait(1)
                end
                task.wait(0.5)
            end
        end)
        Notif:Notify("AutoClean Enabled", 4, "success")
    else
        if autoCleanConnection then
            task.cancel(autoCleanConnection)
            autoCleanConnection = nil
        end
        if equipCheckConnection then
            task.cancel(equipCheckConnection)
            equipCheckConnection = nil
        end
        Notif:Notify("AutoClean Disabled", 4, "success")
    end
end)

Tab4:NewToggle("AutoCarton", false, function(value)
    local tool = localPlayer.Backpack:FindFirstChild(TOOL_NAME)
    if value and not tool then
        Notif:Notify("You don't have Box item", 5, "error")
        sectionAutoFarm:FindFirstChild("AutoCarton"):Set(false)
        return
    end
    isAutoCartonActive = value
    if value then
        autoCartonConnection = task.spawn(function()
            while isAutoCartonActive do
                autoSequence()
                task.wait(1)
            end
        end)
        Notif:Notify("AutoCarton Enabled", 4, "success")
    else
        if autoCartonConnection then
            task.cancel(autoCartonConnection)
            autoCartonConnection = nil
        end
        Notif:Notify("AutoCarton Disabled", 4, "success")
    end
end)

Tab4:NewToggle("AutoCollect Money", false, function(value)
    if value then
        if character and character:FindFirstChild("HumanoidRootPart") then
            originalPosition = character.HumanoidRootPart.CFrame
        else
            Notif:Notify("Character not found", 5, "error")
            sectionAutoFarm:FindFirstChild("AutoCollect Money"):Set(false)
            return
        end
        isAutoCollectActive = true
        autoCollectConnection = task.spawn(function()
            while isAutoCollectActive do
                local moneyItems = getMoneyItems()
                if #moneyItems > 0 then
                    for _, item in ipairs(moneyItems) do
                        if not isAutoCollectActive then break end
                        collectItem(item)
                    end
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = originalPosition
                    end
                end
                task.wait(0.5)
            end
        end)
        Notif:Notify("AutoCollect Money Enabled", 4, "success")
    else
        isAutoCollectActive = false
        if autoCollectConnection then
            task.cancel(autoCollectConnection)
            autoCollectConnection = nil
        end
        if originalPosition and character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = originalPosition
        end
        Notif:Notify("AutoCollect Money Disabled", 4, "success")
    end
end)

local tabServer = Init:NewTab("Server")
local sectionServer = tabServer:NewSection("Server Features")

local PlaceId = 11177482306
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

tabServer:NewButton("Low Player Server", function()
    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and servers and servers.data then
        local lowestServer = nil
        local minPlayers = math.huge
        for _, server in ipairs(servers.data) do
            if server.playing < minPlayers and server.playing <= 0 then
                minPlayers = server.playing
                lowestServer = server
            end
        end
        if not lowestServer then
            for _, server in ipairs(servers.data) do
                if server.playing < minPlayers then
                    minPlayers = server.playing
                    lowestServer = server
                end
            end
        end
        if lowestServer then
            TeleportService:TeleportToPlaceInstance(PlaceId, lowestServer.id, localPlayer)
            Notif:Notify("Teleporting to server with " .. minPlayers .. " players", 4, "success")
        else
            Notif:Notify("No servers found", 5, "error")
        end
    else
        Notif:Notify("Failed to fetch servers", 5, "error")
    end
end)

tabServer:NewButton("High Player Server", function()
    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
    end)
    if success and servers and servers.data then
        local highestServer = nil
        local maxPlayers = -1
        for _, server in ipairs(servers.data) do
            if server.playing > maxPlayers then
                maxPlayers = server.playing
                highestServer = server
            end
        end
        if highestServer then
            TeleportService:TeleportToPlaceInstance(PlaceId, highestServer.id, localPlayer)
            Notif:Notify("Teleporting to server with " .. maxPlayers .. " players", 4, "success")
        else
            Notif:Notify("No servers found", 5, "error")
        end
    else
        Notif:Notify("Failed to fetch servers", 5, "error")
    end
end)

tabServer:NewButton("Rejoin Server", function()
    local currentJobId = game.JobId
    if currentJobId and currentJobId ~= "" then
        TeleportService:TeleportToPlaceInstance(PlaceId, currentJobId, localPlayer)
        Notif:Notify("Rejoining current server", 4, "success")
    else
        Notif:Notify("Cannot rejoin: Private server or invalid JobId", 5, "error")
    end
end)

tabServer:NewButton("Server Random", function()
    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and servers and servers.data then
        local currentJobId = game.JobId
        local validServers = {}
        for _, server in ipairs(servers.data) do
            if server.id ~= currentJobId then
                table.insert(validServers, server)
            end
        end
        if #validServers > 0 then
            local randomServer = validServers[math.random(1, #validServers)]
            TeleportService:TeleportToPlaceInstance(PlaceId, randomServer.id, localPlayer)
            Notif:Notify("Teleporting to random server with " .. randomServer.playing .. " players", 4, "success")
        else
            Notif:Notify("No different servers found", 5, "error")
        end
    else
        Notif:Notify("Failed to fetch servers", 5, "error")
    end
end)

tabServer:NewButton("Crash Game", function()
    while true do end
end)

local playerCountLabel = tabServer:NewLabel("Players on Server: 0", "left")
task.spawn(function()
    while true do
        local playerCount = #Players:GetPlayers()
        playerCountLabel:Text("Players on Server: " .. playerCount)
        task.wait(1)
    end
end)

local fpsLabel = tabServer:NewLabel("FPS Client: " .. library.fps, "left")
task.spawn(function()
    while true do
        fpsLabel:Text("FPS Client: " .. library.fps)
        task.wait(1)
    end
end)

local serverAgeLabel = tabServer:NewLabel("Server Age: 0s", "left")
task.spawn(function()
    while true do
        local serverAge = math.floor(tick() - game:GetService("DataStoreService"):GetDataStore("ServerStartTime"):GetAsync("Server_" .. game.JobId) or tick())
        local minutes = math.floor(serverAge / 60)
        local seconds = serverAge % 60
        serverAgeLabel:Text("Server Age: " .. minutes .. "m " .. seconds .. "s")
        task.wait(1)
    end
end)

Notif:Notify("[Street Wars 2] Loaded Successfully", 4, "success")