-- CLEAR OLD RAYFIELD (fix multiple GUI + toggle không click)
for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if gui:IsA("ScreenGui") and (gui.Name:find("Rayfield") or gui.Name:find("RayfieldInterfaceSuite")) then
        gui:Destroy()
    end
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Dungeon Heroes Hub v2 (Fixed)",
    LoadingTitle = "DH Auto Chest",
    LoadingSubtitle = "by Grok - Optimized",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DH_Hub",
        FileName = "Config"
    },
    KeySystem = false
})

local Tab = Window:CreateTab("Main", 4483362458)
local Section = Tab:CreateSection("Auto Nightmare Booster Chest")

-- Status text
local StatusLabel = Tab:CreateLabel("Trạng thái: Skip Anim OFF | Auto Open OFF")

-- Hàm UpdateStatus (di chuyển lên trước cho an toàn)
local function UpdateStatus()
    local skipStatus = getgenv().SkipEnabled and "ON" or "OFF"
    local autoStatus = getgenv().AutoEnabled and "ON" or "OFF"
    StatusLabel:Set("Trạng thái: Skip Anim " .. skipStatus .. " | Auto Open " .. autoStatus)
end

-- Toggle Skip Animation (OPTIMIZED - không lag nữa)
local ToggleSkip = Tab:CreateToggle({
    Name = "Skip Animation (Instant - No Lag)",
    CurrentValue = false,
    Flag = "SkipAnim",
    Callback = function(Value)
        getgenv().SkipEnabled = Value
        if Value then
            -- One-time scan existing anims (nhanh, chỉ 1 lần)
            for _, obj in workspace:GetDescendants() do
                if obj:IsA("AnimationTrack") and obj.IsPlaying then
                    pcall(function() obj:AdjustSpeed(100) end)
                end
            end
        end
        Rayfield:Notify({
            Title = "Skip Animation",
            Content = Value and "BẬT - Siêu nhanh & NO LAG!" or "TẮT",
            Duration = 2
        })
        UpdateStatus()
    end,
})

-- Toggle Auto Open
local ToggleAuto = Tab:CreateToggle({
    Name = "Auto Open 5x Nightmare Booster (1s)",
    CurrentValue = false,
    Flag = "AutoOpen",
    Callback = function(Value)
        getgenv().AutoEnabled = Value
        Rayfield:Notify({
            Title = "Auto Open",
            Content = Value and "BẬT - Mở 5x mỗi giây!" or "TẮT",
            Duration = 2
        })
        UpdateStatus()
    end,
})

-- Manual
local ButtonManual = Tab:CreateButton({
    Name = "Mở 5x Ngay (Manual)",
    Callback = function()
        pcall(function()
            game:GetService("ReplicatedStorage").Systems.ChestShop.OpenChest:InvokeServer("NightmareBoosterChest", 5)
        end)
        Rayfield:Notify({Title = "Manual", Content = "Đã mở 5x!", Duration = 2})
    end,
})

-- Stop All
local ButtonStopAll = Tab:CreateButton({
    Name = "STOP TẤT CẢ",
    Callback = function()
        getgenv().SkipEnabled = false
        getgenv().AutoEnabled = false
        ToggleSkip:Set(false)
        ToggleAuto:Set(false)
        Rayfield:Notify({Title = "Stopped", Content = "Tắt hết!", Duration = 3})
        UpdateStatus()
    end,
})

-- OPTIMIZED Skip Anim Logic (NO LAG)
local function SpeedAnim(obj)
    if obj:IsA("AnimationTrack") then
        if obj.IsPlaying then
            pcall(function() obj:AdjustSpeed(100) end)
        end
        obj:GetPropertyChangedSignal("IsPlaying"):Connect(function()
            if obj.IsPlaying and getgenv().SkipEnabled then
                pcall(function() obj:AdjustSpeed(100) end)
            end
        end)
    end
end

workspace.DescendantAdded:Connect(SpeedAnim)  -- Global cho new anims

-- Kill Tween (giữ nguyên, tốt)
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    if getnamecallmethod() == "Play" and self.ClassName == "Tween" then
        self:Cancel()
        if self.Instance and self.Goal then
            for prop, val in pairs(self.Goal) do  -- pairs thay vì in (fix nhỏ)
                pcall(function() self.Instance[prop] = val end)
            end
        end
        return
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- Auto Loop (thêm random nhẹ anti-detect)
spawn(function()
    while wait(math.random(80,120)/100) do  -- ~1s random
        if getgenv().AutoEnabled then
            pcall(function()
                game:GetService("ReplicatedStorage").Systems.ChestShop.OpenChest:InvokeServer("NightmareBoosterChest", 5)
            end)
        end
    end
end)

-- Init
getgenv().SkipEnabled = false
getgenv().AutoEnabled = false
UpdateStatus()

Rayfield:Notify({
    Title = "Hub v2 Loaded! ✅",
    Content = "Fixed lag + multiple GUI. Vào Chest Shop → Bật Auto Open farm ngay!",
    Duration = 5
})
