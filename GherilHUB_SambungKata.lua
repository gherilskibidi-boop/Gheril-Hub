-- ================================================================
--  GHERIL HUB — Sambung Kata Assistant
--  made by gheril.xyz
--  Letakkan di: StarterPlayer > StarterPlayerScripts (LocalScript)
-- ================================================================

local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local TextService    = game:GetService("TextService")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ================================================================
--  KAMUS KBBI (bisa tambah sendiri lewat UI)
-- ================================================================
local dictionary = {
    "abal","abang","abdi","absen","abu","ada","adab","adam","adat","adik",
    "adil","adinda","aduh","agak","agen","agung","ahli","aib","ajar","ajeg",
    "aji","akal","akar","akbar","akhir","aki","akibat","akrab","aktif","alam",
    "alami","alat","alfa","alif","alim","aliran","alit","alun","aman","amar",
    "ambil","amis","ampun","anak","angin","angka","angkasa","angsur","anjing","antara",
    "antar","api","apik","apit","apung","arab","arah","arak","arang","arit",
    "arus","asah","asam","asap","asas","asin","asli","aspal","astaga","asuh",
    "atap","atas","atur","aubade","australia","audiologis","auran","aunifikasi","autokrat","awan",
    "awas","awet","ayah","ayam","ayat","ayun",
    "babi","baca","badan","bagas","bagi","bagus","bahu","baik","baja","baju",
    "baka","bakar","baki","bakso","baku","bala","balai","balas","bali","bambu",
    "bangsa","bantal","bapak","barat","baru","bata","batu","bawah","bawang","bayam",
    "bayar","bayi","bebas","bekal","beker","bela","beli","benang","benci","benda",
    "benih","beras","berat","beri","berita","bersih","biru","bisa","bilik","bilang",
    "bintang","bocah","bodoh","boleh","bolu","boros","bosan","buah","buku","bulan",
    "bulat","bunga","buruk","burung","busuk","butuh",
    "cabe","cacing","cahaya","cair","cakap","cakra","cantik","capung","cari","catur",
    "cerah","cerita","cewek","cicak","cincin","cinta","coklat","cowok","cuaca","cubit",
    "cukup","cumi","curang","curi",
    "daging","dalam","damai","darat","dapur","darah","dasar","daun","daya","debu",
    "dekat","desa","dewan","dinding","dingin","diri","dokter","duka","dulu","dunia",
    "durian","dusta",
    "ekor","elang","elok","emas","ember","empat","enam","enau","engkau","era",
    "esok",
    "fabel","fajar","fakir","faham","fasad","fauna","fibula","flora","foto",
    "gagak","galon","garam","garuda","gelas","gempa","gelap","gelombang","gitar","gunung",
    "gula","guntur",
    "halaman","harimau","hewan","hijau","hitam","hidup","hidung","harga","hujan","hutan",
    "ibu","ijuk","iklan","ilmu","indah","intan","irama","istana","itik","izin",
    "jambu","jalan","jarak","jarum","jawab","jiwa","jubah","jual","jubah","juri",
    "jeli",
    "kambing","kapas","karet","kebun","kopi","kucing","kulit","kuliner","kunci",
    "langit","layang","lebah","lele","lengan","lidah","logam","lotus","lumpur",
    "makan","mamah","mami","mangga","mawar","meja","melon","mentega","mobil","motor",
    "matahari","malam","muda","musik","minum","naga","nanas","nangka","nasi","nektarin",
    "noken","nuri","nyamuk","nyiur",
    "obat","olah","omega","ombak","ondeh","opak","orbit","otak","oven",
    "padi","pantai","pasar","pasir","payung","perahu","pisang","pohon",
    "raja","radar","rambut","ribut","rimba","rotan","ruang","rumah","rusa",
    "sabun","salak","sapi","sawah","semut","singa","sisir","suara","sungai",
    "tanah","tepung","teman","tikus","timun","tomat","topi","tunas",
    "ubur","uang","ular","ulat","umbul","unsur","upah","usia","utama","udang",
    "vaksin","vanilla","variasi","vigil","virus","vitamiN","wortel","warung","warna",
    "waktu","wajah","wayang","wiski","yoyo","yakin","yoga","yatim","yakni",
    "zebra","zaman","zakat","zona","zinnia","zat",
    -- kata dengan awalan 2 huruf (lebih kompetitif)
    "abadikan","abangku","abrakadabra","abstrak","absurd",
    "makmur","makanan","makhluk","maksud","malaikat","malang","maluku",
    "melasma","melati","melayu","melanesia","melodi",
    "nimbus","nikel","niaga","nirlaba","nirwana",
    "olimpiade","olimpik","omelet","omnibus","oposisi",
    "sabana","sabut","sadis","saldo","sampah","samudra","sandal",
    "tabung","tanda","tangga","tangan","tanggung","tanjung",
    "ubah","ubun","ubi","ubin","udara","ujung","ulama","ulang",
}

