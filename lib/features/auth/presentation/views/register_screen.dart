import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  bool _isLoading = false;

  final Color primaryColor = const Color(0xFF142175);

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology, size: 32, color: primaryColor),
                const SizedBox(height: 16),
                const Text('Comienza tu viaje', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC6C5D3).withOpacity(0.3)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Nombre(s)', 
                                controller: _firstNameController, 
                                icon: Icons.person_outline, 
                                hint: 'Alejandro',
                                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                              )
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                label: 'Apellidos', 
                                controller: _lastNameController, 
                                icon: Icons.person_outline, 
                                hint: 'Martínez',
                                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                              )
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Nombre de usuario', 
                          controller: _usernameController, 
                          icon: Icons.alternate_email, 
                          hint: 'admin_user',
                          validator: (val) => val == null || val.length < 4 ? 'Mínimo 4 caracteres' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Correo electrónico', 
                          controller: _emailController, 
                          icon: Icons.mail_outline, 
                          hint: 'tu@email.com',
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Requerido';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                              return 'Ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: (val) {
                            if (val == null || val.length < 8) return 'Debe tener al menos 8 caracteres';
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Mínimo 8 caracteres',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F5),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Checkbox(
                              value: _acceptedTerms,
                              activeColor: primaryColor,
                              onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                            ),
                            const Expanded(child: Text('Acepto los Términos de Servicio y la Política de Privacidad.', style: TextStyle(fontSize: 14))),
                          ],
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton.icon(
                          onPressed: (!_acceptedTerms || _isLoading) ? null : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);

                              final viewModel = context.read<AuthViewModel>();
                              final success = await viewModel.register(
                                _usernameController.text.trim(),
                                _firstNameController.text.trim(),
                                _lastNameController.text.trim(),
                                _emailController.text.trim(),
                                _passwordController.text,
                              );
                              
                              if (!context.mounted) return;
                              setState(() => _isLoading = false);

                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('¡Cuenta creada con éxito! Por favor inicia sesión.'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(viewModel.errorMessage ?? 'Ocurrió un error al registrar'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                          icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.arrow_forward),
                          label: _isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Crear mi cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes una cuenta? '),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('Inicia sesión aquí', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label, 
    required TextEditingController controller, 
    required IconData icon, 
    required String hint,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: const Color(0xFFF3F4F5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}