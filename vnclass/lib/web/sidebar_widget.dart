import 'package:flutter/material.dart';

class SidebarWidget extends StatelessWidget {
  final String appTitle;
  final Map<String, dynamic> menuItem; // Chỉ dùng 1 mục
  final bool isSelected;
  final VoidCallback onItemTap;

  const SidebarWidget({
    super.key,
    required this.appTitle,
    required this.menuItem,
    this.isSelected = true, // Mặc định chọn sẵn
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Color(0xFF1F2A44),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.transparent,
                child: Row(
                  children: [
                    Icon(
                      Icons.school,
                      size: 60,
                      color: Colors.white,
                    ),
                    // Text('VNClass',
                    //     style: TextStyle(color: Colors.white, fontSize: 50)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildMenuItem(
            icon: menuItem['icon'],
            label: menuItem['label'],
            isSelected: isSelected,
            onTap: onItemTap,
          ),
          const Spacer(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white70,
            size: 24,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
