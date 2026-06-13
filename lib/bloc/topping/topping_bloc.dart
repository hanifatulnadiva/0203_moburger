
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/topping/topping_event.dart';
import 'package:moburger/bloc/topping/topping_state.dart';
import 'package:moburger/data/models/topping_model.dart';
import 'package:moburger/data/repositories/topping_repository.dart';


class ToppingBloc extends Bloc<ToppingEvent, ToppingState> {
  final ToppingRepository repository;
  ToppingBloc({required this.repository}) : super(ToppingInitial()) {
    on<FetchTopping>((event, emit) async {
      emit(ToppingLoading());
      try{
        final list= await repository.getAllTopping();
        emit(ToppingSuccess(list));
      }catch(e){
        emit(ToppingError(e.toString()));
      }
    });
    on<FetchToppingByKategori>((event, emit) async {
      emit(ToppingLoading());
      try {
        final list = await repository.getToppingsByKategori(event.kategoriMenu);
        emit(ToppingSuccess(list.cast<ToppingModel>())); 
      } catch (e) {
        emit(ToppingError(e.toString()));
      }
    });
    on<CreateTopping>((event,emit)async{
      emit (ToppingLoading());
      try{
        await repository.createTopping(event.data);
        emit(ToppingCreateSuccess());
        add(FetchTopping());
      }catch(e){
        emit(ToppingError(e.toString()));
      }
    });
    on<UpdateTopping>((event, emit)async{
      emit(ToppingLoading());
      try{
        await repository.updateTopping(event.id, event.data);
        emit(ToppingCreateSuccess());
        add(FetchTopping());
      }catch(e){
        emit(ToppingError(e.toString()));
      }
    });
    on<DeleteTopping>((event, emit)async{
      emit(ToppingLoading());
      try{
        await repository.deleteTopping(event.id);
        emit(ToppingCreateSuccess());
        add(FetchTopping());
      }catch(e){
        emit(ToppingError(e.toString()));
      }
    });
  }
}
