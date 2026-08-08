# KayceePvP — atualização do PC2

Este repositório contém a build de distribuição do KayceePvP para que os dois computadores usem **exatamente a mesma DLL**.

## Instruções para o agente no PC2

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
   86A058D82DF57E2E98ECA07700345D8C34A74AE6490A57AB86EDBA55BA0296E8
   ```

   Tamanho esperado: `2383360` bytes.

7. Só depois da confirmação do hash, abra o jogo pelo profile correto do Thunderstore.
8. No lobby, confirme que não aparece incompatibilidade `local=3 peer=0`. Ambos os lados precisam anunciar o mesmo protocolo.

## O que esta build corrige

- Em saves novos do PC2, força a abertura da tela de seleção de baralho no modo multiplayer.
- Mantém os baralhos individuais liberados sem gravar progressão falsa no save.
- Inclui o terceiro mapa **Forja Simétrica**, além das correções e recursos acumulados da build atual.

## Alternativa sem Git

Baixe `KayceePvP-pc2-setup.zip`, extraia-o e siga as mesmas etapas de substituição e validação do hash acima.

Se o hash instalado não for exatamente o esperado, não inicie um teste LAN: a DLL errada ou uma cópia duplicada ainda está sendo carregada.
