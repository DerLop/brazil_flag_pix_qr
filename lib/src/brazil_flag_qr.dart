import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

import 'pix_payload_builder.dart';

/// English: A customizable QR Code widget styled with circular dots,
/// rounded green corner markers, and the Brazilian flag color geometry.
///
/// Español: Widget de código QR personalizable diseñado con puntos circulares,
/// marcadores de esquina redondos en verde y la geometría de colores de la bandera de Brasil.
class BrazilFlagQr extends StatelessWidget {
  /// English: The raw string data encoded inside the QR code.
  /// Español: La cadena de texto sin procesar codificada dentro del código QR.
  final String payload;

  /// English: Total width and height of the QR container.
  /// Español: Ancho y alto total del contenedor del código QR.
  final double size;

  /// English: Optional custom widget displayed at the center of the QR code.
  /// Español: Widget personalizado opcional que se muestra en el centro del código QR.
  final Widget? centerWidget;

  /// English: Whether to show the default Material Pix icon when [centerWidget] is null.
  /// Español: Indica si se debe mostrar el ícono de Pix por defecto cuando [centerWidget] es nulo.
  final bool showDefaultPixIcon;

  /// English: Renders a Brazilian flag QR code from an existing [payload] string.
  /// Español: Renderiza un código QR con la bandera de Brasil a partir de un [payload] existente.
  const BrazilFlagQr.fromPayload({
    super.key,
    required this.payload,
    this.size = 220,
    this.centerWidget,
    this.showDefaultPixIcon = true,
  });

  /// English: All-in-one factory that generates the Pix payload with optional message
  /// and renders the Brazilian flag QR code directly.
  ///
  /// Español: Constructor todo-en-uno que genera el payload Pix con mensaje opcional
  /// y renderiza directamente el código QR con la bandera de Brasil.
  factory BrazilFlagQr.pix({
    Key? key,
    required String pixKey,
    required String merchantName,
    required String merchantCity,
    String? description,
    String txId = '***',
    double? amount,
    double size = 220,
    Widget? centerWidget,
    bool showDefaultPixIcon = true,
  }) {
    final generatedPayload = PixPayloadBuilder.generate(
      pixKey: pixKey,
      merchantName: merchantName,
      merchantCity: merchantCity,
      description: description,
      txId: txId,
      amount: amount,
    );

    return BrazilFlagQr.fromPayload(
      key: key,
      payload: generatedPayload,
      size: size,
      centerWidget: centerWidget,
      showDefaultPixIcon: showDefaultPixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    // English: Use High (H) error correction so the center icon never blocks scanning.
    // Español: Usa corrección de errores Alta (H) para que el ícono central nunca impida el escaneo.
    final qrCode = QrCode.fromData(
      data: payload,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );
    final qrImage = QrImage(qrCode);

    final Widget? resolvedCenter =
        centerWidget ??
        (showDefaultPixIcon
            ? const Icon(Icons.pix, color: Color(0xFF32BCAD), size: 28)
            : null);

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size - 24, size - 24),
            painter: _BrazilFlagQrPainter(qrImage: qrImage),
          ),
          if (resolvedCenter != null)
            SizedBox(
              width: (size - 24) * 0.15,
              height: (size - 24) * 0.15,
              child: Center(child: resolvedCenter),
            ),
        ],
      ),
    );
  }
}

/// English: CustomPainter that draws circular QR modules colored according
/// to the Brazilian flag layout (green background, amber diamond, blue circle).
///
/// Español: CustomPainter que dibuja los módulos circulares del QR coloreados según
/// el diseño de la bandera de Brasil (fondo verde, rombo ámbar, círculo azul).
class _BrazilFlagQrPainter extends CustomPainter {
  final QrImage qrImage;

  _BrazilFlagQrPainter({required this.qrImage});

