class SocialModel {
  final String name;
  final String url;
  final String? iconName;
  final bool enabled;
  final int order;

  SocialModel({
    required this.name,
    required this.url,
    this.iconName,
    this.enabled = true,
    this.order = 0,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'url': url,
    };
    // Only include non-null, non-empty optional fields
    if (iconName != null && iconName!.isNotEmpty) {
      json['iconName'] = iconName;
    }
    // Only include enabled if false (default is true)
    if (!enabled) {
      json['enabled'] = false;
    }
    // Order is omitted - will be inferred from array index
    return json;
  }

  factory SocialModel.fromJson(Map<String, dynamic> json) {
    return SocialModel(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      iconName: json['iconName'],
      enabled: json['enabled'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  SocialModel copyWith({
    String? name,
    String? url,
    String? iconName,
    bool? enabled,
    int? order,
  }) {
    return SocialModel(
      name: name ?? this.name,
      url: url ?? this.url,
      iconName: iconName ?? this.iconName,
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
    );
  }
}
