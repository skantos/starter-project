import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PublishArticlePage extends StatefulWidget {
	const PublishArticlePage({super.key});

	@override
	State<PublishArticlePage> createState() => _PublishArticlePageState();
}

class _PublishArticlePageState extends State<PublishArticlePage> {
	final TextEditingController _titleCtrl = TextEditingController();
	final TextEditingController _contentCtrl = TextEditingController();
	final ImagePicker _picker = ImagePicker();
	XFile? _picked;
	bool _loading = false;

	@override
	void dispose() {
		_titleCtrl.dispose();
		_contentCtrl.dispose();
		super.dispose();
	}

	Future<void> _pickImage() async {
		final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
		if (file != null) setState(() => _picked = file);
	}

	Future<void> _publish() async {
		final String title = _titleCtrl.text.trim();
		final String content = _contentCtrl.text.trim();
		if (title.isEmpty || content.isEmpty || _picked == null) {
			ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa título, imagen y contenido')));
			return;
		}
		setState(() => _loading = true);
		try {
			final String id = FirebaseFirestore.instance.collection('articles').doc().id;
			final Reference ref = FirebaseStorage.instance.ref().child('media/articles/$id.jpg');
			await ref.putFile(File(_picked!.path));
			final String url = await ref.getDownloadURL();
			await FirebaseFirestore.instance.collection('articles').doc(id).set({
				'title': title,
				'content': content,
				'thumbnailURL': url,
				'publishedAt': FieldValue.serverTimestamp(),
				'createdAt': FieldValue.serverTimestamp(),
				'updatedAt': FieldValue.serverTimestamp(),
				'status': 'published',
			});
			if (!mounted) return;
			Navigator.pop(context);
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al publicar: $e')));
		} finally {
			if (mounted) setState(() => _loading = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Publish Article')),
			body: SafeArea(
				child: SingleChildScrollView(
					padding: const EdgeInsets.all(16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							TextField(
								controller: _titleCtrl,
								decoration: InputDecoration(
									border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
									hintText: 'Write your title here...'
								),
							),
							const SizedBox(height: 12),
							GestureDetector(
								onTap: _pickImage,
								child: Container(
									height: 180,
									decoration: BoxDecoration(
										borderRadius: BorderRadius.circular(14),
										color: Colors.grey.shade200,
										image: _picked != null
											? DecorationImage(image: FileImage(File(_picked!.path)), fit: BoxFit.cover)
											: null,
									),
								child: _picked == null
									? Center(
										child: Row(
											mainAxisSize: MainAxisSize.min,
											children: const [Icon(Icons.photo), SizedBox(width: 8), Text('Attach Image')],
										),
									)
									: null,
								),
							),
							const SizedBox(height: 12),
							TextField(
								controller: _contentCtrl,
								minLines: 8,
								maxLines: 16,
								decoration: InputDecoration(
									border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
									hintText: 'Add article here, .....',
								),
							),
							const SizedBox(height: 16),
							ElevatedButton.icon(
								onPressed: _loading ? null : _publish,
								icon: const Icon(Icons.arrow_forward),
								label: Text(_loading ? 'Publishing…' : 'Publish Article'),
								style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
							),
						],
					),
				),
			),
		);
	}
}
