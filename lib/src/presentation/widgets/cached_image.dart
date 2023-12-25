import 'package:flutter/material.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dismissible_page/dismissible_page.dart';

import 'custom_shimmer.dart';

final cacheManager = CacheManager(
  Config(
    'imageCache',
    maxNrOfCacheObjects: 512,
    stalePeriod: const Duration(days: 14),
  ),
);

Future<void> clearImageCache() async => await cacheManager.emptyCache();

class CachedCircleImage extends StatelessWidget {
  final String url;
  final double? radius;
  final Clip? clipBehavior;

  const CachedCircleImage(
    this.url, {
    super.key,
    this.radius,
    this.clipBehavior,
  });

  static const double _defaultRadius = 20.0;

  static const double _defaultMinRadius = 0.0;

  static const double _defaultMaxRadius = double.infinity;

  double get _minDiameter {
    if (radius == null) {
      return _defaultRadius * 2.0;
    }
    return 2.0 * (radius ?? _defaultMinRadius);
  }

  double get _maxDiameter {
    if (radius == null) {
      return _defaultRadius * 2.0;
    }
    return 2.0 * (radius ?? _defaultMaxRadius);
  }

  @override
  Widget build(BuildContext context) {
    final double minDiameter = _minDiameter;
    final double maxDiameter = _maxDiameter;

    return AnimatedContainer(
      constraints: BoxConstraints(
        minHeight: minDiameter,
        minWidth: minDiameter,
        maxWidth: maxDiameter,
        maxHeight: maxDiameter,
      ),
      duration: kThemeChangeDuration,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        clipBehavior: clipBehavior ?? Clip.hardEdge,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          cacheManager: cacheManager,
          placeholder: (context, url) => const CustomShimmer(),
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.error_outline_rounded),
          ),
        ),
      ),
    );

    // return AnimatedContainer(
    //   constraints: BoxConstraints(
    //     minHeight: minDiameter,
    //     minWidth: minDiameter,
    //     maxWidth: maxDiameter,
    //     maxHeight: maxDiameter,
    //   ),
    //   duration: kThemeChangeDuration,
    //   decoration: BoxDecoration(
    //     // shape: BoxShape.circle,
    //     borderRadius: BorderRadius.circular(maxDiameter),
    //   ),
    //   child: ClipRRect(
    //     borderRadius: BorderRadius.circular(maxDiameter),
    //     child: CachedNetworkImage(
    //       imageUrl: url,
    //       fit: BoxFit.cover,
    //       cacheManager: cacheManager,
    //       placeholder: (context, url) => const CustomShimmer(),
    //       errorWidget: (context, url, error) => const Center(
    //         child: Icon(Icons.error_outline_rounded),
    //       ),
    //     ),
    //   ),
    // );
  }
}

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;
  final double? width;
  final double? height;

  const CachedImage(
    this.imageUrl, {
    super.key,
    //this.fit = BoxFit.cover,
    // this.width = double.infinity,
    // this.height = double.infinity,
    this.fit,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      cacheManager: cacheManager,
      placeholder: (context, url) => const CustomShimmer(),
      errorWidget: (context, url, error) => const Center(
        child: Icon(Icons.error_outline_rounded),
      ),
      // progressIndicatorBuilder: (context, _, p) => Center(
      //   child: CircularProgressIndicator(
      //     value: p.progress,
      //   ),
      // ),
    );
  }
}

class ImageViewerPage extends StatefulWidget {
  final String imageUrl;
  final String tag;

  const ImageViewerPage(
    this.imageUrl, {
    super.key,
    required this.tag,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage>
    with SingleTickerProviderStateMixin {
  final _transformCtrl = TransformationController();
  late final AnimationController _animationCtrl;
  late final CurvedAnimation _curveWrapper;
  Animation<Matrix4>? _animation;

  /// Last place the user double-tapped on.
  Offset? _lastOffset;

  @override
  void initState() {
    super.initState();
    _animationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _curveWrapper = CurvedAnimation(
      parent: _animationCtrl,
      curve: Curves.easeOutExpo,
    );
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    _animationCtrl.dispose();
    super.dispose();
  }

  void _updateState() => _transformCtrl.value = _animation!.value;

  void _endAnimation() {
    _animation?.removeListener(_updateState);
    _animation = null;
    _animationCtrl.reset();
  }

  void _animateMatrixTo(Matrix4 goal) {
    _endAnimation();
    _animation = Matrix4Tween(
      begin: _transformCtrl.value,
      end: goal,
    ).animate(_curveWrapper);
    _animation!.addListener(_updateState);
    _animationCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () {
        Navigator.of(context).pop();
      },
      direction: DismissiblePageDismissDirection.vertical,
      isFullScreen: true,
      disabled: false,
      child: GestureDetector(
        onDoubleTapDown: (details) => _lastOffset = details.localPosition,
        onDoubleTap: () {
          // If zoomed in, zoom out.
          if (_transformCtrl.value.getMaxScaleOnAxis() > 1) {
            _animateMatrixTo(Matrix4.identity());
            return;
          }

          // Can't be null, but checking just in case.
          if (_lastOffset == null) return;

          // If zoomed out, zoom in towards the tapped spot.
          final zoomed = _transformCtrl.value.clone();
          zoomed.translate(-_lastOffset!.dx, -_lastOffset!.dy, 0);
          zoomed.scale(2.0, 2.0, 1.0);
          _animateMatrixTo(zoomed);
        },
        child: Hero(
          tag: widget.tag,
          child: InteractiveViewer(
            //clipBehavior: Clip.none,
            transformationController: _transformCtrl,
            child: CachedImage(
              widget.imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
