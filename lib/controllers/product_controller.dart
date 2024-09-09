import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:menu_happy_cream/controllers/category_controller.dart';
import 'package:menu_happy_cream/models/product.dart';

class ProductController extends GetxController {
  final RxList<Product> productList = <Product>[].obs;

  final CategoryController categoryController = Get.find<CategoryController>();
  final db = FirebaseFirestore.instance;
  final RxString categoryId = ''.obs;
  final RxBool isLoading = false.obs;

  var tProducts = 0.obs;
  String imgURL = '';

  @override
  void onInit() {
    super.onInit();
    ever(categoryId, (_) => getProducts());
  }

  void getProducts() async {
    isLoading.value = true;
    try {
      var products = await db.collection('products').get();
      productList.clear();
      for (var product in products.docs) {
        productList.add(Product.fromMap(product.data(), product.id));
      }
      tProducts.value = productList.length;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Hubo un problema al obtener los productos: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
