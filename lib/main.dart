import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(TesteAuth());
}

class TesteAuth extends StatefulWidget {
  const TesteAuth({super.key});

  @override
  State<TesteAuth> createState() => _TesteAuthState();
}

class _TesteAuthState extends State<TesteAuth> {

  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _cancheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Não Autorizado';
  bool _isAuthenticating = false;


@override
void initState(){
  super.initState();
  auth.isDeviceSupported().then(
    (bool isSupported) => setState(() => _supportState = isSupported
    ? _SupportState.supported : _SupportState.unsupported,)
  );
}

  // if can check biometrics
  Future<void> _checkBiometrics() async {
    late bool cancheckBiometrics;
    try {
      cancheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      cancheckBiometrics = false;
      print(e);
    }
    if (!mounted){
      return;
    }
    setState(() {
      _cancheckBiometrics = cancheckBiometrics;
    });
  }

  //if biometrics is available
  Future<void> _getAvailableBiometrics() async{
    late List<BiometricType> availableBiometrics;
    try{
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    } if (!mounted) {
      return;
    }
    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  //authenticating
  Future<void>  _authenticate() async{
    bool authenticated = false;
    try{
      setState(() {
        _isAuthenticating = true; // if is authenticate is true return line below
        _authorized = "Autenticando";
      });
      authenticated = await auth.authenticate(
        localizedReason: "SO determina o método",
        options: const AuthenticationOptions(
          stickyAuth: true,
        )
      );
      setState(() {
      _isAuthenticating = false;
      });
    } on PlatformException catch (e){
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Ops! Tivemos um erro - ${e.message}'; 
      });
      return;
    } if(!mounted) {
      return;
    }
    setState(() => _authorized = authenticated? 'Autorizado' : 'Não Autorizado');  
  }

  //authenticated only with biometrics
  Future<void> _authenticateWithBiometrics() async{
    bool authenticated = false;
    try{
      setState(() {
        _isAuthenticating = true;
        _authorized = "Autenticando";
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Escaneie sua digital para autenticar',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        )
      );
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Ops! Tivemos um erro - ${e.message}'; 
      });
      return;

    } if (!mounted){
      return;
    }
    final String message = authenticated ?  'Autorizado' : 'Não Autorizado';
    setState(() {
      _authorized = message;
    }); 
  }

  Future<void> _cancelAuthentication() async{
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          padding: const EdgeInsets.only(top: 30),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_supportState == _SupportState.unknown)
                  const CircularProgressIndicator()
                else if (_supportState == _SupportState.supported)
                  const Text('This device is supported')
                else
                  const Text('This device is not supported'),
                const Divider(height: 100),
                Text('Can check biometrics: $_cancheckBiometrics\n'),
                ElevatedButton(
                  onPressed: _checkBiometrics,
                  child: const Text('Check biometrics'),
                ),
                const Divider(height: 100),
                Text('Available biometrics: $_availableBiometrics\n'),
                ElevatedButton(
                  onPressed: _getAvailableBiometrics,
                  child: const Text('Get available biometrics'),
                ),
                const Divider(height: 100),
                Text('Current State: $_authorized\n'),
                if (_isAuthenticating)
                  ElevatedButton(
                    onPressed: _cancelAuthentication,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Text('Cancel Authentication'),
                        Icon(Icons.cancel),
                      ],
                    ),
                  )
                else
                  Column(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: _authenticate,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const <Widget>[
                            Text('Authenticate'),
                            Icon(Icons.perm_device_information),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _authenticateWithBiometrics,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(_isAuthenticating
                                ? 'Cancel'
                                : 'Authenticate: biometrics only'),
                            const Icon(Icons.fingerprint),
                          ],
                        ),   
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}