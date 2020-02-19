class StringUtils {
  static String getInitials(
      {String fullname, String firstname, String lastname}) {
    String initials = '';

    if (fullname?.trim()?.isNotEmpty == true) {
      fullname.split(' ')?.forEach((x) {
        initials += x.substring(0, 1).toUpperCase();
      });

      if ((initials?.length ?? 0) == 3) {
        initials = initials.substring(0, 2);
      }
    } else if (firstname?.trim()?.isNotEmpty == true &&
        lastname?.trim()?.isNotEmpty == true) {
      initials = firstname.substring(0, 1).toUpperCase() +
          lastname.substring(0, 1).toUpperCase();
    }

    return initials;
  }

  static String getShortName(
      {String fullname, String firstname, String lastname}) {
    String shortName = '';

    if (fullname?.trim()?.isNotEmpty == true) {
      List<String> names = fullname.replaceAll(',', '').split(' ');

      if (names.length >= 2) {
        shortName = names[0] + ' ' + names[1];
      } else {
        shortName = fullname;
      }
    } else if (firstname?.trim()?.isNotEmpty == true &&
        lastname?.trim()?.isNotEmpty == true) {
      shortName = firstname + ' ' + lastname;
    }

    return shortName;
  }
}
