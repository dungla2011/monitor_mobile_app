import 'package:flutter/material.dart';
import '../services/web_auth_service.dart';

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải thông tin: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    // Hiển thị dialog xác nhận
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      try {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đang đăng xuất...'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        await WebAuthService.signOut();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đăng xuất thành công'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }

        // WebAuthWrapper sẽ tự động điều hướng về LoginScreen
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(
            content: Text('❌ Lỗi khi đăng xuất: $e'),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(
      text: _user?['displayName'] ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa hồ sơ'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên hiển thị',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(nameController.text),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      // TODO: Implement profile update với API của bạn
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chức năng cập nhật hồ sơ chưa được hỗ trợ'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hồ sơ cá nhân',
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
                              'Chưa có tên',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user?['username'] ?? 'Chưa có username',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user?['email'] ?? 'Chưa có email',
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
                              'Đã đăng nhập',
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
                    tooltip: 'Chỉnh sửa hồ sơ',
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
                  const Text(
                    'Thông tin đăng nhập',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Phương thức đăng nhập',
                    _getLoginMethodText(_loginInfo['login_method']),
                    Icons.login,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Username',
                    _user?['username'] ?? 'N/A',
                    Icons.account_circle,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Email', _user?['email'] ?? 'N/A', Icons.email),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Thời gian đăng nhập',
                    _loginInfo['login_time']?.split('T')[0] ?? 'N/A',
                    Icons.access_time,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Bearer Token',
                    WebAuthService.bearerToken != null
                        ? '${WebAuthService.bearerToken!.substring(0, 20)}...'
                        : 'N/A',
                    Icons.security,
                  ),
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
                  const Text(
                    'Hành động',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.refresh, color: Colors.blue),
                    title: const Text('Làm mới thông tin'),
                    subtitle: const Text('Cập nhật thông tin mới nhất'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _loadUserInfo,
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Đăng xuất'),
                    subtitle: const Text('Thoát khỏi tài khoản'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _signOut,
                  ),
                ],
              ),
            ),
          ),
        ],
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
    switch (method) {
      case 'web_api':
        return 'Web API (Username & Password)';
      case 'email':
        return 'Email & Mật khẩu';
      default:
        return 'Không xác định';
    }
  }
}
