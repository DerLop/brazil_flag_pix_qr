import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brazil_flag_pix_qr/brazil_flag_pix_qr.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brazil Flag Pix QR Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF009C3B)),
        useMaterial3: true,
      ),
      home: const PixDemoScreen(),
    );
  }
}

class PixDemoScreen extends StatefulWidget {
  const PixDemoScreen({super.key});

  @override
  State<PixDemoScreen> createState() => _PixDemoScreenState();
}

class _PixDemoScreenState extends State<PixDemoScreen> {
  double? _selectedAmount = 10.0;
  final TextEditingController _messageController = TextEditingController(
    text: 'Ejemplo de mensaje para donaciones',
  );
  final String _dummyPixKey = '123e4567-e89b-12d3-a456-426614174000';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _copyPayload(String payload) {
    Clipboard.setData(ClipboardData(text: payload));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datos de pago Pix copiados al portapapeles'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String pixPayload = PixPayloadBuilder.generate(
      pixKey: _dummyPixKey,
      merchantName: 'JOHN DOE',
      merchantCity: 'Sao Paulo',
      description: _messageController.text,
      txId: 'demoTxId01',
      amount: _selectedAmount,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Brazil Flag Pix QR Demo'),
        centerTitle: true,
        backgroundColor: const Color(0xFF009C3B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    BrazilFlagQr.pix(
                      pixKey: _dummyPixKey,
                      merchantName: 'JOHN DOE',
                      merchantCity: 'Sao Paulo',
                      description: _messageController.text,
                      txId: 'demoTxId01',
                      amount: _selectedAmount,
                      showLogo: true,
                      showContainer: false,
                      logoSize: 20,
                      size: 240,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Qr con showContainer: false, \nshowLogo: true,\nlogoImage: null',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 150),
                Column(
                  children: [
                    BrazilFlagQr.fromPayload(
                      payload: pixPayload,
                      showLogo: true,
                      showContainer: true,
                      logoImage: const AssetImage('assets/paraguay.png'),
                      size: 240,
                      logoSize: 30,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Qr con showContainer: true, \nshowLogo: true,\nlogoImage: AssetImage()',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 150),
                Column(
                  children: [
                    BrazilFlagQr.fromPayload(
                      payload: pixPayload,
                      showLogo: false,
                      showContainer: true,
                      size: 240,
                      logoSize: 30,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Qr con showContainer: true, \nshowLogo: false \n',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Pix Message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [null, 5.0, 10.0, 25.0]
                  .map(
                    (amt) => ChoiceChip(
                      showCheckmark: false,
                      label: Text(amt == null ? 'Free' : 'R\$ $amt'),
                      selected: _selectedAmount == amt,
                      selectedColor: const Color(0xFF009C3B),
                      onSelected: (_) => setState(() => _selectedAmount = amt),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                pixPayload,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy Pix Payload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002776),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _copyPayload(pixPayload),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
