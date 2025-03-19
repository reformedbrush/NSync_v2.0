import 'package:flutter/material.dart';
import 'package:nsync_stud/main.dart';

class JoinClubs extends StatefulWidget {
  const JoinClubs({super.key});

  @override
  State<JoinClubs> createState() => _JoinClubsState();
}

class _JoinClubsState extends State<JoinClubs> {
  List<Map<String, dynamic>> clubList = [];

  //select

  Future<void> fetchClub() async {
    try {
      // Step 1: Get the current user's ID
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        print("No user logged in");
        return;
      }

      // Step 2: Fetch clubs the user is a member of
      final memberResponse = await supabase
          .from('tbl_members')
          .select('club_id')
          .eq('student_id', currentUserId);

      // Extract the list of club IDs the user is a member of
      final userClubIds =
          (memberResponse as List)
              .map((member) => member['club_id'])
              .toSet(); // Use a Set to avoid duplicates

      // Step 3: Fetch all clubs
      final clubResponse = await supabase.from('tbl_club').select();

      // Step 4: Filter out clubs the user is a member of
      final List<Map<String, dynamic>> data =
          (clubResponse as List)
              .map((club) => Map<String, dynamic>.from(club))
              .where((club) => !userClubIds.contains(club['club_id']))
              .toList();

      // Debug: Print the response
      print("Clubs I'm not a member of: $data");

      // Step 5: Update the state with the filtered list
      setState(() {
        clubList = data;
      });
    } catch (e) {
      print("ERROR FETCHING CLUBS: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchClub();
  }

  Future<void> joinClub(int id) async {
    try {
      await supabase.from('tbl_members').insert({'club_id': id});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Club joined')));
      Navigator.pop(context, true);
    } catch (e) {
      print("Error Joining club: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Text(
                "Join Clubs",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: clubList.length,
                itemBuilder: (context, index) {
                  final club = clubList[index];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: (Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 242, 242, 242),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              club['club_name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              joinClub(club['club_id']);
                            },
                            child: Text("Join"),
                          ),
                        ],
                      ),
                    )),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF161616),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 150,
                      vertical: 18,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Return",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
