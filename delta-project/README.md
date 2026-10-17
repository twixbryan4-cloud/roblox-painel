# delta-project

Base Lua criada do zero para iniciar um novo projeto no Delta.

## Estado inicial

`main.lua` inicia o projeto e mostra uma mensagem no console. Esta primeira
versao estabelece o ponto de entrada; as funcoes e a interface ainda serao
definidas.

Ao executar novamente, a instancia anterior e encerrada antes de iniciar a
nova. Recursos criados pelas futuras funcoes devem registrar sua limpeza.

## Estrutura

- `main.lua`: entrada unica, registro de acoes e encerramento dos recursos.
- `.gitignore`: arquivos locais que nao devem entrar nos commits.

## Como estender

Dentro de `main.lua`, antes do `return Project`, registre as funcoes:

```lua
Project:RegisterAction("minha_acao", function(value)
    print(value)
end)

Project:RunAction("minha_acao", "Projeto pronto")
```

Para uma conexao de evento, registre a limpeza assim que cria-la:

```lua
Project:AddCleanup(function()
    connection:Disconnect()
end)
```

`Project:Destroy()` encerra a instancia e executa as limpezas registradas,
mesmo se uma delas falhar.

## Publicacao

O projeto fica na pasta `delta-project/`, na branch `delta-project-zero`,
do repositorio `twixbryan4-cloud/roblox-painel`.

O ponto de entrada e `delta-project/main.lua`. As primeiras funcoes e a
interface serao implementadas nesta base independente.

## Validacao

Base validada em Lua 5.4: inicializacao, registro e chamada de acoes,
reexecucao, encerramento e limpeza de recursos, incluindo falhas em uma
limpeza e o ambiente de `getgenv`.

A execucao dentro do Delta ainda precisa ser verificada no dispositivo;
ela nao foi testada nesse executor.
