import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this package
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AiInput extends StatefulWidget {
  final String message;
  final bool isLoading;

  const AiInput({super.key, required this.message, this.isLoading = false});

  @override
  State<AiInput> createState() => _AiInputState();
}

class _AiInputState extends State<AiInput> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: IntrinsicWidth(
          child: Container(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width *
                  0.8, // Ensure text doesn't exceed 80% of view width
            ),
            decoration: BoxDecoration(
              color: Color(0xFFEEF5F0), // Background color F5F5F5
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15),
                topLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.isLoading)
                          LoadingAnimationWidget.threeArchedCircle(
                            color: Color(0xFF3F6F4C),
                            size: 30,
                          )
                        else
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: widget.message,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (!widget.isLoading)
                  IconButton(
                    icon: Icon(Icons.copy),
                    color: Color.fromARGB(
                      255,
                      134,
                      133,
                      133,
                    ), // Copy icon color F5F5F5
                    onPressed: () {
                      // Handle copy action
                      Clipboard.setData(ClipboardData(text: widget.message));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Message copied to clipboard")),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
