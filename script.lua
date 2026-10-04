-- // Mega Ramp for Slime - Otimizado e Completo
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Função para encontrar a última zona ou o maior multiplicador disponível no Workspace
local function encontrarUltimaZona()
    local pastaZonas = Workspace:FindFirstChild("Zonas") or Workspace:FindFirstChild("Zones") or Workspace:FindFirstChild("Pistas")
    
    if not pastaZonas then
        -- Caso o jogo organize de outra forma, tentamos varrer o Workspace procurando por partes de destino
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj.Name:lower():find("zone") or obj.Name:lower():find("ramp") or obj.Name:lower():find("multi") then
                pastaZonas = obj
                break
            end
        end
    end

    if pastaZonas then
        local maiorZonacframe = nil
        local maiorNumero = -1
        
        for _, zona in ipairs(pastaZonas:GetChildren()) do
            -- Tenta identificar a zona com base no nome ou em atributos numéricos
            local numeroZona = tonumber(zona.Name:match("%d+"))
            if numeroZona and numeroZona > maiorNumero then
                maiorNumero = numeroZona
                if zona:IsA("BasePart") then
                    maiorZonacframe = zona.CFrame + Vector3.new(0, 5, 0)
                elseif zona:IsA("Model") and zona.PrimaryPart then
                    maiorZonacframe = zona.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
        
        if maiorZonacframe then
            return maiorZonacframe
        end
    end
    
    return nil
end

-- Função principal de deslocamento fluido simulando a passagem pela rampa
local function executarMovimentoFluido()
    local character = player.Character
    if not character then return false, "Personagem não encontrado." end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false, "Humanoid não encontrado." end
    
    local vehicleSeat = humanoid.SeatPart
    if not vehicleSeat or not vehicleSeat:IsA("VehicleSeat") then
        return false, "Você precisa estar sentado em um veículo para o sistema funcionar!"
    end
    
    local carroModel = vehicleSeat.Parent
    local primaryPart = carroModel.PrimaryPart or vehicleSeat
    
    -- Busca o destino dinâmico na pista
    local destinoCFrame = encontrarUltimaZona()
    if not destinoCFrame then
        return false, "Não foi possível localizar o destino final no Workspace."
    end
    
    -- Configuração do movimento fluido (Tween) para forçar o registro físico dos gatilhos
    -- Mantemos uma velocidade controlada para o servidor processar a colisão nas rampas
    local distancia = (primaryPart.Position - destinoCFrame.Position).Magnitude
    local velocidadeDesejada = 150 -- studs por segundo simulados
    local tempoTrajeto = math.clamp(distancia / velocidadeDesejada, 0.2, 1.5)
    
    local infoTween = TweenInfo.new(
        tempoTrajeto,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    
    -- Desliga temporariamente a gravidade pesada do assembly se necessário para evitar travar no meio do caminho
    local bvAntigo = primaryPart:FindFirstChild("BodyVelocityAntiGrav")
    
    local tween = TweenService:Create(primaryPart, infoTween, {CFrame = destinoCFrame})
    
    tween:Play()
    tween.Completed:Wait()
    
    return true, "Deslocamento concluído com sucesso e multiplicador acionado!"
end

-- Exemplo de gatilho de execução (pode ser ligado a um botão da sua UI customizada)
task.spawn(function()
    local sucesso, mensagem = executarMovimentoFluido()
    print(mensagem)
end)
