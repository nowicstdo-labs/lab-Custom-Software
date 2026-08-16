import 'package:flutter/material.dart';
import 'camera_preview_widget.dart';

class ImagePickerDialog extends StatefulWidget {
  final String title;
  final ValueChanged<String> onImageSelected;

  const ImagePickerDialog({
    super.key,
    this.title = 'Upload Document or Photo',
    required this.onImageSelected,
  });

  static Future<void> show(
    BuildContext context, {
    String title = 'Upload Document or Photo',
    required ValueChanged<String> onImageSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImagePickerDialog(
        title: title,
        onImageSelected: onImageSelected,
      ),
    );
  }

  @override
  State<ImagePickerDialog> createState() => _ImagePickerDialogState();
}

class _ImagePickerDialogState extends State<ImagePickerDialog> {
  bool _isTakingPhoto = false;
  String? _capturedImagePath;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isTakingPhoto) ...[
              if (_capturedImagePath == null)
                CameraPreviewWidget(
                  title: 'Capture Photo',
                  isScannerMode: false,
                  onPhotoCaptured: (path) {
                    setState(() => _capturedImagePath = path);
                  },
                )
              else
                Column(
                  children: [
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF14B8A6), width: 2),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF10B981), size: 48),
                            SizedBox(height: 10),
                            Text('Photo Captured Successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _capturedImagePath = null),
                            child: const Text('Retake'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onImageSelected(_capturedImagePath!);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Use Photo'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ] else ...[
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: Color(0xFF2563EB)),
                ),
                title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Capture using device camera'),
                onTap: () {
                  setState(() => _isTakingPhoto = true);
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: Color(0xFF14B8A6)),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Select photo from local gallery'),
                onTap: () {
                  final mockGalleryPath = 'gallery_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
                  widget.onImageSelected(mockGalleryPath);
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
