import 'package:flutter/material.dart';



class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Login / Cadastro'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Login'),
                Tab(text: 'Cadastro'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              LoginForm(),
              CadastroForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'E-mail'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Senha'),
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Aqui você faria a lógica de login
              // Exemplo de simulação:
              if (_emailController.text == 'user@example.com' && _passwordController.text == '1234') {
                // Simula um sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Login bem-sucedido!')),
                );
                // Aqui você faria o redirecionamento
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Credenciais inválidas')),
                );
              }
            },
            child: Text('Entrar'),
          ),
        ],
      ),
    );
  }
}

class CadastroForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'E-mail'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Senha'),
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Aqui você faria a lógica de cadastro
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cadastro feito com sucesso!')),
              );
            },
            child: Text('Cadastrar'),
          ),
        ],
      ),
    );
  }
}