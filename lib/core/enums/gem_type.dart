enum GemType {
  allGems('All Gems'),
  sapphire('Sapphire'),
  ruby('Ruby'),
  emerald('Emerald'),
  diamond('Diamond'),
  alexandrite('Alexandrite'),
  topaz('Topaz'),
  spinel('Spinel'),
  tourmaline('Tourmaline'),
  other('Other');

  final String displayName;
  const GemType(this.displayName);

  static GemType fromString(String value) {
    return GemType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() || 
             e.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => GemType.other,
    );
  }
}
