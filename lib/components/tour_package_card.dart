import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tour_model.dart';
import '../utils/animations.dart';
import '../utils/constants.dart';

class TourPackageCard extends StatelessWidget {
  final TourPackage tour;
  final VoidCallback onTap;

  const TourPackageCard({
    super.key,
    required this.tour,
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
              color: AppConstants.warmAccent.withValues(alpha: 0.12),
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
            tag: 'tour-${tour.id}',
            child: tour.imageUrl.startsWith('assets/')
                ? Image.asset(
                    tour.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.tour_rounded, size: 50, color: Colors.grey),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: tour.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: WaveLoader(
                          color: AppConstants.warmAccent,
                          dotSize: 8,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.tour_rounded, size: 50, color: Colors.grey),
                    ),
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55],
              ),
            ),
          ),
          // Multi-City badge with animated border
          Positioned(
            top: 12,
            left: 12,
            child: FloatingAnimation(
              offset: 3,
              duration: const Duration(seconds: 3),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7043), Color(0xFFFFAB40)],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.warmAccent.withValues(alpha: 0.45),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.airline_stops_rounded,
                        size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Multi-City',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Rating
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                    tour.rating.toString(),
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
          // Price pill with glow
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
                  'Rs. ${tour.price.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          // Tour name overlay
          Positioned(
            left: 14,
            bottom: 14,
            child: SizedBox(
              width: 200,
              child: Text(
                tour.name,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                  color: AppConstants.warmAccent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_today_rounded,
                    size: 13, color: AppConstants.warmAccent),
              ),
              const SizedBox(width: 8),
              Text(
                tour.duration,
                style: GoogleFonts.poppins(
                  color: AppConstants.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.wb_sunny_rounded,
                    size: 13, color: AppConstants.accentColor),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  tour.bestSeason,
                  style: GoogleFonts.poppins(
                    color: AppConstants.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tour.description,
            style: GoogleFonts.poppins(
              color: AppConstants.lightTextColor,
              fontSize: 12,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Route chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.primarySoft,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConstants.primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.route_rounded,
                    size: 14, color: AppConstants.primaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tour.destinations.join(' → '),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.primaryDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tour.highlights.take(3).map((highlight) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.successColor.withValues(alpha: 0.15),
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppConstants.successColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  highlight,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1B5E20),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
