import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'login_page.dart'; // ✅ Import LoginPage

class CropSelectionPage extends StatefulWidget {
  const CropSelectionPage({super.key});

  @override
  State<CropSelectionPage> createState() => _CropSelectionPageState();
}

class _CropSelectionPageState extends State<CropSelectionPage> {
  List<String> selectedCrops = []; // ✅ multiple crop selection
  String searchQuery = "";
  List<String> recentCrops = [];

  final List<Map<String, String>> crops = [
    {"name": "Wheat", "image": "assets/Crops/wheat.png"},
    {"name": "Rice", "image": "assets/Crops/rice.png"},
    {"name": "Corn", "image": "assets/Crops/corn.png"},
    {"name": "Mustard", "image": "assets/Crops/mustard.png"},
    {"name": "Gram", "image": "assets/Crops/gram.png"},
    {"name": "Pea", "image": "assets/Crops/pea.png"},
    {"name": "Oats", "image": "assets/Crops/oats.png"},
    {"name": "Barley", "image": "assets/Crops/barley.png"},
    {"name": "Pearl Millet", "image": "assets/Crops/pearl_millet.png"},
    {"name": "Rye", "image": "assets/Crops/rye.png"},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentCrops();
  }

  Future<void> _loadRecentCrops() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedRecents = prefs.getStringList("recentCrops");
    if (savedRecents != null) {
      setState(() {
        recentCrops = savedRecents;
      });
    }
  }

  Future<void> _saveCropsAndContinue() async {
    if (selectedCrops.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList("selectedCrops", selectedCrops);
        await prefs.setBool("seenFeatures", true);

        // Save recent crops (limit 5)
        for (var crop in selectedCrops) {
          recentCrops.remove(crop);
          recentCrops.insert(0, crop);
        }
        if (recentCrops.length > 5) {
          recentCrops = recentCrops.sublist(0, 5);
        }
        await prefs.setStringList("recentCrops", recentCrops);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HomePage(crops: selectedCrops), // ✅ multiple crops
            ),
          );
        }
      } catch (e) {
        _showSnackBar("❌ Failed to save crops. Try again.", Colors.red);
      }
    } else {
      _showSnackBar("⚠️ Please select at least 1 crop", Colors.orange);
    }
  }

  Future<void> _clearRecentCrops() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("recentCrops");
    setState(() {
      recentCrops.clear();
    });
    _showSnackBar("🧹 Recent crops cleared", Colors.green);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter crops by search query
    final filteredCrops = crops
        .where((crop) =>
        crop["name"]!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: const Text(
          "🌾 Choose Your Crops (max 5)",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,

        // 🔙 Back button → always go to LoginPage
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
            );
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search crops...",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: const Icon(Icons.search, color: Colors.green),
              ),
            ),
          ),

          // 🕒 Recently selected crops
          if (recentCrops.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "🕒 Recently Selected",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                      TextButton.icon(
                        onPressed: _clearRecentCrops,
                        icon:
                        const Icon(Icons.delete, size: 18, color: Colors.red),
                        label: const Text(
                          "Clear",
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentCrops.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final cropName = recentCrops[index];
                        final crop = crops.firstWhere(
                              (c) => c["name"] == cropName,
                          orElse: () => {"name": cropName, "image": ""},
                        );
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.green.shade100,
                              backgroundImage: crop["image"]!.isNotEmpty
                                  ? AssetImage(crop["image"]!)
                                  : null,
                              child: crop["image"]!.isEmpty
                                  ? const Icon(Icons.agriculture,
                                  size: 40, color: Colors.green)
                                  : null,
                            ),
                            const SizedBox(height: 6),
                            Text(cropName,
                                style: const TextStyle(fontSize: 14)),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),

          // 🌱 Crop Grid
          Expanded(
            child: filteredCrops.isEmpty
                ? const Center(
              child: Text("No crops found ❌",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            )
                : GridView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: filteredCrops.length,
              itemBuilder: (context, index) {
                final crop = filteredCrops[index];
                final isSelected = selectedCrops.contains(crop["name"]);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedCrops.remove(crop["name"]);
                      } else if (selectedCrops.length < 5) {
                        selectedCrops.add(crop["name"]!);
                      } else {
                        _showSnackBar(
                            "⚠️ You can only select up to 5 crops",
                            Colors.orange);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green.shade100
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.green
                            : Colors.grey.shade300,
                        width: isSelected ? 3 : 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.green.shade50,
                          backgroundImage: AssetImage(crop["image"]!),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          crop["name"]!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.green.shade800
                                : Colors.black,
                          ),
                        ),
                        if (isSelected)
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(Icons.check_circle,
                                color: Colors.green, size: 22),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ Confirm button
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveCropsAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 5,
              ),
              child: const Text(
                "Confirm Selection",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
