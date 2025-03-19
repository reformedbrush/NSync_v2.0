import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:nsync_stud/main.dart';
import 'package:intl/intl.dart';

class StuEvents extends StatefulWidget {
  const StuEvents({super.key});

  @override
  State<StuEvents> createState() => _StuEventsState();
}

class _StuEventsState extends State<StuEvents> {
  int _currentCarouselIndex = 0;
  final List<String> _categories = ['All', 'Department', 'Club', 'Sport'];
  String _selectedCategory = 'All';

  // Sample event data
  List<Map<String, dynamic>> _posterNews = [];

  final List<Map<String, dynamic>> _concertEvents = [];

  //select

  Future<void> fetchEvent() async {
    try {
      final response = await supabase.from('tbl_events').select();
      List<Map<String, dynamic>> eventList = [];
      for (var data in response) {
        eventList.add({
          'title': data['event_name'] ?? "",
          'date': data['created_at'] ?? "",
          'location': data['event_venue'] ?? "",
        });
      }
    } catch (e) {
      print("ERROR FETCHING EVENTS: $e");
    }
  }

  Future<void> fetchNews() async {
    try {
      final response = await supabase.from('tbl_newsletter').select();
      List<Map<String, dynamic>> newsList = [];
      for (var data in response) {
        newsList.add({
          'title': data['newsletter_title'] ?? "",
          'image': data['newsletter_image'] ?? "",
          'date': data['created_at'] ?? "",
        });
      }
      setState(() {
        _posterNews = newsList;
      });
    } catch (e) {
      print("ERROR FETCHING NEWS: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user info
              _buildHeader(),

              // Location info
              _buildLocationInfo(),

              // Festival Music section with carousel
              _buildFestivalSection(),

              // Top Concerts section with ListView
              _buildConcertsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202025-03-19%20104737-vA2GAIgj2pAsLCUjNHQf9nF69INIph.png',
                ), // Replace with actual avatar image
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back!',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Text(
                    'Wilson Culhane',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 5),
              Text(
                'Nirmala College Autonomous, Muvattupuzha, Kerala',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          Icon(Icons.my_location, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget _buildFestivalSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Festival Musics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See All',
                  style: TextStyle(color: Colors.lightBlue),
                ),
              ),
            ],
          ),
        ),

        // Category filters
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.teal : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Carousel slider
        CarouselSlider.builder(
          itemCount: _posterNews.length,
          options: CarouselOptions(
            height: 200,
            aspectRatio: 16 / 9,
            viewportFraction: 0.8,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            scrollDirection: Axis.horizontal,
          ),
          itemBuilder: (BuildContext context, int index, int realIndex) {
            final event = _posterNews[index];
            print(event);
            return _buildPosterCard(event);
          },
        ),

        // Carousel indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              _posterNews.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)
                        .withOpacity(
                          _currentCarouselIndex == entry.key ? 0.9 : 0.4,
                        ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildPosterCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(event['image'] ?? ""),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Bookmark icon
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_border, size: 20),
            ),
          ),
          // Event details at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    event['date'] != null
                        ? DateFormat(
                          'dd-MM-yyyy',
                        ).format(DateTime.parse(event['date']))
                        : 'No date',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConcertsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Concerts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See All',
                  style: TextStyle(color: Colors.lightBlue),
                ),
              ),
            ],
          ),
        ),

        // ListView.builder for concert events
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _concertEvents.length,
          itemBuilder: (context, index) {
            final event = _concertEvents[index];

            // First two items use the new design
            if (index < 2) {
              return _buildConcertCard(event);
            }
            // Remaining items use the original EventCard design
            else {
              return EventCard(
                date: event['date'],
                title: event['title'],
                location: event['location'],
                distance: event['distance'] ?? '',
                price: event['price'],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildConcertCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          // Event image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              event['image'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          // Event details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['date'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text(
                  event['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  event['location'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      'Starting ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      event['price'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String date, title, location, distance, price;
  const EventCard({
    super.key,
    required this.date,
    required this.title,
    required this.location,
    required this.distance,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(date, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(location, style: TextStyle(color: Colors.grey)),
                  Text(distance, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text(price),
            ),
          ],
        ),
      ),
    );
  }
}
