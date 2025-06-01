import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../models/image_data.dart';
import 'dart:ui' show PointMode;

class PlacedImage {
  final ui.Image image;
  final Offset position;
  final double rotation;
  final double scale;
  final String? id;

  PlacedImage({
    required this.image,
    this.position = Offset.zero,
    this.rotation = 0.0,
    this.scale = 1.0,
    this.id,
  });

  PlacedImage copyWith({
    ui.Image? image,
    Offset? position,
    double? rotation,
    double? scale,
    String? id,
  }) {
    return PlacedImage(
      image: image ?? this.image,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      id: id ?? this.id,
    );
  }
}

class Chalkboard extends StatefulWidget {
  final VoidCallback onBack;
  const Chalkboard({super.key, required this.onBack});

  @override
  State<Chalkboard> createState() => _ChalkboardState();
}

class _ChalkboardState extends State<Chalkboard> {
  List<DrawingPoint?> drawingPoints = [];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 5.0;
  String _selectedCategory = 'animals';
  List<ui.Image> _images = [];
  bool _isEraser = false;
  bool _isImageMode = false;
  List<PlacedImage> _placedImages = [];
  PlacedImage? _selectedImage;
  Offset _dragStartPosition = Offset.zero;
  double _rotation = 0.0;
  double _scale = 1.0;
  final GlobalKey _canvasKey = GlobalKey();
  final double _eraserSize = 20.0;
  Offset? _rotationHandlePosition;
  Offset? _scaleHandlePosition;
  bool _isRotating = false;
  bool _isScaling = false;
  bool _isDragging = false;
  bool _isHandleRotating = false;
  bool _isHandleScaling = false;

  @override
  void dispose() {
    for (var image in _images) {
      image.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;
      setState(() {
        _images.add(image);
      });
    }
  }

