enum ThreatLevel { high, medium, low, unknown }

ThreatLevel threatLevelFromString(String value) {
  switch (value.toLowerCase()) {
    case 'high':
      return ThreatLevel.high;
    case 'medium':
      return ThreatLevel.medium;
    case 'low':
      return ThreatLevel.low;
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
    default:
      return 'Unknown';
  }
}
