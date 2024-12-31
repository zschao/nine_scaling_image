
# NineScalingImage README

![Demo Image](https://github.com/zschao/nine_scaling_image/blob/main/image.png)

---

## Introduction
`NineScalingImage` is a Flutter widget for parsing and rendering Android 9-patch images. It supports dynamic 9-grid scaling, black-line marker detection, and black-line clipping, making it ideal for adaptive layouts such as backgrounds, pop-ups, and buttons.

---

## Features
- Automatically detects black-line markers in 9-patch images.
- Supports proportional scaling of the target area.
- Optionally hides black-line markers.
- Dynamically adjusts padding and supports child widgets.
- High-performance custom drawing.

---

## Installation
Copy the component code into your project and import it.

```dart
import 'path_to_file/nine_scaling_image.dart';
```

---

## Usage

1. **Basic Usage**

```dart
NineScalingImage(
  imageProvider: AssetImage('assets/images/example.9.png'),
)
```

2. **Full Example**

```dart
NineScalingImage(
  imageProvider: AssetImage('assets/images/example.9.png'),
  dstPieceScale: 0.5, // Scale factor
  hideLines: true, // Hide black lines
  child: Text(
    'Hello, Nine-Patch!',
    style: TextStyle(color: Colors.white),
  ),
);
```

---

## Parameters

| Parameter          | Type              | Default  | Description                                                          |
|--------------------|-------------------|----------|----------------------------------------------------------------------|
| `imageProvider`    | `ImageProvider`  | Required | Background image (`AssetImage`, `NetworkImage`, etc.).               |
| `dstPieceScale`    | `double`         | `1.0`    | Scaling ratio for the target area.                                   |
| `child`            | `Widget?`        | `null`   | Child widget rendered on the background image.                       |
| `hideLines`        | `bool`           | `true`   | Whether to hide the black-line markers in the 9-patch image.         |
| `padding`          | `EdgeInsets?`    | `null`   | Custom padding (calculated automatically if `null`).                 |

---

## Black-Line Clipping
- **`hideLines` Parameter**  
  When set to `true`, the component automatically clips the black-line markers in the 9-patch image.

---

## Notes
1. **Image Format**  
   The image must comply with the 9-patch standard (with black-line markers).

2. **Performance Optimization**  
   For large images, consider using cached `ImageProvider` for better performance.

3. **Child Widget Size**  
   The child widget's size is constrained by the scaled regions of the background image.

---

## Development Environment
- **Flutter SDK**: 3.0.0 or higher
- **Dependencies**: `image_pixels` (for pixel-level color detection)

---

## References
- [Android 9-Patch Image Guide](https://developer.android.com/studio/write/draw9patch)
- [Flutter Official Documentation](https://flutter.dev)

---

