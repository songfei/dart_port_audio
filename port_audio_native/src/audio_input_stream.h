//
// Created by Song Fei on 2021/11/8.
//

#ifndef PORT_AUDIO_NATIVE_AUDIO_RECORDER_H
#define PORT_AUDIO_NATIVE_AUDIO_RECORDER_H

#include <stdint.h>
#include "common.h"

#define SAMPLE_FORMAT_INT16     0
#define SAMPLE_FORMAT_FLOAT32   1

typedef struct  {
    void* stream;

    int32_t deviceIndex;
    int64_t nativePort;
    int32_t channelCount;

    int32_t sampleFormat;
    int32_t frameCountPerBuffer;
    double sampleRate;
} NativeAudioStream;

EXPORT_API void port_audio_native_create_input_stream(int32_t deviceIndex, int64_t nativePort, int32_t channelCount,
                                                                    int32_t sampleFormat, double sampleRate,
                                                                    int32_t frameCountPerBuffer, const char* callbackId);

EXPORT_API void port_audio_native_start_input_stream(NativeAudioStream* nativeStream, const char* callbackId);
EXPORT_API void port_audio_native_stop_input_stream(NativeAudioStream* nativeStream, const char* callbackId);
EXPORT_API void port_audio_native_abort_input_stream(NativeAudioStream* nativeStream, const char* callbackId);

EXPORT_API void port_audio_native_destroy_input_stream(NativeAudioStream* nativeStream);

#endif //PORT_AUDIO_NATIVE_AUDIO_RECORDER_H
