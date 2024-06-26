import 'dart:async';

class TaskQueue {
  final List<_Task> _queue = [];
  bool _isProcessing = false;

  Future<void> addTask(Future<void> Function() task) {
    final completer = Completer<void>();
    _queue.add(_Task(task, completer));
    _processQueue();
    return completer.future;
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;

    _isProcessing = true;
    while (_queue.isNotEmpty) {
      final currentTask = _queue.removeAt(0);
      try {
        await currentTask.task();
        currentTask.completer.complete();
      } catch (e) {
        currentTask.completer.completeError(e);
      }
    }
    _isProcessing = false;
  }

  void clearQueue() {
    _queue.clear();
  }

  int getLength() {
    return _queue.length;
  }
}

class _Task {
  final Future<void> Function() task;
  final Completer<void> completer;

  _Task(this.task, this.completer);
}
