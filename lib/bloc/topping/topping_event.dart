
import 'package:equatable/equatable.dart';

abstract class ToppingEvent extends Equatable {
  const ToppingEvent();

  @override
  List<Object> get props => [];
}
class FetchToppingByKategori extends ToppingEvent {
  final String kategoriMenu;

  FetchToppingByKategori(this.kategoriMenu);
}

class FetchTopping extends ToppingEvent{}
class CreateTopping extends ToppingEvent{
  final Map<String, dynamic> data;
  const CreateTopping(this.data);
  @override
  List <Object> get props =>[data];
}
class UpdateTopping extends ToppingEvent{
  final int id;
  final Map<String, dynamic> data;
  const UpdateTopping(this.id, this.data);
  @override 
  List<Object> get props =>[id, data];
}

class DeleteTopping extends ToppingEvent{
  final int id;
  const DeleteTopping(this.id);
  @override
  List<Object> get props=>[id];
}

