]-- Carrega a interface Rayfield
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("Falha ao carregar Rayfield UI")
    return
end

local Window = Rayfield:CreateWindow({
   Name = "Auto Farm | Mega Ramp",
   LoadingTitle = "Iniciando...",
   LoadingSubtitle = "Modo Velocidade Física",
   Size = UDim2.fromOffset(450, 320),
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- VARIÁVEIS DE CONTROLE
_G.AutoFarmLoop = false
_G.VelocidadeCarro = 300
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
                if dist < menorDist then
                    menorDist = dist
                    melhorAlvo = v
                end
            end
        end
    end
    return melhorAlvo
end

-- 2. APLICAR IMPULSO FÍSICO NO VEÍCULO
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

-- 3. CICLO DE EXECUÇÃO
local function executarCicloFarm()
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart
        local humanoid = char:FindFirstChildOfClass("Humanoid")

        local startPad = obterStartPad()

        -- Teleporta para o início
        if startPad then
            if humanoid and humanoid.SeatPart and humanoid.SeatPart.Parent then
                humanoid.SeatPart.Parent:PivotTo(startPad.CFrame + Vector3.new(0, 3, 0))
            else
                root.CFrame = startPad.CFrame + Vector3.new(0, 3, 0)
            end
        end

        task.wait(0.2)

        -- Impulsiona o carro rampa abaixo
        local contador = 0
        while contador < 2.5 and _G.AutoFarmLoop do
            impulsionarCarro()
            task.wait(0.1)
            contador = contador + 0.1
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

-- INTERFACE VISUAL
local TabFarm = Window:CreateTab("Auto Farm", 4483362458)

TabFarm:CreateToggle({
   Name = "Ligar Auto Farm Aceleração",
   CurrentValue = false,
   Flag = "ToggleAutoFarm",
   Callback = function(Value)
      _G.AutoFarmLoop = Value
   end,
})

TabFarm:CreateSlider({
   Name = "Velocidade do Carro",
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
   Name = "Intervalo do Ciclo",
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
   end,
})
