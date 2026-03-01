local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Tìm folder Data
local boatsFolder = workspace:WaitForChild("PlayerBoats")
local myFolder = boatsFolder:WaitForChild(player.Name)
-- Nếu là Boat.Data thì đổi thành: myFolder:WaitForChild("Boat"):WaitForChild("Data")
local dataFolder = myFolder:WaitForChild("Data")  

print("Đang đọc folder Data...")

local objectNames = {}
for _, obj in pairs(dataFolder:GetChildren()) do
    table.insert(objectNames, obj.Name .. " (" .. typeof(obj) .. ")")
end

if #objectNames == 0 then
    print("❌ Không tìm thấy object nào trong Data! Chờ boat load đầy hoặc kiểm tra path.")
    return
end

-- Đặt tên file (Không dùng đường dẫn tuyệt đối trên Android)
local fileName = "BABFT_Data_" .. player.Name .. ".txt"

local content = "DANH SÁCH OBJECTS TRONG FOLDER DATA CỦA " .. player.Name .. "\n"
content = content .. "=====================================\n"
for i, name in ipairs(objectNames) do
    content = content .. i .. ". " .. name .. "\n"
end
content = content .. "=====================================\n"
content = content .. "Tổng cộng: " .. #objectNames .. " objects\n"
content = content .. "Ngày: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"

-- Lưu file qua hàm writefile của Executor
local success, err = pcall(function()
    writefile(fileName, content)
end)

if success then
    print("🟢 LƯU THÀNH CÔNG!")
    print("Tên file: " .. fileName)
    
    -- GUI thông báo cho Android
    local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 320, 0, 140)
    frame.Position = UDim2.new(0.5, -160, 0.5, -70)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true
    label.Text = "Đã lưu thành công:\n" .. fileName .. "\n\nMở File Manager của giả lập,\ntìm thư mục workspace của Executor!"
    label.Font = Enum.Font.GothamBold
    
    -- Tự động xóa GUI sau 5 giây
    task.delay(5, function()
        sg:Destroy()
    end)
else
    print("❌ LỖI KHÔNG THỂ LƯU FILE: " .. tostring(err))
    print("Executor của bạn có thể không hỗ trợ hàm writefile.")
end
