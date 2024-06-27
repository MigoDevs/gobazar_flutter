import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class CommonMethods {
  Future<void> checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();

    // Correção: Usar contains para verificar se connectionResult está na lista
    if (![ConnectivityResult.mobile, ConnectivityResult.wifi].contains(connectionResult)) {
      if (!context.mounted) return;
      displaySnackBar("Erro de conexão. Verifique a internet e tente novamente.", context);
      return;
    }

    // Verificação adicional para garantir que a Internet está realmente acessível
    bool hasConnection = await _checkInternetAccess();
    if (!hasConnection) {
      if (!context.mounted) return;
      displaySnackBar("Erro de conexão. Verifique a internet e tente novamente.", context);
    }
  }

  Future<bool> _checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void displaySnackBar(String messageText, BuildContext context) {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
