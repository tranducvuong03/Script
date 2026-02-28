local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Dungeon Heroes Hub",
    LoadingTitle = "DH Auto Chest",
    LoadingSubtitle = "by Grok",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DH_Hub",
        FileName = "Config"
    },
    KeySystem = false
})

local Tab = Window:CreateTab("Main", 4483362458)

local Section = Tab:CreateSection("Auto Nightmare Booster Chest")

-- Status text (hiển thị trạng thái hiện tại)
local StatusLabel = Tab:CreateLabel("Trạng thái: Skip Anim OFF | Auto Open OFF")

-- Toggle Skip Animation (mặc định OFF)
local ToggleSkip = Tab:CreateToggle({
    Name = "Skip Animation (Instant)",
    CurrentValue = false,
    Flag = "SkipAnim",
    Callback = function(Value)
        getgenv().SkipEnabled = Value
        Rayfield:Notify({
            Title = "Skip Animation",
            Content = Value and "BẬT - Anim chạy siêu nhanh!" or "TẮT",
            Duration = 2
        })
        UpdateStatus()
    end,
})

-- Toggle Auto Open (mặc định OFF)
local ToggleAuto = Tab:CreateToggle({
    Name = "Auto Open 5x Nightmare Booster",
    CurrentValue = false,
    Flag = "AutoOpen",
    Callback = function(Value)
        getgenv().AutoEnabled = Value
        Rayfield:Notify({
            Title = "Auto Open",
            Content = Value and "BẬT - Mở 5x mỗi 1 giây!" or "TẮT auto",
            Duration = 2
        })
        UpdateStatus()
    end,
})

-- Nút Manual Open
local ButtonManual = Tab:CreateButton({
    Name = "Mở 5x Nightmare Booster Ngay",
    Callback = function()
        pcall(function()
            game:GetService("ReplicatedStorage").Systems.ChestShop.OpenChest:InvokeServer("NightmareBoosterChest", 5)
        end)
        Rayfield:Notify({
            Title = "Manual",
            Content = "Đã gọi mở 5x Nightmare Booster!",
            Duration = 2
        })
    end,
})

-- Nút Stop All
local ButtonStopAll = Tab:CreateButton({
    Name = "TẮT TẤT CẢ (Stop All)",
    Callback = function()
        getgenv().SkipEnabled = false
        getgenv().AutoEnabled = false
        ToggleSkip:Set(false)
        ToggleAuto:Set(false)
        Rayfield:Notify({
            Title = "Stop All",
            Content = "Đã tắt Skip Anim và Auto Open!",
            Duration = 3
        })
        UpdateStatus()
    end,
})

-- Hàm cập nhật status label
local function UpdateStatus()
    local skipStatus = getgenv().SkipEnabled and "ON" or "OFF"
    local autoStatus = getgenv().AutoEnabled and "ON" or "OFF"
    StatusLabel:Set("Trạng thái: Skip Anim " .. skipStatus .. " | Auto Open " .. autoStatus)
end

-- Skip anim logic
local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
    if not getgenv().SkipEnabled then return end
    for _, obj in workspace:GetDescendants() do
        if obj:IsA("AnimationTrack") and obj.IsPlaying then
            pcall(function() obj:AdjustSpeed(100) end)
        end
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("AnimationTrack") then
        obj:GetPropertyChangedSignal("IsPlaying"):Connect(function()
            if obj.IsPlaying and getgenv().SkipEnabled then
                pcall(function() obj:AdjustSpeed(100) end)
            end
        end)
    end
end)

-- Kill Tween
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    if getnamecallmethod() == "Play" and self.ClassName == "Tween" then
        self:Cancel()
        if self.Instance and self.Goal then
            for prop, val in self.Goal do
                pcall(function() self.Instance[prop] = val end)
            end
        end
        return
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- Auto loop
spawn(function()
    while wait(1) do
        if getgenv().AutoEnabled then
            pcall(function()
                game:GetService("ReplicatedStorage").Systems.ChestShop.OpenChest:InvokeServer("NightmareBoosterChest", 5)
            end)
        end
    end
end)

-- Khởi tạo mặc định OFF
getgenv().SkipEnabled = false
getgenv().AutoEnabled = false
UpdateStatus()

Rayfield:Notify({
    Title = "Hub Loaded!",
    Content = "Tất cả tính năng mặc định OFF. Mở Nightmare Shop rồi bật toggle nếu cần!",
    Duration = 5
})
