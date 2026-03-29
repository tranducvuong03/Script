local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")

-- BIẾN CẤU HÌNH
local AuraSettings = { Enabled = false, Range = 20 }
local FarmSettings = { AutoFly = false, Speed = 50, Height = 5 }
local SelectedConfig = "Default" -- Đặt mặc định để tránh nil lỗi callback

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
-- LOGIC AURA GỐC (GIỮ NGUYÊN)
-----------------------------------------------------------
local function getAllTargetsInRange()
    local targets = {}
    local char = Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return targets end
    local myPos = char.HumanoidRootPart.Position
    for _, mob in pairs(MobsFolder:GetChildren()) do
        local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
        if root then
            local dist = (root.Position - myPos).Magnitude
            if dist <= AuraSettings.Range then
                local hum = mob:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health > 0 then table.insert(targets, mob) end
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
-- TAB: SETTINGS (FIXED CALLBACK)
-----------------------------------------------------------
local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateSection("Config Management")

-- Ô nhập tên Config
SettingsTab:CreateInput({
   Name = "Config Name",
   PlaceholderText = "Nhập tên file...",
   Callback = function(Text)
      SelectedConfig = Text
   end,
})

-- Nút Tạo/Ghi đè
SettingsTab:CreateButton({
   Name = "Save / Create Config",
   Callback = function()
      if SelectedConfig == "" or SelectedConfig == "Default" then
          Rayfield:Notify({Title = "Lỗi", Content = "Vui lòng nhập tên Config hợp lệ!", Duration = 3})
      else
          -- Thay vì ghi đè biến hệ thống, hãy kiểm tra tính tồn tại của folder
          if not isfolder("UranusConfigs") then makefolder("UranusConfigs") end
          
          -- Một số phiên bản Rayfield cũ không hỗ trợ đổi FileName runtime
          -- Bạn nên dùng tên file cố định hoặc viết hàm ghi đè thủ công qua writefile
          Rayfield:SaveConfiguration() 
          
          -- Sau khi lưu, đổi tên file vừa tạo trong folder (Trick cho Rayfield)
          local oldPath = "UranusConfigs/MainConfig.json"
          local newPath = "UranusConfigs/" .. SelectedConfig .. ".json"
          if isfile(oldPath) then
              writefile(newPath, readfile(oldPath))
              Rayfield:Notify({Title = "Thành công", Content = "Đã lưu config: " .. SelectedConfig, Duration = 2})
          end
      end
   end,
})

-- Dropdown chọn file
local ConfigDropdown = SettingsTab:CreateDropdown({
   Name = "Chọn Config có sẵn",
   Options = safeListFiles(),
   CurrentOption = "",
   Callback = function(Option)
      SelectedConfig = Option
   end,
})

SettingsTab:CreateButton({
   Name = "Làm mới danh sách",
   Callback = function()
      ConfigDropdown:Set(safeListFiles())
   end,
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
                -- LOGIC GỐC CỦA BẠN (Dùng unpack)
                PlayerAttackRemote:FireServer(unpack({nearbyMobs}))
            end
        end
    end
end)

-- Vòng lặp Fly
task.spawn(function()
    local currentTween = nil
    
    while true do
        task.wait(0.1) -- Tần suất kiểm tra mục tiêu
        
        if FarmSettings.AutoFly then
            local char = Players.LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            local targetMob = nil
            local dist = math.huge
            
            -- DUYỆT TÌM MỤC TIÊU ƯU TIÊN
            -- DUYỆT TÌM MỤC TIÊU ƯU TIÊN (CHỈ CHỌN MOB CÓ DROPS HOẶC BOSS)
            for _, m in pairs(MobsFolder:GetChildren()) do
                local mRoot = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                local hum = m:FindFirstChildOfClass("Humanoid")
                
                if mRoot and (not hum or hum.Health > 0) then
                    -- KIỂM TRA OBJECT BÊN TRONG (FOLDER/VALUE/PART)
                    local hasDrops = m:FindFirstChild("Drops")
                    local isBoss   = m:FindFirstChild("BOSS") -- Tìm object tên BOSS bên trong Mob
                    
                    -- Nếu thỏa mãn 1 trong 2 điều kiện thì mới bay tới
                    if hasDrops or isBoss then
                        local d = (mRoot.Position - root.Position).Magnitude
                        if d < dist then 
                            dist = d 
                            targetMob = m 
                        end
                    end
                end
            end
            
            -- XỬ LÝ DI CHUYỂN (TWEEN)
            if targetMob then
                local tRoot = targetMob:FindFirstChild("HumanoidRootPart") or targetMob.PrimaryPart
                -- Tính toán vị trí bay (tạo khoảng cách Height phía trên đầu quái)
                local tPos = tRoot.CFrame * CFrame.new(0, FarmSettings.Height, 0)
                
                -- Chỉ di chuyển nếu khoảng cách > 3 studs để tránh rung lắc
                if (root.Position - tPos.Position).Magnitude > 3 then
                    local duration = (root.Position - tPos.Position).Magnitude / FarmSettings.Speed
                    
                    -- Hủy tween cũ trước khi tạo cái mới (Tránh lỗi callback/giật lag)
                    if currentTween then currentTween:Cancel() end
                    
                    currentTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = tPos})
                    currentTween:Play()
                end
            end
        else
            -- Nếu tắt AutoFly, dừng ngay Tween đang chạy
            if currentTween then 
                currentTween:Cancel() 
                currentTween = nil 
            end
        end
    end
end)
