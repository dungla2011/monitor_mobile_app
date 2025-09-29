import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
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
      _user = AuthService.currentUser;
      _loginInfo = await AuthService.getSavedLoginInfo();
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
      builder:
          (context) => AlertDialog(
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
        await AuthService.signOut();
        // AuthWrapper sẽ tự động điều hướng về LoginScreen
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi khi đăng xuất: $e')));
        }
      }
    }
  }

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(
      text: _user?.displayName ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
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
      try {
        await AuthService.updateProfile(displayName: result);
        await _loadUserInfo(); // Reload user info
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật hồ sơ thành công!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi khi cập nhật hồ sơ: $e')));
        }
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
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        _user?.photoURL != null
                            ? NetworkImage(_user!.photoURL!)
                            : null,
                    child:
                        _user?.photoURL == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user?.displayName ?? 'Chưa có tên',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user?.email ?? 'Chưa có email',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _user?.emailVerified == true
                                  ? Icons.verified
                                  : Icons.warning,
                              size: 16,
                              color:
                                  _user?.emailVerified == true
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _user?.emailVerified == true
                                  ? 'Email đã xác thực'
                                  : 'Email chưa xác thực',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    _user?.emailVerified == true
                                        ? Colors.green
                                        : Colors.orange,
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
                  _buildInfoRow('UID', _user?.uid ?? 'N/A', Icons.fingerprint),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Ngày tạo tài khoản',
                    _user?.metadata.creationTime?.toString().split(' ')[0] ??
                        'N/A',
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Lần đăng nhập cuối',
                    _user?.metadata.lastSignInTime?.toString().split(' ')[0] ??
                        'N/A',
                    Icons.access_time,
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

                  if (_user?.emailVerified == false)
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.orange),
                      title: const Text('Xác thực email'),
                      subtitle: const Text('Gửi email xác thực'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        try {
                          await _user?.sendEmailVerification();
                          if (mounted) {
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Email xác thực đã được gửi!'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.showSnackBar(
                              SnackBar(content: Text('Lỗi: $e')),
                            );
                          }
                        }
                      },
                    ),

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
      case 'google':
        return 'Google';
      case 'email':
        return 'Email & Mật khẩu';
      default:
        return 'Không xác định';
    }
  }
}
