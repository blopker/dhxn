import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_gzip/shelf_gzip.dart';
import 'package:shelf_hotreload/shelf_hotreload.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

import 'api.dart';
import 'config.dart';
import 'pages.dart';

var cssHandler = createFileHandler('assets/main.css',
    url: '${Env.staticBase}/main.css'.substring(1));
var favHandler = createFileHandler('assets/favicon.ico',
    url: '${Env.staticBase}/favicon.ico'.substring(1));

// Configure routes.
final _router = Router()
  ..get('/', _indexHandler)
  ..get('/comments/<id>', _commentHandler)
  ..get('${Env.staticBase}/main.css', immutableCache(cssHandler))
  ..get(
    '${Env.staticBase}/favicon.ico',
    immutableCache(favHandler),
  );

Response htmlResponse(String content) => Response.ok(content, headers: {
      'content-type': 'text/html; charset=utf-8',
    });

Response _indexHandler(Request req) {
  return htmlResponse(indexPage());
}

Handler immutableCache(Handler handler) {
  return (Request request) async {
    var response = await handler(request);
    if (Env.isDebug) {
      return response;
    }
    return response.change(
        headers: {'cache-control': 'public, max-age=31536000, immutable'});
  };
}

Future<Response> _commentHandler(Request req) async {
  var id = int.tryParse(req.params['id'] ?? '');
  if (id == null) {
    return Response.notFound('id must be an integer');
  }
  return htmlResponse(await commentPage(id));
}

void main() async {
  unawaited(updateTopStories());
  Timer.periodic(Duration(minutes: 1), (t) {
    updateTopStories();
  });
  if (Env.isDebug) {
    withHotreload(() => createServer());
  } else {
    await createServer();
    print('Server ready');
  }
}

Future<HttpServer> createServer() async {
  final ip = InternetAddress.anyIPv4;
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(gzipMiddleware)
      .addHandler(_router.call);
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port, poweredByHeader: null);
  print('Server at http://localhost:${server.port}');
  return server;
}
