import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final Color primaryColor = const Color(0xFF142175);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))]
              ),
              child: Column(
                children: [
                  const Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(radius: 48, backgroundImage: AssetImage('assets/cinna.png')),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF142175),
                        child: Icon(Icons.edit, color: Colors.white, size: 16),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Sofía Sarmiento', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
                  const SizedBox(height: 4),
                  const Text('sofi@soulmetrics.com', style: TextStyle(color: Color(0xFF454651))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFf3f4f5), borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Color(0xFF1b3129)),
                        SizedBox(width: 8),
                        Text('MIEMBRO DESDE: JUN 2026', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Información Personal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                const Text('Editar todo', style: TextStyle(color: Color(0xFF5a55a2), fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildListTile(Icons.person, 'Nombre Completo', 'Sofía Sarmiento'),
                  const Divider(height: 1),
                  _buildListTile(Icons.cake, 'Edad', '21 años'),
                  const Divider(height: 1),
                  _buildListTile(Icons.work, 'Ocupación', 'Estudiante de Psicología'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text('Configuración de Cuenta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFedeeef), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.notifications, color: Color(0xFF5a55a2))),
                    title: const Text('Notificaciones Push', style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: Switch(value: true, activeColor: const Color(0xFF5a55a2), onChanged: (val) {}),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFedeeef), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.lock_reset, color: Color(0xFF5a55a2))),
                    title: const Text('Cambiar Contraseña', style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, style: BorderStyle.solid),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFedeeef), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}