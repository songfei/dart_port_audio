//
// Created by Song Fei on 2021/11/8.
//

#include "audio_input_stream.h"

#include <portaudio.h>
#include <stdlib.h>
#include <stdio.h>
#include <dart_api_dl.h>
#include <memory.h>

static void post_c_object_finish_call_back(void* isolate_callback_data, void* peer) {
    if(peer != NULL) {
        free(peer);
    }
}

static int port_audio_native_recoder_callback( const void *inputBuffer, void *outputBuffer,
                                               unsigned long framesPerBuffer,
                                               const PaStreamCallbackTimeInfo* timeInfo,
                                               PaStreamCallbackFlags statusFlags,
                                               void *userData )
{
    NativeAudioStream* nativeAudioStream = (NativeAudioStream*)userData;

    printf("receive audio data: %lld %ld\n", nativeAudioStream->nativePort,  framesPerBuffer);

    int byteCountPerFrame = 0;
    if(nativeAudioStream->sampleFormat == SAMPLE_FORMAT_INT16) {
        byteCountPerFrame = 2;
    }
    else if(nativeAudioStream->sampleFormat == SAMPLE_FORMAT_FLOAT32) {
        byteCountPerFrame = 4;
    }

    unsigned long bufferLength = framesPerBuffer * byteCountPerFrame;

    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kExternalTypedData;
    dart_object.value.as_external_typed_data.type = Dart_TypedData_kUint8;

    dart_object.value.as_external_typed_data.length = (int)bufferLength;
    dart_object.value.as_external_typed_data.data = (uint8_t*)malloc(bufferLength);
    memcpy(dart_object.value.as_external_typed_data.data, inputBuffer, bufferLength);

    dart_object.value.as_external_typed_data.peer = dart_object.value.as_external_typed_data.data;
    dart_object.value.as_external_typed_data.callback = post_c_object_finish_call_back;

    Dart_PostCObject_DL(nativeAudioStream->nativePort, &dart_object);

    return 0;
}


NativeAudioStream* port_audio_native_create_input_stream(int32_t deviceIndex, int64_t nativePort, int32_t channelCount,
                                                         int32_t sampleFormat, double sampleRate,
                                                         int32_t frameCountPerBuffer) {
    PaStreamParameters parameters;
    memset(&parameters, 0, sizeof(PaStreamParameters));
    parameters.channelCount = channelCount;
    parameters.device = deviceIndex;

    if(sampleFormat == SAMPLE_FORMAT_FLOAT32) {
        parameters.sampleFormat = paFloat32;
    }
    else {
        parameters.sampleFormat = paInt16;
    }

    NativeAudioStream* nativeStream = (NativeAudioStream*)malloc(sizeof(NativeAudioStream));
    memset(nativeStream, 0, sizeof(NativeAudioStream));
    nativeStream->sample_rate = sampleRate;
    nativeStream->sampleFormat = sampleFormat;
    nativeStream->deviceIndex = deviceIndex;
    nativeStream->channelCount = channelCount;
    nativeStream->frameCountPerBuffer = frameCountPerBuffer;
    nativeStream->nativePort = nativePort;

    PaError error = Pa_OpenStream(&nativeStream->stream, &parameters, NULL, sampleRate,frameCountPerBuffer, 0, port_audio_native_recoder_callback, nativeStream );
    if(error == paNoError){
        return nativeStream;
    }

    printf("create stream error: %s\n", Pa_GetErrorText(error));

    free(nativeStream);
    return NULL;
}

void port_audio_native_start_input_stream(NativeAudioStream* nativeStream) {
    if(nativeStream && nativeStream->stream != NULL) {
        PaError error = Pa_StartStream(nativeStream->stream);
        if(error != paNoError) {
            printf("start stream error: %s\n", Pa_GetErrorText(error));
        }
    }
}

void port_audio_native_stop_input_stream(NativeAudioStream* nativeStream) {
    if(nativeStream && nativeStream->stream != NULL) {
        PaError error = Pa_StopStream(nativeStream->stream);
        if(error != paNoError) {
            printf("stop stream error: %s\n", Pa_GetErrorText(error));
        }
    }
}
void port_audio_native_abort_input_stream(NativeAudioStream* nativeStream) {
    if(nativeStream && nativeStream->stream != NULL) {
        Pa_AbortStream(nativeStream->stream);
    }
}

void port_audio_native_destroy_input_stream(NativeAudioStream* nativeStream) {
    if(nativeStream) {
        if(nativeStream->stream != NULL) {
            Pa_CloseStream(nativeStream->stream);
        }
        free(nativeStream);
    }
}