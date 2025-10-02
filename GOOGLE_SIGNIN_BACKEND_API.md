# Google Sign-In Backend API cho Flutter App

## ⚠️ Vấn đề với code hiện tại

Backend hiện có 2 URL:
- `/auth/google` - Redirect sang Google OAuth
- `/google/callback` - Callback từ Google, redirect về `/member`

**Vấn đề**: Callback redirect về trang web, không trả JSON cho Flutter app.

## ✅ Giải pháp

Có 2 cách:

### Cách 1: Tạo API endpoint mới (RECOMMENDED)

Tạo endpoint mới để Flutter app gửi Google ID token và nhận JWT token.

#### POST /api/auth/google-mobile

**Request:**
```json
{
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjU...",
  "email": "user@gmail.com",
  "name": "User Name"
}
```

**Response:**
```json
{
  "code": 1,
  "payload": "YOUR_JWT_TOKEN_HERE",
  "username": "user_gmail_com",
  "message": "Đăng nhập thành công"
}
```

**Code Laravel:**

```php
// routes/api.php
Route::post('/auth/google-mobile', [AuthController::class, 'handleGoogleMobile']);

// app/Http/Controllers/AuthController.php
public function handleGoogleMobile(Request $request)
{
    try {
        $idToken = $request->input('id_token');
        $email = $request->input('email');
        $name = $request->input('name');
        
        // Verify Google ID token
        $client = new \Google_Client([
            'client_id' => env('GOOGLE_CLIENT_ID', '211733424826-d7dns77hrghn70tugmlbo7p15ugfed4m.apps.googleusercontent.com')
        ]);
        
        $payload = $client->verifyIdToken($idToken);
        
        if (!$payload || $payload['email'] !== $email) {
            return response()->json([
                'code' => 0,
                'message' => 'Invalid Google token'
            ], 401);
        }
        
        // Tìm hoặc tạo user (COPY LOGIC TỪ handleGoogleCallback)
        $userGG = (object)['email' => $email, 'name' => $name];
        $objUser = User::where('email', $userGG->email)->first();
        
        if (!$objUser) {
            // Check deleted user
            if ($objUser = User::withTrashed()->where('email', $userGG->email)->first()) {
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
            $newUser->username = str_replace(['.', '@', '-'], '_', $userGG->email);
            $newUser->email = $userGG->email;
            $newUser->save();
            
            $newUser->setUserTokenIfEmpty();
            
            if (isEmailIsAutoSetAdmin($userGG->email)) {
                $newUser->is_admin = 1;
            }
            $newUser->email_active_at = now();
            $newUser->update();
            
            if (isEmailIsAutoSetAdmin($userGG->email)) {
                $obj = User::findUserWithEmail($userGG->email);
                $obj->_roles()->sync([1, 3]);
            } else {
                $newUser->_roles()->sync([DEF_GID_ROLE_MEMBER]);
            }
            
            AffiliateLog::checkAffCode($newUser->id);
            $objUser = $newUser;
        }
        
        // Trả về JWT token
        return response()->json([
            'code' => 1,
            'payload' => $objUser->getJWTUserToken(),
            'username' => $objUser->username,
            'message' => 'Đăng nhập thành công'
        ]);
        
    } catch (\Exception $e) {
        return response()->json([
            'code' => 0,
            'message' => 'Lỗi: ' . $e->getMessage()
        ], 500);
    }
}
```

**Install Google API Client (nếu chưa có):**
```bash
composer require google/apiclient
```

---

### Cách 2: Sửa callback để detect Flutter app (KHÔNG KHUYẾN KHÍCH)

Thêm parameter `?mobile=1` và trả JSON thay vì redirect:

```php
public function handleGoogleCallback(Request $request)
{
    $isMobile = $request->query('mobile') == '1';
    
    try {
        $userGG = Socialite::driver('google')->user();
        // ... existing logic ...
        
        if ($isMobile) {
            // Trả JSON cho mobile app
            return response()->json([
                'code' => 1,
                'payload' => $objUser->getJWTUserToken(),
                'username' => $objUser->username,
            ]);
        } else {
            // Redirect cho web
            return redirect('/member');
        }
        
    } catch (\Exception $e) {
        if ($isMobile) {
            return response()->json(['code' => 0, 'message' => $e->getMessage()], 500);
        }
        // ... existing error handling ...
    }
}
```

---

## 🎯 Khuyến nghị

**Dùng Cách 1** vì:
- ✅ Tách biệt logic web và mobile
- ✅ Secure hơn (verify ID token)
- ✅ Không ảnh hưởng code web hiện tại
- ✅ Dễ maintain và test

**Cách 2** chỉ nên dùng nếu:
- Không muốn cài Google API Client
- Cần nhanh cho demo

---

## 📝 Cấu hình

### .env
```env
GOOGLE_CLIENT_ID=211733424826-d7dns77hrghn70tugmlbo7p15ugfed4m.apps.googleusercontent.com
```

### CORS (nếu cần)
```php
// config/cors.php
'paths' => ['api/*'],
'allowed_origins' => ['http://localhost:8008', 'https://yourapp.com'],
```

