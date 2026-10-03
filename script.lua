-- Carrega a biblioteca visual Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- MENU COMPACTO E CLEAN (Tamanho reduzido para não ocupar a tela)
local Window = Rayfield:CreateWindow({
   Name = "Auto Farm | Mega Ramp",
   LoadingTitle = "Iniciando...",
   LoadingSubtitle = "Versão Auto-Loop",
   Size = UDim2.fromOffset(450, 320), -- Menu bem menor na tela
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- VARIÁVEIS DE CONTROLE DO AUTO FARM
_G.AutoFarmLoop = false
_G.TempoEspera = 1.5 -- Tempo de espera entre os ciclos (segundos)

-- ==========================================================
-- FUNÇÕES DE AUTOMAÇÃO E LÓGICA DO JOGO
-- ==========================================================

-- 1. Procura e Teleporta para a plataforma de início (Quadrado com a Seta)
local function entrarNaPlataformaInicio()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    -- Busca partes com nomes comuns de início/spawn no jogo
    local startPad = workspace:FindFirstChild("StartPad", true) 
                     or workspace:FindFirstChild("SpawnRamp", true)
                     or workspace:FindFirstChild("SpawnVehicle", true)

    if startPad then
        char.HumanoidRootPart.CFrame = startPad.CFrame + Vector3.new(0, 3, 0)
    end
end

-- 2. Teleporta com segurança até a Caixa/Final (Até o limite máximo)
local function irAteOFinalEAbrirCaixa()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- Procura o ponto da Caixa Final / Recompensa de 7M+
    local chestOrFinish = workspace:FindFirstChild("Chest", true) 
                          or workspace:FindFirstChild("FinishZone", true) 
                          or workspace:FindFirstChild("EndPad", true)

    if chestOrFinish then
        -- Teleporta exatamente em cima da caixa para coletar/abrir
        char.HumanoidRootPart.CFrame = chestOrFinish.CFrame + Vector3.new(0, 4, 0)
    else
        -- Caso não ache pelo nome, vai até o fim máximo da rampa por posição
        char.HumanoidRootPart.CFrame = CFrame.new(0, 100, 10000) 
    end
    
    -- Dispara evento de toque/interação caso a caixa precise de clique/toque
    task.wait(0.5)
    local rewardRemote = ReplicatedStorage:FindFirstChild("ClaimChest", true) or ReplicatedStorage:FindFirstChild("OpenChest", true)
    if rewardRemote and rewardRemote:IsA("RemoteEvent") then
        rewardRemote:FireServer()
    end
end

-- 3. LOOP PRINCIPAL DE AUTO FARM AUTOMÁTICO
task.spawn(function()
    while true do
        task.wait(_G.TempoEspera)
        if _G.AutoFarmLoop then
            -- Passo A: Vai até o quadrado/seta da rampa
            entrarNaPlataformaInicio()
            task.wait(0.8)
            
            -- Passo B: Teleporta para o final supremo e abre a caixa
            irAteOFinalEAbrirCaixa()
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
-- INTERFACE VISUAL (ABAS E BOTÕES)
-- ==========================================================

-- ABA 1: Auto Farm
local TabFarm = Window:CreateTab("Auto Farm", 4483362458)

TabFarm:CreateToggle({
   Name = "Ligar Auto Farm Infinito (Até o Final)",
   CurrentValue = false,
   Flag = "ToggleAutoFarm",
   Callback = function(Value)
      _G.AutoFarmLoop = Value
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
