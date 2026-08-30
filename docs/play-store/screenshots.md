# Roteiro de screenshots

Formato final: PNG, retrato, 1080 × 1920, capturado da interface real. Os dados
de demonstração devem existir somente no ambiente de captura.

1. **Evolua no seu tempo** — início com hábitos e progresso do dia.
2. **Crie hábitos que respeitam seu ritmo** — formulário de novo hábito.
3. **Escolha como perceber o tempo** — sessão com seletor dos cinco modos.
4. **Foco Livre, sem vigiar o relógio** — orbe e controles discretos.
5. **Veja seu progresso crescer** — estatísticas e histórico.
6. **Feito com cuidado, aberto e independente** — tela Sobre com privacidade,
   licença e apoio opcional.

Para carregar dados de captura sem alterar a experiência de produção:

```bash
flutter run --debug --dart-define=AEVUM_SCREENSHOT_MODE=true
```

O fixture é protegido por `kDebugMode`; builds profile e release nunca o
executam.
