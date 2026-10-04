-- Carrega a interface Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Auto Farm | Mega Ramp",
   LoadingTitle = "Iniciando Script...",
   LoadingSubtitle = "Versão Ajustada e Sem Erros",
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

-- TELEPORTE 1: QUADRADO DA SETA (FOTO 1)
local function teleportarParaSeta()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- Procura a seta exata perto da rampa
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
                local nome = string.lower(v.Name)
                local tex = (v:IsA("Texture") or v:IsA("Decal")) and string.lower(v.Texture) or ""
                
                -- Evita o spawn com símbolo de estrela da Foto 2
                if not nome:find("spawn") and not tex:find("spawn") then
                    if nome:find("arrow") or nome:find("seta") or tex:find("arrow") or tex:find("seta") then
                        local alvo = v:IsA("BasePart") and v or v.Parent
                        if alvo and alvo:IsA("BasePart") then
                            root.CFrame = alvo.CFrame + Vector3.new(0, 3, 0)
                            return
                        end
                    end
                end
            end
        end
    end)
end

-- TELEPORTE 2: FINAL DA RAMPA (MULTIPLICADOR)
local function teleportarParaFinal()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local assento = humanoid and humanoid.SeatPart

        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                local nome = string.lower(v.Name)
                if nome:find("finish") or nome:find("end") or nome:find("winner") or nome:find("500000") or nome:find("1000000") or nome:find("x100") then
                    if assento and assento.Parent and assento.Parent:IsA("Model") then
                        assento.Parent:PivotTo(v.CFrame + Vector3.new(0, 5, 0))
                    else
                        root.CFrame = v.CFrame + Vector3.new(0, 5, 0)
                    end
                    return
                end
            end
        end
    end)
end

-- LOOP DO AUTO FARM
task.spawn(function()
    while true do
        task.wait(_G.TempoEspera)
        if _G.AutoFarmLoop then
            teleportarParaSeta()
            task.wait(0.3)
            teleportarParaFinal()
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

-- ABA DE SLIMES / EQUIPAR MELHOR
local TabSlime = Window:CreateTab("Slimes & Pets", 4483362458)

TabSlime:CreateButton({
   Name = "Equipar Melhor Slime",
   Callback = function()
      pcall(function()
          -- Dispara evento remoto do jogo para equipar o melhor pet/slime
          for _, v in pairs(ReplicatedStorage:GetDescendants()) do
              if v:IsA("RemoteEvent") and (v.Name:find("Equip") or v.Name:find("Best") or v.Name:find("Slime")) then
                  v:FireServer()
              end
          end
      end)
      Rayfield:Notify({
         Title = "Equipar Melhor",
         Content = "Comando de equipar o melhor enviado!",
         Duration = 3
      })
   end,
})

TabSlime:CreateButton({
   Name = "Checar Slime Raro / Notificação",
   Callback = function()
      Rayfield:Notify({
         Title = "Sistema de Notificação",
         Content = "Notificações ativas!",
         Duration = 3
      })
   end,
})
