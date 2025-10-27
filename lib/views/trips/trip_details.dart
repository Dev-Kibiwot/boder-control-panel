import 'package:boder/models/trip_model.dart';
import 'package:boder/constants/utils/colors.dart';
import 'package:boder/widgets/text.dart';
import 'package:flutter/material.dart';

class TripDetailsDrawer extends StatelessWidget {
  final Trip trip;
  final VoidCallback onClose;

  const TripDetailsDrawer({
    super.key,
    required this.trip,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.height,
      color: AppColors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.route,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        'Trip #${trip.id.substring(0, 8)}...',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.white,
                      ),
                      CustomText(
                        trip.formattedCreatedAt,
                        fontSize: 12,
                        textColor: AppColors.white.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: 20,
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
                  buildTripInfoSection(),
                  const SizedBox(height: 24),
                  buildPassengerSection(),
                  const SizedBox(height: 24),
                  buildDriverSection(),
                  const SizedBox(height: 24),
                  buildRouteSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTripInfoSection() {
    return buildSection(
      title: 'Trip Information',
      icon: Icons.info_outline,
      children: [
        buildInfoRow('Trip ID', trip.id),
        buildInfoRow('Status', trip.statusText, 
          valueWidget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getStatusColor(trip.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomText(
              trip.statusText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              textColor: getStatusColor(trip.status),
            ),
          ),
        ),
        buildInfoRow('Price', 'KSh ${trip.price.toStringAsFixed(0)}'),
        buildInfoRow('Created', trip.formattedCreatedAt),
        buildInfoRow('Updated', trip.formattedUpdatedAt),
        buildInfoRow('Pickup Location', trip.pickupLocation),
        buildInfoRow('Destination', trip.destinationLocation),
        buildBooleanRow('Driver Accepted', trip.driverAccepted),
        buildBooleanRow('Driver Arrived', trip.driverArrive),
        buildBooleanRow('Trip Paid', trip.paid),
        buildBooleanRow('Payment Confirmed', trip.paymentConfirmed),
        buildBooleanRow('Trip Ended', trip.tripEnded),
        buildBooleanRow('Is Rated', trip.isRated),
      ],
    );
  }

  Widget buildPassengerSection() {
    return buildSection(
      title: 'Passenger Information',
      icon: Icons.person,
      children: [
        buildInfoRow('Full Name', trip.passenger.userName),
        buildInfoRow('Email', trip.passenger.email),
        buildInfoRow('Phone', trip.passenger.phone),
        buildInfoRow('User Type', trip.passenger.userTypeDisplay),
        buildBooleanRow('Email Confirmed', trip.passenger.emailConfirmed),
        if (trip.passenger.lastLogoutTime != null)
          buildInfoRow('Last Logout', 
            '${trip.passenger.lastLogoutTime!.day}/${trip.passenger.lastLogoutTime!.month}/${trip.passenger.lastLogoutTime!.year}'),
      ],
    );
  }

  Widget buildDriverSection() {
    return buildSection(
      title: 'Driver Information',
      icon: Icons.motorcycle,
      children: [
        buildInfoRow('Full Name', trip.rider.fullnames),
        buildInfoRow('Email', trip.rider.email),
        buildInfoRow('Phone', trip.rider.phone),
        buildInfoRow('Gender', trip.rider.gender.isEmpty ? 'Not specified' : trip.rider.gender),
        buildInfoRow('City', trip.rider.city.isEmpty ? 'Not specified' : trip.rider.city),
        buildInfoRow('Status', trip.rider.statusText,
          valueWidget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: trip.rider.approved ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomText(
              trip.rider.statusText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              textColor: trip.rider.approved ? AppColors.success : AppColors.warning,
            ),
          ),
        ),
        buildInfoRow('Joined Date', trip.rider.formattedJoinedDate),
        
        // Driver Stats
        const SizedBox(height: 12),
        CustomText(
          'Driver Stats',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          textColor: AppColors.primaryBlue,
        ),
        const SizedBox(height: 8),
        buildInfoRow('Rating', trip.rider.rating.toString()),
        buildInfoRow('Completed Trips', trip.rider.complitedTrips.toString()),
        buildInfoRow('Cancelled Trips', trip.rider.canciel.toString()),
        buildInfoRow('Balance', 'KSh ${trip.rider.balance.toStringAsFixed(2)}'),
        
        // Vehicle Information
        const SizedBox(height: 12),
        CustomText(
          'Vehicle Information',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          textColor: AppColors.primaryBlue,
        ),
        const SizedBox(height: 8),
        buildInfoRow('Vehicle type', trip.rider.vehicleCategory!.isEmpty ? 'Not specified' : trip.rider.vehicleCategory!),
        buildInfoRow('Number Plate', trip.rider.numberPlate.isEmpty ? 'Not specified' : trip.rider.numberPlate),
        buildInfoRow('Make', trip.rider.bikeMake.isEmpty ? 'Not specified' : trip.rider.bikeMake),
        buildInfoRow('Model', trip.rider.bikeModel.isEmpty ? 'Not specified' : trip.rider.bikeModel),
        buildInfoRow('Color', trip.rider.bikeColor.isEmpty ? 'Not specified' : trip.rider.bikeColor),
        
        // Location
        const SizedBox(height: 12),
        CustomText(
          'Current Location',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          textColor: AppColors.primaryBlue,
        ),
        const SizedBox(height: 8),
        buildInfoRow('Coordinates', trip.rider.locationString),
      ],
    );
  }

  Widget buildRouteSection() {
    if (trip.route.isEmpty) {
      return buildSection(
        title: 'Route Information',
        icon: Icons.route,
        children: [
          CustomText(
            'No route data available',
            fontSize: 12,
            textColor: AppColors.textSecondary,
          ),
        ],
      );
    }

    return buildSection(
      title: 'Route Information',
      icon: Icons.route,
      children: [
        CustomText(
          'Route Points (${trip.route.length} points)',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          textColor: AppColors.primaryBlue,
        ),
        const SizedBox(height: 8),
        ...trip.route.asMap().entries.map((entry) {
          int index = entry.key;
          var point = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: buildInfoRow(
              'Point ${index + 1}',
              '${point.lat.toStringAsFixed(6)}, ${point.lng.toStringAsFixed(6)}',
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 8),
                CustomText(
                  title,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  textColor: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.grey),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String label, String value, {Widget? valueWidget}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: CustomText(
              label,
              fontSize: 12,
              textColor: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: valueWidget ?? CustomText(
              value.isEmpty ? 'Not specified' : value,
              fontSize: 12,
              textColor: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBooleanRow(String label, bool value) {
    return buildInfoRow(
      label,
      '',
      valueWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: value ? AppColors.success.withOpacity(0.1) : AppColors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomText(
          value ? 'Yes' : 'No',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          textColor: value ? AppColors.success : AppColors.red,
        ),
      ),
    );
  }

  Color getStatusColor(dynamic status) {
    switch (status.toString()) {
      case 'TripStatus.completed':
      case 'TripStatus.ended':
        return AppColors.success;
      case 'TripStatus.pending':
      case 'TripStatus.accepted':
      case 'TripStatus.inprogress':
      case 'TripStatus.awaiting_payment':
        return AppColors.warning;
      case 'TripStatus.cancelled':
      case 'TripStatus.auto_cancel':
      case 'TripStatus.no_drivers':
        return AppColors.red;
      default:
        return AppColors.primaryBlue;
    }
  }
}