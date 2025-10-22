import 'package:boder/constants/show_dialog.dart';
import 'package:boder/controller/privillage_user_controller.dart';
import 'package:boder/controller/riders_controller.dart';
import 'package:boder/models/riders_model.dart';
import 'package:boder/views/riders/vehicle_images_carousel.dart';
import 'package:boder/constants/utils/colors.dart';
import 'package:boder/widgets/space.dart';
import 'package:boder/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RiderDetailsDrawer extends StatelessWidget {
  final Rider rider;
  final ridersController = Get.find<RidersController>();
  PrivilegedUserController privilegedUserController = Get.put(PrivilegedUserController());
  final VoidCallback onClose;
  
  RiderDetailsDrawer({
    super.key,
    required this.rider,
    required this.onClose,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: horizontalSpace(context, 0.3),
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.lightGrey,
                  backgroundImage: rider.image != null
                    ? NetworkImage(rider.image!)
                    : AssetImage("assets/icons/logo.png") as ImageProvider,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        rider.fullnames, 
                        fontSize: 13, 
                        textColor: AppColors.black,
                      ),
                      const SizedBox(height: 4),
                      CustomText(
                        rider.email, 
                        fontSize: 13, 
                        textColor: AppColors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSection(
                    'Profile Information',
                    Icons.person,
                    [
                      buildInfoRow('Full Name', rider.fullnames),
                      buildInfoRow('Email', rider.email),
                      buildInfoRow('Phone', rider.phone),
                      buildInfoRow('Gender', rider.gender),
                      buildInfoRow('Date of Birth', rider.dateOfBirth),
                      buildInfoRow('ID Number', rider.idNumber),
                      buildInfoRow('City', rider.city),
                      buildStatusRow('Status', rider.verification.isApproved),
                      buildInfoRow('Joined Date', '${rider.joinedDate.day}/${rider.joinedDate.month}/${rider.joinedDate.year}'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  buildSection(
                    'Stats',
                    Icons.info,
                    [
                      buildInfoRow('Complited trips', rider.complitedTrips.toString()),
                      buildInfoRow('cancieled trips', rider.canciel.toString()),
                      buildInfoRow('Rating', rider.rating.toString()),
                      buildInfoRow('Balance', rider.balance.toString()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  buildSection(
                    'Vehicle Information',
                    Icons.motorcycle,
                    [
                      buildInfoRow('Number Plate', rider.numberPlate),
                      buildInfoRow('Make', rider.bikeMake),
                      buildInfoRow('Model', rider.bikeModel),
                      buildInfoRow('Color', rider.bikeColor),
                    ],
                  ),
                  const SizedBox(height: 24),
                  buildSection(
                    'Experience & Background',
                    Icons.work_history,
                    [
                      buildBooleanRow('Previous Driver Experience', rider.previousDriverExperience),
                      buildBooleanRow('Consent Background Checks', rider.consentBackgroundChecks),
                      if (rider.referalCode != null)
                        buildInfoRow('Referral Code', rider.referalCode!),
                    ],
                  ),
                  const SizedBox(height: 24),
                  buildSection(
                    'Location',
                    Icons.location_on,
                    [
                      buildInfoRow('Latitude', rider.location.lat.toString()),
                      buildInfoRow('Longitude', rider.location.lng.toString()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (rider.complainsFiled.isNotEmpty)
                    buildComplaintsSection(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: rider.approved ? null : () {
                            showActionDialog(
                              context,
                              'Approve Rider',
                              'Are you sure you want to approve ${rider.fullnames}?',
                              'Cancel',      
                              'Approve',     
                              AppColors.success,
                              () {
                                ridersController.approveRider(rider, context, onSuccess: onClose);
                              },
                            );
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(rider.approved ? 'Approved' : 'Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: rider.approved ? AppColors.grey : AppColors.success,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: !rider.approved ? null : () {
                            showActionDialog(
                              context,
                              'Revoke Approval',
                              'Are you sure you want to revoke approval for ${rider.fullnames}?',
                              'Cancel',      
                              'Revoke',     
                              AppColors.red,
                              () {
                                ridersController.disapproveRider(rider, context, onSuccess: onClose);              
                              },
                            );
                          },
                          icon: const Icon(Icons.block, size: 18),
                          label: Text(!rider.approved ? 'Pending' : 'Revoke'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !rider.approved ? AppColors.grey : AppColors.red,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  GestureDetector(
                    onTap: (){
                       ridersController.deleteRider(rider, context);
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(8)
                      ),
                       child: Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Center(
                           child: CustomText(
                            "Delete rider", 
                            fontSize: 14, 
                            textColor: AppColors.white
                                                 ),
                         ),
                       ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }  

  Widget buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.blue),
            const SizedBox(width: 8),
            CustomText(
              title,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              textColor: AppColors.primaryBlue,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            children: [
              ...children,
              if (title == 'Vehicle Information' && rider.photosOfBike.isNotEmpty)
                VehicleImagesCarousel(rider: rider),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: CustomText(
              label, 
              fontSize: 13, 
              textColor: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: CustomText(
              value, 
              fontSize: 13, 
              textColor: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusRow(String label, bool approved) {
    Color statusColor = approved ? AppColors.success : AppColors.warning;
    String statusText = approved ? 'Approved' : 'Pending Approval';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBooleanRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: CustomText(
              label, 
              fontSize: 13, 
              fontWeight: FontWeight.w500,
              textColor: AppColors.textSecondary,
            ),
          ),
          Row(
            children: [
              Icon(
                value ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: value ? AppColors.success : AppColors.red,
              ),
              const SizedBox(width: 6),
              CustomText(
                value ? 'Yes' : 'No', 
                fontSize: 13, 
                fontWeight: FontWeight.w500,
                textColor: value ? AppColors.success : AppColors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildComplaintsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.report_problem, size: 20, color: AppColors.warning),
            const SizedBox(width: 8),
            CustomText(
              'Complaints (${rider.complainsFiled.length})', 
              fontSize: 16, 
              textColor: AppColors.primaryBlue,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...rider.complainsFiled.map((complaint) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.red.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                complaint.complaintText, 
                fontSize: 13, 
                textColor: AppColors.primaryBlue,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CustomText(
                    'Status: ${complaint.status}', 
                    fontSize: 12, 
                    textColor: AppColors.textSecondary,
                  ),
                  const Spacer(),
                  CustomText(
                    '${complaint.createdAt.day}/${complaint.createdAt.month}/${complaint.createdAt.year}', 
                    fontSize: 12, 
                    textColor: AppColors.textSecondary,
                  ),
                ],
              ),
              if (complaint.resolution != null) ...[
                const SizedBox(height: 8),
                CustomText(
                  'Resolution: ${complaint.resolution}', 
                  fontSize: 12, 
                  textColor: AppColors.success,
                ),
              ],
            ],
          ),
        )),
      ],
    );
  }
}