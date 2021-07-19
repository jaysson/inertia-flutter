class ContactPreview {
  int id;
  String name;
  String organizationName;
  String phone;
  String city;
  DateTime? deletedAt;

  ContactPreview({
    required this.id,
    required this.name,
    required this.organizationName,
    required this.phone,
    required this.city,
    this.deletedAt,
  });

  factory ContactPreview.fromMap(Map<String, dynamic> map) {
    return new ContactPreview(
      id: map['id'] as int,
      name: map['name'] as String,
      organizationName: map['organization']['name'] as String,
      phone: map['phone'] as String,
      city: map['city'] as String,
      deletedAt: map['deleted_at'] == null
          ? null
          : DateTime.parse(
              map['deleted_at'],
            ),
    );
  }
}
