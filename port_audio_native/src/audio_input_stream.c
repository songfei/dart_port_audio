//
// Created by Song Fei on 2021/11/8.
//

#include "audio_input_stream.h"
#include "audio_device_manager.h"

#include <portaudio.h>
#include <stdlib.h>
#include <stdio.h>
#include <dart_api_dl.h>
#include <memory.h>
#include <string.h>


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

//    printf("receive audio data: %lld %ld\n", nativeAudioStream->nativePort,  framesPerBuffer);

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

typedef struct {
    NativeAudioStream* nativeAudioStream;
    const char* callbackId;
} PortAudioNativeCreateInputStreamArgs;

void* port_audio_native_create_input_stream_run(void* args) {
    PortAudioNativeCreateInputStreamArgs* structArgs = (PortAudioNativeCreateInputStreamArgs*)args;

    pthread_mutex_lock(&call_function_mutex);

    PaStreamParameters parameters;
    memset(&parameters, 0, sizeof(PaStreamParameters));
    parameters.channelCount = structArgs->nativeAudioStream->channelCount;
    parameters.device = structArgs->nativeAudioStream->deviceIndex;

    if(structArgs->nativeAudioStream->sampleFormat == SAMPLE_FORMAT_FLOAT32) {
        parameters.sampleFormat = paFloat32;
    }
    else {
        parameters.sampleFormat = paInt16;
    }

    NativeAudioStream* nativeStream = structArgs->nativeAudioStream;

    PaError error = Pa_OpenStream(&nativeStream->stream, &parameters, NULL, nativeStream->sampleRate, nativeStream->frameCountPerBuffer, 0, port_audio_native_recoder_callback, nativeStream );
    if(error == paNoError){

    }

    printf("create stream error: %s\n", Pa_GetErrorText(error));
    free(nativeStream);

    pthread_mutex_unlock(&call_function_mutex);

    return NULL;
}



void port_audio_native_create_input_stream(int32_t deviceIndex, int64_t nativePort, int32_t channelCount,
                                                         int32_t sampleFormat, double sampleRate,
                                                         int32_t frameCountPerBuffer, const char* callbackId) {

    NativeAudioStream* nativeStream = (NativeAudioStream*)malloc(sizeof(NativeAudioStream));
    memset(nativeStream, 0, sizeof(NativeAudioStream));
    nativeStream->sampleRate = sampleRate;
    nativeStream->sampleFormat = sampleFormat;
    nativeStream->deviceIndex = deviceIndex;
    nativeStream->channelCount = channelCount;
    nativeStream->frameCountPerBuffer = frameCountPerBuffer;
    nativeStream->nativePort = nativePort;

    PortAudioNativeCreateInputStreamArgs* args = (PortAudioNativeCreateInputStreamArgs* )malloc(sizeof(PortAudioNativeCreateInputStreamArgs));
    memset(args, 0, sizeof(PortAudioNativeCreateInputStreamArgs));
    args->nativeAudioStream = nativeStream;
    args->callbackId = _strdup(callbackId);

    pthread_t thread;
    pthread_create(&thread, NULL, port_audio_native_create_input_stream_run, (void*)args);
}

void port_audio_native_start_input_stream(NativeAudioStream* nativeStream, const char* callbackId) {
    if(nativeStream && nativeStream->stream != NULL) {
        PaError error = Pa_StartStream(nativeStream->stream);
        if(error != paNoError) {
            printf("start stream error: %s\n", Pa_GetErrorText(error));
        }
    }
}

void port_audio_native_stop_input_stream(NativeAudioStream* nativeStream, const char* callbackId) {
    if(nativeStream && nativeStream->stream != NULL) {
        PaError error = Pa_StopStream(nativeStream->stream);
        if(error != paNoError) {
            printf("stop stream error: %s\n", Pa_GetErrorText(error));
        }
    }
}
void port_audio_native_abort_input_stream(NativeAudioStream* nativeStream, const char* callbackId) {
    if(nativeStream && nativeStream->stream != NULL) {
        PaError error = Pa_AbortStream(nativeStream->stream);
        if(error != paNoError) {
            printf("abort stream error: %s\n", Pa_GetErrorText(error));
        }
    }
}

void port_audio_native_destroy_input_stream(NativeAudioStream* nativeStream) {
    if(nativeStream) {
        if(nativeStream->stream != NULL) {
            PaError error = Pa_CloseStream(nativeStream->stream);
            if(error != paNoError) {
                printf("close stream error: %s\n", Pa_GetErrorText(error));
            }
        }
        free(nativeStream);
    }
}