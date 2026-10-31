import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Limits the response while receiving it, including chunked responses whose
/// Content-Length is absent or inaccurate. The caller owns an injected client.
Future<Uint8List> downloadZip(
  Uri uri, {
  required int maxBytes,
  http.Client? client,
  Duration timeout = const Duration(seconds: 30),
}) async {
  if (!['http', 'https'].contains(uri.scheme) || uri.host.isEmpty) {
    throw const FormatException('Enter an HTTP or HTTPS URL.');
  }
  final transport = client ?? http.Client();
  try {
    final response = await transport
        .send(http.Request('GET', uri))
        .timeout(timeout);
    if (response.statusCode != 200) {
      await response.stream.listen((_) {}).cancel();
      throw FormatException('Download failed (HTTP ${response.statusCode}).');
    }
    if ((response.contentLength ?? 0) > maxBytes) {
      await response.stream.listen((_) {}).cancel();
      throw const FormatException('Import exceeds the size limit.');
    }
    final output = BytesBuilder(copy: false);
    await for (final chunk in response.stream.timeout(timeout)) {
      if (output.length + chunk.length > maxBytes) {
        throw const FormatException('Import exceeds the size limit.');
      }
      output.add(chunk);
    }
    return output.takeBytes();
  } finally {
    if (client == null) transport.close();
  }
}
