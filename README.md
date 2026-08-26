# KayceePvP — atualização do PC2

Este repositório contém a build de distribuição do KayceePvP para que os dois computadores usem **exatamente a mesma DLL**, e é também o canal usado para reportar bugs de volta (branch `report-de-erros`).

**Encontrou algo estranho numa partida?** Veja `COMO-REPORTAR-BUGS.md` neste repositório — não precisa esperar a próxima atualização pra reportar.

## Instruções para o agente no PC2

### Método recomendado — atualização automática

Abra o PowerShell nesta pasta e execute:

```powershell
powershell -ExecutionPolicy Bypass -File .\Atualizar-PC2.ps1
```

O script procura o profile `KayceePvP`, encontra todas as cópias da DLL dentro
dos plugins desse profile, substitui e valida cada uma. Se o profile ativo tiver
outro nome, use:

```powershell
powershell -ExecutionPolicy Bypass -File .\Atualizar-PC2.ps1 -ProfileName "NOME_EXATO"
```

Só abra o jogo depois da mensagem `ATUALIZADA E VALIDADA`.

### Método manual

1. Feche completamente o Inscryption e confirme que não existe `Inscryption.exe` no Gerenciador de Tarefas.
2. Atualize este repositório na branch `master` (`git pull origin master`) ou baixe novamente o arquivo `KayceePvP.dll` da raiz.
3. Localize o profile do Thunderstore usado no PC2. O caminho costuma ser:

   ```text
   %APPDATA%\Thunderstore Mod Manager\DataFolder\Inscryption\profiles\KayceePvP
   ```

4. Substitua a DLL antiga por `KayceePvP.dll` neste destino:

   ```text
   BepInEx\plugins\KayceePvP\KayceePvP.dll
   ```

5. Não deixe uma segunda cópia de `KayceePvP.dll` em outra subpasta de `BepInEx\plugins`.
6. Confirme o SHA-256 da DLL instalada no PowerShell:

   ```powershell
   Get-FileHash -Algorithm SHA256 "CAMINHO_DO_PROFILE\BepInEx\plugins\KayceePvP\KayceePvP.dll"
   ```

   Hash esperado desta build:

   ```text
   06200E2C2FFDB1AC911A9C7577DFB9106C495685AFB382A7FF72921214C8FADC
   ```

   (build de 2026-08-25 - corrigido o deck PELES, que vinha com peles
   demais; veja a nota abaixo)

   **Não conte nem copie a quebra de linha exibida pelo terminal.** Um SHA-256 possui
   exatamente 64 caracteres hexadecimais. Para evitar qualquer ambiguidade, execute
   a comparação automática abaixo, trocando somente o caminho:

   ```powershell
   $esperado = "06200E2C2FFDB1AC911A9C7577DFB9106C495685AFB382A7FF72921214C8FADC"
   $obtido = (Get-FileHash -Algorithm SHA256 "CAMINHO_DO_PROFILE\BepInEx\plugins\KayceePvP\KayceePvP.dll").Hash
   $obtido.Length
   $obtido -eq $esperado
   ```

   O resultado correto é `64` e depois `True`. O arquivo `SHA256SUMS.txt`
   contém o mesmo checksum em formato legível por ferramentas automáticas.

7. **IMPORTANTE - confira a versão da dependência `API` (autor `API_dev`) nesse profile.** Esta build foi compilada contra a versão `2.24.0`. Se o profile do PC2 ainda tiver a `API` numa versão diferente (ex: `2.23.7`), o mod pode falhar ao carregar ou dar erro ao iniciar - **esse é o suspeito nº 1 se o jogo der erro ao abrir**. Atualize a dependência `API` para `2.24.0` pelo Thunderstore Mod Manager (aba de mods do profile) antes de continuar. `Atualizar-PC2.ps1` (método automático) já checa isso e avisa se a versão estiver errada.
8. Só depois da confirmação do hash E da versão da `API`, abra o jogo pelo profile correto do Thunderstore.
9. No lobby, confirme que não aparece incompatibilidade `local=3 peer=0`. Ambos os lados precisam anunciar o mesmo protocolo.

