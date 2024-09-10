import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menu_happy_cream/controllers/cart_controller.dart';
import 'package:menu_happy_cream/controllers/theme_controller.dart';
import 'package:menu_happy_cream/models/product.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CartPage extends StatelessWidget {
  final CartController cartController = Get.find<CartController>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
      ),
      body: Obx(() {
        if (cartController.cartList.isEmpty) {
          return const Center(child: Text('El carrito está vacío.'));
        }
        final isDarkMode = themeController.themeMode.value == ThemeMode.dark;

        return ListView.builder(
          itemCount: cartController.cartList.length,
          itemBuilder: (context, categoryIndex) {
            final category = cartController.cartList[categoryIndex];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                initiallyExpanded: true,
                title: Text(
                  category.categoryName,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                children: category.items.map((item) {
                  final toppingPrice = item.selectedToppings.fold<double>(
                    0.0,
                    (sum, topping) => sum + topping.price,
                  );

                  final subtotal = item.productPrice + toppingPrice;
                  return Card(
                    color: isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    child: Dismissible(
                      key: ValueKey(item.productId),
                      direction: DismissDirection
                          .endToStart, // Permitir deslizamiento en ambas direcciones
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        final bool shouldDelete = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Eliminar Item'),
                              content: Text(
                                '¿Estás seguro de que deseas eliminar el item ?',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            );
                          },
                        );
                        if (shouldDelete) {
                          cartController.removeItemFromCategory(
                              category.categoryId, item);
                        }
                        return shouldDelete;
                      },
                      child: ListTile(
                          title: Text(
                            item.productName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text(
                              '${item.productTopping ? 'Toppings: ${item.selectedToppings.map((t) => t.name).join(", ")}' : ''}\n'
                              '${item.productSyrup ? 'Salsas: ${item.selectedSyrups.map((s) => s.name).join(", ")}' : ''}'
                              '\nPrecio: \$${subtotal.toStringAsFixed(2)}\n'
                              'Total: ${subtotal.toStringAsFixed(2)} x ${item.quantity} = \$${item.totalPrice.toStringAsFixed(2)}\n',
                              style: const TextStyle(fontSize: 16)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  cartController.decrementItemQuantity(
                                      category.categoryId, item);
                                },
                              ),
                              Text(
                                item.quantity.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  cartController.incrementItemQuantity(
                                      category.categoryId, item);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  cartController.removeItemFromCategory(
                                      category.categoryId, item);
                                },
                              ),
                            ],
                          )),
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
              if (cartController.cartList.isNotEmpty)
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
                  if (cartController.cartList.isNotEmpty)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            cartController.clearCart();
                            Get.back(); // Regresar a la página anterior
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.red.shade200, // Color rojo mejorado
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Bordes redondeados
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                    ),
                  if (cartController.cartList.isNotEmpty)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _showInfoDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .lightGreen.shade200, // Color verde mejorado
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Bordes redondeados
                            ),
                          ),
                          child: const Text('Enviar'),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Información de Entrega'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Selecciona el tipo de entrega:'),
                trailing: DropdownButton<String>(
                  items:
                      <String>['Domicilio', 'Punto Físico'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    Navigator.pop(context, newValue);
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        if (value == 'Domicilio') {
          _showDomicilioForm(context);
        } else {
          _showPuntoFisicoForm(context);
        }
      }
    });
  }

  void _showDomicilioForm(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    String paymentMethod = 'Transferencia';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Información de Domicilio'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: phoneController,
                  decoration:
                      const InputDecoration(labelText: 'Número de Teléfono'),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (value.length < 10) {
                      return ' Debe Tener 10 digitos';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Dirección'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  onChanged: (String? newValue) {
                    paymentMethod = newValue!;
                  },
                  items:
                      <String>['Transferencia', 'Efectivo'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  // Envía el mensaje sin vista previa
                  await _sendCartToWhatsApp(
                    cartController,
                    nameController.text,
                    phoneController.text,
                    addressController.text,
                    paymentMethod,
                  );
                  Get.back(); // Regresar a la página anterior
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  void _showPuntoFisicoForm(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Información de Punto Físico'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: phoneController,
                  decoration:
                      const InputDecoration(labelText: 'Número de Teléfono'),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (value.length < 10) {
                      return ' Debe Tener 10 digitos';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  Get.back();

                  await _sendCartToWhatsApp(
                    cartController,
                    nameController.text,
                    phoneController.text,
                    '',
                    '',
                  );
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }
}

_sendCartToWhatsApp(
  CartController cartController,
  String name,
  String phone,
  String address,
  String paymentMethod,
) async {
  String whatsappNumber =
      "573007716244"; // Número de teléfono en formato internacional sin signos
  String message =
      _buildCartMessage(cartController, name, phone, address, paymentMethod);

  String whatsappUrl =
      "https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}";

  try {
    final Uri url = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url).whenComplete(() {
        cartController.clearCart();
      });
    } else {
      Get.snackbar(
        'Error',
        'No se pudo abrir WhatsApp',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } catch (e) {
    Get.snackbar(
      'Error',
      'Ocurrió un problema al intentar abrir WhatsApp: ${e.toString()}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

String _buildCartMessage(
  CartController cartController,
  String name,
  String phone,
  String address,
  String paymentMethod,
) {
  final StringBuffer message = StringBuffer();
  message.writeln("Hola, me gustaría realizar el siguiente pedido:");

  int totalProducts = 0; // Contador de productos

  cartController.cartList.forEach((category) {
    message.writeln("\n*${category.categoryName}:*");
    category.items.forEach((item) {
      totalProducts += item.quantity; // Incrementa el contador de productos

      message.writeln(
          "- ${item.productName}: \$${item.totalPriceU.toStringAsFixed(2)} x ${item.quantity} = \$${item.totalPrice.toStringAsFixed(2)}");

      if (item.productTopping && item.selectedToppings.isNotEmpty) {
        message.writeln(
            "  Toppings: ${item.selectedToppings.map((t) => t.name).join(", ")}");
      }

      if (item.productSyrup && item.selectedSyrups.isNotEmpty) {
        message.writeln(
            "  Salsas: ${item.selectedSyrups.map((s) => s.name).join(", ")}");
      }
    });
  });

  message.writeln("\n*Total Productos: $totalProducts*");
  message.writeln("*Total: \$${cartController.totalPrice.toStringAsFixed(2)}*");

  // Agrega la información adicional según el tipo de entrega
  if (address.isNotEmpty) {
    message.writeln("\n*Información de Domicilio:*");
    message.writeln("Nombre: $name");
    message.writeln("Número de Teléfono: $phone");
    message.writeln("Dirección: $address");
    message.writeln("Tipo de Pago: $paymentMethod");
  } else {
    message.writeln("\n*Información de Punto Físico:*");
    message.writeln("Nombre: $name");
    message.writeln("Número de Teléfono: $phone");
  }

  return message.toString();
}
