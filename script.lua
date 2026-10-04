-- DESTROÍ INTERFACE ANTIGA SE EXISTIR
if game:GetService("CoreGui"):FindFirstChild("AutoFarmRampGui") then
    game:GetService("CoreGui").AutoFarmRampGui:Destroy()
end

-- VARIÁVEIS DE CONTROLE
_G.AutoFarmLoop = false
_G.VelocidadeCarro = 300
_G.TempoEspera = 1.0

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- CREATING SCREEN GUI NATIVA
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local EquipBtn = Instance.new("TextButton")
local SpeedPlusBtn = Instance.new("TextButton")
local SpeedMinusBtn = Instance.new("TextButton")
local SpeedLabel = Instance.new("TextLabel")

ScreenGui.Name = "AutoFarmRampGui"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- JANELA PRINCIPAL
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 220)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "AUTO FARM | MEGA RAMP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

-- BOTÃO DE LIGAR/DESLIGAR
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = MainFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.22, 0)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Text = "AUTO FARM: DESLIGADO"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 15

ToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoFarmLoop = not _G.AutoFarmLoop
    if _G.AutoFarmLoop then
        ToggleBtn.Text = "AUTO FARM: LIGADO"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
    else
        ToggleBtn.Text = "AUTO FARM: DESLIGADO"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    end
end)

-- CONTROLE DE VELOCIDADE
SpeedLabel.Parent = MainFrame
SpeedLabel.Position = UDim2.new(0.05, 0, 0.42, 0)
SpeedLabel.Size = UDim2.new(0.9, 0, 0, 20)
SpeedLabel.Font = Enum.Font.SourceSans
SpeedLabel.Text = "Velocidade: " .. tostring(_G.VelocidadeCarro) .. "x"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 14

SpeedMinusBtn.Parent = MainFrame
SpeedMinusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedMinusBtn.Position = UDim2.new(0.05, 0, 0.54, 0)
SpeedMinusBtn.Size = UDim2.new(0.42, 0, 0, 30)
SpeedMinusBtn.Font = Enum.Font.SourceSansBold
SpeedMinusBtn.Text = "- 50 Vel"
SpeedMinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedMinusBtn.TextSize = 14

SpeedMinusBtn.MouseButton1Click:Connect(function()
    if _G.VelocidadeCarro > 50 then
        _G.VelocidadeCarro = _G.VelocidadeCarro - 50
        SpeedLabel.Text = "Velocidade: " .. tostring(_G.VelocidadeCarro) .. "x"
    end
end)

SpeedPlusBtn.Parent = MainFrame
SpeedPlusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedPlusBtn.Position = UDim2.new(0.53, 0, 0.54, 0)
SpeedPlusBtn.Size = UDim2.new(0.42, 0, 0, 30)
SpeedPlusBtn.Font = Enum.Font.SourceSansBold
SpeedPlusBtn.Text = "+ 50 Vel"
SpeedPlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedPlusBtn.TextSize = 14

SpeedPlusBtn.MouseButton1Click:Connect(function()
    if _G.VelocidadeCarro < 2000 then
        _G.VelocidadeCarro = _G.VelocidadeCarro + 50
        SpeedLabel.Text = "Velocidade: " .. tostring(_G.VelocidadeCarro) .. "x"
    end
end)

-- BOTÃO EQUIPAR MELHOR SLIME
EquipBtn.Parent = MainFrame
EquipBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
EquipBtn.Position = UDim2.new(0.05, 0, 0.72, 0)
EquipBtn.Size = UDim2.new(0.9, 0, 0, 35)
EquipBtn.Font = Enum.Font.SourceSansBold
EquipBtn.Text = "EQUIPAR MELHOR SLIME"
EquipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EquipBtn.TextSize = 14

EquipBtn.MouseButton1Click:Connect(function()
    pcall(function()
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local n = remote.Name:lower()
                if n:find("equip") or n:find("best") then
                    if remote:IsA("RemoteEvent") then remote:FireServer() else remote:InvokeServer() end
                end
            end
        end
    end)
end)

-- ==========================================
-- LÓGICA DO AUTO FARM (ACELERAR NA RAMPA)
-- ==========================================
local function obterStartPad()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local root = char.HumanoidRootPart

    local melhorAlvo = nil
    local menorDist = 9999

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local nome = v.Name:lower()
            if nome == "startpad" or nome:find("arrow") or nome:find("seta") then
                local dist = (v.Position - root.Position).Magnitude
                if dist < menorDist then
                    menorDist = dist
                    melhorAlvo = v
                end
            end
        end
    end
    return melhorAlvo
end

local function impulsionarCarro()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local assento = humanoid and humanoid.SeatPart

        if assento and assento.Parent then
            local carroModel = assento.Parent
            local mainPart = carroModel:FindFirstChild("PrimaryPart") or assento

            if mainPart and mainPart:IsA("BasePart") then
                local direcao = mainPart.CFrame.LookVector
                mainPart.AssemblyLinearVelocity = direcao * _G.VelocidadeCarro
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(_G.TempoEspera)
        if _G.AutoFarmLoop then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local root = char.HumanoidRootPart
                local humanoid = char:FindFirstChildOfClass("Humanoid")

                local startPad = obterStartPad()

                if startPad then
                    if humanoid and humanoid.SeatPart and humanoid.SeatPart.Parent then
                        humanoid.SeatPart.Parent:PivotTo(startPad.CFrame + Vector3.new(0, 3, 0))
                    else
                        root.CFrame = startPad.CFrame + Vector3.new(0, 3, 0)
                    end
                end

                task.wait(0.2)

                local c = 0
                while c < 2.5 and _G.AutoFarmLoop do
                    impulsionarCarro()
                    task.wait(0.1)
                    c = c + 0.1
                end
            end)
        end
    end
end)
