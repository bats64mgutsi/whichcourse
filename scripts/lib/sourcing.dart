import 'package:html/dom.dart';

String getHandbookStyles(Document doc) {
  return doc.getElementsByTagName("style")[0].innerHtml;
}

List<Extractable> getCoursesInPages(
    {required int from, required int to, required Document doc}) {
  final sourcer = Sourcer(
    shouldBegin: (children, index) {
      final element = children[index];
      final childElements = element.getElementsByTagName("span");

      return childElements.isNotEmpty && childElements[0].className == "ft50";
    },
    shouldIgnore: (children, index) {
      final element = children[index];
      return element.innerHtml
          .trim()
          .toUpperCase()
          .contains("DEPARTMENTS IN THE FACULTY");
    },
    shouldEnd: (children, index) {
      if (index + 1 == children.length) return false;
      final nextElement = children[index + 1];
      final childElements = nextElement.getElementsByTagName("span");

      return childElements.isNotEmpty && childElements[0].className == "ft50";
    },
  );

  return sourcer.begin(doc, from: from, to: to);
}

class Extractable {
  final List<Element> elements;
  Extractable(this.elements);

  String? firstCourseName() {
    final regexp = RegExp(r"[A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][A-Z]");
    final match = regexp.firstMatch(elements.first.innerHtml);

    if (match == null) return null;
    return elements.first.innerHtml.substring(match.start, match.end);
  }

  String get html => elements.map((e) => e.outerHtml).join("");

  @override
  operator ==(other) {
    return other is Extractable && other.firstCourseName() == firstCourseName();
  }

  @override
  int get hashCode => firstCourseName().hashCode;
}

typedef ShouldDoWhatCallback = bool Function(
    List<Element> pageElements, int thisElementIndex);

class Sourcer {
  final ShouldDoWhatCallback shouldBegin;
  final ShouldDoWhatCallback shouldIgnore;
  final ShouldDoWhatCallback shouldEnd;

  Sourcer({
    required this.shouldBegin,
    required this.shouldIgnore,
    required this.shouldEnd,
  });

  List<Extractable> begin(Document doc, {required int from, required int to}) {
    final List<Extractable> out = [];

    Extractable? extractable;
    for (int pageNumber = from; pageNumber <= to; pageNumber++) {
      final page = doc.getElementById("page_$pageNumber");

      for (int thisElementIndex = 0;
          thisElementIndex < page!.children.length;
          thisElementIndex++) {
        final element = page.children[thisElementIndex];

        // At the moment, even though I still don't understand why, some courses
        // are not extracted when we do not do the null check.
        if (shouldBegin(page.children, thisElementIndex)) {
          print("begin ${page.children[thisElementIndex].innerHtml}");
          extractable = Extractable([element]);
        }

        if (extractable != null &&
            !shouldIgnore(page.children, thisElementIndex)) {
          extractable.elements.add(element);

          if (shouldEnd(page.children, thisElementIndex)) {
            print("close ${page.children[thisElementIndex].innerHtml}");
            out.add(extractable);
            extractable = null;
          }
        }
      }
    }

    return out;
  }
}
