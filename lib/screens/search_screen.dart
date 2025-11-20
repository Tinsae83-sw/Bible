// screens/search_screen.dart
import 'dart:async'; // Add this import for Timer
import 'package:flutter/material.dart';
import 'package:Amharic_bible/services/bible_service.dart';
import 'package:Amharic_bible/models/bible_verse.dart';
import './search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final BibleService _bibleService = BibleService();
  final TextEditingController _searchController = TextEditingController();
  List<BibleVerse> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  void _searchVerses(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _bibleService.searchVerses(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });

        // Navigate to results screen only if we have results
        if (results.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(
                searchResults: results,
                searchQuery: query,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('የፍለጋ ስህተት: $e')),
        );
      }
    }
  }

  void _onSearchTextChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set new timer for debouncing (300ms delay)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchVerses(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ፍለጋ'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'መጽሐፍ ቅዱስ ፍለጋ...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchVerses(_searchController.text),
                ),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _onSearchTextChanged,
              onSubmitted: _searchVerses,
            ),
          ),
          _isSearching
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty
                                    ? 'ፍለጋ የሚፈልጉትን ጥቅስ ይፃፉ'
                                    : '"${_searchController.text}" የሚለውን ቃል የያዘ ጥቅስ አልተገኘም',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontFamily: 'NotoSansEthiopic',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
