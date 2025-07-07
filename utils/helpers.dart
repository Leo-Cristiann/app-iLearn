import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Helpers {
  // Format date
  static String formatDate(DateTime? date, {String format = 'dd MMM yyyy'}) {
    if (date == null) return 'N/A';
    return DateFormat(format).format(date);
  }
  
  // Format time
  static String formatTime(DateTime? time) {
    if (time == null) return 'N/A';
    return DateFormat('hh:mm a').format(time);
  }
  
  // Format date and time
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }
  
  // Format relative time (e.g., 2 minutes ago, 3 hours ago, etc.)
  static String formatRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    }
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    }
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    }
    
    if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    }
    
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    }
    
    return 'Just now';
  }
  
  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  // Format duration
  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes < 60) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    return '$hours:${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  // Format percentage
  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }
  
  // Format currency
  static String formatCurrency(double value, {String symbol = '\$'}) {
    return '$symbol${value.toStringAsFixed(2)}';
  }
  
  // Format phone number
  static String formatPhoneNumber(String phone) {
    if (phone.length < 10) return phone;
    
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    
    return phone;
  }
  
  // Generate initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    
    final parts = name.split(' ');
    
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    
    return parts[0][0].toUpperCase() + parts[parts.length - 1][0].toUpperCase();
  }
  
  // Launch URL
  static Future<bool> launchUrlLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  
  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Show loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
  
  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }
  
  // Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  
  // Calculate course progress
  static double calculateCourseProgress(
    int completedItems,
    int totalItems,
  ) {
    if (totalItems == 0) return 0;
    return (completedItems / totalItems) * 100;
  }
  
  // Get content type icon
  static IconData getContentTypeIcon(String contentType) {
    switch (contentType) {
      case 'video':
        return Icons.video_library;
      case 'text':
        return Icons.article;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'image':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
  
  // Get random color
  static Color getRandomColor() {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    
    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
  }
  
  // Get course status color
  static Color getCourseStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'active':
        return Colors.green;
      case 'archived':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  // Get submission status color
  static Color getSubmissionStatusColor(String status) {
    switch (status) {
      case 'submitted':
        return Colors.blue;
      case 'graded':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}