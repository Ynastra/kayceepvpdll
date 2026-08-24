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
   F73F1EFA47AF1982CBC7C2C24E40A7BF739E86B4968FBCDC981A6A2055543B16
   ```

   Tamanho esperado: `6511616` bytes.

   **Não conte nem copie a quebra de linha exibida pelo terminal.** Um SHA-256 possui
   exatamente 64 caracteres hexadecimais. Para evitar qualquer ambiguidade, execute
   a comparação automática abaixo, trocando somente o caminho:

   ```powershell
   $esperado = "F73F1EFA47AF1982CBC7C2C24E40A7BF739E86B4968FBCDC981A6A2055543B16"
   $obtido = (Get-FileHash -Algorithm SHA256 "CAMINHO_DO_PROFILE\BepInEx\plugins\KayceePvP\KayceePvP.dll").Hash
   $obtido.Length
   $obtido -eq $esperado
   ```

   O resultado correto é `64` e depois `True`. O arquivo `SHA256SUMS.txt`
   contém o mesmo checksum em formato legível por ferramentas automáticas.

7. **IMPORTANTE - confira a versão da dependência `API` (autor `API_dev`) nesse profile.** Esta build foi compilada contra a versão `2.24.0`. Se o profile do PC2 ainda tiver a `API` numa versão diferente (ex: `2.23.7`), o mod pode falhar ao carregar ou dar erro ao iniciar - **esse é o suspeito nº 1 se o jogo der erro ao abrir**. Atualize a dependência `API` para `2.24.0` pelo Thunderstore Mod Manager (aba de mods do profile) antes de continuar. `Atualizar-PC2.ps1` (método automático) já checa isso e avisa se a versão estiver errada.
8. Só depois da confirmação do hash E da versão da `API`, abra o jogo pelo profile correto do Thunderstore.
9. No lobby, confirme que não aparece incompatibilidade `local=3 peer=0`. Ambos os lados precisam anunciar o mesmo protocolo.

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

## O que ainda NÃO foi testado em partida real de 2 PCs

Todas as correções acima passaram por gates automatizados e testes de
código, mas várias delas (principalmente as de sincronização do Rato/
barreira de combate) ainda esperam confirmação num playtest real bilateral.
Se algo parecer estranho, anota o que aconteceu (com log se possível) e
manda pra gente ver.

## Alternativa sem Git

Baixe `KayceePvP-pc2-setup.zip`, extraia-o e siga as mesmas etapas de substituição e validação do hash acima.

Se o hash instalado não for exatamente o esperado, não inicie um teste LAN: a DLL errada ou uma cópia duplicada ainda está sendo carregada.
