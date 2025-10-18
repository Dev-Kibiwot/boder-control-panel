import 'package:boder/controller/riders_controller.dart';
import 'package:boder/models/riders_model.dart';
import 'package:boder/widgets/colors.dart';
import 'package:boder/widgets/space.dart';
import 'package:boder/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VehicleImagesCarousel extends StatelessWidget {
  final Rider rider;
  
  const VehicleImagesCarousel({super.key, required this.rider});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RidersController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.borderColor),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.photo_library, size: 16, color: AppColors.blue),
            const SizedBox(width: 8),
            CustomText(
              'Vehicle Photos (${rider.photosOfBike.length})',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              textColor: AppColors.primaryBlue,
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => controller.showVehicleImagesDialog(rider),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: controller.smallCarouselController,
                    itemCount: rider.photosOfBike.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey.withOpacity(0.3),
                        ),
                        child: Image.network(
                          rider.photosOfBike[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.lightGrey.withOpacity(0.3),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, color: AppColors.textSecondary, size: 30),
                                  SizedBox(height: 4),
                                  Text('Failed to load', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                ],
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppColors.lightGrey.withOpacity(0.3),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.blue,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  // Image counter
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${rider.photosOfBike.length} photos',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Click hint
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, color: AppColors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Tap to view',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Page indicators
                  if (rider.photosOfBike.length > 1)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            rider.photosOfBike.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class VehicleImagesDialog extends StatelessWidget {
  final Rider rider;
  
  const VehicleImagesDialog({super.key, required this.rider});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RidersController>();
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        width: horizontalSpace(context, 0.6),
        height: verticalSpace(context, 0.6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.borderColor),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.photo_library, color: AppColors.blue, size: 24),
                  const SizedBox(width: 12),
                  CustomText(
                    'Vehicle Photos',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.primaryBlue,
                  ),
                  const Spacer(),
                  Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${controller.dialogCurrentIndex.value + 1} of ${rider.photosOfBike.length}',
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: PageView.builder(
                        controller: controller.dialogCarouselController,
                        onPageChanged: controller.updateDialogIndex,
                        itemCount: rider.photosOfBike.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.lightGrey.withOpacity(0.1),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                rider.photosOfBike[index],
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.lightGrey.withOpacity(0.3),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image, color: AppColors.textSecondary, size: 80),
                                        SizedBox(height: 16),
                                        Text(
                                          'Failed to load image',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: AppColors.lightGrey.withOpacity(0.1),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const CircularProgressIndicator(
                                            color: AppColors.blue,
                                            strokeWidth: 3,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Loading image...',
                                            style: TextStyle(
                                              color: AppColors.textSecondary.withOpacity(0.7),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (rider.photosOfBike.length > 1) ...[
                      Positioned(
                        left: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Obx(() => Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: controller.dialogCurrentIndex.value > 0
                                  ? controller.previousImage
                                  : null,
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                color: controller.dialogCurrentIndex.value > 0
                                    ? AppColors.primaryBlue
                                    : AppColors.lightGrey,
                              ),
                            ),
                          )),
                        ),
                      ),                      
                      Positioned(
                        right: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Obx(() => Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: controller.dialogCurrentIndex.value < rider.photosOfBike.length - 1
                                  ? controller.nextImage
                                  : null,
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: controller.dialogCurrentIndex.value < rider.photosOfBike.length - 1
                                    ? AppColors.primaryBlue
                                    : AppColors.lightGrey,
                              ),
                            ),
                          )),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (rider.photosOfBike.length > 1)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border(
                    top: BorderSide(color: AppColors.borderColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() => Row(
                      children: List.generate(
                        rider.photosOfBike.length,
                        (index) => GestureDetector(
                          onTap: () => controller.goToImage(index),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: controller.dialogCurrentIndex.value == index ? 12 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: controller.dialogCurrentIndex.value == index
                                  ? AppColors.blue
                                  : AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}