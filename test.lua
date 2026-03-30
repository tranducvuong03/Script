local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Remote lấy từ script Combat và Mobs
local PetDamage = ReplicatedStorage.Systems.Combat:FindFirstChild("PetDamage")
local RunPetAttack = ReplicatedStorage.Systems.Mobs:FindFirstChild("RunPetAttackModule")

-- Truy cập Module Mobs để điều khiển mục tiêu
local MobsModule = require(ReplicatedStorage.Systems.Mobs)

local RANGE = 60 
local DELAY = 0.1 

task.spawn(function()
    while task.wait(DELAY) do
        -- 1. Tìm Pet của bạn
        local myPet = nil
        for _, obj in pairs(workspace.Mobs:GetChildren()) do
            if obj:GetAttribute("CombatTeamId") == "Player" and obj:GetAttribute("Owner") == player.Name then
                myPet = obj
                break
            end
        end

        if not myPet or not myPet.PrimaryPart then continue end

        -- CHỐT CHẶN QUAN TRỌNG: Xóa mục tiêu AI của Pet để không bị mất Aura
        -- Hàm SetTarget(pet, target, priority, duration, force)
        -- Truyền nil và true ở cuối để ép Pet hủy mục tiêu hiện tại
        MobsModule:SetTarget({model = myPet}, nil, nil, nil, true)

        -- 2. Lấy dữ liệu Skill thật
        local petData = ReplicatedStorage.Mobs:FindFirstChild(myPet.Name)
        if not petData then continue end
        local attacks = petData:FindFirstChild("Attacks"):GetChildren()
        local skill = attacks[1] 
        if not skill then continue end

        local skillName = skill.Name
        local skillData = skill:FindFirstChild("Box") or skill:FindFirstChild("Circle") or skill

        -- 3. Quét Quái vật
        local targets = {}
        for _, target in pairs(workspace.Mobs:GetChildren()) do
            if target:GetAttribute("CombatTeamId") == "Mob" and target:GetAttribute("HP") and target:GetAttribute("HP") > 0 then
                local dist = (myPet.PrimaryPart.Position - target.PrimaryPart.Position).Magnitude
                if dist <= RANGE then
                    table.insert(targets, target)
                end
            end
        end

        -- 4. Thực thi đòn đánh
        if #targets > 0 then
            -- Ép Server chạy đòn đánh ngay lập tức
            RunPetAttack:FireServer(myPet, skillName, targets[1])
            PetDamage:FireServer(myPet, skillName, skillData, targets)
        end
    end
end)
