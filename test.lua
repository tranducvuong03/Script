-- Thiết lập biến điều khiển
getgenv().AutoAuraPet = true

-- Các biến dịch vụ (Cache để chạy nhanh hơn)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MobsFolder = workspace:WaitForChild("Mobs")

-- Remote Events
local RunPetAttack = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Mobs"):WaitForChild("RunPetAttackModule")
local PetDamage = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Combat"):WaitForChild("PetDamage")

-- Hàm thực thi đòn đánh
local function ExecuteAttack()
    -- Tìm mục tiêu chính (Nightmare Krampus)
    local mainTarget = MobsFolder:FindFirstChild("Nightmare Krampus")
    -- Tìm mục tiêu phụ (TargetDummy - Dùng để bypass check sát thương của game)
    local dummyTarget = MobsFolder:FindFirstChild("TargetDummy")
    
    if mainTarget then
        -- 1. Kích hoạt Animation/Module tấn công của Pet trước
        -- Theo mẫu của bạn: {Target, SkillName, NewModel}
        local runArgs = {
            mainTarget,
            "chain whip",
            Instance.new("Model", nil)
        }
        RunPetAttack:FireServer(unpack(runArgs))

        -- 2. Gửi lệnh gây sát thương ngay sau đó
        -- Theo mẫu của bạn: {Target, SkillName, HitboxBox, {TargetsHit}}
        local damageArgs = {
            mainTarget,
            "chain whip",
            ReplicatedStorage:WaitForChild("Mobs"):WaitForChild("Nightmare Krampus"):WaitForChild("Attacks"):WaitForChild("chain whip"):WaitForChild("Box"),
            { dummyTarget or mainTarget } -- Nếu không thấy Dummy, thử dùng chính nó
        }
        PetDamage:FireServer(unpack(damageArgs))
    end
end

-- Vòng lặp chạy ngầm
task.spawn(function()
    print(">>> Auto Aura Pet: Đã khởi động!")
    while getgenv().AutoAuraPet do
        local success, err = pcall(ExecuteAttack)
        if not success then 
            warn("Lỗi script: " .. err) 
        end
        
        -- Tốc độ đánh (0.1 là 10 lần/giây). 
        -- Nếu vẫn không có dmg, hãy thử tăng lên 0.2 hoặc 0.3 để khớp với animation của game.
        task.wait(0.1) 
    end
    print(">>> Auto Aura Pet: Đã dừng.")
end)
