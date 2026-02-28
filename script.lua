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
    KeySystem = false  -- Bật key nếu muốn sau này
})

local Tab = Window:CreateTab("Main", 4483362458)  -- Icon Lucide hoặc Roblox asset id

local Section = Tab:CreateSection("Auto Nightmare Booster Chest")

local ToggleSkip = Tab:CreateToggle({
    Name = "Skip Animation (Instant)",
    CurrentValue = true,
    Flag = "SkipAnim",
    Callback = function(Value)
        getgenv().SkipEnabled = Value
        Rayfield:Notify({
            Title = "Skip Anim",
            Content = Value and "ON - Anim siêu nhanh!" or "OFF",
            Duration = 2
        })
    end,
})

local ToggleAuto = Tab:CreateToggle({
    Name = "Auto Open 5x Nightmare Booster",
    CurrentValue = true,
    Flag = "AutoOpen",
    Callback = function(Value)
        getgenv().AutoEnabled = Value
        Rayfield:Notify({
            Title = "Auto Open",
            Content = Value and "Bắt đầu auto mở 5x mỗi 1s!" or "Tắt auto",
            Duration = 2
        })
    end,
})

local ButtonManual = Tab:CreateButton({
    Name = "Open 5x Nightmare Booster Now",
    Callback = function()
        pcall(function()
            game:GetService("ReplicatedStorage").Systems.ChestShop.OpenChest:InvokeServer("NightmareBoosterChest", 5)
        end)
        Rayfield:Notify({
            Title = "Manual Open",
            Content = "Đã gọi mở 5x Nightmare Booster!",
            Duration = 2
        })
    end,
})

-- Skip anim logic (luôn chạy nếu toggle on)
local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
    if not getgenv().SkipEnabled then return end
    for _, obj in workspace:GetDescendants() do
        if obj:IsA("AnimationTrack") and obj.IsPlaying then
            pcall(function() obj:AdjustSpeed(100) end)
        end
    end
end)

-- Cải tiến: Catch anim mới spawn (tốt hơn cho chest animation)
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("AnimationTrack") then
        obj:GetPropertyChangedSignal("IsPlaying"):Connect(function()
            if obj.IsPlaying and getgenv().SkipEnabled then
                pcall(function() obj:AdjustSpeed(100) end)
            end
        end)
    end
end)

-- Kill Tween (luôn on để skip spin/open/lid animation)
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

-- Auto loop open 5x
spawn(function()
    while wait(1) do
        if getgenv().AutoEnabled then
            pcall(function()
                game:GetService("ReplicatedStorage").Systems.ChestShop.OpenChest:InvokeServer("NightmareBoosterChest", 5)
            end)
        end
    end
end)

-- Init variables (đặt trước để tránh nil)
getgenv().SkipEnabled = true
getgenv().AutoEnabled = true

Rayfield:Notify({
    Title = "Hub Loaded!",
    Content = "Toggle ON/OFF ở tab Main. Mở Nightmare Shop để auto work tốt nhất!",
    Duration = 4
})
 
