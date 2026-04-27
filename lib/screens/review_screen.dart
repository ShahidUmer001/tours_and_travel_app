import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../utils/constants.dart';
import '../utils/animations.dart';

class ReviewScreen extends StatefulWidget {
  final String? destinationName;
  final String? destinationId;

  const ReviewScreen({
    super.key,
    this.destinationName,
    this.destinationId,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with TickerProviderStateMixin {
  final TextEditingController _reviewController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  double _rating = 0;
  bool _isSubmitting = false;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                error ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor:
              error ? AppConstants.errorColor : AppConstants.successColor,
        ),
      );
  }

  void _submitReview() async {
    if (_rating == 0) {
      _showSnack('Please select a rating', error: true);
      return;
    }
    if (_reviewController.text.trim().isEmpty) {
      _showSnack('Please write a review', error: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final user = _auth.currentUser;
    try {
      await _firestore.collection('reviews').add({
        'destinationId': widget.destinationId ?? widget.destinationName ?? 'general',
        'destinationName': widget.destinationName ?? 'General',
        'userId': user?.uid ?? 'guest',
        'userName': user?.displayName ?? 'Anonymous',
        'userEmail': user?.email ?? '',
        'rating': _rating,
        'review': _reviewController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnack('Review submitted successfully!');
      _reviewController.clear();
      setState(() => _rating = 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnack('Error submitting review: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reviews',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (widget.destinationName != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.destinationName!,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWriteReviewCard(),
            const SizedBox(height: 28),
            _buildReviewsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWriteReviewCard() {
    return AnimatedFadeSlide(
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppConstants.warmGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.rate_review_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Write a Review',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Rating
            Text(
              'Your Rating',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 40,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                itemBuilder: (context, _) => const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() => _rating = rating);
                },
              ),
            ),
            if (_rating > 0) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _getRatingText(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Review text
            TextField(
              controller: _reviewController,
              maxLines: 4,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                hintStyle: GoogleFonts.poppins(
                  color: AppConstants.lightTextColor,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFFF4F6FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                      color: AppConstants.primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),

            // Submit button
            LiquidButton(
              label: _isSubmitting ? 'SUBMITTING...' : 'SUBMIT REVIEW',
              icon: Icons.send_rounded,
              isLoading: _isSubmitting,
              onPressed: _submitReview,
              colors: const [Color(0xFFFF7043), Color(0xFFFFAB40)],
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText() {
    if (_rating >= 5) return 'Excellent!';
    if (_rating >= 4) return 'Very Good!';
    if (_rating >= 3) return 'Good';
    if (_rating >= 2) return 'Fair';
    return 'Poor';
  }

  Widget _buildReviewsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: AppConstants.primaryGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Recent Reviews',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppConstants.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('reviews')
              .where('destinationId',
                  isEqualTo: widget.destinationId ??
                      widget.destinationName ??
                      'general')
              .orderBy('timestamp', descending: true)
              .limit(20)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ));
            }

            if (snapshot.hasError) {
              return _buildStaticReviews();
            }

            final reviews = snapshot.data?.docs ?? [];

            if (reviews.isEmpty) {
              return _buildStaticReviews();
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final data = reviews[index].data() as Map<String, dynamic>;
                return _buildReviewCard(
                  name: data['userName'] ?? 'Anonymous',
                  rating: (data['rating'] ?? 0).toDouble(),
                  review: data['review'] ?? '',
                  date: data['timestamp'] != null
                      ? (data['timestamp'] as Timestamp)
                          .toDate()
                          .toString()
                          .substring(0, 10)
                      : 'Recently',
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStaticReviews() {
    final reviews = [
      {
        'name': 'Ahmed Khan',
        'rating': 5.0,
        'review': 'Amazing experience! The scenery was breathtaking and the tour was well organized. Highly recommended!',
        'date': '2025-12-15',
      },
      {
        'name': 'Sara Ali',
        'rating': 4.5,
        'review': 'Beautiful destination with great hospitality. The guide was very knowledgeable and helpful.',
        'date': '2025-12-10',
      },
      {
        'name': 'Usman Malik',
        'rating': 4.0,
        'review': 'Good trip overall. Weather was pleasant and the food was delicious. Will visit again!',
        'date': '2025-12-05',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final r = reviews[index];
        return _buildReviewCard(
          name: r['name'] as String,
          rating: r['rating'] as double,
          review: r['review'] as String,
          date: r['date'] as String,
        );
      },
    );
  }

  Widget _buildReviewCard({
    required String name,
    required double rating,
    required String review,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppConstants.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textColor,
                      ),
                    ),
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppConstants.lightTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppConstants.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
