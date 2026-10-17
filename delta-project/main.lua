-- delta-project | 0.1.0
-- Ponto de entrada independente, pronto para receber as primeiras funcoes.

local ENV_KEY = "__DELTA_PROJECT_INSTANCE"
local environment = _G

if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        environment = result
    end
end

local previous = environment[ENV_KEY]
if type(previous) == "table" and type(previous.Destroy) == "function" then
    previous:Destroy()
end

local Project = {
    Name = "delta-project",
    Version = "0.1.0",
    Active = true,
}

local actions = {}
local cleanups = {}

function Project:RegisterAction(name, callback)
    assert(self.Active, "O projeto ja foi encerrado.")
    assert(type(name) == "string" and name ~= "", "Informe o nome da funcao.")
    assert(type(callback) == "function", "A acao precisa de uma funcao.")
    assert(actions[name] == nil, "Acao ja registrada: " .. name)
    actions[name] = callback
end

function Project:RunAction(name, ...)
    assert(self.Active, "O projeto ja foi encerrado.")
    assert(type(name) == "string", "Informe o nome da funcao.")
    local callback = actions[name]
    assert(callback ~= nil, "Acao nao encontrada: " .. name)
    return callback(...)
end

function Project:AddCleanup(callback)
    assert(self.Active, "O projeto ja foi encerrado.")
    assert(type(callback) == "function", "A limpeza precisa de uma funcao.")
    cleanups[#cleanups + 1] = callback
end

function Project:Destroy()
    if not self.Active then
        return
    end

    self.Active = false

    for index = #cleanups, 1, -1 do
        local ok, message = pcall(cleanups[index])
        if not ok then
            local report = type(warn) == "function" and warn or print
            report("[delta-project] Falha ao encerrar recurso: " .. tostring(message))
        end
        cleanups[index] = nil
    end

    actions = {}

    if environment[ENV_KEY] == self then
        environment[ENV_KEY] = nil
    end
end

environment[ENV_KEY] = Project

-- Registre aqui as funcoes escolhidas para o novo projeto.
-- Project:RegisterAction("nome", function() ... end)
-- Ao criar eventos ou interfaces, use AddCleanup para libera-los ao encerrar.

print("[delta-project] Base iniciada | v" .. Project.Version)

return Project
