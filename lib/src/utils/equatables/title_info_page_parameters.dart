import 'package:equatable/equatable.dart';

class TitleInfoPageParameters extends Equatable {
  const TitleInfoPageParameters({
    required this.id,
    required this.fullRefresh,
  });

  final int id;
  final bool fullRefresh;

  @override
  List<Object> get props => [id, fullRefresh];
}
