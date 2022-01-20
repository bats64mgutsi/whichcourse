import 'dart:html';

import 'courses.dart';

void main() {
  initApp();
}

void clearCoursesView() {
  querySelector("#courses")?.children.clear();
}

late InputElement inputElement;
void initApp() {
  clearCoursesView();
  final query = getQueryFromUrl();
  querySelector("#courses")?.children.add(getCoursesHtmlAsDiv(query));

  inputElement = querySelector("#searchQueryInput")! as InputElement;
  inputElement.value = query;
  inputElement.addEventListener("input", (event) {
    clearCoursesView();
    querySelector("#courses")
        ?.children
        .add(getCoursesHtmlAsDiv(inputElement.value!));
  });

  querySelector("#shareButton")?.onClick.listen((_) {
    final origin = window.location.origin;
    final link = "$origin?q=${inputElement.value}";

    Future<void> exec() async {
      try {
        await window.navigator.clipboard!.writeText(link);
      } catch (e) {
        inputElement.focus();
        inputElement.select();
        window.document.execCommand('copy');
      }

      window.alert(
        "Copied course link $link to clipboard. Share the link with friends 😇",
      );
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
