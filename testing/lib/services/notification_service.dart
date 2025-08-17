import 'package:flutter/material.dart';

class NotificationService {
  
  static void showSuccess(BuildContext context, String message, {String? action, VoidCallback? onAction}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: theme.colorScheme.onSecondary, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: theme.colorScheme.secondary, 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: action != null && onAction != null
            ? SnackBarAction(
                label: action,
                textColor: theme.colorScheme.onSecondary,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static void showError(BuildContext context, String message, {String? action, VoidCallback? onAction}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: theme.colorScheme.onError, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: theme.colorScheme.error, 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
        action: action != null && onAction != null
            ? SnackBarAction(
                label: action,
                textColor: theme.colorScheme.onError,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static void showInfo(BuildContext context, String message, {String? action, VoidCallback? onAction}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: theme.colorScheme.onPrimary, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: theme.colorScheme.primary, 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: action != null && onAction != null
            ? SnackBarAction(
                label: action,
                textColor: theme.colorScheme.onPrimary,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            
            style: isDestructive
                ? ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
