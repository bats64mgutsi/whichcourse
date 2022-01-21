import 'dart:html';
import 'courses.dart';

// TODO: Enable analytics
Future<void> main() async {
  initApp(null);
}

void clearCoursesView() {
  querySelector("#courses")?.children.clear();
}

late InputElement inputElement;
void initApp(dynamic analytics) {
  analytics?.logAppOpen();

  clearCoursesView();

  final query = getQueryFromUrl();
  analytics?.logEvent(name: "launch_query", parameters: {
    "query": query,
  });

  querySelector("#courses")?.children.add(getCoursesHtmlAsDiv(query));

  inputElement = querySelector("#searchQueryInput")! as InputElement;
  inputElement.value = query;
  inputElement.addEventListener("input", (event) {
    final search = inputElement.value!;
    analytics?.logEvent(name: "search", parameters: {
      "query": search,
    });

    clearCoursesView();
    querySelector("#courses")?.children.add(getCoursesHtmlAsDiv(search));
  });

  querySelector("#shareButton")?.onClick.listen((_) {
    final origin = window.location.origin;
    final link = "$origin?q=${inputElement.value}";

    Future<void> exec() async {
      try {
        await window.navigator.share({
          "title": "Course Share",
          "text": "See course information on whichcourse",
          "url": link,
        });

        analytics?.logEvent(name: "share", parameters: {
          "link": link,
          "method": "navigator.share",
        });
      } catch (e) {
        await window.navigator.clipboard!.writeText(link);

        window.alert(
          "Copied course link $link to clipboard. Share the link with friends 😇",
        );

        analytics?.logEvent(name: "share", parameters: {
          "link": link,
          "method": "clipboard",
        });
      }
    }

    exec();
  });
}

Element getCoursesHtmlAsDiv(String query) {
  final children = courses.keys
      .where((name) => name.contains(query.trim().toUpperCase()))
      .map((name) => wrapCourseHtml(courses[name]!))
      .toList();

  return DivElement()..children.addAll(children);
}

Element wrapCourseHtml(String html) {
  return Element.html('<div class="row"><div class="col">$html</div></div>');
}

String getQueryFromUrl() {
  final uri = Uri.parse(window.location.href);

  var out = "";
  uri.queryParameters.forEach((key, value) {
    if (key.toLowerCase() == "q") {
      out = value;
    }
  });

  return out;
}
