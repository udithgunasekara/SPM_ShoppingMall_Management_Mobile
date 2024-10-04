import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../widgets/event_list_item.dart';
import '../widgets/category_chips.dart';
import '../widgets/custom_search_bar_2.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Add Back button to go to Home
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop(); // Navigate back to Home
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Events',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  // Remove the filter icon here
                ],
              ),
            ),
            CustomSearchBar(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            CategoryChips(
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('events').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<Event> events = snapshot.data!.docs
                      .map((doc) => Event.fromFirestore(doc))
                      .where((event) =>
                          (_selectedCategory == 'All' ||
                              event.category == _selectedCategory) &&
                          event.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                      .toList();

                  if (events.isEmpty) {
                    return const Center(child: Text('No events found'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) =>
                        EventListItem(event: events[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
