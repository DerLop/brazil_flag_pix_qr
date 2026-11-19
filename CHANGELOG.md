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
