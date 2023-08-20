if getgenv().BladeQuest then
    return
end

if not game:IsLoaded() then 
    game.Loaded:Wait()
    print("Game has been loaded")
end
wait(2)

getgenv().BladeQuest = true

local teleport_execute = queue_on_teleport or (fluxus and fluxus.queue_on_teleport) or (syn and syn.queue_on_teleport)
if teleport_execute then
    print(1)
    teleport_execute("loadstring(game:HttpGet('https://raw.githubusercontent.com/huyphan1126/BladeQuest/main/BladeQuestScript.lua'))()")
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local RS = game:GetService("ReplicatedStorage")
local PlrUI = game:GetService("Players").LocalPlayer.PlayerGui.UI
local playerLevel = game:GetService("Players").LocalPlayer.leaderstats.Level.Value

local Dungeons = {"Forest", "Ghost Town", "Crystal Mines", "Toy World", 
                  "Collage", "Dragon's Den", "Neon Avenue", "Carnival", "Space Lab"}

local Difficulties  = {"Easy", "Medium", "Hard", "Expert"}

local settings = {
    -- AutoSellCommon = false,
    -- AutoSellUncommon = false,
    AuToBestEquip = false,
    AutoGame = false,
    AutoCreateSpecMap = false,
    AutoHardcore = false,
    Autofarm = false,
    TweenSpeed = 0.5,
    Y_Offset = 3,
    map = "",
    difficulty = "",
    AutoClaimReward = false,
    Host = false,
    Participant = false,
    CommonMerge = false,
    UncommonMerge = false,
    RareMerge = false,
    EpicMerge = false,
    LegendaryMerge = false,
    HostName = "Input Name"
}

function LoadSettingsFromFile(settings)
    local success, file = pcall(readfile, "AutoBladeQuest.txt")
    
    if success then
        for line in file:gmatch("[^\r\n]+") do
            local key, value = line:match("([^=]+)=(.*)")
            if key and value then
                if key == "HostName" or key == "difficulty" or key == "map"then
                    settings[key] = value
                else
                    if tonumber(value) then
                        settings[key] = tonumber(value)
                    else
                        settings[key] = tostring(value) == "true"
                    end 
                end
            end
        end
    else
        -- settings.AutoSellCommon = false
        -- settings.AutoSellUncommon = false
        settings.AutoBestEquip = false
        settings.AutoGame = false
        settings.AutoHardcore = false
        settings.Autofarm = false
        settings.TweenSpeed = 0.5
        settings.Y_Offset = 3
        settings.map = ""
        settings.difficulty = ""
        settings.AutoClaimReward = false
        settings.Host = false
        settings.Participant = false
        settings.HostName = "Input Name"
        settings.CommonMerge = false
        settings.UncommonMerge = false
        settings.RareMerge = false
        settings.EpicMerge = false
        settings.LegendaryMerge = false
    end
    -- for key, value in pairs(settings) do
    --     print("Key:",key,"Value:",type(value))
    -- end
end 

LoadSettingsFromFile(settings)

function SaveSettingsToFile(settings)
    local savesetting = ""
    for key, value in pairs(settings) do
        savesetting = savesetting .. key .. "=" .. tostring(value) .. "\n"
    end
    writefile("AutoBladeQuest.txt",savesetting)
end

function AutoChooseMap(playerLevel)
    local CheckLv = 1
    for _,map in pairs(Dungeons) do
        for _,diff in pairs(Difficulties) do
            if playerLevel <= CheckLv + 3 then
                return map, diff
            end
            CheckLv+=3
        end
    end
end

function CreateRoom(Room_name, Difficult, Hardcore, FriendOnly)
    Hardcore = Hardcore or false
    FriendOnly = FriendOnly or false

    local RoomInfo = {
        [1] = "Create",
        [2] = Room_name,
        [3] = Difficult,
        [4] = FriendOnly,
        [5] = Hardcore
    }
    
    game:GetService("ReplicatedStorage").RF:InvokeServer(unpack(RoomInfo))
    return RoomInfo
end

function StartGame()
    repeat wait()
        if game:GetService("Players").LocalPlayer.PlayerGui.UI.Play.Lobby.Visible then
            game:GetService("ReplicatedStorage").RF:InvokeServer("Start")
        end
    until game:GetService("Players").LocalPlayer.PlayerGui.UI.Play.Lobby.Visible
