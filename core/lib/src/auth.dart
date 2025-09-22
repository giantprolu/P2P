import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'auth.g.dart';

@JsonSerializable()
class AuthRequest {
  final String username;
  final String passwordHash;
  
  AuthRequest(this.username, this.passwordHash);
  
  factory AuthRequest.withPassword(String username, String password) {
    return AuthRequest(username, _hashPassword(password));
  }
  
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert to bytes
    var digest = sha256.convert(bytes);  // Hash the bytes
    return digest.toString();
  }
  
  factory AuthRequest.fromJson(Map<String, dynamic> json) => _$AuthRequestFromJson(json);
  
  Map<String, dynamic> toJson() => _$AuthRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final bool success;
  final String? token;
  final String? message;
  final UserData? userData;
  
  AuthResponse(this.success, {this.token, this.message, this.userData});
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

class AuthService {
  // Simulated token storage - in production would use secure storage
  static final Map<String, UserData> _tokenStore = {};
  
  static AuthResponse authenticate(AuthRequest request) {
    // In a real app, validate against database
    // This is just a demo implementation
    if (request.username == 'demo' && request.passwordHash == _hashPassword('password')) {
      final token = _generateToken();
      final userData = UserData('user_${DateTime.now().millisecondsSinceEpoch}', request.username);
      _tokenStore[token] = userData;
      return AuthResponse(true, token: token, userData: userData);
    }
    return AuthResponse(false, message: 'Invalid username or password');
  }
  
  static bool validateToken(String token) {
    return _tokenStore.containsKey(token);
  }
  
  static UserData? getUserFromToken(String token) {
    return _tokenStore[token];
  }
  
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  static String _generateToken() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000000).toString();
  }
}