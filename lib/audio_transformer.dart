// The MIT License (MIT)
//
// Copyright (c) 2014 Oliver Sand
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

library audio_transformer;

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:barback/barback.dart';

/// A barback transformer that can be used to transform audio files via FFmpeg.
class AudioTransformer extends Transformer implements LazyTransformer {
  String _codec = 'libvorbis';
  String _outputExtension = '.ogg';
  final _inputExtensions = <String>['.m4a'];

  String get allowedExtensions => _inputExtensions.join(' ');

  /// Create a new instance of a [AudioTransformer].
  AudioTransformer.asPlugin(BarbackSettings settings) {
    if (settings.configuration['codec'] != null) {
      _codec = settings.configuration['codec'];
    }

    if (settings.configuration['output_extension'] != null) {
      _outputExtension = settings.configuration['output_extension'];
    }

    if (settings.configuration['input_extensions'] != null) {
      _inputExtensions.clear();

      if (settings.configuration['input_extensions'] is String) {
        _inputExtensions.add(settings.configuration['input_extensions']);
      } else {
        _inputExtensions.addAll(settings.configuration['input_extensions']);
      }
    }
  }

  Future declareOutputs(DeclaringTransform transform) {
    transform.declareOutput(transform.primaryId.changeExtension(_outputExtension));

    return new Future.value();
  }

  Future apply(Transform transform) {
    final outputId = transform.primaryInput.id.changeExtension(_outputExtension);

    return transform.primaryInput.read()
        .toList()
        .then((i) => i.expand((b) => b).toList(growable: false))
        .then((i) => _convertAudio(i, _codec, transform.primaryInput.id.extension, _outputExtension), onError: (e)
            => transform.logger.error('$e', asset: transform.primaryInput.id))
        .then((o) => transform.addOutput(new Asset.fromBytes(outputId, o)));
  }
}

Future<List<int>> _convertAudio(List<int> bytes, String codec, String inputExtension, String outputExtension) {
  return Directory.systemTemp.createTemp('audio-transformer_').then((tempDir) {
    final inputFileName = path.join(tempDir.path, 'input$inputExtension');
    final outputFileName = path.join(tempDir.path, 'output$outputExtension');
    final arguments = ['-y', '-i', inputFileName, '-acodec', codec, outputFileName];

    Future cleanup() => tempDir.delete(recursive: true);

    return new File(inputFileName).writeAsBytes(bytes)
        .then((_) => Process.run('ffmpeg', arguments))
        .then((r) {
          if (r.exitCode != 0) {
            return cleanup().then((_) => throw new StateError('Error while running ffmpeg:\nExitCode: ${r.exitCode}\n${r.stdout}\n${r.stderr}'));
          }
        })
        .then((_) => new File(outputFileName).readAsBytes())
        .then((o) => cleanup()
            .then((_) => o));
    });
}