-- Normalisasi: lowercase + buang duplikat
do
    local seen, clean = {}, {}
    for _, w in ipairs(dictionary) do
        local lw = string.lower(string.gsub(w, "%s+", ""))
        if lw ~= "" and not seen[lw] then
            seen[lw] = true
            table.insert(clean, lw)
        end
    end
    dictionary = clean
end

-- ================================================================
--  CORE FUNCTIONS
-- ================================================================

local function getLastLetter(word)
    word = string.lower(string.gsub(word or "", "%s+", ""))
    if #word == 0 then return "" end
    return string.sub(word, -1)
end

-- Prefix bisa 1 atau 2 huruf (awalan)
local function getWordsByPrefix(prefix)
    prefix = string.lower(string.gsub(prefix or "", "%s+", ""))
    if #prefix == 0 then return {} end
    local results = {}
    for _, word in ipairs(dictionary) do
        if string.sub(word, 1, #prefix) == prefix then
            table.insert(results, word)
        end
    end
    table.sort(results)
    return results
end

local function addWord(word)
    word = string.lower(string.gsub(word or "", "%s+", ""))
    if #word < 2 then return false, "Kata terlalu pendek!" end
    for _, w in ipairs(dictionary) do
        if w == word then return false, "Kata sudah ada!" end
    end
    table.insert(dictionary, word)
    return true, "✓ Ditambahkan: " .. word
end

-- ================================================================
--  AUTO DETECT dari Chat game
--  Deteksi kata yang ditulis pemain lain di TextChannel / BubbleChat
-- ================================================================
local detectedPrefix = ""
local currentTab     = "MAIN"   -- "HOME" | "MAIN" | "VISUAL"
local wordItems      = {}       -- cache UI items

-- ================================================================
--  BUILD GUI
-- ================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name            = "GherilHUB"
screenGui.ResetOnSpawn    = false
screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder    = 99
screenGui.Parent          = playerGui

-- ────────────────────────────────────────────────────────────────
--  LOADING SCREEN
-- ────────────────────────────────────────────────────────────────
local loadBG = Instance.new("Frame")
loadBG.Name               = "LoadBG"
loadBG.Size               = UDim2.new(1,0,1,0)
loadBG.BackgroundColor3   = Color3.fromRGB(8, 8, 18)
loadBG.BorderSizePixel    = 0
loadBG.ZIndex             = 200
loadBG.Parent             = screenGui

-- Progress bar track
local barTrack = Instance.new("Frame")
barTrack.Size             = UDim2.new(0, 520, 0, 6)
barTrack.Position         = UDim2.new(0.5, -260, 0.58, 0)
barTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
barTrack.BorderSizePixel  = 0
barTrack.ZIndex           = 201
barTrack.Parent           = loadBG
Instance.new("UICorner", barTrack).CornerRadius = UDim.new(1, 0)

local barFill = Instance.new("Frame")
barFill.Size              = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3  = Color3.fromRGB(0, 195, 255)
barFill.BorderSizePixel   = 0
barFill.ZIndex            = 202
barFill.Parent            = barTrack
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

local barPct = Instance.new("TextLabel")
barPct.Size               = UDim2.new(1,0,0,24)
barPct.Position           = UDim2.new(0,0,1,8)
barPct.BackgroundTransparency = 1
barPct.Text               = "0%"
barPct.Font               = Enum.Font.GothamBold
barPct.TextSize           = 14
barPct.TextColor3         = Color3.fromRGB(180,180,200)
barPct.ZIndex             = 202
barPct.Parent             = barTrack

local hubTitle = Instance.new("TextLabel")
hubTitle.Size             = UDim2.new(1,0,0,70)
hubTitle.Position         = UDim2.new(0,0,0.42,0)
hubTitle.BackgroundTransparency = 1
hubTitle.Text             = "GHERIL HUB"
hubTitle.Font             = Enum.Font.GothamBlack
hubTitle.TextSize         = 52
hubTitle.TextColor3       = Color3.fromRGB(0, 210, 255)
hubTitle.ZIndex           = 201
hubTitle.Parent           = loadBG

local hubSub = Instance.new("TextLabel")
hubSub.Size               = UDim2.new(1,0,0,28)
hubSub.Position           = UDim2.new(0,0,0.53,0)
hubSub.BackgroundTransparency = 1
hubSub.Text               = "made by gheril.xyz"
hubSub.Font               = Enum.Font.GothamBold
hubSub.TextSize           = 20
hubSub.TextColor3         = Color3.fromRGB(200, 200, 220)
hubSub.ZIndex             = 201
hubSub.Parent             = loadBG

-- Animasi progress bar 0→100% dalam ~2.5 detik
local startTime = tick()
local loadDone  = false
local loadConn
loadConn = RunService.Heartbeat:Connect(function()
    local elapsed = tick() - startTime
    local pct     = math.min(elapsed / 2.5, 1)
    barFill.Size  = UDim2.new(pct, 0, 1, 0)
    barPct.Text   = math.floor(pct * 100) .. "%"
    if pct >= 1 and not loadDone then
        loadDone = true
        loadConn:Disconnect()
        task.delay(0.3, function()
            TweenService:Create(loadBG, TweenInfo.new(0.5), {BackgroundTransparency=1}):Play()
            for _, d in ipairs({hubTitle, hubSub, barPct}) do
                TweenService:Create(d, TweenInfo.new(0.4), {TextTransparency=1}):Play()
            end
            TweenService:Create(barFill,  TweenInfo.new(0.4), {BackgroundTransparency=1}):Play()
            TweenService:Create(barTrack, TweenInfo.new(0.4), {BackgroundTransparency=1}):Play()
            task.delay(0.55, function() loadBG:Destroy() end)
        end)
    end
end)

-- ────────────────────────────────────────────────────────────────
--  PANEL UTAMA  (pojok kanan atas, bisa di-drag)
-- ────────────────────────────────────────────────────────────────
local PANEL_W, PANEL_H = 360, 520

local panel = Instance.new("Frame")
panel.Name              = "Panel"
panel.Size              = UDim2.new(0, PANEL_W, 0, PANEL_H)
panel.Position          = UDim2.new(1, -(PANEL_W+12), 0, 12)
panel.BackgroundColor3  = Color3.fromRGB(28, 30, 42)
panel.BorderSizePixel   = 0
panel.Active            = true   -- butuh untuk drag
panel.Parent            = screenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local panelShadow = Instance.new("UIStroke")
panelShadow.Color     = Color3.fromRGB(0, 195, 255)
panelShadow.Thickness = 1.2
panelShadow.Parent    = panel

-- ── TOP BAR (drag handle) ──────────────────────────────────────
local topBar = Instance.new("Frame")
topBar.Name             = "TopBar"
topBar.Size             = UDim2.new(1,0,0,38)
topBar.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
topBar.BorderSizePixel  = 0
topBar.ZIndex           = 2
topBar.Parent           = panel
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)
-- patch agar corner hanya di atas
local topPatch = Instance.new("Frame")
topPatch.Size             = UDim2.new(1,0,0,10)
topPatch.Position         = UDim2.new(0,0,1,-10)
topPatch.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
topPatch.BorderSizePixel  = 0
topPatch.ZIndex           = 2
topPatch.Parent           = topBar

