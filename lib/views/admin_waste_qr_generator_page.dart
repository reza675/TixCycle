import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AdminWasteQRGeneratorPage extends StatefulWidget {
  const AdminWasteQRGeneratorPage({Key? key}) : super(key: key);

  @override
  State<AdminWasteQRGeneratorPage> createState() =>
      _AdminWasteQRGeneratorPageState();
}

class _AdminWasteQRGeneratorPageState extends State<AdminWasteQRGeneratorPage> {
  static const Color c1 = Color(0xFFFFF8E2);
  static const Color c2 = Color(0xFFB3CC86);
  static const Color c3 = Color(0xFF798E5E);
  static const Color c4 = Color(0xFF3F5135);

  final TextEditingController deviceIdController = TextEditingController();

  // Data sampah dengan poin
  final Map<String, Map<String, dynamic>> wasteData = {
    'Sisa Makanan': {'points': 2, 'quantity': 0, 'category': 'organik'},
    'Kertas / Kardus': {'points': 3, 'quantity': 0, 'category': 'anorganik'},
    'Plastik': {'points': 8, 'quantity': 0, 'category': 'anorganik'},
    'Logam': {'points': 10, 'quantity': 0, 'category': 'anorganik'},
    'Botol Kaca': {'points': 10, 'quantity': 0, 'category': 'anorganik'},
  };

  String? generatedQRData;

  int getTotalPoints() {
    int total = 0;
    wasteData.forEach((key, value) {
      total += (value['points'] as int) * (value['quantity'] as int);
    });
    return total;
  }

  void generateQRCode() {
    // Cek apakah ada item yang dipilih
    bool hasItems = false;
    wasteData.forEach((key, value) {
      if ((value['quantity'] as int) > 0) {
        hasItems = true;
      }
    });

    if (!hasItems) {
      Get.snackbar(
        'Peringatan',
        'Pilih minimal satu jenis sampah',
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    // Build items list for JSON
    List<Map<String, dynamic>> items = [];
    wasteData.forEach((name, data) {
      if ((data['quantity'] as int) > 0) {
        items.add({
          'name': name,
          'quantity': data['quantity'],
          'points': data['points'],
        });
      }
    });

    // Create QR sampah (sekali pakai)
    final scanId =
        'WASTE_${DateTime.now().millisecondsSinceEpoch}_${(items.length * getTotalPoints()).toString().padLeft(4, '0')}';

    final qrData = {
      'type': 'waste_disposal',
      'scan_id': scanId, // Unique ID untuk tracking
      'timestamp': DateTime.now().toIso8601String(),
      'items': items,
      'total_points': getTotalPoints(),
    };

    setState(() {
      generatedQRData = jsonEncode(qrData);
    });
  }

  void resetForm() {
    setState(() {
      wasteData.forEach((key, value) {
        value['quantity'] = 0;
      });
      generatedQRData = null;
      deviceIdController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c1, c2, Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: c4),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            "Generate QR Code Sampah",
            style: TextStyle(
              color: c4,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 16),
              _buildWasteDataCard(),
              const SizedBox(height: 16),
              _buildTotalPointsCard(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              if (generatedQRData != null) ...[
                const SizedBox(height: 24),
                _buildQRCodeDisplay(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c1.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c3, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: c4, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pilih jenis sampah dan jumlahnya, lalu generate QR Code untuk dicetak',
              style: TextStyle(color: c4, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceIdField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device ID (Opsional)',
            style: TextStyle(
              color: c4,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: deviceIdController,
            decoration: InputDecoration(
              hintText: 'IOT_DEVICE_001',
              prefixIcon: Icon(Icons.qr_code_scanner, color: c3),
              filled: true,
              fillColor: c1.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteDataCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.recycling, color: c3, size: 24),
              const SizedBox(width: 8),
              Text(
                'Data Sampah',
                style: TextStyle(
                  color: c4,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCategorySection('Organik'),
          const SizedBox(height: 12),
          _buildCategorySection('Anorganik'),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category) {
    final categoryItems = wasteData.entries
        .where((e) =>
            e.value['category'].toString().toLowerCase() ==
            category.toLowerCase())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: c4,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        ...categoryItems.map((entry) => _buildWasteItem(entry.key)),
      ],
    );
  }

  Widget _buildWasteItem(String name) {
    final data = wasteData[name]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c1.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: data['quantity'] > 0 ? c3 : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: c4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data['points']} Koin / Sampah',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: c3),
                onPressed: () {
                  if (data['quantity'] > 0) {
                    setState(() {
                      data['quantity']--;
                      generatedQRData = null; // Reset QR when data changes
                    });
                  }
                },
              ),
              Container(
                width: 40,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${data['quantity']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: c4,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: c3),
                onPressed: () {
                  setState(() {
                    data['quantity']++;
                    generatedQRData = null; // Reset QR when data changes
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPointsCard() {
    final total = getTotalPoints();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c3,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: c3.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Poin:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+$total',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: c3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text(
              'Reset',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: resetForm,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: c2,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.qr_code),
            label: const Text(
              'Generate QR',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: generateQRCode,
          ),
        ),
      ],
    );
  }

  Widget _buildQRCodeDisplay() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'QR Code Berhasil Dibuat!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: c4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c3, width: 2),
            ),
            child: QrImageView(
              data: generatedQRData!,
              version: QrVersions.auto,
              size: 250.0,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Total: ${getTotalPoints()} Koin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: c3,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: c3,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.copy),
            label: const Text(
              'Salin Data QR',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: generatedQRData!));
              Get.snackbar(
                'Berhasil',
                'Data QR Code berhasil disalin',
                backgroundColor: c2.withOpacity(0.8),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Screenshot QR Code ini untuk dicetak',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    deviceIdController.dispose();
    super.dispose();
  }
}
