local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local isActive = true
local isBeton = false
local animConn
local rgbConn

-- Fungsi utama setup
local function setup(char)
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    local lastPos = hrp.Position
    local jumpCooldown = false

    if animConn then animConn:Disconnect() end
    animConn = RunService.RenderStepped:Connect(function()
        if not hrp or not hrp.Parent then return end

        if isActive then
            local direction = (hrp.Position - lastPos)
            local dist = direction.Magnitude

            if dist > 0.01 then
                local moveVector = direction.Unit * math.clamp(dist * 5, 0, 1)
                humanoid:Move(moveVector, false)
            else
                humanoid:Move(Vector3.zero, false)
            end

            local deltaY = hrp.Position.Y - lastPos.Y
            if deltaY > 0.9 and not jumpCooldown then
                humanoid.Jump = true
                jumpCooldown = true
                task.delay(0.4, function()
                    jumpCooldown = false
                end)
            end
        end

        if isBeton then
            humanoid.Health = humanoid.MaxHealth
        end

        lastPos = hrp.Position
    end)
end

player.CharacterAdded:Connect(setup)
if player.Character then setup(player.Character) end


-- 🟣 Fungsi UI
local function createUI()
    if player.PlayerGui:FindFirstChild("LexUI_Frame") then
        player.PlayerGui.LexUI_Frame:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LexUI_Frame"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = player:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 180, 0, 100)
    Frame.Position = UDim2.new(0.05, 0, 0.05, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 25)
    Label.Position = UDim2.new(0, 5, 0, 5)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 100, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 16
    Label.Text = "Lex UI"
    Label.Parent = Frame

    -- 🌈 Animasi RGB untuk teks
    if rgbConn then rgbConn:Disconnect() end
    local hue = 0
    rgbConn = RunService.RenderStepped:Connect(function(dt)
        hue = (hue + dt * 0.3) % 1
        Label.TextColor3 = Color3.fromHSV(hue, 1, 1)
    end)

    local AnimBtn = Instance.new("TextButton")
    AnimBtn.Size = UDim2.new(1, -10, 0, 30)
    AnimBtn.Position = UDim2.new(0, 5, 0, 35)
    AnimBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    AnimBtn.BorderSizePixel = 0
    AnimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AnimBtn.Font = Enum.Font.GothamBold
    AnimBtn.TextSize = 14
    AnimBtn.Text = "BYPASS: ON"
    AnimBtn.Parent = Frame

    local AnimCorner = Instance.new("UICorner")
    AnimCorner.CornerRadius = UDim.new(0, 8)
    AnimCorner.Parent = AnimBtn

    AnimBtn.MouseButton1Click:Connect(function()
        isActive = not isActive
        if isActive then
            AnimBtn.Text = "BYPASS: ON"
            AnimBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        else
            AnimBtn.Text = "BYPASS: OFF"
            AnimBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        end
    end)

    local BetonBtn = Instance.new("TextButton")
    BetonBtn.Size = UDim2.new(1, -10, 0, 30)
    BetonBtn.Position = UDim2.new(0, 5, 0, 70)
    BetonBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 120)
    BetonBtn.BorderSizePixel = 0
    BetonBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    BetonBtn.Font = Enum.Font.GothamBold
    BetonBtn.TextSize = 14
    BetonBtn.Text = "KEBAL: OFF"
    BetonBtn.Parent = Frame

    local BetonCorner = Instance.new("UICorner")
    BetonCorner.CornerRadius = UDim.new(0, 8)
    BetonCorner.Parent = BetonBtn

    BetonBtn.MouseButton1Click:Connect(function()
        isBeton = not isBeton
        if isBeton then
            BetonBtn.Text = "KEBAL: ON"
            BetonBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
        else
            BetonBtn.Text = "KEBAL: OFF"
            BetonBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 120)
        end
    end)
end

createUI()

player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if not player.PlayerGui:FindFirstChild("LexUI_Frame") then
        createUI()
    end
end)

print("✅ Lex UI | Anim + Beton + Auto Jump aktif (RGB Header)")
