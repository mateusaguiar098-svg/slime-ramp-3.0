-- Carrega a interface Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Auto Farm | Mega Ramp",
   LoadingTitle = "Iniciando...",
   LoadingSubtitle = "Modo Velocidade Física Pro",
   Size = UDim2.fromOffset(450, 320),
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- VARIÁVEIS DE CONTROLE
_G.AutoFarmLoop = false
_G.VelocidadeCarro = 300 -- Velocidade padrão ajustável (100x a 1200x)
_G.TempoEspera = 1.0

-- 1. LOCALIZAR O STARTPAD (SETA CENTRAL)
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
                if dist < menorDist:
                    menorDist = dist
                    melhorAlvo = v
                end
            end
        end
    end
    return melhorAlvo
end

-- 2. ACELERAR E EMPURRAR O CARRO NA RAMPA COM VELOCIDADE REAL
local function impulsionarCarro()
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local assento = humanoid and humanoid.SeatPart

        -- Se estiver no carro, aplica aceleração física no modelo
        if assento and assento.Parent then
            local carroModel = assento.Parent
            local mainPart = carroModel:FindFirstChild("PrimaryPart") or assento

            -- Direção para a frente da rampa
            local direcao = mainPart.CFrame.LookVector
            
            -- Aplica velocidade contínua no veículo para deslizar e pontuar
            if mainPart:IsA("BasePart") then
                mainPart.AssemblyLinearVelocity = direcao * _G.VelocidadeCarro
            end
        end
    end)
end

-- LÓGICA DO CICLO COMPLETO
local function executarCicloFarm()
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart
        local humanoid = char:FindFirstChildOfClass("Humanoid")

        local startPad = obterStartPad()

        -- 1. Reposiciona na seta de largada
        if startPad then
            if humanoid.SeatPart and humanoid.SeatPart.Parent then
                humanoid.SeatPart.Parent:PivotTo(startPad.CFrame + Vector3.new(0, 3, 0))
            else
                root.CFrame = startPad.CFrame + Vector3.new(0, 3, 0)
            end
        end

        task.wait(0.2)

        -- 2. Dispara a aceleração de alta velocidade pela rampa abaixo
        local tempoAcelerando = 0
        while tempoAcelerando < 2.5 e _G.AutoFarmLoop do
            impulsionarCarro()
            task.wait(0.1)
            tempoAcelerando = tempoAcelerando + 0.1
        end
    end)
end

-- LÓGICA DO EQUIP BEST
local function executarEquipBest()
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

-- LOOP PRINCIPAL
task.spawn(function()
    while true do
        task.wait(_G.TempoEspera)
        if _G.AutoFarmLoop then
            executarCicloFarm()
        end
    end
end)

-- ==========================================
-- INTERFACE VISUAL (RAYFIELD)
-- ==========================================
local TabFarm = Window:CreateTab("Auto Farm", 4483362458)

TabFarm:CreateToggle({
   Name = "Ligar Auto Farm com Aceleração",
   CurrentValue = false,
   Flag = "ToggleAutoFarm",
   Callback = function(Value)
      _G.AutoFarmLoop = Value
   end,
})

TabFarm:CreateSlider({
   Name = "Velocidade do Carro na Rampa",
   Range = {100, 1200},
   Increment = 50,
   Suffix = "x Vel",
   CurrentValue = 300,
   Flag = "SliderVelocidadeCarro",
   Callback = function(Value)
      _G.VelocidadeCarro = Value
   end,
})

TabFarm:CreateSlider({
   Name = "Intervalo de Reinício (Segundos)",
   Range = {0.5, 4.0},
   Increment = 0.1,
   Suffix = " seg",
   CurrentValue = 1.0,
   Flag = "SliderTempo",
   Callback = function(Value)
      _G.TempoEspera = Value
   end,
})

local TabSlime = Window:CreateTab("Slimes & Pets", 4483362458)

TabSlime:CreateButton({
   Name = "Equipar Melhor Slime",
   Callback = function()
      executarEquipBest()
      Rayfield:Notify({
         Title = "Equipar Melhor",
         Content = "Comando de equipar enviado!",
         Duration = 3
      })
   end,
})
