-- Garante que o jogo carregou completamente
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

local fpsBoostAtivo = false
local conexaoFps = nil
local originalGlobalShadows = Lighting.GlobalShadows

-- Criação da Interface GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FpsBoosterGuiDelta"
ScreenGui.ResetOnSpawn = false
local success, err = pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
end

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 240)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Arrastável
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Barra Superior (Título)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 8)
TopBarCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "FPS Booster & Partículas"
Title.Parent = TopBar

-- Botão Minimizar (-)
local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0, 30, 0, 30)
MinButton.Position = UDim2.new(1, -65, 0, 2)
MinButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinButton.TextSize = 14
MinButton.Font = Enum.Font.GothamBold
MinButton.Text = "-"
MinButton.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinButton

-- Botão Fechar (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -32, 0, 2)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Container dos Elementos
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, 0, 1, -35)
Container.Position = UDim2.new(0, 0, 0, 35)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- Display de FPS
local FpsLabel = Instance.new("TextLabel")
FpsLabel.Size = UDim2.new(0.85, 0, 0, 40)
FpsLabel.Position = UDim2.new(0.075, 0, 0, 15)
FpsLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FpsLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
FpsLabel.TextSize = 14
FpsLabel.Font = Enum.Font.GothamBold
FpsLabel.Text = "FPS: Calculando..."
FpsLabel.Parent = Container

local FpsCorner = Instance.new("UICorner")
FpsCorner.CornerRadius = UDim.new(0, 6)
FpsCorner.Parent = FpsLabel

-- Botão de Ativar/Desativar Limpeza de Partículas
local BtnBooster = Instance.new("TextButton")
BtnBooster.Size = UDim2.new(0.85, 0, 0, 42)
BtnBooster.Position = UDim2.new(0.075, 0, 0, 68)
BtnBooster.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
BtnBooster.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnBooster.TextSize = 13
BtnBooster.Font = Enum.Font.GothamSemibold
BtnBooster.Text = "FPS Booster (Partículas): OFF"
BtnBooster.Parent = Container

local BtnBoosterCorner = Instance.new("UICorner")
BtnBoosterCorner.CornerRadius = UDim.new(0, 6)
BtnBoosterCorner.Parent = BtnBooster

-- Status Info
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.85, 0, 0, 55)
StatusLabel.Position = UDim2.new(0.075, 0, 0, 122)
StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextWrapped = true
StatusLabel.Text = "Status: Ative o booster para desativar partículas e ganhar FPS."
StatusLabel.Parent = Container

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusLabel

-- Contador de FPS preciso em tempo real
local frames = 0
local ultimoTempo = tick()

conexaoFps = RunService.RenderStepped:Connect(function()
    frames = frames + 1
    local agora = tick()
    if agora - ultimoTempo >= 1 then
        local fps = math.floor(frames / (agora - ultimoTempo))
        FpsLabel.Text = "FPS Atual: " .. fps
        
        if fps >= 45 then
            FpsLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
        elseif fps >= 20 then
            FpsLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        else
            FpsLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
        
        frames = 0
        ultimoTempo = agora
    end
end)

-- Função para Alternar (Ligar/Desligar) Partículas sem precisar apagar do jogo
local function alternarParticulas(estado)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Trail") or obj:IsA("Beam") then
            -- Se estado for true (ON), desliga a emissão. Se for false (OFF), religa.
            obj.Enabled = not estado
        end
    end
    
    if estado then
        Lighting.GlobalShadows = false
    else
        Lighting.GlobalShadows = originalGlobalShadows
    end
end

-- Botão Minimizar
local minimizado = false
MinButton.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    Container.Visible = not minimizado
    if minimizado then
        MainFrame.Size = UDim2.new(0, 260, 0, 35)
        MinButton.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 260, 0, 240)
        MinButton.Text = "-"
    end
end)

-- Botão Fechar
CloseButton.MouseButton1Click:Connect(function()
    if conexaoFps then
        conexaoFps:Disconnect()
    end
    alternarParticulas(false) -- Restaura tudo ao fechar a UI
    ScreenGui:Destroy()
end)

-- Ação do Botão Booster (Agora com suporte a ON e OFF real)
BtnBooster.MouseButton1Click:Connect(function()
    fpsBoostAtivo = not fpsBoostAtivo
    if fpsBoostAtivo then
        BtnBooster.Text = "FPS Booster (Partículas): ON"
        BtnBooster.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        StatusLabel.Text = "Status: Partículas ocultadas. Jogo otimizado!"
        StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        alternarParticulas(true)
    else
        BtnBooster.Text = "FPS Booster (Partículas): OFF"
        BtnBooster.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        StatusLabel.Text = "Status: Jogo restaurado ao visual original!"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        alternarParticulas(false)
    end
end)
