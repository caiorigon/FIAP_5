enum ThreatLevel { high, medium, low, none, unknown }

ThreatLevel threatLevelFromString(String value) {
  switch (value.toLowerCase()) {
    case 'high':
      return ThreatLevel.high;
    case 'medium':
      return ThreatLevel.medium;
    case 'low':
      return ThreatLevel.low;
    case 'none':
      return ThreatLevel.none;
    default:
      return ThreatLevel.unknown;
  }
}

String threatLevelToString(ThreatLevel level) {
  switch (level) {
    case ThreatLevel.high:
      return 'High';
    case ThreatLevel.medium:
      return 'Medium';
    case ThreatLevel.low:
      return 'Low';
    case ThreatLevel.none:
      return 'none';
    default:
      return 'Unknown';
  }
}

bool hasThreat(ThreatLevel level) {
  return level != ThreatLevel.none && level != ThreatLevel.unknown;
}
