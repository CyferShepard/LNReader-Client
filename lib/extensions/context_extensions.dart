import 'dart:math';

import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

extension SizedContext on BuildContext {
  double get pixelsPerInch => UniversalPlatform.isAndroid || UniversalPlatform.isIOS ? 150 : 96;

  /// Returns same as MediaQuery.of(context)
  MediaQueryData get mq => MediaQuery.of(this);

  /// Returns if Orientation is landscape
  bool get isLandscape => mq.orientation == Orientation.landscape;

  /// Returns same as MediaQuery.of(context).size
  Size get sizePx => mq.size;

  /// Returns same as MediaQuery.of(context).size.width
  double get widthPx => sizePx.width;

  /// Returns same as MediaQuery.of(context).height
  double get heightPx => sizePx.height;

  /// Returns diagonal screen pixels
  double get diagonalPx {
    final Size s = sizePx;
    return sqrt((s.width * s.width) + (s.height * s.height));
  }

  /// Returns pixel size in Inches
  Size get sizeInches {
    final Size pxSize = sizePx;
    return Size(pxSize.width / pixelsPerInch, pxSize.height / pixelsPerInch);
  }

  /// Returns screen width in Inches
  double get widthInches => sizeInches.width;

  /// Returns screen height in Inches
  double get heightInches => sizeInches.height;

  /// Returns screen diagonal in Inches
  double get diagonalInches => diagonalPx / pixelsPerInch;

  /// Returns fraction (0-1) of screen width in pixels
  double widthPct(double fraction) => fraction * widthPx;

  /// Returns fraction (0-1) of screen height in pixels
  double heightPct(double fraction) => fraction * heightPx;

  double get shortestSide => mq.size.shortestSide;
  bool get isMobile => shortestSide < 600.0;
  bool get isTablet => shortestSide >= 600.0 && shortestSide < 1000.0;
  bool get isTabletOrDesktop => shortestSide >= 600.0;
  bool get isDesktop => shortestSide >= 1000.0;
  bool get isWatch => shortestSide < 300.0;
  bool get isSmallScreen => shortestSide < 600.0;
  bool get isMediumScreen => shortestSide >= 600.0 && shortestSide < 1000.0;
  bool get isLargeScreen => shortestSide >= 1000.0;
  bool get isVeryLargeScreen => shortestSide >= 1200.0;
  bool get isUltraLargeScreen => shortestSide >= 1400.0;
  bool get isUltraWideScreen => shortestSide >= 1600.0;
}
