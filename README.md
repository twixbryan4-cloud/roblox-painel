# NOVA · Camera Panel v1.1

Painel em Lua/Luau para o cliente da sua experiência no Roblox, com apenas o controle de **sensibilidade da câmera**.

## Arquivo atual

- [NovaPanel.client.lua](./NovaPanel.client.lua)
- [Abrir o código Raw](https://raw.githubusercontent.com/twixbryan4-cloud/roblox-painel/refs/heads/main/NovaPanel.client.lua)

## O que tem

- Inicialização animada e curta.
- Visual escuro com detalhes em azul e lilás, fonte Gotham e crédito **by askzedd**.
- Fundo realmente translúcido, com textos e controles preservados em cores claras.
- Ajuste de **0,25× a 3×**, com **1×** como velocidade original.
- Barra deslizante e atalhos de **0,5×**, **1×** e **2×**.
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

O script usa as APIs públicas da câmera. Durante um arraste, mede a orientação imediatamente antes e depois da atualização padrão do Roblox e ajusta esse giro pelo valor escolhido. Funciona com toque, arraste do mouse e mouse travado em primeira pessoa/shift lock. O controle analógico também pode ativar o ajuste.

Não exige acesso ao PlayerModule nem ao CameraInput. A barra e os presets permanecem operantes sem esses módulos. Ao arrastar a barra no celular, a rolagem do painel fica temporariamente suspensa para não disputar o gesto.

O ajuste mantém o ponto de foco e a distância da câmera, com uma verificação de obstáculos quando gira em terceira pessoa. Não altera CameraType, MouseBehavior nem a sensibilidade salva na conta. Em câmeras Scriptable, como cenas e alguns sistemas próprios de jogo, a correção fica suspensa. Sistemas personalizados que atualizem a câmera após a prioridade padrão podem precisar de integração específica.

O valor vale apenas para o cliente e a sessão atual. Ao remover ou substituir o painel, as funções de atualização adicionais são desconectadas.

## Desempenho e verificação

A interface usa eventos e TweenService nas interações. O ajuste da câmera conecta duas funções curtas ao ciclo de renderização apenas enquanto uma entrada de câmera está ativa e o valor difere de 1×. A correção retorna cedo sem movimento; não há consultas periódicas a jogadores, imagens externas ou desfoque de tela inteira.

Foram verificadas a sintaxe Lua e, em uma simulação de cliente com operações de câmera, a ausência de gradientes sobre o CanvasGroup, a transparência do fundo, os controles sem módulos internos, o giro real em 0,5× e 2×, a manutenção do zoom, os obstáculos, o joystick, o gesto com dois dedos e a limpeza ao reexecutar/remover.

**O visual e a integração final no Roblox ainda precisam ser conferidos no Studio ou no dispositivo.**

O script não contém pulo automático.

**ReferencePanelDemo.client.lua** é o protótipo anterior; o painel novo usa o arquivo **NovaPanel.client.lua**.
