/// Parses a Iso8601-String into a Flutter DateTime
DateTime dateFromString(String key) {
  return DateTime.parse(key);
}

String getLastUpdatedText(DateTime lastModified) {
  Duration differenceToRightNow = DateTime.now().difference(lastModified);

  String returnText = '';
  if (differenceToRightNow > const Duration(days: 2)) {
    returnText = '2 Days ago';
  } else if (differenceToRightNow > const Duration(days: 1)) {
    returnText = '1 Day ago';
  } else {
    returnText = 'Less than 1 Day ago';
  }
  return 'Last Updated: $returnText';
}
