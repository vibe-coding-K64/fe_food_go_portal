import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data/services/image_upload_service.dart';

class ImageUploadField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool required;
  final String? Function(String?)? validator;
  final String folderPath;

  const ImageUploadField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.required = false,
    this.validator,
    this.folderPath = 'uploads',
  });

  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  final ImageUploadService _uploadService = ImageUploadService();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  Uint8List? _localImageBytes;

  Future<void> _pickAndUpload() async {
    final file = await _uploadService.pickImage();
    if (file == null) return;

    final bytes = await file.readAsBytes();

    setState(() {
      _isUploading = true;
      _localImageBytes = bytes;
    });

    try {
      final url = await _uploadService.uploadImage(file, folderPath: widget.folderPath);
      widget.controller.text = url;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label + (widget.required ? ' (*)' : ''),
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FormField<String>(
            initialValue: widget.controller.text,
            validator: (v) {
              final text = widget.controller.text;
              if (widget.required && text.trim().isEmpty) {
                return 'Vui lòng tải lên ${widget.label.toLowerCase()}';
              }
              if (widget.validator != null) {
                return widget.validator!(text);
              }
              return null;
            },
            builder: (FormFieldState<String> state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: state.hasError ? Colors.red : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFF9F9F9),
                    ),
                    child: Row(
                      children: [
                        // Image Preview
                        InkWell(
                          onTap: _isUploading
                              ? null
                              : () async {
                                  await _pickAndUpload();
                                  state.didChange(widget.controller.text);
                                  state.validate();
                                },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _isUploading
                                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B35)))
                                  : _localImageBytes != null
                                      ? Image.memory(
                                          _localImageBytes!,
                                          fit: BoxFit.cover,
                                        )
                                      : widget.controller.text.isNotEmpty
                                          ? Image.network(
                                              widget.controller.text,
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(Icons.image_outlined, color: Colors.grey, size: 30),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Action Buttons
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _isUploading
                                    ? null
                                    : () async {
                                        await _pickAndUpload();
                                        state.didChange(widget.controller.text);
                                        state.validate();
                                      },
                                icon: const Icon(Icons.upload_file, size: 16),
                                label: Text(widget.controller.text.isEmpty ? 'Tải ảnh lên' : 'Đổi ảnh khác'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B35),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Định dạng: JPG, PNG. Tối đa 5MB.',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        state.errorText!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
