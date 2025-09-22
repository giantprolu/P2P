import 'package:flutter/material.dart';
import 'package:p2p_chat_android/constants.dart';
import 'package:p2p_chat_android/bluetooth/bluetooth_provider.dart';
import 'package:p2p_chat_android/model/models.dart';
import 'package:p2p_chat_android/page/home_page.dart';
import 'package:p2p_chat_android/sql/database_helper.dart';
import 'package:p2p_chat_core/p2p_chat_core.dart';

class LoginPage extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const LoginPage({Key? key, required this.dbHelper}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bluetoothProvider = BluetoothNetworkProvider();
  
  String? _selectedRelay;
  List<String> _availableRelays = [];
  bool _isScanning = false;
  bool _isLoggingIn = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scanForRelays();
  }

  Future<void> _scanForRelays() async {
    setState(() {
      _isScanning = true;
      _availableRelays = [];
    });

    try {
      final relays = await _bluetoothProvider.scanForRelays();
      setState(() {
        _availableRelays = relays;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to scan for relays: $e";
        _isScanning = false;
      });
    }
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "Username and password are required";
      });
      return;
    }

    if (_selectedRelay == null) {
      setState(() {
        _errorMessage = "Please select a relay";
      });
      return;
    }

    setState(() {
      _isLoggingIn = true;
      _errorMessage = null;
    });

    try {
      // Connect to relay
      final connected = await _bluetoothProvider.connectToRelay(_selectedRelay!.split('|')[1]);
      
      if (!connected) {
        setState(() {
          _errorMessage = "Failed to connect to relay";
          _isLoggingIn = false;
        });
        return;
      }

      // Create auth request
      // Uncomment and use when implementing actual authentication with relay
      // final authRequest = AuthRequest.withPassword(_usernameController.text, _passwordController.text);
      
      // TODO: Send auth request to relay and get response
      // This would require implementing the actual communication with the relay
      
      // For now, simulate successful authentication
      final userData = UserData(
        'user_${DateTime.now().millisecondsSinceEpoch}', 
        _usernameController.text
      );
      
      // Save user data
      await widget.dbHelper.createUser(userData);
      
      // Navigate to home page
      final conversations = await widget.dbHelper.findAllConversations();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            title: APP_NAME,
            context: Context(widget.dbHelper, userData),
            conversations: conversations,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = "Login failed: $e";
        _isLoggingIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(kDefaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: kDefaultPadding),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: kDefaultPadding),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Relay",
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedRelay,
                    items: _availableRelays.map((relay) {
                      final parts = relay.split('|');
                      final name = parts[0];
                      return DropdownMenuItem(
                        value: relay,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRelay = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _isScanning ? null : _scanForRelays,
                ),
              ],
            ),
            
            if (_isScanning)
              Padding(
                padding: EdgeInsets.symmetric(vertical: kDefaultPadding),
                child: CircularProgressIndicator(),
              ),
              
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: kErrorColor),
                ),
              ),
              
            SizedBox(height: kDefaultPadding),
            
            ElevatedButton(
              onPressed: _isLoggingIn ? null : _login,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: _isLoggingIn 
                ? CircularProgressIndicator(color: Colors.white)
                : Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}