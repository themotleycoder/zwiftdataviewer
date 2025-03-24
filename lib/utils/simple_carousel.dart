import 'dart:async';
import 'package:flutter/material.dart';

class SimpleCarousel extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final double? height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final Clip clipBehavior;

  const SimpleCarousel({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.height,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.clipBehavior = Clip.hardEdge,
  }) : super(key: key);

  @override
  State<SimpleCarousel> createState() => _SimpleCarouselState();
}

class _SimpleCarouselState extends State<SimpleCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    if (widget.autoPlay && widget.itemCount > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (_currentPage < widget.itemCount - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        _pageController.jumpToPage(0);
      }
    });
  }

  void _stopAutoPlay() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.itemCount,
        clipBehavior: widget.clipBehavior,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return widget.itemBuilder(context, index);
        },
      ),
    );
  }
}
