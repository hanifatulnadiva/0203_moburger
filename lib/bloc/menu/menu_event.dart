part of 'menu_bloc.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

class FetchMenu extends MenuEvent{}
class CreateMenu extends MenuEvent{
  final Map<String, dynamic> data;
  const CreateMenu(this.data);
  @override
  List <Object> get props =>[data];
}
class UpdateMenu extends MenuEvent{
  final int id;
  final Map<String, dynamic> data;
  const UpdateMenu(this.id, this.data);
  @override 
  List<Object> get props =>[id, data];
}

class DeleteMenu extends MenuEvent{
  final int id;
  const DeleteMenu(this.id);
  @override
  List<Object> get props=>[id];
}

