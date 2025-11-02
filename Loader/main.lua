-- LEXHOST Loader (FINAL - perbaikan verifikasi + tombol X + judul)
-- Fitur: blur halus saat verifikasi, cinematic FX saat sukses, tombol close (X), judul "LEX HOST PROJECT"
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- URLs verifikasi (tetap seperti semula)
local urlVip = "https://raw.githubusercontent.com/putraborz/VerifikasiScWata/refs/heads/main/Loader/vip.txt"
local urlSatuan = "https://raw.githubusercontent.com/putraborz/VerifikasiScWata/refs/heads/main/Loader/15.txt"

local successUrls = {
    "https://raw.githubusercontent.com/putraborz/WataXMountAtin/main/Loader/WataX.lua",
    "https://raw.githubusercontent.com/putraborz/WataXMountAtin/refs/heads/main/Loader/mainmap792.lua"
}

-- helper fetch yg lebih toleran (pcall sudah ada tapi jaga lagi)
local function fetch(url)
    if not url then return nil end
    local ok, res = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not ok or not res then
        return nil
    end
    return tostring(res)
end

-- isVerified: cari nama (case-insensitive) pada tiap baris file
local function isVerified(uname)
    if not uname then return false end
    local vip = fetch(urlVip)
    local sat = fetch(urlSatuan)
    if not vip and not sat then
        return false -- gagal ambil daftar
    end
    uname = tostring(uname):lower()

    local function checkList(list)
        if not list then return false end
        for line in list:gmatch("[^\r\n]+") do
            -- hapus komentar setelah -- jika ada, lalu trim
            local nameOnly = line:match("^(.-)%s*%-%-") or line
            nameOnly = nameOnly:match("^%s*(.-)%s*$") or ""
            if nameOnly:lower() == uname then
                return true
            end
        end
        return false
    end

    return checkList(vip) or checkList(sat)
end

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Info",
            Text = text or "",
            Duration = duration or 4
        })
    end)
end

-- ============================
-- BUILD GUI
-- ============================
local gui = Instance.new("ScreenGui")
gui.Name = "LEXHOSTLoader"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 360, 0, 220)
frame.Position = UDim2.new(0.5, -180, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 1 -- fade-in
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2

-- Fade-in
TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()

-- Title "LEX HOST PROJECT" (di atas)
local titleLabel = Instance.new("TextLabel", frame)
titleLabel.Size = UDim2.new(1, -24, 0, 28)
titleLabel.Position = UDim2.new(0, 12, 0, 8)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Text = "LEX HOST PROJECT"
titleLabel.TextColor3 = Color3.fromRGB(220,220,255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextTransparency = 1
TweenService:Create(titleLabel, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

-- tombol close (X) kanan atas
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 32, 0, 28)
closeBtn.Position = UDim2.new(1, -40, 0, 8)
closeBtn.AnchorPoint = Vector2.new(0,0)
closeBtn.BackgroundColor3 = Color3.fromRGB(180,60,60)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

closeBtn.MouseEnter:Connect(function()
    pcall(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(220,80,80)}):Play()
    end)
end)
closeBtn.MouseLeave:Connect(function()
    pcall(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(180,60,60)}):Play()
    end)
end)

-- avatar (kanan atas bawah title)
local avatar = Instance.new("ImageLabel", frame)
avatar.Size = UDim2.new(0, 64, 0, 64)
avatar.Position = UDim2.new(0, 16, 0, 44)
avatar.BackgroundTransparency = 1
avatar.Image = "rbxassetid://112840507" -- fallback
task.spawn(function()
    local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100)
    end)
    if ok and img then avatar.Image = img end
end)

-- username
local unameLabel = Instance.new("TextLabel", frame)
unameLabel.Position = UDim2.new(0, 96, 0, 50)
unameLabel.Size = UDim2.new(1, -110, 0, 26)
unameLabel.BackgroundTransparency = 1
unameLabel.Font = Enum.Font.GothamBold
unameLabel.TextSize = 20
unameLabel.TextColor3 = Color3.fromRGB(240,240,240)
unameLabel.TextXAlignment = Enum.TextXAlignment.Left
unameLabel.Text = player.Name