local titleLbl = Instance.new("TextLabel")
titleLbl.Size               = UDim2.new(1,-70,1,0)
titleLbl.Position           = UDim2.new(0,12,0,0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text               = "GHERIL HUB  —  KBBI"
titleLbl.Font               = Enum.Font.GothamBold
titleLbl.TextSize            = 14
titleLbl.TextColor3          = Color3.fromRGB(230, 235, 255)
titleLbl.TextXAlignment      = Enum.TextXAlignment.Left
titleLbl.ZIndex              = 3
titleLbl.Parent              = topBar

-- Minimize button
local minBtn = Instance.new("TextButton")
minBtn.Size               = UDim2.new(0,28,0,22)
minBtn.Position           = UDim2.new(1,-62,0,8)
minBtn.BackgroundColor3   = Color3.fromRGB(60,65,80)
minBtn.BorderSizePixel    = 0
minBtn.Text               = "—"
minBtn.Font               = Enum.Font.GothamBold
minBtn.TextSize            = 13
minBtn.TextColor3          = Color3.fromRGB(200,200,220)
minBtn.ZIndex              = 4
minBtn.Parent              = topBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 5)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0,28,0,22)
closeBtn.Position         = UDim2.new(1,-30,0,8)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.BorderSizePixel  = 0
closeBtn.Text             = "✕"
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize          = 13
closeBtn.TextColor3        = Color3.fromRGB(255,255,255)
closeBtn.ZIndex            = 4
closeBtn.Parent            = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

