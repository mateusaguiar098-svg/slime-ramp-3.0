-- Carrega a interface Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Auto Farm | Mega Ramp",
   LoadingTitle = "Iniciando...",
   LoadingSubtitle = "Foco TOTAL na Seta",
   Size = UDim2.fromOffset(450, 320),
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.AutoFarmLoop = false
_G.TempoEspera = 1.0

-- 1. TELEPORTE EXCLUSIVO PARA O DESENHO DA SETA
local function irParaSeta()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    local alvo = nil
    local menorDistancia = 500 

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local temSeta = false
            
            -- Procura se a peça tem a imagem/textura de uma seta grudada nela
            for _, filho in pairs(v:GetChildren()) do
                if filho:IsA("Decal") or filho:IsA("Texture") then
                    local tex = string.lower(filho.Texture)
                    if tex:find("arrow") or tex:find("seta") then
                        temSeta = true
                    end
                end
            end

            local nome = v.Name:lower()
            -- SÓ ACEITA se tiver a textura da seta OU o nome exato da rampa (StartPad). Ignora Spawns da base!
            if temSeta or nome == "startpad" or nome:find("arrow") then
                local dist = (v.Position - root.Position).Magnitude
                if dist < menorDistancia then
                    menorDistancia = dist
                    alvo = v
                end
            end
        end
    end

    if alvo then
        -- Teleporta bem em cima do quadrado da seta
        root.CFrame = alvo.CFrame + Vector3.new(0, 3, 0)
    end
end

-- 2. TELEPORTE PARA O FINAL DA RAMPA (COM O CARRO)
local function irParaFinal()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local assento = humanoid and humanoid.SeatPart

    local alvoFinal = nil
    local maiorMultiplicador = -1

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("TextLabel") or v:IsA("SurfaceGui") then
            local texto = v:IsA("TextLabel") and v.Text or v.Name
            
            local nStr = texto:lower():match("x%s*(%d+)")
            if nStr then
                local val = tonumber(nStr)
                if val and val > maiorMultiplicador then
                    maiorMultiplicador = val
                    alvoFinal = v:IsA("BasePart") and v or v.Parent
                end
            end
        end
    end

    if alvoFinal and alvoFinal:IsA("BasePart") then
        if assento and assento.Parent and assento.Parent:IsA("Model") then
            assento.Parent:PivotTo(alvoFinal.CFrame + Vector3.new(0, 4, 0))
        else
            root.CFrame = alvoFinal.CFrame + Vector3.new(0, 4, 0)
        end
    end
end

-- LOOP PRINCIPAL
task.spawn(function()
    while true do
        task.wait(_G.TempoEspera)
        if _G.AutoFarmLoop then
            irParaSeta()
            task.wait(0.5) -- Pausa rápida para o carro nascer e você sentar
            irParaFinal()
        end
    end
end)

-- ==========================================
-- INTERFACE VISUAL
-- ==========================================
local TabPrincipal = Window:CreateTab("Principal", 4483362458)

TabPrincipal:CreateToggle({
   Name = "Ligar Auto Farm",
   CurrentValue = false,
   Flag = "ToggleAutoFarm",
   Callback = function(Value)
      _G.AutoFarmLoop = Value
   end,
})

TabPrincipal:CreateSlider({
   Name = "Velocidade (Segundos)",
   Range = {0.3, 3},
   Increment = 0.1,
   Suffix = " seg",
   CurrentValue = 1.0,
   Flag = "SliderTempo",
   Callback = function(Value)
      _G.TempoEspera = Value
   end,
})

TabPrincipal:CreateButton({
   Name = "Equipar Melhor Slime",
   Callback = function()
      pcall(function()
          local rs = game:GetService("ReplicatedStorage")
          for _, v in pairs(rs:GetDescendants()) do
              if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                  local n = v.Name:lower()
                  if n:find("equip") or n:find("best") then
                      if v:IsA("RemoteEvent") then v:FireServer() else v:InvokeServer() end
                  end
              end
          end
      end)
      Rayfield:Notify({
         Title = "Sucesso!",
         Content = "Melhores Slimes equipados.",
         Duration = 3
      })
   end,
})
