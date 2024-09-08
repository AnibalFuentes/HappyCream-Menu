import 'package:menu_happy_cream/models/topping.dart';

class CartItem {
  final String productId;
  final String productName;
  final double productPrice;
  final List<Topping> selectedToppings;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.selectedToppings,
  });

  double get totalPrice {
    double toppingsPrice =
        selectedToppings.fold(0, (sum, topping) => sum + topping.price);
    return productPrice + toppingsPrice;
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
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }
}
