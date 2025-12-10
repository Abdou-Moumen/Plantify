// lib/models/profile_model.dart
class ProfileData {
  final String? firstName;
  final String? phoneNumber;
  final String? speciality;
  final String? birthDate;
  final String? birthPlace;
  final String? email;

  ProfileData({
    this.firstName,
    this.phoneNumber,
    this.speciality,
    this.birthDate,
    this.birthPlace,
    this.email,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      firstName: json['first_name'],
      phoneNumber: json['phone_number'] ?? json['profile']?['phone_number'],
      speciality: json['speciality'] ?? json['profile']?['speciality'],
      birthDate: json['birth_date'] ?? json['profile']?['birth_date'],
      birthPlace: json['birth_place'] ?? json['profile']?['birth_place'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'phone_number': phoneNumber,
      'speciality': speciality,
      'birth_date': birthDate,
      'birth_place': birthPlace,
      'profile': {
        'phone_number': phoneNumber,
        'speciality': speciality,
        'birth_date': birthDate,
        'birth_place': birthPlace,
      },
    };
  }
}