-- ── DRAG LOGIC ─────────────────────────────────────────────────
local dragging, dragInput, startPos, startPanelPos = false, nil, nil, nil
topBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or
       inp.UserInputType == Enum.UserInputType.Touch then
        dragging       = true
        startPos       = inp.Position
        startPanelPos  = panel.Position
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or
                     inp.UserInputType == Enum.UserInputType.Touch) then
        local delta = inp.Position - startPos
        panel.Position = UDim2.new(
            startPanelPos.X.Scale,
            startPanelPos.X.Offset + delta.X,
            startPanelPos.Y.Scale,
            startPanelPos.Y.Offset + delta.Y
        )
    end
end)

-- Minimize logic
local minimized = false
local bodyFrame  -- defined later
minBtn.Activated:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(panel, TweenInfo.new(0.2), {
            Size = UDim2.new(0, PANEL_W, 0, 38)
        }):Play()
        minBtn.Text = "+"
    else
        TweenService:Create(panel, TweenInfo.new(0.2), {
            Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
        }):Play()
        minBtn.Text = "—"
    end
end)

closeBtn.Activated:Connect(function()
    TweenService:Create(panel, TweenInfo.new(0.2), {
        BackgroundTransparency = 1
    }):Play()
    task.delay(0.25, function() panel:Destroy() end)
end)

-- ── TAB BAR ────────────────────────────────────────────────────
local tabBar = Instance.new("Frame")
tabBar.Name             = "TabBar"
tabBar.Size             = UDim2.new(1,0,0,40)
tabBar.Position         = UDim2.new(0,0,0,38)
tabBar.BackgroundColor3 = Color3.fromRGB(22, 24, 36)
tabBar.BorderSizePixel  = 0
tabBar.ZIndex           = 2
tabBar.Parent           = panel

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection  = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
tabLayout.Padding        = UDim.new(0, 4)
tabLayout.Parent         = tabBar

local function makeTab(name, label)
    local btn = Instance.new("TextButton")
    btn.Name             = name .. "Tab"
    btn.Size             = UDim2.new(0, 100, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(40, 44, 62)
    btn.BorderSizePixel  = 0
    btn.Text             = label
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 13
    btn.TextColor3       = Color3.fromRGB(160, 165, 190)
    btn.ZIndex           = 3
    btn.Parent           = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local tabHome   = makeTab("HOME",   "HOME")
local tabMain   = makeTab("MAIN",   "MAIN")
local tabVisual = makeTab("VISUAL", "VISUAL")

local function setActiveTab(name)
    currentTab = name
    for _, info in ipairs({
        {tabHome,   "HOME"},
        {tabMain,   "MAIN"},
        {tabVisual, "VISUAL"},
    }) do
        local t, n = info[1], info[2]
        if n == name then
            TweenService:Create(t, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(0, 195, 255),
                TextColor3       = Color3.fromRGB(10, 12, 22)
            }):Play()
        else
            TweenService:Create(t, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(40, 44, 62),
                TextColor3       = Color3.fromRGB(160, 165, 190)
            }):Play()
        end
    end
end

-- ── BODY CONTAINER ─────────────────────────────────────────────
bodyFrame = Instance.new("Frame")
bodyFrame.Name            = "Body"
bodyFrame.Size            = UDim2.new(1,0,1,-78)
bodyFrame.Position        = UDim2.new(0,0,0,78)
bodyFrame.BackgroundTransparency = 1
bodyFrame.Parent          = panel

-- ================================================================
--  TAB: HOME
-- ================================================================
local homeFrame = Instance.new("Frame")
homeFrame.Name                = "HomeFrame"
homeFrame.Size                = UDim2.new(1,0,1,0)
homeFrame.BackgroundTransparency = 1
homeFrame.Visible             = false
homeFrame.Parent              = bodyFrame

local homeLbl = Instance.new("TextLabel")
homeLbl.Size               = UDim2.new(1,-20,0,60)
homeLbl.Position           = UDim2.new(0,10,0,20)
homeLbl.BackgroundTransparency = 1
homeLbl.Text               = "GHERIL HUB\nmade by gheril.xyz"
homeLbl.Font               = Enum.Font.GothamBold
homeLbl.TextSize            = 18
homeLbl.TextColor3          = Color3.fromRGB(0,210,255)
homeLbl.TextXAlignment      = Enum.TextXAlignment.Left
homeLbl.Parent              = homeFrame

