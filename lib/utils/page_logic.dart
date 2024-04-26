import 'package:obsydia_copy_1/bloc/issue/issue_state.dart';

Map<String, int> pageLogic(IssueState data) {
  int lowestLimit = 1;
  int highestLimit = data.totalPage;
  if (data.currentPage - 3 <= 0) {
    lowestLimit = 1;
  } else {
    lowestLimit = data.currentPage - 3;
  }
  if (data.currentPage + 3 > data.totalPage) {
    highestLimit = data.totalPage;
  } else {
    highestLimit = data.currentPage + 3;
  }
  if (highestLimit - lowestLimit < 6) {
    if (data.currentPage - lowestLimit < 3) {
      if (data.currentPage + (6 - (data.currentPage - lowestLimit)) >
          data.totalPage) {
        highestLimit = data.totalPage;
      } else {
        highestLimit =
            data.currentPage + (6 - (data.currentPage - lowestLimit));
      }
    } else {
      if (data.currentPage - (6 - (highestLimit - data.currentPage)) < 1) {
        lowestLimit = 1;
      } else {
        lowestLimit =
            data.currentPage - (6 - (highestLimit - data.currentPage));
      }
    }
  }
  return {"lowest": lowestLimit, "highest": highestLimit};
}
