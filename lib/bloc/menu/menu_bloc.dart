import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moburger/data/models/menu_model.dart';
import 'package:moburger/data/repositories/menu_repository.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository repository;
  MenuBloc({required this.repository}) : super(MenuInitial()) {
    on<FetchMenu>((event, emit) async {
      try{
        final list= await repository.getAllMenu();
        emit(MenuSuccess(list));
      }catch(e){
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
