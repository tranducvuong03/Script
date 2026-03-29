local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")

-- Khởi tạo Window
local Window = Rayfield:CreateWindow({
   Name = "Uranus Hub",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "by Uranus",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "UranusConfigs", 
      FileName = "AuraSettings"
   },
   KeybindSource = "LeftControl"
})

-- BIẾN CẤU HÌNH
local AuraSettings = {
    Enabled = false,
    Range = 20
}

local FarmSettings = {
    AutoFly = false,
    Speed = 50,
    Height = 5 
}

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MobsFolder = workspace:WaitForChild("Mobs")
local PlayerAttackRemote = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Combat"):WaitForChild("PlayerAttack")

local player = Players.LocalPlayer

-----------------------------------------------------------
-- HÀM LOGIC
-----------------------------------------------------------
local function getAllTargetsInRange()
    local targets = {}
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return targets end
    local myPos = character.HumanoidRootPart.Position
    for _, mob in pairs(MobsFolder:GetChildren()) do
        local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
        if root then
            local dist = (root.Position - myPos).Magnitude
            if dist <= AuraSettings.Range then
                local hum = mob:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health > 0 then
                    table.insert(targets, mob)
                end
            end
        end
    end
    return targets
end

local function getClosestMob()
    local closest = nil
    local dist = math.huge
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    for _, mob in pairs(MobsFolder:GetChildren()) do
        local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
        if root then
            local hum = mob:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health > 0 then
                local d = (root.Position - character.HumanoidRootPart.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = mob
                end
            end
        end
    end
    return closest
end

-----------------------------------------------------------
-- TAB: COMBAT
-----------------------------------------------------------
local MainTab = Window:CreateTab("Combat", 4483362458)

MainTab:CreateToggle({
   Name = "Auto Aura Kill",
   CurrentValue = false,
   Flag = "AuraToggle",
   Callback = function(Value)
      AuraSettings.Enabled = Value
   end,
})

MainTab:CreateSlider({
   Name = "Aura Range",
   Range = {0, 200},
   Increment = 1,
   Suffix = "Studs",
   CurrentValue = 20,
   Flag = "AuraRangeSlider",
   Callback = function(Value)
      AuraSettings.Range = Value
   end,
})

-----------------------------------------------------------
-- TAB: FARM
-----------------------------------------------------------
local FarmTab = Window:CreateTab("Farm", 4483362458)

FarmTab:CreateToggle({
   Name = "Auto Fly to Mob",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      FarmSettings.AutoFly = Value
   end,
})

FarmTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 300},
   Increment = 5,
   Suffix = "Speed",
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
      FarmSettings.Speed = Value
   end,
})

FarmTab:CreateSlider({
   Name = "Fly Height",
   Range = {-10, 20},
   Increment = 1,
   Suffix = "Studs",
   CurrentValue = 5,
   Flag = "FlyHeightSlider",
   Callback = function(Value)
      FarmSettings.Height = Value
   end,
})

-----------------------------------------------------------
-- TAB: SETTINGS (LƯU/TẢI CONFIG)
-----------------------------------------------------------
local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateButton({
   Name = "Save Settings",
   Callback = function()
      Rayfield:SaveConfiguration()
      Rayfield:Notify({Title = "Uranus Hub", Content = "Đã lưu cài đặt thành công!", Duration = 2})
   end,
})

SettingsTab:CreateButton({
   Name = "Destroy UI",
   Callback = function()
      Rayfield:Destroy()
   end,
})

-----------------------------------------------------------
-- LOOPS
-----------------------------------------------------------

task.spawn(function()
    while true do
        task.wait(0.2)
        if AuraSettings.Enabled then
            local nearbyMobs = getAllTargetsInRange()
            if #nearbyMobs > 0 then
                PlayerAttackRemote:FireServer({nearbyMobs})
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if FarmSettings.AutoFly then
            local targetMob = getClosestMob()
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if targetMob and root then
                local targetRoot = targetMob:FindFirstChild("HumanoidRootPart") or targetMob.PrimaryPart
                if targetRoot then
                    local targetPos = targetRoot.CFrame * CFrame.new(0, FarmSettings.Height, 0)
                    local distance = (root.Position - targetPos.Position).Magnitude
                    local duration = distance / FarmSettings.Speed
                    
                    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(root, tweenInfo, {CFrame = targetPos})
                    
                    tween:Play()
                    task.wait(0.1)
                end
            end
        end
    end
end)