end

function CreateWallProtect()
    local ProtectPart = Instance.new("Folder")
    ProtectPart.Name = "ProtectPart"
    ProtectPart.Parent = game.Workspace

    local Platform = Instance.new("Part") 
    Platform.Name = "Platform"
    Platform.Size = Vector3.new(5000, 4, 5000)
    Platform.Transparency = 1
    Platform.Anchored = true
    Platform.Parent = game.Workspace.ProtectPart

    local Wall1 = Instance.new("Part")
    Wall1.Name = "Wall1"
    Wall1.Size = Vector3.new(3, 20, 6)
    Wall1.Transparency = 1
    Wall1.Anchored = true
    Wall1.Parent = game.Workspace.ProtectPart
    Wall1.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(3, 0, 0)

    local Wall2 = Instance.new("Part")
    Wall2.Name = "Wall2"
    Wall2.Size = Vector3.new(3, 20, 6)
    Wall2.Transparency = 1
    Wall2.Anchored = true
    Wall2.Parent = game.Workspace.ProtectPart
    Wall2.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(-3, 0, 0)

    local Wall3 = Instance.new("Part")
    Wall3.Name = "Wall3"
    Wall3.Size = Vector3.new(6, 20, 3)
    Wall3.Transparency = 1
    Wall3.Anchored = true
    Wall3.Parent = game.Workspace.ProtectPart
    Wall3.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 0, 3)

    local Wall4 = Instance.new("Part")
    Wall4.Name = "Wall4"
    Wall4.Size = Vector3.new(6, 20, 3)
    Wall4.Transparency = 1
    Wall4.Anchored = true
    Wall4.Parent = game.Workspace.ProtectPart
    Wall4.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 0, -3)

    return Platform, Wall1, Wall2, Wall3, Wall4
end

function UpdateWallProtect(Platform, Wall1, Wall2, Wall3, Wall4)

    Wall1.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(4, 0, 0)    
    Wall2.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(-4, 0, 0)
    Wall3.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 0, 4)
    Wall4.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 0, -4) 
    Platform.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, -5, 0) 
end

function AutoFarm()
    local Platform, Wall1, Wall2, Wall3, Wall4 = CreateWallProtect()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, -4, 0) 
    local tweenService = game:GetService("TweenService") 
    local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear) 
    game.Players.LocalPlayer.Character:findFirstChildOfClass("Humanoid"):ChangeState(11)
    while settings.Autofarm do
        local MaxPlayerCurrentHp = game.Players.LocalPlayer.Character.Humanoid.Health
        local PlayerRealTimeHp = 0

        game.Players.LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            PlayerRealTimeHp = game.Players.LocalPlayer.Character.Humanoid.Health
            if PlayerRealTimeHp < MaxPlayerCurrentHp then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 6)
                UpdateWallProtect(Platform, Wall1, Wall2, Wall3, Wall4)
                MaxPlayerCurrentHp = game.Players.LocalPlayer.Character.Humanoid.Health
            end
        end)

        for i, v in pairs(game.workspace:GetChildren()) do
            if v.Name == "Map" or v.Name == "Ignore" or v.Name == "Decor" or v.Name == "Kill" or v.Name == "Boss" then
                local temp = v:Clone()
                temp.Parent = RS
                v:Destroy()
            end
        end

        local firstenemy = game.workspace.Enemies:FindFirstChildOfClass("Model") 
        local enemy = game.workspace.Enemies:GetChildren()

        for i, v in pairs(enemy) do
            IsHumanoidThere = firstenemy:FindFirstChild("HumanoidRootPart")
            if IsHumanoidThere and game.Players.LocalPlayer.Character.Humanoid.Health ~= 0 and settings.Autofarm then
                hrp.CFrame = CFrame.lookAt(hrp.Position, IsHumanoidThere.Position)
                local tweenresult = {CFrame = firstenemy.HumanoidRootPart.CFrame + Vector3.new(0, settings.Y_Offset, 0)}
                tween = tweenService:Create(game:GetService("Players")["LocalPlayer"].Character.HumanoidRootPart, tweenInfo, tweenresult)
                game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
                UpdateWallProtect(Platform, Wall1, Wall2, Wall3, Wall4)
                tween:Play()
                UpdateWallProtect(Platform, Wall1, Wall2, Wall3, Wall4)
                UpdateWallProtect(Platform, Wall1, Wall2, Wall3, Wall4)
                game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
                wait()
                RS.Magic:FireServer("Damage")
                RS.Magic:FireServer("Support")
                RS.RE:FireServer("Hit", v, game.Players.LocalPlayer.Character.Sword.Handle.CFrame, settings.TweenSpeed)
                if v:FindFirstChild("Enemy") then 
                    if v.Enemy.Health == 0 then 
                        v:Destroy()
                    end
                end
            else
                if settings.Autofarm == false then
                    break
                end
            end
        end
        wait()
    end
