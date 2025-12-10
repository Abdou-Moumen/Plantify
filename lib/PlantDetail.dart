import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:plant/api_service.dart';
import 'config.dart';
import 'DiseaseDetail.dart';
import 'package:plant/custom_dialog.dart';

class PlantDetail extends StatefulWidget {
  final int diseaseId;
  final bool isDefaultDisease;
  final String predictedClass;
  final Map<String, dynamic> diseaseDetails;

  const PlantDetail({
    super.key,
    required this.diseaseId,
    required this.isDefaultDisease,
    required this.predictedClass,
    required this.diseaseDetails,
  });

  @override
  State<PlantDetail> createState() => _PlantDetailState();
}

class _PlantDetailState extends State<PlantDetail> {
  Map<String, dynamic>? disease;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    disease = widget.diseaseDetails;
    if (!widget.isDefaultDisease) {
      _fetchUpdatedDetails();
    }
  }

  Future<void> _fetchUpdatedDetails() async {
    setState(() => isLoading = true);
    try {
      final updatedDetails = await ApiService.getDiseaseDetails(
        widget.diseaseId,
      );
      setState(() {
        disease = updatedDetails;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteDisease() async {
    try {
      final token = await _getToken();
      if (token == null) {
        showCustomDialog(
          context: context,
          message: 'No user token found. Please log in again.',
          isError: true,
        );
        return;
      }

      setState(() => isLoading = true);

      // Add debugging
      print('Attempting to delete disease with ID: ${widget.diseaseId}');
      print('Using token: $token');

      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/api/delete-disease/${widget.diseaseId}/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      setState(() => isLoading = false);

      // Add response logging
      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 204) {
        showCustomDialog(
          context: context,
          message: 'Disease deleted successfully',
          isError: false,
          displayDuration: 1500,
        ).then((_) {
          if (mounted) Navigator.pop(context, true);
        });
      } else {
        showCustomDialog(
          context: context,
          message: 'Failed to delete disease: ${response.statusCode}',
          isError: true,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error deleting disease: $e');
      showCustomDialog(
        context: context,
        message: 'Error deleting disease: ${e.toString()}',
        isError: true,
      );
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  Widget _buildPlantImage() {
    return Image.asset(
      'assets/plant/plantandmore.png',
      width: 300,
      height: 300,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;
    final diseaseName = disease?['plant_name'] ?? widget.predictedClass;
    final description =
        disease?['disease_description'] ?? 'Description not available';
    final plantDefinition =
        disease?['plant_definition'] ?? 'Plant information not available';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Curved Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _CurvedClipper(),
              child: Container(
                height: screenHeight * 0.45,
                decoration: const BoxDecoration(color: Color(0xFF517159)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 40,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: screenHeight * 0.07,
            left: 0,
            right: 0,
            child: Center(child: _buildPlantImage()),
          ),

          // Content Section
          Positioned.fill(
            top: screenHeight * 0.47,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  diseaseName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF517159),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 21),
                  child: GestureDetector(
                    onTap: () {
                      _showFullTextDialog(
                        context: context,
                        title: 'Disease Description',
                        content: description,
                      );
                    },
                    child: Text(
                      description.length > 100
                          ? '${description.substring(0, 100)}...'
                          : description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.dotted,
                        decorationColor: Colors.black38,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Additional Info Section
          Positioned(
            top: screenHeight * 0.66,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF5F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SizedBox(
                    height: 130,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          _showFullTextDialog(
                            context: context,
                            title: 'Plant Information',
                            content: plantDefinition,
                          );
                        },
                        child: SingleChildScrollView(
                          child: Text(
                            plantDefinition,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.dotted,
                              decorationColor: Colors.black38,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Buttons
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Delete Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: deleteDisease,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF517159),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // More Info Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (disease != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DiseaseDetail(
                                      disease: {
                                        ...disease!,
                                        'name': diseaseName,
                                        'symptoms': disease?['symptoms'],
                                        'management': disease?['management'],
                                      },
                                    ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Color(0xFF517159)),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'More info',
                            style: TextStyle(
                              color: Color(0xFF517159),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (isLoading)
            const Positioned.fill(
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // Helper method to show a dialog with full text
  void _showFullTextDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF517159),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: SingleChildScrollView(
                    child: Text(content, style: TextStyle(fontSize: 16)),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
