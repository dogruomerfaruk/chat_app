class Helper {
  String getInitials(username) {
    List<String> names = username.split(" ");
    String initials = "";

    for (var i = 0; i < names.length; i++) {
      initials += '${names[i][0]}';
    }
    return initials;
  }
}
