import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReceiptOcrPage extends StatefulWidget {
  const ReceiptOcrPage({super.key});

  @override
  State<ReceiptOcrPage> createState() => _ReceiptOcrPageState();
}

class _ReceiptOcrPageState extends State<ReceiptOcrPage> {
  XFile? imageFile;
  String? rawText;
  Map<String, dynamic>? parsed;
  bool processing = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final f = await picker.pickImage(source: ImageSource.gallery);
    if (f != null) {
      setState(() {
        imageFile = f;
        rawText = null;
        parsed = null;
      });
      await _runOcr();
    }
  }

  Future<void> _runOcr() async {
    if (imageFile == null) return;
    setState(() => processing = true);
    try {
      final inputImage = InputImage.fromFilePath(imageFile!.path);
      final recognizer = TextRecognizer();
      final recognized = await recognizer.processImage(inputImage);
      await recognizer.close();
      rawText = recognized.text;
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('OCR error: $e')));
      }
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  Future<void> _callLLM() async {
    if (rawText == null || rawText!.isEmpty) return;
    setState(() => processing = true);
    try {
      // Contoh pakai OpenRouter demo (gratis terbatas). Ganti API key di env bila ada.
      final apiKey =
          const String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');
      final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
      final system =
          'Anda adalah asisten yang mengekstrak data struk BBM. Format keluaran JSON dengan key: date(yyyy-mm-dd), station, fuel_type, quantity_l (number), price_per_liter (number), total (number). Jika tidak yakin, kosongkan.';
      final user = 'Teks struk:\n${rawText}';
      final body = jsonEncode({
        'model': 'openrouter/auto',
        'messages': [
          {'role': 'system', 'content': system},
          {'role': 'user', 'content': user},
        ],
        'response_format': {'type': 'json_object'},
      });
      final headers = {
        'Content-Type': 'application/json',
        if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
        'HTTP-Referer': 'https://fuelmeter-mobile',
        'X-Title': 'FuelMeter OCR',
      };

      final resp = await http.post(url, headers: headers, body: body);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final content = data['choices']?[0]?['message']?['content'];
        if (content is String) {
          try {
            parsed = jsonDecode(content) as Map<String, dynamic>;
          } catch (_) {
            parsed = {'raw': content};
          }
        } else {
          parsed = {'raw': data};
        }
        if (mounted) setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('LLM error: ${resp.statusCode}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('LLM call error: $e')));
      }
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Receipt (Beta)'),
        actions: [
          IconButton(
              onPressed: _pickImage, icon: const Icon(Icons.image_outlined)),
          IconButton(
              onPressed: (rawText == null) ? null : _callLLM,
              icon: const Icon(Icons.smart_toy_outlined)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (imageFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(imageFile!.path),
                  height: 200, fit: BoxFit.cover),
            ),
          const SizedBox(height: 12),
          if (processing) const LinearProgressIndicator(),
          const Text('OCR Text', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context)
                  .colorScheme
                  .surfaceVariant
                  .withValues(alpha: .3),
            ),
            child: Text(rawText ?? '-',
                style: const TextStyle(fontFamily: 'monospace')),
          ),
          const SizedBox(height: 12),
          const Text('LLM Parsed (JSON)',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context)
                  .colorScheme
                  .surfaceVariant
                  .withValues(alpha: .3),
            ),
            child: Text(parsed != null
                ? const JsonEncoder.withIndent('  ').convert(parsed)
                : '-'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImage,
        icon: const Icon(Icons.document_scanner_outlined),
        label: const Text('Pilih Foto'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
