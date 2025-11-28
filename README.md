Aquí tienes el **README.md actualizado**, con las nuevas secciones solicitadas:

* Explicación clara de que **el proxy solo funciona para apps y sistemas que respetan la configuración de proxy HTTP/HTTPS del cliente**.
* Guía de **configuración de proxy** para: Android, Windows, macOS, Linux y iOS.

Todo está redactado de forma profesional, clara y técnica.

---

# 📡 ProxyApp – Proof of Concept (PoC)

ProxyApp es una aplicación móvil desarrollada como **prueba de concepto (PoC)**, cuyo objetivo fue validar si un **dispositivo móvil con datos móviles** puede actuar como **servidor proxy** para otros dispositivos conectados por Wi-Fi local —especialmente en escenarios donde esos otros dispositivos no poseen conexión a Internet.

Este proyecto no nació como un producto final, sino como un experimento técnico para validar:

* 🚀 Creación de un proxy HTTP/HTTPS funcional desde un smartphone
* 🔌 Conexión de múltiples dispositivos al proxy vía Wi-Fi local
* 📶 Ejecución del proxy en segundo plano
* 📊 Monitoreo en tiempo real de tráfico, velocidad y consumo
* 👥 Control de dispositivos conectados y bloqueo por IP
* 🧪 Validación de capacidades reales de datos del plan móvil

Aun así, la aplicación hoy es plenamente funcional y queda **disponible para quien quiera usarla**, sin ningún tipo de garantía.

---

## 🎯 Objetivo especial del PoC: Acceder al 100% de los datos móviles (incluso con límites de hotspot)

Muchos operadores móviles diferencian entre:

| Tipo de datos                   | Descripción                                             |
| ------------------------------- | ------------------------------------------------------- |
| **Datos del plan total**        | Ejemplo: 100 GB disponibles en la SIM                   |
| **Datos compartidos (hotspot)** | Ejemplo: 20 GB permitidos para compartir vía hotspot/AP |

En condiciones normales, un dispositivo solo puede compartir la cuota asignada al hotspot.

### ✔️ Resultado técnico

El proxy **no utiliza** el sistema de hotspot del teléfono, sino que enruta el tráfico directamente por la **conexión móvil primaria** del smartphone.
Esto permitió usar **el 100% de los datos reales del plan**, sin quedar limitado por la cuota de hotspot.

### 🟢 Conclusión

Sí, es posible que otros dispositivos conectados al Wi-Fi del celular **usen todos los datos del plan móvil**, sin estar sujetos a las restricciones del modo hotspot tradicional.

---

## ⚠️ Importante: Aplicable únicamente a aplicaciones y sistemas que respeten la configuración de Proxy HTTP/HTTPS

Este proxy funciona **solo cuando el dispositivo cliente (PC, tablet, otro smartphone, etc.) configura manualmente un proxy HTTP y/o HTTPS** en su sistema operativo.

Esto significa:

* Funciona para **toda aplicación que respete el proxy del sistema** (ej.: navegadores, apps corporativas, gestores de paquetes, etc.).
* No funcionará para apps que:

    * Ignoran la configuración de proxy del sistema
    * Usan conexiones directas basadas en sockets sin soporte proxy
    * Envían tráfico por canales alternativos (VPNs, QUIC estricto, DoH forzado, etc.)

Ejemplos de apps que generalmente sí funcionan:

* Chrome / Firefox / Edge
* Safari / macOS apps que están basadas en networking del sistema
* Apps Android que respeten la configuración de proxy Wi-Fi
* Windows Update (según versión)
* Curl, Wget, Git, APT, YUM, Brew, etc., configurando proxy

Ejemplos de apps que pueden ignorarlo:

* WhatsApp
* Telegram
* Algunos juegos móviles
* Apps con túneles embebidos o APIs internas no estándar

---

## 📡 Información del Proxy dentro de la aplicación

La aplicación ProxyApp muestra **toda la información necesaria** para que cualquier dispositivo cliente pueda conectarse correctamente al servicio proxy.

Dentro de la app encontrarás:

* **IP del proxy (servidor)**
  Corresponde a la dirección local del teléfono anfitrión.
  Ejemplos comunes:

  ```
  10.139.249.44
  ```

* **Puerto configurado del proxy**
  Es el puerto en el cual el servidor está escuchando peticiones HTTP/HTTPS.
  Ejemplos:

  ```
  8080
  ```

