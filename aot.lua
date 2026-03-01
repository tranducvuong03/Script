local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local attackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Mutation"):WaitForChild("Attack")

-- Cấu hình
local weaponID = "Lannister" -- Vũ khí mạnh nhất của bạn
local killAuraEnabled = true
local teleportHitboxEnabled = true

-- Hàm thực hiện Aura tấn công
local function fireAura(targetModel, partName)
    -- Gửi gói tin tấn công chính xác như mã nguồn thanh kiếm yêu cầu
    -- Tham số: (Nạn nhân, ID vũ khí, Bộ phận trúng đòn)
    attackRemote:FireServer(targetModel, weaponID, partName)
end

-- Vòng lặp chính xử lý Hitbox và Aura
RunService.Stepped:Connect(function()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local myPos = player.Character.HumanoidRootPart.Position
    local mutationsFolder = workspace:FindFirstChild("Mutations")
    
    if mutationsFolder then
        for _, monster in pairs(mutationsFolder:GetChildren()) do
            -- Kiểm tra quái còn sống
            local humanoid = monster:FindFirstChildWhichIsA("Humanoid")
            if humanoid and humanoid.Health > 0 then
                
                -- 1. DỊCH CHUYỂN HITBOX (Mục tiêu: Head trong AttackHitbox)
                -- Dựa trên ảnh image_bcdde5.png của bạn
                local hitboxRoot = monster:FindFirstChild("AttackHitbox")
                if hitboxRoot then
                    local headHitbox = hitboxRoot:FindFirstChild("Head")
                    if headHitbox and teleportHitboxEnabled then
                        -- Đưa hitbox đầu về vị trí của bạn (cách 3 studs phía trước)
                        local targetPos = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                        headHitbox.CFrame = targetPos
                    end
                end

                -- 2. KÍCH HOẠT AURA
                if killAuraEnabled then
                    -- Tấn công vào bộ phận Head của quái
                    fireAura(monster, "Head")
                end
            end
        end
    end
end)

print("⚡ Script Aura & Hitbox Teleport đã kích hoạt!")
