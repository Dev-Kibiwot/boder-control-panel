import 'package:get/get.dart';

class SideNavController extends GetxController {
  var selectedIndex = 0.obs;
  var isCollapsed = false.obs;

  void setIndex(int index) {
    selectedIndex.value = index;
  }
  void toggleSidebar() {
    isCollapsed.value = isCollapsed.value;
  }
}
