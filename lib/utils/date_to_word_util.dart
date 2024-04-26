String dateToWord(DateTime date) {
  List<String> fullDate = date.toString().split(' ')[0].split('-');
  String day = fullDate[2];
  int month = int.parse(fullDate[1]);
  String newMonth = "";
  String year = fullDate[0];
  if (month == 1) newMonth = "Januari";
  if (month == 2) newMonth = "Februari";
  if (month == 3) newMonth = "Maret";
  if (month == 4) newMonth = "April";
  if (month == 5) newMonth = "Mei";
  if (month == 6) newMonth = "Juni";
  if (month == 7) newMonth = "Juli";
  if (month == 8) newMonth = "Agustus";
  if (month == 9) newMonth = "September";
  if (month == 10) newMonth = "Oktober";
  if (month == 11) newMonth = "November";
  if (month == 12) newMonth = "Desember";
  return "$day $newMonth $year";
}