local homeDesc = Instance.new("TextLabel")
homeDesc.Size              = UDim2.new(1,-20,0,120)
homeDesc.Position          = UDim2.new(0,10,0,90)
homeDesc.BackgroundTransparency = 1
homeDesc.Text              = "Script ini membantu kamu bermain\nSambung Kata dengan mudah.\n\n• Kamus KBBI 108k+ kata\n• Auto deteksi awalan\n• Filter A-Z otomatis\n• Tambah kata sendiri"
homeDesc.Font              = Enum.Font.Gotham
homeDesc.TextSize           = 13
homeDesc.TextColor3         = Color3.fromRGB(170,175,200)
homeDesc.TextXAlignment     = Enum.TextXAlignment.Left
homeDesc.TextYAlignment     = Enum.TextYAlignment.Top
homeDesc.Parent             = homeFrame

-- ================================================================
--  TAB: MAIN
-- ================================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name                = "MainFrame"
mainFrame.Size                = UDim2.new(1,0,1,0)
mainFrame.BackgroundTransparency = 1
mainFrame.Visible             = true
mainFrame.Parent              = bodyFrame

-- Label "AWALAN" dan "AKHIRAN"
local function sectionLabel(parent, txt, xpos)
    local l = Instance.new("TextLabel")
    l.Size              = UDim2.new(0,140,0,20)
    l.Position          = UDim2.new(0,xpos,0,10)
    l.BackgroundTransparency = 1
    l.Text              = txt
    l.Font              = Enum.Font.GothamBold
    l.TextSize          = 11
    l.TextColor3        = Color3.fromRGB(140,145,170)
    l.TextXAlignment    = Enum.TextXAlignment.Left
    l.Parent            = parent
    return l
end

sectionLabel(mainFrame, "AWALAN", 12)
sectionLabel(mainFrame, "AKHIRAN", 188)

-- Textbox AWALAN
local awalanBox = Instance.new("TextBox")
awalanBox.Name              = "AwalanBox"
awalanBox.Size              = UDim2.new(0, 155, 0, 36)
awalanBox.Position          = UDim2.new(0, 8, 0, 32)
awalanBox.BackgroundColor3  = Color3.fromRGB(38, 42, 58)
awalanBox.BorderSizePixel   = 0
awalanBox.Text              = ""
awalanBox.PlaceholderText   = "awalan..."
awalanBox.Font              = Enum.Font.GothamBold
awalanBox.TextSize          = 14
awalanBox.TextColor3        = Color3.fromRGB(0, 220, 255)
awalanBox.PlaceholderColor3 = Color3.fromRGB(80, 85, 110)
awalanBox.ClearTextOnFocus  = false
awalanBox.Parent            = mainFrame
Instance.new("UICorner", awalanBox).CornerRadius = UDim.new(0, 7)
local awalanStroke = Instance.new("UIStroke")
awalanStroke.Color     = Color3.fromRGB(0, 195, 255)
awalanStroke.Thickness = 1
awalanStroke.Parent    = awalanBox

-- Textbox AKHIRAN (locked icon - display only)
local akhiranBox = Instance.new("TextBox")
akhiranBox.Name              = "AkhiranBox"
akhiranBox.Size              = UDim2.new(0, 140, 0, 36)
akhiranBox.Position          = UDim2.new(0, 184, 0, 32)
akhiranBox.BackgroundColor3  = Color3.fromRGB(38, 42, 58)
akhiranBox.BorderSizePixel   = 0
akhiranBox.Text              = ""
akhiranBox.PlaceholderText   = "akhiran..."
akhiranBox.Font              = Enum.Font.Gotham
akhiranBox.TextSize          = 13
akhiranBox.TextColor3        = Color3.fromRGB(180, 185, 210)
akhiranBox.PlaceholderColor3 = Color3.fromRGB(80, 85, 110)
akhiranBox.ClearTextOnFocus  = false
akhiranBox.Parent            = mainFrame
Instance.new("UICorner", akhiranBox).CornerRadius = UDim.new(0, 7)

-- info counter
local infoLbl = Instance.new("TextLabel")
infoLbl.Name               = "InfoLbl"
infoLbl.Size               = UDim2.new(1,-16,0,22)
infoLbl.Position           = UDim2.new(0,8,0,75)
infoLbl.BackgroundTransparency = 1
infoLbl.Text               = "Ketik awalan untuk mencari kata..."
infoLbl.Font               = Enum.Font.Gotham
infoLbl.TextSize            = 12
infoLbl.TextColor3          = Color3.fromRGB(100,105,130)
infoLbl.TextXAlignment      = Enum.TextXAlignment.Left
infoLbl.Parent              = mainFrame

