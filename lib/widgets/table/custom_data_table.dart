import 'package:devboder/controller/table_controller.dart';
import 'package:devboder/constants/utils/colors.dart';
import 'package:devboder/widgets/table/table_colunm.dart';
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
  final bool showPagination;
  final int? currentPage;
  final int? totalPages;
  final int? pageSize;
  final List<int>? pageSizeOptions;
  final Function(int page)? onPageChange;
  final Function(int size)? onPageSizeChange;
  final int? totalCount;

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
    this.showPagination = false,
    this.currentPage,
    this.totalPages,
    this.pageSize,
    this.pageSizeOptions,
    this.onPageChange,
    this.onPageSizeChange,
    this.totalCount,
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
          if (showPagination && !isLoading && data.isNotEmpty)
            buildPaginationBar(),
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
              flex: 1,
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

  Widget buildPaginationBar() {
    final page = currentPage ?? 1;
    final pages = totalPages ?? 1;
    final size = pageSize ?? 20;
    final total = totalCount ?? data.length;
    final sizeOpts = pageSizeOptions ?? [10, 20, 50, 100];

    final startItem = total == 0 ? 0 : (page - 1) * size + 1;
    final endItem = (page * size).clamp(0, total);

    // Build visible page numbers (show up to 5 around current page)
    List<int> visiblePages = [];
    if (pages <= 7) {
      visiblePages = List.generate(pages, (i) => i + 1);
    } else {
      visiblePages = [1];
      if (page > 3) visiblePages.add(-1); // ellipsis
      for (int i = (page - 1).clamp(2, pages - 1); i <= (page + 1).clamp(2, pages - 1); i++) {
        visiblePages.add(i);
      }
      if (page < pages - 2) visiblePages.add(-1); // ellipsis
      visiblePages.add(pages);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          // Page size selector
          Row(
            children: [
              const Text(
                'Rows per page:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderColor),
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.cardBackground,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: sizeOpts.contains(size) ? size : sizeOpts.first,
                    isDense: true,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                    items: sizeOpts.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text('$s'),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) onPageSizeChange?.call(val);
                    },
                    icon: const Icon(Icons.arrow_drop_down, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Item range info
          Text(
            '$startItem–$endItem of $total',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const Spacer(),
          // Page navigation
          Row(
            children: [
              // First page
              _pageNavButton(
                icon: Icons.first_page,
                enabled: page > 1,
                onTap: () => onPageChange?.call(1),
              ),
              const SizedBox(width: 4),
              // Previous page
              _pageNavButton(
                icon: Icons.chevron_left,
                enabled: page > 1,
                onTap: () => onPageChange?.call(page - 1),
              ),
              const SizedBox(width: 8),
              // Page number buttons
              ...visiblePages.map((p) {
                if (p == -1) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  );
                }
                final isActive = p == page;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: isActive ? null : () => onPageChange?.call(p),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: isActive ? null : Border.all(color: AppColors.borderColor),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$p',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive ? AppColors.white : AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              // Next page
              _pageNavButton(
                icon: Icons.chevron_right,
                enabled: page < pages,
                onTap: () => onPageChange?.call(page + 1),
              ),
              const SizedBox(width: 4),
              // Last page
              _pageNavButton(
                icon: Icons.last_page,
                enabled: page < pages,
                onTap: () => onPageChange?.call(pages),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pageNavButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: enabled ? AppColors.borderColor : AppColors.borderColor.withOpacity(0.4)),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primaryBlue : AppColors.lightGrey,
        ),
      ),
    );
  }
}