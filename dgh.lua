local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")

-- BIẾN CẤU HÌNH
local AuraSettings = { Enabled = false, Range = 20 }
local FarmSettings = { AutoFly = false, Speed = 50, Height = 5 }
local SelectedConfig = "Default"

-- Khởi tạo Window
local Window = Rayfield:CreateWindow({
   Name = "Uranus Hub",
   LoadingTitle = "Fixing Callback Errors...",
   LoadingSubtitle = "by Uranus",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "UranusConfigs", 
      FileName = "MainConfig"
   },
   KeybindSource = "LeftControl"
})

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MobsFolder = workspace:WaitForChild("Mobs")
local PlayerAttackRemote = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Combat"):WaitForChild("PlayerAttack")

-----------------------------------------------------------
-- HÀM KIỂM TRA MỤC TIÊU (MỚI: DÙNG ATTRIBUTE)
-----------------------------------------------------------
local function isValidMob(mob)
    if not mob or not mob.Parent then return false end
    
    -- Kiểm tra Attribute theo phát hiện của bạn
    local teamId = mob:GetAttribute("CombatTeamId")
    local hum = mob:FindFirstChildOfClass("Humanoid")
    
    -- Chỉ chấp nhận nếu là Mob và còn sống
    if teamId == "Mob" then
        if not hum or hum.Health > 0 then
            return true
        end
    end
    return false
end

-----------------------------------------------------------
-- HÀM HỖ TRỢ FILE (AN TOÀN)
-----------------------------------------------------------
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
    return (success and #files > 0) and files or {"No Configs Found"}
end

-----------------------------------------------------------
-- LOGIC AURA (CẬP NHẬT THEO ATTRIBUTE)
-----------------------------------------------------------
local function getAllTargetsInRange()
    local targets = {}
    local char = Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return targets end
    local myPos = char.HumanoidRootPart.Position

    for _, mob in pairs(MobsFolder:GetChildren()) do
        if isValidMob(mob) then -- Kiểm tra CombatTeamId tại đây
            local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
            if root then
                local dist = (root.Position - myPos).Magnitude
                if dist <= AuraSettings.Range then
                    table.insert(targets, mob)
                end
            end
        end
    end
    return targets
end

-----------------------------------------------------------
-- TAB: COMBAT & FARM
-----------------------------------------------------------
local MainTab = Window:CreateTab("Combat", 4483362458)
MainTab:CreateToggle({ Name = "Auto Aura Kill", CurrentValue = false, Flag = "AuraToggle", Callback = function(Value) AuraSettings.Enabled = Value end })
MainTab:CreateSlider({ Name = "Aura Range", Range = {0, 400}, Increment = 1, Suffix = "Studs", CurrentValue = 20, Flag = "AuraRangeSlider", Callback = function(Value) AuraSettings.Range = Value end })

local FarmTab = Window:CreateTab("Farm", 4483362458)
FarmTab:CreateToggle({ Name = "Auto Fly to Mob", CurrentValue = false, Flag = "FlyToggle", Callback = function(Value) FarmSettings.AutoFly = Value end })
FarmTab:CreateSlider({ Name = "Fly Speed", Range = {10, 300}, Increment = 5, Suffix = "Speed", CurrentValue = 50, Flag = "FlySpeedSlider", Callback = function(Value) FarmSettings.Speed = Value end })
FarmTab:CreateSlider({ Name = "Fly Height", Range = {-10, 50}, Increment = 1, Suffix = "Studs", CurrentValue = 5, Flag = "FlyHeightSlider", Callback = function(Value) FarmSettings.Height = Value end })

-----------------------------------------------------------
-- TAB: SETTINGS
-----------------------------------------------------------
local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateSection("Config Management")

SettingsTab:CreateInput({
   Name = "Config Name",
   PlaceholderText = "Nhập tên file...",
   Callback = function(Text) SelectedConfig = Text end,
})

SettingsTab:CreateButton({
   Name = "Save / Create Config",
   Callback = function()
      if SelectedConfig == "" or SelectedConfig == "Default" then
          Rayfield:Notify({Title = "Lỗi", Content = "Vui lòng nhập tên Config hợp lệ!", Duration = 3})
      else
          if not isfolder("UranusConfigs") then makefolder("UranusConfigs") end
          Rayfield:SaveConfiguration() 
          local oldPath = "UranusConfigs/MainConfig.json"
          local newPath = "UranusConfigs/" .. SelectedConfig .. ".json"
          if isfile(oldPath) then
              writefile(newPath, readfile(oldPath))
              Rayfield:Notify({Title = "Thành công", Content = "Đã lưu config: " .. SelectedConfig, Duration = 2})
          end
      end
   end,
})

local ConfigDropdown = SettingsTab:CreateDropdown({
   Name = "Chọn Config có sẵn",
   Options = safeListFiles(),
   CurrentOption = "",
   Callback = function(Option) SelectedConfig = Option end,
})

SettingsTab:CreateButton({
   Name = "Làm mới danh sách",
   Callback = function() ConfigDropdown:Set(safeListFiles()) end,
})

SettingsTab:CreateButton({
   Name = "Tải Config đã chọn",
   Callback = function()
      if SelectedConfig ~= "" and SelectedConfig ~= "No Configs Found" then
         Rayfield.ConfigurationSaving.FileName = SelectedConfig
         Rayfield:LoadConfiguration()
         Rayfield:Notify({Title = "Uranus Hub", Content = "Đã tải: " .. SelectedConfig, Duration = 2})
      else
         Rayfield:Notify({Title = "Lỗi", Content = "Chưa chọn Config hợp lệ!", Duration = 3})
      end
   end,
})

-----------------------------------------------------------
-- VÒNG LẶP THỰC THI (LOOPS)
-----------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.2)
        if AuraSettings.Enabled then
            local nearbyMobs = getAllTargetsInRange()
            if #nearbyMobs > 0 then
                PlayerAttackRemote:FireServer(unpack({nearbyMobs}))
            end
        end
    end
