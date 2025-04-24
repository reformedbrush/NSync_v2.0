import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nsync_stud/main.dart'; // Assuming supabase is initialized here

class NewsletterDetails extends StatefulWidget {
  final int newsId;

  const NewsletterDetails({super.key, required this.newsId});

  @override
  State<NewsletterDetails> createState() => _NewsletterDetailsState();
}

class _NewsletterDetailsState extends State<NewsletterDetails> {
  Map<String, dynamic>? _newsletter;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNewsletterDetails();
  }

  Future<void> _fetchNewsletterDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response =
          await supabase
              .from('tbl_newsletter')
              .select()
              .eq('id', widget.newsId)
              .single();

      setState(() {
        _newsletter = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching newsletter: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Newsletter Details'),
        backgroundColor: Colors.black,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Newsletter Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        _newsletter?['newsletter_image'] ??
                            'https://via.placeholder.com/400',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text('Image not available'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      _newsletter?['newsletter_title'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Date
                    Text(
                      _newsletter?['created_at'] != null
                          ? DateFormat(
                            'dd-MM-yyyy HH:mm',
                          ).format(DateTime.parse(_newsletter!['created_at']))
                          : 'No Date',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    // Author
                    Text(
                      'By ${_newsletter?['newsletter_author'] ?? 'Unknown Author'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Content
                    Text(
                      _newsletter?['newsletter_content'] ??
                          'No content available',
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
    );
  }
}
