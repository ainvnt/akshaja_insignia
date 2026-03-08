import 'package:akshaja_insignia/src/services/aws_sig_v4_signer.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final uri = Uri.parse('https://akshaja-insignia.s3.ap-south-1.amazonaws.com/daily-maintenance-evidence/2026/03/08/photo_5bd65fcf-a5b0-4a73-aef7-b8b0508039ab.avif');
  final headers = AwsSigV4Signer.signedGetHeaders(uri);
  final res = await http.get(uri, headers: headers);
  print('status: ${res.statusCode}');
  print('body: ${res.body.length > 500 ? res.body.substring(0,500) : res.body}');
}
