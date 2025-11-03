class ProfileModel {
  final String? image;
  final String name;
  final String surname;
  final String? description;
  final String? pageColor;
  final String? customProfileUrl;

  ProfileModel({
    this.image,
    required this.name,
    required this.surname,
    this.description,
    this.pageColor,
    this.customProfileUrl,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'surname': surname,
    };
    // Only include non-null, non-empty optional fields
    if (image != null && image!.isNotEmpty) {
      json['image'] = image;
    }
    if (description != null && description!.isNotEmpty) {
      json['description'] = description;
    }
    if (pageColor != null && pageColor!.isNotEmpty) {
      json['pageColor'] = pageColor;
    }
    if (customProfileUrl != null && customProfileUrl!.isNotEmpty) {
      json['customProfileUrl'] = customProfileUrl;
    }
    return json;
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      image: json['image'],
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      description: json['description'],
      pageColor: json['pageColor'],
      customProfileUrl: json['customProfileUrl'],
    );
  }

  ProfileModel copyWith({
    String? image,
    String? name,
    String? surname,
    String? description,
    String? pageColor,
    String? customProfileUrl,
  }) {
    return ProfileModel(
      image: image ?? this.image,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      description: description ?? this.description,
      pageColor: pageColor ?? this.pageColor,
      customProfileUrl: customProfileUrl ?? this.customProfileUrl,
    );
  }
}
