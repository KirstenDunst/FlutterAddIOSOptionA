import 'package:focus_game/redux/rocket_middlewares.dart';
import 'package:focus_game/redux/rocket_reducer.dart';
import 'package:focus_game/repository/repositories.dart';
import 'package:redux/redux.dart';

class StoreContainer {
  static Store<AppState> _global;

  static Store<AppState> get global {
    if (_global == null) {
      _global = Store<AppState>(globalReducer,
          initialState: initialGlobalState(),
          middleware: initialMiddleware(),
          distinct: true); // 当 reducer 操作 store 后发生变化才触发刷新界面。用"=="比较。
    }
    return _global;
  }

  static dispatch(dynamic action) => global.dispatch(action);
}

/// 全局reducer，传入原始 state 和 action，返回新的state
AppState globalReducer(AppState state, action) {
  print('globalReducer $action');
  return AppState(
    rocket: loginReducer(state.rocket, action),
  );
}

/// 状态树的初始化
AppState initialGlobalState() {
  return AppState(rocket: RocketState.initialState());
}

/// 状态树
class AppState {
  final RocketState rocket;

  AppState({this.rocket});
}

/// 参数repo是optional的，用来做测试时传入mock的数据
List<Middleware<AppState>> initialMiddleware([AppRepository repo]) {
  final repository = repo ?? AppRepository();
  List<Middleware<AppState>> middleware = [];
  List<MiddlewareFactory> factories = [RocketMiddlewareFactory(repository)];
  factories.forEach((factory) => middleware.addAll(factory.generate()));
  return middleware;
}

abstract class MiddlewareFactory {
  final AppRepository repository;

  MiddlewareFactory(this.repository);

  /// 返回模块下中间件列表
  List<Middleware<AppState>> generate();
}
