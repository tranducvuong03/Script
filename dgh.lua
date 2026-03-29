local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")

-- BIẾN CẤU HÌNH (Gắn Flag để Rayfield tự lưu/tải)
local AuraSettings = {
    Enabled = false,
    Range = 20
}
local FarmSettings = {
    AutoFly = false,
    Speed = 50,
    Height = 5
}
local SelectedConfig = ""

-- Khởi tạo Window
local Window = Rayfield:CreateWindow({
   Name = "Uranus Hub",
   LoadingTitle = "Loading Systems...",
   LoadingSubtitle = "by Uranus",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "UranusConfigs", 
      FileName = "MainConfig"
   },
   KeybindSource = "LeftControl"
})

-- SERVICES (Giữ nguyên bản gốc)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MobsFolder = workspace:WaitForChild("Mobs")
local PlayerAttackRemote = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Combat"):WaitForChild("PlayerAttack")
local player = Players.LocalPlayer

-----------------------------------------------------------
-- HÀM LOGIC GỐC (GIỮ NGUYÊN 100%)
-----------------------------------------------------------
local function getAllTargetsInRange()
    local targets = {}
    local character = Players.LocalPlayer.Character
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

-- Hàm tìm quái gần nhất cho chức năng Fly
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
                if d < dist then dist = d closest = mob end
            end
        end
    end
    return closest
end

-- Hàm quét file Config an toàn
local function safeListFiles()
    local success, files = pcall(function()
        if not isfolder("UranusConfigs") then makefolder("UranusConfigs") end
        local temp = {}
        for _, file in pairs(listfiles("UranusConfigs")) do
            if file:sub(-5) == ".json" then
                local name = file:gsub("UranusConfigs/", ""):gsub("UranusConfigs\\", ""):gsub(".json", "")
                table.insert(temp, name)
            end
        end
        return temp
    end)
    return success and files or {"Error: Not Supported"}
end

-----------------------------------------------------------
-- TAB: COMBAT (SỬ DỤNG LOGIC GỐC)
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
-- TAB: FARM (FLY TO MOB)
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
-- TAB: SETTINGS (CREATE, LOAD, OVERRIDE)
-----------------------------------------------------------
local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateSection("Manage Configs")

SettingsTab:CreateInput({
   Name = "Config Name",
   PlaceholderText = "New Name / Select to Override",
   Callback = function(Text) SelectedConfig = Text end,
})

local ConfigDropdown = SettingsTab:CreateDropdown({
   Name = "Select Config",
   Options = safeListFiles(),
   CurrentOption = "",
   Callback = function(Option) SelectedConfig = Option end,
})

SettingsTab:CreateButton({
   Name = "Refresh List",
   Callback = function() ConfigDropdown:Set(safeListFiles()) end,
})

SettingsTab:CreateButton({
   Name = "Create / Override Selected",
   Callback = function()
      if SelectedConfig ~= "" then
         Rayfield.ConfigurationSaving.FileName = SelectedConfig
         Rayfield:SaveConfiguration()
         Rayfield:Notify({Title = "Uranus Hub", Content = "Saved: "..SelectedConfig, Duration = 2})
      end
   end,
})

SettingsTab:CreateButton({
   Name = "Load Selected",
   Callback = function()
      if SelectedConfig ~= "" then
         Rayfield.ConfigurationSaving.FileName = SelectedConfig
         Rayfield:LoadConfiguration()
         Rayfield:Notify({Title = "Uranus Hub", Content = "Loaded: "..SelectedConfig, Duration = 2})
      end
   end,
})

-----------------------------------------------------------
-- VÒNG LẶP THỰC THI (LOOPS)
-----------------------------------------------------------

-- Vòng lặp Aura Gốc (0.2s + FireServer + unpack)
task.spawn(function()
    while true do
        task.wait(0.2)
        if AuraSettings.Enabled then
            local nearbyMobs = getAllTargetsInRange()
            if #nearbyMobs > 0 then
                -- ĐÚNG LOGIC GỐC CỦA BẠN:
                local args = { nearbyMobs }
                PlayerAttackRemote:FireServer(unpack(args))
            end
        end
    end
end)

-- Vòng lặp Fly
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
                    local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetPos})
                    tween:Play()
                    task.wait(0.1)
                end
            end
        end
    end
end)
