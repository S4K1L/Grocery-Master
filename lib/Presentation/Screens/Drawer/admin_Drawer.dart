import 'package:flutter/material.dart';
import '../../../Core/Repository_and_Authentication/profile_image_picker.dart';
import '../../../Theme/const.dart';
import '../Admin_Panel/Approve_barcode/approve_barcode.dart';
import '../Admin_Panel/Create_Menu/create_menu.dart';
import '../Admin_Panel/Create_voucher/create_voucher.dart';
import '../Admin_Panel/Create_voucher/voucher_list.dart';
import '../Bottom_bar/admin_bottomBar.dart';


class AdminDrawer extends StatefulWidget {
  const AdminDrawer({super.key});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 3.5,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.green[300]
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: const Center(child: ProfileImagePicker()),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Admin Profile',
                  style: TextStyle(fontSize: 20, color: kTextBlackColor),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              _buildDrawerButton(
                context,
                icon: Icons.home_outlined,
                label: 'Home',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminBottom(),
                    ),
                  );
                },
              ),
              _buildDrawerButton(
                context,
                icon: Icons.add_business_outlined,
                label: 'Add Menu',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateMenu()),
                  );
                },
              ),
              _buildDrawerButton(
                context,
                icon: Icons.crop_free,
                label: 'Create Voucher',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateVoucherPage()),
                  );
                },
              ),
              _buildDrawerButton(
                context,
                icon: Icons.qr_code_sharp,
                label: 'Voucher List',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VoucherListPage()),
                  );
                },
              ),

              _buildDrawerButton(
                context,
                icon: Icons.qr_code_scanner_sharp,
                label: 'Approve Barcode',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ApproveBarcodePage()),
                  );
                },
              ),

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.transparent,
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: kTextBlackColor),
          const SizedBox(width: 30),
          Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              color: kTextBlackColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
