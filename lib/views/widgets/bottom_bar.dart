import 'package:flutter/material.dart';

class CurvedBottomBar extends StatelessWidget {
  const CurvedBottomBar(
      {super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const Color c1 = _MyColors.c1;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      
      child: BottomAppBar(
        height: 72,
        color: c1.withOpacity(0.92),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: const CircularNotchedRectangle(),
        notchMargin: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
                icon: Image.asset('images/widgets/home.png',
                    width: 32, height: 32),
                label: 'Beranda',
                active: currentIndex == 0,
                onTap: () => onTap(0)),
            _NavItem(
                icon: Image.asset('images/widgets/transaksi.png',
                    width: 32, height: 32),
                label: 'Transaksi',
                active: currentIndex == 1,
                onTap: () => onTap(1)),
            const SizedBox(width: 48),
            _NavItem(
                icon: Image.asset('images/widgets/koin.png',
                    width: 32, height: 32),
                label: 'Koin',
                active: currentIndex == 3,
                onTap: () => onTap(3)),
            _NavItem(
                icon: Image.asset('images/widgets/profil.png',
                    width: 32, height: 32),
                label: 'Profil',
                active: currentIndex == 4,
                onTap: () => onTap(4)),
          ],
        ),
      ),
    );
  }
}

class CenterActionButton extends StatelessWidget {
  const CenterActionButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  static const Color c1 = _MyColors.c1;
  static const Color c4 = _MyColors.c4;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: c1,
      shape: const CircleBorder(),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: c1,
          shape: BoxShape.circle,
          border: Border.all(color: _MyColors.c3, width: 3),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        alignment: Alignment.center,
        child: Image.asset('images/widgets/pindai.png', width: 32, height: 32),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  static const Color c4 = _MyColors.c4;

  @override
  Widget build(BuildContext context) {
    final Color color = active ? c4 : Colors.black87;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _MyColors {
  static const Color c1 = Color(0xFFFFF8E2);
  static const Color c3 = Color(0xFF798E5E);
  static const Color c4 = Color(0xFF3F5135);
}