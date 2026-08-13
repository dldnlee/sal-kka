import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/income_settings.dart';
import '../models/shopping_item.dart';

class StorageService {
  static const _itemsKey = 'salkka_items';
  static const _incomeKey = 'salkka_income';

  Future<List<ShoppingItem>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_itemsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveItems(List<ShoppingItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_itemsKey, raw);
  }

  Future<void> addItem(ShoppingItem item) async {
    final items = await getItems();
    items.add(item);
    await saveItems(items);
  }

  Future<void> updateItem(ShoppingItem updated) async {
    final items = await getItems();
    final idx = items.indexWhere((e) => e.id == updated.id);
    if (idx == -1) return;
    items[idx] = updated;
    await saveItems(items);
  }

  Future<IncomeSettings> getIncomeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_incomeKey);
    if (raw == null) return IncomeSettings.defaultSettings;
    return IncomeSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveIncomeSettings(IncomeSettings income) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_incomeKey, jsonEncode(income.toJson()));
  }
}