end

function checkPlrinSv(name)
    for i,v in pairs(game:GetService("Players"):GetPlayers()) do
        if v.Name == name then
            return true
        end
    end

    return false
end

function joinlobby(hostnane)
    local LobbyList = PlrUI.Play.Join.List
    local id_room = nil

    
    for _,id in pairs(LobbyList:GetChildren()) do
        if tonumber(id.Name) then
            if id.Name ~= "UIListLayout" and checkPlrinSv(hostnane) and string.match(id:FindFirstChild("Host").Text,hostnane) ~= nil then
                id_room = id.Name
            end
        end  
    end

    if game:GetService("Players").LocalPlayer.PlayerGui.UI.Play.Lobby.Visible == true then
        if string.match(game:GetService("Players").LocalPlayer.PlayerGui.UI.Play.Lobby.Lobby.Host.Text,hostnane) == nil then
            -- print("Sai phòng")
            RS.RF:InvokeServer("Leave")
        end
    end

    if id_room and game:GetService("Players").LocalPlayer.PlayerGui.UI.Play.Lobby.Visible == false then
        local args = {
            [1] = "Join",
            [2] = game:GetService("ReplicatedStorage").Lobbies:FindFirstChild(id_room)
        }
    
        game:GetService("ReplicatedStorage").RF:InvokeServer(unpack(args))
    end
end

function SmallestLevel(lst_Name)
    local minVal = math.huge
    for _,v in pairs(lst_Name) do
        local level = game:GetService("Players"):FindFirstChild(v).leaderstats.Level.Value
        if level < minVal then
            minVal = level
        end
    end
    return minVal
end

function isValueInList(list, value)
    for _, v in pairs(list) do
        if v == value then
            return true
        end
    end
    return false
end

function HostCreateRoom() 
    local plrInRoomAfterWait = {}
    CreateRoom("Forest","Easy",false,true)
    wait(3)
    if game:GetService("Players").LocalPlayer.PlayerGui.UI.Play.Create.Visible == false and settings.Host then
        for _,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.UI.Play.Lobby.Players:GetChildren()) do
            if v:IsA("ImageLabel") and v.Name ~= "UIListLayout" then
                table.insert(plrInRoomAfterWait, v.Name)
            end
        end
        RS.RF:InvokeServer("Leave")
    else
        return
    end

    local level = SmallestLevel(plrInRoomAfterWait)

    if level then
        local map, diff = AutoChooseMap(level)
        CreateRoom(map,diff,settings.AutoHardcore,true)
    else
        return
    end
end

function BestEquip()
    local lst_sword = PlrUI.Inventory.Swords.ListBg.List
    if #lst_sword:GetChildren() > 2 then

        local Signals = {'MouseButton1Down', 'MouseButton1Click', 'Activated'}
        local equipDamge = nil
        local maxDameInInventory = 0
        local SwordMaxDameEquipInInventory = nil

        for _,sword in pairs(lst_sword:GetChildren()) do
            if sword.Name ~= "UIGridLayout" then
                if sword.Equip.Visible then
                    for _,cmd in pairs(Signals) do
                        firesignal(sword[cmd])
                    end
                    equipDamge = tonumber(game:GetService("Players").LocalPlayer.PlayerGui.UI.Inventory.Swords.SelectBg.Dmg.Text)
                end
                
            end
        end

        for _, sword in pairs(lst_sword:GetChildren()) do
            if sword.Name ~= "UIGridLayout" and sword.Name ~= swordequipname then
                for _,cmd in pairs(Signals) do
                    firesignal(sword[cmd])
                    local swordDamge = tonumber(game:GetService("Players").LocalPlayer.PlayerGui.UI.Inventory.Swords.SelectBg.Dmg.Text)
                    if swordDamge > maxDameInInventory then
                        maxDameInInventory = swordDamge
                        SwordMaxDameEquipInInventory = sword.Name
                    end
                end
            end
        end
        
        if equipDamge < maxDameInInventory then
            local SwordEquipInformation = {
                [1] = "Equip",
                [2] = game:GetService("Players").LocalPlayer.Data.Swords:FindFirstChild(SwordMaxDameEquipInInventory)
            }

            game:GetService("ReplicatedStorage").RE:FireServer(unpack(SwordEquipInformation))
        end
    else
        return
    end
