# Como a gente se comunica sobre bugs — instruções pro Joao (PC2)

Esse repositório agora é o canal oficial entre os dois PCs pra atualizar o
mod e reportar problemas. Guarda essas instruções — elas não mudam a cada
atualização, só o `README.md`/`KayceePvP.dll` mudam.

## Recebendo uma atualização nova

Sempre que o Gaspa avisar que tem build nova:

```powershell
git pull origin master
```

Depois siga o `README.md` (hash novo, versão da dependência `API`, etc.) ou
rode `.\Atualizar-PC2.ps1` direto.

## Quando algo der errado numa partida (cartas não sincronizaram, jogo travou, erro estranho)

**Não feche o jogo antes de salvar o log.** O arquivo de log fica em:

```text
BepInEx\LogOutput.log
```

dentro da pasta do profile que você está usando (o mesmo caminho de onde
você tirou o `KayceePvP.dll` pra atualizar).

Passos:

1. Copie esse `LogOutput.log` pra dentro deste repositório, na pasta
   `logs/`, com um nome que tenha a data/hora (ex:
   `logs/LogOutput-pc2-2026-08-24_1215.log`) — não sobrescreva logs
   anteriores, cada report é um arquivo novo.
2. Rode:

   ```powershell
   git checkout report-de-erros
   git pull origin report-de-erros
   git add logs/
   git commit -m "Descrição curta do que aconteceu (ex: cartas nao sincronizaram, turno 4-5)"
   git push origin report-de-erros
   ```

   Se a branch `report-de-erros` ainda não existir localmente na sua
   máquina na primeira vez, use `git checkout -b report-de-erros` em vez de
   `git checkout report-de-erros`.
3. Me avisa (mensagem normal, WhatsApp/Discord/etc.) que mandou log novo —
   isso não é automático, alguém precisa avisar que tem novidade.
4. Quanto mais contexto você mandar junto (mesmo que só numa frase — "o
   Rato deu bug quando eu transferi sigilo pra ele", "o jogo travou depois
   que o outro lado jogou uma carta", "as duas telas mostravam sigilos
   diferentes na mesma carta"), mais rápido a gente acha a causa. Não
   precisa ser técnico, só descreve o que você viu de errado.

## O que NÃO fazer

- Não edite `KayceePvP.dll`, `Atualizar-PC2.ps1`, `README.md` ou
  `SHA256SUMS.txt` direto na branch `report-de-erros` — essa branch é só
  pra logs. Atualizações de verdade sempre vêm da `master`.
- Não precisa limpar/filtrar o log antes de mandar — manda inteiro, é mais
  fácil achar o problema com o contexto completo.

## Por que isso importa

Boa parte dos bugs de sincronização deste mod só aparecem numa partida real
entre os dois PCs — não dá pra reproduzir testando sozinho. Seu log é
literalmente a única forma de confirmar o que aconteceu de cada lado da
partida ao mesmo tempo. Valeu por testar!
