// start docker
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

enum _MessageType { user, bot }

class _ChatMessage {
  final _MessageType type;
  final String text;
  final File? image;
  final bool isLoading;

  _ChatMessage({
    required this.type,
    required this.text,
    this.image,
    this.isLoading = false,
  });
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final ApiService _api = ApiService();

  File? _pendingImage;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      type: _MessageType.bot,
      text: "Hi y/n, my name is Ed your assistant!",
    ));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked =
      await _picker.pickImage(source: source, imageQuality: 80);
      if (picked == null) return;
      setState(() => _pendingImage = File(picked.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty && _pendingImage == null) return;
    if (_isSending) return;

    final imageFile = _pendingImage;
    _inputController.clear();
    setState(() {
      _pendingImage = null;
      _isSending = true;
      _messages.add(_ChatMessage(
        type: _MessageType.user,
        text: text,
        image: imageFile,
      ));
      _messages.add(_ChatMessage(
        type: _MessageType.bot,
        text: '',
        isLoading: true,
      ));
    });
    _scrollToBottom();

    try {
      String? base64Image;
      String? mimeType;
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        base64Image = base64Encode(bytes);
        mimeType = 'image/jpeg';
      }
      final response = await _api.sendChatMessage(
        message: text.isNotEmpty ? text : 'What is in this image?',
        base64Image: base64Image,
        mimeType: mimeType,
      );
      final reply = response['reply'] as String? ??
          response['message'] as String? ??
          'No response from server.';
      setState(() {
        _messages.removeLast();
        _messages.add(_ChatMessage(type: _MessageType.bot, text: reply));
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add(_ChatMessage(
          type: _MessageType.bot,
          text: 'Sorry. Please try again.',
        ));
      });
    } finally {
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/prfp.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: Colors.grey.shade300),
            ),
          ),
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Container(
                  color: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Image.asset(
                        'assets/images/character.png',
                        height: 34,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.smart_toy,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '-Ed-',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) => _buildBubble(_messages[i]),
                ),
              ),
              if (_pendingImage != null)
                Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_pendingImage!,
                            height: 56, width: 56, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Image attached',
                            style: TextStyle(color: Colors.white70)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () =>
                            setState(() => _pendingImage = null),
                      ),
                    ],
                  ),
                ),
              Container(
                color: Colors.black87,
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Image.asset(
                          'assets/images/camera.png',
                          height: 26,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: _showImageSourceDialog,
                      ),
                      IconButton(
                        icon: const Icon(Icons.link, color: Colors.white70),
                        onPressed: _showImageSourceDialog,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: TextField(
                            controller: _inputController,
                            minLines: 1,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Ask me..',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isSending
                              ? Icons.hourglass_top
                              : Icons.volume_up_outlined,
                          color: Colors.white,
                        ),
                        onPressed: _isSending ? null : _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.black,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90D9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'back.',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    final isUser = msg.type == _MessageType.user;

    if (msg.isLoading) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8, right: 80),
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(delay: 0),
              const SizedBox(width: 4),
              _Dot(delay: 200),
              const SizedBox(width: 4),
              _Dot(delay: 400),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 10,
          left: isUser ? 60 : 0,
          right: isUser ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF9AE3F0) : Colors.black87,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10),
            bottomLeft: Radius.circular(isUser ? 10 : 2),
            bottomRight: Radius.circular(isUser ? 2 : 10),
          ),
          border: isUser ? Border.all(color: Colors.black26) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(msg.image!,
                    width: 180, height: 130, fit: BoxFit.cover),
              ),
              const SizedBox(height: 6),
            ],
            if (msg.text.isNotEmpty)
              Text(
                msg.text,
                style: TextStyle(
                  color: isUser ? Colors.black87 : Colors.white,
                  fontSize: 13,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Colors.white54,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}