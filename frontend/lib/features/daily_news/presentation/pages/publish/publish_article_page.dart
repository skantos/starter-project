import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/article.dart';

class PublishArticlePage extends StatefulWidget {
  const PublishArticlePage({super.key});

  @override
  State<PublishArticlePage> createState() => _PublishArticlePageState();
}

class _PublishArticlePageState extends State<PublishArticlePage> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _contentCtrl = TextEditingController();
  final TextEditingController _categoryCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _picked;
  bool _loading = false;
  // Referencia opcional si se extiende a futuro (no usada por ahora)
  // ArticleEntity? _editingArticle;
  String? _editingDocId;
  String? _editingImageUrl;
  bool _prefilled = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) setState(() => _picked = file);
  }

  Future<void> _publish({String? editingId}) async {
    final String title = _titleCtrl.text.trim();
    final String content = _contentCtrl.text.trim();
    final String category = _categoryCtrl.text.trim();
    if (title.isEmpty || content.isEmpty || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2A85FF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: const Text('Completa título, contenido y categoría'),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (editingId != null) {
        // Update existente
        final Map<String, dynamic> data = {
          'title': title,
          'content': content,
          'category': category,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (_picked != null) {
          final String storagePath = 'media/articles/$editingId.jpg';
          final Reference ref = FirebaseStorage.instance.ref().child(storagePath);
          await ref.putFile(File(_picked!.path));
          data['thumbnailURL'] = storagePath;
        }
        await FirebaseFirestore.instance.collection('articles').doc(editingId).update(data);
      } else {
        // Crear nuevo
        final String id = FirebaseFirestore.instance.collection('articles').doc().id;
        final String storagePath = 'media/articles/$id.jpg';
        if (_picked == null) {
          throw Exception('Selecciona una imagen');
        }
        final Reference ref = FirebaseStorage.instance.ref().child(storagePath);
        await ref.putFile(File(_picked!.path));
        // Leer nombre desde users/{uid} para guardarlo junto al artículo
        String authorName = (user?.email ?? 'Anonymous');
        try {
          if (user != null) {
            final prof = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
            final String n = (prof.data()?['name'] ?? '').toString().trim();
            if (n.isNotEmpty) authorName = n;
          }
        } catch (_) {}

        await FirebaseFirestore.instance.collection('articles').doc(id).set({
          'title': title,
          'content': content,
          'category': category,
          'thumbnailURL': storagePath,
          'publishedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'status': 'published',
          'author': authorName,
          'authorId': user?.uid,
          'tags': <String>[],
        });
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Text('Error al publicar: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is ArticleEntity) {
      _editingDocId = args.url; // usamos url como id del doc
      _editingImageUrl = args.urlToImage;
      _titleCtrl.text = args.title ?? '';
      _contentCtrl.text = args.description?.isNotEmpty == true ? args.description! : (args.content ?? '');
      _categoryCtrl.text = args.category ?? '';
      _prefilled = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Publicar Artículo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D2D2D),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Título del artículo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D2D2D),
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2A85FF)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Escribe un título atractivo...',
                  hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Categoría',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _categoryCtrl,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D2D2D),
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2A85FF)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Ej: Tecnología, Deportes, Política...',
                  hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Imagen destacada',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF3F5F7),
                    border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
                  ),
                  child: _picked != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(_picked!.path), fit: BoxFit.cover),
                        )
                      : (_editingImageUrl != null && _editingImageUrl!.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(_editingImageUrl!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE8F4FD),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.photo, size: 28, color: Color(0xFF2A85FF)),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Agregar imagen',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF6E7C87),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Toca para seleccionar una imagen',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF9E9E9E),
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Contenido del artículo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contentCtrl,
                minLines: 8,
                maxLines: 16,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF444444),
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2A85FF)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Escribe el contenido de tu artículo aquí...',
                  hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : () => _publish(editingId: _editingDocId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A85FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Publicar Artículo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}