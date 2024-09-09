import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_happy_cream/models/category.dart';

class CategoryController extends GetxController {
  final Rx<TextEditingController> name = TextEditingController().obs;
  static CategoryController categoryController = Get.find();
  final RxList<Category> categoryList = <Category>[].obs;
  final db = FirebaseFirestore.instance;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCategories();
  }

  getCategories() async {
    isLoading.value = true;
    try {
      var categories = await db.collection('categories').get();
      categoryList.clear();
      for (var category in categories.docs) {
        categoryList.add(Category.fromMap(category.data(), category.id));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Hubo un problema al obtener las categorías: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
