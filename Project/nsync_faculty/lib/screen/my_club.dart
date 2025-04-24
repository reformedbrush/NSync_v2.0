import 'package:flutter/material.dart';
import 'package:nsync_faculty/main.dart';
import 'package:nsync_faculty/screen/club_hostev.dart';
import 'package:nsync_faculty/screen/participantlist.dart'; // New import

class MyClub extends StatefulWidget {
  const MyClub({super.key});

  @override
  State<MyClub> createState() => _MyClubState();
}

class _MyClubState extends State<MyClub> {
  List<Map<String, dynamic>> eventlist = [];
  bool isFacultyAssignedToClub = false;

  @override
  void initState() {
    super.initState();
    fetchevent();
  }

  Future<void> fetchevent() async {
    try {
      // Check if faculty is assigned to a club
      final facultyClub =
          await supabase
              .from("tbl_club")
              .select("club_id")
              .eq("faculty_id", supabase.auth.currentUser!.id)
              .maybeSingle();

      setState(() {
        isFacultyAssignedToClub = facultyClub != null;
      });

      if (isFacultyAssignedToClub) {
        final events = await supabase
            .from("tbl_events")
            .select("*, tbl_club(*)")
            .eq("club_id", facultyClub!['club_id']);

        setState(() {
          eventlist = List<Map<String, dynamic>>.from(events);
        });
      }
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            if (isFacultyAssignedToClub)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClubHostev(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Host Event",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF161616),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 18,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 50),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Club Events",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            eventlist.isEmpty
                ? const Center(
                  child: Text(
                    "No events available",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: eventlist.length,
                  itemBuilder: (context, index) {
                    final event = eventlist[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EventParticipants(
                                  eventId: event['event_id'],
                                ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text(
                            event['event_name'] ?? 'Unnamed Event',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Club: ${event['tbl_club']?['club_name'] ?? 'Unknown'}\nDate: ${event['event_fordate'] ?? 'N/A'}',
                          ),
                          trailing: const Icon(Icons.event),
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
