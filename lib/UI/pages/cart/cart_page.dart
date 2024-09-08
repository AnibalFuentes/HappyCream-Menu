import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_happy_cream/controllers/cart_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CartPage extends StatelessWidget {
  final CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
      ),
      body: Obx(() {
        if (cartController.cartCategories.isEmpty) {
          return const Center(child: Text('El carrito está vacío.'));
        }

        return ListView.builder(
          itemCount: cartController.cartCategories.length,
          itemBuilder: (context, categoryIndex) {
            final category = cartController.cartCategories[categoryIndex];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                initiallyExpanded: true,
                title: Text(
                  category.categoryName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: category.items.map((item) {
                  return ListTile(
                    title: Text(item.productName),
                    subtitle: Text(
                        'Precio: \$${item.totalPrice.toStringAsFixed(2)}\nToppings: ${item.selectedToppings.map((t) => t.name).join(", ")}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        cartController.removeItem(category.categoryId, item);
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      }),
      bottomNavigationBar: Obx(
        () => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total: \$${cartController.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _sendCartToWhatsApp(cartController),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Color verde para enviar
                    ),
                    child: const Text('Enviar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      cartController.clearCart();
                      Get.back(); // Regresar a la página anterior
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Color rojo para cancelar
                    ),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendCartToWhatsApp(CartController cartController) async {
    String whatsappNumber =
        "573207427550"; // Número de teléfono en formato internacional sin signos
    String message = _buildCartMessage(cartController);

    String whatsappUrl =
        "https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrlString(whatsappUrl)) {
      await launchUrlString(whatsappUrl);
    } else {
      Get.snackbar('Error', 'No se pudo abrir WhatsApp',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  String _buildCartMessage(CartController cartController) {
    StringBuffer message = StringBuffer();
    message.writeln("Hola, me gustaría realizar el siguiente pedido:");

    cartController.cartCategories.forEach((category) {
      message.writeln("\n*${category.categoryName}:*");
      category.items.forEach((item) {
        message.writeln(
            "- ${item.productName}: \$${item.totalPrice.toStringAsFixed(2)}");
        if (item.selectedToppings.isNotEmpty) {
          message.writeln(
              "  Toppings: ${item.selectedToppings.map((t) => t.name).join(", ")}");
        }
      });
    });

    message.writeln(
        "\n*Total: \$${cartController.totalPrice.toStringAsFixed(2)}*");
    return message.toString();
  }
}
