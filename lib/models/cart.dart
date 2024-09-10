import 'package:menu_happy_cream/models/syrup.dart';
import 'package:menu_happy_cream/models/topping.dart';

class CartItem {
  final String productId;
  final String productName;
  final bool productTopping;
  final bool productSyrup;
  final double productPrice;
  final List<Topping> selectedToppings;
  final List<Syrup> selectedSyrups;
  int quantity; // Añade esta línea

  CartItem({
    required this.productId,
    required this.productName,
    required this.productTopping,
    required this.productSyrup,
    required this.productPrice,
    required this.selectedToppings,
    required this.selectedSyrups,
    this.quantity = 1, // Valor por defecto
  });

  double get totalPrice {
    double toppingsPrice =
        selectedToppings.fold(0, (sum, topping) => sum + topping.price);
    return (productPrice + toppingsPrice) * quantity; // Ajuste para multiplicar por la cantidad
  }
  double get totalPriceU {
    double toppingsPrice =
        selectedToppings.fold(0, (sum, topping) => sum + topping.price);
    return (productPrice + toppingsPrice) ; // Ajuste para multiplicar por la cantidad
  }
}
class CartCategory {
  final String categoryId;
  final String categoryName;
  final List<CartItem> items;

  CartCategory({
    required this.categoryId,
    required this.categoryName,
    required this.items,
  });

  double get totalPrice {
    // Calcula el precio total de todos los productos en la categoría
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    // Suma la cantidad total de productos en esta categoría
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}


