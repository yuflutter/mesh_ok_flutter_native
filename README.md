# Mesh.OK

Текстовый чат между двумя устройствами Android через WiFi-direct. Первая попытка реализации на базе плагина flutter_p2p_connection оказалась не вполне удачной. Вот этот код:

https://github.com/yuflutter/mesh_ok_flutter_pure

Он работает, но из-за недостатков плагина и полном отсутcтвии обработки сетевых ошибок (все методы платформы возвращают true/false), пришлось отказаться от использования плагина, и переписать сетевую часть на котлин.

В итоге на котлин перенесено:
- Запрос разрешений и включение сетевых сервисов (асинхронный API андроида был преобразован в корутины).
- Реализация протокола WiFi-direct (кроме определения сетевых служб).

На флаттере осталось:
- Пользовательский интерфейс.
- Реализация клиентских и серверных вебсокетов.

## TODO

- Протестировать и усовершенствовать обработку ошибок, похоже сейчас не всё обрабатывается корректно (редкие зависания на диалоге "подключить к ...").

- При отключении от группы P2P - что делать, если открыт чат? Закрывать экран? А историю сообщений удалять?

- Разобраться, как работает группа P2P, и насколько реально построить MESH (PS: нереально, так как устройство может входить только в одну группу P2P).

- Отказаться от прямого использования FlutterView, и оформить котлин-код в соответствии с рекомендациям к нативным плагинам флаттер.

- Разобраться с фоновым режимом на стороне котлина, похоже мы иногда теряем глобал-стейт или бродкаст. PS: Вероятно это касается только дебаг-режима, в релизе пока не удалось поймать.

- В перспективе оформить сетевую часть отдельным публичным пакетом, который будет лучше, чем flutter_p2p_connection.
