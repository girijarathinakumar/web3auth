import 'dart:collection';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:web3auth/screens/call_screen.dart';
import 'package:web3auth/screens/message_screen.dart';
import 'package:web3auth/screens/person_screen.dart';
import 'package:web3auth/screens/setting_screen.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _result = '';
  bool logoutVisible = false;
  String rpcUrl = 'https://rpc.ankr.com/eth_goerli';
  void onTabTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }
  int _selectedIndex = 0;

  Future<void> initPlatformState() async {
    final themeMap = HashMap<String, String>();
    themeMap['primary'] = "#229954";

    Uri redirectUrl;

    if (Platform.isAndroid) {
      redirectUrl = Uri.parse('https://com.example.web3auth');
    } else if (Platform.isIOS) {
      redirectUrl = Uri.parse('com.example.w3aflutter://openlogin');
    } else {
      throw UnKnownException('Unknown platform');
    }

    await Web3AuthFlutter.init(Web3AuthOptions(
        clientId:
        'BJWqYNwacimOkzp1rUeFCKRpN5JN0xVceemWdhcB6CgQBRpWsH7lcJV-wF5Oipki0IemPqPwoG2WsBCjIBkCE_4',
        network: Network.testnet,
        redirectUrl: redirectUrl,
        whiteLabel: WhiteLabelData(
            dark: true, name: "Web3Auth Flutter App", theme: themeMap)));

  }



  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: Colors.white,
          body:
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                ),
                Row(
                    children: [
                      Text(
                        "Today's Task",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily:
                            "assets/fonts/Didact_Gothic/DidactGothic-Regular.ttf",
                            fontWeight: FontWeight.w500,
                            fontSize: 22),
                      ),
                      SizedBox(
                        width: 140,
                      ),
                      Visibility(
                        child: TextButton(
                            onPressed:_login(_withGoogle),

                            child: Text(
                              "Connect",
                              style: TextStyle(color: Colors.black),
                            )),
                      )
                    ]),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.withOpacity(0.2)),
                  child: TabBar(
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white),
                    labelColor: Colors.black,
                    dividerColor: Colors.black,
                    tabs: const [
                      Tab(text: "All"),
                      Tab(
                        text: "Work",
                      ),
                      Tab(
                        text: "Person",
                      ),
                      Tab(
                        text: "Design",
                      )
                    ],
                  ),
                ),
                 const Expanded(
                    child: TabBarView(
                      children: [
                        CallScreen(),
                        PersonScreen(),
                        MessageScreen(),
                        SettingScreen(),
                      ],
                    )),
              ]),
          bottomNavigationBar: BottomAppBar(

            color: Colors.black,
            shape:  CircularNotchedRectangle(),
            notchMargin: 8.0,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon:  Icon(
                    Icons.call,
                    color: _selectedIndex == 3 ? Colors.deepOrange:Colors.white,
                  ),
                  onPressed: () {
                    onTabTapped(3);
                    Navigator.push(context,MaterialPageRoute(builder: (ctx)=>CallScreen()));


                  },
                ),
                IconButton(
                  icon:  Icon(
                    Icons.person,
                    color:_selectedIndex == 2 ? Colors.deepOrange:Colors.white,
                  ),
                  onPressed: () {
                    onTabTapped(2);
                    Navigator.push(context,MaterialPageRoute(builder: (ctx)=>PersonScreen()));

                  },
                ),
                const SizedBox(width: 48.0),
                IconButton(
                  icon:  Icon(
                    Icons.messenger_outlined,
                    color: _selectedIndex == 1 ? Colors.deepOrange:Colors.white,
                  ),
                  onPressed: () {
                    onTabTapped(1);
                    Navigator.push(context,MaterialPageRoute(builder: (ctx)=>MessageScreen()));

                  },
                ),
                IconButton(
                  icon:  Icon(
                    Icons.settings,
                    color: _selectedIndex == 0 ? Colors.deepOrange:Colors.white,
                  ),
                  onPressed: () {
                    onTabTapped(0);
                    Navigator.push(context,MaterialPageRoute(builder: (ctx)=>SettingScreen()));
                  },
                ),

              ],


            ),
          ),
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.deepOrange,
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PersonScreen()));
            },
          ),
        ));
  }
  VoidCallback _login(Future<Web3AuthResponse> Function() method) {
    return () async {
      try {
        final Web3AuthResponse response = await method();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('privateKey', response.privKey.toString());
        setState(() {
          _result = response.toString();
          logoutVisible = true;
        });
      } on UserCancelledException {
        print("User cancelled.");
      } on UnKnownException {
        print("Unknown exception occurred");
      }
    };
  }

  Future<Web3AuthResponse> _withGoogle() {
    return Web3AuthFlutter.login(LoginParams(
      loginProvider: Provider.google,
      mfaLevel: MFALevel.DEFAULT,
    ));
  }


}