## Correção nova nesta build (2026-08-25, achada no teste real): deck PELES vinha com peles demais

O deck inicial "PELES" (menu de seleção de baralho) estava registrado
errado desde o início: em vez das 3 cartas originais do mod antigo
(1 Pele Dourada, 1 Pele de Lobo, 1 Pele de Coelho), o código tinha a
Pele de Coelho triplicada por engano, resultando em 5 cartas em vez de
3. Reconferido byte a byte contra o `.dll` original do mod antigo
(ainda em cache no disco) - confirmado que a composição certa é
mesmo 1 de cada. Corrigido.

## Correção nova nesta build (2026-08-25, achada no seu teste solo): erro de conexão depois de um tempo de partida

Achamos por que a conexão caía sozinha depois de um tempo jogando, sem
nada de especial acontecer. A mensagem no log era `IOException: ...
An established connection was aborted in your host machine.` - esse
texto específico é como o .NET avisa que um limite de tempo de leitura
estourou, não que a conexão caiu de verdade do outro lado. O código
só dava 10 segundos para o resto de uma mensagem terminar de chegar
depois do primeiro pedacinho dela - e esse mesmo teste (2 processos do
jogo brigando pelos recursos da mesma máquina) já tinha mostrado
atrasos de rede de mais de 36 segundos em outros pontos do log.
Corrigido: agora são 60 segundos de folga.

## Correção nova nesta build (2026-08-25, achada no seu teste solo): erro de conexão no turno 2

Achamos por que a conexão caiu logo no turno 2, mesmo sem nada de
especial acontecer. O lado que recebe (PEER) tem um contador interno
que diz "qual turno do outro lado eu já posso aceitar". Só que esse
contador era montado em dois passos, e o segundo passo sobrescrevia o
primeiro sem checar se ele já tinha avançado de verdade - se o HOST
fechasse o turno inicial rápido o suficiente, essa sobrescrita apagava
o progresso real e o PEER ficava travado achando que ainda esperava o
turno 0, mesmo já tendo recebido ele. Quando o HOST fechava o turno 2
de verdade, o PEER recusava por achar que era "um turno do futuro" -
`PROTOCOL_DESYNC_FATAL`. Corrigido: o segundo passo agora não
sobrescreve mais um progresso já feito.

## Correção nova nesta build (2026-08-25, achada no teste solo com o Snelk): timeout aumentado

No seu teste sozinho, dois processos completos do jogo rodando na mesma
máquina disputam CPU/GPU entre si de um jeito que não acontece entre 2
PCs de verdade. O log mostrou um atraso de rede sozinho de ~26 segundos
num único pacote durante o ataque do Snelk, e o combate do seu lado
resolveu certinho, só que depois do limite de 15 segundos já ter
disparado o `PROTOCOL_DESYNC_FATAL` por segurança. Não era uma
dessincronização de verdade, só falta de paciência do timeout. Aumentado
de 15s pra 45s.

## Correção nova nesta build (2026-08-25, achada testando a Colmeia): o `CorpseEater`

Achamos por que o `PROTOCOL_DESYNC_FATAL` com `card=Beehive`/`card=Bee` acontecia
sempre do lado de quem era dono da Colmeia com `CorpseEater`. A habilidade
real do jogo (`CorpseEater`) joga a carta sozinha no tabuleiro, sem
nenhum clique, no instante em que uma aliada sua morre em combate. Só que
isso costuma acontecer no turno do **adversário** (quando ele ataca e
mata sua aliada), e o código antigo tratava toda jogada automática como
se fosse um clique manual seu, exigindo que fosse o SEU turno pra
mandar pro outro lado. Corrigido: jogadas automáticas de habilidade
agora têm um caminho próprio, sem essa exigência de turno.

## IMPORTANTE antes de abrir o jogo com esta build: desative o TVFsStarterDecks

