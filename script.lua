-- Garante que não vai duplicar a interface se já estiver aberta
if game:GetService("CoreGui"):FindFirstChild("RayfieldInterface") then
    game:GetService("CoreGui").RayfieldInterface:Destroy()
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Mega Ramp for Slime",
    LoadingTitle = "Carregando Auto Farm...",
    LoadingSubtitle = "Por Mateus",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "MegaRampConfig"
    },
    KeySystem = false,
})

local Tab = Window:CreateTab("Home", 4483362458)

local Section = Tab:CreateSection("Funções Principais")

_G.InstantLastZone = false
_G.EquipBest = false

-- TOGGLE INSTANT LAST ZONE
Tab:CreateToggle({
    Name = "Instant LastZone",
    CurrentValue = false,
    Flag = "InstantLastZoneFlag",
    Callback = function(Value)
        _G.InstantLastZone = Value
    end,
})

-- TOGGLE EQUIP BEST
Tab:CreateToggle({
    Name = "Equip Best",
    CurrentValue = false,
    Flag = "EquipBestFlag",
    Callback = function(Value)
        _G.EquipBest = Value
    end,
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Função para achar a última zona da rampa de forma inteligente
local function obterUltimaZona()
    local melhorAlvo = nil
    local maiorZ = -999999

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local nome = v.Name:lower()
            -- Procura por termos comuns de fim de rampa ou pega a peça mais distante no eixo Z
            if nome:find("zone") or nome:find("end") or nome:find("finish") or nome:find("multi") or nome:find("last") then
                if v.Position.Z > maiorZ then
                    maiorZ = v.Position.Z
                    melhorAlvo = v
                end
            end
        end
    end

    -- Se não achar por nome específico, pega a peça mais distante do mapa na direção da rampa
    if not melhorAlvo then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Size.Magnitude > 10 then
                if v.Position.Z > maiorZ then
                    maiorZ = v.Position.Z
                    melhorAlvo = v
                end
            end
        end
    end

    return melhorAlvo
end

-- Loop principal do Auto Farm
task.spawn(function()
    while true do
        task.wait(0.2)
        
        -- Executa Equip Best se estiver ativado
        if _G.EquipBest then
            pcall(function()
                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        local n = remote.Name:lower()
                        if n:find("equip") or n:find("best") then
                            if remote:IsA("RemoteEvent") then remote:FireServer() else remote:InvokeServer() end
                        end
                    end
                end
            end)
        end

        -- Executa Instant LastZone se estiver ativado
        if _G.InstantLastZone then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local assento = humanoid and humanoid.SeatPart

                local ultimaZona = obterUltimaZona()
                
                if ultimaZona then
                    -- Se estiver sentado no carro, teleporta o modelo inteiro do carro
                    if assento and assento.Parent then
                        local carroModel = assento.Parent
                        carroModel:PivotTo(ultimaZona.CFrame + Vector3.new(0, 4, 0))
                    else
                        -- Caso contrário, teleporta o personagem
                        char.HumanoidRootPart.CFrame = ultimaZona.CFrame + Vector3.new(0, 4, 0)
                    end
                end
            end)
        end
    end
end)
