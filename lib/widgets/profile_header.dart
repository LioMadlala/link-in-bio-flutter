import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String surname;

  const ProfileHeader({
    super.key,
    this.imageUrl,
    required this.name,
    required this.surname,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imageUrl != null && imageUrl!.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(imageUrl!),
              onBackgroundImageError: (exception, stackTrace) {
                // Handle error silently
              },
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade300,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        const SizedBox(height: 24),
        Text(
          '$name $surname',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
