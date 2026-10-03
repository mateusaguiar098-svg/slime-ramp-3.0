-- Carrega a biblioteca de interface visual Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Cria a janela principal do Menu
local Window = Rayfield:CreateWindow({
   Name = "Meu Hub | Mega Ramp",
   LoadingTitle = "Iniciando Script...",
   LoadingSubtitle = "Criado por Mim",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ==========================================================
-- LOGICA DE VELOCIDADE E AUTOMAÇÃO
-- ==========================================================
_G.SuperBoostRampa = false
_G.VelocidadeRampa = 1800 -- Valor padrão

local function acelerarVeiculoExtremo()
    local char = LocalPlayer.Character
    if not char then return end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local seat = char:FindFirstChildOfClass("Humanoid") and char.Humanoid.SeatPart
    local alvoFisica = seat or rootPart

    if alvoFisica then
        -- Aplica o impulso na velocidade definida na barra do menu
        alvoFisica.AssemblyLinearVelocity = alvoFisica.CFrame.LookVector * _G.VelocidadeRampa
    end
end

-- Loop de velocidade continua em segundo plano
task.spawn(function()
    while true do
        task.wait(0.05)
        if _G.SuperBoostRampa then
            acelerarVeiculoExtremo()
        end
    end
end)

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

-- ABA 1: Rampa e Slimes
local TabRampa = Window:CreateTab("Rampa & Slimes", 4483362458)

-- Botão Liga/Desliga a Velocidade
TabRampa:CreateToggle({
   Name = "Ativar Super Velocidade na Rampa",
   CurrentValue = false,
   Flag = "ToggleFastRamp",
   Callback = function(Value)
      _G.SuperBoostRampa = Value
   end,
})

-- Barra para controlar a intensidade do impulso
TabRampa:CreateSlider({
   Name = "Intensidade da Velocidade",
   Range = {500, 4000},
   Increment = 100,
   Suffix = " Força",
   CurrentValue = 1800,
   Flag = "SliderVelocidade",
   Callback = function(Value)
      _G.VelocidadeRampa = Value
   end,
})

-- Botão para Equipar o Melhor Slime
TabRampa:CreateButton({
   Name = "Equipar Melhor Slime",
   Callback = function()
      equiparMelhorSlime()
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
