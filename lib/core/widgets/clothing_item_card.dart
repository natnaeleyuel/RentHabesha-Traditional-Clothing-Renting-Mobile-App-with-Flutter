import 'package:flutter/material.dart';

class ClothingItemCard extends StatelessWidget {
  final String? imagePath;
  final String title;
  final String price;
  final String clothingId;
  final String ownerId;
  final VoidCallback? onTap;

  const ClothingItemCard({
    Key? key,
    this.imagePath,
    required this.title,
    required this.price,
    required this.clothingId,
    required this.ownerId,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      child: SizedBox(
        width: double.infinity,
        child: imagePath != null
            ? Image.network(
          imagePath!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 150,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 150, // Match the same height
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 50),
      ),
    );
  }
}

