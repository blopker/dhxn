import 'package:http/http.dart';

import 'templates/index.dart';
import 'templates/comment.dart';
import 'api.dart';

String indexPage() {
  var topStories = getTopStories();
  return indexTemplate(topStories);
}

Future<String> commentPage(int id) async {
  var story = await getStory(id);
  if (story == null) {
    return '404';
  }
  return commentTemplate(story);
}
