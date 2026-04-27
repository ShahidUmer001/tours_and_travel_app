import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/destination_model.dart';
import '../utils/animations.dart';
import '../utils/constants.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      scaleDown: 0.98,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              _buildInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        children: [
          Hero(
            tag: 'dest-${destination.id}',
            child: destination.imageUrl.startsWith('assets/')
                ? Image.asset(
                    destination.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_rounded, size: 50, color: Colors.grey),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: destination.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: WaveLoader(
                          color: AppConstants.primaryColor,
                          dotSize: 8,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_rounded, size: 50, color: Colors.grey),
                    ),
                  ),
          ),
          // Top-bottom gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.6],
              ),
            ),
          ),
          // Rating badge (top-right)
          Positioned(
            top: 12,
            right: 12,
            child: FloatingAnimation(
              offset: 3,
              duration: const Duration(seconds: 3),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppConstants.goldAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      destination.rating.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Price badge (bottom-right)
          Positioned(
            bottom: 12,
            right: 12,
            child: GlowPulse(
              glowColor: AppConstants.successColor,
              maxRadius: 18,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Rs. ${destination.price.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          // Destination title overlay
          Positioned(
            left: 14,
            bottom: 14,
            child: Text(
              destination.name,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on_rounded,
                    size: 14, color: AppConstants.primaryColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  destination.location,
                  style: GoogleFonts.poppins(
                    color: AppConstants.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            destination.description,
            style: GoogleFonts.poppins(
              color: AppConstants.lightTextColor,
              fontSize: 12,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (destination.highlights.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: destination.highlights.take(3).map((highlight) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.primarySoft,
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppConstants.primaryColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    highlight,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.primaryDark,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
