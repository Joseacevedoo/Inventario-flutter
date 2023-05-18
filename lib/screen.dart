import 'package:flutter/material.dart';
import 'package:flutter_application_1/sql_helper.dart';
import 'delegate_search.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // All journals
  List<Map<String, dynamic>> inventariado = [];

  bool _isLoading = true;
  // Funcion para obtener los datos de la base de datos
  void _refreshInventariado() async {
    final data = await SQLHelper.getInventario();
    setState(() {
      inventariado = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshInventariado(); // Cargar el inventariado cuando carga la app
  }

  //controlador de los campos de texto a ingresar
  final TextEditingController _productoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  // Cuando se presione el floatting button se activara esta funcion
  //y cuando se desee actualizar
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> crear un nuevo producto
      // id != null -> actualizar un producto
      final inventariadoExistente =
          inventariado.firstWhere((element) => element['id'] == id);
      _productoController.text = inventariadoExistente['producto'];
      _descripcionController.text = inventariadoExistente['descripcion'];
      _precioController.text = inventariadoExistente['precio'].toString();
      _cantidadController.text = inventariadoExistente['cantidad'].toString();
      _stockController.text = inventariadoExistente['stock'].toString();
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          // Evita que el teclado cubra los campos de texto
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              textCapitalization: TextCapitalization.sentences,
              controller: _productoController,
              decoration: const InputDecoration(
                  icon: Icon(Icons.sell), labelText: 'Producto'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              textCapitalization: TextCapitalization.sentences,
              controller: _descripcionController,
              decoration: const InputDecoration(
                  icon: Icon(Icons.description),
                  labelText: 'Descripcion(Marca)'),
            ),
            TextField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              controller: _precioController,
              decoration: const InputDecoration(
                icon: Icon(Icons.attach_money),
                labelText: 'Precio x unidad',
                prefixText: '\$',
              ),
            ),
            TextField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              controller: _cantidadController,
              decoration: const InputDecoration(
                icon: Icon(Icons.inventory_2_outlined),
                labelText: 'Precio x caja',
                prefixText: '\$',
              ),
            ),
            TextField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              controller: _stockController,
              decoration: const InputDecoration(
                icon: Icon(Icons.inventory),
                labelText: 'Cantidad (Stock)',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                // Guardar un nuevo producto
                if (id == null) {
                  await _addItem();
                }

                if (id != null) {
                  await _updateItem(id);
                }

                // Limpiar los textfields
                _productoController.text = " ";
                _descripcionController.text = " ";
                _precioController.text = " ";
                _cantidadController.text = " ";
                _stockController.text = " ";

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(id == null ? 'Agregar Producto' : 'Actualizar',
                  style: GoogleFonts.signikaNegative()),
            ),
          ],
        ),
      ),
    );
  }

// Insertar un nuevo producto
  Future<void> _addItem() async {
    await SQLHelper.createProducto(
        _productoController.text,
        _descripcionController.text,
        double.parse(_precioController.text),
        double.parse(_cantidadController.text),
        int.parse(_stockController.text));
    _refreshInventariado();
  }

  // Actualizar un producto
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateProducto(
        id,
        _productoController.text,
        _descripcionController.text,
        double.parse(_precioController.text),
        double.parse(_cantidadController.text),
        int.parse(_stockController.text));
    _refreshInventariado();
  }

  // Borrar un item
  void _deleteItem(int id) async {
    await SQLHelper.deleteProducto(id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Eliminado con exito'),
      ));
    }
    _refreshInventariado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text('Inventario', style: GoogleFonts.signikaNegative()),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: MyDelegateSearch(
                      inventariado,
                      showProductDetails: showProductDetails,
                    ));
              },
            )
          ]),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: inventariado.length,
              itemBuilder: (context, index) => SizedBox(
                height: 180,
                child: Card(
                  elevation: 5.0,
                  color: Colors.teal,
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    title: RichText(
                      text: TextSpan(
                        children: [
                          const WidgetSpan(
                            child: Icon(Icons.sell, size: 18),
                          ),
                          TextSpan(
                            text: inventariado[index]['producto'],
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily:
                                    GoogleFonts.signikaNegative().fontFamily),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              const WidgetSpan(
                                child: Icon(Icons.description, size: 18),
                              ),
                              TextSpan(
                                text: (inventariado[index]['descripcion']),
                                style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: GoogleFonts.signikaNegative()
                                        .fontFamily),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                            text: TextSpan(children: [
                          const WidgetSpan(child: Icon(Icons.attach_money)),
                          TextSpan(
                            text:
                                ('Precio x unidad:\$${inventariado[index]['precio'].toString()}'),
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily:
                                    GoogleFonts.signikaNegative().fontFamily),
                          )
                        ])),
                        RichText(
                            text: TextSpan(children: [
                          const WidgetSpan(
                              child: Icon(Icons.inventory_2_outlined)),
                          TextSpan(
                            text:
                                ('Precio x caja: \$${inventariado[index]['cantidad'].toString()}'),
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily:
                                    GoogleFonts.signikaNegative().fontFamily),
                          )
                        ])),
                        RichText(
                            text: TextSpan(children: [
                          const WidgetSpan(child: Icon(Icons.inventory)),
                          TextSpan(
                            text:
                                ('Stock: ${inventariado[index]['stock'].toString()}'),
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily:
                                    GoogleFonts.signikaNegative().fontFamily),
                          )
                        ]))
                      ],
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _showForm(inventariado[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteItem(inventariado[index]['id']),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }

  void showProductDetails(int titleId) {
    // Obtener el producto seleccionado
    Map<String, dynamic> selectedProduct =
        inventariado.firstWhere((element) => element['id'] == titleId);

    // Mostrar los detalles del producto en un diálogo
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.teal[200],
          title: Text(selectedProduct['producto'], textAlign: TextAlign.center),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Descripción:${selectedProduct['descripcion']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text('Precio x unidad:\$ ${selectedProduct['precio']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Precio x caja:\$ ${selectedProduct['cantidad']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Stock: ${selectedProduct['stock']}',
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
            ButtonBar(
              children: [
                TextButton(
                  onPressed: () {
                    // Editar el producto
                    Navigator.pop(context); // Cerrar el diálogo
                    _showForm(titleId); // Mostrar el formulario
                  },
                  child: const Text('Actualizar',
                      style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar el diálogo
                  },
                  child: const Text('Cerrar',
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