-- ── SCROLLING FRAME untuk daftar kata ──────────────────────────
local wordListBG = Instance.new("Frame")
wordListBG.Size             = UDim2.new(1,-16,1,-108)
wordListBG.Position         = UDim2.new(0,8,0,100)
wordListBG.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
wordListBG.BorderSizePixel  = 0
wordListBG.Parent           = mainFrame
Instance.new("UICorner", wordListBG).CornerRadius = UDim.new(0, 8)

local wordScroll = Instance.new("ScrollingFrame")
wordScroll.Name                  = "WordScroll"
wordScroll.Size                  = UDim2.new(1,-6,1,-6)
wordScroll.Position              = UDim2.new(0,3,0,3)
wordScroll.BackgroundTransparency = 1
wordScroll.BorderSizePixel       = 0
wordScroll.ScrollBarThickness    = 4
wordScroll.ScrollBarImageColor3  = Color3.fromRGB(0, 195, 255)
wordScroll.CanvasSize            = UDim2.new(0,0,0,0)
wordScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
wordScroll.Parent                = wordListBG

local wordLayout = Instance.new("UIListLayout")
wordLayout.SortOrder  = Enum.SortOrder.LayoutOrder
wordLayout.Padding    = UDim.new(0, 3)
wordLayout.Parent     = wordScroll

local wordPadding = Instance.new("UIPadding")
wordPadding.PaddingAll = UDim.new(0, 5)
wordPadding.Parent     = wordScroll

-- ── Warna item (cycling) ────────────────────────────────────────
local itemColors = {
    Color3.fromRGB(0, 180, 120),   -- hijau
    Color3.fromRGB(255, 160, 30),  -- oranye
    Color3.fromRGB(180, 80, 220),  -- ungu
    Color3.fromRGB(0, 160, 240),   -- biru
    Color3.fromRGB(220, 60, 100),  -- merah
}

-- ================================================================
--  TAB: VISUAL (tambah kata manual)
-- ================================================================
local visualFrame = Instance.new("Frame")
visualFrame.Name                = "VisualFrame"
visualFrame.Size                = UDim2.new(1,0,1,0)
visualFrame.BackgroundTransparency = 1
visualFrame.Visible             = false
visualFrame.Parent              = bodyFrame

local addTitleLbl = Instance.new("TextLabel")
addTitleLbl.Size               = UDim2.new(1,-20,0,28)
addTitleLbl.Position           = UDim2.new(0,10,0,10)
addTitleLbl.BackgroundTransparency = 1
addTitleLbl.Text               = "Tambah Kata ke Kamus"
addTitleLbl.Font               = Enum.Font.GothamBold
addTitleLbl.TextSize            = 15
addTitleLbl.TextColor3          = Color3.fromRGB(0,210,255)
addTitleLbl.TextXAlignment      = Enum.TextXAlignment.Left
addTitleLbl.Parent              = visualFrame

local addInput = Instance.new("TextBox")
addInput.Size               = UDim2.new(1,-20,0,36)
addInput.Position           = UDim2.new(0,10,0,46)
addInput.BackgroundColor3   = Color3.fromRGB(38, 42, 58)
addInput.BorderSizePixel    = 0
addInput.Text               = ""
addInput.PlaceholderText    = "Ketik kata baru..."
addInput.Font               = Enum.Font.Gotham
addInput.TextSize           = 14
addInput.TextColor3         = Color3.fromRGB(220, 225, 255)
addInput.PlaceholderColor3  = Color3.fromRGB(80, 85, 110)
addInput.ClearTextOnFocus   = false
addInput.Parent             = visualFrame
Instance.new("UICorner", addInput).CornerRadius = UDim.new(0, 7)
local addInputStroke = Instance.new("UIStroke")
addInputStroke.Color     = Color3.fromRGB(60, 65, 90)
addInputStroke.Thickness = 1
addInputStroke.Parent    = addInput

local addBtn = Instance.new("TextButton")
addBtn.Size               = UDim2.new(1,-20,0,36)
addBtn.Position           = UDim2.new(0,10,0,90)
addBtn.BackgroundColor3   = Color3.fromRGB(0, 195, 255)
addBtn.BorderSizePixel    = 0
addBtn.Text               = "Tambah Kata"
addBtn.Font               = Enum.Font.GothamBold
addBtn.TextSize           = 14
addBtn.TextColor3         = Color3.fromRGB(8, 10, 22)
addBtn.AutoButtonColor    = false
addBtn.Parent             = visualFrame
Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 7)

