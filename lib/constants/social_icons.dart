// Predefined popular social media icons - using typed icons from colorful_iconify_flutter
import 'package:colorful_iconify_flutter/icons/logos.dart';

class SocialIcons {
  /// Map of display name to icon name (for backward compatibility with storage)
  static const Map<String, String> popular = {
    'Twitter/X': 'logos:twitter',
    'Instagram': 'logos:instagram-icon',
    'Facebook': 'logos:facebook',
    'LinkedIn': 'logos:linkedin-icon',
    'YouTube': 'logos:youtube-icon',
    'TikTok': 'logos:tiktok-icon',
    'GitHub': 'logos:github-icon',
    'Snapchat': 'logos:snapchat',
    'Pinterest': 'logos:pinterest',
    'Reddit': 'logos:reddit-icon',
    'Discord': 'logos:discord-icon',
    'Telegram': 'logos:telegram',
    'WhatsApp': 'logos:whatsapp-icon',
    'Spotify': 'logos:spotify-icon',
    'Twitch': 'logos:twitch',
    'Behance': 'logos:behance',
    'Dribbble': 'logos:dribbble-icon',
    'Medium': 'logos:medium-icon',
    'Patreon': 'logos:patreon',
    'Mastodon': 'logos:mastodon-icon',
  };

  /// Map of display name to typed icon data getter functions
  /// Using Logos class directly: Iconify(Logos.whatsapp_icon)
  /// Only includes icons confirmed to exist in Logos class
  static final Map<String, Function> popularIcons = {
    'Twitter/X': () => Logos.twitter,
    'Instagram': () => Logos.instagram_icon,
    'Facebook': () => Logos.facebook,
    'LinkedIn': () => Logos.linkedin_icon,
    'YouTube': () => Logos.youtube_icon,
    'TikTok': () => Logos.tiktok_icon,
    'GitHub': () => Logos.github_icon,
    'Pinterest': () => Logos.pinterest,
    'Reddit': () => Logos.reddit_icon,
    'Discord': () => Logos.discord_icon,
    'Telegram': () => Logos.telegram,
    'WhatsApp': () => Logos.whatsapp_icon,
    'Spotify': () => Logos.spotify_icon,
    'Twitch': () => Logos.twitch,
    'Behance': () => Logos.behance,
    'Dribbble': () => Logos.dribbble_icon,
    'Medium': () => Logos.medium_icon,
    'Patreon': () => Logos.patreon,
    'Mastodon': () => Logos.mastodon_icon,
  };

  /// Get icon name string for URL (for backward compatibility)
  static String? getIconForUrl(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('twitter.com') || lowerUrl.contains('x.com')) {
      return popular['Twitter/X'];
    } else if (lowerUrl.contains('instagram.com')) {
      return popular['Instagram'];
    } else if (lowerUrl.contains('facebook.com')) {
      return popular['Facebook'];
    } else if (lowerUrl.contains('linkedin.com')) {
      return popular['LinkedIn'];
    } else if (lowerUrl.contains('youtube.com') ||
        lowerUrl.contains('youtu.be')) {
      return popular['YouTube'];
    } else if (lowerUrl.contains('tiktok.com')) {
      return popular['TikTok'];
    } else if (lowerUrl.contains('github.com')) {
      return popular['GitHub'];
    } else if (lowerUrl.contains('snapchat.com')) {
      return popular['Snapchat'];
    } else if (lowerUrl.contains('pinterest.com')) {
      return popular['Pinterest'];
    } else if (lowerUrl.contains('reddit.com')) {
      return popular['Reddit'];
    } else if (lowerUrl.contains('discord.com')) {
      return popular['Discord'];
    } else if (lowerUrl.contains('telegram.org')) {
      return popular['Telegram'];
    } else if (lowerUrl.contains('whatsapp.com')) {
      return popular['WhatsApp'];
    } else if (lowerUrl.contains('spotify.com')) {
      return popular['Spotify'];
    } else if (lowerUrl.contains('twitch.tv')) {
      return popular['Twitch'];
    } else if (lowerUrl.contains('behance.net')) {
      return popular['Behance'];
    } else if (lowerUrl.contains('dribbble.com')) {
      return popular['Dribbble'];
    } else if (lowerUrl.contains('medium.com')) {
      return popular['Medium'];
    } else if (lowerUrl.contains('patreon.com')) {
      return popular['Patreon'];
    } else if (lowerUrl.contains('mastodon')) {
      return popular['Mastodon'];
    }
    return null;
  }
}
