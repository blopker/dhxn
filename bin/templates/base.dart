import 'dart:convert';
import '../config.dart';

final c = HtmlEscape();

String baseTemplate(String title, String content) {
  title = c.convert(title);
  return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>dHXN - $title</title>
    <link rel="icon" href="${Env.staticBase}/favicon.ico" type="image/x-icon" />
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
    <link rel="stylesheet" href="${Env.staticBase}/main.css" />
</head>
    <body>
        <a href="/">
            <header>
                <div class="header-title">
                    <h3>dHXN</h3>
                </div>
            </header>
        </a>
        <div id="container" class="items">
            $content
        </div>
        <footer>
            Yolo'd by blopker. <a href="https://github.com/blopker/gohxn">Source</a>.
        </footer>
    </body>
</html>
''';
}
