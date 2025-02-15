/// Простейший DI для глобальных зависимостей.
/// Используется в слоях, где недоступен BuildContext.
/// Поддерживает стек и полиморфизм (поиск по любому из предков класса).
class Global {
  static final List<Object> _instances = [];

  static void put(Object instance) => _instances.insert(0, instance);

  static void putAll(List<Object> instances) => instances.forEach(put);

  static T get<T>() {
    for (final i in _instances) {
      if (i is T) return i as T;
    }
    throw 'Instance of $T is not found in Global';
  }
}

/// Краткий синоним для Global.get()
T global<T>() => Global.get<T>();

/// Пример использования с полиморфизмом
void exampleOfUseGlobal() {
  Global.put(_MyUserSession());
  print(global<_AbstractUserSession>());
  print(global<_MyUserSession>());
}

class _AbstractUserSession {}

class _MyUserSession extends _AbstractUserSession {}
