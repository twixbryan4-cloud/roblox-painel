# NOVA · Camera Panel

Painel em Lua/Luau para o cliente da sua experiência no Roblox, com apenas o controle de **sensibilidade da câmera**.

## Arquivo atual

- [NovaPanel.client.lua](./NovaPanel.client.lua)
- [Abrir o código Raw](https://raw.githubusercontent.com/twixbryan4-cloud/roblox-painel/refs/heads/main/NovaPanel.client.lua)

## O que tem

- Inicialização animada e curta.
- Visual escuro com detalhes em azul e lilás, fonte Gotham e crédito **by askzedd**.
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

O script procura o CameraInput do PlayerModule padrão e multiplica o resultado de getRotation. Assim, o mesmo controle ajusta a rotação por mouse, toque e controle, mantendo a lógica padrão de zoom e colisões.

Esse módulo é interno ao Roblox e pode mudar. Uma câmera personalizada que não use essa entrada precisa de integração própria. Se a entrada não estiver acessível, o painel informa **“Câmera não compatível com este ajuste”** e não ativa o slider.

O valor vale apenas para o cliente e a sessão atual. Não altera a sensibilidade salva na conta Roblox. Ao remover ou substituir o painel, a função original da câmera é restaurada.

## Desempenho e verificação

A interface não usa um loop por frame, consultas periódicas a jogadores, imagens externas nem desfoque de tela inteira. As animações usam TweenService apenas ao iniciar e interagir. O controle da câmera acrescenta uma multiplicação à entrada que ela já processa.

Foram verificadas a sintaxe Lua e, em uma simulação de cliente, a sensibilidade, os limites, o slider com toque, o arraste, as transições interrompidas e a limpeza ao reexecutar/remover. **O visual e a integração no Roblox ainda precisam ser conferidos no Studio ou no dispositivo.**

O script não contém pulo automático.

**ReferencePanelDemo.client.lua** é o protótipo anterior; o painel novo usa o arquivo **NovaPanel.client.lua**.
