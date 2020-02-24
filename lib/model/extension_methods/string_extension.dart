extension StringExtension on String {
  String toProperCase() {
    if (this.length <= 0) {
      return this;
    }
    return this.toLowerCase().split(' ').map((word) {
      if (word.length <= 0) {
        return word;
      }
      return word.substring(0, 1).toUpperCase() + word.substring(1);
    }).join(' ');
  }

  bool isEqual(String second, {bool ignoreCase = true, bool trim = true}) {
    String left = this;
    String right = second;
    if (trim) {
      left = left?.trim();
      right = right?.trim();
    }

    if (ignoreCase) {
      left = left?.toUpperCase();
      right = right?.toUpperCase();
    }
    return left == right;
  }

  String spaceDevisions() {
    String value = this;
    String result = '';
    if (value?.isEmpty != false) {
      return result;
    }
    value = value.replaceAll(' ', '');
    for (int i = 0; i < value.length; ++i) {
      if (i != 0 && i % 3 == 0) {
        result = ' ' + result;
      }
      result = value[value.length - 1 - i] + result;
    }
    return result;
  }
}
