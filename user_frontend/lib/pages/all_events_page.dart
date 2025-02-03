import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:user_frontend/pages/events_page.dart';

class AllEventsPage extends StatefulWidget {
  @override
  _AllEventsPageState createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Events'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                EventsPage(pastEvents: false),
                EventsPage(pastEvents: true),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          SmoothPageIndicator(
            controller: _pageController,
            count: 2,
            effect: WormEffect(
              dotHeight: 8.0,
              dotWidth: 8.0,
              spacing: 16.0,
              dotColor: Colors.grey,
              activeDotColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
