import 'package:get/get.dart';
import 'package:menu_happy_cream/models/cart.dart';


class CartController extends GetxController {
  var cartCategories = <CartCategory>[].obs;

  void addItem(String categoryId, String categoryName, CartItem item) {
    var category = cartCategories.firstWhereOrNull((c) => c.categoryId == categoryId);
    if (category != null) {
      // Si la categoría ya existe, añade el producto a la categoría existente
      category.items.add(item);
    } else {
      // Si la categoría no existe, crea una nueva y añade el producto
      cartCategories.add(CartCategory(
        categoryId: categoryId,
        categoryName: categoryName,
        items: [item],
      ));
    }
    // Actualiza la lista observada para reflejar los cambios
    cartCategories.refresh();
  }

  void removeItem(String categoryId, CartItem item) {
    var category = cartCategories.firstWhereOrNull((c) => c.categoryId == categoryId);
    if (category != null) {
      category.items.remove(item);
      // Elimina la categoría si no tiene más productos
      if (category.items.isEmpty) {
        cartCategories.remove(category);
      } else {
        // Actualiza la lista observada para reflejar los cambios
        cartCategories.refresh();
      }
    }
  }

  double get totalPrice {
    return cartCategories.fold(0, (sum, category) => sum + category.totalPrice);
  }

  void clearCart() {
    cartCategories.clear();
  }
}
