import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:menu_happy_cream/models/topping.dart';

class ToppingController extends GetxController {
  final RxList<Topping> toppingList = <Topping>[].obs;
  final db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs; // Añadido para el estado de carga

  var tTopings = 0.obs;
  String imgURL = '';

  @override
  void onInit() {
    super.onInit();
    getToppings();
  }

  void getToppings() async {
    isLoading.value = true; // Comienza la carga
    try {
      var toppings = await db.collection('toppings').get();
      toppingList.clear();
      for (var product in toppings.docs) {
        toppingList.add(Topping.fromMap(product.data(), product.id));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Hubo un problema al obtener los productos: ${e.toString()}',
      );
    } finally {
      isLoading.value = false; // Termina la carga
    }
  }
}
