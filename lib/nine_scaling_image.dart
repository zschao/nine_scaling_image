import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_pixels/image_pixels.dart';

class NineScalingImage extends StatelessWidget {
  final ImageProvider imageProvider; // Background image
  final double dstPieceScale; // Target image scaling ratio
  final Widget? child;
  final bool hideLines; // Whether to hide lines
  final EdgeInsets? padding; // Padding

  /// Calculates the padding based on black line markers in the 9-patch image.
  EdgeInsets? _calculatePadding(
    int topStart,
    int topEnd,
    ImgDetails img,
    int leftStart,
    int leftEnd,
  ) {
    final padding = EdgeInsets.fromLTRB(
          leftStart.toDouble(),
          topStart.toDouble(),
          (img.width ?? 0) - leftEnd.toDouble(),
          (img.height ?? 0) - topEnd.toDouble(),
        ) *
        dstPieceScale;

    return padding.isNonNegative ? padding : null;
  }

  const NineScalingImage(
      {super.key,
      required this.imageProvider,
      this.dstPieceScale = 1.0,
      this.hideLines = true,
      this.child,
      this.padding});

  @override
  Widget build(BuildContext context) {
    return ImagePixels(
      imageProvider: imageProvider,
      builder: (context, img) {
        if (!img.hasImage) {
          return const SizedBox();
        }
        // Initialize variables to store the position of black lines
        int topStart = -1, topEnd = -1;
        int leftStart = -1, leftEnd = -1;

        // Ensure the image size is not null
        if (img.height != null && img.width != null) {
          // Scan the black pixels at the top and bottom of the image
          _scanMarkers(
            (index) => img.pixelColorAt!(0, index),
            length: img.height!,
            onStart: (val) => topStart = val,
            onEnd: (val) => topEnd = val,
          );

          // Scan the black pixels at the left and right of the image
          _scanMarkers(
            (index) => img.pixelColorAt!(index, 0),
            length: img.width!,
            onStart: (val) => leftStart = val,
            onEnd: (val) => leftEnd = val,
          );
        }

        // If the black line is not found, use 0 by default
        topStart = topStart == -1 ? 0 : topStart;
        topEnd = topEnd == -1 ? 0 : topEnd;
        leftStart = leftStart == -1 ? 0 : leftStart;
        leftEnd = leftEnd == -1 ? 0 : leftEnd;
        if (topStart == topEnd) {
          ++topEnd;
        }
        if (leftStart == leftEnd) {
          ++leftEnd;
        }
        // Use ClipPath to remove unnecessary black lines
        return ClipPath(
            clipper: BlackLineClipper(hideLines: hideLines),
            child: RepaintBoundary(
              child: CustomPaint(
                  painter: _NineScalingPainter(
                    image: img.uiImage!,
                    dstPieceScale: dstPieceScale,
                    topStart: topStart,
                    topEnd: topEnd,
                    leftStart: leftStart,
                    leftEnd: leftEnd,
                  ),
                  child: Container(
                    padding: padding ??
                        _calculatePadding(
                            topStart, topEnd, img, leftStart, leftEnd),
                    child: child,
                  )),
            ));
      },
    );
  }

  // Scan the black markers in the image and determine the start and end positions
  void _scanMarkers(
    Color Function(int index) getColor, {
    required int length,
    required Function(int) onStart,
    required Function(int) onEnd,
  }) {
    int start = -1, end = -1;
    for (int i = 0; i < length; i++) {
      if (getColor(i) == Colors.black) {
        if (start == -1) start = i;
        end = i;
      }
    }
    onStart(start);
    onEnd(end);
  }
}

class _NineScalingPainter extends CustomPainter {
  final ui.Image image;
  final double dstPieceScale;
  final int topStart;
  final int topEnd;
  final int leftStart;
  final int leftEnd;

  const _NineScalingPainter({
    required this.image,
    required this.dstPieceScale,
    required this.topStart,
    required this.topEnd,
    required this.leftStart,
    required this.leftEnd,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = Paint();
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();

    // Dynamically calculate the width and height of each region
    final List<double> srcWidth = [
      0,
      leftStart.toDouble(),
      imageWidth - (imageWidth - leftEnd.toDouble()),
      imageWidth
    ];
    final List<double> srcHeight = [
      0,
      topStart.toDouble(),
      imageHeight - (imageHeight - topEnd.toDouble()),
      imageHeight
    ];

    final List<double> dstWidth = [
      0,
      leftStart.toDouble() * dstPieceScale,
      size.width - (imageWidth - leftEnd.toDouble()) * dstPieceScale,
      size.width
    ];
    final List<double> dstHeight = [
      0,
      topStart.toDouble() * dstPieceScale,
      size.height - (imageHeight - topEnd.toDouble()) * dstPieceScale,
      size.height
    ];

    paint.isAntiAlias = false;

    // debugPrint(
    //     'srcWidth: $srcWidth, srcHeight: $srcHeight, dstWidth: $dstWidth, dstHeight: $dstHeight');

    // Draw each region according to the 9-patch grid
    for (int y = 0; y < 3; y++) {
      for (int x = 0; x < 3; x++) {
        final srcRect = Rect.fromLTRB(
            srcWidth[x], srcHeight[y], srcWidth[x + 1], srcHeight[y + 1]);
        final Rect dstRect = Rect.fromLTRB(
            dstWidth[x], dstHeight[y], dstWidth[x + 1], dstHeight[y + 1]);

        // Draw the current region
        canvas.drawImageRect(image, srcRect, dstRect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint when critical parameters change
    if (oldDelegate is _NineScalingPainter) {
      return oldDelegate.image != image ||
          oldDelegate.dstPieceScale != dstPieceScale ||
          oldDelegate.topStart != topStart ||
          oldDelegate.topEnd != topEnd ||
          oldDelegate.leftStart != leftStart ||
          oldDelegate.leftEnd != leftEnd;
    }
    return true;
  }
}

class BlackLineClipper extends CustomClipper<Path> {
  final bool hideLines;

  BlackLineClipper({required this.hideLines});

  @override
  Path getClip(Size size) {
    final path = Path();
    double offset = hideLines ? 1 : 0; // Set whether to hide black lines
    path.addRect(Rect.fromLTWH(
      offset,
      offset,
      size.width - 2 * offset,
      size.height - 2 * offset,
    ));
    return path;
  }

  @override
  bool shouldReclip(BlackLineClipper oldClipper) =>
      hideLines != oldClipper.hideLines;
}
