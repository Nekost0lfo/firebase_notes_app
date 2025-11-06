import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _createNote() async {
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();

    if (title.isEmpty) {
      _showSnackBar('Заголовок не может быть пустым');
      return;
    }

    try {
      final Timestamp now = Timestamp.now();
      await _db.collection('notes').add({
        'title': title,
        'content': content,
        'createdAt': now,
        'updatedAt': now,
      });
      
      _titleController.clear();
      _contentController.clear();
      if (mounted) Navigator.pop(context);
      _showSnackBar('Заметка создана');
    } catch (e) {
      _showSnackBar('Ошибка при создании заметки: $e');
    }
  }

  Future<void> _updateNote(DocumentReference ref, String title, String content) async {
    if (title.isEmpty) {
      _showSnackBar('Заголовок не может быть пустым');
      return;
    }

    try {
      await ref.update({
        'title': title,
        'content': content,
        'updatedAt': Timestamp.now(),
      });
      if (mounted) Navigator.pop(context);
      _showSnackBar('Заметка обновлена');
    } catch (e) {
      _showSnackBar('Ошибка при обновлении заметки: $e');
    }
  }

  Future<void> _deleteNote(DocumentReference ref) async {
    try {
      await ref.delete();
      _showSnackBar('Заметка удалена');
    } catch (e) {
      _showSnackBar('Ошибка при удалении заметки: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openCreateDialog() {
    _titleController.clear();
    _contentController.clear();
    
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Новая заметка'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Заголовок',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Текст заметки',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: _createNote,
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _openEditDialog(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    final TextEditingController titleController = 
        TextEditingController(text: data['title']?.toString() ?? '');
    final TextEditingController contentController = 
        TextEditingController(text: data['content']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Редактировать заметку'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Заголовок',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Текст заметки',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => _updateNote(
              doc.reference,
              titleController.text.trim(),
              contentController.text.trim(),
            ),
            child: const Text('Обновить'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(DocumentReference ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Удалить заметку?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              _deleteNote(ref);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> notesStream = 
        _db.collection('notes').orderBy('createdAt', descending: true).snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Notes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notesStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка загрузки: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final List<DocumentSnapshot> docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Пока нет заметок',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Нажмите + чтобы создать первую заметку'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (BuildContext context, int index) => 
                const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              final DocumentSnapshot doc = docs[index];
              final Map<String, dynamic> data = 
                  doc.data() as Map<String, dynamic>? ?? {};
              
              final String title = data['title']?.toString() ?? '(без названия)';
              final String content = data['content']?.toString() ?? '';
              final Timestamp? createdAt = data['createdAt'] as Timestamp?;
              
              String formattedDate = 'Дата неизвестна';
              if (createdAt != null) {
                formattedDate = '${createdAt.toDate().day}.${createdAt.toDate().month}.${createdAt.toDate().year}';
              }

              return Card(
                elevation: 2,
                child: ListTile(
                  title: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (content.isNotEmpty) ...[
                        Text(
                          content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _openEditDialog(doc),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(doc.reference),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}