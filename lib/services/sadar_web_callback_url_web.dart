import 'package:web/web.dart' as web;

void clearSadarWebCallbackQuery() {
  final current = Uri.parse(web.window.location.href);
  final params = {...current.queryParameters}
    ..removeWhere((key, _) => key.startsWith('fc_'));
  final next = current.replace(queryParameters: params);
  web.window.history.replaceState(
    null,
    '',
    '${next.path}${next.hasQuery ? '?${next.query}' : ''}${next.hasFragment ? '#${next.fragment}' : ''}',
  );
}
