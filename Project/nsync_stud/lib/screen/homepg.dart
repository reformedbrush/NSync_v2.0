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
      backgroundColor: Colors.white,
      body: IndexedStack(index: myIndex, children: pages),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home),
            _buildNavItem(1, Icons.sports_outlined, Icons.sports),
            _buildNavItem(2, Icons.person_outline, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData unselectedIcon,
    IconData selectedIcon,
  ) {
    return IconButton(
      onPressed: () {
        setState(() {
          myIndex = index;
        });
      },
      icon: Icon(
        myIndex == index ? selectedIcon : unselectedIcon,
        color: myIndex == index ? Colors.black : Colors.grey,
        size: 28,
      ),
    );
  }
}