end)

local currentTargetMob = nil 

-- Vòng lặp Fly
task.spawn(function()
    local currentTween = nil
    
    while true do
        task.wait(0.1)
        
        if FarmSettings.AutoFly then
            local char = Players.LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            -- 1. KIỂM TRA MỤC TIÊU CŨ (DÙNG ATTRIBUTE)
            local isTargetValid = isValidMob(currentTargetMob)

            -- 2. TÌM QUÁI MỚI NẾU CẦN
            if not isTargetValid then
                currentTargetMob = nil
                local dist = math.huge
                
                for _, m in pairs(MobsFolder:GetChildren()) do
                    if isValidMob(m) then
                        local mRoot = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                        if mRoot then
                            local d = (mRoot.Position - root.Position).Magnitude
                            if d < dist then 
                                dist = d 
                                currentTargetMob = m 
                            end
                        end
                    end
                end
                if currentTween then currentTween:Cancel() end
            end
            
            -- 3. XỬ LÝ DI CHUYỂN
            if currentTargetMob then
                local tRoot = currentTargetMob:FindFirstChild("HumanoidRootPart") or currentTargetMob.PrimaryPart
                local tPos = tRoot.CFrame * CFrame.new(0, FarmSettings.Height, 0)
                
                local distanceToPoint = (root.Position - tPos.Position).Magnitude

                if distanceToPoint > 3 then
                    if not currentTween or (currentTween.PlaybackState ~= Enum.PlaybackState.Playing) then
                        local duration = distanceToPoint / FarmSettings.Speed
                        currentTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = tPos})
                        currentTween:Play()
                    end
                end
            end
        else
            if currentTween then 
                currentTween:Cancel() 
                currentTween = nil 
            end
            currentTargetMob = nil
        end
    end
end)
