import 'package:boder/controller/table_controller.dart';
import 'package:boder/constants/utils/colors.dart';
import 'package:boder/widgets/table/table_colunm.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class CustomDataTable<T extends Map<String, dynamic>> extends StatelessWidget {
  final List<TableColumn> columns;
  final List<T> data;
  final Function(T item)? onRowTap;
  final Function(String column, bool ascending)? onSort;
  final bool showSearch;
  final String searchHint;
  final Function(String query)? onSearch;
  final Widget? actionBar;
  final double? maxHeight;
  final bool isLoading;
  final String noDataMessage;
  final String? tag;
  final bool showSearchBar;

  const CustomDataTable({
    super.key,
    required this.columns,
    required this.data,
    this.onRowTap,
    this.onSort,
    this.showSearch = true,
    this.searchHint = 'Search...',
    this.onSearch,
    this.actionBar,
    this.maxHeight,
    this.isLoading = false,
    this.noDataMessage = 'No data available',
    this.tag,
    this.showSearchBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TableController>(
      tag: tag,
      init: TableController(),
      builder: (controller) => Column(
        children: [
          if (showSearchBar && (showSearch || actionBar != null)) 
            buildSearchBar(controller),
          Expanded(
            child: buildContent(controller)
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar(TableController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          if (showSearch)
            Expanded(
              flex: 2,
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: (value) {
                    controller.onSearchChanged(value);
                    onSearch?.call(value);
                  },
                  decoration: InputDecoration(
                    hintText: searchHint,
                    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                    suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          controller.clearSearch();
                          onSearch?.call('');
                        },
                      )
                    : const SizedBox()),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
          if (showSearch && actionBar != null) const SizedBox(width: 16),
          if (actionBar != null) Expanded(child: actionBar!),
        ],
      ),
    );
  }
  
  Widget buildContent(TableController controller) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.blue
        )
      );
    }
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(
              Icons.inbox_outlined, 
              size: 64, 
              color: AppColors.lightGrey
            ),
            const SizedBox(height: 16),
            Text(
              noDataMessage, 
              style: const TextStyle(
                fontSize: 16, 
                color: AppColors.textSecondary
              )
            ),
          ],
        ),
      );
    }
    return buildTable();
  }

  Widget buildTable() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            buildHeader(),
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) => buildRow(data[index], index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.lightGrey
          )
        ),
      ),
      child: Row(
        children: columns.map((column) => Expanded(
          flex: column.flex,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              column.header,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.primaryBlue,
                letterSpacing: 0.5,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget buildRow(T item, int index) {
    return InkWell(
      onTap: onRowTap != null ? () => onRowTap!(item) : null,
      hoverColor: AppColors.cardBackground,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: index.isEven ? AppColors.cardBackground : AppColors.white,
          border: const Border(bottom: BorderSide(color: AppColors.borderColor, width: 0.5)),
        ),
        child: Row(
          children: columns.map((column) => Expanded(
            flex: column.flex,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: column.customWidget != null ? column.customWidget!(item[column.key], item) : Text(
                item[column.key]?.toString() ?? '',
                style: const TextStyle(fontSize: 14, color: AppColors.primaryBlue),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }
}