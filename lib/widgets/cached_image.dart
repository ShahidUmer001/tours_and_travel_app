import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final Alignment alignment;
  final ImageRepeat repeat;
  final FilterQuality filterQuality;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showPlaceholder;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Curve fadeInCurve;
  final Curve fadeOutCurve;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? shadow;
  final bool cache;

  const CachedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.filterQuality = FilterQuality.medium,
    this.placeholder,
    this.errorWidget,
    this.showPlaceholder = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.fadeOutDuration = const Duration(milliseconds: 300),
    this.fadeInCurve = Curves.easeIn,
    this.fadeOutCurve = Curves.easeOut,
    this.borderRadius,
    this.shadow,
    this.cache = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If URL is empty, show error widget
    if (imageUrl.isEmpty) {
      return errorWidget ?? _buildDefaultErrorWidget();
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      color: color,
      alignment: alignment,
      repeat: repeat,
      filterQuality: filterQuality,
      placeholder: (context, url) =>
      showPlaceholder ? (placeholder ?? _buildPlaceholder()) : const SizedBox(),
      errorWidget: (context, url, error) =>
      errorWidget ?? _buildDefaultErrorWidget(),
      fadeInDuration: fadeInDuration,
      fadeOutDuration: fadeOutDuration,
      fadeInCurve: fadeInCurve,
      fadeOutCurve: fadeOutCurve,
    );

    // Apply border radius if provided
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    // Apply shadow if provided
    if (shadow != null) {
      imageWidget = Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: shadow,
        ),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: Colors.grey[400],
            size: width != null ? (width! * 0.3).clamp(24, 48) : 40,
          ),
          if (height != null && height! > 80) ...[
            const SizedBox(height: 8),
            Text(
              'Failed to load image',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            if (imageUrl.length > 30) ...[
              const SizedBox(height: 4),
              Text(
                _getShortUrl(),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _getShortUrl() {
    if (imageUrl.length <= 30) return imageUrl;
    final uri = Uri.tryParse(imageUrl);
    if (uri != null) {
      return '${uri.host}${uri.path}';
    }
    return '...${imageUrl.substring(imageUrl.length - 20)}';
  }

  // Factory constructor for circular images
  factory CachedImage.circular({
    required String imageUrl,
    required double size,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    List<BoxShadow>? shadow,
    bool cache = true,
  }) {
    return CachedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget ?? _buildCircularErrorWidget(size),
      borderRadius: BorderRadius.circular(size / 2),
      shadow: shadow,
      cache: cache,
    );
  }

  static Widget _buildCircularErrorWidget(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: size * 0.5,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  // Factory constructor for profile images
  factory CachedImage.profile({
    required String imageUrl,
    required double size,
    BoxFit fit = BoxFit.cover,
    String? fallbackInitials,
    Color? backgroundColor,
    Color? textColor,
    bool cache = true,
  }) {
    return CachedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: fit,
      borderRadius: BorderRadius.circular(size / 2),
      errorWidget: _buildProfileErrorWidget(
        size: size,
        initials: fallbackInitials,
        backgroundColor: backgroundColor,
        textColor: textColor,
      ),
      cache: cache,
    );
  }

  static Widget _buildProfileErrorWidget({
    required double size,
    String? initials,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final bgColor = backgroundColor ?? Colors.blue.shade100;
    final txtColor = textColor ?? Colors.blue.shade800;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials?.substring(0, 2).toUpperCase() ?? '?',
          style: TextStyle(
            color: txtColor,
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Factory constructor for banners with shadow
  factory CachedImage.banner({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
    List<BoxShadow>? shadow,
    Widget? placeholder,
    bool cache = true,
  }) {
    return CachedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      borderRadius: borderRadius,
      shadow: shadow ?? [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      cache: cache,
    );
  }

  // Factory constructor for thumbnail images - FIXED CONST ISSUE
  factory CachedImage.thumbnail({
    required String imageUrl,
    double size = 60,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
    bool cache = true,
  }) {
    return CachedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: borderRadius,
      placeholder: Container(
        width: size,
        height: size,
        color: Colors.grey[200],
      ),
      errorWidget: Container(
        width: size,
        height: size,
        color: Colors.grey[200],
        child: Icon(
          Icons.image,
          size: size * 0.4,
          color: Colors.grey[400],
        ),
      ),
      cache: cache,
    );
  }
}