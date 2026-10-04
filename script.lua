-- Carrega a interface Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Auto Farm | Mega Ramp",
   LoadingTitle = "Iniciando Script...",
   LoadingSubtitle = "Baseado na lógica Gumanba",
   Size = UDim2.fromOffset(450, 320),
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- VARIÁVEIS DE CONTROLE
_G.AutoFarmLoop = false
_G.TempoEspera = 1.0
local jaNotificouRaro = false

-- FUNÇÃO PARA ENCONTRAR A BASE / PLOT DO JOGADOR LOCAL
local function obterBaseDoJogador()
    local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Bases") or workspace:FindFirstChild("Tycoons")
    if plots then
        for _, plot in pairs(plots:GetChildren()) do
            -- Verifica se a base pertence ao jogador atual
            if plot:FindFirstChild("Owner") and tostring(plot.Owner.Value) == LocalPlayer.Name then
                return plot
            elseif plot.Name:find(LocalPlayer.Name) then
                return plot
            end
        end
    end
    return nil
end

-- TELEPORTE 1: QUADRADO DA SETA DA SUA BASE
local function irParaSetaBase()
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart

        local minhaBase = obterBaseDoJogador()
        
        -- Se achou a base do jogador, busca a seta nela
        if minhaBase then
            local startPad = minhaBase:FindFirstChild("StartPad", true) or minhaBase:FindFirstChild("Spawn", true) or minhaBase:FindFirstChild("Arrow", true)
            if startPad and startPad:IsA("BasePart") then
                root.CFrame = startPad.CFrame + Vector3.new(0, 3, 0)
                return
            end
        end

        -- Fallback: busca peças com nome de seta no mapa geral
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():find("startpad") or v.Name:lower():find("seta")) then
                root.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                return
            end
        end
    end)
end

-- TELEPORTE 2: FINAL DA RAMPA (CARRO + BONECO)
local function irParaFinalRampa()
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local assento = humanoid and humanoid.SeatPart

        local minhaBase = obterBaseDoJogador()
        local blocoFinal = nil

        -- Procura a rampa/zona final na base do jogador
        if minhaBase then
            blocoFinal = minhaBase:FindFirstChild("EndPad", true) or minhaBase:FindFirstChild("Finish", true) or minhaBase:FindFirstChild("MaxMultiplier", true)
        end

        -- Fallback: busca pelo multiplicador mais alto
        if not blocoFinal then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("endpad") or v.Name:lower():find("finish") or v.Name:find("1000000")) then
                    blocoFinal = v
                    break
                end
            end
        end

        if blocoFinal and blocoFinal:IsA("BasePart") then
            -- Se estiver no carro, move o veículo inteiro
            if assento and assento.Parent and assento.Parent:IsA("Model") then
                assento.Parent:PivotTo(blocoFinal.CFrame + Vector3.new(0, 5, 0))
            else
                root.CFrame = blocoFinal.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end)
end

-- MONITORADOR DE SLIME RARO
local function checarSlimeRaro()
    pcall(function()
        local achouRaro = false
        for _, obj in pairs(LocalPlayer:GetDescendants()) do
            local nome = string.lower(obj.Name)
            if nome:find("arco-íris") or nome:find("rainbow") or nome:find("limited") then
                achouRaro = true
                break
            end
        end

        if achouRaro and not jaNotificouRaro then
            jaNotificouRaro = true
            Rayfield:Notify({
               Title = " SLIME RARO!",
               Content = "Você obteve o Slime Arco-íris Limitado!",
               Duration = 8,
            })
        end
    end)
end

-- LOOP DO AUTO FARM
task.spawn(function()
    while true do
        task.wait(_G.TempoEspera)
        if _G.AutoFarmLoop then
            irParaSetaBase()
            task.wait(0.4)
            irParaFinalRampa()
            checarSlimeRaro()
        end
    end
end)

-- INTERFACE VISUAL
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
   Range = {0.3, 3},
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
          for _, v in pairs(ReplicatedStorage:GetDescendants()) do
              if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                  if v.Name:find("Equip") or v.Name:find("Best") then
                      if v:IsA("RemoteEvent") then v:FireServer() else v:InvokeServer() end
                  end
              end
          end
      end)
      Rayfield:Notify({
         Title = "Equipar Melhor",
         Content = "Comando enviado para equipar os melhores slimes!",
         Duration = 3
      })
   end,
})
