class ProfileModel {
  final String? image;
  final String name;
  final String surname;
  final String? description;
  final String? pageColor;

  ProfileModel({
    this.image,
    required this.name,
    required this.surname,
    this.description,
    this.pageColor,
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
    return json;
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      image: json['image'],
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      description: json['description'],
      pageColor: json['pageColor'],
    );
  }

  ProfileModel copyWith({
    String? image,
    String? name,
    String? surname,
    String? description,
    String? pageColor,
  }) {
    return ProfileModel(
      image: image ?? this.image,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      description: description ?? this.description,
      pageColor: pageColor ?? this.pageColor,
    );
  }
}
