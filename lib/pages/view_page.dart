import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/post_model.dart';
import '../models/profile_model.dart';
import '../models/social_model.dart';
import '../utils/color_palette.dart';
import '../utils/icon_helper.dart';
import '../utils/url_data_helper.dart';
import '../widgets/post_preview_card.dart';

class ViewPage extends StatelessWidget {
  final String? encoded;

  const ViewPage({super.key, this.encoded});

  @override
  Widget build(BuildContext context) {
    final data = UrlDataHelper.decode(encoded);

    if (data == null) {
      return Scaffold(
        body: Container(
          color: ColorPalette.getDefaultColor(),
          child: const Center(
            child: Text(
              'Invalid or missing data in URL.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    final profile = ProfileModel.fromJson(data['profile']);
    final socials =
        (data['socials'] as List?)
            ?.map((s) => SocialModel.fromJson(s))
            .toList() ??
        [];
    final posts =
        (data['posts'] as List?)?.map((p) => PostModel.fromJson(p)).toList() ??
        [];

    // Get page color
    final pageColor =
        ColorPalette.getColorByValue(profile.pageColor) ??
        ColorPalette.getDefaultColor();

    // Helper function to get card color with page color theme
    Color getCardColor() {
      // Mix page color with white (85% white, 15% page color) for subtle theming
      return Color.fromRGBO(
        (255 * 0.85 + pageColor.red * 0.15).round().clamp(0, 255),
        (255 * 0.85 + pageColor.green * 0.15).round().clamp(0, 255),
        (255 * 0.85 + pageColor.blue * 0.15).round().clamp(0, 255),
        1.0,
      );
    }

    final cardColor = getCardColor();

    // Filter enabled items and sort by order
    final enabledSocials = socials.where((s) => s.enabled).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final enabledPosts = posts.where((p) => p.enabled).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return Scaffold(
      backgroundColor: pageColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with share button
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.share,
                        size: 22,
                        color: Colors.grey.shade700,
                      ),
                      onPressed: () {
                        final currentUrl = Uri.base.toString();
                        Share.share(currentUrl);
                      },
                      tooltip: 'Share',
                    ),
                  ],
                ),
              ),
              // Profile section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    if (profile.image != null && profile.image!.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(profile.image!),
                          onBackgroundImageError: (exception, stackTrace) {},
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white.withOpacity(0.5),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      '${profile.name} ${profile.surname}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (profile.description != null &&
                        profile.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        profile.description!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Social links section - card list
              if (enabledSocials.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: enabledSocials.asMap().entries.map((entry) {
                      final index = entry.key;
                      final social = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == enabledSocials.length - 1 ? 0 : 12,
                        ),
                        child: Material(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          elevation: 3,
                          shadowColor: Colors.black.withOpacity(0.08),
                          child: InkWell(
                            onTap: () async {
                              final uri = Uri.parse(social.url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: pageColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: IconHelper.buildIconWidget(
                                        social.iconName,
                                        size: 24,
                                        fallbackColor: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Platform name
                                  Expanded(
                                    child: Text(
                                      social.name.isNotEmpty
                                          ? social.name
                                          : 'Social Link',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 40),
              ],
              // Posts section - full width cards
              if (enabledPosts.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: enabledPosts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final post = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == enabledPosts.length - 1 ? 0 : 16,
                        ),
                        child: PostPreviewCard(
                          url: post.url,
                          text: post.text,
                          type: post.type,
                          cardColor: cardColor,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 40),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    'No posts available',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              // Footer spacing
              const SizedBox(height: 56),
            ],
          ),
        ),
      ),
    );
  }
}
