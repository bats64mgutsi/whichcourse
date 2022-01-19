import 'dart:io';
import 'package:dart_style/dart_style.dart';
import 'package:html/parser.dart';
import 'package:scripts/sourcing.dart';

/// Reads in the html file of the Science 2022 handbook and parses out
/// All courses it lists. The pdf was converted to html using
/// https://pdf.online/convert-pdf-to-html
void main() {
  final out = generateSourcesFile();
  File("/Users/batandwamgutsi/Desktop/whichcourse/app/constants/courses.dart")
      .writeAsStringSync(out);
}

String generateSourcesFile() {
  final html = File(
          "/Users/batandwamgutsi/Desktop/whichcourse/scripts/data/2022_SCI_Handbook.html")
      .readAsStringSync();

  final doc = parse(html);
  final out = StringBuffer("/// Auto generated. Do not modify by hand.\n\n");
  out.write("const courses = {\n");

  for (final extractable
      in getCoursesInPages(from: 55, to: 227, doc: doc).toSet().toList()) {
    final courseName = extractable.firstCourseName();
    final html =
        extractable.html.replaceAll('"', '\\"').replaceAll('\$', '\\\$');

    out.write('"$courseName": """$html""",\n');
  }

  out.write("};");

  final formatter = DartFormatter();
  return formatter.format(out.toString());
}
