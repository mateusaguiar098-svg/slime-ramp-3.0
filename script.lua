-- Carrega a interface Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MEGA RAMP FOR SLIME",
   LoadingTitle = "Iniciando Sistema...",
   LoadingSubtitle = "Auto Farm + Equip Best",
   Size = UDim2.fromOffset(450, 320),
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- VARIÁVEIS DE CONTROLE
_G.InstantLastZone = false
_G.AutoEquipBest = false
_G.TempoCiclo = 0.5

-- FUNÇÃO PARA ENCONTRAR O PONTO FINAL (LAST ZONE / MAIOR MULTIPLICADOR)
local function obterZonaFinal()
    local zonaFinal = nil
    local maiorPosicaoY = -9999 -- Caso o final seja no ponto mais baixo/alto do mapa

    -- Procura no workspace por regiões de chegada ou partes com valores altos
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local nome = obj.Name:lower()
            if nome:find("end") or nome:find("finish") or nome:find("winner") or nome:find("last") or nome:find("zone") then
                zonaFinal = obj
                break
            end
        end
    end

    -- Fallback: Se não achar por nome específico, procura o bloco no fim da rampa principal
    if not zonaFinal then
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Folder") then
                for _, subObj in pairs(obj:GetDescendants()) do
                    if subObj:IsA("BasePart") and (subObj.Name:lower():find("pad") or subObj.Name:lower():find("reward")) then
                        zonaFinal = subObj
                        break
                    end
                end
            end
        end
    end

    return zonaFinal
end

-- LÓGICA DO TELEPORTE INSTANTÂNEO
local function executarTeleporte()
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart
        local humanoid = char:FindFirstChildOfClass("Humanoid")

        -- 1. Forçar a chamada de spawn do carro se o jogador não estiver num assento
        if not humanoid.SeatPart then
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    local n = remote.Name:lower()
                    if n:find("spawn") or n:find("car") or n:find("race") or n:find("start") then
                        if remote:IsA("RemoteEvent") then 
                            remote:FireServer() 
                        else 
                            remote:InvokeServer() 
                        end
                    end
                end
            end
            task.wait(0.2)
        end

        -- 2. Localiza o destino final e realiza o teleporte do veículo ou do personagem
        local destino = obterZonaFinal()
        if destino then
            local assento = humanoid.SeatPart
            if assento and assento.Parent and assento.Parent:IsA("Model") then
                -- Move o modelo completo do veículo
                assento.Parent:PivotTo(destino.CFrame + Vector3.new(0, 5, 0))
            else
                -- Move o personagem
                root.CFrame = destino.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end)
end

-- LÓGICA PARA EQUIPAR MELHOR SLIME
local function executarEquipBest()
    pcall(function()
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local n = remote.Name:lower()
                if n:find("equip") or n:find("best") or n:find("slime") then
                    if remote:IsA("RemoteEvent") then 
                        remote:FireServer() 
                    else 
                        remote:InvokeServer() 
                    end
                end
            end
        end
    end)
end

-- LOOP PRINCIPAL
task.spawn(function()
    while true do
        task.wait(_G.TempoCiclo)
        
        if _G.AutoEquipBest then
            executarEquipBest()
        end

        if _G.InstantLastZone then
            executarTeleporte()
        end
    end
end)

-- INTERFACE VISUAL (RAYFIELD)
local TabPrincipal = Window:CreateTab("Auto Farm", 4483362458)

TabPrincipal:CreateToggle({
   Name = "Instant Last Zone (Auto Farm)",
   CurrentValue = false,
   Flag = "ToggleInstantLastZone",
   Callback = function(Value)
      _G.InstantLastZone = Value
   end,
})

TabPrincipal:CreateToggle({
   Name = "Auto Equip Best Slime",
   CurrentValue = false,
   Flag = "ToggleEquipBest",
   Callback = function(Value)
      _G.AutoEquipBest = Value
   end,
})

TabPrincipal:CreateSlider({
   Name = "Velocidade do Ciclo (Segundos)",
   Range = {0.2, 2.0},
   Increment = 0.1,
   Suffix = " seg",
   CurrentValue = 0.5,
   Flag = "SliderTempo",
   Callback = function(Value)
      _G.TempoCiclo = Value
   end,
})
