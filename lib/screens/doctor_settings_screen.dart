import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the custom primary color for consistency
    const Color primaryColor = Color(0xFFC80469);

    return Scaffold(
      // 1. Enhanced AppBar
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        // Add elevation for a slight lift effect
        elevation: 4.0,
      ),

      // 2. Body with a ListView for impressive settings layout
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          // --- General Settings Section ---
          const Padding(
            padding: EdgeInsets.only(top: 16.0, left: 8.0, bottom: 8.0),
            child: Text(
              "General",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),

          // Theme/Dark Mode Setting
          ListTile(
            leading: const Icon(Icons.palette, color: primaryColor),
            title: const Text('App Theme'),
            subtitle: const Text('Change to Light or Dark mode'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Placeholder action: Implement navigation to Theme Settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Go to Theme Settings')),
              );
            },
          ),

          // Notifications Setting (with a Switch)
          SwitchListTile(
            activeColor: primaryColor,
            secondary: const Icon(Icons.notifications, color: primaryColor),
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive alerts and updates'),
            value: true, // Placeholder for the actual state variable
            onChanged: (bool value) {
              // Placeholder action: Update the notification setting state
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notifications set to $value')),
              );
            },
          ),

          // --- Account Settings Section ---
          const Divider(), // Separator
          const Padding(
            padding: EdgeInsets.only(top: 16.0, left: 8.0, bottom: 8.0),
            child: Text(
              "Account",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),

          // Profile Setting
          ListTile(
            leading: const Icon(Icons.person, color: primaryColor),
            title: const Text('Edit Profile'),
            subtitle: const Text('Update your name, email, and photo'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Placeholder action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Go to Profile Editor')),
              );
            },
          ),

          // Password Setting
          ListTile(
            leading: const Icon(Icons.lock, color: primaryColor),
            title: const Text('Change Password'),
            subtitle: const Text('Secure your account with a new password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Placeholder action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Go to Password Change Screen')),
              );
            },
          ),

          // --- App Information Section ---
          const Divider(), // Separator
          const Padding(
            padding: EdgeInsets.only(top: 16.0, left: 8.0, bottom: 8.0),
            child: Text(
              "About",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),

          // Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: primaryColor),
            title: const Text('Privacy Policy'),
            onTap: () {
              // Placeholder action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('View Privacy Policy')),
              );
            },
          ),

          // Version Info
          const ListTile(
            leading: Icon(Icons.info, color: primaryColor),
            title: Text('App Version'),
            trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
