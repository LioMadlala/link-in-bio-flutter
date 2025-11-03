import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:colorful_iconify_flutter/icons/logos.dart';

/// Helper to convert icon name strings to typed icons from colorful_iconify_flutter
/// Uses typed icons when available (Iconify(Logos.whatsapp_icon)), falls back to string-based for compatibility
class IconHelper {
  /// Map of icon name string to typed icon data
  /// Using Logos class directly as shown in user example: Iconify(Logos.whatsapp_icon)
  /// Note: Only including confirmed available icons; others will fall back to string-based iconify
  static final Map<String, dynamic> _iconMap = {
    // Core social icons - using typed Logos icons
    'logos:twitter': () => Logos.twitter,
    'logos:instagram-icon': () => Logos.instagram_icon,
    'logos:facebook': () => Logos.facebook,
    'logos:linkedin-icon': () => Logos.linkedin_icon,
    'logos:youtube-icon': () => Logos.youtube_icon,
    'logos:tiktok-icon': () => Logos.tiktok_icon,
    'logos:github-icon': () => Logos.github_icon,
    'logos:pinterest': () => Logos.pinterest,
    'logos:reddit-icon': () => Logos.reddit_icon,
    'logos:discord-icon': () => Logos.discord_icon,
    'logos:telegram': () => Logos.telegram,
    'logos:whatsapp-icon': () => Logos.whatsapp_icon,
    'logos:spotify-icon': () => Logos.spotify_icon,
    'logos:twitch': () => Logos.twitch,
    'logos:behance': () => Logos.behance,
    'logos:dribbble-icon': () => Logos.dribbble_icon,
    'logos:medium-icon': () => Logos.medium_icon,
    'logos:patreon': () => Logos.patreon,
    'logos:mastodon-icon': () => Logos.mastodon_icon,
  };

  /// Get typed icon data from icon name string
  static dynamic getTypedIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) return null;
    final iconGetter = _iconMap[iconName];
    if (iconGetter != null) {
      try {
        return (iconGetter as Function)();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Build Iconify widget with typed icon or fallback to string-based iconify
  /// Icons display in their natural colors (no color filter applied)
  static Widget buildIconWidget(
    String? iconName, {
    double size = 24,
    Color? fallbackColor,
  }) {
    if (iconName == null || iconName.isEmpty) {
      return Icon(
        Icons.link,
        size: size,
        color: fallbackColor ?? Colors.grey.shade600,
      );
    }

    // Try to use typed icon first - no color filter, let icons use natural colors
    final typedIcon = getTypedIcon(iconName);
    if (typedIcon != null) {
      return Iconify(
        typedIcon,
        size: size,
      );
    }

    // Fallback to string-based iconify for custom icons - no color filter
    try {
      return Iconify(
        iconName,
        size: size,
      );
    } catch (e) {
      return Icon(
        Icons.link,
        size: size,
        color: fallbackColor ?? Colors.grey.shade600,
      );
    }
  }
}
