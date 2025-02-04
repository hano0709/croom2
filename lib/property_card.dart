import 'package:flutter/material.dart';

class PropertyCard extends StatelessWidget {
  final String title;
  final String price;
  final String location;
  final String imageUrl;

  PropertyCard({
    required this.title,
    required this.price,
    required this.location,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = Color(0xFF6B9080); // Same primary color
    final Color surface = Color(0xFFF8F9FA); // Same background color

    return Card(
      elevation: 4, // Consistent elevation
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Consistent spacing
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Consistent rounded corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)), // Rounded top corners
            child: imageUrl.startsWith('http') // Check if the image is a network image
                ? Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Container(
              height: 180,
              width: double.infinity,
              color: primary.withOpacity(0.1), // Fallback color
              child: Icon(
                Icons.home,
                size: 60,
                color: primary,
              ),
            ),
          ),
          // Property Details
          Padding(
            padding: const EdgeInsets.all(16), // Consistent padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8), // Consistent spacing
                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8), // Consistent spacing
                // Price
                Row(
                  children: [
                    Icon(
                      Icons.currency_rupee_rounded,
                      size: 16,
                      color: primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Price: $price',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}