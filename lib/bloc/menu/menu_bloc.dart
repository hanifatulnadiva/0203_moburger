import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moburger/bloc/menu/menu_event.dart';
import 'package:moburger/bloc/menu/menu_state.dart';
import 'package:moburger/core/contants/app_contants.dart';
import 'package:moburger/data/models/menu_model.dart';
import 'package:moburger/data/repositories/menu_repository.dart';


class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository repository;
  MenuBloc({required this.repository}) : super(MenuInitial()) {
    on<FetchMenu>((event, emit) async {
    try {
      final currentState = state;

      if (currentState is MenuSuccess && currentState.hasReachedMax) return;

      final page = currentState is MenuSuccess
          ? currentState.page
          : AppConstants.initialPage;

      final result = await repository.getAllMenu(page: page);

      if (currentState is MenuSuccess) {
        final isLast = result.length < AppConstants.defaultPageSize;

        emit(currentState.copyWith(
          menu: [...currentState.menu, ...result],
          page: page + 1,
          hasReachedMax: isLast,
          isLoadingMore: false,
        ));
      } else {
        emit(MenuSuccess(
          menu: result,
          page: 2,
          hasReachedMax: result.length < AppConstants.defaultPageSize,
        ));
      }
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  });
    on<CreateMenu>((event,emit)async{
      emit (MenuLoading());
      try{
        await repository.createMenu(event.data);
        emit(MenuCreateSuccess());
        add(FetchMenu());
      }catch(e){
        emit(MenuError(e.toString()));
      }
    });
    on<UpdateMenu>((event, emit)async{
      emit(MenuLoading());
      try{
        await repository.updateMenu(event.id, event.data);
        emit(MenuCreateSuccess());
        add(FetchMenu());
      }catch(e){
        emit(MenuError(e.toString()));
      }
    });
    // Di menu_bloc.dart
    on<UpdateMenuStatus>((event, emit) {
      final currentState = state;
      if (currentState is MenuSuccess) {
        // Mencari menu yang diupdate berdasarkan ID dan mengubah statusnya
        final updatedList = currentState.menu.map((menu) {
          if (menu.id == event.id) {
            return menu.copyWith(tersedia: event.newStatus);
          }
          return menu;
        }).toList();
        
        // Emit state sukses dengan list yang sudah diperbarui
        emit(currentState.copyWith(menu: updatedList));
      }
    });
    on<DeleteMenu>((event, emit)async{
      emit(MenuLoading());
      try{
        await repository.deleteMenu(event.id);
        emit(MenuCreateSuccess());
        add(FetchMenu());
      }catch(e){
        emit(MenuError(e.toString()));
      }
    });
  }
}