-- status text
local status = Instance.new("TextLabel", frame)
status.Position = UDim2.new(0, 16, 0, 118)
status.Size = UDim2.new(1, -32, 0, 26)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextColor3 = Color3.fromRGB(200,200,200)
status.Text = "Klik tombol verifikasi untuk lanjut..."

-- tombol verify
local verifyBtn = Instance.new("TextButton", frame)
verifyBtn.Size = UDim2.new(0.62, 0, 0, 36)
verifyBtn.Position = UDim2.new(0.19, 0, 1, -48)
verifyBtn.Text = "Verifikasi"
verifyBtn.Font = Enum.Font.GothamBold
verifyBtn.TextSize = 16
verifyBtn.TextColor3 = Color3.fromRGB(255,255,255)
verifyBtn.BackgroundColor3 = Color3.fromRGB(60, 170, 100)
Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 8)

-- tombol lain (placeholder cepat copy link)
local tiktokBtn = Instance.new("TextButton", frame)
tiktokBtn.Size = UDim2.new(0.13, 0, 0, 28)
tiktokBtn.Position = UDim2.new(0.02, 0, 1, -40)
tiktokBtn.Text = "TikTok"
tiktokBtn.Font = Enum.Font.GothamBold
tiktokBtn.TextSize = 12
tiktokBtn.TextColor3 = Color3.fromRGB(255,255,255)
tiktokBtn.BackgroundColor3 = Color3.fromRGB(50,50,60)
Instance.new("UICorner", tiktokBtn).CornerRadius = UDim.new(0,6)

local discordBtn = Instance.new("TextButton", frame)
discordBtn.Size = UDim2.new(0.13, 0, 0, 28)
discordBtn.Position = UDim2.new(0.86, 0, 1, -40)
discordBtn.Text = "Discord"
discordBtn.Font = Enum.Font.GothamBold
discordBtn.TextSize = 12
discordBtn.TextColor3 = Color3.fromRGB(255,255,255)
discordBtn.BackgroundColor3 = Color3.fromRGB(48,60,110)
Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0,6)

-- RGB border anim
task.spawn(function()
    while frame.Parent do
        for h = 0, 255 do
            if not frame.Parent then break end
            stroke.Color = Color3.fromHSV(h/255, 0.85, 0.95)
            task.wait(0.02)
        end
    end
end)

-- helper pulse
local function pulse(obj, amt, times)
    amt = amt or 6
    times = times or 3
    for i = 1, times do
        local orig = obj.Position
        pcall(function() TweenService:Create(obj, TweenInfo.new(0.05), {Position = orig + UDim2.new(0, amt, 0, 0)}):Play() end)
        task.wait(0.05)
        pcall(function() TweenService:Create(obj, TweenInfo.new(0.05), {Position = orig}):Play() end)
        task.wait(0.05)
    end
end

-- close button logic: bersihkan gui + blur + efek
closeBtn.MouseButton1Click:Connect(function()
    -- hapus blur jika ada
    local b = Lighting:FindFirstChild("LEXHOST_Blur")
    if b then
        pcall(function() TweenService:Create(b, TweenInfo.new(0.3), {Size = 0}):Play() end)
        task.delay(0.35, function() if b and b.Parent then b:Destroy() end end)
    end
    -- hapus any verified GUI
    local vg = player.PlayerGui:FindFirstChild("LEXHOST_VerifiedFX")
    if vg then vg:Destroy() end
    if gui and gui.Parent then gui:Destroy() end
end)