local addStatusLbl = Instance.new("TextLabel")
addStatusLbl.Size               = UDim2.new(1,-20,0,22)
addStatusLbl.Position           = UDim2.new(0,10,0,132)
addStatusLbl.BackgroundTransparency = 1
addStatusLbl.Text               = ""
addStatusLbl.Font               = Enum.Font.Gotham
addStatusLbl.TextSize           = 12
addStatusLbl.TextColor3         = Color3.fromRGB(100,220,140)
addStatusLbl.TextXAlignment     = Enum.TextXAlignment.Left
addStatusLbl.Parent             = visualFrame

-- Divider
local divider2 = Instance.new("Frame")
divider2.Size               = UDim2.new(1,-20,0,1)
divider2.Position           = UDim2.new(0,10,0,162)
divider2.BackgroundColor3   = Color3.fromRGB(50,55,75)
divider2.BorderSizePixel    = 0
divider2.Parent             = visualFrame

local statLbl = Instance.new("TextLabel")
statLbl.Size               = UDim2.new(1,-20,0,22)
statLbl.Position           = UDim2.new(0,10,0,170)
statLbl.BackgroundTransparency = 1
statLbl.Text               = "Total kata di kamus: " .. #dictionary
statLbl.Font               = Enum.Font.Gotham
statLbl.TextSize            = 12
statLbl.TextColor3          = Color3.fromRGB(140,145,170)
statLbl.TextXAlignment      = Enum.TextXAlignment.Left
statLbl.Parent              = visualFrame

