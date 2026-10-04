-- // ================================================================= //
-- // MEGA RAMP FOR SLIME - SCRIPT COMPLETO E AUTOMÁTICO               //
-- // ================================================================= //

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- // ESTADOS DE CONTROLE (FLAGS)
_G.AutoLastZone = false
_G.AutoEquip = false
_G.VelocidadeMovimento = 180 -- Studs por segundo no Tween

-- // 1. CRIAÇÃO DA INTERFACE GRÁFICA (UI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MegaRampHubUI"

-- Tenta inserir na CoreGui para maior segurança do executor, se falhar vai para PlayerGui
local success, _ = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 260)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 25, 32)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(85, 170, 255)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Título da Janela
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundColor3 = Color3.fromRGB(32, 34, 44)
TitleLabel.Text = "MEGA RAMP FOR SLIME"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleLabel

-- Status do Script
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(0.9, 0, 0, 25)
StatusLabel.Position = UDim2.new(0.05, 0, 0.82, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Aguardando..."
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- // SISTEMA DE ARRASTE DA UI (DRAGGABLE)
local dragging, dragInput, dragStart, startPos

TitleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- // FUNÇÃO AUXILIAR PARA CRIAR BOTÕES
local function CriarBotaoToggle(nomeText, posicaoY, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.9, 0, 0, 40)
    Button.Position = UDim2.new(0.05, 0, 0, posicaoY)
    Button.BackgroundColor3 = Color3.fromRGB(40, 43, 56)
    Button.Text = nomeText .. ": [ OFF ]"
    Button.TextColor3 = Color3.fromRGB(255, 85, 85)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamSemibold
    Button.Parent = MainFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button

    local estado = false
    Button.MouseButton1Click:Connect(function()
        estado = not estado
        if estado then
            Button.Text = nomeText .. ": [ ON ]"
            Button.TextColor3 = Color3.fromRGB(85, 255, 127)
            Button.BackgroundColor3 = Color3.fromRGB(48, 65, 52)
        else
            Button.Text = nomeText .. ": [ OFF ]"
            Button.TextColor3 = Color3.fromRGB(255, 85, 85)
            Button.BackgroundColor3 = Color3.fromRGB(40, 43, 56)
        end
        callback(estado)
    end)
    
    return Button
end

-- // 2. LÓGICA DE MAPEAMENTO E MOVIEMNTO DO VEÍCULO

-- Identifica o veículo do jogador e a sua part principal (PrimaryPart)
local function ObterVeiculo()
    local char = LocalPlayer.Character
    if not char then return nil, nil end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or not humanoid.SeatPart then return nil, nil end
    
    local seat = humanoid.SeatPart
    if not seat:IsA("VehicleSeat") then return nil, nil end
    
    local model = seat.Parent
    while model and not model:IsA("Model") do
        model = model.Parent
    end
    
    local primaryPart = (model and model.PrimaryPart) or seat
    return seat, primaryPart
end

-- Mapeia o Workspace procurando o maior multiplicador ou a menor/maior coordenada Z/Y
local function EncontrarMaiorMultiplicador()
    local pontoAlvoCFrame = nil
    local maiorValorEncontrado = -1
    
    -- Busca em containers comuns de rampas/multiplicadores
    local pastasPossiveis = {
        Workspace:FindFirstChild("Zones"),
        Workspace:FindFirstChild("Zonas"),
        Workspace:FindFirstChild("Multipliers"),
        Workspace:FindFirstChild("Ramps"),
        Workspace:FindFirstChild("Pistas")
    }
    
    for _, pasta in ipairs(pastasPossiveis) do
        if pasta then
            for _, item in ipairs(pasta:GetChildren()) do
                -- Extrai qualquer número do nome (ex: "70000x", "Zone_85000")
                local num = tonumber(item.Name:match("%d+"))
                if num and num > maiorValorEncontrado then
                    maiorValorEncontrado = num
                    if item:IsA("BasePart") then
                        pontoAlvoCFrame = item.CFrame
                    elseif item:IsA("Model") and item.PrimaryPart then
                        pontoAlvoCFrame = item.PrimaryPart.CFrame
                    end
                end
            end
        end
    end
    
    -- Fallback: Se não achar por nome numérico, procura a parte mais distante na pista
    if not pontoAlvoCFrame then
        local menorZ = math.huge
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("finish") or obj.Name:lower():find("end") or obj.Name:lower():find("multi")) then
                if obj.Position.Z < menorZ then
                    menorZ = obj.Position.Z
                    pontoAlvoCFrame = obj.CFrame
                end
            end
        end
    end

    if pontoAlvoCFrame then
        -- Eleva ligeiramente a posição (5 studs) para evitar colidir por baixo da pista
        return pontoAlvoCFrame + Vector3.new(0, 5, 0)
    end
    
    return nil
end

-- Executa o movimento fluido (Tween) simulando travessia física
local function ExecutarDeslocamentoFluido(destinoCFrame)
    local seat, primaryPart = ObterVeiculo()
    
    if not seat or not primaryPart then
        StatusLabel.Text = "Status: Entre em um veículo!"
        return false
    end
    
    local distancia = (primaryPart.Position - destinoCFrame.Position).Magnitude
    local tempoTrajeto = math.clamp(distancia / _G.VelocidadeMovimento, 0.3, 1.8)
    
    StatusLabel.Text = "Status: Movendo (" .. math.floor(distancia) .. "m)..."
    
    local infoTween = TweenInfo.new(
        tempoTrajeto,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(primaryPart, infoTween, {CFrame = destinoCFrame})
    tween:Play()
    tween.Completed:Wait()
    
    StatusLabel.Text = "Status: Multiplicador atingido!"
    return true
end

-- // 3. CONEXÃO DOS BOTÕES DA UI COM O LOOP DE AUTOMAÇÃO

CriarBotaoToggle("Instant LastZone", 50, function(ativado)
    _G.AutoLastZone = ativado
    
    if ativado then
        task.spawn(function()
            while _G.AutoLastZone do
                local destino = EncontrarMaiorMultiplicador()
                
                if destino then
                    local sucesso = ExecutarDeslocamentoFluido(destino)
                    if sucesso then
                        task.wait(0.5) -- Pausa para o servidor registrar e resetar
                    end
                else
                    StatusLabel.Text = "Status: Zona não localizada no Workspace"
                end
                
                task.wait(0.3)
            end
            StatusLabel.Text = "Status: Parado"
        end)
    end
end)

CriarBotaoToggle("Auto Equip Best", 100, function(ativado)
    _G.AutoEquip = ativado
    if ativado then
        task.spawn(function()
            while _G.AutoEquip do
                -- Tenta disparar o evento de Equip Best caso exista no ReplicatedStorage
                local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") or game:GetService("ReplicatedStorage")
                local equipEvent = remotes:FindFirstChild("EquipBest") or remotes:FindFirstChild("EquipBestPet")
                if equipEvent and equipEvent:IsA("RemoteEvent") then
                    equipEvent:FireServer()
                end
                task.wait(5)
            end
        end)
    end
end)

StatusLabel.Text = "Status: Script Carregado com Sucesso!"