end

function SortLvWeapon(WeaponDict)
    local temp = {}

    for key, value in pairs(WeaponDict) do
        table.insert(temp, {key = key, value = value})
    end

    table.sort(temp, function(a, b)
        return a.value > b.value
    end)

    local sortedWeapon = {}
    for _, entry in pairs(temp) do
        sortedWeapon[entry.key] = entry.value
    end
    return sortedWeapon
end

function GetRarityOfSword(SwordName)
    local DataSword = RS.Sword

    for _,sword in pairs(DataSword:GetChildren()) do
        if sword.Name == SwordName then
            return sword.Rarity.Value
        end
    end

end

function Merge(Rarity)
    local lst_sword = PlrUI.Inventory.Swords.ListBg.List
    local swordDict = {}
    
    if #lst_sword:GetChildren() > 2 then
        local Signals = {'MouseButton1Down', 'MouseButton1Click', 'Activated'}

        for _,sword in pairs(lst_sword:GetChildren()) do
            if sword.Name ~= "UIGridLayout" and sword.Equip.Visible == false then
                local sowrdlv = tonumber(sword.Lvl.Text:match("%d+"))
                swordDict[sword.Name] = sowrdlv
            end
        end
    

        swordDict = SortLvWeapon(swordDict)
        
        local MergeRarityWeapon = {}
        
        for swordname ,levelSword in pairs(swordDict) do
            for _, cmd in pairs(Signals) do
                firesignal(lst_sword:FindFirstChild(swordname)[cmd])
            end

            local name = game:GetService("Players").LocalPlayer.PlayerGui.UI.Inventory.Swords.SelectBg.Tag.Text
            local swordRarity = GetRarityOfSword(name)

            if swordRarity == Rarity then
                table.insert(MergeRarityWeapon,swordname)
            end
        end
        
        while #MergeRarityWeapon >= 5 do
            -- print(#MergeRarityWeapon)
            -- print("Đang merge"..Rarity)

            local RarityNum = {
                ["Common"] = 1,
                ["Uncommon"] = 2,
                ["Rare"] = 3,
                ["Epic"] = 4,
                ["Legendary"] = 5
            }
            
            local MergeInformation = {
                [1] = "Merge",
                [2] = {
                    [1] = game:GetService("Players").LocalPlayer.Data.Swords:FindFirstChild(MergeRarityWeapon[1]),
                    [2] = game:GetService("Players").LocalPlayer.Data.Swords:FindFirstChild(MergeRarityWeapon[2]),
                    [3] = game:GetService("Players").LocalPlayer.Data.Swords:FindFirstChild(MergeRarityWeapon[3]),
                    [4] = game:GetService("Players").LocalPlayer.Data.Swords:FindFirstChild(MergeRarityWeapon[4]),
                    [5] = game:GetService("Players").LocalPlayer.Data.Swords:FindFirstChild(MergeRarityWeapon[5])
                },
                [3] = RarityNum[Rarity],
                [4] = "Swords"
            }

            RS.RF:InvokeServer(unpack(MergeInformation))
            wait(1)
            table.remove(MergeRarityWeapon,1)
            table.remove(MergeRarityWeapon,2)
            table.remove(MergeRarityWeapon,3)
            table.remove(MergeRarityWeapon,4)
            table.remove(MergeRarityWeapon,5)
        end
    end
end

-- function SellRarity(Rarity)
--     local lst_sword = PlrUI.Inventory.Swords.ListBg.List
--     if #lst_sword:GetChildren() > 2 then
--         local Signals = {'MouseButton1Down', 'MouseButton1Click', 'Activated'}

--         local SellInformation = {
--             [1] = "Sell",
--             [2] = game:GetService("Players").LocalPlayer.Data.Swords:FindFirstChild("1")
--         }

--         game:GetService("ReplicatedStorage").RF:InvokeServer(unpack(args))
        
--     end
-- end

local Window = Rayfield:CreateWindow({
    Name = "[X2] Blade Quest | Autofarm Version 1.0 | By: Ello_Doge",
    LoadingTitle = "Loading Script",
    LoadingSubtitle = "By Ello_Doge",
    ConfigurationSaving = {
       Enabled = false,
       FolderName = nil, -- Create a custom folder for your hub/game
       FileName = "Big Hub"
    },
    Discord = {
       Enabled = false,
       Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
       RememberJoins = true -- Set this to false to make them join the discord every time they load it up
    },
    KeySystem = false, -- Set this to true to use our key system
    KeySettings = {
       Title = "Untitled",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided",
       FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
       SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
       GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
       Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
    }
})

local LobbyTab = Window:CreateTab("Lobby", nil)

local EquipSection = LobbyTab:CreateSection("Equip")

local BestWeaponEquip = LobbyTab:CreateToggle({
    Name = "Auto Best Equip",
    CurrentValue = settings.AuToBestEquip,
    Flag = "Toggle8", 
    Callback = function(IsBestEquip)
        settings.AuToBestEquip = IsBestEquip
        SaveSettingsToFile(settings)

        if settings.AuToBestEquip and game.PlaceId == 6494523288 then
            BestEquip()
        end

        local swordfolder = PlrUI.Inventory.Swords.ListBg.List

        swordfolder.ChildAdded:Connect(function()
            if settings.AuToBestEquip and game.PlaceId == 6494523288 then
                BestEquip()
            end
        end)
    end,
})

local MergeWeaponSection = LobbyTab:CreateSection("Merge")

local CommonMerge = LobbyTab:CreateToggle({
    Name = "Common Merge",
    CurrentValue = settings.CommonMerge,
    Flag = "Toggle9", 
    Callback = function(Value)
        settings.CommonMerge = Value
        SaveSettingsToFile(settings)
        local swordfolder = PlrUI.Inventory.Swords.ListBg.List
        if settings.CommonMerge and game.PlaceId == 6494523288 then
            Merge("Common")
        end
        swordfolder.ChildAdded:Connect(function()
            if settings.CommonMerge and game.PlaceId == 6494523288 then
                Merge("Common")
            end
        end)

    end,
})

local UncommonMerge = LobbyTab:CreateToggle({
    Name = "Uncommon Merge",
    CurrentValue = settings.UncommonMerge,
    Flag = "Toggle10", 
    Callback = function(Value)
        settings.UncommonMerge = Value
        SaveSettingsToFile(settings)
        local swordfolder = PlrUI.Inventory.Swords.ListBg.List
        if settings.UncommonMerge and game.PlaceId == 6494523288 then
            Merge("Uncommon")
        end

        swordfolder.ChildAdded:Connect(function()
            if settings.UncommonMerge and game.PlaceId == 6494523288 then
                Merge("Uncommon")
            end
        end)
    end,
})

local RareMerge = LobbyTab:CreateToggle({
    Name = "Rare Merge",
    CurrentValue = settings.RareMerge,
    Flag = "Toggle11", 
    Callback = function(Value)
        settings.RareMerge = Value
        SaveSettingsToFile(settings)
        local swordfolder = PlrUI.Inventory.Swords.ListBg.List
        if settings.RareMerge and game.PlaceId == 6494523288 then
            Merge("Rare")
        end
        swordfolder.ChildAdded:Connect(function()
            if settings.RareMerge and game.PlaceId == 6494523288 then
                Merge("Rare")
            end
        end)
    end,
})

local EpicMerge = LobbyTab:CreateToggle({
    Name = "Epic Merge",
    CurrentValue = settings.EpicMerge,
    Flag = "Toggle12", 
    Callback = function(Value)
        settings.EpicMerge = Value
        SaveSettingsToFile(settings)
        local swordfolder = PlrUI.Inventory.Swords.ListBg.List
        if settings.EpicMerge and game.PlaceId == 6494523288 then
            Merge("Epic")
        end
        swordfolder.ChildAdded:Connect(function()
            if settings.EpicMerge and game.PlaceId == 6494523288 then
                Merge("Epic")
            end
        end)
    end,
})

local LegendaryMerge = LobbyTab:CreateToggle({
    Name = "Legendary Merge",
    CurrentValue = settings.LegendaryMerge,
    Flag = "Toggle13", 
    Callback = function(Value)
        settings.LegendaryMerge = Value
        SaveSettingsToFile(settings)
        local swordfolder = PlrUI.Inventory.Swords.ListBg.List
        if settings.LegendaryMerge and game.PlaceId == 6494523288 then
            Merge("Legendary")
        end
        swordfolder.ChildAdded:Connect(function()
            if settings.LegendaryMerge and game.PlaceId == 6494523288 then
                Merge("Legendary")
            end
        end)
    end,
})

local AutoFarmTab = Window:CreateTab("Auto Farm", nil)

local AutoFarmMainSection = AutoFarmTab:CreateSection("Dungeon")

local HardCore = AutoFarmTab:CreateToggle({
    Name = "Auto HardCore",
    CurrentValue = settings.AutoHardcore,
    Flag = "Toggle1", 
    Callback = function(IsHardcore)
        settings.AutoHardcore = IsHardcore
        SaveSettingsToFile(settings)
    end,
})

local AutoDugeonToggle = AutoFarmTab:CreateToggle({
    Name = "Automatic Dungeon And Difficulty",
    CurrentValue = settings.AutoGame,
    Flag = "Toggle2", 
    Callback = function(AutoFindDungeonAndDiff)
        settings.AutoGame = AutoFindDungeonAndDiff
        SaveSettingsToFile(settings)
        if game.PlaceId == 6494523288 and settings.AutoGame then
            local map, diff = AutoChooseMap(playerLevel)
         	CreateRoom(map,diff,settings.AutoHardcore,false)
            StartGame()
        end
    end,
})

local AutoFarmMainSection = AutoFarmTab:CreateSection("Main")

local AutoFarmToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Farm (Don't turn off when in use)",
    CurrentValue = settings.Autofarm,
    Flag = "Toggle3", 
    Callback = function(isFarming)
        if game.PlaceId == 6494523288 then
            return
        end
        settings.Autofarm = isFarming
        SaveSettingsToFile(settings)

        if settings.Autofarm then
            AutoFarm()
        end

        if settings.Autofarm == false then
            for _, v in pairs(RS:GetChildren()) do
                if v.Name == "Map" or v.Name == "Ignore" or v.Name == "Decor" or v.Name == "Kill" or v.Name == "Boss" then
                    local temp = v:Clone()
                    temp.Parent = game.Workspace
                    v:Destroy()
                end
            end
        end
    end,
})

