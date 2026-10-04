-- DESTROÍ INTERFACE ANTIGA SE EXISTIR
if game:GetService("CoreGui"):FindFirstChild("AutoFarmRampGui") then
    game:GetService("CoreGui").AutoFarmRampGui:Destroy()
end

-- VARIÁVEIS DE CONTROLE
_G.InstantLastZone = false
_G.EquipBest = false

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- CRIANDO INTERFACE NATIVA NA TELA (ESTILO TORA ISME)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleLastZone = Instance.new("TextButton")
local ToggleEquip = Instance.new("TextButton")
local CreditLabel = Instance.new("TextLabel")

ScreenGui.Name = "AutoFarmRampGui"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 280, 0, 190)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "MEGA RAMP FOR SLIME"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15

-- BOTÃO INSTANT LAST ZONE
ToggleLastZone.Name = "ToggleLastZone"
ToggleLastZone.Parent = MainFrame
ToggleLastZone.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleLastZone.Position = UDim2.new(0.05, 0, 0.25, 0)
ToggleLastZone.Size = UDim2.new(0.9, 0, 0, 40)
ToggleLastZone.Font = Enum.Font.SourceSansBold
ToggleLastZone.Text = "Instant LastZone: [ OFF ]"
ToggleLastZone.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleLastZone.TextSize, ToggleLastZone.AutoButtonColor = 14, true

ToggleLastZone.MouseButton1Click:Connect(function()
    _G.InstantLastZone = not _G.InstantLastZone
    if _G.InstantLastZone then
        ToggleLastZone.Text = "Instant LastZone: [ ON ]"
        ToggleLastZone.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
    else
        ToggleLastZone.Text = "Instant LastZone: [ OFF ]"
        ToggleLastZone.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    end
end)

-- BOTÃO EQUIP BEST
ToggleEquip.Name = "ToggleEquip"
ToggleEquip.Parent = MainFrame
ToggleEquip.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleEquip.Position = UDim2.new(0.05, 0, 0.53, 0)
ToggleEquip.Size = UDim2.new(0.9, 0, 0, 40)
ToggleEquip.Font = Enum.Font.SourceSansBold
ToggleEquip.Text = "Equip Best: [ OFF ]"
ToggleEquip.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleEquip.TextSize = 14

ToggleEquip.MouseButton1Click:Connect(function()
    _G.EquipBest = not _G.EquipBest
    if _G.EquipBest then
        ToggleEquip.Text = "Equip Best: [ ON ]"
        ToggleEquip.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
    else
        ToggleEquip.Text = "Equip Best: [ OFF ]"
        ToggleEquip.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    end
end)

-- CRÉDITOS
CreditLabel.Parent = MainFrame
CreditLabel.Position = UDim2.new(0.05, 0, 0.82, 0)
CreditLabel.Size = UDim2.new(0.9, 0, 0, 20)
CreditLabel.Font = Enum.Font.SourceSansItalic
CreditLabel.Text = "YouTube: Mateus / Baseado no Tora IsMe"
CreditLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
CreditLabel.TextSize = 12

-- ==========================================
-- BUSCAR A ÚLTIMA ZONA (FINAL DA RAMPA)
-- ==========================================
local function obterUltimaZona()
    local melhorAlvo = nil
    local maiorZ = -999999

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local nome = v.Name:lower()
            -- Procura por peças no final da rampa (maior distância/posição Z ou blocos de pontuação máxima)
            if nome:find("zone") or nome:find("end") or nome:find("finish") or nome:find("multi") or v.Position.Z > maiorZ then
                if v.Position.Z > maiorZ then
                    maiorZ = v.Position.Z
                    melhorAlvo = v
                end
            end
        end
    end
    return melhorAlvo
end

-- ==========================================
-- LOOP PRINCIPAL DO INSTANT LASTZONE & EQUIP BEST
-- ==========================================
task.spawn(function()
    while true do
        task.wait(0.2)
        
        -- Equip Best Automático se ativado
        if _G.EquipBest then
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
        end

        -- Instant LastZone
        if _G.InstantLastZone then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local assento = humanoid and humanoid.SeatPart

                -- Localiza o ponto final da rampa (LastZone)
                local ultimaZona = obterUltimaZona()
                
                if ultimaZona and assento and assento.Parent then
                    local carroModel = assento.Parent
                    -- Teleporta o carro instantaneamente para a última zona recolhendo a pontuação máxima
                    carroModel:PivotTo(ultimaZona.CFrame + Vector3.new(0, 5, 0))
                elseif ultimaZona then
                    char.HumanoidRootPart.CFrame = ultimaZona.CFrame + Vector3.new(0, 5, 0)
                end
            end)
        end
    end
end)
