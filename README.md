# NOVA · Camera Panel v1.3

Painel em Lua/Luau para o cliente da sua experiência no Roblox, com apenas o controle de **sensibilidade da câmera**.

## Arquivo atual

- [NovaPanel.client.lua](./NovaPanel.client.lua)
- [Abrir o código Raw](https://raw.githubusercontent.com/twixbryan4-cloud/roblox-painel/refs/heads/main/NovaPanel.client.lua)

## O que tem

- Inicialização animada e curta.
- Visual escuro em tons de ameixa, cantos arredondados, fonte **Roboto Mono**, títulos em negrito e crédito **by askzedd**.
- Barra lateral **Main / Misc**, com ícones lineares de casa e cubos desenhados no próprio script.
- Seleção suave e fade-in de 120 ms ao trocar de categoria, sem esperar uma saída nem reconstruir os controles.
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
- Vídeo opcional atrás do conteúdo, com camada escura limitada ao painel, proporção preservada, pausa ao recolher e retomada ao abrir.

## Categorias

- **Main:** contém a sensibilidade existente, slider, ajuste preciso e quatro atalhos de velocidade.
- **Misc:** mostra a entrada atual e como abrir/recolher; o botão **Recolher painel** usa a mesma função do botão superior. Não acrescenta funções de jogo.

## Instalação no Studio

1. Abra **StarterPlayer > StarterPlayerScripts**.
2. Crie um **LocalScript**.
3. Cole o conteúdo completo de **NovaPanel.client.lua**.
4. Use **Play** para testar. Para testar toque, use a emulação de dispositivos.

## Fundo de vídeo no Studio

A versão v1.2 do repositório não tinha `VideoFrame` nem ID de vídeo configurado. A v1.3 reaproveita um fundo configurado por qualquer uma destas formas:

- Crie um **VideoFrame** chamado **BackgroundVideo** como filho do LocalScript e configure sua propriedade **Video** com o asset do seu vídeo. O script copia o conteúdo, a posição de reprodução e o volume para dentro do painel.
- Ou crie no LocalScript o atributo **BackgroundVideoId**, como string `rbxassetid://SEU_ID` ou número do asset.

O vídeo enviado precisa ser importado/publicado como asset de vídeo no Roblox e estar acessível à experiência. Um MP4 anexado ao chat ou um link do TikTok não é diretamente reproduzível por esse LocalScript no Studio. Consulte a [documentação de vídeos do Roblox](https://create.roblox.com/docs/ui/video-frames).

O fundo aparece apenas dentro do painel, sem mudar a transparência da tela inteira. Trocar de aba não reinicia o vídeo. Ao recolher, o decoder é liberado; a posição é guardada para reabrir e para reexecutar durante a sessão. O carregamento do vídeo não bloqueia a interface. Sem asset configurado, continua disponível o fundo escuro translúcido; o script não usa vídeos ou IDs inventados.

## Como a sensibilidade funciona

O painel assume o controle da câmera em modo **Scriptable**, para desligar o controlador padrão do Roblox. A orientação vem diretamente do toque, mouse ou controle; a rotação produzida por outros scripts não entra no cálculo. Há uma única atualização de câmera por quadro, na prioridade **RenderPriority.Last + 1**.

Frames acima de **100 ms** descartam o movimento acumulado. Entradas antigas também são descartadas, e picos de giro têm limite de velocidade. O excedente é descartado no mesmo quadro, sem uma fila que continue girando após a travada.

O controlador acompanha o personagem local, aceita zoom com dois dedos ou roda do mouse, libera o cursor ao abrir o painel no PC e tem suporte a primeira pessoa e shift lock. O joystick de movimento e os controles da interface não entram no arraste da câmera. Ao arrastar a barra, a rolagem do painel fica temporariamente suspensa.

Para coexistir com câmeras personalizadas, outros scripts do próprio jogo podem consultar o atributo local **NovaCameraActive** do jogador e suspender sua atualização enquanto ele estiver ativo. A prioridade final cobre os controladores que atualizam antes dela; um script que force mudanças depois dessa prioridade precisa respeitar esse atributo ou ser integrado ao controlador. Não há garantia universal de exclusividade contra scripts que continuem sobrescrevendo a câmera depois dele.

O valor vale apenas para o cliente e a sessão atual. A sensibilidade salva na conta não é alterada. Ao remover ou substituir o painel, o callback é desconectado e os tipos de câmera, cursor e visibilidade local modificados pelo controlador são restaurados.

## Desempenho e verificação

A interface usa eventos e TweenService nas interações, atualizando os textos somente quando o valor muda. As páginas e os ícones são criados uma vez; clicar na aba já selecionada não cria animações. O layout é recalculado por mudança do tamanho da tela e a identificação de dispositivo por mudança da entrada preferida. Não há loop de animação decorativa.

O bloco do controlador de câmera é idêntico ao da v1.2. Ele mantém um callback de custo constante e recalcula a rotação apenas quando há entrada. As verificações de obstáculos ficam limitadas a **20 por segundo em movimento** e **4 por segundo em repouso**, sem laços de compensação após um lag.

Foram verificadas a sintaxe Lua e, em uma simulação de cliente, a faixa até 5×, os incrementos 2,0→2,1→2,2, o controle único, o conflito com uma câmera que muda a orientação, a travada de 500 ms, a ausência de giro acumulado, os picos de entrada, o limite de colisões, a primeira pessoa, o zoom, o respawn e a limpeza ao reexecutar/remover.

A simulação também cobriu troca rápida de categorias, preservação dos controles, soltura do slider ao trocar de aba, ausência de tweens em repouso e layouts de 320×640 a 1920×1080. Os botões têm alvo mínimo de 44 px; em conteúdo estreito, os presets ficam em duas colunas e as páginas permitem rolagem vertical. O teste do vídeo verifica a integração e a pausa/retomada com um `VideoFrame` simulado; não valida download, permissões ou reprodução de um asset real.

## Roteiro de teste no Studio

1. **Inicialização:** inicie com Play; confira o carregamento curto, textos claros, transparência do fundo e crédito no cabeçalho.
2. **Main:** arraste a barra de 0,1× a 5×; use −0,1/+0,1 para passar de 2,0 a 2,1 e 2,2. Toque nos atalhos 0,5×, 1×, 2× e 5×. Recolha o painel e compare o mesmo movimento de câmera em 1× e 2×.
3. **Misc:** confira dispositivo e instrução de acesso. Troque rapidamente Main/Misc e volte à Main: valor, controles e posição da rolagem devem continuar disponíveis. **Recolher painel** deve mostrar o botão flutuante.
4. **Abertura:** teste − no topo, botão flutuante e Shift direito no PC. Arraste o botão flutuante sem abrir por engano, depois dê um toque curto para reabrir. Arraste também pelo cabeçalho.
5. **Mobile:** emule 320×640 e modo paisagem. Role a página até todos os controles; arraste o slider e confira que a rolagem volta ao soltar. Toques na interface não devem girar a câmera.
6. **Vídeo configurado:** confira legibilidade e proporção. Troque abas sem reiniciar o fundo; recolha/reabra para verificar pausa/retomada. Um asset indisponível não deve impedir o painel de abrir.
7. **Regressão de câmera:** teste zoom, primeira pessoa, shift lock, respawn e reexecução. Use o MicroProfiler e o painel de desempenho do Studio/dispositivo para conferir o custo real.

**O FPS, a integração final e a resposta no celular ainda precisam ser conferidos no Roblox. Os testes simulados não medem o desempenho real do dispositivo.**

O script não contém pulo automático.

**ReferencePanelDemo.client.lua** é o protótipo anterior; o painel novo usa o arquivo **NovaPanel.client.lua**.