local AutoFarmSettingSection = AutoFarmTab:CreateSection("Setting")

local TweenSpeedSlider = AutoFarmTab:CreateSlider({
    Name = "Tween speed",
    Range = {0, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = math.floor((1.5 - settings.TweenSpeed) / (1.5 - 0.1) * 100),
    Flag = "Slider1", 
    Callback = function(TweenSpeedValue)
        local minValue = 1.5
        local maxValue = 0.1
        local convertedValue = minValue - (TweenSpeedValue / 100) * (minValue - maxValue)
        
        settings.TweenSpeed = convertedValue
        SaveSettingsToFile(settings)
    end,
})

local Y_OffsetSlider = AutoFarmTab:CreateSlider({
    Name = "Y Offset",
    Range = {0, 10},
    Increment = 1,
    Suffix = "Units",
    CurrentValue = tonumber(settings.Y_Offset),
    Flag = "Slider2", 
    Callback = function(Height) 
        settings.Y_Offset = Height
        SaveSettingsToFile(settings)
    end,
})

local MultiFarmTab = Window:CreateTab("Multi Farm", nil) 

local HostSection = MultiFarmTab:CreateSection("Host")

local HostToggle = MultiFarmTab:CreateToggle({
    Name = "Host",
    CurrentValue = settings.Host,
    Flag = "Toggle6", 
    Callback = function(IsHost)
        settings.Host = IsHost
        SaveSettingsToFile(settings)
        if settings.Participant then
            print("You choose both Host and Participant")
        end

        if settings.Host then
            HostCreateRoom()
            wait(2)
            StartGame()
        end
    end,
})

local ParticipantsSection = MultiFarmTab:CreateSection("Participants")

local ParticipantsToggle = MultiFarmTab:CreateToggle({
    Name = "Participants",
    CurrentValue = settings.Participant,
    Flag = "Toggle7", 
    Callback = function(IsParticipants)
        settings.Participant = IsParticipants
        SaveSettingsToFile(settings)
        if settings.Host then
            print("You choose both Host and Participant")
            return
        end

        if game.PlaceId == 6494523288 and settings.Participant then
            spawn(function()
                while settings.Participant do
                    -- print("Đang join")
                    joinlobby(settings.HostName)
                    wait()
                end
            end)
        end
    end,
})
ParticipantsToggle:Set(settings.Participant)
local HostNameInput = MultiFarmTab:CreateInput({
    Name = "Host's Name: ",
    PlaceholderText = settings.HostName,
    RemoveTextAfterFocusLost = false,
    Callback = function(Name)
        settings.HostName = Name
        SaveSettingsToFile(settings)
    end,
})

local AutoSpecificDungeonTab = Window:CreateTab("Dungeon", nil)

local AutoStartSpecDungeonSection = AutoSpecificDungeonTab:CreateSection("Start Dungeon")

local AutoCreateDugeonSpecificToggle = AutoSpecificDungeonTab:CreateToggle({
    Name = "Automatic Create Dungeon",
    CurrentValue = settings.AutoCreateSpecMap,
    Flag = "Toggle4", 
    Callback = function(Create)
        settings.AutoCreateSpecMap = Create
        SaveSettingsToFile(settings)
        if game.PlaceId == 6494523288 and settings.AutoCreateSpecMap then
            if settings.map and settings.difficulty then            
                CreateRoom(settings.map,settings.difficulty,settings.AutoHardcore,false)
                wait(1)
                if settings.AutoCreateSpecMap then
                    StartGame()
                end
            end
        end
    end,
})

local SettingsSpecDungeonSection = AutoSpecificDungeonTab:CreateSection("Settings")

local MapDropdown = AutoSpecificDungeonTab:CreateDropdown({
    Name = "Map",
    Options = Dungeons,
    CurrentOption = settings.map,
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Map)
        settings.map = Map[1]
        SaveSettingsToFile(settings)
    end,
})