O mod TVFLabs-TVFsStarterDecks não é mais dependência do KayceePvP (o deck
"Pelts" dele virou nativo, chamado "PELES" na seleção). Se esse mod ainda
estiver habilitado no seu profile, o KayceePvP agora recusa deixar você
ficar "Pronto" (ver a seção do bloqueio de mods abaixo). Antes de testar:
desabilite (ou desinstale) o TVFsStarterDecks nesse profile pelo próprio
Thunderstore Mod Manager. Nenhum outro mod deve estar habilitado além de
BepInExPack, MonoMod Loader e API.

## Correção nova nesta build (2026-08-25): o `STATE HASH MISMATCH` do último log

Achamos a causa exata do que apareceu na sua partida de hoje. Quando uma
carta com um sigilo que reposiciona sozinho no fim do turno (Estampida/
Strafe, ex: Pronghorn) terminava um turno que não era o primeiro da
batalha, os dois lados calculavam o "resumo" (hash) do tabuleiro em momentos
diferentes: um lado antes da carta se mover, o outro depois. Isso gerava um
`STATE HASH MISMATCH` real no log e, pouco depois, travava a partida de vez
(`PROTOCOL_DESYNC_FATAL`), exatamente como aconteceu com você. Corrigido pra
qualquer turno, qualquer mapa, não só o turno de abertura (que já tinha
sido corrigido antes).

**Também nesta build**: o mod agora recusa deixar você marcar "Pronto" se
detectar qualquer outro mod instalado no seu profile que não seja uma
dependência conhecida do KayceePvP (API/CommunityPatch/ele mesmo). Isso
existe porque um outro jogador reportou cartas de mods de terceiros
vazando pro pool do PvP e causando bugs. Se isso acontecer com você, o jogo
mostra uma mensagem dizendo exatamente qual mod remover.

**Baralho do F6 atualizado pra testar esse fix específico** (veja
`KayceePvP.F6Deck.txt` incluído neste update, o `Atualizar-PC2.ps1` já
copia ele junto com a DLL): Squirrel/Goat/Pronghorn/Snelk. No turno 1, joga
Squirrel, sacrifica pra jogar Goat, sacrifica pra jogar Pronghorn (fica
sozinho no tabuleiro) e toca o sino. No turno 3, joga Snelk sozinho num
slot e Pronghorn (2ª cópia) sozinho em outro, toca o sino de novo. Repita
a sequência nos dois PCs. Se aparecer erro, manda o log de novo (veja
`COMO-REPORTAR-BUGS.md`); senão, essa é a confirmação que faltava pra
fechar esse bug de vez.

**Segundo cenário no mesmo baralho: a Colmeia do report bilateral.** O F6
agora também traz `Beehive+CorpseEater+Sacrificial` (a Colmeia com as duas
habilidades extras que ela tinha na sua partida, além do `BeesOnHit`
normal dela). Posicione um Squirrel numa lane onde o Pronghorn do oponente
vai atacar, mantenha a Colmeia na mão; quando o Pronghorn matar o
Squirrel em combate, o `CorpseEater` deve fazer a Colmeia entrar sozinha
em campo, de graça, pro lado que perdeu o Squirrel. Repita nos dois PCs
(cada um com seu próprio Squirrel morto) e confira os dois logs por
`STATE HASH MISMATCH`/`PROTOCOL_DESYNC_FATAL` com `card=Beehive`.

## O que esta build corrige (acumulado desde a última atualização do PC2, 2026-08-07)

Sessão longa de correções reais de sincronização de rede e recursos novos.
Destaques mais relevantes pra jogar:

- **Correções de sincronização confirmadas por log real** (bugs que só
  apareciam jogando de verdade entre 2 PCs, não em teste local): mãos
  embaralhadas de forma diferente a cada batalha do melhor-de-3 (antes
  repetiam a mesma ordem); limiar de vitória do duelo PvP unificado em 15
  dentes em todos os modos; stats do Morsel (Larva) sincronizados
  corretamente entre os dois lados; um falso-positivo de "estado
  dessincronizado" no fim de turno foi identificado e corrigido (o jogo
  nunca tinha realmente dessincronizado nesse ponto, era um bug de
  diagnóstico).
