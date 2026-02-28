-- My Simple GUI - No Library, chỉ built-in Roblox
-- Tạo bởi: B - Dungeon Heroes Auto Chest

local player = game.Players.LocalPlayer
local coreGui = game:GetService("CoreGui")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Clear old GUI nếu có (tránh chồng)
for _, gui in pairs(coreGui:GetChildren()) do
    if gui:IsA("ScreenGui") and gui.Name == "MySimpleChestGUI" then
        gui:Destroy()
    end
end

-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MySimpleChestGUI"
screenGui.Parent = coreGui
screenGui.ResetOnSpawn = false

-- Khung chính (Frame)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 180)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Tiêu đề
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Auto Nightmare Chest - By B"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = mainFrame

-- Trạng thái label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 30)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Trạng thái: TẮT"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 16
statusLabel.Parent = mainFrame

-- Toggle Button (bật/tắt auto)
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 40)
toggleButton.Position = UDim2.new(0.1, 0, 0, 70)
toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggleButton.Text = "BẬT AUTO"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20
toggleButton.Parent = mainFrame

-- Manual Button
local manualButton = Instance.new("TextButton")
manualButton.Size = UDim2.new(0.8, 0, 0, 40)
manualButton.Position = UDim2.new(0.1, 0, 0, 120)
manualButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
manualButton.Text = "Mở 5x Ngay"
manualButton.TextColor3 = Color3.fromRGB(255, 255, 255)
manualButton.Font = Enum.Font.SourceSans
manualButton.TextSize = 18
manualButton.Parent = mainFrame

-- Biến auto
getgenv().simpleAutoEnabled = false

-- Hàm cập nhật trạng thái
local function updateStatus()
    statusLabel.Text = "Trạng thái: " .. (getgenv().simpleAutoEnabled and "BẬT" or "TẮT")
    toggleButton.BackgroundColor3 = getgenv().simpleAutoEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(80, 80, 80)
    toggleButton.Text = getgenv().simpleAutoEnabled and "TẮT AUTO" or "BẬT AUTO"
end

-- Toggle logic
toggleButton.MouseButton1Click:Connect(function()
    getgenv().simpleAutoEnabled = not getgenv().simpleAutoEnabled
    updateStatus()
end)

-- Manual open
manualButton.MouseButton1Click:Connect(function()
    pcall(function()
        replicatedStorage.Systems.ChestShop.OpenChest:InvokeServer("NightmareBoosterChest", 5)
    end)
end)

-- Auto loop (nền)
spawn(function()
    while true do
        wait(math.random(90, 110)/100)  -- ~1s random
        if getgenv().simpleAutoEnabled then
            pcall(function()
                replicatedStorage.Systems.ChestShop.OpenChest:InvokeServer("NightmareBoosterChest", 5)
            end)
        end
    end
end)

-- Init
updateStatus()

-- Optional: Làm khung có thể kéo (drag)
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("Simple GUI loaded! Kéo khung để di chuyển. Vào Chest Shop rồi bật auto nhé!")
