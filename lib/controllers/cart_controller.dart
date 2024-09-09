import 'package:get/get.dart';
import 'package:menu_happy_cream/models/cart.dart';

class CartController extends GetxController {
  var cartList = <CartCategory>[].obs;
  var totalItems = 0.obs; // Usar Rx para el total de items

  @override
  void onInit() {
    super.onInit();
    // Recalcular totalItems al inicializar el controlador
    _updateTotalItems();
  }

  // Método para incrementar la cantidad de un item
  void incrementItemQuantity(String categoryId, CartItem item) {
    var category = cartList.firstWhereOrNull((c) => c.categoryId == categoryId);
    if (category != null) {
      var existingItem = category.items.firstWhereOrNull((i) =>
          i.productId == item.productId && _areToppingsAndSyrupsEqual(i, item));
      if (existingItem != null) {
        existingItem.quantity++;
        cartList.refresh(); // Asegúrate de actualizar el totalItems
        _updateTotalItems();
      }
    }
  }

  void removeItemFromCategory(String categoryId, CartItem item) {
    final categoryIndex =
        cartList.indexWhere((cat) => cat.categoryId == categoryId);
    if (categoryIndex != -1) {
      final category = cartList[categoryIndex];
      category.items.remove(item);

      // Eliminar la categoría si no tiene más items
      if (category.items.isEmpty) {
        cartList.removeAt(categoryIndex);
      }
      cartList.refresh(); // Asegúrate de actualizar el totalItems
      _updateTotalItems();

      // Actualiza el estado del carrito
    } else {
      // Maneja el caso en que no se encuentra la categoría, si es necesario
      print('Categoría con ID $categoryId no encontrada.');
    }
  }

  // Método para decrementar la cantidad de un item
  void decrementItemQuantity(String categoryId, CartItem item) {
    var category = cartList.firstWhereOrNull((c) => c.categoryId == categoryId);
    if (category != null) {
      var existingItem = category.items.firstWhereOrNull((i) =>
          i.productId == item.productId &&
          i.selectedToppings == item.selectedToppings &&
          i.selectedSyrups == item.selectedSyrups);
      if (existingItem != null) {
        if (existingItem.quantity > 1) {
          existingItem.quantity--;
          cartList.refresh();
          _updateTotalItems();
        } else {
          removeItem(categoryId, item);
        }
      }
    }
  }

  void addItem(String categoryId, String categoryName, CartItem item) {
    var category = cartList.firstWhereOrNull((c) => c.categoryId == categoryId);
    if (category != null) {
      var existingItem = category.items.firstWhereOrNull((i) =>
          i.productId == item.productId && _areToppingsAndSyrupsEqual(i, item));
      if (existingItem != null) {
        existingItem.quantity += item.quantity;
      } else {
        category.items.add(item);
      }
    } else {
      cartList.add(CartCategory(
        categoryId: categoryId,
        categoryName: categoryName,
        items: [item],
      ));
    }
    _updateTotalItems(); // Actualizar totalItems

    update(); // Actualizar la UI
  }

  void removeItem(String categoryId, CartItem item) {
    var category = cartList.firstWhereOrNull((c) => c.categoryId == categoryId);
    if (category != null) {
      var existingItem = category.items.firstWhereOrNull((i) =>
          i.productId == item.productId && _areToppingsAndSyrupsEqual(i, item));
      if (existingItem != null) {
        if (existingItem.quantity > 1) {
          existingItem.quantity--;
        } else {
          category.items.remove(existingItem);
        }
      }
      if (category.items.isEmpty) {
        cartList.remove(category);
      }
      _updateTotalItems(); // Actualizar totalItems
      update(); // Actualizar la UI
    }
  }

  void clearCart() {
    cartList.clear();
    _updateTotalItems(); // Actualizar totalItems
    update(); // Actualizar la UI
  }

  double get totalPrice {
    return cartList.fold(0, (sum, category) => sum + category.totalPrice);
  }

  void _updateTotalItems() {
    totalItems.value =
        cartList.fold(0, (sum, category) => sum + category.totalItems);
  }

  bool _areToppingsAndSyrupsEqual(CartItem a, CartItem b) {
    return listEquals(a.selectedToppings, b.selectedToppings) &&
        listEquals(a.selectedSyrups, b.selectedSyrups);
  }

  bool listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
