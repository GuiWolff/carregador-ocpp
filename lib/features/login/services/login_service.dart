import 'package:simulador_ocpp/features/login/domain/models/login_credenciais.dart';
import 'package:simulador_ocpp/features/login/domain/repositories/login_repository.dart';

class LoginService {
  const LoginService({required LoginRepository repository})
    : _repository = repository;

  final LoginRepository _repository;

  LoginCredenciais criarCredenciais({
    required String usuario,
    required String senha,
  }) {
    final credenciais = LoginCredenciais.normalizadas(
      usuario: usuario,
      senha: senha,
    );

    if (credenciais.incompletas) {
      throw const LoginException('Informe usuário e senha.');
    }

    return credenciais;
  }

  Future<void> autenticar(LoginCredenciais credenciais) async {
    final autenticado = await _repository.autenticar(credenciais);

    if (!autenticado) {
      throw const LoginException('Credenciais inválidas.');
    }
  }
}

class LoginException implements Exception {
  const LoginException(this.mensagem);

  final String mensagem;
}
