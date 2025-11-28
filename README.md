# app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


PAsos para cambiar nombre de paquete:
🔹 Android

Abre android/app/src/main/AndroidManifest.xml

Busca la etiqueta <application android:label="..." ...>
Ejemplo:

<application
android:name="${applicationName}"
android:label="RenEdu"
android:icon="@mipmap/ic_launcher">


Cambia el paquete del MainActivity.kt
 

Guarda los cambios.

🔹 iOS

Abre ios/Runner/Info.plist

Busca la clave CFBundleName y cambia su valor:

<key>CFBundleName</key>
<string>RenEdu</string>


Si deseas cambiar también el nombre mostrado en la pantalla de inicio, revisa CFBundleDisplayName (a veces está separado):

<key>CFBundleDisplayName</key>
<string>RenEdu</string>


en console: grep -rl "package:renedu" lib/ | xargs sed -i '' 's/package:renedu/package:proxyapp/g'


🔁 Finalmente

Ejecuta:

flutter clean
flutter pub get
flutter run 



Comando para generar íconos:
flutter pub run flutter_launcher_icons


Pantalla de inicio (splash_logo.png)
🔹 Ubicación

Crea:

assets/splash/


Y coloca:

assets/splash/splash_logo.png

🔹 Configuración en pubspec.yaml

Agrega:

flutter_native_splash:
color: "#FFFFFF"  # Puedes cambiarlo si quieres otro color de fondo
image: assets/splash/splash_logo.png
android: true
ios: true
web: true
android_gravity: center
ios_content_mode: center

🔹 Comando para generar splash:
flutter pub run flutter_native_splash:create


