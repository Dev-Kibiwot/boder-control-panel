import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TableController extends GetxController {
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }
  
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}