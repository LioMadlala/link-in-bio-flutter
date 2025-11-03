class PostModel {
  final String type;
  final String? text;
  final String? url;
  final int order;
  final Map<String, dynamic>? previewMetadata;

  PostModel({
    required this.type,
    this.text,
    this.url,
    this.order = 0,
    this.previewMetadata,
  });

  Map<String, dynamic> toJson({bool optimizeForUrl = false}) {
    final json = <String, dynamic>{};

    if (optimizeForUrl) {
      // Use single character type code
      json['t'] = _getTypeCode(type);
    } else {
      json['type'] = type;
    }

    // Only include non-null, non-empty optional fields
    if (text != null && text!.isNotEmpty) {
      if (optimizeForUrl) {
        json['tx'] = text;
      } else {
        json['text'] = text;
      }
    }
    if (url != null && url!.isNotEmpty) {
      if (optimizeForUrl) {
        json['u'] = url;
      } else {
        json['url'] = url;
      }
    }

    // Order is omitted - will be inferred from array index
    // Note: previewMetadata is never serialized to keep URL short

    return json;
  }

  String _getTypeCode(String type) {
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

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Handle both optimized (short keys) and non-optimized formats
    String type;
    if (json.containsKey('t')) {
      // Optimized format - decode type code
      type = _decodeTypeCode(json['t']);
    } else {
      type = json['type'] ?? 'link';
    }

    String? text = json['tx'] ?? json['text'];
    String? url = json['u'] ?? json['url'];
    int order = json['o'] ?? json['order'] ?? 0;

    return PostModel(
      type: type,
      text: text,
      url: url,
      order: order,
    );
  }

  static String _decodeTypeCode(dynamic code) {
    final codeStr = code?.toString().toLowerCase() ?? 'l';
    switch (codeStr) {
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

  PostModel copyWith({
    String? type,
    String? text,
    String? url,
    int? order,
    Map<String, dynamic>? previewMetadata,
  }) {
    return PostModel(
      type: type ?? this.type,
      text: text ?? this.text,
      url: url ?? this.url,
      order: order ?? this.order,
      previewMetadata: previewMetadata ?? this.previewMetadata,
    );
  }
}
