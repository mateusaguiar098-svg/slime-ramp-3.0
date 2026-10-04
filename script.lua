-- Carrega a interface Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Auto Farm | Mega Ramp",
   LoadingTitle = "Carregando Script...",
   LoadingSubtitle = "Versão Teleporte Rápido",
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

-- FUNÇÃO 1: Teleportar EXATAMENTE para o quadrado da seta (Início)
local function teleportarParaSeta()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
                local nome = string.lower(v.Name)
                local tex = (v:IsA("Texture") or v:IsA("Decal")) and string.lower(v.Texture) or ""
                
                -- Procura a seta do início
                if nome:find("arrow") or nome:find("seta") or tex:find("arrow") or tex:find("seta") or nome:find("start") or nome:find("spawn") then
                    local alvo = v:IsA("BasePart") and v or v.Parent
                    if alvo and alvo:IsA("BasePart") then
                        root.CFrame = alvo.CFrame + Vector3.new(0, 3, 0)
                        return
                    end
                end
            end
        end
    end)
end

-- FUNÇÃO 2: Teleportar para o FINAL da rampa (Carro + Boneco)
local function teleportarParaFinal()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local assento = humanoid and humanoid.SeatPart

        -- Procura o bloco de chegada no final da rampa
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                local nome = string.lower(v.Name)
                if nome:find("finish") or nome:find("end") or nome:find("winner") or nome:find("500000") or nome:find("1000000") or nome:find("x10") then
                    -- Se estiver sentado no carro, teleporta o carro todo!
                    if assento and assento.Parent and assento.Parent:IsA("Model") then
                        assento.Parent:PivotTo(v.CFrame + Vector3.new(0, 5, 0))
                    else
                        -- Se estiver a pé, teleporta só o boneco
                        root.CFrame = v.CFrame + Vector3.new(0, 5, 0)
                    end
                    return
                end
            end
        end
    end)
end

-- LOOP PRINCIPAL DO AUTO FARM
task.spawn(function()
    while true do
        task.wait(_G.TempoEspera)
        if _G.AutoFarmLoop then
            -- 1. Vai no quadrado da seta
            teleportarParaSeta()
            task.wait(0.3)
            
            -- 2. Vai para o final da rampa
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

local TabUGC = Window:CreateTab("Notificações", 4483362458)

TabUGC:CreateButton({
   Name = "Testar Notificação",
   Callback = function()
      Rayfield:Notify({
         Title = "Sistema de Notificação",
         Content = "Notificações ativas e funcionando perfeitamente!",
         Duration = 4
      })
   end,
})
