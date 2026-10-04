-- Carrega a interface Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Auto Farm | Mega Ramp",
   LoadingTitle = "Iniciando Projeto...",
   LoadingSubtitle = "Teleporte Instantâneo para o Final",
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
local jaNotificouRaro = false

-- FUNÇÃO PARA ENCONTRAR A BASE / PLOT DO JOGADOR LOCAL
local function obterBaseJogador()
    local bases = workspace:FindFirstChild("Bases") or workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Tycoons")
    if bases then
        for _, b in pairs(bases:GetChildren()) do
            if b:FindFirstChild("Owner") and tostring(b.Owner.Value) == LocalPlayer.Name then
                return b
            elseif b.Name == LocalPlayer.Name or b.Name:find(LocalPlayer.Name) then
                return b
            end
        end
    end
    return nil
end

-- FUNÇÃO DE TELEPORTE INSTANTÂNEO (SETA -> FINAL ABSOLUTO DA RAMPA)
local function executarTeleporteInstantaneo()
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart
        local humanoid = char:FindFirstChildOfClass("Humanoid")

        local minhaBase = obterBaseJogador()

        -- 1. Posiciona no quadrado branco da Seta (StartPad)
        local startPad = minhaBase and minhaBase:FindFirstChild("StartPad", true)
        if startPad then
            root.CFrame = startPad.CFrame + Vector3.new(0, 3, 0)
        end

        task.wait(0.15)

        -- 2. Localiza o ponto FINAL ABSOLUTO (EndPad / Último Multiplicador)
        local endPad = minhaBase and (minhaBase:FindFirstChild("EndPad", true) or minhaBase:FindFirstChild("Finish", true))

        -- Se não achar por nome na base, varre o mapa atrás do maior bloco final (ignora o meio x70000)
        if not endPad then
            local maiorVal = -1
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    local nome = v.Name:lower()
                    if nome:find("endpad") or nome:find("finish") or nome:find("1000000") or nome:find("500000") then
                        endPad = v
                        break
                    end
                end
            end
        end

        -- 3. Teleporta o veículo inteiro (ou o boneco) direto para o FINAL
        if endPad then
            local assento = humanoid and humanoid.SeatPart
            if assento and assento.Parent and assento.Parent:IsA("Model") then
                assento.Parent:PivotTo(endPad.CFrame + Vector3.new(0, 4, 0))
            else
                root.CFrame = endPad.CFrame + Vector3.new(0, 4, 0)
            end
        end
    end)
end

-- MONITORADOR DE SLIME RARO / RAINBOW
local function checarSlimeRaro()
    pcall(function()
        for _, obj in pairs(LocalPlayer:GetDescendants()) do
            local nome = string.lower(obj.Name)
            if (nome:find("rainbow") or nome:find("limited") or nome:find("arco-íris")) and not jaNotificouRaro then
                jaNotificouRaro = true
                Rayfield:Notify({
                   Title = "🌈 SLIME RARO ENCONTRADO!",
                   Content = "Você obteve um Slime Arco-íris / Limitado!",
                   Duration = 6
                })
                break
            end
        end
    end)
end

-- LOOP PRINCIPAL DO AUTO FARM
task.spawn(function()
    while true do
        task.wait(_G.TempoEspera)
        if _G.AutoFarmLoop then
            executarTeleporteInstantaneo()
            checarSlimeRaro()
        end
    end
end)

-- ==========================================
-- NOSSA INTERFACE VISUAL (RAYFIELD)
-- ==========================================
local TabFarm = Window:CreateTab("Auto Farm", 4483362458)

TabFarm:CreateToggle({
   Name = "Ligar Auto Farm Infinito (Final da Rampa)",
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
         Content = "Comando de equipar o melhor slime enviado!",
         Duration = 3
      })
   end,
})
