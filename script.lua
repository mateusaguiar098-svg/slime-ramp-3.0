-- Script Auto Farm - Foco no Final da Rampa (Maior Multiplicador)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Auto Farm - Slime & Rampa",
   LoadingTitle = "Carregando Script...",
   LoadingSubtitle = "por Assistente",
   ConfigurationSaving = {
      Enabled = false
   }
})

local TabFarm = Window:CreateTab("Auto Farm", 4483362458)

-- Variáveis de controle
_G.AutoFarmAtivo = false

-- Função para encontrar a plataforma inicial da seta
local function irParaSeta()
    local player = game.Players.LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return false end
    
    local hrp = player.Character.HumanoidRootPart
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
            local nome = string.lower(obj.Name)
            local tex = (obj:IsA("Decal") or obj:IsA("Texture")) and string.lower(obj.Texture) or ""
            
            if string.find(nome, "seta") or string.find(nome, "arrow") or string.find(tex, "seta") or string.find(tex, "arrow") or string.find(nome, "spawn") then
                local alvo = obj:IsA("BasePart") and obj or obj.Parent
                if alvo and alvo:IsA("BasePart") then
                    hrp.CFrame = alvo.CFrame + Vector3.new(0, 4, 0)
                    return true
                end
            end
        end
    end
    return false
end

-- Função para encontrar o FINAL da rampa colorida (Maior Multiplicador)
local function irParaFinalDaRampa()
    local player = game.Players.LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = player.Character.HumanoidRootPart
    local alvoMaisLonge = nil
    local maiorPosicaoZ = -math.huge
    local menorPosicaoZ = math.huge
    
    -- Varre as partes do mapa procurando os blocos de multiplicador da rampa
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local nome = string.lower(obj.Name)
            
            -- Procura por partes da rampa / multiplicadores (ex: x1000000, multiplier, ramp, zone)
            local ehRampa = string.find(nome, "multiplier") or string.find(nome, "rampa") or string.find(nome, "ramp") or string.find(nome, "multi") or string.find(nome, "zone") or string.find(nome, "finish") or string.find(nome, "win")
            
            -- Também verifica se há texto de multiplicador dentro do bloco
            if not ehRampa then
                for _, child in pairs(obj:GetChildren()) do
                    if child:IsA("SurfaceGui") or child:IsA("BillboardGui") or child:IsA("TextLabel") then
                        ehRampa = true
                        break
                    end
                end
            end
            
            if ehRampa then
                -- Descobre o bloco mais distante no eixo de profundidade (fim da pista)
                local distZ = math.abs(obj.Position.Z)
                if distZ > maiorPosicaoZ then
                    maiorPosicaoZ = distZ
                    alvoMaisLonge = obj
                end
            end
        end
    end

    -- Teleporta para o bloco mais distante encontrado na pista (faixa final)
    if alvoMaisLonge then
        hrp.CFrame = alvoMaisLonge.CFrame + Vector3.new(0, 5, 0)
    else
        -- Fallback: Se não achar pelo nome, busca o ponto mais distante do centro
        local blocoMaisDistante = nil
        local maxDist = 0
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not string.find(string.lower(obj.Name), "slime") then
                local dist = (obj.Position - Vector3.new(0, 0, 0)).Magnitude
                if dist > maxDist and dist < 15000 then -- limita para não ir fora do mapa
                    maxDist = dist
                    blocoMaisDistante = obj
                end
            end
        end
        if blocoMaisDistante then
            hrp.CFrame = blocoMaisDistante.CFrame + Vector3.new(0, 5, 0)
        end
    end
end

-- Função para equipar melhor Slime/Pet
local function equiparMelhorSlime()
    local args = {
        [1] = "EquipBest",
        [2] = {}
    }
    local replicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Procura os eventos remotos de Pet/Slime comuns
    for _, child in pairs(replicatedStorage:GetDescendants()) do
        if child:IsA("RemoteFunction") or child:IsA("RemoteEvent") then
            local n = string.lower(child.Name)
            if string.find(n, "equip") or string.find(n, "pet") or string.find(n, "slime") then
                pcall(function()
                    if child:IsA("RemoteFunction") then
                        child:InvokeServer("EquipBest")
                    else
                        child:FireServer("EquipBest")
                    end
                end)
            end
        end
    end
end

-- Elementos da Interface (UI)
local ToggleFarm = TabFarm:CreateToggle({
   Name = "Auto Farm (Ir para Final da Rampa)",
   CurrentValue = false,
   Flag = "AutoFarmFlag",
   Callback = function(Value)
      _G.AutoFarmAtivo = Value
      
      task.spawn(function()
         while _G.AutoFarmAtivo do
            -- 1. Vai até a seta inicial
            irParaSeta()
            task.wait(1.2) -- Tempo para entrar no veículo
            
            -- 2. Teleporta direto para a faixa do maior multiplicador no fim da rampa
            if _G.AutoFarmAtivo then
               irParaFinalDaRampa()
               task.wait(2.5) -- Tempo para contabilizar o multiplicador/grana
            end
            
            task.wait(0.5)
         end
      end)
   end,
})

local ButtonEquip = TabFarm:CreateButton({
   Name = "Equipar Melhor Slime",
   Callback = function()
      equiparMelhorSlime()
      Rayfield:Notify({
         Title = "Slimes",
         Content = "Tentando equipar os melhores slimes!",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})
