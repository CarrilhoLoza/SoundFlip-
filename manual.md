# 🎧 TrocaSom

Alterne entre duas saídas de áudio do Windows usando um atalho de teclado personalizável, sem precisar manter uma janela aberta.

> Este manual acompanha o pacote completo do TrocaSom apresentado neste projeto. O aplicativo funciona em segundo plano na sessão do usuário; não é um serviço nem um componente nativo do Windows.

## Índice

- [Recursos](#recursos)
- [Requisitos](#requisitos)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Instalação](#instalação)
- [Primeira configuração](#primeira-configuração)
- [Uso no dia a dia](#uso-no-dia-a-dia)
- [Atalho personalizado](#atalho-personalizado)
- [Inicialização automática](#inicialização-automática)
- [Desinstalação](#desinstalação)
- [Solução de problemas](#solução-de-problemas)
- [Informações técnicas](#informações-técnicas)
- [Distribuição e limitações](#distribuição-e-limitações)

## Recursos

- Alternância entre duas saídas de áudio, como headset e caixas de som.
- Exibição dos nomes dos dispositivos informados pelo Windows.
- Atalho configurável; a combinação inicial é `Ctrl + Alt + S`.
- Ícone personalizado na área de notificação, perto do relógio.
- Configurações salvas entre execuções.
- Inicialização automática ao entrar na conta do Windows.
- Atalhos no menu Iniciar para abrir, configurar e desinstalar.
- Arquivos PowerShell organizados em uma pasta própria.

## Requisitos

- Windows 10 ou Windows 11, com Windows PowerShell 5.1 disponível.
- Duas saídas de áudio disponíveis para seleção.
- Permissão para executar os scripts do projeto na conta do usuário.
- Módulo `AudioDeviceCmdlets`, instalado pelo instalador caso esteja ausente.
- Internet durante a instalação da dependência, caso ela ainda não esteja disponível.

O instalador foi preparado para uso na conta atual, sem precisar selecionar **Executar como administrador**. Políticas de segurança de computadores corporativos ou escolares podem impedir a execução.

> A versão deste pacote foi gerada em um ambiente sem Windows. Embora versões anteriores tenham sido testadas pelo usuário do projeto, a execução deste pacote completo ainda precisa ser validada no computador de destino. Compatibilidade prevista não equivale a teste concluído.

## Estrutura do projeto

```text
TrocaSom/
├── Instalar.bat
├── Iniciar.bat
├── Configurar.bat
├── Desinstalar.bat
├── LEIA-ME.txt
├── manual.md              # Adicione este manual à raiz do projeto
├── scripts/
│   ├── Instalar.ps1
│   ├── Iniciar.ps1
│   ├── Configurar.ps1
│   ├── Desinstalar.ps1
│   ├── Common.ps1
│   └── TrocaSom.ps1
└── assets/
    └── TrocaSom.ico
```

| Arquivo | Finalidade |
| --- | --- |
| `Instalar.bat` | Iniciar a instalação ou reinstalação. |
| `Iniciar.bat` | Iniciar o aplicativo manualmente após a instalação. |
| `Configurar.bat` | Abrir a configuração, inclusive quando o aplicativo já estiver em execução. |
| `Desinstalar.bat` | Solicitar confirmação e remover o aplicativo instalado. |
| `scripts/` | Reunir o código PowerShell do aplicativo e das operações de gerenciamento. |
| `assets/TrocaSom.ico` | Fornecer o ícone personalizado. |

## Instalação

1. Obtenha o pacote completo de uma origem confiável.
2. Extraia **todos os arquivos** do ZIP para uma pasta.
3. Se uma versão anterior estiver rodando, use o ícone perto do relógio para escolher **Sair**.
4. Execute `Instalar.bat` com um duplo clique, sem executar como administrador.
5. Confirme a instalação na janela apresentada.
6. Se o PowerShell solicitar a instalação de dependências, leia os avisos antes de confirmar. Podem aparecer solicitações relacionadas ao provedor NuGet e à PSGallery.
7. Aguarde a configuração do aplicativo e escolha suas saídas de áudio.

Não execute os arquivos diretamente de dentro do ZIP: os scripts e o ícone precisam estar disponíveis nas pastas esperadas.

### O que o instalador faz

- Verifica a disponibilidade de `AudioDeviceCmdlets` e tenta instalá-lo se necessário.
- Copia o aplicativo para `%LOCALAPPDATA%\TrocaSom`.
- Cria atalhos na pasta **TrocaSom** do menu Iniciar.
- Cria um atalho na pasta Inicializar do usuário atual.
- Inicia o aplicativo e solicita a configuração.

Depois da instalação, a cópia extraída do ZIP não é necessária para o uso diário. Você pode usar os atalhos do menu Iniciar, inclusive para desinstalar.

## Primeira configuração

1. Em **Saída 1**, escolha o primeiro dispositivo, por exemplo, seu headset.
2. Em **Saída 2**, escolha outro dispositivo, por exemplo, suas caixas de som.
3. Na seção de atalho, selecione os modificadores e a tecla principal.
4. Clique em **Salvar**.

Escolha dois dispositivos diferentes. Se acabou de conectar uma saída, clique em **Atualizar saídas** para reabrir a tela com a lista atualizada.

Fechar a configuração sem salvar não encerra o aplicativo. Se ainda não houver duas saídas salvas, pressione o atalho ou abra as configurações novamente para concluir a seleção.

## Uso no dia a dia

Pressione o atalho configurado para alternar a saída padrão de áudio.

A regra de alternância é:

- Se a saída padrão atual for a **Saída 1**, o aplicativo ativa a **Saída 2**.
- Caso contrário, ativa a **Saída 1**.

Isso significa que, se você selecionar um terceiro dispositivo manualmente no Windows, a próxima ativação do atalho retorna à **Saída 1**.

### Ícone perto do relógio

O ícone pode aparecer diretamente na área de notificação ou dentro do menu de ícones ocultos.

- **Duplo clique:** abre as configurações.
- **Botão direito → Configurações:** permite mudar as saídas e o atalho.
- **Botão direito → Sair:** encerra o aplicativo e libera o atalho.

Não é necessário deixar uma janela aberta ou minimizada. Entretanto, o processo em segundo plano precisa continuar em execução para reconhecer a combinação de teclas.

## Atalho personalizado

O padrão inicial é:

```text
Ctrl + Alt + S
```

Você pode selecionar:

- Um ou mais modificadores: `Ctrl`, `Alt` e `Shift`.
- Uma tecla principal: letras de `A` a `Z`, números de `0` a `9` ou teclas de `F1` a `F11`.

Exemplos:

```text
Ctrl + Alt + S
Ctrl + Shift + M
Alt + F9
```

Para alterar:

1. Abra **Configurações**.
2. Marque os modificadores desejados.
3. Escolha a tecla principal na lista.
4. Clique em **Salvar**.

A mudança passa a valer imediatamente e fica salva para as próximas execuções. Se o Windows recusar a nova combinação, o aplicativo informa que ela está indisponível e mantém o registro anterior.

A tecla Windows, `F12`, teclas de mídia e combinações sem modificadores não estão disponíveis nesta interface. Prefira uma combinação que não seja usada pelos seus jogos ou aplicativos.

## Inicialização automática

O instalador configura o TrocaSom para iniciar quando você entra na sua conta do Windows.

- Não inicia antes do login.
- Não instala um serviço do Windows.
- Não instala o aplicativo nas contas dos outros usuários.
- Não exige uma janela visível para funcionar.

Para conferir o atalho de inicialização:

1. Pressione `Win + R`.
2. Digite `shell:startup`.
3. Localize `TrocaSom.lnk`.

Para impedir a inicialização automática sem remover o aplicativo, exclua apenas esse atalho. Você ainda pode iniciar o TrocaSom pelo menu Iniciar. Uma reinstalação cria o atalho novamente.

## Desinstalação

Use uma das opções:

- Execute `Desinstalar.bat` na pasta extraída do pacote; ou
- Abra **Desinstalar TrocaSom** na pasta TrocaSom do menu Iniciar.

Depois:

1. Confirme a remoção.
2. Se houver uma janela de configuração aberta e a remoção solicitar o encerramento, feche-a e escolha **Sair** no ícone do aplicativo.
3. Tente a desinstalação novamente, se necessário.
4. Aguarde a mensagem de conclusão.

### O que é removido

- Pasta instalada em `%LOCALAPPDATA%\TrocaSom`, incluindo configurações, ícone e eventuais backups presentes nela.
- Atalho de inicialização automática.
- Pasta de atalhos do aplicativo no menu Iniciar.

### O que é mantido

- A pasta na qual você extraiu o ZIP.
- O módulo `AudioDeviceCmdlets`, pois pode ser utilizado por outros scripts ou programas.

> Não guarde arquivos pessoais dentro da pasta instalada do TrocaSom: o desinstalador remove essa pasta inteira.

## Solução de problemas

### O nome do dispositivo não aparece na lista

Verifique se o dispositivo está conectado e reconhecido nas configurações de som do Windows. Depois, abra as configurações do TrocaSom e clique em **Atualizar saídas**.

### Só consigo selecionar uma saída

Conecte ou habilite uma segunda saída no Windows e atualize a lista. O programa precisa de dois dispositivos diferentes para alternar.

### O atalho está indisponível

Escolha outra combinação. Se uma versão antiga do TrocaSom ainda estiver aberta, encerre-a primeiro. Outra aplicação também pode estar usando o mesmo atalho.

Se uma combinação salva estiver ocupada ao iniciar o aplicativo, a tela de configuração é aberta para que você escolha outra.

### O atalho não faz nada

1. Confira se o ícone do TrocaSom está perto do relógio ou na área de ícones ocultos.
2. Se não estiver, inicie pelo menu Iniciar.
3. Abra as configurações e confira o atalho e os dois dispositivos salvos.
4. Se necessário, teste outra combinação.

### Apareceu uma mensagem de saída desconectada

Reconecte o dispositivo ou escolha outra saída nas configurações. O aplicativo não conecta nem liga um dispositivo Bluetooth automaticamente.

### O áudio de um jogo ou aplicativo não mudou

O TrocaSom altera a saída padrão do Windows. Ele não implementa redirecionamento individual de áudio por aplicativo. Confira se o programa em questão está configurado para seguir a saída padrão, em vez de usar um dispositivo fixo.

### Não consigo instalar a dependência

Leia a mensagem apresentada pelo instalador. A instalação do módulo pode depender de conexão à internet, disponibilidade da PSGallery e permissões da conta. Em computadores gerenciados, consulte o responsável de TI em vez de desativar as proteções do sistema.

### O antivírus ou o Windows bloqueou o pacote

Não desative suas proteções automaticamente. Confira a origem do ZIP e revise os scripts antes de autorizar a execução. O pacote contém scripts PowerShell e não inclui assinatura digital do projeto.

### A reinstalação ou desinstalação pede para fechar o aplicativo

Feche a janela de configuração e use **Sair** no ícone perto do relógio. Depois, execute a operação novamente. Versões antigas podem precisar de encerramento manual.

## Informações técnicas

| Item | Implementação |
| --- | --- |
| Aplicação | Windows PowerShell com interface Windows Forms. |
| Atalho global | Integração com a API `RegisterHotKey` do Windows. |
| Controle de áudio | Módulo externo `AudioDeviceCmdlets`. |
| Configuração | Arquivo JSON local com IDs das saídas e combinação de teclas. |
| Instalação | `%LOCALAPPDATA%\TrocaSom`. |
| Inicialização | Atalho na pasta Inicializar do usuário. |
| Execução | Processo PowerShell em segundo plano, na sessão atual. |

### Estrutura instalada

```text
%LOCALAPPDATA%\TrocaSom/
├── config.json
├── scripts/
│   ├── TrocaSom.ps1
│   ├── Common.ps1
│   ├── Iniciar.ps1
│   ├── Configurar.ps1
│   └── Desinstalar.ps1
└── assets/
    └── TrocaSom.ico
```

O arquivo `config.json` é criado ao salvar uma configuração válida. Arquivos temporários de solicitação podem aparecer durante operações de configuração ou encerramento.

Os iniciadores usam `ExecutionPolicy Bypass` somente no processo iniciado; não contêm um comando para alterar permanentemente a política de execução do Windows. Isso não elimina restrições impostas por políticas administrativas.

### Dependência externa

O projeto utiliza **AudioDeviceCmdlets**, mantido separadamente:

- Código-fonte e documentação: <https://github.com/frgnca/AudioDeviceCmdlets>
- Repositório usado pelo instalador: PSGallery.

Consulte a documentação e a licença dessa dependência antes de redistribuí-la. O pacote do TrocaSom solicita sua instalação; não inclui o módulo dentro do ZIP.

## Distribuição e limitações

Ao compartilhar com outras pessoas:

1. Envie o pacote completo, incluindo `scripts/`, `assets/` e este manual.
2. Não compartilhe somente os arquivos `.bat`.
3. Não envie sua pasta instalada nem seu `config.json`: os identificadores de áudio pertencem ao seu computador.
4. Oriente cada pessoa a extrair o ZIP e executar `Instalar.bat`.
5. Informe a dependência de internet para instalação inicial quando o módulo estiver ausente.
6. Se publicar o código, adicione uma licença escolhida pelo responsável do projeto e informe os termos das dependências.

### Limitações atuais

- Alterna apenas entre duas saídas configuradas.
- Não altera o microfone.
- A mudança também pode afetar a saída padrão de comunicação.
- Não oferece seleção de saída individual para cada aplicativo.
- Precisa estar em execução para reconhecer o atalho.
- Não há migração automática garantida das preferências de versões anteriores.
- O funcionamento deste pacote completo ainda precisa ser validado em Windows no computador de destino.

---

**Resumo rápido:** extraia o ZIP → execute `Instalar.bat` → escolha duas saídas e um atalho → clique em **Salvar** → use o atalho para alternar o áudio.