local DifficultiesDropdown = AutoSpecificDungeonTab:CreateDropdown({
    Name = "Difficulties",
    Options = Difficulties,
    CurrentOption = settings.difficulty,
    MultipleOptions = false,
    Flag = "Dropdown2",
    Callback = function(Difficulty)
        settings.difficulty = Difficulty[1]
        SaveSettingsToFile(settings)
    end,
})

AutoCreateDugeonSpecificToggle:Set(settings.AutoCreateSpecMap)

local MiscTab = Window:CreateTab("Misc", nil)

local AutoClainDailySection = MiscTab:CreateSection("Daily Reward")

local AutoClaimDailyRewardToggle = MiscTab:CreateToggle({
    Name = "Auto Claim",
    CurrentValue = settings.AutoClaimReward,
    Flag = "Toggle5", 
    Callback = function(IsClaim)
        settings.AutoClaimReward = IsClaim
        SaveSettingsToFile(settings)
        if settings.AutoClaimReward then
            local dailyRewardFrame = PlrUI.Daily
            local Signals = {'MouseButton1Down', 'MouseButton1Click', 'Activated'}
            if dailyRewardFrame.Claim.Visible == true then
                for _, cmd in pairs(Signals) do
                    firesignal(dailyRewardFrame.Claim[cmd])
                end
            end
            wait(1)
        end
    end,
})

if game.PlaceId == 6494523288 then
    BestWeaponEquip:Set(settings.AuToBestEquip)
    CommonMerge:Set(settings.CommonMerge)
    UncommonMerge:Set(settings.UncommonMerge)
    RareMerge:Set(settings.RareMerge)
    EpicMerge:Set(settings.EpicMerge)
    LegendaryMerge:Set(settings.LegendaryMerge)
    HardCore:Set(settings.AutoHardcore)
    AutoClaimDailyRewardToggle:Set(settings.AutoClaimReward)
    
    HostToggle:Set(settings.Host)
    AutoDugeonToggle:Set(settings.AutoGame)
end

if game.PlaceId ~= "6494523288" then
    TweenSpeedSlider:Set(math.floor((1.5 - settings.TweenSpeed) / (1.5 - 0.1) * 100))
    Y_OffsetSlider:Set(settings.Y_Offset)
    AutoFarmToggle:Set(settings.Autofarm)
end