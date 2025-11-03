import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

class PreviewMetadata {
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? siteName;
  final String? url;

  PreviewMetadata({
    this.title,
    this.description,
    this.imageUrl,
    this.siteName,
    this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'siteName': siteName,
      'url': url,
    };
  }

  factory PreviewMetadata.fromJson(Map<String, dynamic> json) {
    return PreviewMetadata(
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      siteName: json['siteName'],
      url: json['url'],
    );
  }
}

class PreviewFetcher {
  // User agent to avoid bot blocking
  static const String _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  static Future<PreviewMetadata?> fetchMetadata(String url) async {
    try {
      // Ensure URL has protocol
      String fullUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        fullUrl = 'https://$url';
      }

      final uri = Uri.tryParse(fullUrl);
      if (uri == null) return null;

      // For YouTube - use direct thumbnail API (faster)
      if (uri.host.contains('youtube.com') || uri.host.contains('youtu.be')) {
        return _extractYouTubePreview(uri);
      }

      // For all other URLs (including TikTok, Twitter, etc.), fetch Open Graph metadata
      return await _fetchOpenGraphMetadata(uri, fullUrl);
    } catch (e) {
      // Return null on any error
      return null;
    }
  }

  static Future<PreviewMetadata?> _fetchOpenGraphMetadata(
      Uri uri, String fullUrl) async {
    try {
      // Fetch HTML with proper user agent
      final response = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Timeout'),
          );

      if (response.statusCode != 200) return null;

      final document = html_parser.parse(response.body);

      // Extract Open Graph tags (preferred)
      String? title =
          document
              .querySelector('meta[property="og:title"]')
              ?.attributes['content'] ??
          document
              .querySelector('meta[name="twitter:title"]')
              ?.attributes['content'] ??
          document.querySelector('title')?.text;

      String? description =
          document
              .querySelector('meta[property="og:description"]')
              ?.attributes['content'] ??
          document
              .querySelector('meta[name="twitter:description"]')
              ?.attributes['content'] ??
          document
              .querySelector('meta[name="description"]')
              ?.attributes['content'];

      // Try multiple image sources
      String? imageUrl =
          document
              .querySelector('meta[property="og:image"]')
              ?.attributes['content'] ??
          document
              .querySelector('meta[name="twitter:image"]')
              ?.attributes['content'] ??
          document
              .querySelector('meta[name="twitter:image:src"]')
              ?.attributes['content'];

      // If no OG image, try to find first image in HTML
      if (imageUrl == null || imageUrl.isEmpty) {
        final imgElement = document.querySelector('img');
        imageUrl = imgElement?.attributes['src'];
      }

      String? siteName =
          document
              .querySelector('meta[property="og:site_name"]')
              ?.attributes['content'] ??
          _extractSiteNameFromHost(uri.host);

      // Clean up image URLs (handle relative URLs)
      if (imageUrl != null && imageUrl.isNotEmpty) {
        imageUrl = imageUrl.trim();
        // Remove query parameters from image URL if it's a data URL or if it looks like it has tracking params
        if (imageUrl.startsWith('data:')) {
          // Keep data URLs as-is
        } else if (!imageUrl.startsWith('http://') &&
            !imageUrl.startsWith('https://')) {
          // Resolve relative URLs
          imageUrl = uri.resolve(imageUrl).toString();
        }
        // Clean up common image CDN URLs
        if (imageUrl.contains('?')) {
          // Remove some tracking parameters but keep important ones
          final uriImg = Uri.tryParse(imageUrl);
          if (uriImg != null) {
            final cleanParams = Map<String, String>.from(uriImg.queryParameters);
            cleanParams.removeWhere((key, value) =>
                key.toLowerCase().contains('utm_') ||
                key.toLowerCase().contains('ref') ||
                key.toLowerCase().contains('tracking'));
            final cleanUri = uriImg.replace(queryParameters: cleanParams);
            imageUrl = cleanUri.toString();
          }
        }
      }

      return PreviewMetadata(
        title: title?.trim(),
        description: description?.trim(),
        imageUrl: imageUrl,
        siteName: siteName,
        url: fullUrl,
      );
    } catch (e) {
      // Return null on any error
      return null;
    }
  }

  static String? _extractSiteNameFromHost(String host) {
    // Extract clean site name from host
    final cleanHost = host
        .replaceFirst('www.', '')
        .replaceFirst('m.', '')
        .split('.')
        .first;
    if (cleanHost.isNotEmpty) {
      return cleanHost.substring(0, 1).toUpperCase() +
          cleanHost.substring(1).toLowerCase();
    }
    return null;
  }

  static PreviewMetadata _extractYouTubePreview(Uri uri) {
    String? videoId;
    if (uri.host.contains('youtu.be')) {
      videoId = uri.path.substring(1);
    } else {
      videoId = uri.queryParameters['v'];
    }

    if (videoId == null) {
      return PreviewMetadata(url: uri.toString());
    }

    // YouTube thumbnail
    final thumbnailUrl =
        'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

    return PreviewMetadata(
      title: 'YouTube Video',
      imageUrl: thumbnailUrl,
      siteName: 'YouTube',
      url: uri.toString(),
    );
  }

}
