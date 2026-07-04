# Sabidos — Frontend Mobile 📱

O **Sabidos** é uma plataforma educacional móvel focada no aprendizado eficiente através de metodologias de estudos. Este repositório contém o código-fonte do frontend da aplicação, desenvolvido inteiramente em **Flutter**. O ecossistema se integra de forma híbrida com um backend robusto em **ASP.NET Core API** (para centralização de lógica de negócios e persistência principal) e com o **Firebase Firestore** para operações em tempo real, seguindo políticas rígidas de segurança.

---

## 🎓 Sobre o Projeto

O **Sabidos** nasceu como um projeto interdisciplinar do curso de **Desenvolvimento de Software Multiplataforma da FATEC**. O objetivo central é unir conceitos estruturais de engenharia de software com ferramentas e metodologias de estudo comprovadas em uma única solução prática e moderna.

A plataforma vai muito além da revisão convencional, oferecendo um ecossistema completo para maximizar o rendimento dos estudantes através das seguintes mecânicas:

- **Perfil Gamificado:** Um sistema de progressão contínua com **níveis, missões e conquistas**, criado para manter os usuários engajados e motivados na jornada de aprendizado.
- **Flashcards e Repetição Espaçada:** Criação, organização e revisão de cartões de estudo com um algoritmo otimizado para exibição com base no nível de retenção de memória.
- **Metodologia Pomodoro:** Temporizador nativo integrado ao fluxo de estudos para gerenciar ciclos de foco intenso e pausas, auxiliando no combate à procrastinação.
- **Área de Resumos:** Um espaço dedicado para a criação, formatação e organização de anotações, mantendo todo o material de apoio centralizado dentro do app.

---

## 🚀 Funcionalidades Técnicas Principais

- **Gerenciamento de Decks e Flashcards:** Criação, edição, organização e exclusão de baralhos de estudo personalizados.
- **Sincronização Híbrida:** Consumo centralizado de endpoints da API ASP.NET Core associado à reatividade do Firebase Firestore.
- **Autenticação Segura:** Fluxo completo de login, cadastro e recuperação de conta com validações locais e remotas.
- **Modo Offline:** Cache local estruturado para permitir revisões mesmo sem conectividade de rede.

---

## 🏗️ Arquitetura do Projeto

Para garantir a escalabilidade, testabilidade e manutenibilidade do app, o projeto adota uma variação da **Clean Architecture** dividida em camadas lógicas bem definidas dentro do diretório `lib/`:

```text
lib/
│
├── core/                  # Elementos compartilhados e configurações globais
│   ├── constants/         # Cores, estilos, dimensões e strings fixas
│   ├── network/           # Cliente HTTP (Dio/Http) configurado e interceptadores
│   ├── theme/             # Definições de temas (Light/Dark Mode)
│   └── utils/             # Funções utilitárias e helpers
│
├── data/                  # Camada de Dados (Infraestrutura)
│   ├── datasources/       # Fontes de dados: Remote (API/Firestore) e Local (SQLite/Hive)
│   ├── models/            # Serialização de dados (JSON mappers, subclasses de entidades)
│   └── repositories/      # Implementações concretas dos contratos de repositórios
│
├── domain/                # Camada de Domínio (Regras de Negócio Puras)
│   ├── entities/          # Objetos de negócio principais (ex: Card, Deck, User)
│   ├── repositories/      # Interfaces/Contratos abstratos dos repositórios
│   └── usecases/          # Casos de uso específicos do aplicativo
│
└── presentation/          # Camada de Apresentação (Interface de Usuário)
    ├── controllers/       # Gerenciadores de estado (Bloc, Cubit ou Provider)
    ├── screens/           # Telas principais da aplicação
    └── widgets/           # Componentes visuais modulares e reutilizáveis
```

---

## 🛠️ Tecnologias e Dependências Utilizadas

A stack principal utilizada no desenvolvimento do frontend engloba:

| Tecnologia / Pacote | Finalidade |
| :--- | :--- |
| **Flutter SDK** | Framework de desenvolvimento multiplataforma. |
| **Dart** | Linguagem de programação nativa do Flutter. |
| **Firebase Core & Firestore** | Integração com banco de dados em tempo real e regras de segurança. |
| **Dio** | Cliente HTTP avançado para consumo da API centralizada em ASP.NET Core. |
| **State Management** | Controle de estado reativo e ciclo de vida da UI (ex: BLoC / Provider). |

---

## ⚙️ Pré-requisitos e Configuração

Antes de iniciar, certifique-se de ter as seguintes ferramentas instaladas em sua máquina:

- **Flutter SDK** (Versão estável recomendada)
- **Dart SDK** (Incluso no Flutter)
- **Git**
- Um emulador configurado (Android/iOS) ou um dispositivo físico com depuração USB ativa.

### 1. Clonar o Repositório
```bash
git clone na branch main desse repositório
cd sabidos2app
```

### 2. Instalar as Dependências
Execute o comando abaixo para baixar todos os pacotes definidos no `pubspec.yaml`:
```bash
flutter pub get
```

### 3. Executar a Aplicação
Para rodar o projeto em modo de desenvolvimento:
```bash
flutter run
```

---

## 🛡️ Integração e Segurança (Firestore & API)

O **Sabidos** possui um ecossistema de dados muito bem protegido:
1. **API Centralizada:** Toda a lógica pesada de persistência relacional, relatórios e controle de usuários passa estritamente pela API desenvolvida em **ASP.NET Core**.
2. **Segurança no Firestore:** As coleções acessadas diretamente pelo Flutter possuem **Firestore Security Rules** parametrizadas, garantindo que um usuário autenticado possa ler e escrever única e exclusivamente em seus próprios documentos e Decks (`request.auth.uid == resource.data.userId`).

---

## 📝 Boas Práticas de Desenvolvimento

Ao contribuir para este repositório, lembre-se de:
- **Formatação:** Executar sempre `flutter format .` antes de abrir um Pull Request.
- **Análise Estatística:** Verificar se há alertas pendentes utilizando `flutter analyze`.
- **Commits Semânticos:** Adotar o padrão de Commits Semânticos (ex: `feat:`, `fix:`, `docs:`, `refactor:`).

---
Desenvolvido com 💙 como parte do Ecossistema Educacional **Sabidos**.