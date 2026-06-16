
import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable{
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
  final String id;
  final Map<String, dynamic> data;
  const UpdateMenu(this.id, this.data);
  @override 
  List<Object> get props =>[id, data];
}

class UpdateMenuStatus extends MenuEvent {
  final String id;
  final bool newStatus;
  UpdateMenuStatus(this.id, this.newStatus);
}

class DeleteMenu extends MenuEvent{
  final String id;
  const DeleteMenu(this.id);
  @override
  List<Object> get props=>[id];
}

