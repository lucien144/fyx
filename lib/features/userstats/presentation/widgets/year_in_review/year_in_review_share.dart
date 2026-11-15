import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Renders the summary card into a PNG and hands it to the system share sheet.
abstract final class YearInReviewShare {
  static const _pixelRatio = 3.0;

  /// Margin around the card, in logical pixels.
  static const _margin = 12.0;

  /// [cardKey] must belong to a [RepaintBoundary]. The card is drawn on
  /// [background] so its rounded corners never end up transparent.
  static Future<void> shareCard(GlobalKey cardKey, {required Color background, required int year}) async {
    final context = cardKey.currentContext;
    final boundary = context?.findRenderObject();
    if (context == null || boundary is! RenderRepaintBoundary) return;

    final box = context.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset.zero) & box.size;

    final card = await boundary.toImage(pixelRatio: _pixelRatio);
    const margin = _margin * _pixelRatio;
    final size = Size(card.width + 2 * margin, card.height + 2 * margin);

    final recorder = ui.PictureRecorder();
    Canvas(recorder)
      ..drawRect(Offset.zero & size, Paint()..color = background)
      ..drawImage(card, const Offset(margin, margin), Paint());
    final image = await recorder.endRecording().toImage(size.width.round(), size.height.round());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    card.dispose();
    image.dispose();
    if (bytes == null) throw StateError('Encoding the Year in Review card failed');

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/fyx-$year.png');
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

    await Share.shareXFiles([XFile(file.path, mimeType: 'image/png')], sharePositionOrigin: origin);
  }
}
