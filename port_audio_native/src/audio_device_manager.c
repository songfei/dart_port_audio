//
// Created by Song Fei on 2021/10/20.
//

#include "audio_device_manager.h"
#include <dart_api_dl.h>

#include <portaudio.h>
#include <stdlib.h>
#include <string.h>

void port_audio_native_initialize(void* dartApiData) {
    Dart_InitializeApiDL(dartApiData);
    Pa_Initialize();
}
void port_audio_native_terminate() {
    Pa_Terminate();
}

NativeAudioDeviceInfo* port_audio_native_create_native_device_info(int index, const PaDeviceInfo* info) {
    NativeAudioDeviceInfo* native_device_info = (NativeAudioDeviceInfo*)malloc(sizeof(NativeAudioDeviceInfo));
    native_device_info->deviceIndex = index;
    native_device_info->name = info->name;
    native_device_info->maxInputChannelCount = info->maxInputChannels;
    native_device_info->maxOutputChannelCount = info->maxOutputChannels;
    native_device_info->defaultSamplingRate = info->defaultSampleRate;
    return native_device_info;
}

NativeAudioDeviceInfo* port_audio_native_get_default_input_device() {
    PaDeviceIndex index = Pa_GetDefaultInputDevice();
    const PaDeviceInfo* info = Pa_GetDeviceInfo(index);
    return port_audio_native_create_native_device_info(index, info);
}

NativeAudioDeviceInfo* port_audio_native_get_default_output_device() {
    PaDeviceIndex index = Pa_GetDefaultOutputDevice();
    const PaDeviceInfo* info = Pa_GetDeviceInfo(index);
    return port_audio_native_create_native_device_info(index, info);
}

NativeAudioDeviceInfoList* port_audio_native_get_input_device_list() {
    int count = Pa_GetDeviceCount();
    NativeAudioDeviceInfoList* native_info_list = (NativeAudioDeviceInfoList*)malloc(sizeof(NativeAudioDeviceInfoList));
    native_info_list->count = 0;
    native_info_list->list = NULL;

    int index = 0;
    if(count > 0) {
        native_info_list->list = (NativeAudioDeviceInfo**)malloc(sizeof(NativeAudioDeviceInfo*) * count);
        for(int i=0; i<count; i++) {
            const PaDeviceInfo* info = Pa_GetDeviceInfo(i);
            if(info->maxInputChannels > 0) {
                native_info_list->list[index++] = port_audio_native_create_native_device_info(i, info);
            }
        }
        native_info_list->count = index;
    }

    return native_info_list;
}

NativeAudioDeviceInfoList* port_audio_native_get_output_device_list() {
    int count = Pa_GetDeviceCount();
    NativeAudioDeviceInfoList* native_info_list = (NativeAudioDeviceInfoList*)malloc(sizeof(NativeAudioDeviceInfoList));
    native_info_list->count = 0;
    native_info_list->list = NULL;

    int index = 0;
    if(count > 0) {
        native_info_list->list = (NativeAudioDeviceInfo**)malloc(sizeof(NativeAudioDeviceInfo*) * count);
        for(int i=0; i<count; i++) {
            const PaDeviceInfo* info = Pa_GetDeviceInfo(i);
            if(info->maxOutputChannels > 0) {
                native_info_list->list[index++] = port_audio_native_create_native_device_info(i, info);
            }
        }
        native_info_list->count = index;
    }

    return native_info_list;
}

void port_audio_native_destroy_device_info(NativeAudioDeviceInfo* info) {
    if(info) {
        free(info);
    }
}

void port_audio_native_destroy_device_info_list(NativeAudioDeviceInfoList* list) {
    if(list) {
        for(int i=0; i<list->count; i++) {
            port_audio_native_destroy_device_info(list->list[i]);
        }
        free(list);
    }
}
