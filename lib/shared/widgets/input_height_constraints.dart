import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Build a max-height constraint for large text inputs to avoid UI overflow.
///
/// This keeps editors readable while respecting keyboard/viewInsets and
/// surrounding UI (buttons, headers, etc.) via [reservedHeight].
BoxConstraints buildInputMaxHeightConstraints({
  required BuildContext context,
  double reservedHeight = 0,
  double softCapFraction = 0.45,
  double minHeight = 80,
  double extraBottomPadding = 0,
  bool enabled = true,
}) {
  if (!enabled) return const BoxConstraints();
  final maxHeight = computeInputMaxHeight(
    context: context,
    reservedHeight: reservedHeight,
    softCapFraction: softCapFraction,
    minHeight: minHeight,
    extraBottomPadding: extraBottomPadding,
  );
  if (!maxHeight.isFinite || maxHeight <= 0) {
    return const BoxConstraints();
  }
  return BoxConstraints(maxHeight: maxHeight);
}

/// Compute a max height for text inputs based on visible screen area.
double computeInputMaxHeight({
  required BuildContext context,
  double reservedHeight = 0,
  double softCapFraction = 0.45,
  double minHeight = 80,
  double extraBottomPadding = 0,
}) {
  final size = MediaQuery.sizeOf(context);
  final viewInsets = MediaQuery.viewInsetsOf(context);
  final visibleHeight = math.max(0.0, size.height - viewInsets.bottom - extraBottomPadding);
  final cappedFraction = softCapFraction.clamp(0.1, 0.95);
  final softCap = visibleHeight * cappedFraction;
  final available = visibleHeight - reservedHeight;
  final minCap = math.max(0.0, minHeight);

  if (available > 0) {
    final capped = math.min(softCap, available);
    return math.min(available, math.max(minCap, capped));
  }
  final fallback = math.max(minCap, softCap);
  return math.min(visibleHeight, fallback);
}