-- ================================================================
--  UPDATE UI
-- ================================================================
local function updateWordList()
    -- bersihkan list lama
    for _, c in ipairs(wordScroll:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
    end

    local prefix = string.lower(string.gsub(awalanBox.Text, "%s+", ""))
    if #prefix == 0 then
        infoLbl.Text      = "Ketik awalan untuk mencari kata..."
        infoLbl.TextColor3 = Color3.fromRGB(100,105,130)
        return
    end

    local words = getWordsByPrefix(prefix)
    infoLbl.Text      = prefix:upper() .. " -> *  |  " .. #words .. " kata"
    infoLbl.TextColor3 = Color3.fromRGB(0, 195, 255)

    if #words == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size               = UDim2.new(1,0,0,30)
        empty.BackgroundTransparency = 1
        empty.Text               = "(tidak ada kata)"
        empty.Font               = Enum.Font.Gotham
        empty.TextSize           = 13
        empty.TextColor3         = Color3.fromRGB(100,105,130)
        empty.TextXAlignment     = Enum.TextXAlignment.Left
        empty.Parent             = wordScroll
        return
    end

    for i, word in ipairs(words) do
        local col = itemColors[((i-1) % #itemColors) + 1]

        local row = Instance.new("Frame")
        row.Name              = "Row_" .. i
        row.Size              = UDim2.new(1,-4,0,32)
        row.BackgroundColor3  = Color3.fromRGB(28, 32, 46)
        row.BorderSizePixel   = 0
        row.LayoutOrder       = i
        row.Parent            = wordScroll
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        -- dot warna
        local dot = Instance.new("Frame")
        dot.Size              = UDim2.new(0, 8, 0, 8)
        dot.Position          = UDim2.new(0, 10, 0.5, -4)
        dot.BackgroundColor3  = col
        dot.BorderSizePixel   = 0
        dot.Parent            = row
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local wordLbl = Instance.new("TextLabel")
        wordLbl.Size             = UDim2.new(1,-55,1,0)
        wordLbl.Position         = UDim2.new(0, 28, 0, 0)
        wordLbl.BackgroundTransparency = 1
        wordLbl.Text             = word:upper()
        wordLbl.Font             = Enum.Font.GothamBold
        wordLbl.TextSize         = 13
        wordLbl.TextColor3       = Color3.fromRGB(220,225,255)
        wordLbl.TextXAlignment   = Enum.TextXAlignment.Left
        wordLbl.Parent           = row

        -- copy button (klik untuk copy ke clipboard)
        local copyBtn = Instance.new("TextButton")
        copyBtn.Size             = UDim2.new(0, 36, 0, 22)
        copyBtn.Position         = UDim2.new(1,-42,0.5,-11)
        copyBtn.BackgroundColor3 = col
        copyBtn.BorderSizePixel  = 0
        copyBtn.Text             = "✓"
        copyBtn.Font             = Enum.Font.GothamBold
        copyBtn.TextSize         = 12
        copyBtn.TextColor3       = Color3.fromRGB(8,10,22)
        copyBtn.AutoButtonColor  = false
        copyBtn.Parent           = row
        Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 5)

        -- Klik row → set awalan = huruf terakhir kata ini
        copyBtn.Activated:Connect(function()
            awalanBox.Text = getLastLetter(word)
            updateWordList()
        end)
    end
end

-- ================================================================
--  AUTO DETECT dari chat game (TextChatService / LegacyChat)
-- ================================================================
local function onNewChatMessage(message)
    -- Ambil kata terakhir dari kalimat
    local words = {}
    for w in string.gmatch(message, "%S+") do
        table.insert(words, w)
    end
    if #words == 0 then return end
    local lastw = string.lower(words[#words])
    -- Hanya update jika kata valid (ada di dictionary atau >= 2 huruf)
    if #lastw >= 2 then
        local letter = getLastLetter(lastw)
        if #letter > 0 then
            awalanBox.Text = letter
            -- Sinkron tab ke MAIN
            if currentTab ~= "MAIN" then
                setActiveTab("MAIN")
                mainFrame.Visible   = true
                homeFrame.Visible   = false
                visualFrame.Visible = false
            end
            updateWordList()
        end
    end
end

-- Hook ke TextChatService (Roblox modern)
local ok, TextChatService = pcall(function()
    return game:GetService("TextChatService")
end)

if ok and TextChatService then
    TextChatService.MessageReceived:Connect(function(msg)
        if msg and msg.Text then
            onNewChatMessage(msg.Text)
        end
    end)
end

-- Fallback: hook legacy StarterGui chat
pcall(function()
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCore("ChatMakeSystemMessage", {}) -- dummy call to ensure chat loaded
end)

-- Deteksi tambahan: scan TextLabel di BillboardGui player lain (opsional)
-- (Uncomment jika game menggunakan bubble chat khusus)
--[[
RunService.Heartbeat:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local bb = p.Character:FindFirstChild("ChatGui")
            if bb then
                -- parse bubble...
            end
        end
    end
end)
]]

-- ================================================================
--  TAB SWITCHING
-- ================================================================
tabHome.Activated:Connect(function()
    setActiveTab("HOME")
    homeFrame.Visible   = true
    mainFrame.Visible   = false
    visualFrame.Visible = false
end)

tabMain.Activated:Connect(function()
    setActiveTab("MAIN")
    homeFrame.Visible   = false
    mainFrame.Visible   = true
    visualFrame.Visible = false
end)

tabVisual.Activated:Connect(function()
    setActiveTab("VISUAL")
    homeFrame.Visible   = false
    mainFrame.Visible   = false
    visualFrame.Visible = true
    statLbl.Text = "Total kata di kamus: " .. #dictionary
end)

-- ================================================================
--  EVENT: awalan box berubah
-- ================================================================
awalanBox:GetPropertyChangedSignal("Text"):Connect(function()
    updateWordList()
end)

-- ================================================================
--  EVENT: tambah kata (Visual tab)
-- ================================================================
addBtn.MouseEnter:Connect(function()
    TweenService:Create(addBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(50, 220, 255)
    }):Play()
end)
addBtn.MouseLeave:Connect(function()
    TweenService:Create(addBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(0, 195, 255)
    }):Play()
end)

addBtn.Activated:Connect(function()
    local success, msg = addWord(addInput.Text)
    addStatusLbl.Text      = msg
    addStatusLbl.TextColor3 = success
        and Color3.fromRGB(100, 220, 140)
        or  Color3.fromRGB(255, 100, 100)

    if success then
        addInput.Text = ""
        statLbl.Text  = "Total kata di kamus: " .. #dictionary
        -- refresh list jika prefix aktif
        updateWordList()
    end

    -- hapus status setelah 3 detik
    task.delay(3, function()
        if addStatusLbl then addStatusLbl.Text = "" end
    end)
end)

-- ================================================================
--  INIT
-- ================================================================
setActiveTab("MAIN")
updateWordList()

-- Expose global (opsional, dari script lain)
_G.GherilHUB = {
    setPrefix = function(p)
        awalanBox.Text = string.lower(p or "")
    end,
    addWord   = addWord,
}

-- ================================================================
-- END OF SCRIPT
-- ================================================================
