import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class CatchGame extends FlameGame with PanDetector {
  // Game Entities & Metrics
  late Vector2 playerPosition;
  late Vector2 playerSize;

  List<FallingObject> fallingObjects = [];
  double spawnTimer = 0.0;
  double spawnInterval = 1.0; // Spawns an object every 1 second
  int score = 0;
  int missedCount = 0;
  final int maxMisses = 5;
  bool isGameOver = false;

  final Random random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    initGame();
  }

  void initGame() {
    score = 0;
    missedCount = 0;
    isGameOver = false;
    fallingObjects.clear();
    spawnInterval = 1.0;

    playerSize = Vector2(100, 20);
    playerPosition = Vector2(
      (size.x - playerSize.x) / 2,
      size.y - 80,
    );
  }

  // ---------------------------------------------------------------------------
  // INPUT HANDLING (Touch / Drag Player Left & Right)
  // ---------------------------------------------------------------------------
  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (isGameOver) return;
    playerPosition.x += info.delta.global.x;
    // Clamp player within screen bounds
    playerPosition.x = playerPosition.x.clamp(0.0, size.x - playerSize.x);
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (isGameOver) {
      initGame();
    }
  }

  // ---------------------------------------------------------------------------
  // GAME LOOP UPDATE
  // ---------------------------------------------------------------------------
  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    // Spawner Timer Logic
    spawnTimer += dt;
    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0;
      spawnObject();
    }

    // Update Falling Objects
    for (int i = fallingObjects.length - 1; i >= 0; i--) {
      final obj = fallingObjects[i];
      obj.position.y += obj.speed * dt;

      // AABB Collision Check with Player Paddle
      if (checkCollision(obj)) {
        score += 10;
        fallingObjects.removeAt(i);
        // Gradually increase difficulty
        if (score % 50 == 0 && spawnInterval > 0.4) {
          spawnInterval -= 0.05;
        }
        continue;
      }

      // Check if object fell past the bottom boundary
      if (obj.position.y > size.y) {
        fallingObjects.removeAt(i);
        missedCount++;
        if (missedCount >= maxMisses) {
          isGameOver = true;
        }
      }
    }
  }

  void spawnObject() {
    final double radius = 15;
    final double randomX = random.nextDouble() * (size.x - radius * 2);
    final double randomSpeed = 150 + random.nextDouble() * 150;
    final Color color = Colors.primaries[random.nextInt(Colors.primaries.length)];

    fallingObjects.add(
      FallingObject(
        position: Vector2(randomX, -radius * 2),
        radius: radius,
        speed: randomSpeed,
        color: color,
      ),
    );
  }

  bool checkCollision(FallingObject obj) {
    final Rect playerRect = Rect.fromLTWH(
      playerPosition.x,
      playerPosition.y,
      playerSize.x,
      playerSize.y,
    );
    final Rect objRect = Rect.fromLTWH(
      obj.position.x,
      obj.position.y,
      obj.radius * 2,
      obj.radius * 2,
    );
    return playerRect.overlaps(objRect);
  }

  // ---------------------------------------------------------------------------
  // RENDER GAME CANVAS & SCORE HUD
  // ---------------------------------------------------------------------------
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Draw Player Paddle
    final Paint playerPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(playerPosition.x, playerPosition.y, playerSize.x, playerSize.y),
        const Radius.circular(10),
      ),
      playerPaint,
    );

    // 2. Draw Falling Objects
    for (final obj in fallingObjects) {
      final Paint objPaint = Paint()..color = obj.color;
      canvas.drawCircle(
        Offset(obj.position.x + obj.radius, obj.position.y + obj.radius),
        obj.radius,
        objPaint,
      );
    }

    // 3. Render Score Counter HUD
    final TextPainter scoreText = TextPainter(
      text: TextSpan(
        text: 'Score: $score  |  Misses: $missedCount/$maxMisses',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    scoreText.layout();
    scoreText.paint(canvas, const Offset(20, 50));

    // 4. Render Game Over Screen Overlay
    if (isGameOver) {
      final Paint overlayPaint = Paint()..color = Colors.black.withOpacity(0.75);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), overlayPaint);

      final TextPainter gameOverText = TextPainter(
        text: TextSpan(
          text: 'GAME OVER\nFinal Score: $score\n\nTap to Restart',
          style: const TextStyle(
            color: Color(0xFFEF4444),
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      gameOverText.layout();
      gameOverText.paint(
        canvas,
        Offset((size.x - gameOverText.width) / 2, (size.y - gameOverText.height) / 2),
      );
    }
  }
}

class FallingObject {
  Vector2 position;
  double radius;
  double speed;
  Color color;

  FallingObject({
    required this.position,
    required this.radius,
    required this.speed,
    required this.color,
  });
}