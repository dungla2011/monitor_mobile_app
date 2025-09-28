// Firebase Cloud Messaging Service Worker
// This service worker is required for Firebase Messaging to work on web

importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

// Initialize Firebase in the service worker
firebase.initializeApp({
  apiKey: 'AIzaSyBCHpCDZoONPpwsiBurfvKqOqSMbzFlkio',
  authDomain: 'monitorv2-dcf5b.firebaseapp.com',
  projectId: 'monitorv2-dcf5b',
  storageBucket: 'monitorv2-dcf5b.firebasestorage.app',
  messagingSenderId: '916524608033',
  appId: '1:916524608033:web:YOUR_WEB_APP_ID_HERE', // ⚠️ THAY BẰNG APP ID TỪ FIREBASE CONSOLE
});

// Retrieve an instance of Firebase Messaging so that it can handle background messages
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);

  // Customize notification here
  const notificationTitle = payload.notification?.title || 'Background Message Title';
  const notificationOptions = {
    body: payload.notification?.body || 'Background Message Body',
    icon: '/favicon.png', // You can customize this
    badge: '/favicon.png',
    data: payload.data,
    tag: 'background-message' // Prevents duplicate notifications
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Optional: Handle notification click
self.addEventListener('notificationclick', (event) => {
  console.log('[firebase-messaging-sw.js] Notification click received.', event);

  event.notification.close();

  // Add custom logic here, e.g., open a specific URL
  event.waitUntil(
    clients.openWindow('http://localhost:61535') // Adjust URL as needed
  );
});