import 'package:hydrated_bloc/hydrated_bloc.dart';

class ReviewCubit extends HydratedCubit<int> {
  ReviewCubit(super.state);

  void init() {
    emit(state + 1);
  }

  @override
  int? fromJson(Map<String, dynamic> json) {
    return json["value"];
  }

  @override
  Map<String, dynamic>? toJson(int state) {
    return {"value" : state};
  }
}