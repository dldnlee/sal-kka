import 'package:flutter/foundation.dart';
import '../models/income_settings.dart';
import '../models/shopping_item.dart';
import 'storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<ShoppingItem> items = [];
  IncomeSettings income = IncomeSettings.defaultSettings;
  bool loaded = false;
  int currentTab = 0;

  void goToTab(int index) {
    currentTab = index;
    notifyListeners();
  }

  Future<void> load() async {
    items = await _storage.getItems();
    income = await _storage.getIncomeSettings();
    loaded = true;
    notifyListeners();
  }

  Future<void> setIncome(IncomeSettings newIncome) async {
    income = newIncome;
    await _storage.saveIncomeSettings(newIncome);
    notifyListeners();
  }

  Future<void> addItem(ShoppingItem item) async {
    items.add(item);
    await _storage.addItem(item);
    notifyListeners();
  }

  Future<void> resolveItem(String id, ItemStatus status) async {
    final idx = items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    items[idx].status = status;
    items[idx].decisionAt = DateTime.now();
    await _storage.updateItem(items[idx]);
    notifyListeners();
  }

  List<ShoppingItem> get coolingItems =>
      items.where((e) => e.status == ItemStatus.cooling).toList()
        ..sort((a, b) => a.cooldownEndsAt.compareTo(b.cooldownEndsAt));

  List<ShoppingItem> get resolvedItems =>
      items.where((e) => e.status != ItemStatus.cooling).toList()
        ..sort((a, b) =>
            (b.decisionAt ?? b.createdAt).compareTo(a.decisionAt ?? a.createdAt));

  double get totalSaved => items
      .where((e) => e.status == ItemStatus.saved)
      .fold(0.0, (sum, e) => sum + e.price);

  int get savedCount =>
      items.where((e) => e.status == ItemStatus.saved).length;
}
