-- Carrega a interface Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Auto Farm | Mega Ramp",
   LoadingTitle = "Iniciando...",
   LoadingSubtitle = "Lógica Gumanba Decodificada",
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

-- FUNÇÃO PARA LOCALIZAR A BASE/PISTA DO JOGADOR
local function obterMinhaBase()
    local bases = workspace:FindFirstChild("Bases") or workspace:FindFirstChild("Plots")
    if bases then
        for _, base in pairs(bases:GetChildren()) do
            if base:FindFirstChild("Owner") and tostring(base.Owner.Value) == LocalPlayer.Name then
                return base
            elseif base.Name == LocalPlayer.Name or base.Name:find(LocalPlayer.Name) then
                return base
            end
        end
    end
    return nil
end

-- LÓGICA DO AUTO FARM VIA REMOTES + TELEPORTE
local function executarCicloFarm()
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart
        local humanoid = char:FindFirstChildOfClass("Humanoid")

        local minhaBase = obterMinhaBase()
        if not minhaBase then return end

        local startPad = minhaBase:FindFirstChild("StartPad", true)
        local endPad = minhaBase:FindFirstChild("EndPad", true) or minhaBase:FindFirstChild("Finish", true)

        -- 1. Mover para o StartPad (Seta)
        if startPad then
            if humanoid.SeatPart and humanoid.SeatPart.Parent then
                humanoid.SeatPart.Parent:PivotTo(startPad.CFrame + Vector3.new(0, 3, 0))
            else
                root.CFrame = startPad.CFrame + Vector3.new(0, 3, 0)
            end
        end

        task.wait(0.3)

        -- 2. Disparar avisos/remotes de início caso existam no jogo
        local events = ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage
        for _, remote in pairs(events:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local nome = remote.Name:lower()
                if nome:find("start") or nome:find("race") or nome:find("spawn") then
                    remote:FireServer()
                end
            end
        end

        task.wait(0.2)

        -- 3. Mover para o EndPad (Multiplicador Máximo no topo)
        if endPad then
            if humanoid.SeatPart and humanoid.SeatPart.Parent then
                humanoid.SeatPart.Parent:PivotTo(endPad.CFrame + Vector3.new(0, 4, 0))
            else
                root.CFrame = endPad.CFrame + Vector3.new(0, 4, 0)
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

-- INTERFACE VISUAL (RAYFIELD)
local TabPrincipal = Window:CreateTab("Principal", 4483362458)

TabPrincipal:CreateToggle({
   Name = "Ligar Auto Farm Infinito",
   CurrentValue = false,
   Flag = "ToggleAutoFarm",
   Callback = function(Value)
      _G.AutoFarmLoop = Value
   end,
})

TabPrincipal:CreateSlider({
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

TabPrincipal:CreateButton({
   Name = "Equipar Melhor Slime",
   Callback = function()
      pcall(function()
          local events = ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage
          for _, v in pairs(events:GetDescendants()) do
              if v:IsA("RemoteEvent") and (v.Name:lower():find("equip") or v.Name:lower():find("best")) then
                  v:FireServer()
              end
          end
      end)
      Rayfield:Notify({
         Title = "Sucesso!",
         Content = "Comando de equipar os melhores slimes enviado ao servidor!",
         Duration = 3
      })
   end,
})

TabPrincipal:CreateButton({
   Name = "Testar Notificações",
   Callback = function()
      Rayfield:Notify({
         Title = "Sistema Ativo",
         Content = "Notificações e monitoramento funcionando!",
         Duration = 4
      })
   end,
})
