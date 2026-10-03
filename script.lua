-- Carrega a biblioteca visual Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- MENU COMPACTO E CLEAN
local Window = Rayfield:CreateWindow({
   Name = "Auto Farm | Mega Ramp",
   LoadingTitle = "Iniciando...",
   LoadingSubtitle = "Versão Final Corrigida",
   Size = UDim2.fromOffset(450, 320),
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- VARIÁVEIS DE CONTROLE
_G.AutoFarmLoop = false
_G.TempoEspera = 1.5

-- ==========================================================
-- FUNÇÕES DE BUSCA DINÂMICA NO MAPA
-- ==========================================================

-- Função para achar o quadrado com a seta (Entrar no Carro)
local function irParaQuadradoSeta()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- Procura no workspace por plataformas de Spawn/Seta
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local nome = string.lower(obj.Name)
            if nome:find("arrow") or nome:find("seta") or nome:find("spawn") or nome:find("start") or nome:find("pad") then
                -- Teleporta para cima da plataforma da seta
                char.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                return
            end
        end
    end
end

-- Função para ir até o Slime Gigante / Final da Rampa (Dentro dos limites)
local function irParaFinalDaRampa()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- Procura o ponto final legítimo (Slime Gigante / Chest / Finish)
    local pontoFinal = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local nome = string.lower(obj.Name)
            if nome:find("giant") or nome:find("chest") or nome:find("finish") or nome:find("end") or nome:find("caixa") or nome:find("win") then
                pontoFinal = obj
                break
            end
        end
    end

    if pontoFinal then
        if pontoFinal:IsA("Model") then
            char.HumanoidRootPart.CFrame = pontoFinal:GetPivot() + Vector3.new(0, 4, 0)
        else
            char.HumanoidRootPart.CFrame = pontoFinal.CFrame + Vector3.new(0, 4, 0)
        end
    end
end

-- Função para Equipar o Melhor Slime
local function equiparMelhorSlime()
    local remote = ReplicatedStorage:FindFirstChild("EquipBest", true) 
                   or ReplicatedStorage:FindFirstChild("EquipBestPets", true)
                   or ReplicatedStorage:FindFirstChild("AutoEquip", true)

    if remote and remote:IsA("RemoteFunction") then
        remote:InvokeServer()
    elseif remote and remote:IsA("RemoteEvent") then
        remote:FireServer()
    end
end

-- Loop Principal Automático
task.spawn(function()
    while true do
        task.wait(_G.TempoEspera)
        if _G.AutoFarmLoop then
            -- 1. Vai para o quadrado com a seta para entrar no carro
            irParaQuadradoSeta()
            task.wait(0.8)
            
            -- 2. Teleporta para a zona do Slime Gigante no final da rampa
            irParaFinalDaRampa()
            task.wait(1)
        end
    end
end)

-- Function para checar o estoque de limitados
local function checarEstoqueLimitados()
    local ugcFolder = ReplicatedStorage:FindFirstChild("UGCStock") or ReplicatedStorage:FindFirstChild("Limiteds")
    if ugcFolder then
        local estoque = ugcFolder:GetAttribute("Stock") or 0
        return "Limitados Restantes: " .. tostring(estoque)
    else
        return "Sem estoque detectado / Esgotado"
    end
end

-- ==========================================================
-- INTERFACE VISUAL
-- ==========================================================

-- ABA 1: Auto Farm
local TabFarm = Window:CreateTab("Auto Farm", 4483362458)

TabFarm:CreateToggle({
   Name = "Ligar Auto Farm Infinito",
   CurrentValue = false,
   Flag = "ToggleAutoFarm",
   Callback = function(Value)
      _G.AutoFarmLoop = Value
   end,
})

TabFarm:CreateButton({
   Name = "Equipar Melhor Slime",
   Callback = function()
      equiparMelhorSlime()
   end,
})

TabFarm:CreateSlider({
   Name = "Velocidade do Ciclo (Segundos)",
   Range = {0.5, 5},
   Increment = 0.5,
   Suffix = " seg",
   CurrentValue = 1.5,
   Flag = "SliderTempo",
   Callback = function(Value)
      _G.TempoEspera = Value
   end,
})

-- ABA 2: Limitados / UGC
local TabUGC = Window:CreateTab("Limitados", 4483362458)

local LabelLimitados = TabUGC:CreateLabel("Verificando estoque...")

task.spawn(function()
    while task.wait(5) do
        LabelLimitados:Set(checarEstoqueLimitados())
    end
end)
