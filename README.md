# Mouse Recovery Panel

Painel em Lua (Luau) para usar **dentro da sua própria experiência** no Roblox Studio. O painel tem as categorias **Info** e **Visual**, com vídeo de fundo opcional e um atalho para recuperar o cursor.

## Instalação no Roblox Studio

1. Abra a experiência no Roblox Studio.
2. No Explorer, encontre `StarterPlayer > StarterPlayerScripts`.
3. Insira um **LocalScript** nessa pasta.
4. Copie o conteúdo de [MouseRecoveryPanel.client.lua](./MouseRecoveryPanel.client.lua) para o LocalScript.
5. Teste com **Play**.

## Vídeo de fundo

O vídeo precisa ser enviado ao Roblox como asset antes de tocar no jogo. No início do script, substitua o valor vazio de `VIDEO_ASSET_ID` pelo ID, neste formato: `rbxassetid://1234567890`. O vídeo toca sem áudio e as opções ficam sobre uma camada escura translúcida.

O clipe enviado para esta conversa não é incorporado ao arquivo Lua automaticamente. Use um vídeo que você tenha permissão para publicar e confira as regras e custos atuais de upload do Roblox.

## Categorias e controles

- **Info** mostra dados do jogador atual: nome de exibição, usuário, UserId, idade da conta, ping e tipo de entrada/dispositivo.
- O Roblox não fornece ao LocalScript o endereço IP nem a região de rede do jogador. Esses campos aparecem como indisponíveis.
- **Visual** contém o botão para liberar o cursor e a escolha de tecla. **F6** é a tecla inicial; toque no campo de tecla e pressione outra. **Esc** cancela a seleção.
- **Right Shift** mostra ou esconde o painel.
- O botão **−** minimiza o painel. O botão flutuante **N** reabre e pode ser arrastado com mouse ou toque.
- O cabeçalho mostra **FREE**, **by askzedd** e o tipo de entrada atual (MOBILE, PC ou GAMEPAD).

A correção define `UserInputService.MouseBehavior` como `Default` e habilita o ícone do mouse. O comando é reaplicado por um curto período para tentar vencer um bloqueio momentâneo da câmera. A escala do painel se adapta a telas menores.

## Desempenho e animações

A interface reage a entradas e mudanças de tela, sem um loop contínuo por frame. O ping só atualiza enquanto a categoria Info está aberta. As transições usam tweens curtos para suavizar o carregamento, abrir e fechar o painel, alternar categorias e mostrar o botão flutuante.

## Limite importante

Este é um LocalScript para colocar na sua experiência pelo Studio. Ele não é um executor nem altera outros jogos. Se um script de câmera do próprio jogo continuar forçando o mouse para `LockCenter` ou prendendo o jogador em primeira pessoa, ele pode travar o cursor novamente; nesse caso, será preciso ajustar a lógica dessa câmera.
