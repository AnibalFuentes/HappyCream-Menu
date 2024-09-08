import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_happy_cream/UI/pages/add_topping.dart';
import 'package:menu_happy_cream/controllers/topping_controller.dart';

class ToppingPage extends StatelessWidget {
  const ToppingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ToppingController controller = Get.find<ToppingController>();

    return Scaffold(
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.toppingList.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Para centrar verticalmente
                mainAxisAlignment:
                    MainAxisAlignment.center, // Alineación vertical
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Alineación horizontal
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      size: 45,
                    ),
                    onPressed: () => showToppingDialog(
                      context: context,
                      isEditing: false,
                    ),
                  ),
                  const Text(
                    'Añade un topping',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: controller.toppingList.map((topping) {
                    return Card(
                      child: ExpansionTile(
                          subtitle: Text(
                            topping.state ? 'Visible' : 'Oculto',
                            style: TextStyle(
                                color:
                                    topping.state ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                          leading: GestureDetector(
                            onTap: () {},
                            child: const CircleAvatar(
                              child: Icon(Icons.add_photo_alternate),
                            ),
                          ),
                          title: Text(
                            topping.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: [
                            ListTile(
                              title: Text('\$ ${topping.price.toString()}'),
                              trailing: Switch(
                                activeColor: Colors.grey,
                                activeTrackColor: Colors.lightGreen,
                                value: topping.state,
                                onChanged: (newState) {
                                  controller.updateToopingState(
                                      topping.id, newState);
                                },
                              ),
                            ),
                          ]),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
      
    );
  }
}
