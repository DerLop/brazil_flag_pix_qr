import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brazil_flag_pix_qr/brazil_flag_pix_qr.dart';

void main() {
  group('PixPayloadBuilder Unit Tests / Pruebas Unitarias', () {
    test('Generates exact payload with description, amount, and CRC16 / Genera payload exacto con descripción, monto y CRC16', () {
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
      'Renders BrazilFlagQr.fromPayload properly / Renderiza BrazilFlagQr.fromPayload correctamente',
      (tester) async {
        final payload = PixPayloadBuilder.generate(
          pixKey: '123e4567-e89b-12d3-a456-426614174000',
          merchantName: 'Ana Costa',
          merchantCity: 'Curitiba',
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: BrazilFlagQr.fromPayload(payload: payload, size: 200),
            ),
          ),
        );

        expect(find.byType(BrazilFlagQr), findsOneWidget);
        expect(find.byType(CustomPaint), findsNWidgets(2));
      },
    );

    testWidgets(
      'Renders BrazilFlagQr.pix all-in-one constructor / Renderiza el constructor todo-en-uno BrazilFlagQr.pix',
      (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: BrazilFlagQr.pix(
                pixKey: '123e4567-e89b-12d3-a456-426614174000',
                merchantName: 'Pedro Santos',
                merchantCity: 'Brasilia',
                description: 'Sample message',
                amount: 15.0,
                showDefaultPixIcon: false,
              ),
            ),
          ),
        );

        expect(find.byType(BrazilFlagQr), findsOneWidget);
        expect(find.byType(CustomPaint), findsOneWidget);
      },
    );
  });
}
