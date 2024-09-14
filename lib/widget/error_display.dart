import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorDisplay({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 100),
          SizedBox(height: 20),
          Text(
            'Error fetching data',
            style: TextStyle(
              fontSize: 24, // Larger font size
            ),
          ),
          SizedBox(height: 20), // Add margin to the top of the button
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Text style
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}