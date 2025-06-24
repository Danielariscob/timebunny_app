import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ViewProfilePage extends StatefulWidget {
  const ViewProfilePage({super.key});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String _selectedTimezone = 'GMT-05:00 — Lima, Bogotá, Quito';
  bool _isEditing = false;
  File? _profileImage;

  final List<String> _timezones = [
    'GMT-08:00 — Los Angeles, San Francisco',
    'GMT-07:00 — Denver, Phoenix',
    'GMT-06:00 — Chicago, Mexico City',
    'GMT-05:00 — Lima, Bogotá, Quito',
    'GMT-04:00 — Caracas, La Paz',
    'GMT-03:00 — Buenos Aires, Montevideo',
    'GMT-02:00 — South Georgia',
    'GMT-01:00 — Azores',
    'GMT+00:00 — London, Lisbon',
    'GMT+01:00 — Berlin, Paris, Rome',
    'GMT+02:00 — Athens, Cape Town',
    'GMT+03:00 — Istanbul, Nairobi, Moscow',
    'GMT+03:30 — Tehran',
    'GMT+04:00 — Dubai, Baku',
    'GMT+04:30 — Kabul',
    'GMT+05:00 — Islamabad, Tashkent',
    'GMT+05:30 — Mumbai, New Delhi, Colombo',
    'GMT+06:00 — Dhaka, Almaty',
    'GMT+06:30 — Yangon',
    'GMT+07:00 — Bangkok, Jakarta, Hanoi',
    'GMT+08:00 — Beijing, Singapore, Perth',
    'GMT+09:00 — Tokyo, Seoul',
    'GMT+09:30 — Adelaide, Darwin',
    'GMT+10:00 — Sydney, Melbourne, Vladivostok',
    'GMT+11:00 — Solomon Islands, Magadan',
    'GMT+12:00 — Auckland, Fiji',
    'GMT+13:00 — Nukuʻalofa, Apia',
    'GMT+14:00 — Kiritimati Island',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstNameController.text = prefs.getString('first_name') ?? '';
      _lastNameController.text = prefs.getString('last_name') ?? '';
      _selectedTimezone = prefs.getString('timezone') ?? _selectedTimezone;

      final imagePath = prefs.getString('profile_image_path');
      if (imagePath != null && File(imagePath).existsSync()) {
        _profileImage = File(imagePath);
      }
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('first_name', _firstNameController.text.trim());
    await prefs.setString('last_name', _lastNameController.text.trim());
    await prefs.setString('timezone', _selectedTimezone);
    if (_profileImage != null) {
      await prefs.setString('profile_image_path', _profileImage!.path);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', picked.path);
    }
  }

  void _showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFEC729C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFF176), Color(0xFFF48FB1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ClipOval(
                      child:
                          _profileImage != null
                              ? Image.file(_profileImage!, fit: BoxFit.cover)
                              : Image.asset(
                                'assets/default_profile.png',
                                fit: BoxFit.cover,
                              ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _showImageSourceSelector,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFEC729C),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTimezone,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Preferred Time Zone',
                border: OutlineInputBorder(),
              ),
              items:
                  _timezones
                      .map(
                        (tz) => DropdownMenuItem(
                          value: tz,
                          child: Text(
                            tz,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                      )
                      .toList(),
              onChanged:
                  _isEditing
                      ? (val) {
                        setState(() {
                          _selectedTimezone = val!;
                        });
                      }
                      : null,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      _isEditing
                          ? () async {
                            if (_firstNameController.text.trim().isEmpty ||
                                _lastNameController.text.trim().isEmpty) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '❗ Por favor completa todos los campos.',
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            await _saveProfileData();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '✅ Perfil guardado correctamente.',
                                ),
                                backgroundColor: Color(0xFFEC729C),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            setState(() {
                              _isEditing = false;
                            });
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC729C),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                  ),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
