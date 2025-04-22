import 'package:flutter/material.dart';
import 'package:nsync_stud/main.dart';
import 'package:nsync_stud/screen/join_clubs.dart';
import 'package:intl/intl.dart';
import 'package:nsync_stud/screen/event_details.dart';

class StudentClub extends StatefulWidget {
  const StudentClub({super.key});

  @override
  State<StudentClub> createState() => _StudentClubState();
}

class _StudentClubState extends State<StudentClub> {
  List<Map<String, dynamic>> clubList = [];
  Map<String, List<Map<String, dynamic>>> clubEvents = {};

  Future<void> fetchClubs() async {
    try {
      final response = await supabase
          .from('tbl_members')
          .select('*, tbl_club(*)')
          .eq('student_id', supabase.auth.currentUser!.id);

      setState(() {
        clubList = List<Map<String, dynamic>>.from(response);
      });

      // Fetch events for each club
      await fetchClubEvents();
    } catch (e) {
      print("ERROR FETCHING CLUBS: $e");
    }
  }

  Future<void> fetchClubEvents() async {
    try {
      // Get current date for filtering active events
      final currentDate = DateTime.now();
      final currentDateOnly = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );
      final formattedCurrentDate =
          currentDateOnly.toIso8601String().split('T')[0];

      // Create a map to store events for each club
      Map<String, List<Map<String, dynamic>>> tempClubEvents = {};

      // Fetch events for each club
      for (var club in clubList) {
        final clubId =
            club['tbl_club']['club_id'].toString(); // Convert to string
        final response = await supabase
            .from('tbl_events')
            .select(
              'event_id, event_name, event_venue, event_fordate, event_lastdate, created_at',
            )
            .eq('club_id', clubId)
            .gte('event_lastdate', formattedCurrentDate) // Only active events
            .eq('event_status', 1)
            .order('event_fordate', ascending: true);

        tempClubEvents[clubId] =
            List<Map<String, dynamic>>.from(response).map((event) {
              return {
                'event_id':
                    event['event_id']?.toString() ?? '', // Ensure string
                'event_name': event['event_name'] ?? '',
                'event_venue': event['event_venue'] ?? '',
                'event_fordate': event['event_fordate'] ?? '',
                'event_lastdate': event['event_lastdate'] ?? '',
                'created_at': event['created_at'] ?? '',
              };
            }).toList();
      }

      setState(() {
        clubEvents = tempClubEvents;
      });
    } catch (e) {
      print("ERROR FETCHING CLUB EVENTS: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchClubs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child:
            clubList.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 60,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "You have not joined any clubs",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Banner Image Container
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: const DecorationImage(
                            image: AssetImage("./assets/art.jpg"),
                            fit: BoxFit.cover,
                            opacity: 0.9,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "MY CLUBS",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: clubList.length,
                          itemBuilder: (context, index) {
                            final club = clubList[index];
                            final clubId =
                                club['tbl_club']['club_id']
                                    .toString(); // Convert to string
                            final events = clubEvents[clubId] ?? [];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [Colors.blue[50]!, Colors.white],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.group,
                                          color: Colors.blue[700],
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              club['tbl_club']['club_name'] ??
                                                  'Unknown Club',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              club['tbl_club']['description'] ??
                                                  'No description available',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 80), // Space for FAB
                    ],
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const JoinClubs()),
          );
          if (result == true) {
            await fetchClubs(); // Refresh clubs and events after joining
          }
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        label: const Row(
          children: [
            Text(
              "Join Club",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 8),
            Icon(Icons.add, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEventButtonOrStatus(
    BuildContext context,
    Map<String, dynamic> event,
  ) {
    final currentDate = DateTime.now();
    final currentDateOnly = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    DateTime eventDate;
    try {
      eventDate = DateTime.parse(event['event_fordate']);
      eventDate = DateTime(eventDate.year, eventDate.month, eventDate.day);
    } catch (e) {
      return const Text(
        'Invalid event date',
        style: TextStyle(color: Colors.red, fontSize: 12),
      );
    }

    final isEventToday = currentDateOnly == eventDate;

    if (isEventToday) {
      return const Text(
        'Online Registration Closed\nSpot Registration Open',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      );
    } else {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetails(id: event['event_id']),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('View More'),
      );
    }
  }
}
