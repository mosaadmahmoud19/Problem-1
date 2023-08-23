import 'dart:io';
import 'package:image/image.dart';
import 'package:path/path.dart' as path;

void extractImages(String sourceFolder, String destinationFolder) {
  if (!Directory(destinationFolder).existsSync()) {
    Directory(destinationFolder).createSync(recursive: true);
  }

  List<Map<String, dynamic>> imageInfo = [];

  final sourceDir = Directory(sourceFolder);
  _processDirectory(sourceDir, destinationFolder, imageInfo);

  final reportFile = File(path.join(destinationFolder, 'image_report.csv'));
  reportFile.writeAsStringSync('Image Name,Image Size,Modification Date\n');
  imageInfo.forEach((info) {
    reportFile.writeAsStringSync(
        '${info['Image Name']},${info['Image Size']},${info['Modification Date']}\n',
        mode: FileMode.append);
  });
}

void _processDirectory(
    Directory sourceDir, String destinationFolder, List<Map<String, dynamic>> imageInfo) {
  for (var entity in sourceDir.listSync()) {
    if (entity is File) {
      if (_isImageFile(entity.path)) {
        final img = decodeImage(File(entity.path).readAsBytesSync());
        if (img != null) {
          final imgNameWithPrefix = path.basename(entity.path);
          final imgName = imgNameWithPrefix.split('_').last; // Remove the prefix
          final imgSize = entity.lengthSync();
          final imgModificationDate = entity.lastModifiedSync();

          final destPath = path.join(destinationFolder, imgName);
          File(destPath).writeAsBytesSync(File(entity.path).readAsBytesSync());

          imageInfo.add({
            'Image Name': imgName,
            'Image Size': imgSize,
            'Modification Date': imgModificationDate.toString(),
          });
        }
      }
    } else if (entity is Directory) {
      _processDirectory(
          entity, destinationFolder, imageInfo);
    }
  }
}

bool _isImageFile(String filePath) {
  final supportedExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.bmp'];
  final extension = path.extension(filePath).toLowerCase();
  return supportedExtensions.contains(extension);
}

void main() {
  const sourceFolder = 'assets/image';
  const destinationFolder = 'images_dataset';
  extractImages(sourceFolder, destinationFolder);
}










