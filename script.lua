-- Carrega a biblioteca visual Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- MENU COMPACTO E CLEAN
local Window = Rayfield:CreateWindow({
   Name = "Auto Farm | Mega Ramp",
   LoadingTitle = "Iniciando...",
   LoadingSubtitle = "Versão Teleporte Direto",
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

-- ==========================================================
-- FUNÇÕES DE TELEPORTE DIRETO E SEM TRAVAS
-- ==========================================================

-- 1. Teleporta direto para o quadrado branco com a seta
local function irParaSetaInício()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Procura a seta ou o spawn principal no mapa
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
            local nome = string.lower(obj.Name)
            local tex = (obj:IsA("Texture") or obj:IsA("Decal")) and string.lower(obj.Texture) or ""
            
            if nome:find("arrow") or nome:find("seta") or tex:find("arrow") or tex:find("seta") or nome:find("start") then
                local parteAlvo = obj:IsA("BasePart") and obj or obj.Parent
                if parteAlvo and parteAlvo:IsA("BasePart") then
                    root.CFrame = parteAlvo.CFrame + Vector3.new(0, 3, 0)
                    return
                end
            end
        end
    end
end

-- 2. Teleporta direto para a última faixa de multiplicador no final da rampa
local function irParaFinalRampa()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local melhorBloco = nil
    local maiorMultiplicador = -1

    -- Procura as faixas de multiplicadores (ex: x500000, x1000000, x10M)
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

    -- Se achou o maior multiplicador da rampa
    if melhorBloco and melhorBloco:IsA("BasePart") then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local assento = humanoid and humanoid.SeatPart
        
        -- Se estiver no carro, move o modelo do carro. Se não, move o boneco.
        if assento and assento.Parent and assento.Parent:IsA("Model") then
            assento.Parent:PivotTo(melhorBloco.CFrame + Vector3.new(0, 4, 0))
        else
            root.CFrame = melhorBloco.CFrame + Vector3.new(0, 4, 0)
        end
    end
end

-- 3. Verificação do Slime Raro ("Arco-íris Limitado")
local function checarSlimeRaro()
    pcall(function()
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

-- LOOP PRINCIPAL DO AUTO FARM (Sem travas)
task.spawn(function()
    while true do
        task.wait(_G.TempoEspera)
        if _G.AutoFarmLoop then
            -- Passo 1: Teleporta para a seta
            irParaSetaInício()
            task.wait(0.5)
            
            -- Passo 2: Teleporta direto para o final da rampa
            irParaFinalRampa()
            
            -- Passo 3: Checa o slime raro
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
-- INTERFACE VISUAL
-- ==========================================================

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
      Rayfield:Notify({
         Title = "Slimes Equipados",
         Content = "Os melhores slimes foram equipados!",
         Duration = 2.5
      })
   end,
})

TabFarm:CreateSlider({
   Name = "Velocidade do Ciclo (Segundos)",
   Range = {0.5, 3},
   Increment = 0.1,
   Suffix = " seg",
   CurrentValue = 1.0,
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
