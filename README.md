audio_transformer
=================

A Pub tranformer for converting audio files using [FFmpeg](http://www.ffmpeg.org/). 
As browser vendors still don't have agreed on one audio format for the usage in 
browsers  (see [MDN](https://developer.mozilla.org/en-US/docs/HTML/Supported_media_formats#Browser_compatibility)), 
you have to support multiple formats during the developent of your web 
application (for example a game). This Pub transformer creates the formats your 
require during your build.

### Prerequisites

This tranformer relies on FFmpeg, you need to install it first on your system. 
The installation depends on your operating system, see the 
[FFmpeg homepage](http://www.ffmpeg.org/) for download and install instructions.

*Make sure that FFmpeg is accessible via PATH!*

### Configuration

The next step is configurating the transformer for your package. Add it to the 
```dependencies``` and ```transformers``` sections of your ```pubspec.yaml``` 
and add the desired FFmpeg options. The following example converts ```m4a``` 
files to ```ogg```:

```
transformers:
   - audio_transformer:
       codec: libvorbis
       input_extensions: '.m4a'
       output_extension: '.ogg'
```

The next example converts a ```m4a``` file to ```webm```:

```
transformers:
   - audio_transformer:
       codec: libvorbis
       input_extensions: '.m4a'
       output_extension: '.webm'
```

You can add multiple instances of the transformer to your ```pubspec.yaml``` if 
you need the files in different output formats.

#### codec

The codec parameter that is passed to FFmpeg. See the FFmpeg manpage for details.

#### input_extensions

A input extension or a list of input extensions that should be processed.

#### output_extension

The extension of the format to output.

### License

```
The MIT License (MIT)

Copyright (c) 2014 Oliver Sand

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```