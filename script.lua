-- // OTIMIZADOR DE FPS E REMOVEDOR DE PARTÍCULAS //
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Remove UI anterior se já estiver aberta
local parentUI = (gethui and gethui()) or CoreGui
if parentUI:FindFirstChild("OptmizerUI") then
    parentUI.OptmizerUI:Destroy()
end

-- Criação da Interface Limpa
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OptmizerUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = parentUI end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 170, 0, 65)
Frame.Position = UDim2.new(0.05, 0, 0.12, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true -- Você pode arrastar o painel para onde quiser na tela
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 180, 255)
UIStroke.Thickness = 1.2
UIStroke.Parent = Frame

-- Contador de FPS
local FpsLabel = Instance.new("TextLabel")
FpsLabel.Size = UDim2.new(1, 0, 0, 30)
FpsLabel.Position = UDim2.new(0, 0, 0, 5)
FpsLabel.BackgroundTransparency = 1
FpsLabel.Text = "FPS: Calculando..."
FpsLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
FpsLabel.Font = Enum.Font.GothamBold
FpsLabel.TextSize = 14
FpsLabel.Parent = Frame

-- Status de Partículas Removidas
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Partículas: Desativadas 🧹"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.Parent = Frame

-- Lógica do Contador de FPS
local frameCount = 0
local lastTick = tick()

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = tick()
    if currentTime - lastTick >= 1 then
        FpsLabel.Text = "FPS: " .. tostring(frameCount)
        frameCount = 0
        lastTick = currentTime
    end
end)

-- Função para Destruir / Desativar Partículas
local function LimparParticula(obj)
    if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Beam") or obj:IsA("Trail") then
        pcall(function()
            obj.Enabled = false
            obj:Destroy()
        end)
    end
end

-- Varredura inicial em todo o mapa para limpar as partículas existentes
task.spawn(function()
    pcall(function()
        for _, descendant in ipairs(Workspace:GetDescendants()) do
            LimparParticula(descendant)
        end
    end)
end)

-- Monitor contínuo: Se o jogo gerar novas partículas, o script apaga na mesma hora
Workspace.DescendantAdded:Connect(function(descendant)
    LimparParticula(descendant)
end)