-- Cinematic FX ketika sukses (blur tetap ada)
local function playCinematicFX()
    -- pastikan blur sudah ada dan halus (size=8)
    local blur = Lighting:FindFirstChild("LEXHOST_Blur")
    if not blur then
        blur = Instance.new("BlurEffect")
        blur.Name = "LEXHOST_Blur"
        blur.Size = 0
        blur.Parent = Lighting
        TweenService:Create(blur, TweenInfo.new(0.35), {Size = 8}):Play()
    else
        pcall(function() TweenService:Create(blur, TweenInfo.new(0.25), {Size = 8}):Play() end)
    end

    -- part & particle di depan kamera
    local part = Instance.new("Part")
    part.Name = "LEXHOST_ParticlePart"
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(1,1,1)
    part.CFrame = cam.CFrame * CFrame.new(0, 0, -6)
    part.Parent = workspace
    Debris:AddItem(part, 6)

    local emitter = Instance.new("ParticleEmitter", part)
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Rate = 80
    emitter.Lifetime = NumberRange.new(0.9, 2.4)
    emitter.Speed = NumberRange.new(0.8, 3.4)
    emitter.Rotation = NumberRange.new(0, 360)
    emitter.RotSpeed = NumberRange.new(-90, 90)
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.42), NumberSequenceKeypoint.new(1, 0.88)})
    emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.06), NumberSequenceKeypoint.new(1, 1)})
    emitter.LightEmission = 0.85
    emitter.LockedToPart = true
    emitter.VelocitySpread = 180
    emitter.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 80, 255)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(80, 200, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,160,80))
    }
    emitter.Enabled = true
    task.delay(3.6, function() if emitter and emitter.Parent then emitter.Enabled = false end end)

    -- fullscreen verified GUI
    local verifiedGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    verifiedGui.Name = "LEXHOST_VerifiedFX"

    local holder = Instance.new("Frame", verifiedGui)
    holder.AnchorPoint = Vector2.new(0.5,0.5)
    holder.Position = UDim2.new(0.5,0,0.5,0)
    holder.Size = UDim2.new(0.12,0,0,60)
    holder.BackgroundTransparency = 1

    local bigText = Instance.new("TextLabel", holder)
    bigText.Size = UDim2.new(1,0,1,0)
    bigText.Position = UDim2.new(0,0,0,0)
    bigText.BackgroundTransparency = 1
    bigText.Text = "✅ LEXHOST VERIFIED"
    bigText.Font = Enum.Font.GothamBlack
    bigText.TextSize = 56
    bigText.TextTransparency = 1
    bigText.TextStrokeTransparency = 0.6
    bigText.TextColor3 = Color3.fromRGB(255,255,255)
    bigText.TextScaled = true

    -- animate
    TweenService:Create(holder, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(0.7,0,0,160)}):Play()
    TweenService:Create(bigText, TweenInfo.new(0.6), {TextTransparency = 0}):Play()

    local cycle = true
    task.spawn(function()
        while cycle and bigText.Parent do
            for h = 0,255 do
                if not (cycle and bigText.Parent) then break end
                bigText.TextColor3 = Color3.fromHSV(h/255, 0.95, 1)
                task.wait(0.014)
            end
        end
    end)

    -- show then fade
    task.wait(3.6)
    cycle = false
    pcall(function()
        TweenService:Create(bigText, TweenInfo.new(0.9), {TextTransparency = 1}):Play()
        TweenService:Create(holder, TweenInfo.new(0.9), {Size = UDim2.new(0.05,0,0,40)}):Play()
        if Lighting:FindFirstChild("LEXHOST_Blur") then
            TweenService:Create(Lighting:FindFirstChild("LEXHOST_Blur"), TweenInfo.new(0.9), {Size = 0}):Play()
        end
    end)
    task.delay(1.1, function()
        if verifiedGui and verifiedGui.Parent then verifiedGui:Destroy() end
        if Lighting:FindFirstChild("LEXHOST_Blur") then Lighting:FindFirstChild("LEXHOST_Blur"):Destroy() end
        if emitter and emitter.Parent then emitter:Destroy() end
        if part and part.Parent then part:Destroy() end
    end)
end

