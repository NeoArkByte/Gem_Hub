enum GemCategory {
  sapphire('Sapphire'),
  spinel('Spinel'),
  garnet('Garnet'),
  other('Other');

  final String displayName;
  const GemCategory(this.displayName);
}

enum GemVisibility {
  private('Private'),
  public('Public');

  final String displayName;
  const GemVisibility(this.displayName);
}

enum CostType {
  treatment('Treatment'),
  cutting('Cutting'),
  recutting('Recutting'),
  heat('Heat'),
  transport('Transport'),
  other('Other');

  final String displayName;
  const CostType(this.displayName);
}

enum GemShape {
  rough('Rough'),
  faceted('Faceted'),
  cabochon('Cabochon'),
  beads('Beads'),
  other('Other');

  final String displayName;
  const GemShape(this.displayName);
}

enum GemClarity {
  fl('FL'),
  ifClarity('IF'),
  vvs1('VVS1'),
  vvs2('VVS2'),
  vs1('VS1'),
  vs2('VS2'),
  si1('SI1'),
  si2('SI2'),
  i1('I1'),
  i2('I2'),
  i3('I3');

  final String displayName;
  const GemClarity(this.displayName);
}

enum InventoryGemStatus {
  rough('Rough'),
  cut('Cut');

  final String displayName;
  const InventoryGemStatus(this.displayName);
}
