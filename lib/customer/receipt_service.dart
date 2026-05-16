import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';

/// Layanan untuk me-render [ReceiptWidget] menjadi gambar
/// lalu menyimpannya ke galeri perangkat.
///
/// Dependency yang dibutuhkan di pubspec.yaml:
///   image_gallery_saver: ^2.0.3
///   permission_handler: ^11.3.0   (Android / iOS permission)
class ReceiptService {
  /// Render widget [child] ke bitmap PNG lalu simpan ke galeri.
  ///
  /// Mengembalikan `true` jika berhasil, `false` jika gagal.
  static Future<bool> saveReceiptToGallery({
    required Widget child,
    double pixelRatio = 3.0,
  }) async {
    try {
      // 1. Render widget di luar layar menggunakan RenderRepaintBoundary
      // 2. Gunakan overlayEntry untuk merender widget secara off-screen
      //    lalu capture dengan RepaintBoundary
      final bytes = await _captureWidget(
        child: child,
        pixelRatio: pixelRatio,
      );

      if (bytes == null) return false;

      // 4. Simpan ke galeri
      await Gal.putImageBytes(
        bytes,
        name: 'struk_mbahmeth_${DateTime.now().millisecondsSinceEpoch}',
      );

      return true;
    } catch (e) {
      debugPrint('ReceiptService error: $e');
      return false;
    }
  }

  static Future<Uint8List?> _captureWidget({
    required Widget child,
    required double pixelRatio,
  }) async {
    try {
      // Buat RenderRepaintBoundary secara programatik
      final repaintBoundary = RenderRepaintBoundary();

      final pipelineOwner = PipelineOwner();
      final buildOwner = BuildOwner(focusManager: FocusManager());

      // RenderView fiktif agar widget bisa di-layout
      final renderView = RenderView(
        view: ui.PlatformDispatcher.instance.implicitView!,
        child: RenderPositionedBox(
          alignment: Alignment.center,
          child: repaintBoundary,
        ),
        configuration: ViewConfiguration(
          logicalConstraints: const BoxConstraints(maxWidth: 320),
          devicePixelRatio: pixelRatio,
        ),
      );

      pipelineOwner.rootNode = renderView;
      renderView.prepareInitialFrame();

      final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: child,
          ),
        ),
      ).attachToRenderTree(buildOwner);

      buildOwner.buildScope(rootElement);
      buildOwner.finalizeTree();

      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();

      final image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('_captureWidget error: $e');
      return null;
    }
  }
}