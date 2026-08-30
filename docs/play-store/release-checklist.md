# Checklist de publicação Android

## Concluído no repositório

- [x] Identidade Aevum e `applicationId` `app.aevum.focus`.
- [x] Versão de preparação `0.9.0+1`.
- [x] Compile/target SDK 36.
- [x] Sem anúncios, analytics, conta ou coleta.
- [x] Sem permissão de notificações.
- [x] Política local, exclusão de dados e Data Safety documentados.
- [x] Ícone, feature graphic e roteiro de seis screenshots.
- [x] CI, análise, testes e build release de validação.
- [x] Release sem assinatura debug.

## Bloqueadores externos antes do primeiro upload

- [ ] Confirmar disponibilidade jurídica de Aevum no INPI.
- [ ] Criar o repositório público e ativar GitHub Pages em `/docs`.
- [ ] Substituir o contato provisório na política por um e-mail público.
- [ ] Configurar `AEVUM_PRIVACY_URL`, `AEVUM_SOURCE_URL` e, se desejado,
  `AEVUM_CONTACT_URL` e `AEVUM_SUPPORT_URL` no build final.
- [ ] Criar e verificar a conta da Play Console e o aparelho Android.
- [ ] Criar a upload key, ativar Play App Signing e guardar backups.
- [ ] Criar o app na Play Console com categoria Produtividade e público 18+.
- [ ] Enviar ícone, feature graphic, screenshots e textos pt-BR.
- [ ] Preencher Data Safety, classificação de conteúdo e declaração de anúncios.
- [ ] Se exigido para a conta pessoal, manter 12 testadores no teste fechado por
  14 dias contínuos e depois solicitar acesso à produção.
- [ ] Reservar `1.0.0` e incrementar o versionCode para a versão pública.
