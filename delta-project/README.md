# delta-project — Video reference panel 0.3.0

Painel Lua independente recriado a partir das imagens e dos dois videos enviados.
Mantem o visual preto compacto, categorias na lateral, controles em duas colunas,
fade curto entre categorias e previa 3D do avatar.

Codigo: `delta-project/main.lua`, branch `delta-project-zero` do repositorio
`twixbryan4-cloud/roblox-painel`.

## Executar e comparar com o video

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/twixbryan4-cloud/roblox-painel/delta-project-zero/delta-project/main.lua"))()
```

1. Toque em **Blue look**, na barra superior, para aplicar a composicao azul.
2. Em **World → Video looks**, compare **Blue**, **Violet** e **Crimson lighting**.
3. Em **World → Circle**, use **Test Circle** para ver o circulo no chao.
4. Em **Models**, ajuste o chapeu e o halo. Em **World**, ajuste aura, rastro e linhas.

**Insert** ou **≡** ocultam e reabrem o painel. A parte vazia da barra superior
permite arrastar a janela, e arrastar a previa gira o avatar. Colunas e categorias
tem rolagem independente e suporte a toque. Os efeitos comecam desativados;
os presets os ativam em conjunto.

## Acrescentado apos a analise dos videos

| Elemento observado | Implementacao |
| --- | --- |
| Aura azul/violeta em espiral | Ribbons orbitais animados, particulas e selecao combinada de Angelic, Ambient e Nimb. |
| Anel luminoso sobre o avatar | Halo de geometria local, com cor, raio, altura, inclinacao e rotacao. |
| Chapeu conico | Modelo procedural com triangulos, cor, tamanho, altura e rotacao. |
| Constelacoes e linhas no ambiente | Grupos de linhas 3D com movimento, fade, cor, quantidade, largura e glow. |
| Particulas flutuando pela cena | Emissor local proximo a camera, com cor e quantidade ajustaveis. |
| Circulo no chao | Aneis e pentagrama projetados sobre o piso, com vida, crescimento, cor, brilho e rotacao. |
| Rastro | Sparkle, Snow, Stars, Ribbon e Smoke, com tamanho, densidade, comprimento, brilho, espalhamento e deriva. Snow e Stars sao variacoes procedurais do emissor, sem as texturas privadas do original. |
| Menu de tipos de aura | Selecao multipla com feedback imediato. |
| Efeitos de morte | Chams temporario e Neon Burst em eventos de morte do alvo escolhido, alem de botao para testar. |
| Sons | IDs configuraveis para dano e morte, dependentes das permissoes do audio no jogo. |
| Geometria animada no menu | Wireframe 2D projetado e animado enquanto a categoria Menu esta visivel. |
| Lista de configuracoes | Salvar, listar, selecionar, carregar, copiar, excluir e restaurar configuracoes do proprio projeto. |

## Categorias

- **ESP:** contorno, nomes, distancia em studs, vida, equipe e alcance.
- **World:** shaders, skybox, iluminacao, aura, rastro, circulos, linhas e efeitos.
- **Screen:** FOV, mira, watermark e particulas de ambiente.
- **Skins:** cor e material locais do personagem, com restauracao.
- **Models:** previa, silhueta branca, rotacao, chapeu e halo.
- **Emotes / Animations:** emotes disponiveis no avatar, velocidade e parada.
- **Helpers:** atualizar avatar, restaurar ajustes, desativar efeitos e descarregar.
- **Menu:** tecla, escala, transparencia, qualidade, arte da lateral e configuracoes.
- **Music:** audio por ID, pausa, volume e repeticao.

Os efeitos sao locais. `Self` seleciona seu personagem. `Others` seleciona os
jogadores mais proximos, dentro de 500 studs, com limite de 2 na qualidade baixa
e 4 na alta. Efeitos de dano e morte observam os eventos dos alvos; o painel
nao determina quem causou o dano e nao aplica dano.

## Qualidade e encerramento

**Menu → Effect quality** oferece Auto, Low e High. Auto usa o perfil reduzido
em dispositivos de toque: ate 14 grupos de linhas, menos segmentos e menos
particulas. High permite ate 32 grupos. Cor, velocidade, largura e rotacao sao
atualizadas sem recriar toda a cena durante esses ajustes.

**Unload** remove objetos, eventos e sons criados pelo painel e restaura as
propriedades de iluminacao e camera que ele alterou. Reexecutar encerra a
instancia anterior. Os alvos sao atualizados apos respawn.

## Configuracoes

As configuracoes contem apenas valores validados em JSON. O painel usa as
funcoes de arquivo e clipboard quando disponiveis no ambiente e informa
quando uma operacao nao esta disponivel. Leitura, listagem e exclusao ficam
restritas aos nomes de configuracao do proprio projeto.

Perfis da versao 0.2 continuam aceitos; os campos novos usam seus valores iniciais.
IDs de audio e imagem aceitam somente numeros.

## Recursos que precisam dos arquivos originais

Os videos nao fornecem o codigo do painel original, a ilustracao da lateral,
as seis imagens da skybox vermelha ou suas texturas de efeitos. Os recursos
visiveis foram recriados com geometria e recursos do Roblox; nao sao os
arquivos originais.

- **Menu → Artwork ID:** substitui a miniatura do seu avatar por uma imagem
  publicada no Roblox, quando seu ID for conhecido.
- **World → Skybox → Custom:** libera seis campos em **Skybox assets** para
  Back, Down, Front, Left, Right e Up. Todas as faces precisam de IDs validos.
- **Crimson lighting** recria uma iluminacao vermelha; a paisagem da floresta
  depende das imagens originais da skybox.
- A previa mostra o avatar, o chapeu e o halo; emissores de particulas do mundo
  nao sao renderizados dentro dela.

## Validacao realizada

- Compilacao em Lua 5.4 e testes de contrato com uma API Roblox simulada.
- Dez categorias, callbacks, toque ativo, seletor de cor e selecao multipla.
- Presets, criacao e encerramento de geometria, ciclos de animacao, rastro por
  movimento, expiracao de circulos e perfil de qualidade para celular.
- Troca de alvos apos respawn, eventos de dano/morte, limites de objetos e sons.
- Listagem, copia e exclusao de configuracoes e restauracao das seis faces de
  skybox, incluindo propriedades booleanas originalmente desativadas.
- Ocultar/reabrir, reexecucao, unload, restauracao de FOV e iluminacao e
  preservacao dos personagens originais ao remover efeitos.

**A execucao e a renderizacao reais no Roblox/Delta ainda precisam ser validadas
no dispositivo.** Os testes simulados nao substituem esse teste.

APIs consultadas: [ViewportFrame](https://create.roblox.com/docs/reference/engine/classes/ViewportFrame),
[ParticleEmitter](https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter),
[Trail](https://create.roblox.com/docs/reference/engine/classes/Trail),
[CFrame](https://create.roblox.com/docs/reference/engine/datatypes/CFrame),
[RaycastParams](https://create.roblox.com/docs/reference/engine/datatypes/RaycastParams) e
[Player](https://create.roblox.com/docs/reference/engine/classes/Player).
