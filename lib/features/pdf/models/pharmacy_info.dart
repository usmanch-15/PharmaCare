/// Pharmacy store information used in invoice header.
/// Populate from your Firestore /settings/pharmacy_config document.
class PharmacyInfo {
  const PharmacyInfo({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.drugLicenseNo,
    required this.ntn,
    this.website,
    this.tagline,
    this.logoPath,       // local asset path or null
  });

  final String name;
  final String address;
  final String phone;
  final String email;
  final String drugLicenseNo;
  final String ntn;
  final String? website;
  final String? tagline;
  final String? logoPath;

  /// Default fallback used when settings are not loaded yet.
  factory PharmacyInfo.defaultInfo() => const PharmacyInfo(
        name:           'PharmaCare Pharmacy',
        address:        'Shop # 12, Main Market, Islamabad',
        phone:          '+92-51-1234567',
        email:          'info@pharmacare.pk',
        drugLicenseNo:  'DL-2024-ISB-00142',
        ntn:            '1234567-8',
        website:        'www.pharmacare.pk',
        tagline:        'Your health, our priority',
      );
}