- **Rato Misterioso virou "Rato Curioso" e Amoeba virou "Ameba Alfa"**:
  depois de vários bugs reais de sincronização causados pelo sigilo
  Amorphous (habilidade aleatória) nessas duas cartas, abandonamos esse
  design. Agora o Rato Curioso tem `Tutor` (Pega-rabuda/Hoarder) fixo e a
  Ameba Alfa tem `BuffNeighbours` (Líder/Leader) fixo - sem sorteio, sem
  risco de dessincronizar. Nenhuma das duas concede mais item de mochila.
- **Novo modo de mapa**: as 3 rotas do modo "Batalhas" (Refinamento/Totem/
  Expansão) foram redesenhadas com identidades próprias (decks
  trabalhados/clonados, sinergia tribal com Totem, ou deck grande com
  economia de peles). O estipêndio pós-batalha central agora é concedido
  aos dois jogadores, vença ou perca.
- **F6 agora é configurável**: o baralho de teste do atalho F6 pode ser
  editado num arquivo de texto (sem recompilar), útil pra reproduzir
  cenários específicos rapidamente.
- Novo starter deck "COBAIAS" (Rato Curioso + Larva + Skink) disponível na
  seleção normal quando multiplayer está habilitado.
- Dependência `API` atualizada para `2.24.0` (ver passo 7 acima - precisa
  atualizar dos dois lados).

## Correção nova nesta build (2026-08-24, achada no seu último report)

O log que você mandou (obrigado!) mostrou que TODAS as cartas divergiam
entre os dois lados desde a primeira jogada da batalha. Achamos a causa
exata: um sigilo que reposiciona a criatura no fim do turno (como o do
Moose) disparava certinho no lado de quem jogou, mas nunca disparava no
espelho do outro lado — só na primeira jogada de cada batalha. Isso fazia
o tabuleiro discordar pro resto do duelo inteiro. Corrigido.

## Correção nova nesta build (2026-08-24, achada no seu segundo log)

O Ijiraq foi removido do mod inteiramente. Achamos que essa carta tem um
mecanismo de disfarce (finge ser outra criatura aleatória até ser jogada,
depois revela sua forma verdadeira) que é sorteado localmente e nunca é
avisado pro outro lado - toda vez que ela aparecia, os dois PCs discordavam
sobre o que aquela carta realmente era. Removida do mod, igual já fizemos
com o Kraken e as cartas de tentáculo.

## Novidade grande nesta build (2026-08-24): idioma automático + F10

O mod agora segue o idioma configurado no próprio Inscryption (inglês ou
português) - textos, diálogos, nomes das cartas renomeadas, tudo. Trocar
idioma pelo menu do jogo já reflete sem precisar reiniciar. Também tem um
atalho novo, **F10**, que abre a página de reportar bugs/sugestões no
GitHub (aparece uma linha abaixo do crédito do mod avisando disso).

## Novidade (0.1.1 candidata): painel de feedback completo

O F10 não abre mais o navegador direto - agora abre um painel bilíngue
dentro do jogo: **ENTER** abre a página de reportar bug/sugestão no
GitHub, **D** gera um arquivo de diagnóstico sanitizado (sem IP, sem
código de convite, sem caminho pessoal) numa pasta local pra você anexar
manualmente, **ESC** fecha sem fazer nada. Nada é enviado automaticamente
em nenhum momento.

## O que ainda NÃO foi testado em partida real de 2 PCs

Todas as correções acima passaram por gates automatizados e testes de
código, mas várias delas (principalmente as de sincronização do Rato/
barreira de combate) ainda esperam confirmação num playtest real bilateral.
Se algo parecer estranho, anota o que aconteceu (com log se possível) e
manda pra gente ver.

## Alternativa sem Git

Baixe `KayceePvP-pc2-setup.zip`, extraia-o e siga as mesmas etapas de substituição e validação do hash acima.

Se o hash instalado não for exatamente o esperado, não inicie um teste LAN: a DLL errada ou uma cópia duplicada ainda está sendo carregada.
