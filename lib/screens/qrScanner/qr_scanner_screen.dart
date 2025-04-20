import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';
import '../../data/food_data.dart'; // Updated data structure

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: QRScannerScreen(),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String? _scannedQRCode;
  bool _hasNavigated = false;

  Future<void> _handleQRCode(String code) async {
    final bool isValidRestaurant = restaurantMenus.containsKey(code);

    if (isValidRestaurant) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_restaurant_id', code);

      if (!_hasNavigated && mounted) {
        setState(() => _hasNavigated = true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(restaurantId: code),
          ),
        );
      }
    } else {
      setState(() {
        _scannedQRCode = 'Not a restaurant QR';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Scanner')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: MobileScanner(
              onDetect: (BarcodeCapture barcodeCapture) {
                final String code =
                    barcodeCapture.barcodes.first.rawValue ?? 'Unknown';
                _handleQRCode(code);
              },
            ),
          ),
          if (_scannedQRCode != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Scanned QR Code: $_scannedQRCode',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
