-- Script de Diagnóstico para mapear a estrutura do Workspace
print("=== INICIANDO MAPEAMENTO DE ZONAS E RAMPAS ===")

for _, obj in ipairs(game.Workspace:GetChildren()) do
    local nome = obj.Name:lower()
    if nome:find("zone") or nome:find("ramp") or nome:find("pista") or nome:find("stage") or nome:find("multi") then
        print("Encontrada pasta/objeto potencial:", obj.Name, "| Classe:", obj.ClassName)
        
        -- Mostra os primeiros itens dentro dessa pasta
        for i, subObj in ipairs(obj:GetChildren()) do
            if i <= 5 then
                print("   --> Item interno:", subObj.Name, "| Classe:", subObj.ClassName)
            end
        end
    end
end

print("=== MAPEAMENTO CONCLUÍDO ===")