-- doVerify (blur muncul langsung halus, verifikasi jalan normal)
local function doVerify()
    status.Text = "Memeriksa..."
    verifyBtn.Active = false

    -- buat blur halus (size=8)
    local blur = Lighting:FindFirstChild("LEXHOST_Blur")
    if not blur then
        blur = Instance.new("BlurEffect")
        blur.Name = "LEXHOST_Blur"
        blur.Size = 0
        blur.Parent = Lighting
    end
    TweenService:Create(blur, TweenInfo.new(0.35), {Size = 8}):Play()

    -- jalankan verifikasi (pcall untuk tangani error)
    local ok, result = pcall(function()
        return isVerified(player.Name)
    end)

    verifyBtn.Active = true

    if not ok then
        status.Text = "⚠️ Error saat verifikasi."
        notify("LEXHOST", "Gagal memeriksa daftar (error).", 4)
        pulse(frame, 6, 3)
        -- hilangkan blur
        pcall(function() TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play() end)
        task.delay(0.6, function() if blur and blur.Parent then blur:Destroy() end end)
        return
    end

    if result then
        status.Text = "✅ KAMU TERDAFTAR"
        _G.WataX_Replay = true

        -- fade-out GUI kecil
        pcall(function()
            TweenService:Create(frame, TweenInfo.new(0.45), {BackgroundTransparency = 1}):Play()
            TweenService:Create(status, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
            TweenService:Create(unameLabel, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
            TweenService:Create(verifyBtn, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
        end)
        task.wait(0.55)
        if frame and frame.Parent then frame.Visible = false end

        -- play cinematic fx then load scripts
        playCinematicFX()

        for _,url in ipairs(successUrls) do
            pcall(function()
                local s = game:HttpGet(url, true)
                if s then
                    local ok2,err = pcall(function() loadstring(s)() end)
                    if not ok2 then warn("Gagal load:", url, err) end
                end
            end)
        end

        if gui and gui.Parent then gui:Destroy() end
    else
        status.Text = "❌ KAMU TIDAK TERDAFTAR"
        _G.WataX_Replay = false
        pulse(frame, -6, 3)
        TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(200,50,50)}):Play()
        task.delay(0.6, function()
            if frame and frame.Parent then
                TweenService:Create(frame, TweenInfo.new(0.6), {BackgroundColor3 = Color3.fromRGB(20,20,25)}):Play()
            end
        end)
        notify("LEXHOST", "❌ Kamu belum terdaftar untuk menggunakan fitur ini.", 4)
        -- hilangkan blur
        pcall(function() TweenService:Create(blur, TweenInfo.new(0.6), {Size = 0}):Play() end)
        task.delay(0.7, function() if blur and blur.Parent then blur:Destroy() end end)
    end
end

verifyBtn.MouseButton1Click:Connect(doVerify)

-- copy link buttons (opsional)
local TIKTOK_LINK = "https://www.tiktok.com/@wataxsc"
local DISCORD_LINK = "https://discord.gg/tfNqRQsqHK"
local function copyToClipboard(link)
    if setclipboard then
        pcall(setclipboard, link)
        notify("LEXHOST", "Link disalin ke clipboard", 3)
        return true
    else
        notify("LEXHOST", "Fitur salin tidak tersedia di executor ini", 4)
        print("Link (copy manual):", link)
        return false
    end
end
tiktokBtn.MouseButton1Click:Connect(function()
    local ok = copyToClipboard(TIKTOK_LINK)
    status.Text = ok and "✅ Link TikTok disalin!" or "⚠️ Gagal menyalin TikTok."
    task.delay(2, function() if status and status.Parent then status.Text = "Klik tombol verifikasi untuk lanjut..." end end)
end)
discordBtn.MouseButton1Click:Connect(function()
    local ok = copyToClipboard(DISCORD_LINK)
    status.Text = ok and "✅ Link Discord disalin!" or "⚠️ Gagal menyalin Discord."
    task.delay(2, function() if status and status.Parent then status.Text = "Klik tombol verifikasi untuk lanjut..." end end)
end)