  Future<void> _addCardImage(String imagePath) async {
    final bytes = await rootBundle.load(imagePath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes.buffer.asUint8List(),
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;
    setState(() {
      _placedImages.add(PlacedImage(
        image: image,
        position: Offset(100, 100),
        rotation: 0.0,
        scale: 1.0,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      ));
    });
  }

  void _removeLastDrawable() {
    setState(() {
      if (_images.isNotEmpty) {
        _images.last.dispose();
        _images.removeLast();
      } else if (drawingPoints.isNotEmpty) {
        drawingPoints.removeLast();
      }
    });
  }

  void _toggleEraser() {
    setState(() {
      _isEraser = !_isEraser;
      if (_isEraser) {
        _selectedColor = Colors.white;
      }
    });
  }

  void _toggleImageMode() {
    setState(() {
      _isImageMode = !_isImageMode;
      if (!_isImageMode) {
        _selectedImage = null;
      }
      _isEraser = false;
    });
  }

  void _eraseAtPoint(Offset point) {
    setState(() {
      // 지우개 영역 내의 점들을 찾아서 제거
      drawingPoints.removeWhere((drawingPoint) {
        if (drawingPoint == null) return false;
        final distance = (drawingPoint.offset - point).distance;
        return distance < _eraserSize;
      });
    });
  }

  void _onImageTap(PlacedImage image) {
    if (_isImageMode) {
      setState(() {
        _selectedImage = image;
        _updateHandlePositions(image);
        _isDragging = false;
        _isRotating = false;
        _isScaling = false;
        _dragStartPosition = Offset.zero;
      });
    }
  }

  void _updateHandlePositions(PlacedImage image) {
    final imageWidth = image.image.width.toDouble() * image.scale;
    final imageHeight = image.image.height.toDouble() * image.scale;

    // 회전 핸들 위치 (우측 상단)
    _rotationHandlePosition = Offset(
      image.position.dx + imageWidth,
      image.position.dy,
    );

    // 크기 조절 핸들 위치 (우측 하단)
    _scaleHandlePosition = Offset(
      image.position.dx + imageWidth,
      image.position.dy + imageHeight,
    );
  }

  void _onCanvasTap() {
    if (_isImageMode) {
      setState(() {
        _selectedImage = null;
        _rotationHandlePosition = null;
        _scaleHandlePosition = null;
        _isDragging = false;
        _isRotating = false;
        _isScaling = false;
        _dragStartPosition = Offset.zero;
      });
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (!_isImageMode || _selectedImage == null) return;

    final localPosition = details.localFocalPoint;

    // 회전 핸들 영역 확인
    if (_rotationHandlePosition != null) {
      final rotationHandleRect = Rect.fromCenter(
        center: _rotationHandlePosition!,
        width: 40,
        height: 40,
      );
      if (rotationHandleRect.contains(localPosition)) {
        _isRotating = true;
        _isDragging = false;
        _isScaling = false;
        _dragStartPosition = localPosition;
        return;
      }
    }

    // 크기 조절 핸들 영역 확인
    if (_scaleHandlePosition != null) {
      final scaleHandleRect = Rect.fromCenter(
        center: _scaleHandlePosition!,
        width: 40,
        height: 40,
      );
      if (scaleHandleRect.contains(localPosition)) {
        _isScaling = true;
        _isDragging = false;
        _isRotating = false;
        _dragStartPosition = localPosition;
        return;
      }
    }

    // 이미지 영역 확인
    final imageRect = Rect.fromLTWH(
      _selectedImage!.position.dx,
      _selectedImage!.position.dy,
      _selectedImage!.image.width.toDouble() * _selectedImage!.scale,
      _selectedImage!.image.height.toDouble() * _selectedImage!.scale,
    );

    if (imageRect.contains(localPosition)) {
      _isDragging = true;
      _isRotating = false;
      _isScaling = false;
      _dragStartPosition = localPosition;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!_isImageMode || _selectedImage == null) return;

    final localPosition = details.localFocalPoint;
    final imageCenter = Offset(
      _selectedImage!.position.dx +
          _selectedImage!.image.width.toDouble() * _selectedImage!.scale / 2,
      _selectedImage!.position.dy +
          _selectedImage!.image.height.toDouble() * _selectedImage!.scale / 2,
    );

    if (_isRotating) {
      // 회전 계산
      final startAngle = (_dragStartPosition - imageCenter).direction;
      final currentAngle = (localPosition - imageCenter).direction;
      final rotationDelta = currentAngle - startAngle;

      _selectedImage = _selectedImage!.copyWith(
        rotation: _selectedImage!.rotation + rotationDelta,
      );
      _dragStartPosition = localPosition;
      _updateHandlePositions(_selectedImage!);
      setState(() {});
    } else if (_isScaling) {
      // 크기 조절 계산
      final startDistance = (_dragStartPosition - imageCenter).distance;
      final currentDistance = (localPosition - imageCenter).distance;
      final scaleDelta = currentDistance / startDistance;

      _selectedImage = _selectedImage!.copyWith(
        scale: (_selectedImage!.scale * scaleDelta).clamp(0.1, 5.0),
      );
      _dragStartPosition = localPosition;
      _updateHandlePositions(_selectedImage!);
      setState(() {});
    } else if (_isDragging) {
      // 이미지 이동
      final delta = localPosition - _dragStartPosition;
      _selectedImage = _selectedImage!.copyWith(
        position: _selectedImage!.position + delta,
      );
      _dragStartPosition = localPosition;
      _updateHandlePositions(_selectedImage!);
      setState(() {});
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (!_isImageMode || _selectedImage == null) return;

    final index =
        _placedImages.indexWhere((img) => img.id == _selectedImage!.id);
    if (index != -1) {
      _placedImages[index] = _selectedImage!;
      _isRotating = false;
      _isScaling = false;
      _isDragging = false;
      _dragStartPosition = Offset.zero;
      setState(() {});
    }
  }

  void _deleteSelectedImage() {
    if (_selectedImage != null) {
      setState(() {
        _placedImages.removeWhere((img) => img.id == _selectedImage!.id);
        _selectedImage = null;
      });
    }
  }

  void _onRotateHandlePanStart(DragStartDetails details) {
    _isHandleRotating = true;
    _dragStartPosition = details.localPosition;
  }

  void _onRotateHandlePanUpdate(DragUpdateDetails details) {
    if (_selectedImage == null) return;
    final image = _selectedImage!;
    final imageWidth = image.image.width.toDouble() * image.scale;
    final imageHeight = image.image.height.toDouble() * image.scale;
    final center = Offset(
      image.position.dx + imageWidth / 2,
      image.position.dy + imageHeight / 2,
    );
    final startAngle = (_dragStartPosition +
            _rotationHandlePosition! -
            Offset(20, 20) -
            center)
        .direction;
    final currentAngle = (details.localPosition +
            _rotationHandlePosition! -
            Offset(20, 20) -
            center)
        .direction;
    final rotationDelta = currentAngle - startAngle;
    setState(() {
      _selectedImage = image.copyWith(
        rotation: image.rotation + rotationDelta,
      );
      _updateHandlePositions(_selectedImage!);
      _dragStartPosition = details.localPosition;
    });
  }

  void _onRotateHandlePanEnd(DragEndDetails details) {
    _isHandleRotating = false;
    _dragStartPosition = Offset.zero;
    if (_selectedImage != null) {
      final idx =
          _placedImages.indexWhere((img) => img.id == _selectedImage!.id);
      if (idx != -1)
        setState(() {
          _placedImages[idx] = _selectedImage!;
        });
    }
  }

  void _onScaleHandlePanStart(DragStartDetails details) {
    _isHandleScaling = true;
    _dragStartPosition = details.localPosition;
  }

  void _onScaleHandlePanUpdate(DragUpdateDetails details) {
    if (_selectedImage == null) return;
    final image = _selectedImage!;
    final imageWidth = image.image.width.toDouble() * image.scale;
    final imageHeight = image.image.height.toDouble() * image.scale;
    final center = Offset(
      image.position.dx + imageWidth / 2,
      image.position.dy + imageHeight / 2,
    );
    final startDistance =
        (_dragStartPosition + _scaleHandlePosition! - Offset(20, 20) - center)
            .distance;
    final currentDistance = (details.localPosition +
            _scaleHandlePosition! -
            Offset(20, 20) -
            center)
        .distance;
    final scaleDelta = currentDistance / startDistance;
    setState(() {
      _selectedImage = image.copyWith(
        scale: (image.scale * scaleDelta).clamp(0.1, 5.0),
      );
      _updateHandlePositions(_selectedImage!);
      _dragStartPosition = details.localPosition;
    });
  }

  void _onScaleHandlePanEnd(DragEndDetails details) {
    _isHandleScaling = false;
    _dragStartPosition = Offset.zero;
    if (_selectedImage != null) {
      final idx =
          _placedImages.indexWhere((img) => img.id == _selectedImage!.id);
      if (idx != -1)
        setState(() {
          _placedImages[idx] = _selectedImage!;
        });
    }
  }

  void _onImagePanStart(DragStartDetails details) {
    _isDragging = true;
    _dragStartPosition = details.localPosition;
  }

  void _onImagePanUpdate(DragUpdateDetails details) {
    if (_selectedImage == null) return;
    setState(() {
      _selectedImage = _selectedImage!.copyWith(
        position: _selectedImage!.position + details.delta,
      );
      _updateHandlePositions(_selectedImage!);
    });
  }

  void _onImagePanEnd(DragEndDetails details) {
    _isDragging = false;
    _dragStartPosition = Offset.zero;
    if (_selectedImage != null) {
      final idx =
          _placedImages.indexWhere((img) => img.id == _selectedImage!.id);
      if (idx != -1)
        setState(() {
          _placedImages[idx] = _selectedImage!;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.yellow[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: widget.onBack,
        ),
        title: const Text('칠판', style: TextStyle(color: Colors.brown)),
        centerTitle: true,
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.brown),
              onPressed: _deleteSelectedImage,
              tooltip: '선택한 이미지 삭제',
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.brown),
            onPressed: _removeLastDrawable,
            tooltip: '마지막 그리기/이미지 삭제',
          ),
          IconButton(
            icon: Icon(_isEraser ? Icons.edit : Icons.auto_fix_high,
                color: Colors.brown),
            onPressed: _toggleEraser,
            tooltip: '지우개',
          ),
          IconButton(
            icon: Icon(_isImageMode ? Icons.edit : Icons.image,
                color: Colors.brown),
            onPressed: _toggleImageMode,
            tooltip: '이미지 조작 모드',
          ),
          IconButton(
            icon: const Icon(Icons.image, color: Colors.brown),
            onPressed: _pickImage,
            tooltip: '이미지 불러오기',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.yellow[100],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isImageMode) ...[
                      _buildColorButton(Colors.black),
                      _buildColorButton(Colors.brown),
                      _buildColorButton(Colors.red),
                      _buildColorButton(Colors.blue),
                      _buildColorButton(Colors.green),
                      _buildColorButton(Colors.purple),
                      const SizedBox(width: 16),
                      _buildStrokeWidthButton(3.0),
                      _buildStrokeWidthButton(6.0),
                      _buildStrokeWidthButton(9.0),
                      const SizedBox(width: 16),
                      _buildEraserButton(),
                    ] else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.brown[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.image, color: Colors.brown),
                            const SizedBox(width: 8),
                            const Text(
                              '이미지 조작 모드',
                              style: TextStyle(
                                color: Colors.brown,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_selectedImage != null) ...[
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.brown),
                                onPressed: _deleteSelectedImage,
                                tooltip: '선택한 이미지 삭제',
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryButton('동물', 'animals'),
                      _buildCategoryButton('과일', 'fruits'),
                      _buildCategoryButton('탈것', 'vehicles'),
                      _buildCategoryButton('사물', 'objects'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        ImageData.imageMap[_selectedCategory]?.length ?? 0,
                    itemBuilder: (context, index) {
                      final card =
                          ImageData.imageMap[_selectedCategory]![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () => _addCardImage(card['src']!),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.brown),
                            ),
                            child: Image.asset(
                              card['src']!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: Stack(
                  children: [
                    ..._placedImages.map((image) {
                      return Positioned(
                        left: image.position.dx,
                        top: image.position.dy,
                        child: GestureDetector(
                          onTap: () => _onImageTap(image),
                          onPanStart:
                              image.id == _selectedImage?.id && _isImageMode
                                  ? _onImagePanStart
                                  : null,
                          onPanUpdate:
                              image.id == _selectedImage?.id && _isImageMode
                                  ? _onImagePanUpdate
                                  : null,
                          onPanEnd:
                              image.id == _selectedImage?.id && _isImageMode
                                  ? _onImagePanEnd
                                  : null,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: image.id == _selectedImage?.id
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Transform.rotate(
                                  angle: image.rotation,
                                  child: Transform.scale(
                                    scale: image.scale,
                                    child: RawImage(
                                      image: image.image,
                                      width: image.image.width.toDouble(),
                                      height: image.image.height.toDouble(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    if (!_isImageMode)
                      GestureDetector(
                        onTap: _onCanvasTap,
                        onScaleStart: _onScaleStart,
                        onScaleUpdate: _onScaleUpdate,
                        onScaleEnd: _onScaleEnd,
                        child: CustomPaint(
                          key: _canvasKey,
                          painter: _DrawingPainter(
                            drawingPoints: drawingPoints,
                            images: _images,
                            placedImages: _placedImages,
                            selectedImage: _selectedImage,
                          ),
                          size: Size(
                            MediaQuery.of(context).size.width * 0.95,
                            MediaQuery.of(context).size.height * 0.8,
                          ),
                        ),
                      ),
                    if (_isEraser && !_isImageMode)
                      Positioned(
                        left: _dragStartPosition.dx - _eraserSize,
                        top: _dragStartPosition.dy - _eraserSize,
                        child: Container(
                          width: _eraserSize * 2,
                          height: _eraserSize * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    if (_selectedImage != null &&
                        _rotationHandlePosition != null &&
                        _isImageMode)
                      Positioned(
                        left: _rotationHandlePosition!.dx - 20,
                        top: _rotationHandlePosition!.dy - 20,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: GestureDetector(
                            onPanStart: _onRotateHandlePanStart,
                            onPanUpdate: _onRotateHandlePanUpdate,
                            onPanEnd: _onRotateHandlePanEnd,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.rotate_right,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_selectedImage != null &&
                        _scaleHandlePosition != null &&
                        _isImageMode)
                      Positioned(
                        left: _scaleHandlePosition!.dx - 20,
                        top: _scaleHandlePosition!.dy - 20,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: GestureDetector(
                            onPanStart: _onScaleHandlePanStart,
                            onPanUpdate: _onScaleHandlePanUpdate,
                            onPanEnd: _onScaleHandlePanEnd,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.aspect_ratio,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
      ),
    );
  }

  Widget _buildStrokeWidthButton(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => setState(() => _strokeWidth = width),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: _strokeWidth == width ? Colors.brown : Colors.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: Container(
              width: width,
              height: width,
              decoration: const BoxDecoration(
                color: Colors.brown,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEraserButton() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _isEraser ? Colors.grey[300] : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: _isEraser ? Colors.brown : Colors.grey,
          width: 2,
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.auto_fix_high, size: 16),
        onPressed: _toggleEraser,
        color: Colors.brown,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildCategoryButton(String label, String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedCategory = category),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _selectedCategory == category ? Colors.brown : Colors.white,
          foregroundColor:
              _selectedCategory == category ? Colors.white : Colors.brown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.brown),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class DrawingPoint {
  Offset offset;
  Paint paint;

  DrawingPoint(this.offset, this.paint);
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> drawingPoints;
  final List<ui.Image> images;
  final List<PlacedImage> placedImages;
  final PlacedImage? selectedImage;

  _DrawingPainter({
    required this.drawingPoints,
    required this.images,
    required this.placedImages,
    this.selectedImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var imageData in placedImages) {
      canvas.save();
      canvas.translate(imageData.position.dx, imageData.position.dy);
      canvas.rotate(imageData.rotation);
      canvas.scale(imageData.scale, imageData.scale);
      canvas.drawImage(imageData.image, Offset.zero, Paint());

      if (imageData.id == selectedImage?.id) {
        final rect = Rect.fromLTWH(
          0,
          0,
          imageData.image.width.toDouble(),
          imageData.image.height.toDouble(),
        );
        final paint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawRect(rect, paint);

        final rotationHandle = Offset(
          rect.right + 20,
          rect.top - 20,
        );
        canvas.drawCircle(rotationHandle, 8, Paint()..color = Colors.blue);
      }

      canvas.restore();
    }

    for (int i = 0; i < drawingPoints.length - 1; i++) {
      if (drawingPoints[i] != null && drawingPoints[i + 1] != null) {
        canvas.drawLine(
          drawingPoints[i]!.offset,
          drawingPoints[i + 1]!.offset,
          drawingPoints[i]!.paint,
        );
      } else if (drawingPoints[i] != null && drawingPoints[i + 1] == null) {
        canvas.drawPoints(
          PointMode.points,
          [drawingPoints[i]!.offset],
          drawingPoints[i]!.paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
