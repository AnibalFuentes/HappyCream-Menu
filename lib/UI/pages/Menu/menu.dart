import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_happy_cream/UI/pages/cart/cart_page.dart';
import 'package:menu_happy_cream/controllers/cart_controller.dart';
import 'package:menu_happy_cream/controllers/category_controller.dart';
import 'package:menu_happy_cream/controllers/product_controller.dart';
import 'package:menu_happy_cream/controllers/theme_controller.dart';
import 'package:menu_happy_cream/controllers/topping_controller.dart';
import 'package:menu_happy_cream/models/cart.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final CategoryController controllerC = Get.find<CategoryController>();
    final ProductController controllerP = Get.find<ProductController>();
    final ToppingController toppingController = Get.find<ToppingController>();

    return Scaffold(
      body: Obx(() {
        if (controllerC.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

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
                          child: Image.asset(
                            'assets/vaca.jpg',
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
                      ),
                    )),
              ],
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.blueAccent,
                height: 100.0,
                child: const Center(
                  child: Text(
                    'Encima de la lista',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
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

                    return Card(
                      child: ExpansionTile(
                        title: Text(
                          category.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(category.description),
                        children: products.isEmpty
                            ? [
                                const ListTile(
                                    title: Text('No hay productos disponibles'))
                              ]
                            : products.map((product) {
                                return Card(
                                  color: Colors.grey[400],
                                  child: ListTile(
                                    title: Text(
                                      product.name.capitalizeFirst!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    onTap: () {
                                      // Muestra el diálogo al hacer tap en un producto
                                      _showProductDialog(
                                          context, product, toppingController,category.id,category.name);
                                    },
                                  ),
                                );
                              }).toList(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => CartPage());
        },
        child: Icon(Icons.shopping_cart),
      ),
    );
  }

  // Método para mostrar el diálogo del producto
  // Método para mostrar el diálogo del producto
void _showProductDialog(
    BuildContext context, var product, ToppingController toppingController, String categoryId, String categoryName) {
  final CartController cartController = Get.find<CartController>();

  var activeToppings = toppingController.toppingList
      .where((topping) => topping.state)
      .toList();

  List<bool> toppingSelections = List<bool>.filled(activeToppings.length, false);
  double totalPrice = product.price;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(product.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Precio: \$${totalPrice.toStringAsFixed(2)}'),
                const SizedBox(height: 10),
                const Text('Toppings Disponibles:'),
                const SizedBox(height: 10),
                ...activeToppings.asMap().entries.map((entry) {
                  int index = entry.key;
                  var topping = entry.value;
                  return CheckboxListTile(
                    title: Text(topping.name),
                    subtitle: Text('\$${topping.price.toStringAsFixed(2)}'),
                    value: toppingSelections[index],
                    onChanged: (bool? value) {
                      if (value == true &&
                          toppingSelections.where((t) => t).length >= 2) {
                        return;
                      }
                      setState(() {
                        toppingSelections[index] = value!;
                        totalPrice = product.price +
                            activeToppings
                                .asMap()
                                .entries
                                .where((entry) => toppingSelections[entry.key])
                                .map((entry) => entry.value.price)
                                .fold<double>(
                                    0.0, (prev, amount) => prev + amount);
                      });
                    },
                  );
                }).toList(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
              ElevatedButton(
                onPressed: () {
                  var selectedToppings = activeToppings
                      .asMap()
                      .entries
                      .where((entry) => toppingSelections[entry.key])
                      .map((entry) => entry.value)
                      .toList();
                  cartController.addItem(
                    categoryId,
                    categoryName,
                    CartItem(
                      productId: product.id,
                      productName: product.name,
                      productPrice: product.price,
                      selectedToppings: selectedToppings,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Agregar al Carrito'),
              ),
            ],
          );
        },
      );
    },
  );
}

}
