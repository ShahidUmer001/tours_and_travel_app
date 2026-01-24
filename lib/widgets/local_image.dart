import 'package:flutter/material.dart';

class LocalImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showPlaceholder;
  final Duration fadeInDuration;
  final FilterQuality filterQuality;

  const LocalImage({
    Key? key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.placeholder,
    this.errorWidget,
    this.showPlaceholder = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.filterQuality = FilterQuality.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        color: color,
        alignment: alignment,
        repeat: repeat,
        filterQuality: filterQuality,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultErrorWidget();
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }

          if (showPlaceholder && frame == null) {
            return placeholder ?? _buildPlaceholder();
          }

          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: fadeInDuration,
            curve: Curves.easeIn,
            child: child,
          );
        },
      );
    } catch (e) {
      return errorWidget ?? _buildDefaultErrorWidget();
    }
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
            Icons.image_not_supported_outlined,
            color: Colors.grey[400],
            size: width != null ? (width! * 0.3).clamp(24, 48) : 40,
          ),
          if (height != null && height! > 80) ...[
            const SizedBox(height: 8),
            Text(
              'Image not found',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            if (path.length > 30) ...[
              const SizedBox(height: 4),
              Text(
                path.split('/').last,
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

  // Factory constructor for common use cases
  factory LocalImage.circular({
    required String path,
    required double size,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return LocalImage(
      path: path,
      width: size,
      height: size,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget ?? _buildCircularErrorWidget(size),
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

  // Factory constructor for network fallback
  factory LocalImage.withNetworkFallback({
    required String localPath,
    required String networkUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return LocalImage(
      path: localPath,
      width: width,
      height: height,
      fit: fit,
      errorWidget: Image.network(
        networkUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey[400],
              size: 40,
            ),
          );
        },
      ),
    );
  }
}

// Example usage:
/*
// Basic usage
LocalImage(
  path: 'assets/images/destinations/Hunza_1.jpg',
  width: 200,
  height: 150,
  fit: BoxFit.cover,
)

// Circular profile image
LocalImage.circular(
  path: 'assets/images/profile/user.jpg',
  size: 100,
)

// With network fallback
LocalImage.withNetworkFallback(
  localPath: 'assets/images/hotels/marriott.jpg',
  networkUrl: 'https://example.com/hotel.jpg',
  width: 300,
  height: 200,
)
*/