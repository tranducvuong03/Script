local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
-- Tia sét (RemoteEvent) dùng để tấn công
local attackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Mutation"):WaitForChild("Attack")

local weaponID = "Lannister" -- Vũ khí bạn đang dùng

RunService.Stepped:Connect(function()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    -- Folder chứa quái vật Mutations
    local mutationsFolder = workspace:FindFirstChild("Mutations")
    if not mutationsFolder then return end
    
    for _, monster in pairs(mutationsFolder:GetChildren()) do
        local humanoid = monster:FindFirstChildWhichIsA("Humanoid")
        
        -- Chỉ xử lý quái còn sống
        if humanoid and humanoid.Health > 0 then
            local attackHitbox = monster:FindFirstChild("AttackHitbox") --
            if attackHitbox then
                local headModel = attackHitbox:FindFirstChild("Head") -- Đây là Model
                if headModel then
                    -- FIX LỖI: Truy cập vào Part 'Head' thực sự bên trong Model
                    local realHeadPart = headModel:FindFirstChild("Head") 
                    
                    if realHeadPart and realHeadPart:IsA("BasePart") then
                        -- 1. DỊCH CHUYỂN HITBOX: Đưa đầu quái về phía trước mặt bạn 3 studs
                        realHeadPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                        
                        -- 2. KILL AURA: Gửi tín hiệu tấn công lên Server
                        -- Tham số: (Nạn nhân, ID vũ khí, Tên bộ phận trúng đòn)
                        attackRemote:FireServer(monster, weaponID, realHeadPart.Name)
                    end
                end
            end
        end
    end
end)
