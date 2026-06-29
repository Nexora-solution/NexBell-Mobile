// Generates a padded version of the logo for the native splash icon. The
// Android 12 splash shows the icon at a fixed large size, so the source needs
// built-in transparent margin or it gets cropped by the squircle mask. Run:
//   dart run tool/pad_logo.dart
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final src = img.decodePng(File('assets/images/nexbell_logo.png').readAsBytesSync());
  if (src == null) {
    stderr.writeln('Could not read assets/images/nexbell_logo.png');
    exit(1);
  }

  const canvas = 1024; // output size
  const content = 560; // logo content size (~55%) — leaves a comfortable margin

  final scaled = img.copyResize(src, width: content, height: content);
  final out = img.Image(width: canvas, height: canvas, numChannels: 4);
  img.fill(out, color: img.ColorRgba8(0, 0, 0, 0)); // transparent background
  final offset = ((canvas - content) / 2).round();
  img.compositeImage(out, scaled, dstX: offset, dstY: offset);

  File('assets/images/nexbell_splash_logo.png').writeAsBytesSync(img.encodePng(out));
  stdout.writeln('Wrote assets/images/nexbell_splash_logo.png (${canvas}x$canvas, content ${content}px)');
}
