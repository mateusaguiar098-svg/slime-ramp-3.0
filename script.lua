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

-- CRIANDO INTERFACE NATIVA NA TELA
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
ToggleLastZone.TextSize = 14

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

CreditLabel.Parent = MainFrame
CreditLabel.Position = UDim2.new(0.05, 0, 0.82, 0)
CreditLabel.Size = UDim2.new(0.9, 0, 0, 20)
CreditLabel.Font = Enum.Font.SourceSansItalic
CreditLabel.Text = "Corrigido - Fim da Rampa"
CreditLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
CreditLabel.TextSize = 12

-- ==========================================
-- PROCURAR APENAS OS BLOCOS DE MULTIPLICADOR DA PISTA
-- ==========================================
local function obterFimDaPista()
    local melhorAlvo = nil
    local maiorZ = -999999

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local nome = v.Name:lower()
            -- Busca blocos da rampa que contenham números de multiplicador (ex: x1000, x50000) ou blocos coloridos finais
            if nome:find("x") or nome:find("ramp") or nome:find("track") or nome:find("mult") then
                if v.Position.Z > maiorZ and v.Position.Y > 0 and v.Position.Y < 50 then -- Filtra para não pegar o teto nem o slime alto
                    maiorZ = v.Position.Z
                    melhorAlvo = v
                end
            end
        end
    end
    return melhorAlvo
end

-- ==========================================
-- LOOP PRINCIPAL
-- ==========================================
task.spawn(function()
    while true do
        task.wait(0.3)
        
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

        if _G.InstantLastZone then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local assento = humanoid and humanoid.SeatPart

                local fimPista = obterFimDaPista()
                
                if fimPista and assento and assento.Parent then
                    local carroModel = assento.Parent
                    -- Teleporta para o último bloco da pista, mas mantendo a altura correta (acima da pista, longe do slime)
                    carroModel:PivotTo(fimPista.CFrame + Vector3.new(0, 4, -10))
                elseif fimPista then
                    char.HumanoidRootPart.CFrame = fimPista.CFrame + Vector3.new(0, 4, -10)
                end
            end)
        end
    end
end)
