import 'base.dart';
import '../api.dart';

Future<String> commentTemplate(Story story) async {
  var commentsHTML = StringBuffer();
  for (var comment in await story.getKids()) {
    commentsHTML.write(await _commentHTML(comment));
  }

  return baseTemplate('Comments', _storyHTML(story, commentsHTML.toString()));
}

Future<String> _commentHTML(Comment comment) async {
  if (comment.by.isEmpty || comment.text.isEmpty) {
    return '';
  }
  return '''
  <details open class="comment">
      <summary class="author">${comment.by} - ${comment.timeago}</summary>
      <div class="text">${comment.text}</div>
      ${await _childrenHTML(await comment.getKids())}
  </details>''';
}

Future<String> _childrenHTML(List<Comment> comments) async {
  var content =
      (await Future.wait(comments.map((comment) => _commentHTML(comment))))
          .join('\n');
  if (content.isEmpty) {
    return '';
  }
  return '''
  <div class="children">
    $content
  </div>''';
}

String _storyHTML(Story story, String commentsHTML) {
  return '''
    <div>
        <div class="comment-header">
            <h3>${story.title}</h3>
            <a href=${story.url} rel="noreferrer">${story.displayUrlLong}</a>
            <div class="comment-header-author">By: ${story.by}</div>
            <a href=${story.displayHNUrl} rel="noreferrer">HN Link</a>
            <div class="text">${story.text}</div>
        </div>
        <div class="comments">
            $commentsHTML
        </div>
    </div>''';
}
