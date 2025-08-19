import 'package:flutter/material.dart';

class ProfessionalDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final IconData? icon;
  final Color? iconColor;
  final Color? primaryButtonColor;
  final bool isError;

  const ProfessionalDialog({
    super.key,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.icon,
    this.iconColor,
    this.primaryButtonColor,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: Offset(0.0, 4.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (iconColor ?? (isError ? Colors.red.shade50 : Colors.green.shade50)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? (isError ? Icons.error_outline : Icons.check_circle_outline),
                size: 32,
                color: iconColor ?? (isError ? Colors.red.shade600 : Colors.green.shade600),
              ),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.3),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (secondaryButtonText != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSecondaryPressed ?? () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: Text(
                        secondaryButtonText!,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPrimaryPressed ?? () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryButtonColor ?? (isError ? Colors.red.shade600 : Colors.green.shade600),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 1,
                    ),
                    child: Text(
                      primaryButtonText ?? 'OK',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfessionalConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;

  const ProfessionalConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: Offset(0.0, 4.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
              child: Icon(Icons.warning_amber_rounded, size: 32, color: Colors.orange.shade600),
            ),
            SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800), textAlign: TextAlign.center),
            SizedBox(height: 12),
            Text(message, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.3), textAlign: TextAlign.center),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel ?? () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    child: Text(cancelText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm ?? () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmButtonColor ?? Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 1,
                    ),
                    child: Text(confirmText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


