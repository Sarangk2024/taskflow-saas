import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DraftService {
  static const String _draftKey = 'task_draft';

  Future<void> saveDraft(Map<String, dynamic> draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftKey, json.encode(draft));
  }

  Future<Map<String, dynamic>?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftString = prefs.getString(_draftKey);
    if (draftString != null) {
      return json.decode(draftString);
    }
    return null;
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }
}
