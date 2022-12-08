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
  bool? _cancheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Não Autorizado';
  bool _isAuthenticating = false;


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
    }
  }



  @override
  Widget build(BuildContext context) {
    return Container();
  }
}