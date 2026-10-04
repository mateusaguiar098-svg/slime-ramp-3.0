-- Carrega a interface Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Auto Farm | Mega Ramp",
   LoadingTitle = "Iniciando Script...",
   LoadingSubtitle = "Versão Estável e Rápida",
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

-- TELEPORTE PARA A SETA (INÍCIO)
local function teleportarParaSeta()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- Procura parte de início no workspace
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                local n = string.lower(v.Name)
                if n:find("arrow") or n:find("seta") or n:find("spawn") or n:find("start") then
                    root.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                    return
                end
            end
        end
    end)
end

-- TELEPORTE PARA O FINAL DA RAMPA
local function teleportarParaFinal()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local assento = humanoid and humanoid.SeatPart

        -- Procura o maior multiplicador
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                local n = string.lower(v.Name)
                if n:find("500000") or n:find("1000000") or n:find("finish") or n:find("end") or n:find("winner") then
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

local TabUGC = Window:CreateTab("Limitados", 4483362458)

TabUGC:CreateButton({
   Name = "Checar Slime Raro / Notificação",
   Callback = function()
      Rayfield:Notify({
         Title = "Sistema de Notificação",
         Content = "Notificações ativas e funcionando!",
         Duration = 4
      })
   end,
})
