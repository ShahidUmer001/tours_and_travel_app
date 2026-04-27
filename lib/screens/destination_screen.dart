import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/destination_model.dart';
import '../utils/animations.dart';
import '../utils/constants.dart';
import 'hotel_selection_screen.dart';

class DestinationScreen extends StatefulWidget {
  final Destination destination;

  const DestinationScreen({super.key, required this.destination});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen>
    with TickerProviderStateMixin {
  late AnimationController _contentController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            _buildHeroImage(),

            // Destination Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StaggeredListItem(
                    index: 0,
                    animation: _contentController,
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.destination.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.blue[700], size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  widget.destination.location,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              widget.destination.rating.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Info Cards
                  StaggeredListItem(
                    index: 1,
                    animation: _contentController,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            Icons.access_time,
                            'Duration',
                            widget.destination.duration,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            Icons.calendar_today,
                            'Best Season',
                            widget.destination.bestSeason,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            Icons.attach_money,
                            'Price',
                            'Rs. ${widget.destination.price.toStringAsFixed(0)}',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Description
                  StaggeredListItem(
                    index: 2,
                    animation: _contentController,
                    child: const Text(
                      'About Destination',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.destination.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Highlights
                  const Text(
                    'Key Highlights',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: widget.destination.highlights.map((highlight) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue[100]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.blue[700], size: 16),
                            const SizedBox(width: 6),
                            Text(
                              highlight,
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 25),

                  // Photo Gallery
                  _buildPhotoGallery(),

                  const SizedBox(height: 40),

                  // Book Now Button
                  StaggeredListItem(
                    index: 6,
                    animation: _contentController,
                    child: PulseAnimation(
                      child: Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: AppConstants.primaryGradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.primaryColor.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransitions.fadeSlide(
                                  HotelSelectionScreen(destination: widget.destination),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.book_online, color: Colors.white),
                                const SizedBox(width: 10),
                                Text(
                                  'Book Now - Rs. ${widget.destination.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    final parallaxOffset = (_scrollOffset * 0.4).clamp(0.0, 200.0);
    return Stack(
      children: [
        Transform.translate(
          offset: Offset(0, -parallaxOffset),
          child: Hero(
            tag: 'destination_${widget.destination.id}',
            child: SizedBox(
              height: 340,
              width: double.infinity,
              child: widget.destination.imageUrl.startsWith('assets/')
                  ? Image.asset(
                      widget.destination.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.landscape, size: 100, color: Colors.grey),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: widget.destination.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.landscape, size: 100, color: Colors.grey),
                      ),
                    ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              height: 340,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.blue[700]),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery() {
    // Real local photos of each destination
    Map<String, List<String>> destinationPhotos = {
      'Hunza Valley': [
        'assets/images/destinations/Hunza_1.jpg',
        'assets/images/destinations/Hunza_2.jpg',
        'assets/images/destinations/Hunza_3.jpg',
        'assets/images/destinations/Hunza_4.jpg',
      ],
      'Skardu & Shangrila': [
        'assets/images/destinations/Skardu_&_Shangrila_1.jpg',
        'assets/images/destinations/Skardu_2.jpg',
        'assets/images/destinations/Skardu_3.jpg',
        'assets/images/destinations/Skardu_4.jpg',
      ],
      'Swat Valley': [
        'assets/images/destinations/Swat_Valley_1.jpg',
        'assets/images/destinations/Swat_Valley_2.jpg',
        'assets/images/destinations/Swat_Valley_3.jpg',
      ],
      'Naran & Kaghan': [
        'assets/images/destinations/Naran_&_Kaghan_1.jpeg',
        'assets/images/destinations/Naran_2.jpg',
        'assets/images/destinations/Naran_3.jpg',
        'assets/images/destinations/Naran_4.jpg',
      ],
      'Fairy Meadows': [
        'assets/images/destinations/Fairy_Meadows_1.jpg',
        'assets/images/destinations/Fairy_Meadows_2.jpg',
        'assets/images/destinations/Fairy_Meadows_3.jpg',
      ],
    };

    List<String> photos = destinationPhotos[widget.destination.name] ??
        destinationPhotos['Hunza Valley']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photo Gallery',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                height: 120,
                margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    photos[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}