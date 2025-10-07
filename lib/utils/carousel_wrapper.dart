import 'package:flutter/material.dart';

import 'simple_carousel.dart';

// A wrapper for SimpleCarousel to maintain compatibility with existing code
class ZwiftCarouselSlider extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int, int) itemBuilder;
  final ZwiftCarouselOptions options;

  const ZwiftCarouselSlider({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleCarousel(
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(context, index, itemCount),
      height: options.height,
      autoPlay: options.autoPlay,
      autoPlayInterval: options.autoPlayInterval,
      clipBehavior: options.clipBehavior,
    );
  }
}

// Define our own CarouselOptions class to maintain compatibility
class ZwiftCarouselOptions {
  final double? height;
  final double aspectRatio;
  final double viewportFraction;
  final bool enlargeCenterPage;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final Duration autoPlayAnimationDuration;
  final Curve autoPlayCurve;
  final bool enableInfiniteScroll;
  final bool reverse;
  final ScrollPhysics? scrollPhysics;
  final Function(int, ZwiftCarouselPageChangedReason)? onPageChanged;
  final ValueChanged<double?>? onScrolled;
  final Clip clipBehavior;

  ZwiftCarouselOptions({
    this.height,
    this.aspectRatio = 16 / 9,
    this.viewportFraction = 0.8,
    this.enlargeCenterPage = false,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.autoPlayAnimationDuration = const Duration(milliseconds: 800),
    this.autoPlayCurve = Curves.fastOutSlowIn,
    this.enableInfiniteScroll = true,
    this.reverse = false,
    this.scrollPhysics,
    this.onPageChanged,
    this.onScrolled,
    this.clipBehavior = Clip.hardEdge,
  });
}

// Define our own CarouselPageChangedReason enum for compatibility
enum ZwiftCarouselPageChangedReason {
  timed,
  manual,
  controller,
}
