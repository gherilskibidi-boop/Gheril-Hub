-- [[ GHERIL HUB V8 - WORD SOLVER PRO EDITION ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Header = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local OwnerBadge = Instance.new("TextLabel")
local Content = Instance.new("ScrollingFrame")
local UIList = Instance.new("UIListLayout")

-- Setup Main UI (Warna dari CSS lo: --bg #0e1117)
ScreenGui.Parent = game:GetService("CoreGui")
Main.Name = "WordSolverPro"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(14, 17, 23)
Main.Size = UDim2.new(0, 240, 0, 320)
Main.Position = UDim2.new(0.5, -120, 0.5, -160)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = Main

-- Header Section (Warna --card #161920)
Header.Parent = Main
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(22, 25, 32)
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 15)
HeaderCorner.Parent = Header

Title.Parent = Header
Title.Text = "WORD SOLVER PRO"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.fromRGB(0, 229, 255) -- Warna --cyan
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

OwnerBadge.Parent = Header
OwnerBadge.Text = "👑 OWNER MODE AKTIF"
OwnerBadge.Position = UDim2.new(0, 0, 0, 25)
OwnerBadge.Size = UDim2.new(1, 0, 0, 20)
OwnerBadge.TextColor3 = Color3.fromRGB(255, 214, 0) -- Warna --yellow
OwnerBadge.Font = Enum.Font.GothamBold
OwnerBadge.TextSize = 10

-- Container Tombol
Content.Parent = Main
Content.Position = UDim2.new(0, 10, 0, 60)
Content.Size = UDim2.new(1, -20, 1, -70)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 2

UIList.Parent = Content
UIList.Padding = UDim.new(0, 8)

-- Fungsi Bikin Tombol Gaya Dashboard lo
local function AddProBtn(name, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = Content
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = color
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255
    
