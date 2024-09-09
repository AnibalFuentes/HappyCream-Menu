import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_happy_cream/UI/pages/cart/cart_page.dart';
import 'package:menu_happy_cream/controllers/cart_controller.dart';
import 'package:menu_happy_cream/controllers/category_controller.dart';
import 'package:menu_happy_cream/controllers/product_controller.dart';
import 'package:menu_happy_cream/controllers/syrup_controller.dart';
import 'package:menu_happy_cream/controllers/theme_controller.dart';
import 'package:menu_happy_cream/controllers/topping_controller.dart';
import 'package:menu_happy_cream/models/cart.dart';
import 'package:badges/badges.dart' as badges;

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final CategoryController controllerC = Get.find<CategoryController>();
    final ProductController controllerP = Get.find<ProductController>();
    final ToppingController toppingController = Get.find<ToppingController>();
    final SyrupController syrupController = Get.find<SyrupController>();
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      body: Obx(() {
        if (controllerC.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final isDarkMode = themeController.themeMode.value == ThemeMode.dark;

        // Filtra las categorías para mostrar solo las que están activas
        final activeCategories = controllerC.categoryList
            .where((category) => category.state && category.tProduct > 0)
            .toList();

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              pinned: true,
              floating: true,
              expandedHeight: 250.0,
              toolbarHeight: 56.0,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final percent = ((constraints.maxHeight - kToolbarHeight) /
                          (250.0 - kToolbarHeight))
                      .clamp(0.0, 1.0);

                  return FlexibleSpaceBar(
                    centerTitle: true,
                    title: const Text(
                      'Menu Happy Cream',
                      style: TextStyle(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(-1.5, -1.5),
                            color: Colors.black,
                          ),
                          Shadow(
                            offset: Offset(1.5, -1.5),
                            color: Colors.black,
                          ),
                          Shadow(
                            offset: Offset(1.5, 1.5),
                            color: Colors.black,
                          ),
                          Shadow(
                            offset: Offset(-1.5, 1.5),
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    background: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            'assets/Producto.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Transform.translate(
                            offset: Offset(0, 30),
                            child: Transform.scale(
                              scale: 1.0 + percent * 0.5,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 15,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 30 + 20 * percent,
                                  backgroundImage:
                                      const AssetImage('assets/icon.png'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              actions: [
                Obx(() => IconButton(
                      onPressed: () {
                        themeController.toggleTheme();
                      },
                      icon: Icon(
                        themeController.themeMode.value == ThemeMode.dark
                            ? Icons.nightlight_round
                            : Icons.wb_sunny,
                        color: Colors.white,
                      ),
                    )),
              ],
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            // SliverToBoxAdapter(
            //   child: Container(
            //     color: Colors.blueAccent,
            //     height: 100.0,
            //     child: const Center(
            //       child: Text(
            //         'Encima de la lista',
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 20.0,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var category = activeCategories[index];
                  controllerP.categoryId.value = category.id;

                  return Obx(() {
                    // Filtra los productos para mostrar solo las que están activos
                    var products = controllerP.productList
                        .where(
                          (product) =>
                              product.categoryId == category.id &&
                              product.state,
                        )
                        .toList();

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0), // Agrega espacio a los lados
                      child: Card(
                        child: ExpansionTile(
                          title: Text(
                            category.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                          subtitle: Text(category.description,
                              style: const TextStyle(fontSize: 16)),
                          children: products.map((product) {
                            return Card(
                              color: isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                              child: ListTile(
                                leading: Container(
                                  width:
                                      60, // Ajusta el tamaño según sea necesario
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(
                                            0.5), // Color de la sombra
                                        spreadRadius:
                                            3, // Radio de expansión de la sombra
                                        blurRadius:
                                            5, // Radio de desenfoque de la sombra
                                        offset: const Offset(0,
                                            3), // Desplazamiento de la sombra (x, y)
                                      ),
                                    ],
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Mostrar el diálogo con la imagen al hacer clic
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            child: Container(
                                              width:
                                                  300, // Ajusta el tamaño según sea necesario
                                              height:
                                                  300, // Ajusta el tamaño según sea necesario
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(
                                                    20), // Redondea los bordes del diálogo
                                                child: Image.network(
                                                  product.image.isEmpty
                                                      ? 'assets/Producto.jpg'
                                                      : product.image,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundImage: NetworkImage(
                                        product.image.isEmpty
                                            ? 'assets/icon.png'
                                            : product.image,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  product.name.capitalizeFirst!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  '\$ ${product.price}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                trailing: Icon(
                                  Icons.add_circle_outline,
                                  size: 40,
                                ),
                                onTap: () {
                                  // Muestra el diálogo al hacer tap en un producto
                                  _showProductDialog(
                                    context,
                                    product,
                                    toppingController,
                                    syrupController,
                                    cartController,
                                    category.id,
                                    category.name,
                                    isDarkMode,
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  });
                },
                childCount: activeCategories.length,
              ),
            ),
          ],
        );
      }),
      floatingActionButton: Obx(() {
        final CartController cartController = Get.find<CartController>();
        return badges.Badge(
          badgeContent: Text(
            cartController.totalItems
                .toString(), // Usa totalItems para mostrar el total de productos
            style: const TextStyle(color: Colors.white),
          ),
          position: badges.BadgePosition.topEnd(top: -10, end: -10),
          child: FloatingActionButton(
            onPressed: () {
              Get.to(() => CartPage());
            },
            child: const Icon(Icons.shopping_cart),
          ),
        );
      }),
    );
  }

  // Método para mostrar el diálogo del producto
  // Método para mostrar el diálogo del producto
  void _showProductDialog(
    BuildContext context,
    var product,
    ToppingController toppingController,
    SyrupController syrupController,
    CartController cartController,
    String categoryId,
    String categoryName,
    bool isDarkMode,
  ) {
    var activeToppings = toppingController.toppingList
        .where((topping) => topping.state)
        .toList();
    var activeSyrups =
        syrupController.syrupList.where((syrup) => syrup.state).toList();

    List<bool> toppingSelections =
        List<bool>.filled(activeToppings.length, false);
    List<bool> syrupSelections = List<bool>.filled(activeSyrups.length, false);
    double basePrice = product.price;
    double toppingPrice = 0.0;
    double syrupPrice = 0.0;
    double totalPrice = basePrice;
    int quantity = 1; // Cantidad inicial

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Row(
                // Center the Row contents
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () =>
                        Navigator.pop(context), // Close the AlertDialog
                  ),
                  Text(
                    product.name.toString().capitalize!,
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  if (product.topping) ...[
                    Card(
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        title: Text('Toppings Disponibles:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        children: [
                          ...activeToppings.asMap().entries.map((entry) {
                            int index = entry.key;
                            var topping = entry.value;

                            return Card(
                              color: isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                              child: CheckboxListTile(
                                title: Text(topping.name),
                                subtitle: topping.price == 0.0
                                    ? Text('')
                                    : Text(
                                        '\$${topping.price.toStringAsFixed(2)}'),
                                value: toppingSelections[index],
                                onChanged: (bool? value) {
                                  if (value == true &&
                                      toppingSelections
                                              .where((t) => t)
                                              .length >=
                                          product.cTopping) {
                                    _showWarningSnackbar('MENSAJE DE TOPPINGS',
                                        'No puedes seleccionar más de ${product.cTopping} toppings.');
                                    return;
                                  }
                                  setState(() {
                                    toppingSelections[index] = value!;
                                    toppingPrice = activeToppings
                                        .asMap()
                                        .entries
                                        .where((entry) =>
                                            toppingSelections[entry.key])
                                        .map((entry) => entry.value.price)
                                        .fold<double>(0.0,
                                            (prev, amount) => prev + amount);
                                    totalPrice =
                                        (basePrice + toppingPrice) * quantity;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    )
                  ],
                  if (product.syrup) ...[
                    Card(
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        title: const Text(
                          'Salsas Disponibles:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        children: [
                          ...activeSyrups.asMap().entries.map((entry) {
                            int index = entry.key;
                            var syrup = entry.value;

                            return Card(
                              color: isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                              child: CheckboxListTile(
                                title: Text(syrup.name),
                                subtitle: syrup.price == 0.0
                                    ? Text('')
                                    : Text(
                                        '\$${syrup.price.toStringAsFixed(2)}'),
                                value: syrupSelections[index],
                                onChanged: (bool? value) {
                                  if (value == true &&
                                      syrupSelections.where((s) => s).length >=
                                          product.cSyrup) {
                                    _showWarningSnackbar('MENSAJE DE SALSAS',
                                        'No puedes seleccionar más de ${product.cSyrup} salsas.');
                                    return;
                                  }
                                  setState(() {
                                    syrupSelections[index] = value!;
                                    syrupPrice = activeSyrups
                                        .asMap()
                                        .entries
                                        .where((entry) =>
                                            syrupSelections[entry.key])
                                        .map((entry) => entry.value.price)
                                        .fold<double>(0.0,
                                            (prev, amount) => prev + amount);
                                    totalPrice = (basePrice +
                                            toppingPrice +
                                            syrupPrice) *
                                        quantity;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    )
                  ],
                  Text('Precio Unitario: \$${basePrice.toStringAsFixed(2)}'),
                  if (toppingPrice > 0)
                    Text(
                        'Costo Toppings: \$${toppingPrice.toStringAsFixed(2)}'),
                  if (syrupPrice > 0)
                    Text('Costo Salsas: \$${syrupPrice.toStringAsFixed(2)}'),
                  Text(
                      'Precio Final: \$${(basePrice + toppingPrice).toStringAsFixed(2)}'),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          quantity = (quantity > 1) ? quantity - 1 : 1;
                          totalPrice = (basePrice + toppingPrice + syrupPrice) *
                              quantity;
                        });
                      },
                      icon: Icon(Icons.remove),
                    ),
                    Text(quantity.toString()),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          quantity++;
                          totalPrice = (basePrice + toppingPrice + syrupPrice) *
                              quantity;
                        });
                      },
                      icon: Icon(Icons.add),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        var selectedToppings = activeToppings
                            .asMap()
                            .entries
                            .where((entry) => toppingSelections[entry.key])
                            .map((entry) => entry.value)
                            .toList();
                        var selectedSyrups = activeSyrups
                            .asMap()
                            .entries
                            .where((entry) => syrupSelections[entry.key])
                            .map((entry) => entry.value)
                            .toList();

                        // Agrega la cantidad de productos seleccionada
                        cartController.addItem(
                          categoryId,
                          categoryName,
                          CartItem(
                            productId: product.id,
                            productName: product.name,
                            productTopping: product.topping,
                            productSyrup: product.syrup,
                            productPrice: basePrice,
                            selectedToppings: selectedToppings,
                            selectedSyrups: selectedSyrups,
                            quantity: quantity,
                          ),
                        );

                        Navigator.of(context).pop();
                      },
                      child: Text('Agregar \$ ${totalPrice}'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showWarningSnackbar(title, String message) {
    Get.snackbar(
      title,
      message,
      duration: Duration(seconds: 2),
      backgroundColor: const Color.fromARGB(255, 155, 101, 221),
      colorText: Colors.white,
      icon: const Icon(
        Icons.info,
        color: Colors.white,
        size: 30,
      ),
      dismissDirection: DismissDirection.horizontal,
      messageText: Text(
        message,
        style: TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }
}
