local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Đường dẫn ĐÚNG theo ảnh bạn cung cấp (Tìm Data bên trong LocalPlayer)
local dataFolder = player:WaitForChild("Data")

print("Đang đọc folder Data của " .. player.Name .. "...")

local objectNames = {}
-- Đọc tất cả các "con" (children) bên trong folder Data
for _, obj in pairs(dataFolder:GetChildren()) do
    -- Lưu tên và loại component (VD: BackWheel (Instance))
    table.insert(objectNames, obj.Name .. " (" .. typeof(obj) .. ")")
end

if #objectNames == 0 then
    print("❌ Không tìm thấy object nào trong Data!")
    return
end

-- Đặt tên file
local fileName = "BABFT_Data_" .. player.Name .. ".txt"

-- Tạo nội dung text
local content = "DANH SÁCH OBJECTS TRONG FOLDER DATA CỦA " .. player.Name .. "\n"
content = content .. "=====================================\n"
for i, name in ipairs(objectNames) do
    content = content .. i .. ". " .. name .. "\n"
end
content = content .. "=====================================\n"
content = content .. "Tổng cộng: " .. #objectNames .. " objects\n"

-- Thử lưu file vào thư mục workspace của Executor trên Android
local success, err = pcall(function()
    writefile(fileName, content)
end)

if success then
    print("🟢 LƯU THÀNH CÔNG! Tên file: " .. fileName)
    print("Mở File Manager trên giả lập -> tìm folder workspace của Executor để lấy file .txt nhé!")
else
    print("❌ Executor không hỗ trợ lưu file: " .. tostring(err))
    print("Nhưng không sao, mình in toàn bộ danh sách ra đây cho bạn copy:\n")
    print(content)
end
