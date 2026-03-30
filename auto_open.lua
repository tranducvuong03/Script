--[[
  _    _                           
 | |  | |                          
 | |  | |_ __ __ _ _ __  _   _ ___ 
 | |  | | '__/ _` | '_ \| | | / __|
 | |__| | | | (_| | | | | |_| \__ \
  \____/|_|  \__,_|_| |_|\__,_|___/
]]--

local player = game.Players.LocalPlayer
local coreGui = game:GetService("CoreGui")
local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")

-- clear GUI cũ
for _, gui in pairs(coreGui:GetChildren()) do
    if gui:IsA("ScreenGui") and gui.Name == "MySimpleChestGUI" then
        gui:Destroy()
    end
end

getgenv().simpleAutoEnabled = false
getgenv().selectedChest = "NightmareBoosterChest"

local isMinimized = false
local dropdownOpen = false

local chestOptions = {
    {Name = "Nightmare Booster", ID = "NightmareBoosterChest", Color = Color3.fromRGB(100,40,100)},
    {Name = "Valentines Booster", ID = "ValentinesBoosterChest", Color = Color3.fromRGB(180,50,100)},
    {Name = "Banana Booster", ID = "BananaBoosterChest", Color = Color3.fromRGB(70,70,150)}
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MySimpleChestGUI"
screenGui.Parent = coreGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,250,0,200)
mainFrame.Position = UDim2.new(0.5,-125,0.5,-100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-30,0,30)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)
title.Text = "AutoOpenChest - Made by Uranus"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = mainFrame

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0,30,0,30)
minimizeButton.Position = UDim2.new(1,-30,0,0)
minimizeButton.Text = "-"
minimizeButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
minimizeButton.TextColor3 = Color3.fromRGB(255,255,255)
minimizeButton.Parent = mainFrame

-- dropdown chọn chest
local dropdownMainBtn = Instance.new("TextButton")
dropdownMainBtn.Size = UDim2.new(0.8,0,0,30)
dropdownMainBtn.Position = UDim2.new(0.1,0,0,40)
dropdownMainBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
dropdownMainBtn.Text = "Chọn Chest ▼"
dropdownMainBtn.TextColor3 = Color3.fromRGB(255,255,255)
dropdownMainBtn.Font = Enum.Font.SourceSans
dropdownMainBtn.TextSize = 16
dropdownMainBtn.Parent = mainFrame

local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(0.8,0,0,#chestOptions*30)
listFrame.Position = UDim2.new(0.1,0,0,70)
listFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
listFrame.Visible = false
listFrame.ZIndex = 5
listFrame.Parent = mainFrame

for i, chest in ipairs(chestOptions) do
    local itemBtn = Instance.new("TextButton")
    itemBtn.Size = UDim2.new(1,0,0,30)
    itemBtn.Position = UDim2.new(0,0,0,(i-1)*30)
    itemBtn.BackgroundColor3 = chest.Color
    itemBtn.Text = chest.Name
    itemBtn.TextColor3 = Color3.fromRGB(255,255,255)
    itemBtn.ZIndex = 6
    itemBtn.Parent = listFrame

    itemBtn.MouseButton1Click:Connect(function()
        getgenv().selectedChest = chest.ID
        dropdownMainBtn.Text = chest.Name.." ▼"
        listFrame.Visible = false
        dropdownOpen = false
    end)
end

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,0,0,25)
statusLabel.Position = UDim2.new(0,0,0,100)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Trạng thái: TẮT"
statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
statusLabel.Parent = mainFrame

-- hiển thị VoidStar
local voidStarLabel = Instance.new("TextLabel")
voidStarLabel.Size = UDim2.new(1,0,0,25)
voidStarLabel.Position = UDim2.new(0,0,0,120)
voidStarLabel.BackgroundTransparency = 1
voidStarLabel.Text = "VoidStar: 0"
voidStarLabel.TextColor3 = Color3.fromRGB(170,120,255)
voidStarLabel.Font = Enum.Font.SourceSansBold
voidStarLabel.TextSize = 16
voidStarLabel.Parent = mainFrame

-- nút bật auto
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8,0,0,40)
toggleButton.Position = UDim2.new(0.1,0,0,150)
toggleButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
toggleButton.Text = "BẬT AUTO"
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.Parent = mainFrame

-- remote
local function fireChestRemote()
    pcall(function()
        replicatedStorage.Systems.ChestShop.OpenChest:InvokeServer(getgenv().selectedChest,5)
    end)
end

dropdownMainBtn.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    listFrame.Visible = dropdownOpen
end)

toggleButton.MouseButton1Click:Connect(function()
    getgenv().simpleAutoEnabled = not getgenv().simpleAutoEnabled
    statusLabel.Text = "Trạng thái: "..(getgenv().simpleAutoEnabled and "BẬT" or "TẮT")
    toggleButton.BackgroundColor3 = getgenv().simpleAutoEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(80,80,80)
    toggleButton.Text = getgenv().simpleAutoEnabled and "TẮT AUTO" or "BẬT AUTO"
end)

-- auto open loop
task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().simpleAutoEnabled then
            fireChestRemote()
        end
    end
end)

-- cập nhật VoidStar
local voidStarValue = player.PlayerGui.Profile.Currencies:WaitForChild("VoidStar")

local function updateVoidStar()
    voidStarLabel.Text = "VoidStar: "..tostring(voidStarValue.Value)
end

updateVoidStar()
voidStarValue:GetPropertyChangedSignal("Value"):Connect(updateVoidStar)

-- minimize
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized

    if isMinimized then
        mainFrame.Size = UDim2.new(0,250,0,30)
        dropdownMainBtn.Visible = false
        listFrame.Visible = false
        statusLabel.Visible = false
        toggleButton.Visible = false
        voidStarLabel.Visible = false
        minimizeButton.Text = "+"
    else
        mainFrame.Size = UDim2.new(0,250,0,200)
        dropdownMainBtn.Visible = true
        statusLabel.Visible = true
        toggleButton.Visible = true
        voidStarLabel.Visible = true
        minimizeButton.Text = "-"
    end
end)

-- drag GUI
local dragging
local dragStart
local startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y - mainFrame.AbsolutePosition.Y <= 30 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

userInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

userInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("GUI Updated - Manual button removed!")
