# Pointer Lock Unlock — MouseBridge Labs

Protótipo iOS em SwiftUI para testar eventos de mouse relativos via `GameController` (`GCMouse`), demonstrar um modo de ponteiro virtual dentro do app e importar arquivos escolhidos pelo usuário.

## Build pelo GitHub Actions

1. Crie um repositório GitHub e envie todo o conteúdo deste ZIP.
2. Abra **Actions**.
3. Execute **Build Pointer Lock Unlock IPA**.
4. Baixe o artefato `PointerLockUnlock-unsigned-IPA`.

O IPA produzido é **não assinado**. Será necessário assinar com um método de instalação compatível antes de instalar no iPhone.

## Limitações reais do iOS

- Um app de terceiros não pode ativar um Pointer Lock global no iPhone por conta própria.
- O modo virtual deste protótipo só representa o comportamento dentro do próprio app.
- O app não consegue injetar eventos de mouse em Amethyst nem controlar a câmera de outro app.
- Para Minecraft Java no Amethyst, será necessário integrar o motor de captura e conversão de movimento ao código-fonte do próprio Amethyst.
- O app não pode varrer ou extrair livremente os arquivos privados do iPhone. A aba Arquivos usa o seletor oficial do iOS; o usuário escolhe quais arquivos compartilhar com o app.

## Estrutura

- `Sources/PointerLockUnlock/MouseEngine.swift`: captura de eventos via GameController.
- `Sources/PointerLockUnlock/ContentView.swift`: interface, ajustes, monitor e importação.
- `.github/workflows/build-ipa.yml`: build e empacotamento IPA sem assinatura.
- `project.yml`: configuração XcodeGen.
