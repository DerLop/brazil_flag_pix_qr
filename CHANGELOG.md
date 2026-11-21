## 1.1.0

### 🇪🇸 Español
* **Logo personalizable y modo sin logo (`showLogo` y `logoImage`):** Ahora puedes mostrar el logo vectorial de Pix por defecto (`showLogo: true`, `logoImage: null`), colocar tu propia imagen personalizada (`logoImage: AssetImage(...)`) o rellenar completamente el centro con puntos del QR (`showLogo: false`) sin dejar espacios en blanco.
* **Control de tamaño del logo (`logoSize` y `logoSizeRatio`):** Se agregaron propiedades para ajustar el tamaño del logo central en píxeles fijos (`logoSize`) o por proporción (`logoSizeRatio: 0.10` por defecto), escalando automáticamente el margen de seguridad para mantener el escaneo confiable.
* **Contenedor opcional (`showContainer`):** Se añadió la opción `showContainer` (por defecto `true`) para permitir quitar el recuadro blanco redondeado con borde y envolver el QR puro en cualquier diseño propio.
* **Alineación matemática exacta:** El logo vectorial de Pix ahora se dibuja directamente sobre el mismo lienzo (`Canvas`) que los módulos del QR, asegurando un centrado perfecto en cualquier tamaño o resolución de pantalla.

### 🇺🇸 English
* **Custom logo support & logo-free mode (`showLogo` and `logoImage`):** You can now display the default built-in vector Pix logo (`showLogo: true`, `logoImage: null`), render your own custom image (`logoImage: AssetImage(...)`), or fill the center area completely with QR dots (`showLogo: false`) without leaving a blank gap.
* **Center logo sizing (`logoSize` and `logoSizeRatio`):** Added support for customizing the center logo size using fixed logical pixels (`logoSize`) or a relative width ratio (`logoSizeRatio: 0.10` by default), automatically scaling the center clearance zone to preserve scannability.
* **Optional outer container (`showContainer`):** Added `showContainer` (defaults to `true`) so you can disable the default white rounded container and border to wrap the raw QR code in your own custom layout.
* **Exact mathematical center alignment:** The default vector Pix logo is now drawn directly on the same `Canvas` as the QR modules, ensuring pixel-perfect centering across all screen sizes and orientations.


## 1.0.1

### 🇪🇸 Español
* **Actualización de dependencias:** Se actualizó el paquete `qr` a la versión `^4.0.1` para mantener compatibilidad con las últimas versiones del ecosistema Dart/Flutter.
* **Eliminación de `material.dart`:** Se migró `BrazilFlagQr` a `package:flutter/widgets.dart` reemplazando el ícono de Material por un dibujante vectorial propio (`CustomPaint`) del símbolo oficial de Pix, eliminando advertencias de obsolescencia en Flutter 3.50+.
* **Licencia OSI estándar:** Se ajustó el archivo `LICENSE` al formato oficial MIT en inglés para su detección automática en pub.dev.

### 🇺🇸 English
* **Dependency upgrade:** Upgraded the `qr` package constraint to `^4.0.1` for full compatibility with the latest Dart/Flutter ecosystem releases.
* **Removed `material.dart` dependency:** Migrated `BrazilFlagQr` to `package:flutter/widgets.dart` and replaced the Material icon with a custom vector painter (`CustomPaint`) for the official Pix logo, resolving deprecation warnings in Flutter 3.50+.
* **Standard OSI License:** Updated `LICENSE` to the standard English MIT template for proper automated detection on pub.dev.


## 1.0.0

### 🇪🇸 Español
* **Generación de Payload Pix (`PixPayloadBuilder`):** Soporte completo para generar cadenas *Pix Copia e Cola* (estándar EMV / BR Code) con cálculo automático de **CRC16-CCITT (0xFFFF)**.
* **Soporte para mensajes y referencias:** Inclusión de descripciones personalizadas (subcampo `02` dentro del bloque `26`) respetando el límite de 99 caracteres del Banco Central de Brasil, además de `txId` y monto opcional.
* **Limpieza automática de caracteres:** Conversión automática de tildes, `ñ`, `ç` y símbolos no admitidos.
* **Widget QR Bandera de Brasil (`BrazilFlagQr`):** Renderizado con puntos circulares, marcadores de esquina redondos en verde bandera, rombo ámbar de alto contraste, círculo azul central e ícono de Pix.

### 🇺🇸 English
* **Pix Payload Generation (`PixPayloadBuilder`):** Full support for generating *Pix Copia e Cola* strings (EMV / BR Code standard) with automatic **CRC16-CCITT (0xFFFF)** checksum calculation.
* **Message & Reference Support:** Optional descriptions (sub-tag `02` inside field `26`) automatically enforcing the 99-character Banco Central do Brasil limit, plus `txId` and optional amount.
* **Automatic Text Sanitization:** Strips accents, diacritics, and unsupported symbols for universal banking compatibility.
* **Brazilian Flag QR Widget (`BrazilFlagQr`):** Renders circular modules, rounded green corner finder patterns, high-contrast amber diamond, blue center circle, and center Pix icon.
