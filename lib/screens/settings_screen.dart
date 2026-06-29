import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'activity_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final email = authProvider.currentUserEmail ?? '';
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Theme Mode Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette, color: primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Theme Mode',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ThemeOptionButton(
                          label: 'System',
                          icon: Icons.brightness_auto,
                          isSelected: settings.themeMode == ThemeMode.system,
                          onTap: () => settings.updateThemeMode(email, 'system'),
                        ),
                        _ThemeOptionButton(
                          label: 'Light',
                          icon: Icons.light_mode,
                          isSelected: settings.themeMode == ThemeMode.light,
                          onTap: () => settings.updateThemeMode(email, 'light'),
                        ),
                        _ThemeOptionButton(
                          label: 'Dark',
                          icon: Icons.dark_mode,
                          isSelected: settings.themeMode == ThemeMode.dark,
                          onTap: () => settings.updateThemeMode(email, 'dark'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Color Palette Selector Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.color_lens, color: primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Primary Theme Color',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ColorSeedOption(
                          color: const Color(0xFF6366F1),
                          name: 'indigo',
                          isSelected: settings.themePalette == 'indigo',
                          onTap: () => settings.updateThemePalette(email, 'indigo'),
                        ),
                        _ColorSeedOption(
                          color: const Color(0xFF10B981),
                          name: 'green',
                          isSelected: settings.themePalette == 'green',
                          onTap: () => settings.updateThemePalette(email, 'green'),
                        ),
                        _ColorSeedOption(
                          color: const Color(0xFFED4C67),
                          name: 'rose',
                          isSelected: settings.themePalette == 'rose',
                          onTap: () => settings.updateThemePalette(email, 'rose'),
                        ),
                        _ColorSeedOption(
                          color: const Color(0xFF009688),
                          name: 'teal',
                          isSelected: settings.themePalette == 'teal',
                          onTap: () => settings.updateThemePalette(email, 'teal'),
                        ),
                        _ColorSeedOption(
                          color: const Color(0xFFFF9F43),
                          name: 'amber',
                          isSelected: settings.themePalette == 'amber',
                          onTap: () => settings.updateThemePalette(email, 'amber'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Currency Selection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.monetization_on, color: primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Display Currency',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF0F172A)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: settings.currencyCode,
                          isExpanded: true,
                          dropdownColor: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                          icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                          items: const [
                            DropdownMenuItem(value: 'USD', child: Text('USD - United States Dollar (\$)')),
                            DropdownMenuItem(value: 'INR', child: Text('INR - Indian Rupee (₹)')),
                            DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro (€)')),
                            DropdownMenuItem(value: 'GBP', child: Text('GBP - British Pound (£)')),
                            DropdownMenuItem(value: 'JPY', child: Text('JPY - Japanese Yen (¥)')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              settings.updateCurrency(email, val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Activity Log Card (Secured)
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.security, color: primaryColor),
                ),
                title: const Text('Activity Log', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('View securely logged app activities'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showPasswordDialog(context, email, authProvider);
                },
              ),
            ),
            const SizedBox(height: 80), // spacer for floating action bar
          ],
        ),
      ),
    );
  }

  Future<void> _showPasswordDialog(BuildContext context, String email, AuthProvider authProvider) async {
    final passwordController = TextEditingController();
    final bool? isVerified = await showDialog<bool>(
      context: context,
      builder: (context) {
        bool isLoading = false;
        String? error;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Security Verification'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Please enter your password to view the Activity Log.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: error,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                  ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() {
                      isLoading = true;
                      error = null;
                    });
                    final success = await authProvider.verifyPassword(email, passwordController.text);
                    if (!context.mounted) return;
                    
                    if (success) {
                      Navigator.of(context).pop(true);
                    } else {
                      setState(() {
                        isLoading = false;
                        error = 'Incorrect password';
                      });
                    }
                  },
                  child: isLoading 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Text('Verify'),
                ),
              ],
            );
          }
        );
      }
    );

    if (isVerified == true && context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityScreen()));
    }
  }
}

class _ThemeOptionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.15)
                : (isDark ? const Color(0xFF0F172A) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4)),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4)),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorSeedOption extends StatelessWidget {
  final Color color;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSeedOption({
    required this.color,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)
                : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}
