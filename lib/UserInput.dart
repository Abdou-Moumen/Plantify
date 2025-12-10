import 'package:flutter/material.dart';

class UserInput extends StatefulWidget {
  final String message;

  const UserInput({super.key, required this.message});

  @override
  State<UserInput> createState() => _UserInputState();
}

class _UserInputState extends State<UserInput> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0, bottom: 20.0),
        child: IntrinsicWidth(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFF3F6F4C),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 5, left: 5),
              child: RichText(
                textDirection:
                    TextDirection.ltr, // Left-to-right text direction
                text: TextSpan(
                  children: [
                    // WidgetSpan(
                    //   child: Padding(
                    //     padding:
                    //         EdgeInsets.only(bottom: 5.0), // Add bottom padding
                    //     child: Text(
                    //       'أنت',
                    //       style: TextStyle(
                    //         fontWeight: FontWeight.bold,
                    //         color: Colors.white,
                    //         fontSize: 16,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // TextSpan(
                    //   text: '\n',
                    // ),
                    TextSpan(
                      text: widget.message,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
