String dateTimeConverter(DateTime date) {
  var milisecondsOnDate = date.millisecondsSinceEpoch;
  var milisecondNow = DateTime.now().millisecondsSinceEpoch;
  var differences = milisecondNow - milisecondsOnDate;
  if (differences < 60000) {
    var result = differences / 1000;
    if (result.floor() == 1) {
      return "a few seconds ago";
    }
    return "${(result).floor().toString()} seconds ago";
  } else if (differences < 3600000) {
    var result = differences / 60000;
    if (result.floor() == 1) {
      return "an minutes ago";
    }
    return "${(result).floor().toString()} minutes ago";
  } else if (differences < 86400000) {
    var result = differences / 3600000;
    if (result.floor() == 1) {
      return "an hour ago";
    }
    return "${(result).floor().toString()} hours ago";
  } else if (differences < 2628000000) {
    var result = differences / 86400000;
    if (result.floor() == 1) {
      return "a day ago";
    }
    return "${(result).floor().toString()} days ago";
  } else if (differences < 31540000000) {
    var result = differences / 2628000000;
    if (result.floor() == 1) {
      return "a month ago";
    }
    return "${(result).floor().toString()} months ago";
  }
  var result = differences / 31540000000;
  if (result.floor() == 1) {
    return "a year ago";
  }
  return "${(result).floor().toString()} years ago";
}
