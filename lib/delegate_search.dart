import 'package:flutter/material.dart';
//import 'package:flutter_application_1/screen.dart';

class MyDelegateSearch extends SearchDelegate {
  List<Map<String, dynamic>> inventariado = [];
  Function(int) showProductDetails;
  MyDelegateSearch(this.inventariado, {required this.showProductDetails});

  @override
  String get searchFieldLabel => 'Buscar producto';
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(
    BuildContext context,
  ) {
    List<Map<String, dynamic>> matchQuery = [];
    for (Map<String, dynamic> product in inventariado) {
      String productName = product['producto'];
      if (productName.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(product);
      }
    }

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result['producto'] as String),
          trailing: const SizedBox(
            width: 100,
          ),
          onTap: () {
            int productId = result['id'] as int;
            close(context, null); // Cerrar la búsqueda
            showProductDetails(
                productId); // Mostrar los detalles del producto seleccionado
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Map<String, dynamic>> matchQuery = [];
    for (Map<String, dynamic> product in inventariado) {
      String productName = product['producto'];
      if (productName.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(product);
      }
    }

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result['producto'] as String),
          trailing: const SizedBox(
            width: 100,
          ),
          onTap: () {
            int productId = result['id'] as int;
            close(context, null); // Cerrar la búsqueda
            showProductDetails(
                productId); // Mostrar los detalles del producto seleccionado
          },
        );
      },
    );
  }
}