Esta información aparece claramente dentro de la app, y **debe usarse exactamente igual** en los dispositivos clientes al momento de configurar el **proxy HTTP y HTTPS**.

* **Ilustración del dashbaord inicial del proxy HTTP/HTTPS en un teléfono Android**

![Dashbaord del Proxy](docs/proxy_dashboard.jpeg)

* **Ilustración de la configuración inicial del proxy HTTP/HTTPS en un teléfono Android**

![Configuración del Proxy](docs/proxy_settings.jpeg)

### ✔️ ¿Para qué sirve esta información?

Los dispositivos cliente (Android, Windows, macOS, Linux o iOS) deberán introducir **esa IP y ese puerto** en la configuración de *Proxy Manual* para que **todo el tráfico HTTP/HTTPS sea redirigido al smartphone que actúa como servidor**.

### ✔️ Requisito obligatorio

Si el cliente coloca una IP o un puerto diferente:

* No habrá conexión
* No habrá navegación
* El proxy no recibirá tráfico
* El cliente no usará los datos del móvil servidor

Por eso, **siempre toma la IP y el puerto directamente desde la aplicación.**

---

## 📱 Android (cliente)

1. Conectarse a la red Wi-Fi creada por el móvil servidor
2. Mantener presionado el nombre de la red → **Modificar red**
3. Mostrar opciones avanzadas
4. En **Proxy**, seleccionar: **Manual**
5. Configurar:

```
Tomando la config del proxyapp (Ilustración de la configuración inicial del proxy HTTP/HTTPS en un teléfono Android)

Proxy host name: 10.139.249.44
Proxy port: 8080
```

6. Guardar

---

## 🖥 Windows 10 / 11

1. Inicio → Configuración
2. Red e Internet
3. Proxy
4. En **Configuración manual de proxy**, activar **Usar un servidor proxy**
5. Ingresar:

```
Tomando la config del proxyapp (Ilustración de la configuración inicial del proxy HTTP/HTTPS en un teléfono Android)

Proxy host name: 10.139.249.44
Proxy port: 8080
```

6. Guardar

---

## 🍏 macOS (cliente)

1. Preferencias del Sistema
2. Red
3. Seleccionar la interfaz Wi-Fi
4. Clic en **Avanzado…**
5. Ir a pestaña **Proxies**
6. Marcar:

* **Proxy web (HTTP)**
* **Proxy seguro (HTTPS)**

7. Configurar:

```
Tomando la config del proxyapp (Ilustración de la configuración inicial del proxy HTTP/HTTPS en un teléfono Android)

Proxy host name: 10.139.249.44
Proxy port: 8080
```

8. Aceptar → Aplicar

9. Ilustración:
   ![Configuración del Proxy](docs/proxy_mac_os.png)

---

## 🐧 Linux (Ubuntu / Debian / derivados)

### GNOME (GUI)

1. Configuración
2. Red
3. Proxy
4. Seleccionar **Manual**
5. Ingresar:

```
Tomando la config del proxyapp (Ilustración de la configuración inicial del proxy HTTP/HTTPS en un teléfono Android)

Proxy host name: 10.139.249.44
Proxy port: 8080
```

---

## 📱 iOS (iPhone / iPad)

1. Ajustes
2. Wi-Fi
3. Tocar la red conectada
4. Al final, en **Proxy HTTP**, seleccionar **Manual**
5. Configurar:

```
Tomando la config del proxyapp (Ilustración de la configuración inicial del proxy HTTP/HTTPS en un teléfono Android)

Proxy host name: 10.139.249.44
Proxy port: 8080
```

6. Guardar

---

# ⚖️ Licencia – MIT

Este proyecto utiliza la **licencia MIT**, que:

* Permite uso libre, personal o comercial
* Permite modificar, copiar, redistribuir o integrar el código
* **Exime al autor de toda responsabilidad**

Definitivamente la más adecuada para este tipo de PoC.

---

# 📝 Descargo de responsabilidad

Este proyecto:

* No garantiza funcionamiento continuo
* No asegura privacidad o protección de datos
* No debe usarse en producción
* Fue creado exclusivamente para experimentación y aprendizaje

El autor no es responsable por daños, fallos, pérdidas o mal uso.

---

# 📦 Instalación rápida (desarrolladores)

```bash
git clone https://github.com/josmejia2401/proxyapp.git
flutter pub get
flutter run
```

---

# 📬 Contacto

Se aceptan PRs, mejoras, forks e ideas para nuevas PoCs.