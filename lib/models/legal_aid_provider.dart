class LegalAidProvider {
  final String id;
  final String name;
  final String district;
  final String address;
  final String phone;
  final String email;
  final String? whatsapp;
  final double? latitude;
  final double? longitude;
  final List<String> services;
  final List<String> languages;
  final bool isFreeAid;
  final bool isOpenNow;
  final bool isVerified;
  final String? about;
  final String? workingHours;
  final Map<String, List<String>>? documentsByService;

  LegalAidProvider({
    required this.id,
    required this.name,
    required this.district,
    required this.address,
    required this.phone,
    required this.email,
    this.whatsapp,
    this.latitude,
    this.longitude,
    required this.services,
    required this.languages,
    required this.isFreeAid,
    required this.isOpenNow,
    required this.isVerified,
    this.about,
    this.workingHours,
    this.documentsByService,
  });

  factory LegalAidProvider.fromJson(Map<String, dynamic> json) {
    return LegalAidProvider(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      district: json['district'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      whatsapp: json['whatsapp'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      services: List<String>.from(json['services'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      isFreeAid: json['is_free_aid'] as bool? ?? false,
      isOpenNow: json['is_open_now'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      about: json['about'] as String?,
      workingHours: json['working_hours'] as String?,
      documentsByService: (json['documents_by_service'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'district': district,
      'address': address,
      'phone': phone,
      'email': email,
      'whatsapp': whatsapp,
      'latitude': latitude,
      'longitude': longitude,
      'services': services,
      'languages': languages,
      'is_free_aid': isFreeAid,
      'is_open_now': isOpenNow,
      'is_verified': isVerified,
      'about': about,
      'working_hours': workingHours,
      'documents_by_service': documentsByService,
    };
  }
}
