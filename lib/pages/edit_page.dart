import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/social_icons.dart';
import '../models/post_model.dart';
import '../models/social_model.dart';
import '../utils/app_theme.dart';
import '../utils/icon_helper.dart';
import '../utils/url_data_helper.dart';
import '../widgets/color_picker.dart';
import '../widgets/social_icon_picker.dart';

class EditPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const EditPage({super.key, this.initialData});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _imageCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _customUrlCtrl = TextEditingController();
  final _existingLinkCtrl = TextEditingController();

  final List<SocialModel> _socials = [];
  final List<PostModel> _posts = [];
  String? _selectedPageColor;
  String? _generatedLink;

  @override
  void initState() {
    super.initState();
    _loadInitial(widget.initialData);
  }

  @override
  void dispose() {
    _imageCtrl.dispose();
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _descriptionCtrl.dispose();
    _customUrlCtrl.dispose();
    _existingLinkCtrl.dispose();
    super.dispose();
  }

  void _loadInitial(Map<String, dynamic>? data) {
    if (data == null) return;
    final profile = data['profile'];
    final socials = List<Map<String, dynamic>>.from(data['socials'] ?? []);
    final posts = List<Map<String, dynamic>>.from(data['posts'] ?? []);

    _imageCtrl.text = profile['image'] ?? '';
    _nameCtrl.text = profile['name'] ?? '';
    _surnameCtrl.text = profile['surname'] ?? '';
    _descriptionCtrl.text = profile['description'] ?? '';
    _customUrlCtrl.text = profile['customProfileUrl'] ?? '';
    _selectedPageColor = profile['pageColor'];

    _socials.clear();
    for (int i = 0; i < socials.length; i++) {
      _socials.add(SocialModel.fromJson(socials[i]).copyWith(order: i));
    }

    _posts.clear();
    for (int i = 0; i < posts.length; i++) {
      _posts.add(PostModel.fromJson(posts[i]).copyWith(order: i));
    }
  }

  void _loadFromLink() {
    final input = _existingLinkCtrl.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or paste a link')),
      );
      return;
    }

    String? encoded;

    // Try to parse as URI first
    final uri = Uri.tryParse(input);
    if (uri != null) {
      // Check if it has 'd' query parameter
      encoded = uri.queryParameters['d'];
      // Also check if the path contains the encoded data (for hash-based routing)
      if (encoded == null && uri.path.contains('?d=')) {
        final match = RegExp(r'[?&]d=([^&]+)').firstMatch(input);
        encoded = match?.group(1);
      }
      // Also check fragment (for hash routing like #/view?d=...)
      if (encoded == null && uri.fragment.isNotEmpty) {
        final fragmentUri = Uri.tryParse('?${uri.fragment}');
        encoded = fragmentUri?.queryParameters['d'];
      }
    }

    // If still no encoded data, try treating the entire input as base64
    if (encoded == null) {
      // Try to decode the input directly (might be just the encoded string)
      final testDecode = UrlDataHelper.decode(input);
      if (testDecode != null) {
        encoded = input;
      }
    }

    if (encoded == null || encoded.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not find encoded data in the link. Please paste the full link.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final data = UrlDataHelper.decode(encoded);
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not decode link data. The link may be invalid or corrupted.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _socials.clear();
      _posts.clear();
      _loadInitial(data);
      _existingLinkCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile loaded successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _generateLink() {
    if (_nameCtrl.text.trim().isEmpty || _surnameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name and surname')),
      );
      return;
    }

    final profile = {
      'image': _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
      'name': _nameCtrl.text.trim(),
      'surname': _surnameCtrl.text.trim(),
      'description': _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      'pageColor': _selectedPageColor,
      'customProfileUrl': _customUrlCtrl.text.trim().isEmpty
          ? null
          : _customUrlCtrl.text.trim(),
    };

    final socials = _socials.map((s) => s.toJson()).toList();

    final posts = _posts.map((p) => p.toJson()).toList();

    final data = {'profile': profile, 'socials': socials, 'posts': posts};
    final encoded = UrlDataHelper.encode(data);

    // Use custom URL if provided, otherwise generate
    final link = _customUrlCtrl.text.trim().isNotEmpty
        ? _customUrlCtrl.text.trim()
        : '${Uri.base.origin}/#/view?d=$encoded';

    setState(() {
      _generatedLink = link;
    });
  }

  void _addSocial() {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    String? selectedIcon;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Social Link'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 1: Enter link details',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: AppTheme.compactInputDecoration(
                    'Link Title *',
                    hint: 'e.g., My Instagram',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlCtrl,
                  decoration: AppTheme.compactInputDecoration(
                    'URL *',
                    hint: 'https://instagram.com/username',
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (value) {
                    // Auto-detect icon from URL if icon not selected
                    if (value.isNotEmpty && selectedIcon == null) {
                      final icon = SocialIcons.getIconForUrl(value);
                      if (icon != null) {
                        setDialogState(() {
                          selectedIcon = icon;
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Step 2: Select icon (optional)'),
                const SizedBox(height: 8),
                SocialIconPicker(
                  selectedIcon: selectedIcon,
                  onIconSelected: (icon) {
                    setDialogState(() {
                      selectedIcon = icon;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final url = urlCtrl.text.trim();

                if (url.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('URL is required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Validate URL format
                if (!url.startsWith('http://') && !url.startsWith('https://')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('URL must start with http:// or https://'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() {
                  _socials.add(
                    SocialModel(
                      name: name.isEmpty ? 'Social Link' : name,
                      url: url,
                      iconName: selectedIcon,
                      order: _socials.length,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Add Link'),
            ),
          ],
        ),
      ),
    );
  }

  void _addPost() {
    final typeCtrl = TextEditingController(text: 'note');
    final textCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    String selectedType = 'note';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 1: Select post type',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: AppTheme.compactInputDecoration('Post Type *'),
                  items: const [
                    DropdownMenuItem(value: 'note', child: Text('Note/Text')),
                    DropdownMenuItem(value: 'youtube', child: Text('YouTube')),
                    DropdownMenuItem(value: 'tiktok', child: Text('TikTok')),
                    DropdownMenuItem(
                      value: 'twitter',
                      child: Text('X/Twitter'),
                    ),
                    DropdownMenuItem(
                      value: 'link',
                      child: Text('Generic Link'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedType = value ?? 'note';
                      typeCtrl.text = selectedType;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  selectedType == 'note'
                      ? 'Step 2: Enter your note text'
                      : 'Step 2: Enter the URL',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedType == 'note')
                  TextField(
                    controller: textCtrl,
                    decoration: AppTheme.compactInputDecoration(
                      'Note Text *',
                      hint: 'Write your note here...',
                    ),
                    maxLines: 5,
                    autofocus: true,
                  )
                else
                  TextField(
                    controller: urlCtrl,
                    decoration: AppTheme.compactInputDecoration(
                      'URL *',
                      hint: 'https://...',
                    ),
                    keyboardType: TextInputType.url,
                    autofocus: true,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedType == 'note') {
                  if (textCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Note text is required'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                } else {
                  final url = urlCtrl.text.trim();
                  if (url.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('URL is required'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (!url.startsWith('http://') &&
                      !url.startsWith('https://')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'URL must start with http:// or https://',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }

                setState(() {
                  _posts.add(
                    PostModel(
                      type: selectedType,
                      text: selectedType == 'note'
                          ? (textCtrl.text.trim().isEmpty
                                ? null
                                : textCtrl.text.trim())
                          : null,
                      url: selectedType == 'note'
                          ? null
                          : (urlCtrl.text.trim().isEmpty
                                ? null
                                : urlCtrl.text.trim()),
                      order: _posts.length,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Add Post'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteSocial(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Link'),
        content: const Text('Are you sure you want to delete this link?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _socials.removeAt(index);
                // Reorder
                for (int i = 0; i < _socials.length; i++) {
                  _socials[i] = _socials[i].copyWith(order: i);
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deletePost(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _posts.removeAt(index);
                // Reorder
                for (int i = 0; i < _posts.length; i++) {
                  _posts[i] = _posts[i].copyWith(order: i);
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editSocial(int index) {
    final social = _socials[index];
    final nameCtrl = TextEditingController(text: social.name);
    final urlCtrl = TextEditingController(text: social.url);
    String? selectedIcon = social.iconName;
    bool enabled = social.enabled;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Link'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: AppTheme.compactInputDecoration('Link Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlCtrl,
                  decoration: AppTheme.compactInputDecoration('URL'),
                ),
                const SizedBox(height: 16),
                const Text('Select Icon:'),
                const SizedBox(height: 8),
                SocialIconPicker(
                  selectedIcon: selectedIcon,
                  onIconSelected: (icon) {
                    setDialogState(() {
                      selectedIcon = icon;
                    });
                  },
                ),
                if (urlCtrl.text.isNotEmpty && selectedIcon == null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      final icon = SocialIcons.getIconForUrl(urlCtrl.text);
                      if (icon != null) {
                        setDialogState(() {
                          selectedIcon = icon;
                        });
                      }
                    },
                    child: const Text('Auto-detect from URL'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final url = urlCtrl.text.trim();

                if (url.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('URL is required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Validate URL format
                if (!url.startsWith('http://') && !url.startsWith('https://')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('URL must start with http:// or https://'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() {
                  _socials[index] = social.copyWith(
                    name: name.isEmpty ? 'Social Link' : name,
                    url: url,
                    iconName: selectedIcon,
                    enabled: enabled,
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _editPost(int index) {
    final post = _posts[index];
    final typeCtrl = TextEditingController(text: post.type);
    final textCtrl = TextEditingController(text: post.text ?? '');
    final urlCtrl = TextEditingController(text: post.url ?? '');
    bool enabled = post.enabled;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: typeCtrl.text.isEmpty ? 'note' : typeCtrl.text,
                  decoration: AppTheme.compactInputDecoration('Post Type'),
                  items: const [
                    DropdownMenuItem(value: 'note', child: Text('Note/Text')),
                    DropdownMenuItem(value: 'youtube', child: Text('YouTube')),
                    DropdownMenuItem(value: 'tiktok', child: Text('TikTok')),
                    DropdownMenuItem(
                      value: 'twitter',
                      child: Text('X/Twitter'),
                    ),
                    DropdownMenuItem(
                      value: 'link',
                      child: Text('Generic Link'),
                    ),
                  ],
                  onChanged: (value) {
                    typeCtrl.text = value ?? 'note';
                  },
                ),
                const SizedBox(height: 16),
                if (typeCtrl.text == 'note')
                  TextField(
                    controller: textCtrl,
                    decoration: AppTheme.compactInputDecoration('Note Text'),
                    maxLines: 5,
                  ),
                if (typeCtrl.text != 'note') ...[
                  TextField(
                    controller: urlCtrl,
                    decoration: AppTheme.compactInputDecoration('URL'),
                  ),
                  if (typeCtrl.text == 'note') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: textCtrl,
                      decoration: AppTheme.compactInputDecoration(
                        'Optional Description',
                      ),
                      maxLines: 2,
                    ),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final type = typeCtrl.text;

                // Validate based on type
                if (type == 'note') {
                  if (textCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Note text is required'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                } else {
                  final url = urlCtrl.text.trim();
                  if (url.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('URL is required'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (!url.startsWith('http://') &&
                      !url.startsWith('https://')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'URL must start with http:// or https://',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }

                setState(() {
                  _posts[index] = post.copyWith(
                    type: type,
                    text: type == 'note'
                        ? (textCtrl.text.trim().isEmpty
                              ? null
                              : textCtrl.text.trim())
                        : null,
                    url: type == 'note'
                        ? null
                        : (urlCtrl.text.trim().isEmpty
                              ? null
                              : urlCtrl.text.trim()),
                    enabled: enabled,
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostingServiceChip(String name, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade300, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.open_in_new, size: 14, color: Colors.blue.shade700),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialsSection() {
    if (_socials.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.link_off, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No links yet',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _addSocial,
                icon: const Icon(Icons.add),
                label: const Text('Add Link'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Links',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            OutlinedButton.icon(
              onPressed: _addSocial,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add link'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = _socials.removeAt(oldIndex);
              _socials.insert(newIndex, item);
              // Update orders
              for (int i = 0; i < _socials.length; i++) {
                _socials[i] = _socials[i].copyWith(order: i);
              }
            });
          },
          children: _socials.asMap().entries.map((entry) {
            final index = entry.key;
            final social = entry.value;
            return Card(
              key: ValueKey(social.order),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.drag_handle,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: IconHelper.buildIconWidget(
                        social.iconName,
                        size: 28,
                        fallbackColor: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            social.name.isEmpty ? 'New Link' : social.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            social.url,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _editSocial(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.red.shade400,
                      onPressed: () => _deleteSocial(index),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPostsSection() {
    if (_posts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.article_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No posts yet',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _addPost,
                icon: const Icon(Icons.add),
                label: const Text('Add Post'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Posts', style: Theme.of(context).textTheme.titleLarge),
            OutlinedButton.icon(
              onPressed: _addPost,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Post'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = _posts.removeAt(oldIndex);
              _posts.insert(newIndex, item);
              // Update orders
              for (int i = 0; i < _posts.length; i++) {
                _posts[i] = _posts[i].copyWith(order: i);
              }
            });
          },
          children: _posts.asMap().entries.map((entry) {
            final index = entry.key;
            final post = entry.value;
            return Card(
              key: ValueKey(post.order),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.drag_handle, color: Colors.grey.shade400),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${post.type.toUpperCase()} Post',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () => _editPost(index),
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                          if (post.url != null && post.url!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              post.url!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (post.text != null && post.text!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              post.text!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _editPost(index),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                                color: Colors.red.shade400,
                                onPressed: () => _deletePost(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Link in bio', style: AppTheme.brandingTextStyle),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Load existing link section
            Card(
              color: Colors.blue.shade50,
              child: ExpansionTile(
                title: Row(
                  children: [
                    Icon(Icons.link, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Edit Existing Profile',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                subtitle: const Text(
                  'Paste your link here to load and edit',
                  style: TextStyle(fontSize: 12),
                ),
                initiallyExpanded: false,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paste your full link (works with any domain):',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _existingLinkCtrl,
                          decoration: AppTheme.compactInputDecoration(
                            'Link',
                            hint: 'https://... or just paste the encoded data',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _loadFromLink,
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('Load Profile'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Profile section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _imageCtrl,
                            decoration: AppTheme.compactInputDecoration(
                              'Profile Image URL (Optional)',
                              hint: 'Paste image URL here',
                            ),
                            keyboardType: TextInputType.url,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'How to get a profile image URL:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '1. Upload your image to a free image hosting service\n'
                            '2. Copy the direct image URL\n'
                            '3. Paste it in the field above',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Recommended free image hosting services:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildHostingServiceChip(
                                'Imgur',
                                'https://imgur.com',
                              ),
                              _buildHostingServiceChip(
                                'ImgBB',
                                'https://imgbb.com',
                              ),
                              _buildHostingServiceChip(
                                'Postimage',
                                'https://postimg.cc',
                              ),
                              _buildHostingServiceChip(
                                'FreeImage',
                                'https://freeimage.host',
                              ),
                              _buildHostingServiceChip(
                                'ImgBox',
                                'https://imgbox.com',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameCtrl,
                      decoration: AppTheme.compactInputDecoration('Name'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _surnameCtrl,
                      decoration: AppTheme.compactInputDecoration('Surname'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionCtrl,
                      decoration: AppTheme.compactInputDecoration(
                        'Description (Optional)',
                        hint: 'A short bio or tagline about you',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Page Color',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ColorPickerWidget(
                      selectedValue: _selectedPageColor,
                      onColorSelected: (value) {
                        setState(() {
                          _selectedPageColor = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _customUrlCtrl,
                      decoration: AppTheme.compactInputDecoration(
                        'Custom Profile URL (Optional)',
                        hint: 'Leave empty to use generated URL',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Socials section
            _buildSocialsSection(),
            const SizedBox(height: 32),
            // Posts section
            _buildPostsSection(),
            const SizedBox(height: 32),
            // Generate link button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generateLink,
                child: const Text('Generate Link'),
              ),
            ),
            if (_generatedLink != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Link:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        _generatedLink!,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Share.share(_generatedLink!);
                              },
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Share'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: _generatedLink!),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Link copied to clipboard!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 18),
                              label: const Text('Copy'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
