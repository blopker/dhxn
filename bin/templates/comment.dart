import 'base.dart';
import '../api.dart';

String commentTemplate(Story story) {
  var commentsHTML = StringBuffer();
  for (var comment in story.getKids()) {
    commentsHTML.write(_commentHTML(comment));
  }

  return baseTemplate('Comments', _storyHTML(story, commentsHTML.toString()));
}

String _commentHTML(Comment comment) {
  if (comment.by.isEmpty || comment.text.isEmpty) {
    return '';
  }
  return '''        
  <details open class="comment">
      <summary class="author">${comment.by}</summary>
      <div class="text">${comment.text}</div>
      ${_childrenHTML(comment.getKids())}
  </details>''';
}

String _childrenHTML(List<Comment> comments) {
  var content = comments.map((comment) => _commentHTML(comment)).join('\n');
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
            <a href=${story.url}>${story.displayUrlLong}</a>
            <div class="comment-header-author">By: ${story.by}</div>
            <a href=${story.displayHNUrl}>HN Link</a>
            <div class="text">${story.text}</div>
        </div>
        <div class="comments">
            $commentsHTML
        </div>
    </div>''';
}
