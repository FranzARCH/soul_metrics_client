import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayoutScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayoutScreen({super.key, required this.navigationShell});

  final Color primaryColor = const Color(0xFF142175);
  final Color secondaryColor = const Color(0xFF5a55a2);

  // Método para manejar el cambio de pestaña y URL
  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // Mantiene el estado de la pestaña si el usuario hace clic de nuevo
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Nota: Removimos la validación manual del AuthViewModel de aquí,
    // ya que ahora el router centralizado (`redirect`) maneja la seguridad de rutas de forma nativa.

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.psychology, color: primaryColor, size: 32),
            const SizedBox(width: 8),
            Text('SoulMetrics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 24.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/cinna.png'),
              backgroundColor: Colors.grey,
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFC6C5D3).withValues(alpha: 0.3), height: 1.0),
        ),
      ),
      
      // El cuerpo ahora es directamente la rama del Shell (actúa idéntico a IndexedStack de forma interna)
      body: navigationShell,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex, // Sincronizado con la ruta web
          onTap: _onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: secondaryColor,
          unselectedItemColor: const Color(0xFF767682),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.insights_outlined), activeIcon: Icon(Icons.insights), label: 'Resultados'),
            BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Historial'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}