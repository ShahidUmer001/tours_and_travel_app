import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/destination_model.dart';
import '../widgets/custom_button.dart';
import 'hotel_selection_screen.dart';

class DestinationScreen extends StatefulWidget {
  final Destination destination;

  const DestinationScreen({Key? key, required this.destination}) : super(key: key);

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.destination.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Image with Collage
            _buildImageCollage(),

            // Destination Details
            Padding(
              padding: const EdgeInsets.all(20),
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
                  const SizedBox(height: 20),

                  // Duration and Best Season
                  Row(
                    children: [
                      _buildInfoCard('Duration', widget.destination.duration, Icons.access_time),
                      const SizedBox(width: 12),
                      _buildInfoCard('Best Season', widget.destination.bestSeason, Icons.calendar_today),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Description
                  const Text(
                    'About Destination',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

                  // Photo Gallery
                  _buildPhotoGallery(),

                  const SizedBox(height: 25),

                  // Highlights
                  const Text(
                    'Highlights',
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

                  const SizedBox(height: 40),

                  // Book Now Button
                  CustomButton(
                    text: 'Book Now - Rs. ${widget.destination.price.toStringAsFixed(0)}',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HotelSelectionScreen(
                            destination: widget.destination,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCollage() {
    // ✅ FIXED WORKING PAKISTAN DESTINATION IMAGES
    Map<String, List<String>> destinationCollageImages = {
      'Hunza Valley': [
        'https://images.unsplash.com/photo-1565955887216-6a6c48f8747c?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1599982890795-64e3b4c33d07?ixlib=rb-4.0.3&w=1000&q=80',
      ],
      'Skardu & Shangrila': [
        'https://images.unsplash.com/photo-1559666647-1c355f4b8eb4?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1592210459276-38a175f6e4c9?ixlib=rb-4.0.3&w=1000&q=80',
      ],
      'Fairy Meadows': [
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1592210459276-38a175f6e4c9?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1559666647-1c355f4b8eb4?ixlib=rb-4.0.3&w=1000&q=80',
      ],
      'Swat Valley': [
        'https://images.unsplash.com/photo-1592210459276-38a175f6e4c9?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1559666647-1c355f4b8eb4?ixlib=rb-4.0.3&w=1000&q=80',
      ],
      'Naran & Kaghan': [
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1592210459276-38a175f6e4c9?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1559666647-1c355f4b8eb4?ixlib=rb-4.0.3&w=1000&q=80',
      ],
    };

    List<String> images = destinationCollageImages[widget.destination.name] ??
        destinationCollageImages['Hunza Valley']!;

    return Container(
      height: 350,
      child: Stack(
        children: [
          // Main Background Image
          CachedNetworkImage(
            imageUrl: images[0],
            imageBuilder: (context, imageProvider) => Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            placeholder: (context, url) => Container(
              color: Colors.grey[300],
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.landscape, size: 60, color: Colors.grey[500]),
                  SizedBox(height: 10),
                  Text(
                    widget.destination.name,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Small Collage Images
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                // Top small image
                Container(
                  width: 80,
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(images[1]),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                // Bottom small image
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(images[2]),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Rating Badge
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Price
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Rs. ${widget.destination.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery() {
    // ✅ FIXED WORKING PAKISTAN DESTINATION IMAGES
    Map<String, List<String>> destinationPhotos = {
      'Hunza Valley': [
        'https://images.unsplash.com/photo-1599982890795-64e3b4c33d07?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1592210459276-38a175f6e4c9?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1559666647-1c355f4b8eb4?ixlib=rb-4.0.3&w=1000&q=80',
      ],
      'Skardu & Shangrila': [
        'https://images.unsplash.com/photo-1559666647-1c355f4b8eb4?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1592210459276-38a175f6e4c9?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1559666647-1c355f4b8eb4?ixlib=rb-4.0.3&w=1000&q=80',
      ],
      'Fairy Meadows': [
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1592210459276-38a175f6e4c9?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1559666647-1c355f4b8eb4?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&w=1000&q=80',
      ],
      'Swat Valley': [
        'https://images.unsplash.com/photo-1592210459276-38a175f6e4c9?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1559666647-1c355f4b8eb4?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&w=1000&q=80',
      ],
      'Naran & Kaghan': [
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1592210459276-38a175f6e4c9?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1559666647-1c355f4b8eb4?ixlib=rb-4.0.3&w=1000&q=80',
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&w=1000&q=80',
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
                margin: EdgeInsets.only(right: index == photos.length - 1 ? 0 : 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(photos[index]),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
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
            ),
          ],
        ),
      ),
    );
  }
}