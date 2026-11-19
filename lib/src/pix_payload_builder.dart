/// English: Utility class to generate valid Pix BR Code (EMV) payloads
/// with optional description/message, transaction ID, and amount.
///
/// Español: Clase utilitaria para generar payloads válidos de Pix BR Code (EMV)
/// con soporte opcional para descripción/mensaje, ID de transacción y monto.
class PixPayloadBuilder {
  /// English: Global Unique Identifier (GUI) for Brazilian Pix.
  /// Español: Identificador Único Global (GUI) para el sistema Pix de Brasil.
  static const String _pixGui = 'br.gov.bcb.pix';

  /// English: Generates a static Pix BR Code payload string ("Copia e Cola").
  /// Automatically sanitizes accents/special characters, enforces the 99-char limit
  /// on Merchant Account Information (ID 26), and appends the CRC16 checksum.
  ///
  /// Español: Genera la cadena de texto Pix BR Code estática ("Copia e Cola").
  /// Limpia automáticamente tildes y caracteres especiales, respeta el límite de
  /// 99 caracteres en la información de cuenta (ID 26) y añade el CRC16.
  static String generate({
    required String pixKey,
    required String merchantName,
    required String merchantCity,
    String? description,
    String txId = '***',
    double? amount,
  }) {
    // 00 - Payload Format Indicator / Indicador de formato del payload
    final p00 = _formatTlv('00', '01');

    // 26 - Merchant Account Information (GUI + Pix Key + Optional Description)
    // 26 - Información de la cuenta del comercio (GUI + Llave Pix + Descripción opcional)
    final guiField = _formatTlv('00', _pixGui);
    final keyField = _formatTlv('01', pixKey.trim());

    String descriptionField = '';
    if (description != null && description.trim().isNotEmpty) {
      // English: Calculate remaining space within the 99-character limit of field 26.
      // Español: Calcula el espacio restante dentro del límite de 99 caracteres del campo 26.
      final availableSpace = 99 - (guiField.length + keyField.length + 4);
      if (availableSpace > 0) {
        final sanitizedDesc = _sanitizeText(description, availableSpace);
        if (sanitizedDesc.isNotEmpty) {
          descriptionField = _formatTlv('02', sanitizedDesc);
        }
      }
    }
    final p26 = _formatTlv('26', '$guiField$keyField$descriptionField');

    // 52 - Merchant Category Code / Código de categoría del comercio
    final p52 = _formatTlv('52', '0000');

    // 53 - Transaction Currency (986 = BRL) / Moneda de la transacción (986 = BRL)
    final p53 = _formatTlv('53', '986');

    // 54 - Transaction Amount (Optional) / Monto de la transacción (Opcional)
    final p54 = (amount != null && amount > 0)
        ? _formatTlv('54', amount.toStringAsFixed(2))
        : '';

    // 58 - Country Code (BR) / Código de país (BR)
    final p58 = _formatTlv('58', 'BR');

    // 59 - Merchant Name (max 25 chars) / Nombre del titular (máx 25 caracteres)
    final cleanName = _sanitizeText(merchantName, 25);
    final p59 = _formatTlv('59', cleanName.isEmpty ? '*' : cleanName);

    // 60 - Merchant City (max 15 chars) / Ciudad del titular (máx 15 caracteres)
    final cleanCity = _sanitizeText(merchantCity, 15);
    final p60 = _formatTlv('60', cleanCity.isEmpty ? '*' : cleanCity);

    // 62 - Additional Data Field Template (05 - txId, max 25 chars)
    // 62 - Plantilla de datos adicionales (05 - txId, máx 25 caracteres)
    final cleanTxId = txId.trim().isEmpty
        ? '***'
        : _sanitizeText(txId, 25, allowSpaces: false);
    final p62 = _formatTlv(
      '62',
      _formatTlv('05', cleanTxId.isEmpty ? '***' : cleanTxId),
    );

    // 63 - CRC16 Checksum / Suma de verificación CRC16
    final rawPayload = '$p00$p26$p52$p53$p54$p58$p59$p60${p62}6304';
    final crc = _calculateCrc16(rawPayload);

    return '$rawPayload$crc';
  }

  /// English: Formats a field in EMV TLV (Tag-Length-Value) standard.
  /// Español: Formatea un campo según el estándar EMV TLV (Etiqueta-Longitud-Valor).
  static String _formatTlv(String id, String value) {
    final length = value.length.toString().padLeft(2, '0');
    return '$id$length$value';
  }

  /// English: Removes accents, diacritics, and unsupported symbols for banking compatibility.
  /// Español: Elimina tildes, diacríticos y símbolos no soportados para compatibilidad bancaria.
  static String _sanitizeText(
    String input,
    int maxLength, {
    bool allowSpaces = true,
  }) {
    const accented = 'áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ';
    const unaccented = 'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN';

    String sanitized = input.trim();
    for (int i = 0; i < accented.length; i++) {
      sanitized = sanitized.replaceAll(accented[i], unaccented[i]);
    }

    final pattern = allowSpaces
        ? RegExp(r'[^a-zA-Z0-9 *\-.,]')
        : RegExp(r'[^a-zA-Z0-9*]');
    sanitized = sanitized.replaceAll(pattern, '');

    return sanitized.length > maxLength
        ? sanitized.substring(0, maxLength).trim()
        : sanitized;
  }

  /// English: Calculates the CRC16-CCITT (0xFFFF) checksum required by Banco Central do Brasil.
  /// Español: Calcula el checksum CRC16-CCITT (0xFFFF) exigido por el Banco Central de Brasil.
  static String _calculateCrc16(String payload) {
    int crc = 0xFFFF;
    for (int i = 0; i < payload.length; i++) {
      crc ^= (payload.codeUnitAt(i) << 8);
      for (int j = 0; j < 8; j++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}
