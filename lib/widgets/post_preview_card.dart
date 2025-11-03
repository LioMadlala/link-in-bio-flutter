import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/preview_fetcher.dart';

class PostPreviewCard extends StatefulWidget {
  final String? url;
  final String? text;
  final String type;
  final Color? cardColor;

  const PostPreviewCard({
    super.key,
    required this.url,
    this.text,
    required this.type,
    this.cardColor,
  });

  @override
  State<PostPreviewCard> createState() => _PostPreviewCardState();
}

class _PostPreviewCardState extends State<PostPreviewCard> {
  PreviewMetadata? _metadata;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPreview();
  }

  Future<void> _fetchPreview() async {
    if (widget.url == null || widget.url!.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final metadata = await PreviewFetcher.fetchMetadata(widget.url!);
      if (mounted) {
        setState(() {
          _metadata = metadata;
          _isLoading = false;
          _hasError = metadata == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _launchUrl() async {
    if (widget.url == null || widget.url!.isEmpty) return;
    final uri = Uri.parse(widget.url!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      String host = uri.host;
      if (host.startsWith('www.')) {
        host = host.substring(4);
      }
      if (host.startsWith('m.')) {
        host = host.substring(2);
      }
      // Capitalize first letter
      if (host.isNotEmpty) {
        return host.substring(0, 1).toUpperCase() +
            host.substring(1).toLowerCase();
      }
      return host;
    } catch (e) {
      return 'Link';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.cardColor ?? Colors.white;
    
    // Text/note post
    if (widget.type == 'note' || widget.type == 'text') {
      return Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.08),
        child: InkWell(
          onTap: _launchUrl,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.text != null && widget.text!.isNotEmpty)
                  Text(
                    widget.text!,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey.shade800,
                    ),
                  ),
                if (widget.url != null && widget.url!.isNotEmpty) ...[
                  if (widget.text != null && widget.text!.isNotEmpty)
                    const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.link, size: 18, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.url!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                              decoration: TextDecoration.underline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // URL-based post with preview
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        onTap: _launchUrl,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview image
              if (_isLoading)
                Container(
                  height: 220,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_metadata?.imageUrl != null && !_hasError)
                Image.network(
                  _metadata!.imageUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      ),
                    );
                  },
                )
              else if (widget.url != null && widget.url!.isNotEmpty)
                Container(
                  height: 220,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.link, size: 48, color: Colors.grey),
                  ),
                ),

              // Preview content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        height: 60,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_metadata != null) ...[
                      if (_metadata!.title != null)
                        Text(
                          _metadata!.title!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (_metadata!.description != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _metadata!.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (_metadata!.siteName != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _metadata!.siteName!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ] else if (widget.text != null && widget.text!.isNotEmpty)
                      Text(
                        widget.text!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      )
                    else if (widget.url != null && widget.url!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _extractDomain(widget.url!),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.link, size: 18, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.url!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue.shade700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
