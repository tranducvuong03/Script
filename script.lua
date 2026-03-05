-- Tạo bởi: B - Dungeon Heroes Auto Chest (Dropdown Version)

local player = game.Players.LocalPlayer
local coreGui = game:GetService("CoreGui")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Clear old GUI
for _, gui in pairs(coreGui:GetChildren()) do
    if gui:IsA("ScreenGui") and (gui.Name == "MySimpleChestGUI" or gui.Name == "ChestDropdownGUI") then
        gui:Destroy()
    end
end

-- Biến cấu hình
getgenv().simpleAutoEnabled = false
getgenv().selectedChest = "NightmareBoosterChest"
local isMinimized = false
local dropdownOpen = false

-- Danh sách Chest
local chestOptions = {
    {Name = "Nightmare", ID = "NightmareBoosterChest", Color = Color3.fromRGB(100, 40, 100)},
    {Name = "Valentines", ID = "ValentinesBoosterChest", Color = Color3.fromRGB(180, 50, 100)},
    {Name = "Ancient", ID = "AncientBoosterChest", Color = Color3.fromRGB(40, 100, 100)} -- Thêm loại thứ 3 ở đây
}

-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MySimpleChestGUI"
screenGui.Parent = coreGui
screenGui.ResetOnSpawn = false

-- Khung chính
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 220)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Tiêu đề
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Multi-Auto Chest - By Uranus"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = mainFrame

-- Nút thu nhỏ
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -30, 0, 0)
minimizeButton.Text = "-"
minimizeButton.Parent = mainFrame

-- Dropdown Button (Nút chính để mở menu)
local dropdownMainBtn = Instance.new("TextButton")
dropdownMainBtn.Size = UDim2.new(0.8, 0, 0, 30)
dropdownMainBtn.Position = UDim2.new(0.1, 0, 0, 40)
dropdownMainBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dropdownMainBtn.Text = "Chọn Chest ▼"
dropdownMainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdownMainBtn.Font = Enum.Font.SourceSans
dropdownMainBtn.TextSize = 16
dropdownMainBtn.Parent = mainFrame

-- Dropdown List Container
local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(0.8, 0, 0, #chestOptions * 30)
listFrame.Position = UDim2.new(0.1, 0, 0, 70)
listFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
listFrame.Visible = false
listFrame.ZIndex = 5
listFrame.Parent = mainFrame

-- Tạo các item trong Dropdown
for i, chest in ipairs(chestOptions) do
    local itemBtn = Instance.new("TextButton")
    itemBtn.Size = UDim2.new(1, 0, 0, 30)
    itemBtn.Position = UDim2.new(0, 0, 0, (i-1) * 30)
    itemBtn.BackgroundColor3 = chest.Color
    itemBtn.Text = chest.Name
    itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    itemBtn.ZIndex = 6
    itemBtn.Parent = listFrame

    itemBtn.MouseButton1Click:Connect(function()
        getgenv().selectedChest = chest.ID
        dropdownMainBtn.Text = "Chest: " .. chest.Name .. " ▼"
        listFrame.Visible = false
        dropdownOpen = false
    end)
end

-- Trạng thái label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 75)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Trạng thái: TẮT"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Parent = mainFrame

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 40)
toggleButton.Position = UDim2.new(0.1, 0, 0, 110)
toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggleButton.Text = "BẬT AUTO"
toggleButton.Parent = mainFrame

-- Manual Button
local manualButton = Instance.new("TextButton")
manualButton.Size = UDim2.new(0.8, 0, 0, 40)
manualButton.Position = UDim2.new(0.1, 0, 0, 160)
manualButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
manualButton.Text = "Mở 5x Ngay"
manualButton.Parent = mainFrame

--- LOGIC HỆ THỐNG ---

-- Mở/Đóng Dropdown
dropdownMainBtn.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    listFrame.Visible = dropdownOpen
end)

-- Thu nhỏ
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    mainFrame.Size = isMinimized and UDim2.new(0, 250, 0, 30) or UDim2.new(0, 250, 0, 220)
    minimizeButton.Text = isMinimized and "+" or "-"
    if isMinimized then listFrame.Visible = false end
end)

local function updateStatus()
    statusLabel.Text = "Trạng thái: " .. (getgenv().simpleAutoEnabled and "BẬT" or "TẮT")
    toggleButton.BackgroundColor3 = getgenv().simpleAutoEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(80, 80, 80)
    toggleButton.Text = getgenv().simpleAutoEnabled and "TẮT AUTO" or "BẬT AUTO"
end

toggleButton.MouseButton1Click:Connect(function()
    getgenv().simpleAutoEnabled = not getgenv().simpleAutoEnabled
    updateStatus()
end)

local function fireChestRemote()
    pcall(function()
        replicatedStorage.Systems.ChestShop.OpenChest:InvokeServer(getgenv().selectedChest, 5)
    end)
end

manualButton.MouseButton1Click:Connect(fireChestRemote)

task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().simpleAutoEnabled then
            fireChestRemote()
        end
    end
end)

-- Logic Kéo thả (Drag)
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y - mainFrame.AbsolutePosition.Y <= 30 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
game:GetService("UserInputService").InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging == false then
		-- Đóng dropdown nếu click ra ngoài
		if dropdownOpen then
			dropdownOpen = false
			listFrame.Visible = false
		end
	end
end)

updateStatus()
print("GUI Loaded with Dropdown!")
