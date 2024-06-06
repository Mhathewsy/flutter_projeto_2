import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';


import 'sobre_page.dart'; // Importação da pagina sobre

// Função principal para rodar o aplicativo
void main() {
  runApp(MyApp());
}

// Definição do widget principal do aplicativo
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 34, 244, 255)),
        ),
        home: MyHomePage(),
        routes: {
          // Adicione a rota para SobrePage
          '/sobre': (context) => SobrePage(), // Rota para a página "Sobre"
        },
      ),
    );
  }
}

// Estado principal do aplicativo, contendo a lógica de negócios
class MyAppState extends ChangeNotifier {
  var current = WordPair.random(); // Palavra atual gerada

  void getNext() {
    current = WordPair.random(); // Gera uma nova palavra
    notifyListeners();
  }

  var favorites = <WordPair>[]; // Lista de favoritos

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current); // Remove da lista de favoritos se já estiver presente
    } else {
      favorites.add(current); // Adiciona à lista de favoritos se ainda não estiver presente
    }
    notifyListeners();
  }
}

// Definição da página inicial do aplicativo
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // Índice da página selecionada

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage(); // Página do gerador de palavras
        break;
      case 1:
        page = FavoritesPage(); // Página de favoritos
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Início'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favoritos'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value; // Altera o índice da página selecionada
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page, // Exibe a página selecionada
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Página de Gerador de palavras
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Obtém o estado global do aplicativo
    var pair = appState.current; // Obtém a palavra atual gerada

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite; // Ícone do botão de favorito
    } else {
      icon = Icons.favorite_border; // Ícone do botão de não favorito
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair), // Exibe a palavra gerada
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(); // Alterna o estado do favorito ao pressionar o botão
                },
                icon: Icon(icon),
                label: Text('Curtir'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext(); // Obtém a próxima palavra gerada
                },
                child: Text('Próxima'),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Botão para navegar para SobrePage
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/sobre'); // Navega para a página "Sobre"
            },
            child: Text('Sobre'),
          ),
        ],
      ),
    );
  }
}

// Widget BigCard que mostra o par de palavras atual
class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

// Página de Favoritos
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Obtém o estado global do aplicativo

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('Nenhum favorito ainda.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Você tem ${appState.favorites.length} favoritos:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}