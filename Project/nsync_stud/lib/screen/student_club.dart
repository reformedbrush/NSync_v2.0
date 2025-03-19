import 'package:flutter/material.dart';
import 'package:nsync_stud/main.dart';
import 'package:nsync_stud/screen/join_clubs.dart';

class StudentClub extends StatefulWidget {
  const StudentClub({super.key});

  @override
  State<StudentClub> createState() => _StudentClubState();
}

class _StudentClubState extends State<StudentClub> {
  List<Map<String, dynamic>> clubList = [];

  Future<void> fetchClubs() async {
    try {
      final response = await supabase
          .from('tbl_members')
          .select("*, tbl_club(*)")
          .eq('student_id', supabase.auth.currentUser!.id);
      setState(() {
        clubList = response;
      });
    } catch (e) {
      print("ERROR FETCHING CLUBS: $e");
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child:
            clubList.isEmpty
                ? Center(child: Text("You havnt joined any club"))
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      const Center(
                        child: Text(
                          "My Clubs",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: clubList.length,
                          itemBuilder: (context, index) {
                            final club = clubList[index];
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    242,
                                    242,
                                    242,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        club['tbl_club']['club_name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
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
            fetchClubs();
          }
        },
        label: Row(children: [Text("Join Club"), Icon(Icons.add)]),
      ),
    );
  }
}
