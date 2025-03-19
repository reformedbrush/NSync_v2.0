import 'package:flutter/material.dart';
import 'package:nsync_stud/screen/eventspg.dart';
import 'package:nsync_stud/screen/myprofile.dart';
import 'package:nsync_stud/screen/student_club.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int myIndex = 0;

  final List<Widget> pages = [StuEvents(), StudentClub(), MyProfile()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: myIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: myIndex,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.sports), label: 'Clubs'),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
