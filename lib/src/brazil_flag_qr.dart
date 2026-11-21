import 'dart:math';

import 'package:flutter/widgets.dart';
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

  /// English: Total width and height of the QR container in logical pixels.
  /// Español: Ancho y alto total del contenedor del código QR en píxeles lógicos.
  final double size;

  /// English: Whether to display a logo at the center of the QR code.
  /// When false, the center area is filled with standard QR dots.
  ///
  /// Español: Indica si se debe mostrar un logo en el centro del código QR.
  /// Cuando es false, el área central se rellena con los puntos normales del QR.
  final bool showLogo;

  /// English: Whether to wrap the QR code inside the default white rounded container with border.
  /// Set to false to render the raw QR code and build your own custom container.
  ///
  /// Español: Indica si se debe envolver el código QR dentro del contenedor blanco redondeado con borde.
  /// Ponlo en false para renderizar el QR puro y crear tu propio contenedor personalizado.
  final bool showContainer;

  /// English: Custom image to display at the center when [showLogo] is true.
  /// If null, the default vector Pix logo is rendered directly on the canvas.
  ///
  /// Español: Imagen personalizada para mostrar en el centro cuando [showLogo] is true.
  /// Si es nula, se dibuja el logo vectorial de Pix por defecto directamente en el lienzo.
  final ImageProvider? logoImage;

  /// English: Size ratio of the center logo relative to the inner QR width.
  /// Defaults to 0.10 (10%). Ignored if [logoSize] is explicitly provided.
  ///
  /// Español: Proporción del tamaño del logo central respecto al ancho interno del QR.
  /// Por defecto es 0.10 (10%). Se ignora si se especifica [logoSize].
  final double logoSizeRatio;

  /// English: Optional fixed width and height in logical pixels for the center logo.
  /// Overrides [logoSizeRatio] when provided (clamped to a safe 24% max of QR width).
  ///
  /// Español: Ancho y alto fijo opcional en píxeles lógicos para el logo central.
  /// Sobrescribe [logoSizeRatio] cuando se especifica (limitado a un máximo seguro del 24% del QR).
  final double? logoSize;

  /// English: Optional custom widget overlay (kept for backwards compatibility).
  /// Español: Widget personalizado opcional superpuesto (mantenido por retrocompatibilidad).
  final Widget? centerWidget;

  /// English: Renders a Brazilian flag QR code from an existing [payload] string.
  /// Español: Renderiza un código QR con la bandera de Brasil a partir de un [payload] existente.
  const BrazilFlagQr.fromPayload({
    super.key,
    required this.payload,
    this.size = 220,
    this.showLogo = true,
    this.showContainer = true,
    this.logoImage,
    this.logoSizeRatio = 0.10,
    this.logoSize,
    this.centerWidget,
  });

  /// English: All-in-one factory that generates the Pix EMV payload with optional message
  /// and renders the Brazilian flag QR code directly.
  ///
  /// Español: Constructor todo-en-uno que genera el payload Pix EMV con mensaje opcional
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
    bool showLogo = true,
    bool showContainer = true,
    ImageProvider? logoImage,
    double logoSizeRatio = 0.10,
    double? logoSize,
    Widget? centerWidget,
  }) {
    // English: Build the standardized BR Code / EMV payload string first.
    // Español: Construye primero la cadena estandarizada de payload BR Code / EMV.
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
      showLogo: showLogo,
      showContainer: showContainer,
      logoImage: logoImage,
      logoSizeRatio: logoSizeRatio,
      logoSize: logoSize,
      centerWidget: centerWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    // English: Generate the QR matrix using High (H) error correction (up to 30% recovery)
    // so the center logo never interferes with camera scanning.
    //
    // Español: Genera la matriz QR usando corrección de errores Alta (H) (hasta 30% de recuperación)
    // para que el logo central nunca interfiera con el escaneo de la cámara.
    final qrCode = QrCode(
      payload: QrPayload.fromString(payload),
      errorCorrectLevel: QrErrorCorrectLevel.high,
    );
    final qrImage = QrImage(qrCode);

    // English: Calculate internal QR canvas size depending on whether the container padding is enabled.
    // Español: Calcula el tamaño interno del lienzo del QR según si el relleno del contenedor está activado.
    final double paddingValue = showContainer ? 12.0 : 0.0;
    final double qrContentSize = size - (paddingValue * 2);

    // English: Compute exact logo pixel size from [logoSize] or [logoSizeRatio], clamped to a safe 24% max.
    // Español: Calcula el tamaño exacto en píxeles del logo desde [logoSize] o [logoSizeRatio], limitado a un máximo seguro del 24%.
    final double maxSafeLogoPx = qrContentSize * 0.24;
    final double resolvedLogoPx = (logoSize ?? (qrContentSize * logoSizeRatio))
        .clamp(12.0, maxSafeLogoPx);
    final double effectiveRatio = resolvedLogoPx / qrContentSize;

    // English: Resolve the 3 center logo scenarios:
    // 1. showLogo == true && logoImage == null -> Draw built-in vector Pix logo on canvas.
    // 2. showLogo == true && logoImage != null -> Display user's custom image directly without extra wrappers.
    // 3. showLogo == false -> Render nothing in the center and keep all QR dots intact.
    //
    // Español: Resuelve los 3 escenarios del logo central:
    // 1. showLogo == true && logoImage == null -> Dibuja el logo vectorial de Pix integrado en el lienzo.
    // 2. showLogo == true && logoImage != null -> Muestra la imagen personalizada del usuario directamente sin contenedores extra.
    // 3. showLogo == false -> No renderiza nada en el centro y mantiene intactos todos los puntos del QR.
    final bool shouldDrawDefaultPix =
        showLogo && logoImage == null && centerWidget == null;

    Widget? customCenterOverlay;
    if (showLogo) {
      if (centerWidget != null) {
        customCenterOverlay = centerWidget;
      } else if (logoImage != null) {
        customCenterOverlay = ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image(
            image: logoImage!,
            width: resolvedLogoPx,
            height: resolvedLogoPx,
            fit: BoxFit.contain,
          ),
        );
      }
    }

    final Widget qrStack = Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(qrContentSize, qrContentSize),
          painter: _BrazilFlagQrPainter(
            qrImage: qrImage,
            clearCenter: showLogo,
            drawDefaultPixIcon: shouldDrawDefaultPix,
            logoSizeRatio: effectiveRatio,
          ),
        ),
        ?customCenterOverlay,
      ],
    );

    // English: Wrap in the default white rounded container only if showContainer is true.
    // Español: Envuelve en el contenedor blanco redondeado por defecto solo si showContainer es true.
    return Center(
      child: showContainer
          ? Container(
              width: size,
              height: size,
              padding: EdgeInsets.all(paddingValue),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: qrStack,
            )
          : SizedBox(width: size, height: size, child: qrStack),
    );
  }
}

