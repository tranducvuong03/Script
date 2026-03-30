local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local PetDamage = ReplicatedStorage.Systems.Combat:FindFirstChild("PetDamage")
local RunPetAttack = ReplicatedStorage.Systems.Mobs:FindFirstChild("RunPetAttackModule")
local MobsModule = require(ReplicatedStorage.Systems.Mobs)

local RANGE = 65 
local DELAY = 0.1 

task.spawn(function()
    while task.wait(DELAY) do
        local char = player.Character
        if not char or not char.PrimaryPart then continue end

        -- 1. Tìm Pet
        local myPet = nil
        for _, obj in pairs(workspace.Mobs:GetChildren()) do
            if obj:GetAttribute("CombatTeamId") == "Player" and obj:GetAttribute("Owner") == player.Name then
                myPet = obj
                break
            end
        end

        if not myPet or not myPet.PrimaryPart then continue end

        -- 2. KHÓA CỨNG PET (Anti-Chase): 
        -- Ép Pet luôn đứng cạnh bạn để AI không thể tự chạy đi đánh con khác làm mất Aura
        myPet.PrimaryPart.CFrame = char.PrimaryPart.CFrame * CFrame.new(0, 0, 3)
        myPet.PrimaryPart.Velocity = Vector3.new(0, 0, 0) -- Triệt tiêu lực đẩy của AI

        -- 3. Xóa mục tiêu hiện tại trong bộ nhớ Module
        MobsModule:SetTarget({model = myPet}, nil, nil, nil, true)

        -- 4. Lấy Skill thật
        local petData = ReplicatedStorage.Mobs:FindFirstChild(myPet.Name)
        if not petData then continue end
        local attacks = petData:FindFirstChild("Attacks"):GetChildren()
        local skill = attacks[1]
        if not skill then continue end

        local skillName = skill.Name
        local skillData = skill:FindFirstChild("Box") or skill:FindFirstChild("Circle") or skill

        -- 5. Quét Quái vật
        local targets = {}
        for _, target in pairs(workspace.Mobs:GetChildren()) do
            if target:GetAttribute("CombatTeamId") == "Mob" and target:GetAttribute("HP") and target:GetAttribute("HP") > 0 then
                local dist = (myPet.PrimaryPart.Position - target.PrimaryPart.Position).Magnitude
                if dist <= RANGE then
                    table.insert(targets, target)
                end
            end
        end

        -- 6. Thực thi đòn đánh AOE (Đánh nhiều mục tiêu cùng lúc)
        if #targets > 0 then
            RunPetAttack:FireServer(myPet, skillName, targets[1])
            PetDamage:FireServer(myPet, skillName, skillData, targets)
        end
    end
end)
