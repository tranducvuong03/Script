local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Khởi tạo Window với tên Uranus Hub
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

-- Biến điều khiển
local AuraSettings = {
    Enabled = false,
    Range = 20
}

-- SERVICES (Giữ nguyên logic đang hoạt động của bạn)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MobsFolder = workspace:WaitForChild("Mobs")
local PlayerAttackRemote = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Combat"):WaitForChild("PlayerAttack")

-- HÀM LOGIC QUÉT MỤC TIÊU
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

-- TẠO TAB
local MainTab = Window:CreateTab("Main", 4483362458)

-- Nút Bật/Tắt
MainTab:CreateToggle({
   Name = "Auto Aura Kill",
   CurrentValue = false,
   Callback = function(Value)
      AuraSettings.Enabled = Value
      if Value then
          Rayfield:Notify({Title = "Uranus Hub", Content = "Aura đã được KÍCH HOẠT!", Duration = 2})
      else
          Rayfield:Notify({Title = "Uranus Hub", Content = "Aura đã TẮT!", Duration = 2})
      end
   end,
})

-- Thanh kéo khoảng cách
MainTab:CreateSlider({
   Name = "Aura Range",
   Range = {0, 200},
   Increment = 1,
   Suffix = "Studs",
   CurrentValue = 20,
   Callback = function(Value)
      AuraSettings.Range = Value
   end,
})

-- function chạy
task.spawn(function()
    print("Uranus Hub loaded successfully!")
    while task.wait(0.2) do 
        if AuraSettings.Enabled then
            local nearbyMobs = getAllTargetsInRange()
            
            if #nearbyMobs > 0 then
                local args = {
                    nearbyMobs 
                }
                PlayerAttackRemote:FireServer(unpack(args))
            end
        end
    end
end)
