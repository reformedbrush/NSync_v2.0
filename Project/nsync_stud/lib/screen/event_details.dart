import 'package:flutter/material.dart';
import 'package:nsync_stud/main.dart';

class EventDetails extends StatefulWidget {
  final int id;
  const EventDetails({super.key, required this.id});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  Map<String, dynamic> eventData = {};
  bool isRegistered = false;
  bool isLoading = true;

  Future<void> fetchEvent() async {
    try {
      final response =
          await supabase
              .from('tbl_events')
              .select()
              .eq('event_id', widget.id)
              .single();
      setState(() {
        eventData = response;
      });
    } catch (e) {
      print("Error Event: $e");
    }
  }

  Future<void> checkRegistration() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase
            .from('tbl_participants')
            .select()
            .eq('event_id', widget.id)
            .eq('student_id', user.id);

        setState(() {
          isRegistered = response.isNotEmpty;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error Checking Registration: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> registerEvent() async {
    try {
      setState(() {
        isLoading = true;
      });

      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('tbl_participants').insert({
          'event_id': widget.id,
          'student_id': user.id,
        });

        setState(() {
          isRegistered = true;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully registered for the event"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error Registering Event: $e");
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to register for the event"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEvent().then((_) => checkRegistration());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button and title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Tickets',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Event Ticket Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // Upper part of the ticket
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Event Poster
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child:
                                    eventData['event_poster'] != null &&
                                            eventData['event_poster'].isNotEmpty
                                        ? Image.network(
                                          eventData['event_poster'],
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              height: 150,
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Text(
                                                  'Failed to load poster',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                        : Container(
                                          height: 150,
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Text(
                                              'No poster available',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                eventData['event_name'] ?? 'Event Name',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                eventData['event_venue'] ?? 'Venue',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        eventData['event_fordate'] ?? 'Date',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        'Date',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '8 PM',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        'Time',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Lower part of the ticket
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Event Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                eventData['event_details'] ??
                                    'No details available',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              // Registration button
                              Center(
                                child: Column(
                                  children: [
                                    isLoading
                                        ? const CircularProgressIndicator()
                                        : GestureDetector(
                                          onTap:
                                              isRegistered
                                                  ? null
                                                  : () {
                                                    registerEvent();
                                                  },
                                          child: Container(
                                            height: 40,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              color:
                                                  isRegistered
                                                      ? Colors.grey
                                                      : Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Center(
                                              child: Text(
                                                isRegistered
                                                    ? 'Already Registered'
                                                    : 'Register',
                                                style: TextStyle(
                                                  color:
                                                      isRegistered
                                                          ? Colors.black
                                                          : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
