local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Khởi tạo Window
local Window = Rayfield:CreateWindow({
   Name = "Uranus Hub",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "by Uranus",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "UranusConfigs", 
      FileName = "AuraSettings"
   }
})

-- Biến lưu trạng thái
local _G = {
    AuraPlayer = false,
    AuraPet = false,
    AuraRange = 50,
    AttackSpeed = 0.4
}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerAttackRemote = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Combat"):WaitForChild("PlayerAttack")
local PetAttackRemote = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Mobs"):WaitForChild("RunPetAttackModule")
local MobsFolder = workspace:WaitForChild("Mobs")

-- Hàm lấy danh sách quái trong tầm
local function getNearbyMobs()
    local targets = {}
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return targets end
    
    for _, mob in pairs(MobsFolder:GetChildren()) do
        local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
        if root then
            local dist = (root.Position - char.HumanoidRootPart.Position).Magnitude
            if dist <= _G.AuraRange then
                local hum = mob:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health > 0 then
                    table.insert(targets, mob)
                end
            end
        end
    end
    return targets
end

-- Tab Chính
local MainTab = Window:CreateTab("Aura Settings", 4483362458)

-- Bật/Tắt Aura Player
MainTab:CreateToggle({
   Name = "Auto Player Attack",
   CurrentValue = false,
   Callback = function(Value)
      _G.AuraPlayer = Value
   end,
})

-- Bật/Tắt Aura Pet
MainTab:CreateToggle({
   Name = "Auto Pet Attack (Sack of Torment)",
   CurrentValue = false,
   Callback = function(Value)
      _G.AuraPet = Value
   end,
})

-- Thanh kéo khoảng cách (Max 200)
MainTab:CreateSlider({
   Name = "Aura Range (Khoảng cách)",
   Range = {0, 200},
   Increment = 5,
   Suffix = "Studs",
   CurrentValue = 50,
   Flag = "RangeSlider", 
   Callback = function(Value)
      _G.AuraRange = Value
   end,
})

-- Vòng lặp thực thi (Main Loop)
task.spawn(function()
    while task.wait(_G.AttackSpeed) do
        local targets = getNearbyMobs()
        if #targets > 0 then
            -- Thực thi Aura Player
            if _G.AuraPlayer then
                PlayerAttackRemote:FireServer({targets})
            end
            
            -- Thực thi Aura Pet (Target con gần nhất)
            if _G.AuraPet then
                local args = {
                    targets[1],
                    "sack of torment",
                    Instance.new("Model")
                }
                PetAttackRemote:FireServer(unpack(args))
            end
        end
    end
end)

Rayfield:Notify({
   Title = "Thành công!",
   Content = "Script Aura đã sẵn sàng. Chúc bạn farm vui vẻ!",
   Duration = 5,
   Image = 4483362458,
})
