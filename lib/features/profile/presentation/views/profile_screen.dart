import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../auth/presentation/views/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _avatarStorageKey = 'profile_custom_avatar_b64';

  final Color primaryColor = const Color(0xFF142175);
  final ImagePicker _imagePicker = ImagePicker();

  bool pushNotificationsEnabled = true;
  Uint8List? customAvatarBytes;

  void _openEditProfile(AuthViewModel vm) {
    final user = vm.currentUser;
    if (user == null) return;
    _showEditProfileDialog(
      context,
      currentUsername: user.username,
      currentEmail: user.email,
      currentAge: user.age,
      currentOccupation: user.occupation,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AuthViewModel>();
      if (vm.currentUser == null) {
        vm.loadProfile();
      }
      _restoreAvatar();
    });
  }

  Future<void> _restoreAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_avatarStorageKey);
    if (!mounted || stored == null || stored.isEmpty) return;

    setState(() {
      customAvatarBytes = base64Decode(stored);
    });
  }

  Future<void> _pickAvatarFromGallery() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1200,
    );

    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    if (bytes.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarStorageKey, base64Encode(bytes));

    if (!mounted) return;
    setState(() {
      customAvatarBytes = bytes;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto de perfil actualizada.')),
    );
  }

  Future<void> _removeCustomAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_avatarStorageKey);

    if (!mounted) return;
    setState(() {
      customAvatarBytes = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Se restauró la foto de perfil predeterminada.')),
    );
  }

  void _showAvatarOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8F9FA),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC6C5D3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Foto de perfil',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Elige una imagen diferente para personalizar tu cuenta.',
                  style: TextStyle(color: Color(0xFF454651)),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFdfe0ff),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.upload_file, color: primaryColor),
                  ),
                  title: const Text('Subir foto desde galería'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _pickAvatarFromGallery();
                  },
                ),
                if (customAvatarBytes != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8E8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    ),
                    title: const Text('Quitar foto personalizada'),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await _removeCustomAvatar();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
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
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: customAvatarBytes != null
                            ? MemoryImage(customAvatarBytes!)
                            : const AssetImage('assets/cinna.png') as ImageProvider,
                      ),
                      InkWell(
                        onTap: () => _showAvatarOptionsModal(),
                        borderRadius: BorderRadius.circular(16),
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF142175),
                          child: Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
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
                  onTap: user == null ? null : () => _openEditProfile(vm),
                  child: const Text('Editar', style: TextStyle(color: Color(0xFF5a55a2), fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildListTile(
                    Icons.person,
                    'Usuario',
                    user?.username ?? '-',
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    Icons.email_outlined,
                    'Correo',
                    user?.email ?? '-',
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    Icons.cake,
                    'Edad',
                    user?.age != null ? '${user!.age} años' : '-',
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    Icons.work,
                    'Ocupación',
                    user?.occupation ?? '-',
                  ),
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
                    trailing: Switch(
                      value: pushNotificationsEnabled,
                      activeThumbColor: const Color(0xFF5a55a2),
                      onChanged: (val) => setState(() => pushNotificationsEnabled = val),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFedeeef), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.lock_reset, color: Color(0xFF5a55a2))),
                    title: const Text('Cambiar Contraseña', style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Aún no hay endpoint activo para cambio de contraseña.'),
                        ),
                      );
                    },
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
    );
  }

  void _showEditProfileDialog(
    BuildContext context, {
    required String currentUsername,
    required String currentEmail,
    int? currentAge,
    String? currentOccupation,
  }) {
    final usernameController = TextEditingController(text: currentUsername);
    final emailController = TextEditingController(text: currentEmail);
    final ageController = TextEditingController(text: currentAge?.toString() ?? '');
    final occupationController = TextEditingController(text: currentOccupation ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFC6C5D3).withValues(alpha: 0.35)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFdfe0ff),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.manage_accounts, color: primaryColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Actualizar perfil',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Usuario'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Campo requerido';
                      if (value.trim().contains('@')) return 'No uses correo aquí';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Correo'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Campo requerido';
                      if (!value.trim().contains('@')) return 'Correo inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor.withValues(alpha: 0.45)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            final authVm = context.read<AuthViewModel>();
                            final nav = Navigator.of(dialogContext);
                            final messenger = ScaffoldMessenger.of(context);

                            final ok = await authVm.updateProfile(
                                  usernameController.text.trim(),
                                  emailController.text.trim(),
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}