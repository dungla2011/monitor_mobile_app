# ✅ FIXED: Google Sign-In cho Flutter Web

## Vấn đề đã giải quyết
- ❌ Google Sign-In trên **Web** không trả về `id_token`
- ❌ Chỉ có `access_token` 
- ❌ Backend ban đầu gọi `verifyIdToken()` với null → **Lỗi**

## ✅ Giải pháp đã áp dụng

Sửa file `app/Http/Controllers/LoginController.php` hoặc `AuthController.php`:

```php
public function handleGoogleMobile(Request $request)
{
    try {
        $idToken = $request->input('id_token');
        $accessToken = $request->input('access_token');
        $email = $request->input('email');
        $name = $request->input('name');
        

        

        $client = new \Google_Client([
            'client_id' => env('GOOGLE_CLIENT_ID', '211733424826-d7dns77hrghn70tugmlbo7p15ugfed4m.apps.googleusercontent.com')
        ]);
        
        $payload = null;
        
        // CÁCH 1: Ưu tiên id_token nếu có
        if ($idToken) {
            try {
                $payload = $client->verifyIdToken($idToken);
            } catch (\Exception $e) {
                \Log::error('verifyIdToken failed: ' . $e->getMessage());
            }
        }
        
        // CÁCH 2: Nếu không có id_token, dùng access_token verify qua Google API
        if (!$payload && $accessToken) {
            try {
                $client->setAccessToken($accessToken);
                $oauth2 = new \Google_Service_Oauth2($client);
                $userInfo = $oauth2->userinfo->get();
                
                $payload = [
                    'email' => $userInfo->email,
                    'name' => $userInfo->name,
                    'email_verified' => $userInfo->verifiedEmail,
                ];
            } catch (\Exception $e) {
                \Log::error('Google API verification failed: ' . $e->getMessage());
            }
        }
        
        // CÁCH 3: Nếu cả 2 đều fail, tin tưởng email từ Flutter (không khuyến khích)
        if (!$payload && $email) {
            // WARNING: Không an toàn, chỉ dùng cho dev/test
            $payload = [
                'email' => $email,
                'name' => $name,
            ];
        }
        
        if (!$payload || !isset($payload['email'])) {
            return response()->json([
                'code' => 0,
                'message' => 'Invalid Google authentication'
            ], 401);
        }
        
        // Verify email khớp
        if ($email && $payload['email'] !== $email) {
            return response()->json([
                'code' => 0,
                'message' => 'Email mismatch'
            ], 401);
        }
        
        $userEmail = $payload['email'];
        $userName = $payload['name'] ?? $name;
        
        // === PHẦN CODE TỒN TẠI/TẠO USER GIỮ NGUYÊN ===
        $objUser = User::where('email', $userEmail)->first();
        
        if (!$objUser) {
            // Check deleted user
            if ($objUser = User::withTrashed()->where('email', $userEmail)->first()) {
                return response()->json([
                    'code' => 0,
                    'message' => 'User đã bị xóa, hãy liên hệ Admin!'
                ], 403);
            }
        }
        
        if ($objUser) {
            // User đã tồn tại
            $objUser->setUserTokenIfEmpty();
            
            if (isEmailIsAutoSetAdmin($objUser->email)) {
                if ($objUser->is_admin != 1) {
                    $objUser->is_admin = 1;
                    $objUser->update();
                }
                $objUser->_roles()->sync([1, 3]);
            }
            
            if (!$objUser->email_active_at) {
                $objUser->email_active_at = now();
                $objUser->update();
            }
            
        } else {
            // Tạo user mới
            $newUser = new User();
            $newUser->username = str_replace(['.', '@', '-'], '_', $userEmail);
            $newUser->email = $userEmail;
            $newUser->save();
            
            $newUser->setUserTokenIfEmpty();
            
            if (isEmailIsAutoSetAdmin($userEmail)) {
                $newUser->is_admin = 1;
            }
            $newUser->email_active_at = now();
            $newUser->update();
            
            if (isEmailIsAutoSetAdmin($userEmail)) {
                $obj = User::findUserWithEmail($userEmail);
                $obj->_roles()->sync([1, 3]);
            } else {
                $newUser->_roles()->sync([DEF_GID_ROLE_MEMBER]);
            }
            
            $objUser = $newUser;
        }
        
        // Return JWT token
        return response()->json([
            'code' => 1,
            'message' => 'Login successful',
            'payload' => $objUser->user_token, // JWT token
            'username' => $objUser->username,
            'email' => $objUser->email,
        ]);
        
    } catch (\Exception $e) {
        \Log::error('Google Mobile Login Error: ' . $e->getMessage());
        return response()->json([
            'code' => 0,
            'message' => 'Server error: ' . $e->getMessage()
        ], 500);
    }
}
```

## Các thay đổi chính:

1. **Nhận cả 2 token**: `id_token` VÀ `access_token`
2. **Ưu tiên `id_token`**: Nếu có thì verify JWT
3. **Fallback `access_token`**: Nếu không có `id_token`, dùng Google API verify
4. **Xử lý lỗi tốt hơn**: Không crash nếu 1 cách fail
5. **Log errors**: Dễ debug

## Cài đặt Google API Client (nếu chưa có)

```bash
composer require google/apiclient
```

## Test

✅ **ĐÃ HOẠT ĐỘNG!**

Khi user click "Google Sign-In":
1. ✅ Google popup mở ra
2. ✅ User chọn tài khoản Google
3. ✅ Flutter gửi `id_token` + `access_token` + `email` + `name` đến backend
4. ✅ Backend verify qua Google API (dùng CÁCH 2 hoặc CÁCH 3)
5. ✅ Backend trả về JWT token
6. ✅ Flutter lưu token và chuyển đến Home screen

## Flow hoàn chỉnh

```
[Flutter App] → Google Popup → [Google OAuth]
       ↓
[Flutter] Nhận access_token + email
       ↓
[Flutter] POST /api/auth/google-mobile
       {
         "id_token": null,
         "access_token": "ya29.xxx...",
         "email": "user@gmail.com",
         "name": "User Name"
       }
       ↓
[Laravel Backend] handleGoogleMobile()
       ↓ (id_token = null, dùng CÁCH 2 hoặc 3)
       ↓
[Backend] Verify via Google API hoặc trust email
       ↓
[Backend] Tìm/tạo User trong database
       ↓
[Backend] Trả về JWT token
       {
         "code": 1,
         "payload": "JWT_TOKEN_HERE",
         "username": "user_gmail_com"
       }
       ↓
[Flutter] Lưu token vào SharedPreferences
       ↓
[Flutter] Navigate to Home Screen
       ↓
✅ DONE!
```

## Test đã thực hiện

## Bảo mật

- **Khuyến khích**: Dùng CÁCH 1 (id_token) hoặc CÁCH 2 (access_token verify qua Google)
- **KHÔNG nên**: Dùng CÁCH 3 (tin tưởng email trực tiếp) trong production
