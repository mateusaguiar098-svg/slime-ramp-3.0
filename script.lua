-- Carrega a interface Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Auto Farm | Mega Ramp",
   LoadingTitle = "Iniciando...",
   LoadingSubtitle = "Teleporte Direto pela Rampa Central",
   Size = UDim2.fromOffset(450, 320),
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- VARIÁVEIS DE CONTROLE
_G.AutoFarmLoop = false
_G.TempoEspera = 0.5

-- 1. LOCALIZAR A SETA DE LARGADA (ÁREA CENTRAL)
local function obterSetaCentral()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local root = char.HumanoidRootPart

    local melhorAlvo = nil
    local menorDistancia = 9999

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local nome = v.Name:lower()
            -- Busca direta por StartPad ou peças com textura de seta/arrow
            if nome == "startpad" or nome:find("arrow") or nome:find("seta") then
                local dist = (v.Position - root.Position).Magnitude
                if dist < menorDistancia then
                    menorDistancia = dist
                    melhorAlvo = v
                end
            end
        end
    end
    return melhorAlvo
end

-- 2. LOCALIZAR O FINAL ABSOLUTO DA RAMPA (MAIOR MULTIPLICADOR)
local function obterFinalRampa()
    local pontoFinal = nil
    local maiorVal = -1

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local nome = v.Name:lower()
            if nome:find("endpad") or nome:find("finish") or nome:find("1000000") or nome:find("500000") or nome:find("70000") then
                pontoFinal = v
                break
            end
        end
    end

    return pontoFinal
end

-- LÓGICA DE TELEPORTE INSTANTÂNEO
local function executarTeleporteRampa()
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart
        local humanoid = char:FindFirstChildOfClass("Humanoid")

        local seta = obterSetaCentral()
        local finalRampa = obterFinalRampa()

        -- 1. Posiciona na Seta Central de Largada
        if seta then
            if humanoid.SeatPart and humanoid.SeatPart.Parent then
                humanoid.SeatPart.Parent:PivotTo(seta.CFrame + Vector3.new(0, 3, 0))
            else
                root.CFrame = seta.CFrame + Vector3.new(0, 3, 0)
            end
        end

        task.wait(0.15)

        -- 2. Dispara o teleporte instantâneo para o Final da Rampa
        if finalRampa then
            local assento = humanoid and humanoid.SeatPart
            if assento and assento.Parent and assento.Parent:IsA("Model") then
                assento.Parent:PivotTo(finalRampa.CFrame + Vector3.new(0, 4, 0))
            else
                root.CFrame = finalRampa.CFrame + Vector3.new(0, 4, 0)
            end
        end
    end)
end

-- LOOP PRINCIPAL
task.spawn(function()
    while true do
        task.wait(_G.TempoEspera)
        if _G.AutoFarmLoop then
            executarTeleporteRampa()
        end
    end
end)

-- INTERFACE VISUAL (RAYFIELD)
local TabFarm = Window:CreateTab("Auto Farm", 4483362458)

TabFarm:CreateToggle({
   Name = "Ligar Auto Farm Infinito",
   CurrentValue = false,
   Flag = "ToggleAutoFarm",
   Callback = function(Value)
      _G.AutoFarmLoop = Value
   end,
})

TabFarm:CreateSlider({
   Name = "Velocidade do Ciclo (Segundos)",
   Range = {0.2, 2.0},
   Increment = 0.1,
   Suffix = " seg",
   CurrentValue = 0.5,
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
          for _, v in pairs(ReplicatedStorage:GetDescendants()) do
              if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                  local n = v.Name:lower()
                  if n:find("equip") or n:find("best") then
                      if v:IsA("RemoteEvent") then v:FireServer() else v:InvokeServer() end
                  end
              end
          end
      end)
      Rayfield:Notify({
         Title = "Equipar Melhor",
         Content = "Comando enviado para o servidor!",
         Duration = 3
      })
   end,
})
