import 'package:simulador_ocpp/features/login/domain/models/login_credenciais.dart';

abstract class LoginRepository {
  Future<bool> autenticar(LoginCredenciais credenciais);
}
