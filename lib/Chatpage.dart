import 'package:plant/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:plant/AiInput.dart';
import 'package:plant/Home.dart';
import 'package:plant/UserInput.dart';
import 'package:http/http.dart' as http;
import 'package:plant/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

// This ChatPage handles chat functionality including:
// - Creating new chat sessions
// - Loading previous chat sessions
// - Sending messages and receiving AI responses
// - Displaying chat history
// - Refreshing messages periodically to update any pending AI responses
// The chat messages are fetched using the endpoint: /api/chat-sessions/<session_id>/messages/

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

List<Map<String, dynamic>> previousChats = [];
bool isLoadingChats = false;

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> messages = [];
  int? currentSessionId;
  bool isLoading = false;
  Timer? _refreshTimer;
  bool isTextFieldExpanded = false;
  bool hasText = false;
  bool isAiGenerating = false;

  // Add scroll controller for messages
  final ScrollController _scrollController = ScrollController();

  final TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start a timer to refresh messages every 5 seconds if there's an active chat session
    _startRefreshTimer();

    // Add listener to text controller
    contentController.addListener(_updateHasText);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    contentController.removeListener(_updateHasText);
    _scrollController.dispose(); // Dispose the scroll controller
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      // Only refresh if there's an active session and we're not already loading
      if (currentSessionId != null && !isLoading) {
        _refreshCurrentChat();
      }
    });
  }

  // Method to refresh current chat without UI indicators
  Future<void> _refreshCurrentChat() async {
    if (currentSessionId == null) return;

    final token = await getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse(
          '${Config.baseUrl}/chat-sessions/$currentSessionId/messages/',
        ),
        headers: {'Authorization': 'Token $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Check if we have any loading messages that might need updating
        bool hasLoadingMessages = messages.any(
          (msg) => msg['isLoading'] == true,
        );

        if (hasLoadingMessages) {
          setState(() {
            messages = [];

            // Process each message pair from the new response format
            final List<dynamic> messagePairs = data['messages'];
            for (var messagePair in messagePairs) {
              if (messagePair['user_message'] != null &&
                  messagePair['user_message'].toString().isNotEmpty) {
                messages.add({
                  'content': messagePair['user_message'].toString(),
                  'isUser': true,
                });
              }

              // Check if there's an AI message
              if (messagePair['ai_message'] != null &&
                  messagePair['ai_message'].toString().isNotEmpty) {
                messages.add({
                  'content': messagePair['ai_message'].toString(),
                  'isUser': false,
                });
              } else if (messagePair['ai_message'] == '') {
                // If AI message is empty string (no response yet), show loading indicator
                messages.add({
                  'content': '...',
                  'isUser': false,
                  'isLoading': true,
                });
              }
            }
          });
        }
      }
    } catch (e) {
      print('Silent refresh error: $e');
    }
  }

  // Get user token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  Future<int?> createChatSession() async {
    final token = await getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user token found. Please login again.')),
      );
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/create-chat-session/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode(
          {},
        ), // The user will be set automatically on the server
      );

      print("Create session response status: ${response.statusCode}");
      print("Create session response body: ${response.body}");

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("Created session with ID: ${data['id']}");
        return data['id'];
      } else {
        throw Exception(
          'Failed to create chat session: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print("Exception in createChatSession: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating chat session: $e')),
      );
      return null;
    }
  }

  Future<void> _fetchPreviousChats() async {
    setState(() {
      isLoadingChats = true;
    });

    final token = await getToken();
    if (token == null) {
      setState(() {
        isLoadingChats = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/chat-sessions/'),
        headers: {'Authorization': 'Token $token'},
      );

      print("Sessions response status: ${response.statusCode}");
      print("Sessions response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Debug session information
        print('Sessions associated with this user:');
        for (var session in data) {
          print(
            'Session ID: ${session['id']}, Title: ${session['title']}, User ID: ${session['user'] ?? 'unknown'}',
          );
        }

        setState(() {
          previousChats =
              data.map((item) => item as Map<String, dynamic>).toList();
          isLoadingChats = false;
        });
      } else {
        print(
          'Error fetching sessions: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to load chat history: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Exception in _fetchPreviousChats: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading chat history: $e')));
      setState(() {
        isLoadingChats = false;
      });
    }
  }

  // Load a specific chat
  Future<void> _loadChat(int chatId) async {
    setState(() {
      isLoading = true;
    });

    final token = await getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
      });
      showCustomDialog(
        context: context,
        message: 'No user token found',
        isError: true,
      );
      return;
    }

    try {
      // Use the URL format that matches Django's url.py configuration exactly
      final url = '${Config.baseUrl}/chat-sessions/$chatId/messages/';
      print("Requesting URL: $url");
      print(
        "Using token: ${token.substring(0, 5)}...",
      ); // Only show first 5 chars for security

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Token $token'},
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Received data: $data'); // Debugging

        // Clear current messages and set current session ID
        setState(() {
          messages = [];
          currentSessionId = chatId; // Make sure this is set correctly

          // Process each message pair from the new response format
          final List<dynamic> messagePairs = data['messages'];
          for (var messagePair in messagePairs) {
            if (messagePair['user_message'] != null &&
                messagePair['user_message'].toString().isNotEmpty) {
              messages.add({
                'content': messagePair['user_message'].toString(),
                'isUser': true,
              });
            }

            // Check if there's an AI message
            if (messagePair['ai_message'] != null &&
                messagePair['ai_message'].toString().isNotEmpty) {
              messages.add({
                'content': messagePair['ai_message'].toString(),
                'isUser': false,
              });
            } else if (messagePair['ai_message'] == '') {
              // If AI message is empty string (no response yet), show loading indicator
              messages.add({
                'content': '...',
                'isUser': false,
                'isLoading': true,
              });
            }
          }

          isLoading = false;
        });

        // Reset the refresh timer when loading a new chat
        _startRefreshTimer();

        // Close the drawer after loading the chat
        Navigator.pop(context);
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');

        // Show a more user-friendly error message
        if (response.statusCode == 404) {
          showCustomDialog(
            context: context,
            message:
                'Chat messages not found. The chat may have been deleted or you may not have access.',
            isError: true,
          );
        } else {
          throw Exception(
            'Failed to load chat messages: ${response.statusCode} - ${response.body}',
          );
        }
      }
    } catch (e) {
      print('Exception caught: $e');
      showCustomDialog(
        context: context,
        message: 'Error loading chat: ${e.toString()}',
        isError: true,
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteChat(int chatId) async {
    final token = await getToken();
    if (token == null) {
      showCustomDialog(
        context: context,
        message: 'No user token found',
        isError: true,
      );
      return;
    }

    bool confirmDelete =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                title: Text(
                  'Delete Chat',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: Text(
                  'Are you sure you want to delete this chat?',
                  style: TextStyle(color: Colors.black),
                ),
                actions: [
                  TextButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  TextButton(
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
        ) ??
        false;

    if (!confirmDelete) return;

    try {
      print("Deleting chat with ID: $chatId");
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/api/chat-sessions/$chatId/'),
        headers: {'Authorization': 'Token $token'},
      );

      print("Delete response status: ${response.statusCode}");
      if (response.body.isNotEmpty) {
        print("Delete response body: ${response.body}");
      }

      if (response.statusCode == 204) {
        _fetchPreviousChats();

        if (currentSessionId == chatId) {
          setState(() {
            messages = [];
            currentSessionId = null;
          });
        }

        showCustomDialog(
          context: context,
          message: 'Chat deleted successfully',
          isError: false,
        );
      } else {
        throw Exception(
          'Failed to delete chat: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print("Exception in _deleteChat: $e");
      showCustomDialog(
        context: context,
        message: 'Error deleting chat: ${e.toString()}',
        isError: true,
      );
    }
  }

  void message(BuildContext context) async {
    final trimmedText = contentController.text.trim();
    if (trimmedText.isEmpty) {
      await showCustomDialog(
        context: context,
        message: 'Please enter a message before sending.',
        isError: true,
      );
      return;
    }

    // Set AI generating state to true
    setState(() {
      isAiGenerating = true;
      messages.add({'content': trimmedText, 'isUser': true});
      messages.add({'content': '...', 'isUser': false, 'isLoading': true});
      contentController.clear();
      // Collapse the TextField if it was expanded
      isTextFieldExpanded = false;
    });

    // Scroll to the bottom after adding new messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Get user token
    final token = await getToken();
    if (token == null) {
      setState(() {
        messages.removeLast(); // Remove loading message
      });
      showCustomDialog(
        context: context,
        message: 'No user token found',
        isError: true,
      );
      return;
    }

    try {
      // Create session if needed
      if (currentSessionId == null) {
        currentSessionId = await createChatSession();
        if (currentSessionId == null) {
          setState(() {
            messages.removeLast(); // Remove loading message
          });
          return;
        }
      }

      // Get AI response from Django backend
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/generate-response/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({
          'content': trimmedText,
          'session_id': currentSessionId,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final aiResponse = data['response'];

        // Save the messages to the chat session
        bool success = await createChatMessage(
          currentSessionId!,
          trimmedText,
          aiResponse,
        );

        if (success) {
          setState(() {
            // Replace loading message with actual response
            messages.removeLast();
            messages.add({'content': aiResponse, 'isUser': false});
            isAiGenerating = false;
          });

          // Refresh the chat session list in the background
          _fetchPreviousChats();
        }
      } else {
        setState(() {
          messages.removeLast(); // Remove loading message
          isAiGenerating = false;
        });
        throw Exception(
          'Failed to get AI response: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print("Error in message sending: $e");
      setState(() {
        messages.removeLast(); // Remove loading message
        isAiGenerating = false;
      });
      showCustomDialog(
        context: context,
        message: 'Error: ${e.toString()}',
        isError: true,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> createChatMessage(
    int sessionId,
    String userMessage,
    String aiMessage,
  ) async {
    final token = await getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user token found. Please login again.')),
      );
      return false;
    }

    try {
      print("Creating chat message for session ID: $sessionId");
      final requestBody = json.encode({
        "session": sessionId,
        "user_message": userMessage,
        "ai_message": aiMessage,
      });
      print("Request body: $requestBody");

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/create-chat-message/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: requestBody,
      );

      print("Create message response status: ${response.statusCode}");
      print("Create message response body: ${response.body}");

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          'Failed to create chat message: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print("Exception in createChatMessage: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating chat message: $e')),
      );
      return false;
    }
  }

  // Method to update hasText based on TextField content
  void _updateHasText() {
    setState(() {
      hasText = contentController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 05.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back, size: 30, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'AI ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'Plant',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3F6F4C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 0.0, right: 15.0),
            child: IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                size: 27,
                color: Color(0xFF3F6F4C),
              ),
              onPressed: _createNewSession,
            ),
          ),
        ],
      ),
      endDrawer: _buildChatHistoryDrawer(),
      onEndDrawerChanged: (isOpen) {
        if (isOpen) {
          _fetchPreviousChats();
        }
      },
      body: Container(
        child: Column(
          children: [
            Expanded(
              child:
                  messages.isEmpty
                      ? Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    contentController.text =
                                        'How often should I water my snake plant during winter?';
                                    message(context);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEEF5F0),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Text(
                                          'How often should I water my snake plant during winter?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    contentController.text =
                                        'What are the best companion plants for tomatoes?';
                                    message(context);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEEF5F0),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Text(
                                          'What are the best companion plants for tomatoes?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    contentController.text =
                                        'How can I naturally get rid of aphids on my roses?';
                                    message(context);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEEF5F0),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Text(
                                          'How can I naturally get rid of aphids on my roses?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      : Padding(
                        padding: const EdgeInsets.only(top: 35.0),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isUser = message['isUser'] as bool;
                            final isLoading =
                                message['isLoading'] as bool? ?? false;

                            return Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: isUser ? 10.0 : 0.0,
                                ),
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: Column(
                                    children: [
                                      if (isUser)
                                        UserInput(message: message['content'])
                                      else if (isLoading)
                                        AiInput(message: '...', isLoading: true)
                                      else
                                        AiInput(message: message['content']),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: isTextFieldExpanded ? 120 : 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFFEEF5F0),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: contentController,
                        onChanged: (value) {
                          setState(() {
                            contentController.text = value;
                          });
                        },
                        textDirection: TextDirection.ltr,
                        maxLines: null,
                        minLines: 1,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFEEF5F0),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Write what you want...',
                          suffixIcon:
                              contentController.text.isNotEmpty
                                  ? IconButton(
                                    icon: Icon(
                                      isTextFieldExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Color(0xFF3F6F4C),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isTextFieldExpanded =
                                            !isTextFieldExpanded;
                                      });
                                    },
                                  )
                                  : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: isAiGenerating ? Colors.grey : Color(0xFF3F6F4C),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed:
                          isAiGenerating
                              ? null
                              : () {
                                message(context);
                              },
                      icon: Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHistoryDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 50, bottom: 20),
              color: Colors.white,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'AI ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'Plants',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3F6F4C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 15),
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF3F6F4C),
                        size: 20,
                      ),
                      onPressed: _createNewSession,
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, thickness: 1),
            Expanded(
              child:
                  isLoadingChats
                      ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3F6F4C),
                        ),
                      )
                      : previousChats.isEmpty
                      ? Center(
                        child: Text(
                          'No previous chats',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                      : ListView.builder(
                        itemCount: previousChats.length,
                        itemBuilder: (context, index) {
                          final chat = previousChats[index];
                          final sessionId = chat['id'];

                          // Format the date for better readability
                          String formattedDate = 'No date';
                          if (chat['created_at'] != null) {
                            try {
                              final DateTime dateTime = DateTime.parse(
                                chat['created_at'],
                              );
                              formattedDate =
                                  '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
                            } catch (e) {
                              formattedDate = chat['created_at'];
                            }
                          }

                          // Get a title or create one from the first message if available
                          String title = chat['title'] ?? 'Chat ${index + 1}';
                          if (title.isEmpty || title == 'New Chat') {
                            if (chat['first_message'] != null &&
                                chat['first_message'].toString().isNotEmpty) {
                              // Use first few words of first message as title
                              String firstMessage =
                                  chat['first_message'].toString();
                              title =
                                  firstMessage.length > 30
                                      ? '${firstMessage.substring(0, 30)}...'
                                      : firstMessage;
                            }
                          }

                          return Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFEEF5F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              title: Text(
                                title,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                formattedDate,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFF3F6F4C),
                                ),
                                onPressed: () => _deleteChat(sessionId),
                              ),
                              onTap: () {
                                print('Tapped on chat with ID: $sessionId');
                                _loadChat(sessionId);
                              },
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to create a new chat session without sending backend requests
  void _createNewSession() {
    // Close the drawer if it's open
    if (scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      Navigator.pop(context);
    }

    // Reset the current state to create a new session
    setState(() {
      currentSessionId = null;
      messages = [];
      contentController.clear();
    });

    // Reset the refresh timer
    _startRefreshTimer();

    showCustomDialog(
      context: context,
      message: 'New chat session started',
      isError: false,
    );
  }
}
