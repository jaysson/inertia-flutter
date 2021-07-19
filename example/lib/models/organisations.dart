class OrganizationPreview {
  final int id;
  final String name;
  final String? phone;
  final String? city;
  final DateTime? deletedAt;

  const OrganizationPreview({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    this.deletedAt,
  });

  factory OrganizationPreview.fromMap(Map<String, dynamic> map) {
    return new OrganizationPreview(
      id: map['id'] as int,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      city: map['city'] as String?,
      deletedAt: map['deleted_at'] == null
          ? null
          : DateTime.parse(
              map['deleted_at'],
            ),
    );
  }
}
