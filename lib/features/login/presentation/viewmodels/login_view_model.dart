import 'package:simulador_ocpp/features/login/data/repositories/login_repository_local.dart';
import 'package:simulador_ocpp/features/login/services/login_service.dart';
import 'package:simulador_ocpp/observable/rx.dart';

class LoginViewModel {
  LoginViewModel({LoginService? loginService})
    : _loginService =
          loginService ??
          const LoginService(repository: LoginRepositoryLocal());

  final LoginService _loginService;

  final carregando = Rx<bool>(false);
  final erro = Rx<String?>(null);
  final senhaVisivel = Rx<bool>(false);

  Future<bool> entrar({required String usuario, required String senha}) async {
    erro.value = null;

    try {
      final credenciais = _loginService.criarCredenciais(
        usuario: usuario,
        senha: senha,
      );

      carregando.value = true;
      await _loginService.autenticar(credenciais);
      return true;
    } on LoginException catch (exception) {
      erro.value = exception.mensagem;
      return false;
    } finally {
      carregando.value = false;
    }
  }

  void alternarVisibilidadeSenha() {
    senhaVisivel.value = !senhaVisivel.value;
  }

  void dispose() {
    carregando.dispose();
    erro.dispose();
    senhaVisivel.dispose();
  }
}
