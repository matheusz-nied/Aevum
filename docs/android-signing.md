# Assinatura Android

O projeto nunca usa a chave debug em uma compilação release.

Enquanto `android/key.properties` não existir, o Gradle produz somente um AAB
release não assinado para validação técnica. Esse arquivo não pode ser enviado à
Google Play.

Antes do primeiro envio:

1. Ative o Play App Signing ao criar o app na Play Console.
2. Crie uma upload key dedicada seguindo a documentação oficial do Android.
3. Guarde o keystore e as senhas em um gerenciador seguro com backup separado.
4. Copie `android/key.properties.example` para `android/key.properties` e
   substitua os quatro valores.
5. Execute `flutter build appbundle --release` e confira a assinatura antes do
   upload.

O `.gitignore` exclui `android/key.properties`, `*.jks` e `*.keystore`.
