import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moburger/bloc/menu/menu_event.dart';
import 'package:moburger/bloc/menu/menu_state.dart';
import 'package:moburger/core/contants/app_contants.dart';
import 'package:moburger/data/repositories/menu_repository.dart';


class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository repository;

  MenuBloc({required this.repository}) : super(MenuInitial()) {

    on<FetchMenu>((event, emit) async {
      try {
        final result = await repository.getAllMenu(page: 1);

        emit(MenuSuccess(
          menu: result,
          page: 2,
          hasReachedMax: result.length < AppConstants.defaultPageSize,
        ));
      } catch (e) {
        emit(MenuError(e.toString()));
      }
    });
    on<SearchMenuRequested>((event, emit) {
    if (state is MenuSuccess) {
      final originalList = (state as MenuSuccess).menu;
      final filtered = originalList.where((m) => 
        m.nama_menu!.toLowerCase().contains(event.query.toLowerCase())
      ).toList();
      emit(MenuSuccess(menu: filtered));
    }
  });

    on<LoadMoreMenu>((event, emit) async {
      final currentState = state;
      if (currentState is! MenuSuccess) return;
      if (currentState.hasReachedMax) return;

      try {
        final result = await repository.getAllMenu(page: currentState.page);

        final isLast = result.length < AppConstants.defaultPageSize;

        emit(currentState.copyWith(
          menu: [...currentState.menu, ...result],
          page: currentState.page + 1,
          hasReachedMax: isLast,
        ));
      } catch (e) {
        emit(MenuError(e.toString()));
      }
    });

    on<CreateMenu>((event, emit) async {
      emit(MenuLoading());
      try {
        await repository.createMenu(event.data);
        emit(MenuCreateSuccess());
        add(FetchMenu());
      } catch (e) {
        emit(MenuError(e.toString()));
      }
    });

    on<UpdateMenu>((event, emit) async {
      emit(MenuLoading());
      try {
        await repository.updateMenu(event.id, event.data);
        emit(MenuCreateSuccess());
        add(FetchMenu());
      } catch (e) {
        emit(MenuError(e.toString()));
      }
    });

    on<UpdateMenuStatus>((event, emit) {
      final currentState = state;
      if (currentState is MenuSuccess) {
        final updated = currentState.menu.map((menu) {
          if (menu.id == event.id) {
            return menu.copyWith(tersedia: event.newStatus);
          }
          return menu;
        }).toList();

        emit(currentState.copyWith(menu: updated));
      }
    });

    on<DeleteMenu>((event, emit) async {
      emit(MenuLoading());
      try {
        await repository.deleteMenu(event.id);
        emit(MenuCreateSuccess());
        add(FetchMenu());
      } catch (e) {
        emit(MenuError(e.toString()));
      }
    });
  }
}