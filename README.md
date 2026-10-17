# NOVA · Camera Panel v1.2

Painel em Lua/Luau para o cliente da sua experiência no Roblox, com apenas o controle de **sensibilidade da câmera**.

## Arquivo atual

- [NovaPanel.client.lua](./NovaPanel.client.lua)
- [Abrir o código Raw](https://raw.githubusercontent.com/twixbryan4-cloud/roblox-painel/refs/heads/main/NovaPanel.client.lua)

## O que tem

- Inicialização animada e curta.
- Visual escuro com detalhes em azul e lilás, fonte Gotham e crédito **by askzedd**.
- Fundo realmente translúcido, com textos e controles preservados em cores claras.
- Ajuste de **0,1× a 5×**, em passos de **0,1×**. **1×** é a base do controlador NOVA.
- Botões **−0,1** e **+0,1** para escolher valores como **2,1×** e **2,2×**.
- Barra deslizante e atalhos de **0,5×**, **1×**, **2×** e **5×**.
- Botão **−** no topo para recolher.
- Botão flutuante **N**, arrastável com mouse ou toque, para reabrir.
- Cabeçalho arrastável e adaptação ao tamanho da tela.
- **Shift direito** para abrir e recolher no teclado.
- Identificação de entrada: **MOBILE**, **PC** ou **CONTROLE**.
- Reexecutar substitui a interface anterior e mantém o valor da sessão.

## Instalação no Studio

1. Abra **StarterPlayer > StarterPlayerScripts**.
2. Crie um **LocalScript**.
3. Cole o conteúdo completo de **NovaPanel.client.lua**.
4. Use **Play** para testar. Para testar toque, use a emulação de dispositivos.

## Como a sensibilidade funciona

O painel assume o controle da câmera em modo **Scriptable**, para desligar o controlador padrão do Roblox. A orientação vem diretamente do toque, mouse ou controle; a rotação produzida por outros scripts não entra no cálculo. Há uma única atualização de câmera por quadro, na prioridade **RenderPriority.Last + 1**.

Frames acima de **100 ms** descartam o movimento acumulado. Entradas antigas também são descartadas, e picos de giro têm limite de velocidade. O excedente é descartado no mesmo quadro, sem uma fila que continue girando após a travada.

O controlador acompanha o personagem local, aceita zoom com dois dedos ou roda do mouse, libera o cursor ao abrir o painel no PC e tem suporte a primeira pessoa e shift lock. O joystick de movimento e os controles da interface não entram no arraste da câmera. Ao arrastar a barra, a rolagem do painel fica temporariamente suspensa.

Para coexistir com câmeras personalizadas, outros scripts do próprio jogo podem consultar o atributo local **NovaCameraActive** do jogador e suspender sua atualização enquanto ele estiver ativo. A prioridade final cobre os controladores que atualizam antes dela; um script que force mudanças depois dessa prioridade precisa respeitar esse atributo ou ser integrado ao controlador. Não há garantia universal de exclusividade contra scripts que continuem sobrescrevendo a câmera depois dele.

O valor vale apenas para o cliente e a sessão atual. A sensibilidade salva na conta não é alterada. Ao remover ou substituir o painel, o callback é desconectado e os tipos de câmera, cursor e visibilidade local modificados pelo controlador são restaurados.

## Desempenho e verificação

A interface usa eventos e TweenService nas interações, atualizando os textos somente quando o valor muda. A câmera mantém um callback de custo constante e recalcula a rotação apenas quando há entrada. As verificações de obstáculos ficam limitadas a **20 por segundo em movimento** e **4 por segundo em repouso**, sem laços de compensação após um lag.

Foram verificadas a sintaxe Lua e, em uma simulação de cliente, a faixa até 5×, os incrementos 2,0→2,1→2,2, o controle único, o conflito com uma câmera que muda a orientação, a travada de 500 ms, a ausência de giro acumulado, os picos de entrada, o limite de colisões, a primeira pessoa, o zoom, o respawn e a limpeza ao reexecutar/remover.

**O FPS, a integração final e a resposta no celular ainda precisam ser conferidos no Roblox. Os testes simulados não medem o desempenho real do dispositivo.**

O script não contém pulo automático.

**ReferencePanelDemo.client.lua** é o protótipo anterior; o painel novo usa o arquivo **NovaPanel.client.lua**.
