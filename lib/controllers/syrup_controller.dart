import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_happy_cream/models/syrup.dart';

class SyrupController extends GetxController {
  final Rx<TextEditingController> name = TextEditingController().obs;
  final Rx<TextEditingController> price = TextEditingController().obs;
  static SyrupController syrupController = Get.find();
  final RxList<Syrup> syrupList = <Syrup>[].obs;
  final db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;

  var tTopings = 0.obs;
  String imgURL = '';

  @override
  void onInit() {
    super.onInit();
    getSyrups();
  }

  void getSyrups() async {
    isLoading.value = true;
    try {
      var syrups = await db.collection('syrups').get();
      syrupList.clear();
      for (var syrup in syrups.docs) {
        syrupList.add(Syrup.fromMap(syrup.data(), syrup.id));
      }
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
