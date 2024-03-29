import 'dart:convert';
import 'dart:core';

import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:quiver/collection.dart';
import 'package:timeago/timeago.dart' as ta;

var _cache = LruMap<int, Item>(maximumSize: 10000);

var _topStories = <int>[];

final _client = RetryClient(http.Client());

class Item {
  int id;
  String by;
  bool deleted = false;
  int time;
  String text;
  bool dead = false;
  List<int> kids;
  Item({
    required this.id,
    required this.by,
    required this.time,
    required this.text,
    required this.kids,
  });

  String get timeago =>
      ta.format(DateTime.fromMillisecondsSinceEpoch(time * 1000));

  Future<List<Comment>> getKids() async {
    var resultsF = kids.map((kid) => _getItem(kid));
    var results = await Future.wait(resultsF);
    return results.whereType<Comment>().toList();
  }
}

class Story extends Item {
  String url;
  String title;
  int descendants;
  int score;
  String displayUrl;
  String displayUrlLong;
  String displayHNUrl;
  Story({
    required super.id,
    required super.by,
    required super.time,
    required super.text,
    required super.kids,
    required this.url,
    required this.title,
    required this.descendants,
    required this.score,
    required this.displayUrl,
    required this.displayUrlLong,
    required this.displayHNUrl,
  });
}

class Comment extends Item {
  int? parent;
  Comment({
    required super.id,
    required super.by,
    required super.time,
    required super.text,
    required super.kids,
    required this.parent,
  });
}

Comment _makeComment(Map data) {
  var kids = data['kids']?.cast<int>() ?? <int>[];
  return Comment(
    id: data['id'],
    by: data['by'] ?? '',
    time: data['time'],
    text: data['text'] ?? '',
    kids: kids,
    parent: data['parent'],
  );
}

String cleanTag(String html) {
  return html
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}

Story _makeStory(Map data) {
  var kids = data['kids']?.cast<int>() ?? <int>[];
  var displayHNUrl = 'https://news.ycombinator.com/item?id=${data['id']}';
  String url = data['url'] ?? displayHNUrl;
  var displayUrl = url;
  var displayUrlLong = url;
  try {
    var urlParsed = Uri.parse(url);
    displayUrlLong = urlParsed.host + urlParsed.path;
    displayUrl = urlParsed.host;
    if (displayUrl.contains('github.com')) {
      displayUrl = displayUrlLong;
    }
  } catch (e) {
    // ignore
  }

  return Story(
    id: data['id'],
    by: data['by'],
    time: data['time'],
    text: data['text'] ?? '',
    kids: kids,
    score: data['score'],
    url: url,
    title: cleanTag(data['title']),
    descendants: data['descendants'],
    displayUrl: displayUrl,
    displayUrlLong: displayUrlLong,
    displayHNUrl: displayHNUrl,
  );
}

Future<http.Response> getUri(String url) async {
  var uri = Uri.parse(url);
  try {
    return await _client.get(uri);
  } catch (e) {
    return await _client.get(uri);
  }
}

Future<Map?> getJsonMap(String url) async {
  var response = await getUri(url);
  if (response.statusCode != 200) {
    return null;
  }
  if (response.body.isEmpty) {
    return null;
  }
  try {
    final decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return decodedResponse;
  } catch (e) {
    return null;
  }
}

Future<List<int>?> getJsonList(String url) async {
  var response = await getUri(url);
  if (response.statusCode != 200) {
    return null;
  }
  if (response.body.isEmpty) {
    return null;
  }
  try {
    final decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return decodedResponse.cast<int>();
  } catch (e) {
    return null;
  }
}

Future<Item?> _getItem(int id, {cache = true}) async {
  if (cache && _cache.containsKey(id)) {
    return _cache[id];
  }
  var json =
      await getJsonMap('https://hacker-news.firebaseio.com/v0/item/$id.json');
  if (json == null || json['type'] == null) {
    return null;
  }
  Item? item;
  if (json['type'] == 'story') {
    item = _makeStory(json);
  } else if (json['type'] == 'comment') {
    item = _makeComment(json);
  }
  if (item != null) {
    _cache[id] = item;
  }
  return item;
}

Future<void> updateTopStories() async {
  List<int> stories;
  try {
    final response = await getJsonList(
        'https://hacker-news.firebaseio.com/v0/topstories.json');
    if (response == null) {
      return;
    }
    stories = response;
  } catch (e) {
    print(e);
    return;
  }
  _topStories = stories.sublist(0, 30);
  var cachedResults = _topStories.map((id) => _cache[id]).toList();
  var results =
      await Future.wait(_topStories.map((id) => _getItem(id, cache: false)));
  for (var i = 0; i < _topStories.length; i++) {
    var story = results[i] as Story?;
    var cached = cachedResults[i] as Story?;
    if (story == null) {
      continue;
    }
    if (cached == null || cached.descendants != story.descendants) {
      _refresh(story);
    }
  }
}

void _refresh(Item item) async {
  for (var commentId in item.kids) {
    var comment = (await _getItem(commentId, cache: false)) as Comment?;
    if (comment == null) {
      return;
    }
    _cache[comment.id] = comment;
    _refresh(comment);
  }
}

Iterable<Story> getTopStories() {
  List<Story> stories = [];
  for (var storyId in _topStories) {
    var story = _cache[storyId] as Story?;
    if (story != null) {
      stories.add(story);
    }
  }
  return stories;
}

Future<Story?> getStory(int id) async {
  return await _getItem(id) as Story?;
}
