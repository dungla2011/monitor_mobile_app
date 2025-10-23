import 'package:flutter/material.dart';
import 'package:monitor_app/l10n/app_localizations.dart';
import '../services/web_auth_service.dart';
import '../widgets/web_auth_wrapper.dart';
import '../config/app_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  Map<String, String?> _loginInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);

    try {
      _user = WebAuthService.currentUser;
      _loginInfo = await WebAuthService.getSavedLoginInfo();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
            SnackBar(content: Text(l10n.profileLoadError(e.toString()))));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    final l10n = AppLocalizations.of(context)!;
    // Hiển thị dialog xác nhận
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.authLogout),
        content: Text(l10n.profileLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.appCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.authLogout),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      try {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.profileLoggingOut),
              duration: Duration(seconds: 1),
            ),
          );
        }

        await WebAuthService.signOut();

        // Navigate to WebAuthWrapper (root) to trigger auth check
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WebAuthWrapper()),
            (route) => false,
          );

          // Show success message after navigation
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.profileLogoutSuccess),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            }
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(
            content: Text(l10n.profileLogoutError(e.toString())),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  Future<void> _showEditProfileDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(
      text: _user?['displayName'] ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileEditProfile),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.profileDisplayName,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.appCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(nameController.text),
            child: Text(l10n.appSave),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      // TODO: Implement profile update với API của bạn
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdateNotSupported),
          ),
        );
      }
    }
  }

  void _showAboutDialog() {
    final l10n = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: AppConfig.appName,
      applicationVersion: 'Version ${AppConfig.appVersion}',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.monitor_heart,
          size: 40,
          color: Colors.white,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        Text(
          l10n.profileAboutDescription,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        _buildAboutInfoRow(l10n.profileApiUrl, AppConfig.domain),
        _buildAboutInfoRow(l10n.profileAppVersion, AppConfig.appVersion),
        _buildAboutInfoRow('Build Date', DateTime.now().toString().split(' ')[0]),
        const SizedBox(height: 16),
        Text(
          '© 2025 ${AppConfig.appName}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            l10n.profileTitle,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // User Avatar và thông tin cơ bản
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user?['displayName'] ??
                              _user?['username'] ??
                              l10n.profileNoName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user?['username'] ?? l10n.profileNoUsername,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user?['email'] ?? l10n.profileNoEmail,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.profileLoggedIn,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _showEditProfileDialog,
                    icon: const Icon(Icons.edit),
                    tooltip: l10n.profileEditProfileTooltip,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Thông tin đăng nhập
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.profileLoginInfo,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    l10n.profileLoginMethod,
                    _getLoginMethodText(_loginInfo['login_method']),
                    Icons.login,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    l10n.authUsername,
                    _user?['username'] ?? 'N/A',
                    Icons.account_circle,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      l10n.authPassword.replaceAll('Password', 'Email'),
                      _user?['email'] ?? 'N/A',
                      Icons.email),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    l10n.profileLoginTime,
                    _loginInfo['login_time']?.split('T')[0] ?? 'N/A',
                    Icons.access_time,
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Các hành động
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.profileActions,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.refresh, color: Colors.blue),
                    title: Text(l10n.profileRefreshInfo),
                    subtitle: Text(l10n.profileRefreshInfoDesc),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _loadUserInfo,
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.green),
                    title: Text(l10n.profileViewAbout),
                    subtitle: Text(l10n.profileViewAboutDesc),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _showAboutDialog,
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(l10n.authLogout),
                    subtitle: Text(l10n.profileLogoutDesc),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _signOut,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // About / App Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.profileAbout,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    l10n.profileAppName,
                    AppConfig.appName,
                    Icons.apps,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    l10n.profileAppVersion,
                    AppConfig.appVersion,
                    Icons.info_outline,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    l10n.profileApiUrl,
                    AppConfig.domain,
                    Icons.cloud,
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  String _getLoginMethodText(String? method) {
    final l10n = AppLocalizations.of(context)!;
    switch (method) {
      case 'web_api':
        return l10n.profileLoginMethodWebApi;
      case 'email':
        return l10n.profileLoginMethodEmail;
      default:
        return l10n.profileLoginMethodUnknown;
    }
  }
}
