
import 'package:equatable/equatable.dart';
import 'package:moburger/data/models/menu_model.dart';

sealed class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object> get props => [];
}

final class MenuInitial extends MenuState {}

final class MenuLoading extends MenuState {}

final class MenuSuccess extends MenuState {
  final List<MenuModel> menu;
  final int page;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const MenuSuccess({
    required this.menu,
    this.page = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  MenuSuccess copyWith({
    List<MenuModel>? menu,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return MenuSuccess(
      menu: menu ?? this.menu,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [menu, page, hasReachedMax, isLoadingMore];
}

final class MenuError extends MenuState {
  final String message;
  const MenuError(this.message);

  @override
  List<Object> get props => [message];
}

final class MenuCreateSuccess extends MenuState {}