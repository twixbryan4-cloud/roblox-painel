# delta-project — Reference panel 0.2.0

Interface Lua independente, implementada a partir das imagens de referencia.
Usa painel preto compacto, categorias na lateral, controles em duas colunas,
transicao curta de categoria e uma previa 3D do avatar em painel separado.

O codigo fica em `delta-project/main.lua`, na branch `delta-project-zero` do
repositorio `twixbryan4-cloud/roblox-painel`.

## Executar

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/twixbryan4-cloud/roblox-painel/delta-project-zero/delta-project/main.lua"))()
```

O painel abre em **World**. Use **Insert** ou o botao flutuante **≡** para
ocultar e reabrir. Arraste a parte vazia da barra superior para mover o painel;
arraste o avatar da previa para gira-lo. As colunas e a lista de categorias
tem rolagem independente, inclusive por toque.

## Categorias

| Categoria | Controles implementados |
| --- | --- |
| ESP | Contorno dos jogadores, nomes, distancia em studs, vida, filtro de equipe e alcance. |
| World | Presets de iluminacao, estrelas, fog, bloom, sun rays, blur, color grade, atmosfera, aura, rastro e cores. |
| Screen | FOV, mira e watermark com FPS e horario local. |
| Skins | Cor e material locais do personagem, com restauracao. |
| Models | Previa do avatar, silhueta branca e rotacao. |
| Emotes | Tentativa de reproduzir emotes que o avatar possui; velocidade e parada. |
| Animations | Velocidade e parada dos emotes iniciados pelo painel, alem da rotacao da previa. |
| Helpers | Atualizar avatar, restaurar configuracoes, desativar efeitos e descarregar. |
| Menu | Tecla de abertura, transparencia, escala e configuracoes. |
| Music | Reproducao de audio por ID, volume, pausa e repeticao. |

Os efeitos de mundo, aparencia e ESP sao locais. Aura e rastro comecam
**desativados**. As opcoes extras de fog, bloom, blur e atmosfera aparecem ao
ativar o respectivo efeito; a busca tambem pode encontra-las.

## Configuracoes e encerramento

**Menu → Config** salva e carrega apenas valores validados em JSON. O recurso
usa `readfile` e `writefile` quando o ambiente disponibiliza essas funcoes;
mostra uma mensagem quando nao pode gravar ou ler arquivos. Os nomes sao
limitados a letras, numeros, `_` e `-`.

**Unload** remove os objetos e eventos criados pelo painel e restaura as
propriedades que ele alterou. Reexecutar o loader encerra a instancia anterior.
A interface acompanha o respawn do personagem.

## Limites desta versao

As imagens nao contem o codigo, a ilustracao original da lateral, os arquivos
de skybox nem os efeitos exclusivos do painel de referencia. A lateral usa
uma miniatura do seu avatar, e os efeitos foram recriados com recursos do
Roblox. Nao e uma copia dos arquivos originais.

A previa 3D mostra o avatar e sua silhueta; ela nao renderiza os emissores de
particulas do mundo. Musicas dependem das permissoes de audio do jogo. Emotes
dependem dos que estao disponiveis no avatar.

## Validacao

- Sintaxe compilada em Lua 5.4.
- Inicializacao das dez categorias e callbacks dos controles verificados com
  uma API Roblox simulada.
- Verificadas normalizacao de valores, toque ativo, limpeza de popups,
  configuracoes, limites da janela, ocultar/reabrir, reexecucao e unload.
- Verificada restauracao de iluminacao e FOV e a preservacao dos personagens
  originais ao remover os objetos de ESP.

**A renderizacao real no Roblox e a execucao no Delta ainda precisam ser
validadas no dispositivo.** A simulacao nao substitui esse teste.

## APIs de referencia

- [ViewportFrame](https://create.roblox.com/docs/reference/engine/classes/ViewportFrame)
- [ParticleEmitter](https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter)
- [Trail](https://create.roblox.com/docs/reference/engine/classes/Trail)
- [GuiBase2d](https://create.roblox.com/docs/reference/engine/classes/GuiBase2d)
- [Humanoid](https://create.roblox.com/docs/reference/engine/classes/Humanoid)
