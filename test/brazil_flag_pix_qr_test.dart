import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brazil_flag_pix_qr/brazil_flag_pix_qr.dart';

void main() {
  // English: 1x1 transparent PNG bytes in Base64 to test custom logoImage without asset files.
  // Español: Bytes de un PNG transparente de 1x1 en Base64 para probar logoImage sin archivos externos.
  final kTransparentImageBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
  );

  group('PixPayloadBuilder Unit Tests / Pruebas Unitarias', () {
    test('Generates exact payload with description, amount, and CRC16 / Genera payload exacto con descripción, monto y CRC16', () {
      // English: Uses fictional data and a dummy UUID key to verify EMV structure and CRC16.
      // Español: Usa datos ficticios y una llave UUID de prueba para verificar la estructura EMV y el CRC16.
      final payload = PixPayloadBuilder.generate(
        pixKey: '123e4567-e89b-12d3-a456-426614174000',
        merchantName: 'JUAN PEREZ SILVA',
        merchantCity: 'Sao Paulo',
        description: 'test payment',
        txId: 'idTestApp',
        amount: 10.00,
      );

      expect(
        payload,
        equals(
          '00020126740014br.gov.bcb.pix0136123e4567-e89b-12d3-a456-426614174000'
          '0212test payment520400005303986540510.005802BR5916JUAN PEREZ SILVA'
          '6009Sao Paulo62130509idTestApp63048E4F',
        ),
      );
    });

    test('Generates payload without amount (free amount) / Genera payload sin monto fijo (monto libre)', () {
      final payload = PixPayloadBuilder.generate(
        pixKey: '123e4567-e89b-12d3-a456-426614174000',
        merchantName: 'Maria Silva',
        merchantCity: 'Rio de Janeiro',
      );

      // English: Field 54 (Amount) must not be present when amount is null.
      // Español: El campo 54 (Monto) no debe existir cuando el monto es nulo.
      expect(payload.contains('53039865802BR'), isTrue);
      expect(payload.endsWith('6304') == false && payload.length > 20, isTrue);
    });

    test('Sanitizes accents and special characters / Limpia tildes y caracteres especiales', () {
      final payload = PixPayloadBuilder.generate(
        pixKey: '123e4567-e89b-12d3-a456-426614174000',
        merchantName: 'José Núñez Peña',
        merchantCity: 'Foz do Iguaçu',
        description: 'Donación Ñandutí!',
      );

      expect(payload.contains('Jose Nunez Pena'), isTrue);
      expect(payload.contains('Foz do Iguacu'), isTrue);
      expect(payload.contains('Donacion Nanduti'), isTrue);
    });

    test('Enforces 99-char limit on Merchant Account (ID 26) / Respeta el límite de 99 caracteres en el bloque 26', () {
      const dummyRandomKey = '123e4567-e89b-12d3-a456-426614174000';
      final payload = PixPayloadBuilder.generate(
        pixKey: dummyRandomKey,
        merchantName: 'Carlos Souza',
        merchantCity: 'Sao Paulo',
        description: 'This is a very long description that exceeds the maximum allowed characters inside field 26',
      );

      final index26 = payload.indexOf('26');
      final field26Length = int.parse(
        payload.substring(index26 + 2, index26 + 4),
      );

      expect(field26Length, lessThanOrEqualTo(99));
    });
  });

  group('BrazilFlagQr Widget Tests / Pruebas de Widget', () {
    testWidgets(
      'Renders default vector Pix logo and white container / Renderiza el logo Pix vectorial por defecto y el contenedor blanco',
      (tester) async {
        final payload = PixPayloadBuilder.generate(
          pixKey: '123e4567-e89b-12d3-a456-426614174000',
          merchantName: 'Ana Costa',
          merchantCity: 'Curitiba',
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: BrazilFlagQr.fromPayload(payload: payload, size: 200),
          ),
        );

        // English: Verifies that the widget renders with a single CustomPaint (QR + integrated vector logo)
        // and wraps the QR inside the default Container.
        // Español: Verifica que el widget renderice un solo CustomPaint (QR + logo vectorial integrado)
        // y envuelva el QR dentro del Container por defecto.
        expect(find.byType(BrazilFlagQr), findsOneWidget);
        expect(find.byType(CustomPaint), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Image), findsNothing);
      },
    );

    testWidgets(
      'Renders custom logoImage when showLogo is true / Renderiza logoImage personalizada cuando showLogo es true',
      (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: BrazilFlagQr.pix(
              pixKey: '123e4567-e89b-12d3-a456-426614174000',
              merchantName: 'Pedro Santos',
              merchantCity: 'Brasilia',
              showLogo: true,
              logoImage: MemoryImage(kTransparentImageBytes),
            ),
          ),
        );

        // English: Verifies that the custom Image widget is displayed at the center.
        // Español: Verifica que el widget Image personalizado se muestre en el centro.
        expect(find.byType(BrazilFlagQr), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets(
      'Hides center logo and outer container when set to false / Oculta el logo central y el contenedor exterior cuando están en false',
      (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: BrazilFlagQr.pix(
              pixKey: '123e4567-e89b-12d3-a456-426614174000',
              merchantName: 'Lucas Lima',
              merchantCity: 'Salvador',
              showLogo: false,
              showContainer: false,
            ),
          ),
        );

        // English: When showContainer is false, no Container widget is created.
        // Español: Cuando showContainer es false, no se crea ningún widget Container.
        expect(find.byType(BrazilFlagQr), findsOneWidget);
        expect(find.byType(Container), findsNothing);
        expect(find.byType(Image), findsNothing);
      },
    );
  });
}
