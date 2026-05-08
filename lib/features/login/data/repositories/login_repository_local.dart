import 'package:simulador_ocpp/features/login/domain/models/login_credenciais.dart';
import 'package:simulador_ocpp/features/login/domain/repositories/login_repository.dart';

class LoginRepositoryLocal implements LoginRepository {
  const LoginRepositoryLocal();

  @override
  Future<bool> autenticar(LoginCredenciais credenciais) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return credenciais.usuario == 'admin' && credenciais.senha == 'admin';
  }
}
