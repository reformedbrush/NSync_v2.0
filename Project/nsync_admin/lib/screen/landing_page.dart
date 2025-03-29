import 'package:flutter/material.dart';
import 'package:nsync_admin/main.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  List<Map<String, dynamic>> eventList = [];

  // select
  Future<void> fetchEvents() async {
    try {
      final response = await supabase
          .from('tbl_events')
          .select()
          .eq("event_status", 1);
      setState(() {
        eventList = response;
      });
    } catch (e) {}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [const Color(0xFF1F4037), Color(0xFF99F2C8)],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
            ),
            width: 1250,
            height: 90,
            child: Padding(
              padding: const EdgeInsets.only(top: 27, left: 20),
              child: Text(
                "Welcome Admin",
                style: TextStyle(
                  color: Color(0xFF1F4037),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xffeeeeeee),
                    ),
                    width: 700,
                    height: 500,
                    child: Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Upcoming Events",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: eventList.length,
                          itemBuilder: (context, index) {
                            final event = eventList[index];
                            return Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: (Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /* Image.asset(event                        ), */
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        event['event_name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0,
                                      ),
                                      child: Text(
                                        event['event_venue'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        event['event_details'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffeeeeeee),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 500,
                  width: 530,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Event Analytics",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          height: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildBar(0.7, "Mon", Colors.blue),
                              _buildBar(0.5, "Tue", Colors.blue),
                              _buildBar(0.8, "Wed", Colors.blue),
                              _buildBar(0.4, "Thu", Colors.blue),
                              _buildBar(0.9, "Fri", Colors.blue),
                              _buildBar(0.6, "Sat", Colors.blue),
                              _buildBar(0.3, "Sun", Colors.blue),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard("Total Events", "24"),
                            _buildStatCard("Active Events", "12"),
                            _buildStatCard("Completed", "8"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xffeeeeeee),
                ),
                height: 500,
                width: 600,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Monthly Event Distribution",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildPieChart(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLegendItem("Music", Colors.blue),
                          _buildLegendItem("Sports", Colors.green),
                          _buildLegendItem("Arts", Colors.orange),
                          _buildLegendItem("Others", Colors.purple),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xffeeeeeee),
                ),
                height: 500,
                width: 600,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Recent Activities",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(16),
                        children: [
                          _buildActivityItem(
                            "New event created: Summer Festival",
                            "2 hours ago",
                          ),
                          _buildActivityItem(
                            "Event updated: Sports Tournament",
                            "5 hours ago",
                          ),
                          _buildActivityItem(
                            "Ticket sales started: Concert Night",
                            "1 day ago",
                          ),
                          _buildActivityItem(
                            "Event completed: Art Exhibition",
                            "2 days ago",
                          ),
                          _buildActivityItem(
                            "New venue added: Central Park",
                            "3 days ago",
                          ),
                          _buildActivityItem(
                            "Event cancelled: Dance Workshop",
                            "4 days ago",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 150 * height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
          ),
        ),
        SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F4037),
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            gradient: SweepGradient(
              colors: [Colors.blue, Colors.green, Colors.orange, Colors.purple],
              stops: [0.25, 0.5, 0.75, 1.0],
            ),
          ),
        ),
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Color(0xffeeeeeee),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}
