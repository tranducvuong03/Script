-- Biến điều khiển
getgenv().AutoAuraPet = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

-- Tìm một con quái bất kỳ làm "Mồi" nếu TargetDummy không tồn tại
local function getDummy()
    return workspace:WaitForChild("Mobs"):FindFirstChild("TargetDummy") or workspace:WaitForChild("Mobs"):FindFirstChildOfClass("Model")
end

-- Tìm con Pet thật của bạn (Rất quan trọng)
local function getRealPet()
    -- Thử tìm trong Workspace theo tên bạn
    local pet = workspace:FindFirstChild(lplr.Name .. "'s Pet") or workspace:FindFirstChild("Pets"):FindFirstChild(lplr.Name)
    if not pet then
        -- Nếu không thấy, lấy đại một cái Model nào đó trong Workspace (Bypass check)
        pet = lplr.Character or workspace:FindFirstChildOfClass("Model")
    end
    return pet
end

local function Attack()
    local target = workspace:WaitForChild("Mobs"):FindFirstChild("Nightmare Krampus")
    local dummy = getDummy()
    local myPet = getRealPet()
    
    if target and target:FindFirstChild("HumanoidRootPart") then
        -- LẤY BOX THẬT TỪ STORAGE
        local attackBox = ReplicatedStorage:WaitForChild("Mobs"):WaitForChild("Nightmare Krampus"):WaitForChild("Attacks"):WaitForChild("chain whip"):WaitForChild("Box")

        -- BƯỚC 1: CHẠY MODULE TẤN CÔNG (Dùng Pet thật thay vì Instance.new)
        local runArgs = {
            target,
            "chain whip",
            myPet -- Truyền Pet thật của bạn vào đây
        }
        ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Mobs"):WaitForChild("RunPetAttackModule"):FireServer(unpack(runArgs))

        -- BƯỚC 2: GÂY SÁT THƯƠNG
        local damageArgs = {
            target,
            "chain whip",
            attackBox,
            { target, dummy } -- Đưa cả target và dummy vào mảng hit
        }
        ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Combat"):WaitForChild("PetDamage"):FireServer(unpack(damageArgs))
    end
end

-- Chạy vòng lặp
task.spawn(function()
    warn("Đang thử nghiệm phương pháp Bypass mới...")
    while getgenv().AutoAuraPet do
        local success, err = pcall(Attack)
        if not success then print("Đợi quái xuất hiện...") end
        task.wait(0.2) -- Thử delay chậm lại một chút (5 lần/giây) để server kịp xử lý
    end
end)
