-- Carrega a biblioteca visual Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- MENU COMPACTO E CLEAN
local Window = Rayfield:CreateWindow({
   Name = "Auto Farm | Mega Ramp",
   LoadingTitle = "Iniciando...",
   LoadingSubtitle = "Versão Final com Notificador",
   Size = UDim2.fromOffset(450, 320),
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- VARIÁVEIS DE CONTROLE
_G.AutoFarmLoop = false
_G.TempoEspera = 1.2
local jaNotificouRaro = false

-- ==========================================================
-- FUNÇÕES DE AUTOMAÇÃO E MOVIMENTAÇÃO
-- ==========================================================

-- 1. Vai até a seta e garante que o jogador sentou no carro
local function entrarNoCarroPelaSeta()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end

    -- Procura o quadrado com a seta no spawn/base
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
            local nome = string.lower(obj.Name)
            local texture = (obj:IsA("Texture") or obj:IsA("Decal")) and string.lower(obj.Texture) or ""
            
            if nome:find("arrow") or nome:find("seta") or texture:find("arrow") or texture:find("seta") then
                local targetPart = obj:IsA("BasePart") and obj or obj.Parent
                if targetPart and targetPart:IsA("BasePart") then
                    char.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
                    break
                end
            end
        end
    end

    -- Espera 1 segundo para o jogo spawnar o veículo e o jogador sentar no banco
    task.wait(1)
    
    -- Retorna verdadeiro se estiver em um veículo ou pronto
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.SeatPart ~= nil
end

-- 2. Teleporta o Carro + Jogador para a ÚLTIMA FAIXA de multiplicador (Antes do Slime/Barreira)
local function teleportarParaFinalRampa()
    local char = LocalPlayer.Character
    if not char then return end

    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    
    -- Identifica se estamos no banco do carro para mover o carro junto
    local assentoCarro = humanoid and humanoid.SeatPart
    local parteParaMover = assentoCarro and assentoCarro.Parent:FindFirstChild("PrimaryPart") or assentoCarro or rootPart

    if not parteParaMover then return end

    local melhorBloco = nil
    local maiorMultiplicador = -1

    -- Busca a faixa com o maior multiplicador de todos na rampa (ex: x1000000, x10M, etc.)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("SurfaceGui") or obj:IsA("BasePart") then
            local texto = ""
            if obj:IsA("TextLabel") then
                texto = obj.Text
            elseif obj:IsA("BasePart") then
                texto = obj.Name
            end

            local numStr = texto:lower():match("x%s*(%d+)")
            if numStr then
                local valor = tonumber(numStr)
                if valor and valor > maiorMultiplicador then
                    maiorMultiplicador = valor
                    melhorBloco = obj:IsA("BasePart") and obj or obj.Parent
                end
            end
        end
    end

    -- Se encontrou a última faixa de multiplicador
    if melhorBloco and melhorBloco:IsA("BasePart") then
        if assentoCarro and assentoCarro.Parent:IsA("Model") then
            -- Move o Modelo do Carro inteiro com você dentro
            assentoCarro.Parent:PivotTo(melhorBloco.CFrame + Vector3.new(0, 4, 0))
        else
            -- Move o personagem
            rootPart.CFrame = melhorBloco.CFrame + Vector3.new(0, 4, 0)
        end
    end
end

-- 3. Monitorador de Slime Raro ("Arco-íris Limitado" / Asas de Anjo)
local function checarSlimeRaro()
    pcall(function()
        -- Busca no inventário, no personagem ou em notificações da tela
        local achouRaro = false
        
        for _, obj in pairs(LocalPlayer:GetDescendants()) do
            local nome = string.lower(obj.Name)
            if nome:find("arco-íris") or nome:find("arco iris") or nome:find("rainbow") or nome:find("divine") or nome:find("limited") then
                achouRaro = true
                break
            end
        end

        if achouRaro and not jaNotificouRaro then
            jaNotificouRaro = true
            Rayfield:Notify({
               Title = " SLIME RARO ENCONTRADO!",
               Content = "Você conseguiu o Slime Arco-íris Limitado (Asas de Anjo)!",
               Duration = 8,
               Image = 4483362458,
            })
        end
    end)
end

-- 4. Equipar Melhores Slimes
local function equiparMelhorSlime()
    pcall(function()
        local remotes = {"EquipBest", "EquipBestPets", "EquipBestSlimes", "EquipBestSlime", "AutoEquip"}
        for _, name in pairs(remotes) do
            local remote = ReplicatedStorage:FindFirstChild(name, true)
            if remote and remote:IsA("RemoteFunction") then
                remote:InvokeServer()
            elseif remote and remote:IsA("RemoteEvent") then
                remote:FireServer()
            end
        end
    end)
end

-- LOOP PRINCIPAL DO AUTO FARM
task.spawn(function()
    while true do
        task.wait(_G.TempoEspera)
        if _G.AutoFarmLoop then
            -- Passo A: Pisa na seta e aguarda montar no carro
            entrarNoCarroPelaSeta()
            
            -- Passo B: Teleporta o Carro + Jogador até a faixa final da rampa
            teleportarParaFinalRampa()
            
            -- Passo C: Verifica se ganhou o Slime Raro
            checarSlimeRaro()
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

local TabFarm = Window:CreateTab("Auto Farm", 4483362458)

TabFarm:CreateToggle({
   Name = "Ligar Auto Farm Infinito (Com Carro)",
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
      Rayfield:Notify({
         Title = "Slimes Equipados",
         Content = "Os melhores slimes foram equipados!",
         Duration = 2.5
      })
   end,
})

TabFarm:CreateSlider({
   Name = "Velocidade do Ciclo (Segundos)",
   Range = {0.8, 4},
   Increment = 0.2,
   Suffix = " seg",
   CurrentValue = 1.2,
   Flag = "SliderTempo",
   Callback = function(Value)
      _G.TempoEspera = Value
   end,
})

local TabUGC = Window:CreateTab("Limitados", 4483362458)

local LabelLimitados = TabUGC:CreateLabel("Verificando estoque...")

task.spawn(function()
    while task.wait(5) do
        LabelLimitados:Set(checarEstoqueLimitados())
    end
end)
