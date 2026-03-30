local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local PetDamage = ReplicatedStorage.Systems.Combat:FindFirstChild("PetDamage")
local RunPetAttack = ReplicatedStorage.Systems.Mobs:FindFirstChild("RunPetAttackModule")

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

        -- Khóa Pet cạnh chủ để tránh AI tự chạy đi làm mất Aura
        myPet.PrimaryPart.CFrame = char.PrimaryPart.CFrame * CFrame.new(0, 0, 3)

        -- 2. Lấy danh sách quái trong tầm
        local targets = {}
        for _, target in pairs(workspace.Mobs:GetChildren()) do
            if target:GetAttribute("CombatTeamId") == "Mob" and target:GetAttribute("HP") and target:GetAttribute("HP") > 0 then
                local dist = (myPet.PrimaryPart.Position - target.PrimaryPart.Position).Magnitude
                if dist <= RANGE then
                    table.insert(targets, target)
                end
            end
        end

        -- 3. LOGIC QUÉT SKILL (Fix lỗi hồi chiêu)
        if #targets > 0 then
            local petData = ReplicatedStorage.Mobs:FindFirstChild(myPet.Name)
            if petData and petData:FindFirstChild("Attacks") then
                -- Quét qua TẤT CẢ các skill mà Pet có
                for _, skill in pairs(petData.Attacks:GetChildren()) do
                    local skillName = skill.Name
                    local skillData = skill:FindFirstChild("Box") or skill:FindFirstChild("Circle") or skill
                    
                    -- Gửi lệnh đánh cho mỗi skill. 
                    -- Nếu skill 1 đang hồi, Server sẽ bỏ qua, nhưng skill 2 hoặc skill đánh thường (Basic) sẽ trúng.
                    RunPetAttack:FireServer(myPet, skillName, targets[1])
                    PetDamage:FireServer(myPet, skillName, skillData, targets)
                end
            end
        end
    end
end)
