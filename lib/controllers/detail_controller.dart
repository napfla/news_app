import 'package:get/get.dart';

import '../models/article_model.dart';

class DetailController extends GetxController {
  final ArticleModel article = Get.arguments as ArticleModel;
}