/// English: CustomPainter that renders circular QR modules colored according
/// to the Brazilian flag geometry (green field, amber diamond, blue circle).
///
/// Español: CustomPainter que dibuja los módulos circulares del QR coloreados según
/// la geometría de la bandera de Brasil (fondo verde, rombo ámbar, círculo azul).
class _BrazilFlagQrPainter extends CustomPainter {
  final QrImage qrImage;
  final bool clearCenter;
  final bool drawDefaultPixIcon;
  final double logoSizeRatio;

  _BrazilFlagQrPainter({
    required this.qrImage,
    required this.clearCenter,
    required this.drawDefaultPixIcon,
    required this.logoSizeRatio,
  });

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
    final whitePaint = Paint()..color = const Color(0xFFFFFFFF);

    // English: Exact grid midpoint used to align colors and the center logo symmetrically.
    // Español: Punto medio exacto de la cuadrícula usado para alinear simétricamente los colores y el logo central.
    final double center = moduleCount / 2.0;
    // English: Scale the circular clearance radius proportionally to logoSizeRatio
    // so larger custom logos never overlap with QR dots.
    //
    // Español: Escala el radio del espacio circular libre proporcionalmente a logoSizeRatio
    // para que logos personalizados más grandes nunca se superpongan con los puntos del QR.
    final double clearRadiusInModules = moduleCount * (logoSizeRatio * 0.62);
    for (int row = 0; row < moduleCount; row++) {
      for (int col = 0; col < moduleCount; col++) {
        // English: Skip the 3 corner finder patterns; they are drawn as concentric circles below.
        // Español: Omite los 3 patrones de esquina; se dibujan como círculos concéntricos más abajo.
        if (_isFinderPattern(row, col, moduleCount)) continue;
        // English: Carve out a circular safe zone in the middle only when showLogo is enabled.
        // Español: Recorta una zona segura circular en el medio únicamente cuando showLogo está activado.
        if (clearCenter) {
          final double centerDist = sqrt(
            pow(col + 0.5 - center, 2) + pow(row + 0.5 - center, 2),
          );
          if (centerDist < clearRadiusInModules) continue;
        }
        // English: Draw dark QR modules as circular dots tinted by their flag region.
        // Español: Dibuja los módulos oscuros del QR como puntos circulares teñidos según su región de la bandera.
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
    // English: Render the 3 circular corner finder markers in flag green.
    // Español: Renderiza los 3 marcadores circulares de esquina en verde bandera.
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
    // English: Draw the built-in vector Pix logo scaled proportionally to logoSizeRatio.
    // Español: Dibuja el logo vectorial integrado de Pix escalado proporcionalmente a logoSizeRatio.
    if (drawDefaultPixIcon) {
      _drawCenterPixLogo(
        canvas,
        center * cellSize,
        size.width * (logoSizeRatio * 0.90),
      );
    }
  }

  /// English: Evaluates whether a module falls inside the blue circle, amber diamond, or green field.
  /// Español: Evalúa si un módulo cae dentro del círculo azul, el rombo ámbar o el campo verde.
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
    // English: Inner circle equation (x^2 + y^2 <= r^2) -> Flag Blue.
    // Español: Ecuación del círculo interior (x^2 + y^2 <= r^2) -> Azul bandera.
    if (radialDist <= moduleCount * 0.23) return blue;
    // English: Diamond (rhombus) Manhattan equation (|x|/a + |y|/b <= 1) -> Flag Amber/Yellow.
    // Español: Ecuación del rombo (|x|/a + |y|/b <= 1) -> Ámbar/Amarillo bandera.
    if ((dx / (moduleCount * 0.46)) + (dy / (moduleCount * 0.36)) <= 1.0) {
      return yellow;
    }
    // English: Outer background area -> Flag Green.
    // Español: Área exterior de fondo -> Verde bandera.
    return green;
  }

