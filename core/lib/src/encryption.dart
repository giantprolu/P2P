import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class MessageEncryption {
  static final _iv = IV.fromLength(16);
  
  // In a real app, you would implement proper key exchange
  // This is a simplified version for demonstration
  static String encryptMessage(String message, String secretKey) {
    final key = Key.fromUtf8(padKey(secretKey));
    final encrypter = Encrypter(AES(key));
    
    final encrypted = encrypter.encrypt(message, iv: _iv);
    return encrypted.base64;
  }
  
  static String decryptMessage(String encryptedMessage, String secretKey) {
    final key = Key.fromUtf8(padKey(secretKey));
    final encrypter = Encrypter(AES(key));
    
    final encrypted = Encrypted.fromBase64(encryptedMessage);
    return encrypter.decrypt(encrypted, iv: _iv);
  }
  
  // Ensure key is exactly 32 bytes (256 bits) for AES-256
  static String padKey(String key) {
    if (key.length < 32) {
      return key.padRight(32, '*');
    } else if (key.length > 32) {
      return key.substring(0, 32);
    }
    return key;
  }
}