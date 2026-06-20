import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../auth/presentation/views/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color primaryColor = const Color(0xFF142175);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AuthViewModel>();
      if (vm.currentUser == null) {
        vm.loadProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final user = vm.currentUser;

    if (vm.isLoading && user == null) {
      return const SafeArea(
        child: Center(child: CircularProgressIndicator()),
      );
    }

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
                boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 5))]
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
                  Text(user?.username ?? 'Usuario', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? 'correo@ejemplo.com', style: const TextStyle(color: Color(0xFF454651))),
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
                GestureDetector(
                  onTap: user == null
                      ? null
                      : () => _showEditProfileDialog(
                            context,
                            currentAge: user.age,
                            currentOccupation: user.occupation,
                          ),
                  child: const Text('Editar', style: TextStyle(color: Color(0xFF5a55a2), fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildListTile(Icons.person, 'Usuario', user?.username ?? '-'),
                  const Divider(height: 1),
                  _buildListTile(Icons.cake, 'Edad', user?.age != null ? '${user!.age} años' : '-'),
                  const Divider(height: 1),
                  _buildListTile(Icons.work, 'Ocupación', user?.occupation ?? '-'),
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
                    trailing: Switch(value: true, activeThumbColor: const Color(0xFF5a55a2), onChanged: (val) {}),
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
              onPressed: () async {
                await vm.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
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

  void _showEditProfileDialog(BuildContext context, {int? currentAge, String? currentOccupation}) {
    final ageController = TextEditingController(text: currentAge?.toString() ?? '');
    final occupationController = TextEditingController(text: currentOccupation ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Actualizar perfil'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Edad'),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) return 'Edad inválida';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: occupationController,
                  decoration: const InputDecoration(labelText: 'Ocupación'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Campo requerido' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final authVm = context.read<AuthViewModel>();
                final nav = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(context);

                final ok = await authVm.updateProfile(
                      int.parse(ageController.text.trim()),
                      occupationController.text.trim(),
                    );

                if (!mounted || !dialogContext.mounted) return;

                nav.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Perfil actualizado' : (authVm.errorMessage ?? 'No se pudo actualizar')),
                    backgroundColor: ok ? Colors.green : Colors.redAccent,
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}