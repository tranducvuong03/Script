local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Các Remote chuẩn từ script của bạn
local PetDamage = ReplicatedStorage.Systems.Combat:FindFirstChild("PetDamage")
local RunPetAttack = ReplicatedStorage.Systems.Mobs:FindFirstChild("RunPetAttackModule")

local ATTACK_RANGE = 55 -- Để 55 cho an toàn (Server giới hạn 60)
local ATTACK_SPEED = 0.5 

task.spawn(function()
    while task.wait(ATTACK_SPEED) do
        -- 1. Tìm Pet của bạn (Lọc theo attribute Player)
        local myPet = nil
        for _, mob in pairs(workspace.Mobs:GetChildren()) do
            if mob:GetAttribute("Player") == player.Name and not mob:GetAttribute("Minion") then
                myPet = mob
                break
            end
        end

        if not myPet or not myPet.PrimaryPart then continue end

        -- 2. Tìm chiêu thức hợp lệ của Pet trong ReplicatedStorage
        local petData = ReplicatedStorage.Mobs:FindFirstChild(myPet.Name)
        local attacks = petData and petData:FindFirstChild("Attacks"):GetChildren()
        local skill = attacks and attacks[1] -- Lấy chiêu đầu tiên
        
        if not skill then continue end

        -- 3. Quét quái vật (CombatTeamId == "Mob")
        for _, target in pairs(workspace.Mobs:GetChildren()) do
            if target:GetAttribute("CombatTeamId") == "Mob" and target:GetAttribute("HP") > 0 then
                local dist = (myPet.PrimaryPart.Position - target.PrimaryPart.Position).Magnitude
                
                if dist <= ATTACK_RANGE then
                    -- Gửi lệnh thực thi đòn đánh (Cấu trúc chuẩn theo line 851 của script Mobs)
                    -- Tham số: PetModel, TênSkill, TargetModel
                    RunPetAttack:FireServer(myPet, skill.Name, target)
                    
                    -- Gửi lệnh gây sát thương (Cấu trúc chuẩn theo script Combat)
                    -- Tham số: PetModel, TênSkill, FolderSkill, {TargetTable}
                    local skillData = skill:FindFirstChild("Box") or skill:FindFirstChild("Circle") or skill
                    PetDamage:FireServer(myPet, skill.Name, skillData, {target})
                    
                    -- Nếu bạn muốn Aura đánh lan (AOE), đừng break. Nếu đánh đơn, hãy break.
                    break 
                end
            end
        end
    end
end)
