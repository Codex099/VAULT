import 'package:flutter/foundation.dart';
import '../models/progress_model.dart';
import '../services/hive_service.dart';

class FavoritesProvider extends ChangeNotifier {
  List<FavoriteItem> _favorites = [];

  List<FavoriteItem> get favorites => _favorites;
  int get count => _favorites.length;

  void loadFavorites() {
    _favorites = HiveService.getAllFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(FavoriteItem item) async {
    if (HiveService.isFavorite(item.imdbId)) {
      await HiveService.removeFromFavorites(item.imdbId);
    } else {
      await HiveService.addToFavorites(item);
    }
    loadFavorites();
  }

  Future<void> addFavorite(FavoriteItem item) async {
    await HiveService.addToFavorites(item);
    loadFavorites();
  }

  Future<void> removeFavorite(String imdbId) async {
    await HiveService.removeFromFavorites(imdbId);
    loadFavorites();
  }

  bool isFavorite(String imdbId) => HiveService.isFavorite(imdbId);

  List<FavoriteItem> get movies =>
      _favorites.where((f) => f.type == 'movie').toList();

  List<FavoriteItem> get series =>
      _favorites.where((f) => f.type == 'series').toList();

  void sortByDate() {
    _favorites.sort((a, b) => b.addedDate.compareTo(a.addedDate));
    notifyListeners();
  }

  void sortByRating() {
    _favorites.sort((a, b) => b.rating.compareTo(a.rating));
    notifyListeners();
  }

  void sortByTitle() {
    _favorites.sort((a, b) => a.title.compareTo(b.title));
    notifyListeners();
  }
}
