# Mouse Recovery Panel

Painel em Lua (Luau) para usar **dentro da sua própria experiência** no Roblox Studio. O painel tem as categorias **Info**, **Visual** e **Config**, um controle de transparência e um atalho para recuperar o cursor.

## Instalação no Roblox Studio

1. Abra a experiência no Roblox Studio.
2. No Explorer, encontre `StarterPlayer > StarterPlayerScripts`.
3. Insira um **LocalScript** nessa pasta.
4. Copie o conteúdo de [MouseRecoveryPanel.client.lua](./MouseRecoveryPanel.client.lua) para o LocalScript.
5. Teste com **Play**.

## Imagem de fundo

A arte enviada foi compactada e embutida diretamente no LocalScript. O carregamento usa `EditableImage` e `WritePixelsBuffer`; para experiências publicadas, as APIs de imagem editável precisam estar habilitadas nas configurações do Creator Dashboard. Se o Roblox bloquear a API ou não houver memória disponível, o painel abre sem a arte.

## Categorias e controles

- **Info** mostra dados do jogador atual: nome de exibição, usuário, UserId, idade da conta, ping e tipo de entrada/dispositivo.
- O Roblox não fornece ao LocalScript o endereço IP nem a região de rede do jogador. Esses campos aparecem como indisponíveis.
- **Visual** contém o botão para liberar o cursor e a escolha de tecla. **F6** é a tecla inicial; toque no campo de tecla e pressione outra. **Esc** cancela a seleção.
- **Config** tem um controle deslizante para ajustar a transparência apenas do painel.
- **Right Shift** mostra ou esconde o painel.
- O botão **−** minimiza o painel. O botão flutuante **N** reabre e pode ser arrastado com mouse ou toque.
- O cabeçalho mostra **FREE**, **by askzedd** e o tipo de entrada atual (MOBILE, PC ou GAMEPAD).

A correção define `UserInputService.MouseBehavior` como `Default` e habilita o ícone do mouse. O comando é reaplicado por um curto período para tentar vencer um bloqueio momentâneo da câmera. A escala do painel se adapta a telas menores.

## Desempenho e animações

A interface reage a entradas e mudanças de tela, sem um loop contínuo por frame. O ping só atualiza enquanto a categoria Info está aberta. As transições usam tweens curtos para suavizar o carregamento, abrir e fechar o painel, alternar categorias e mostrar o botão flutuante.

## Limite importante

Este é um LocalScript para colocar na sua experiência pelo Studio. Ele não é um executor nem altera outros jogos. Se um script de câmera do próprio jogo continuar forçando o mouse para `LockCenter` ou prendendo o jogador em primeira pessoa, ele pode travar o cursor novamente; nesse caso, será preciso ajustar a lógica dessa câmera.
