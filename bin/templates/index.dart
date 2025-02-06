import 'base.dart';
import '../api.dart';

String indexTemplate(Iterable<Story> stories) {
  var content = stories.map((e) => _storyHTML(e)).join('\n');
  return baseTemplate('Stories', content);
}

String _storyHTML(Story story) {
  var content = '''
    <div class="list-item">
        <a href="${story.url}" rel="noreferrer">
            <div class="story">
                <h3>${story.title}</h3>
                <div class="host">${story.displayUrl}</div>
            </div>
        </a>
        <a href="/comments/${story.id}">
            <aside>
                <div class="comment-count">${story.descendants}</div>
                <div class="score">${story.score}</div>
            </aside>
        </a>
    </div>
  ''';
  return content;
}