  @override
  void paint(Canvas canvas, Size size) {
    final int moduleCount = qrImage.moduleCount;
    final double cellSize = size.width / moduleCount;
    final double dotRadius = cellSize * 0.43;

    // English: High-contrast Brazilian flag color palette for reliable camera scanning.
    // Español: Paleta de colores de la bandera de Brasil con alto contraste para lectura confiable.
    final greenPaint = Paint()..color = const Color(0xFF009C3B);
    final yellowPaint = Paint()..color = const Color(0xFFD99B00);
    final bluePaint = Paint()..color = const Color(0xFF002776);
    final whitePaint = Paint()..color = Colors.white;

    final double center = moduleCount / 2.0;

    for (int row = 0; row < moduleCount; row++) {
      for (int col = 0; col < moduleCount; col++) {
        // English: Skip the 3 corner finder patterns to draw them as circles later.
        // Español: Omite los 3 patrones de esquina para dibujarlos como círculos después.
        if (_isFinderPattern(row, col, moduleCount)) continue;

        // English: Keep a tight circular clearance around the center icon.
        // Español: Mantiene un margen circular ajustado alrededor del ícono central.
        final double centerDist = sqrt(
          pow(col + 0.5 - center, 2) + pow(row + 0.5 - center, 2),
        );
        if (centerDist < moduleCount * 0.068) continue;

        if (qrImage.isDark(row, col)) {
          final selectedPaint = _getFlagPaint(
            row + 0.5,
            col + 0.5,
            center,
            moduleCount,
            greenPaint,
            yellowPaint,
            bluePaint,
          );
          canvas.drawCircle(
            Offset((col + 0.5) * cellSize, (row + 0.5) * cellSize),
            dotRadius,
            selectedPaint,
          );
        }
      }
    }

    // English: Draw the 3 circular corner finder patterns in flag green.
    // Español: Dibuja los 3 patrones circulares de esquina en verde bandera.
    _drawCircularFinder(canvas, 0, 0, cellSize, greenPaint, whitePaint);
    _drawCircularFinder(
      canvas,
      0,
      moduleCount - 7,
      cellSize,
      greenPaint,
      whitePaint,
    );
    _drawCircularFinder(
      canvas,
      moduleCount - 7,
      0,
      cellSize,
      greenPaint,
      whitePaint,
    );
  }

  /// English: Determines whether a module belongs to the blue circle, yellow diamond, or green field.
  /// Español: Determina si un módulo pertenece al círculo azul, al rombo amarillo o al fondo verde.
  Paint _getFlagPaint(
    double y,
    double x,
    double center,
    int moduleCount,
    Paint green,
    Paint yellow,
    Paint blue,
  ) {
    final double dx = (x - center).abs();
    final double dy = (y - center).abs();
    final double radialDist = sqrt(dx * dx + dy * dy);

    if (radialDist <= moduleCount * 0.23) return blue;
    if ((dx / (moduleCount * 0.46)) + (dy / (moduleCount * 0.36)) <= 1.0) {
      return yellow;
    }
    return green;
  }

  /// English: Checks if the given row and column fall inside the 7x7 corner finder areas.
  /// Español: Verifica si la fila y columna dadas están dentro de las áreas de esquina de 7x7.
  bool _isFinderPattern(int row, int col, int count) {
    return (row < 7 && col < 7) ||
        (row < 7 && col >= count - 7) ||
        (row >= count - 7 && col < 7);
  }

  /// English: Renders a 3-ring concentric circular finder pattern (ratio 7:5:3).
  /// Español: Renderiza un patrón de búsqueda circular concéntrico de 3 anillos (proporción 7:5:3).
  void _drawCircularFinder(
    Canvas canvas,
    int startRow,
    int startCol,
    double cellSize,
    Paint green,
    Paint white,
  ) {
    final Offset finderCenter = Offset(
      (startCol + 3.5) * cellSize,
      (startRow + 3.5) * cellSize,
    );
    canvas.drawCircle(finderCenter, cellSize * 3.5, green);
    canvas.drawCircle(finderCenter, cellSize * 2.5, white);
    canvas.drawCircle(finderCenter, cellSize * 1.5, green);
  }

  @override
  bool shouldRepaint(covariant _BrazilFlagQrPainter oldDelegate) =>
      oldDelegate.qrImage != qrImage;
}