  /// English: Checks if the given row and column fall inside the three 7x7 corner finder areas.
  /// Español: Verifica si la fila y columna dadas caen dentro de las tres áreas de esquina de 7x7.
  bool _isFinderPattern(int row, int col, int count) {
    return (row < 7 && col < 7) ||
        (row < 7 && col >= count - 7) ||
        (row >= count - 7 && col < 7);
  }

  /// English: Renders a 3-ring concentric circular finder pattern (standard 7:5:3 module ratio).
  /// Español: Renderiza un patrón de búsqueda circular concéntrico de 3 anillos (proporción estándar de módulos 7:5:3).
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

  /// English: Draws the official 4-diamond Pix symbol in turquoise (#32BCAD) at [exactCenter].
  /// Español: Dibuja el símbolo oficial de 4 rombos de Pix en turquesa (#32BCAD) en [exactCenter].
  void _drawCenterPixLogo(Canvas canvas, double exactCenter, double logoSize) {
    final paint = Paint()
      ..color = const Color(0xFF32BCAD)
      ..style = PaintingStyle.fill;
    final double r = logoSize * 0.22;
    final double d = logoSize * 0.25;
    // English: Helper to trace each of the 4 symmetrical rhombus petals.
    // Español: Función auxiliar para trazar cada uno de los 4 pétalos romboidales simétricos.
    void drawDiamond(double x, double y) {
      final path = Path()
        ..moveTo(x, y - r)
        ..lineTo(x + r, y)
        ..lineTo(x, y + r)
        ..lineTo(x - r, y)
        ..close();
      canvas.drawPath(path, paint);
    }

    drawDiamond(exactCenter, exactCenter - d); // Top / Arriba
    drawDiamond(exactCenter, exactCenter + d); // Bottom / Abajo
    drawDiamond(exactCenter - d, exactCenter); // Left / Izquierda
    drawDiamond(exactCenter + d, exactCenter); // Right / Derecha
  }

  @override
  bool shouldRepaint(covariant _BrazilFlagQrPainter oldDelegate) =>
      oldDelegate.qrImage != qrImage ||
      oldDelegate.clearCenter != clearCenter ||
      oldDelegate.drawDefaultPixIcon != drawDefaultPixIcon ||
      oldDelegate.logoSizeRatio != logoSizeRatio;
}
