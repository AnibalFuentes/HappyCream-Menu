// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:menu_happy_cream/UI/pages/add_category.dart';
// import 'package:menu_happy_cream/UI/pages/product_page.dart';
// import 'package:menu_happy_cream/controllers/category_controller.dart';

// class CategoryPage extends StatelessWidget {
//   const CategoryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final CategoryController controller = Get.find<CategoryController>();

//     return Scaffold(
//       body: Obx(
//       () {
//         if (controller.isLoading.value) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         return Column(
//           children: <Widget>[
//             Expanded(
//               child: ListView(
//                 children: controller.categoryList.map((category) {
//                   return Card(
//                     // color: category.state == true
//                     //     ? Colors.white
//                     //     : Colors.grey.shade300,
//                     child: Dismissible(
//                         key: ValueKey(
//                             category.id), // Clave única para cada categoría
//                         direction: DismissDirection
//                             .horizontal, // Permitir deslizamiento en ambas direcciones
//                         background: Container(
//                           color: Colors.blue,
//                           alignment: Alignment.centerLeft,
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: const Icon(Icons.edit, color: Colors.white),
//                         ),
//                         secondaryBackground: Container(
//                           color: Colors.red,
//                           alignment: Alignment.centerRight,
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: const Icon(Icons.delete_forever,
//                               color: Colors.white),
//                         ),
//                         confirmDismiss: (direction) async {
//                           if (direction == DismissDirection.startToEnd) {
//                             // Acción para editar
//                             final bool? shouldDismiss =
//                                 await showCategoryDialog(
//                               context: context,
//                               isEditing: true,
//                               category: category,
//                             );
//                             return shouldDismiss ?? false;
//                           } else if (direction == DismissDirection.endToStart) {
//                             // Acción para eliminar
//                             final bool shouldDelete = await showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return AlertDialog(
//                                   title: const Text('Eliminar categoría'),
//                                   content: Text(
//                                     '¿Estás seguro de que deseas eliminar la categoría ${category.name}?',
//                                   ),
//                                   actions: <Widget>[
//                                     TextButton(
//                                       onPressed: () {
//                                         Navigator.of(context).pop(false);
//                                       },
//                                       child: const Text('Cancelar'),
//                                     ),
//                                     TextButton(
//                                       onPressed: () {
//                                         Navigator.of(context).pop(true);
//                                       },
//                                       child: const Text('Eliminar'),
//                                     ),
//                                   ],
//                                 );
//                               },
//                             );
//                             if (shouldDelete) {
//                               controller.deleteCategory(
//                                   category.id, category.name);
//                             }
//                             return shouldDelete;
//                           }
//                           return false;
//                         },
//                         child: ListTile(
//                           title: Text(
//                             category.name.capitalizeFirst!,
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment
//                                 .start, // Alinea el contenido a la izquierda
//                             children: [
//                               Text(
//                                 category.state ? 'Visible' : 'Oculto',
//                                 style: TextStyle(
//                                   color: category.state
//                                       ? Colors.green
//                                       : Colors.red,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               Text(
//                                 category.tProduct.toString(),
//                                 style: TextStyle(fontWeight: FontWeight.normal),
//                               ),
//                             ],
//                           ),
//                           trailing: Switch(
//                             activeColor: Colors.grey,
//                             activeTrackColor: Colors.lightGreen,
//                             value: category.state,
//                             onChanged: (newState) {
//                               controller.updateCategoryState(
//                                   category.id, newState);
//                             },
//                           ),
//                           onTap: () {
//                             Get.to(() => ProductPage(
//                                   categoryId: category.id,
//                                   categoryName: category.name,
//                                 ));
//                           },
//                         )),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],
//         );
//       },
//     ));
//   }
// }
