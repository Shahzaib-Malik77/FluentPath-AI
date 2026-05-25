import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final imagePath = 'assets/images/logo.png';
  final paddedPath = 'assets/images/app_icon_padded.png';
  
  // Read the image
  final imageFile = File(imagePath);
  if (!imageFile.existsSync()) {
    print('Logo file not found');
    return;
  }
  
  final imageBytes = imageFile.readAsBytesSync();
  final originalImage = img.decodeImage(imageBytes);
  
  if (originalImage == null) {
    print('Failed to decode image');
    return;
  }
  
  // Find max dimension to make it perfectly square
  int maxDim = originalImage.width > originalImage.height ? originalImage.width : originalImage.height;
  
  // Add 35% padding to the max dimension to ensure it fits safely inside Android adaptive masks
  int targetDim = (maxDim * 1.35).round();
  
  // Create a transparent square canvas
  final paddedImage = img.Image(width: targetDim, height: targetDim);
  
  // Calculate offsets to center the original image
  int offsetX = (targetDim - originalImage.width) ~/ 2;
  int offsetY = (targetDim - originalImage.height) ~/ 2;
  
  // Draw the original image onto the center of the padded image
  img.compositeImage(paddedImage, originalImage, dstX: offsetX, dstY: offsetY);
  
  // Save the result
  File(paddedPath).writeAsBytesSync(img.encodePng(paddedImage));
  print('Successfully padded image to $targetDim x $targetDim');
}
