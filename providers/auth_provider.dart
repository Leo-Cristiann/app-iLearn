import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:project_ilearn/services/user_service.dart';
import 'dart:developer';

class AuthProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isStudent => _user != null && _user!.userType == 'student';
  bool get isEducator => _user != null && _user!.userType == 'educator';
  
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      log("AuthProvider: Memulai proses login untuk email: $email");
      
      // Login ke Firebase Auth
      UserCredential userCredential;
      try {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        log("Login berhasil dengan uid: ${userCredential.user?.uid}");
      } catch (authError) {
        log("Error saat login di Firebase Auth: $authError");
        
        if (authError is FirebaseAuthException) {
          switch (authError.code) {
            case 'user-not-found':
              _error = 'Email tidak terdaftar';
              break;
            case 'wrong-password':
              _error = 'Password salah';
              break;
            case 'invalid-email':
              _error = 'Format email tidak valid';
              break;
            case 'user-disabled':
              _error = 'Akun telah dinonaktifkan';
              break;
            default:
              _error = authError.message ?? 'Error saat login';
          }
        } else {
          _error = authError.toString();
        }
        
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Dapatkan userId dari user yang login
      final userId = userCredential.user?.uid;
      if (userId == null) {
        _error = 'Gagal mendapatkan user ID';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Ambil data user dari Firestore
      try {
        final userDoc = await _userService.getUserById(userId);
        
        if (userDoc != null) {
          _user = userDoc;
          _isLoading = false;
          notifyListeners();
          return true;
        }
        
        // Jika user tidak ditemukan di Firestore, coba buat profil baru
        log("User tidak ditemukan di Firestore, mencoba membuat profil baru");
        
        final email = userCredential.user?.email ?? '';
        final username = email.split('@')[0]; // Username default
        
        // Coba buat sebagai student (default)
        final success = await _userService.createStudent(
          userId: userId,
          username: username,
          email: email,
        );
        
        if (success) {
          // Ambil lagi data user
          final newUserDoc = await _userService.getUserById(userId);
          
          if (newUserDoc != null) {
            _user = newUserDoc;
            _isLoading = false;
            notifyListeners();
            return true;
          }
        }
        
        // Jika masih gagal, buat objek user manual
        _user = StudentModel(
          id: userId,
          username: username,
          email: email,
          joinedDate: DateTime.now(),
          isActive: true,
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (getUserError) {
        log("Error saat mengambil data user setelah login: $getUserError");
        
        // Buat objek user manual sebagai fallback
        final email = userCredential.user?.email ?? '';
        final username = email.split('@')[0];
        
        _user = StudentModel(
          id: userId,
          username: username,
          email: email,
          joinedDate: DateTime.now(),
          isActive: true,
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      log("Error umum pada proses login: $e");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> register(
    String email,
    String password,
    String username,
    String userType,
    {String? specialization}
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      log("AuthProvider: Memulai proses register untuk email: $email");
      
      // Buat user di Firebase Auth
      UserCredential userCredential;
      try {
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        log("User berhasil dibuat di Firebase Auth dengan uid: ${userCredential.user?.uid}");
      } catch (authError) {
        log("Error saat membuat user di Firebase Auth: $authError");
        
        if (authError is FirebaseAuthException) {
          switch (authError.code) {
            case 'email-already-in-use':
              _error = 'Email sudah digunakan';
              break;
            case 'invalid-email':
              _error = 'Format email tidak valid';
              break;
            case 'weak-password':
              _error = 'Password terlalu lemah';
              break;
            default:
              _error = authError.message ?? 'Error saat registrasi';
          }
        } else {
          _error = authError.toString();
        }
        
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Dapatkan userId dari user yang baru dibuat
      final userId = userCredential.user?.uid;
      if (userId == null) {
        _error = 'Gagal mendapatkan user ID';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Simpan data user ke Firestore
      bool saveSuccess = false;
      try {
        if (userType == 'student') {
          saveSuccess = await _userService.createStudent(
            userId: userId,
            username: username,
            email: email,
          );
        } else {
          saveSuccess = await _userService.createEducator(
            userId: userId,
            username: username,
            email: email,
            specialization: specialization ?? '',
          );
        }
        
        log("Simpan data ke Firestore: ${saveSuccess ? 'berhasil' : 'gagal'}");
      } catch (firestoreError) {
        log("Error saat menyimpan data user ke Firestore: $firestoreError");
        saveSuccess = false;
      }
      
      // Ambil data user yang baru dibuat
      try {
        final userDoc = await _userService.getUserById(userId);
        
        if (userDoc != null) {
          _user = userDoc;
          _isLoading = false;
          notifyListeners();
          return true;
        }
        
        // Jika gagal mendapatkan dari Firestore, buat objek user manual
        if (!saveSuccess) {
          log("Data tidak ditemukan di Firestore, membuat objek manual");
          if (userType == 'student') {
            _user = StudentModel(
              id: userId,
              username: username,
              email: email,
              joinedDate: DateTime.now(),
              isActive: true,
            );
          } else {
            _user = EducatorModel(
              id: userId,
              username: username,
              email: email,
              joinedDate: DateTime.now(),
              isActive: true,
              specialization: specialization ?? '',
            );
          }
          
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } catch (getUserError) {
        log("Error saat mengambil data user setelah registrasi: $getUserError");
        
        // Buat objek user manual sebagai fallback
        if (userType == 'student') {
          _user = StudentModel(
            id: userId,
            username: username,
            email: email,
            joinedDate: DateTime.now(),
            isActive: true,
          );
        } else {
          _user = EducatorModel(
            id: userId,
            username: username,
            email: email,
            joinedDate: DateTime.now(),
            isActive: true,
            specialization: specialization ?? '',
          );
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = 'Gagal membuat profil user';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      log("Error umum pada proses registrasi: $e");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> checkCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Dapatkan user saat ini langsung dari FirebaseAuth
      final firebaseUser = FirebaseAuth.instance.currentUser;
      
      if (firebaseUser != null) {
        final userDoc = await _userService.getUserById(firebaseUser.uid);
        
        if (userDoc != null) {
          _user = userDoc;
        }
      }
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await FirebaseAuth.instance.signOut();
      _user = null;
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> updateProfile(Map<String, String> profileData) async {
    if (_user == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await _userService.updateUserProfile(_user!.id, profileData);
      
      final userDoc = await _userService.getUserById(_user!.id);
      
      if (userDoc != null) {
        _user = userDoc;
      }
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Menggunakan FirebaseAuth langsung
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Handle Firebase authentication errors specifically
      String errorMessage = 'An error occurred while sending password reset email';
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'The email address is not valid';
            break;
          case 'user-not-found':
            errorMessage = 'No user found with this email';
            break;
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your connection';
            break;
          default:
            errorMessage = e.message ?? 'Error sending password reset email';
        }
      } else {
        errorMessage = e.toString();
      }
      
      _error = errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    if (_user == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Find the notification by ID and mark it as read
      await _userService.markNotificationAsRead(_user!.id, notificationId);
      
      // Refresh user data
      final userDoc = await _userService.getUserById(_user!.id);
      
      if (userDoc != null) {
        _user = userDoc;
      }
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
}