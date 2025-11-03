import 'dart:convert';

class UrlDataHelper {
  // Optimize data structure with short keys before encoding
  // Aggressively filters out nulls, empty strings, and default values
  static Map<String, dynamic> _optimizeData(Map<String, dynamic> data) {
    final optimized = <String, dynamic>{};

    // Profile: use 'p' instead of 'profile'
    if (data.containsKey('profile')) {
      final p = data['profile'] as Map<String, dynamic>;
      final profileOpt = <String, dynamic>{
        'n': p['name'], // name (required)
        's': p['surname'], // surname (required)
      };
      
      // Only include non-null, non-empty optional fields
      if (p['image'] != null && (p['image'] as String).isNotEmpty) {
        profileOpt['i'] = p['image'];
      }
      if (p['description'] != null && (p['description'] as String).isNotEmpty) {
        profileOpt['d'] = p['description']; // description
      }
      if (p['pageColor'] != null && (p['pageColor'] as String).isNotEmpty) {
        profileOpt['c'] = p['pageColor'];
      }
      
      optimized['p'] = profileOpt;
    }

    // Socials: use 's' instead of 'socials'
    // Order is inferred from array index, enabled=true is omitted
    if (data.containsKey('socials')) {
      final socials = data['socials'] as List;
      optimized['s'] = socials.map((item) {
        final soc = item as Map<String, dynamic>;
        final socialOpt = <String, dynamic>{
          'n': soc['name'], // name (required)
          'u': soc['url'], // url (required)
        };
        
        // Only include non-null, non-empty optional fields
        if (soc['iconName'] != null && (soc['iconName'] as String).isNotEmpty) {
          socialOpt['i'] = soc['iconName'];
        }
        // Only include enabled if false (default is true)
        if (soc['enabled'] == false) {
          socialOpt['e'] = false;
        }
        // Order is omitted - inferred from array index
        
        return socialOpt;
      }).toList();
    }

    // Posts: use 'ps' instead of 'posts'
    // Use single char type codes, order inferred from array index, enabled=true omitted
    if (data.containsKey('posts')) {
      final posts = data['posts'] as List;
      optimized['ps'] = posts.map((item) {
        final post = item as Map<String, dynamic>;
        final postOpt = <String, dynamic>{};
        
        // Type: use single char code
        final type = post['type'] ?? 'link';
        postOpt['t'] = _getTypeCode(type);
        
        // Only include non-null, non-empty optional fields
        if (post['text'] != null && (post['text'] as String).isNotEmpty) {
          postOpt['tx'] = post['text'];
        }
        if (post['url'] != null && (post['url'] as String).isNotEmpty) {
          postOpt['u'] = post['url'];
        }
        
        // Only include enabled if false (default is true)
        if (post['enabled'] == false) {
          postOpt['e'] = false;
        }
        // Order is omitted - inferred from array index
        
        return postOpt;
      }).toList();
    }

    return optimized;
  }
  
  // Get single character post type code
  static String _getTypeCode(String type) {
    switch (type.toLowerCase()) {
      case 'note':
      case 'text':
        return 'n';
      case 'youtube':
        return 'y';
      case 'tiktok':
        return 't';
      case 'twitter':
        return 'x';
      case 'link':
      default:
        return 'l';
    }
  }
  
  // Decode single character post type code
  static String _decodeTypeCode(String code) {
    switch (code.toLowerCase()) {
      case 'n':
        return 'note';
      case 'y':
        return 'youtube';
      case 't':
        return 'tiktok';
      case 'x':
        return 'twitter';
      case 'l':
      default:
        return 'link';
    }
  }

  // Restore full structure after decoding
  // Handles both optimized format (with defaults) and old format (backward compatibility)
  static Map<String, dynamic> _restoreData(Map<String, dynamic> optimized) {
    final restored = <String, dynamic>{};

    if (optimized.containsKey('p')) {
      final p = optimized['p'] as Map<String, dynamic>;
      restored['profile'] = {
        'name': p['n'] ?? '',
        'surname': p['s'] ?? '',
        'image': p['i'],
        'description': p['d'],
        'pageColor': p['c'],
      };
    }

    if (optimized.containsKey('s')) {
      final socials = optimized['s'] as List;
      restored['socials'] = socials.asMap().entries.map((entry) {
        final index = entry.key;
        final soc = entry.value as Map<String, dynamic>;
        return {
          'name': soc['n'] ?? '',
          'url': soc['u'] ?? '',
          'iconName': soc['i'],
          'enabled': soc['e'] ?? true, // Default is true
          'order': index, // Order is inferred from array index
        };
      }).toList();
    }

    if (optimized.containsKey('ps')) {
      final posts = optimized['ps'] as List;
      restored['posts'] = posts.asMap().entries.map((entry) {
        final index = entry.key;
        final post = entry.value as Map<String, dynamic>;
        return {
          'type': _decodeTypeCode(post['t']?.toString() ?? 'l'),
          'text': post['tx'],
          'url': post['u'],
          'enabled': post['e'] ?? true, // Default is true
          'order': index, // Order is inferred from array index
        };
      }).toList();
    }

    return restored;
  }

  static String encode(Map<String, dynamic> data) {
    // Optimize data structure with short keys
    final optimized = _optimizeData(data);

    // Convert to JSON
    final jsonStr = jsonEncode(optimized);
    final bytes = utf8.encode(jsonStr);

    // Try to compress (skip compression on web for compatibility)
    // JSON key optimization alone significantly reduces size
    List<int> compressed;
    try {
      // Only compress if we have access to zlib (not on web)
      compressed = bytes; // For now, skip compression for web compatibility
      // In a real implementation, you'd use conditional compilation
      // or a compression package that works on all platforms
    } catch (e) {
      compressed = bytes;
    }

    // Base64URL encode for URL safety
    return base64Url.encode(compressed);
  }

  static Map<String, dynamic>? decode(String? encoded) {
    if (encoded == null || encoded.isEmpty) return null;
    try {
      // Base64URL decode
      final compressed = base64Url.decode(encoded);

      // Decompress (skip for now - compression disabled for web compatibility)
      final bytes = compressed;

      // Decode JSON
      final optimized = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;

      // Restore full structure
      return _restoreData(optimized);
    } catch (e) {
      // Fallback: try old format (non-compressed)
      try {
        final bytes = base64Url.decode(encoded);
        final data = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
        // If it's already in old format, return as-is
        if (data.containsKey('profile') ||
            data.containsKey('socials') ||
            data.containsKey('posts')) {
          return data;
        }
        return _restoreData(data);
      } catch (e2) {
        return null;
      }
    }
  }
}
