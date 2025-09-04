import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MandiPage extends StatefulWidget {
  final String? crop;

  const MandiPage({super.key, this.crop});

  @override
  State<MandiPage> createState() => _MandiPageState();
}

class _MandiPageState extends State<MandiPage> {
  bool isLoading = false;
  List<dynamic> allRecords = [];
  List<dynamic> mandiPrices = [];
  String? errorMessage;
  String? selectedCrop;
  String searchQuery = "";

  final TextEditingController _searchController = TextEditingController();

  List<String> availableCrops = [];

  static const String apiKey =
      "579b464db66ec23bdd0000011061a7ea7bc343854d542a2f820ccd4b";
  static const String endpoint =
      "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070";

  @override
  void initState() {
    super.initState();
    selectedCrop = widget.crop;
    fetchCropsAndPrices();
  }

  Future<void> fetchCropsAndPrices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse("$endpoint?api-key=$apiKey&format=json&limit=500"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final records = data["records"] ?? [];

        final cropsSet = records
            .map((item) => (item["commodity"] ?? "").toString())
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        setState(() {
          allRecords = records;
          availableCrops = cropsSet.cast<String>();

          if (selectedCrop == null && availableCrops.isNotEmpty) {
            selectedCrop = availableCrops.first;
          }

          filterByCrop();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "⚠️ Couldn’t fetch mandi prices";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "⚠️ Error fetching mandi prices";
        isLoading = false;
      });
    }
  }

  void filterByCrop() {
    if (selectedCrop == null || selectedCrop!.isEmpty) {
      mandiPrices = [];
      return;
    }

    mandiPrices = allRecords
        .where((item) =>
    (item["commodity"] ?? "").toString().toLowerCase() ==
        selectedCrop!.toLowerCase())
        .where((item) {
      if (searchQuery.isEmpty) return true;
      return (item["district"] ?? "")
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase()) ||
          (item["market"] ?? "")
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
    })
        .toList();
  }

  String getFarmerTip() {
    if (selectedCrop != null && selectedCrop!.isNotEmpty) {
      return "💡 For $selectedCrop, compare mandi prices across districts before selling.";
    }
    return "💡 Compare mandi prices before selling to maximize profit.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📊 Mandi Prices"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchCropsAndPrices,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : CustomScrollView(
        slivers: [
          // 🔝 Sticky Header
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            expandedHeight: 120,
            flexibleSpace: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  if (availableCrops.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: selectedCrop,
                      hint: const Text("Select Crop"),
                      items: availableCrops
                          .map((crop) => DropdownMenuItem(
                          value: crop, child: Text(crop)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCrop = value;
                          filterByCrop();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Choose Crop",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                      "Search in $selectedCrop (district/market)",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            searchQuery = "";
                            filterByCrop();
                          });
                        },
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (query) {
                      setState(() {
                        searchQuery = query;
                        filterByCrop();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // 📋 Price List
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final item = mandiPrices[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${item['commodity'] ?? 'Unknown Crop'}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("State: ${item['state'] ?? '-'}"),
                        Text("District: ${item['district'] ?? '-'}"),
                        Text("Market: ${item['market'] ?? '-'}"),
                        Text("Price: ₹${item['modal_price'] ?? '-'}"),
                      ],
                    ),
                  ),
                );
              },
              childCount: mandiPrices.length,
            ),
          ),

          // 👨‍🌾 Farmer Tip
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.green[100],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    getFarmerTip(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
