local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Remote lấy từ script Combat và Mobs của bạn
local PetDamage = ReplicatedStorage.Systems.Combat:FindFirstChild("PetDamage")
local RunPetAttack = ReplicatedStorage.Systems.Mobs:FindFirstChild("RunPetAttackModule")

local RANGE = 60 
local DELAY = 0.5 

task.spawn(function()
    while task.wait(DELAY) do
        -- 1. Tìm Pet của bạn (CombatTeamId là "Player" và thuộc quyền sở hữu của bạn)
        local myPet = nil
        for _, obj in pairs(workspace.Mobs:GetChildren()) do
            if obj:GetAttribute("CombatTeamId") == "Player" and obj:GetAttribute("Owner") == player.Name then
                myPet = obj
                break
            end
        end

        if not myPet or not myPet.PrimaryPart then continue end

        -- 2. Lấy dữ liệu Skill thật từ ReplicatedStorage
        local petData = ReplicatedStorage.Mobs:FindFirstChild(myPet.Name)
        if not petData then continue end
        local attacks = petData:FindFirstChild("Attacks"):GetChildren()
        local skill = attacks[1] -- Lấy chiêu đầu tiên có sẵn
        if not skill then continue end

        local skillName = skill.Name
        local skillData = skill:FindFirstChild("Box") or skill:FindFirstChild("Circle") or skill

        -- 3. Quét Quái vật (CombatTeamId là "Mob")
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
            -- Kích hoạt Animation và trạng thái tấn công trên Server
            RunPetAttack:FireServer(myPet, skillName, targets[1])
            -- Gửi lệnh gây sát thương thực tế
            PetDamage:FireServer(myPet, skillName, skillData, targets)
        end
    end
end)
