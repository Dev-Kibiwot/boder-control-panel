import 'package:boder/constants/show_dialog.dart';
import 'package:boder/controller/privillage_user_controller.dart';
import 'package:boder/controller/riders_controller.dart';
import 'package:boder/models/riders_model.dart';
import 'package:boder/constants/utils/colors.dart';
import 'package:boder/widgets/space.dart';
import 'package:boder/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RiderDetailsDialog extends StatelessWidget {
  final Rider rider;
  final RidersController ridersController = Get.find<RidersController>();
  final PrivilegedUserController privilegedUserController = Get.put(PrivilegedUserController());
  RiderDetailsDialog({super.key, required this.rider});
  BoxDecoration get _cardDecoration => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
@override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final maxHeight = constraints.maxHeight * 0.9;
      return Center(
        child: Container(
          width: constraints.maxWidth * 0.58,
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Material(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Stack( // Changed from Column to Stack
              children: [
                // Main content
                Column(
                  children: [
                    _buildHeader(context),
                    const Divider(height: 0),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            _buildDualSection(
                              'Driver Info & Verification',
                              Icons.info_outline,
                              _buildDriverInfo(),
                              _buildVerificationStatus(),
                              leftTitle: 'Driver\'s Info',
                              leftIcon: Icons.person,
                              rightTitle: 'Verification',
                              rightIcon: Icons.verified_user,
                            ),
                            const SizedBox(height: 8),
                            _buildDualSection(
                              'Documents & Experience',
                              Icons.document_scanner,
                              _buildDocuments(context),
                              _buildExperience(),
                              leftTitle: 'Documents',
                              leftIcon: Icons.document_scanner,
                              rightTitle: 'Experience',
                              rightIcon: Icons.work_history,
                            ),
                            const SizedBox(height: 24),
                            _buildVehicleSection(),
                            const SizedBox(height: 24),
                            if (rider.complainsFiled.isNotEmpty) _buildComplaintsSection(),
                            const SizedBox(height: 24),
                            _buildActionButtons(context),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Loading overlay
                Obx(() => _buildLoadingOverlay()),
              ],
            ),
          ),
        ),
      );
    },
  );
}
Widget _buildLoadingOverlay() {
  if (!ridersController.isActionLoading.value) {
    return const SizedBox.shrink();
  }

  return Container(
    color: AppColors.black.withOpacity(0.5),
    child: Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
            const SizedBox(height: 16),
            CustomText(
              'Processing...',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              textColor: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 12, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.white,
            backgroundImage: rider.image?.isNotEmpty == true ? NetworkImage(rider.image!) : null,
            child: rider.image?.isEmpty != false ? Icon(Icons.person, size: 40, color: AppColors.grey) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(rider.fullnames, fontSize: 20, fontWeight: FontWeight.bold, textColor: AppColors.white),
                const SizedBox(height: 4),
                CustomText(rider.email, fontSize: 13, textColor: AppColors.white.withOpacity(0.9)),
                const SizedBox(height: 2),
                CustomText(rider.phone, fontSize: 13, textColor: AppColors.white.withOpacity(0.9)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildBadge(
                      rider.verification.isApproved ? 'Approved' : 'Pending',
                      rider.verification.isApproved ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    _buildBadge('ID: ${rider.idNumber}', AppColors.white.withOpacity(0.1), fontSize: 11),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(child: _buildHeaderStat('Trips', rider.complitedTrips.toString(), Icons.check_circle, AppColors.success)),
                const SizedBox(width: 8),
                Expanded(child: _buildHeaderStat('Cancelled', rider.canciel.toString(), Icons.cancel, AppColors.red)),
                const SizedBox(width: 8),
                Expanded(child: _buildHeaderStat('Rating', rider.rating.toStringAsFixed(1), Icons.star, AppColors.warning)),
                const SizedBox(width: 8),
                Expanded(child: _buildHeaderStat('Balance', 'KES ${rider.balance.toStringAsFixed(0)}', Icons.account_balance_wallet, AppColors.blue)),
              ],
            ),
          ),
          IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {double fontSize = 12}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: CustomText(text, fontSize: fontSize, fontWeight: FontWeight.bold, textColor: AppColors.white),
    );
  }

  Widget _buildHeaderStat(String title, String value, IconData icon, Color color) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 6),
            FittedBox(child: CustomText(value, fontSize: 14, fontWeight: FontWeight.bold, textColor: AppColors.white)),
            const SizedBox(height: 2),
            FittedBox(child: CustomText(title, fontSize: 10, textColor: AppColors.white.withOpacity(0.85))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 12),
        CustomText(title, fontSize: 18, fontWeight: FontWeight.bold, textColor: AppColors.primaryBlue),
      ],
    );
  }

  Widget _buildDualSection(
    String mainTitle,
    IconData mainIcon,
    Widget leftContent,
    Widget rightContent, {
    required String leftTitle,
    required IconData leftIcon,
    required String rightTitle,
    required IconData rightIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(mainTitle, mainIcon),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSubSectionTitle(leftTitle, leftIcon),
                      const SizedBox(height: 16),
                      leftContent,
                    ],
                  ),
                ),
                Container(width: 1, margin: const EdgeInsets.symmetric(horizontal: 20), color: AppColors.borderColor),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSubSectionTitle(rightTitle, rightIcon),
                      const SizedBox(height: 16),
                      rightContent,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        CustomText(title, fontSize: 16, fontWeight: FontWeight.bold, textColor: AppColors.primaryBlue),
      ],
    );
  }

  Widget _buildDriverInfo() {
    return Column(
      children: [
        _buildInfoRow('Full Name', rider.fullnames),
        _buildInfoRow('Phone', rider.phone),
        _buildInfoRow('Gender', rider.gender),
        _buildInfoRow('Date of Birth', rider.dateOfBirth),
        _buildInfoRow('ID Number', rider.idNumber),
        _buildInfoRow('City', rider.city),
      ],
    );
  }

  Widget _buildVerificationStatus() {
    return Column(
      children: [
        _buildBooleanRow('Account Approved', rider.verification.isApproved),
        _buildBooleanRow('Documents Verified', rider.verification.documentVerified),
        _buildBooleanRow('Interviewed', rider.verification.interviewed),
        _buildBooleanRow('License Verified', rider.verification.isLicenseVerified),
      ],
    );
  }

  Widget _buildDocuments(BuildContext context) {
    return Column(
      children: [
        _buildDocumentRow(context, 'ID Photo', rider.idPhoto),
        _buildDocumentRow(context, 'Driver\'s License', rider.driversLicensePhoto),
      ],
    );
  }

  Widget _buildExperience() {
    return Column(
      children: [
        _buildBooleanRow('Driver Experience', rider.previousDriverExperience),
        _buildBooleanRow('Background Checks', rider.consentBackgroundChecks),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: CustomText(label, fontSize: 14, fontWeight: FontWeight.w500, textColor: AppColors.textSecondary)),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: CustomText(value, fontSize: 14, fontWeight: FontWeight.w600, textColor: AppColors.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildBooleanRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: CustomText(label, fontSize: 14, fontWeight: FontWeight.w500, textColor: AppColors.textSecondary)),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(value ? Icons.check_circle : Icons.cancel, size: 18, color: value ? AppColors.success : AppColors.red),
                const SizedBox(width: 8),
                CustomText(value ? 'Yes' : 'No', fontSize: 14, fontWeight: FontWeight.w600, textColor: value ? AppColors.success : AppColors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(BuildContext context, String label, String? documentUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: documentUrl?.isNotEmpty == true
                ? GestureDetector(
                    onTap: () => _showDocumentDialog(context, documentUrl, label),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderColor),
                            image: DecorationImage(image: NetworkImage(documentUrl!), fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(label, fontSize: 13, fontWeight: FontWeight.w600, textColor: AppColors.primaryBlue),
                              const SizedBox(height: 4),
                              CustomText('Tap to view', fontSize: 11, textColor: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : CustomText('Not uploaded', fontSize: 14, textColor: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showDocumentDialog(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxWidth: 600, maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(title, fontSize: 16, fontWeight: FontWeight.bold, textColor: AppColors.primaryBlue),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        height: verticalSpace(context, 0.5),
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: AppColors.lightGrey,
                          child: const Center(child: Icon(Icons.error, size: 48)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Bike/Vehicle Info', Icons.motorcycle),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Vehicle Category', rider.vehicleCategory ?? 'Not specified'),
                    _buildInfoRow('Number Plate', rider.numberPlate),
                    _buildInfoRow('Make', rider.bikeMake),
                    _buildInfoRow('Model', rider.bikeModel),
                    _buildInfoRow('Color', rider.bikeColor),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              if (rider.photosOfBike.isNotEmpty) _buildCompactVehicleImages(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactVehicleImages() {
    return GestureDetector(
      onTap: () => ridersController.showVehicleImagesDialog(rider),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              PageView.builder(
                controller: ridersController.smallCarouselController,
                itemCount: rider.photosOfBike.length,
                itemBuilder: (context, index) => Image.network(
                  rider.photosOfBike[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.lightGrey.withOpacity(0.3),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: AppColors.textSecondary, size: 30),
                        SizedBox(height: 4),
                        Text('Failed to load', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  loadingBuilder: (_, child, loadingProgress) => loadingProgress == null
                      ? child
                      : Container(
                          color: AppColors.lightGrey.withOpacity(0.3),
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blue)),
                        ),
                ),
              ),
              _buildImageBadge(top: 8, right: 8, '${rider.photosOfBike.length}'),
              _buildImageBadge(bottom: 8, left: 8, right: 8, Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.zoom_in, color: AppColors.white, size: 14),
                  SizedBox(width: 4),
                  Text('Tap to view', style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              )),
              if (rider.photosOfBike.length > 1)
                _buildImageBadge(
                  top: 8,
                  left: 8,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      rider.photosOfBike.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(color: AppColors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageBadge(dynamic content, {double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppColors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(12)),
        child: content is String 
            ? Text(content, style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600)) 
            : content,
      ),
    );
  }

  Widget _buildComplaintsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.report_problem, size: 20, color: AppColors.warning),
            ),
            const SizedBox(width: 12),
            CustomText('Complaints Filed (${rider.complainsFiled.length})', fontSize: 18, fontWeight: FontWeight.bold, textColor: AppColors.primaryBlue),
          ],
        ),
        const SizedBox(height: 16),
        ...rider.complainsFiled.map((complaint) {
          final statusColor = _getComplaintStatusColor(complaint.status);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration.copyWith(border: Border.all(color: AppColors.red.withOpacity(0.2))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: CustomText(complaint.status.toUpperCase(), fontSize: 11, fontWeight: FontWeight.bold, textColor: statusColor),
                    ),
                    const Spacer(),
                    CustomText('${complaint.createdAt.day}/${complaint.createdAt.month}/${complaint.createdAt.year}', fontSize: 12, textColor: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 12),
                CustomText(complaint.complaintText, fontSize: 14, textColor: AppColors.primaryBlue),
                if (complaint.resolution != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText('Resolution', fontSize: 12, fontWeight: FontWeight.bold, textColor: AppColors.success),
                              const SizedBox(height: 4),
                              CustomText(complaint.resolution!, fontSize: 12, textColor: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getComplaintStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'resolved' => AppColors.success,
      'pending' => AppColors.warning,
      'investigating' => AppColors.blue,
      _ => AppColors.red,
    };
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildActionButton(
          context,
          'Approve',
          Icons.check_circle,
          rider.approved ? AppColors.grey : AppColors.success,
          !rider.approved,
          () => _handleApprove(context),
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton(
          context,
          'Revoke',
          Icons.block,
          rider.approved ? AppColors.warning : AppColors.grey,
          rider.approved,
          () => _handleRevoke(context),
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton(
          context,
          'Delete',
          Icons.delete_forever,
          AppColors.red,
          true,
          () => _handleDelete(context),
        )),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, bool enabled, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleApprove(BuildContext context) {
    showActionDialog(
      context,
      'Approve Rider',
      'Are you sure you want to approve ${rider.fullnames}?',
      'Cancel',
      'Approve',
      AppColors.success,
      () {
        ridersController.approveRider(rider, context, onSuccess: () {
          Get.back();
          Get.back();
        });
      },
    );
  }

  void _handleRevoke(BuildContext context) {
  showActionDialog(
    context,
    'Revoke Approval',
    'Are you sure you want to revoke approval for ${rider.fullnames}?',
    'Cancel',
    'Revoke',
    AppColors.red,
    () {
       ridersController.disapproveRider(rider, context, onSuccess: () {
        Get.back();
        Get.back();
      });
    },
  );
}

  void _handleDelete(BuildContext context) {
    showActionDialog(
      context,
      'Delete Rider',
      'Are you sure you want to delete ${rider.fullnames}? This action cannot be undone.',
      'Cancel',
      'Delete',
      AppColors.red,
      () {
        ridersController.deleteRider(rider, context);
        Get.back();
        Get.back();
      },
    );
  }
}