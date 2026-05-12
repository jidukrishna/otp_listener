import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../services/sync_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _initializeController();
  }

  void _initializeController() {
    final settings = context.read<AppProvider>().settings;
    _urlController.text = settings.backendUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Configuration',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Enable/Disable Toggle
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OTP Listener',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appProvider.settings.isEnabled
                                  ? 'Active - Listening for OTPs'
                                  : 'Inactive - Not listening',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: appProvider.settings.isEnabled
                                        ? AppTheme.successColor
                                        : Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                        Switch(
                          value: appProvider.settings.isEnabled,
                          onChanged: (value) {
                            appProvider.setEnabled(value);
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Backend URL Section
                Text(
                  'Backend Configuration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),

                // URL Input
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: 'https://your-backend.com/otp',
                    labelText: 'Backend URL',
                    prefixIcon: const Icon(Icons.link, color: AppTheme.primaryColor),
                    suffixIcon: _urlController.text.isNotEmpty
                        ? _buildValidationIcon(_urlController.text)
                        : null,
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    _saveUrl(appProvider);
                  },
                ),
                const SizedBox(height: 12),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _saveUrl(appProvider);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save URL'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),

                // URL Info
                if (_urlController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current URL:',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            _urlController.text,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontFamily: 'monospace',
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Expected Payload Section
                Text(
                  'Expected Backend Payload',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    border: Border.all(color: AppTheme.surfaceColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    '''POST /otp
Content-Type: application/json

{
  "sender": "+1234567890",
  "message": "Your OTP is 123456",
  "otp": "123456",
  "timestamp": "2026-05-11T10:30:00.000Z"
}''',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // About Section
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Version', '1.0.0'),
                        const Divider(color: AppTheme.surfaceColor),
                        _buildInfoRow('Retry Attempts', '${SyncService.maxRetries}'),
                        const Divider(color: AppTheme.surfaceColor),
                        _buildInfoRow('Retry Delay', '${SyncService.retryDelay.inSeconds}s'),
                      ],
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

  void _saveUrl(AppProvider appProvider) {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      _showSnackBar('URL cannot be empty', isError: true);
      return;
    }

    if (!SyncService.isValidBackendUrl(url)) {
      _showSnackBar('Invalid URL format. Use http:// or https://', isError: true);
      return;
    }

    appProvider.setBackendUrl(url);
    _showSnackBar('URL saved successfully');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildValidationIcon(String url) {
    final isValid = SyncService.isValidBackendUrl(url);
    return Icon(
      isValid ? Icons.check_circle : Icons.error,
      color: isValid ? AppTheme.successColor : AppTheme.errorColor,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
