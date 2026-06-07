
import 'package:equatable/equatable.dart';
import 'package:moburger/data/models/topping_model.dart';

abstract class ToppingState extends Equatable {
  const ToppingState();
  
  @override
  List<Object> get props => [];
}

final class ToppingInitial extends ToppingState {}
final class ToppingLoading extends ToppingState{}
final class ToppingSuccess extends ToppingState{
  final List<ToppingModel> topping;
  const ToppingSuccess(this.topping);
  @override
  List<Object> get props=>[topping];
}
final class ToppingError extends ToppingState{
  final String message;
  const ToppingError(this.message);
  @override
  List<Object> get props => [message];
}

final class ToppingCreateSuccess extends ToppingState{}
