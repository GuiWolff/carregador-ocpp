class LoginCredenciais {
  const LoginCredenciais({required this.usuario, required this.senha});

  factory LoginCredenciais.normalizadas({
    required String usuario,
    required String senha,
  }) {
    return LoginCredenciais(usuario: usuario.trim(), senha: senha.trim());
  }

  final String usuario;
  final String senha;

  bool get incompletas => usuario.isEmpty || senha.isEmpty;
}
