# Mouse Recovery Panel

Painel em Lua (Luau) para usar **dentro da sua própria experiência** no Roblox Studio. O script mostra uma tela de carregamento, abre um painel compacto e oferece um atalho para restaurar o cursor.

## Instalação no Roblox Studio

1. Abra a experiência no Roblox Studio.
2. No Explorer, encontre `StarterPlayer > StarterPlayerScripts`.
3. Insira um **LocalScript** nessa pasta.
4. Copie o conteúdo de [MouseRecoveryPanel.client.lua](./MouseRecoveryPanel.client.lua) para o LocalScript.
5. Teste com **Play**.

## Controles

- **F6** é a tecla inicial para liberar o cursor. Clique no botão de tecla no painel e pressione outra tecla para trocar. **Esc** cancela a seleção.
- **Right Shift** mostra ou esconde o painel.
- O botão **LIBERAR CURSOR** também executa a correção.

A correção define `UserInputService.MouseBehavior` como `Default` e habilita o ícone do mouse. O comando é reaplicado por um curto período para tentar vencer um bloqueio momentâneo da câmera. A escala do painel se adapta a telas menores.

## Limite importante

Este é um LocalScript para colocar na sua experiência pelo Studio. Ele não é um executor nem altera outros jogos. Se um script de câmera do próprio jogo continuar forçando o mouse para `LockCenter` ou prendendo o jogador em primeira pessoa, ele pode travar o cursor novamente; nesse caso, será preciso ajustar a lógica dessa câmera.
