//
// Created by flysong on 2021/11/12.
//

#ifndef PORT_AUDIO_NATIVE_COMMON_H
#define PORT_AUDIO_NATIVE_COMMON_H

#ifdef WIN32
#define EXPORT_API __declspec(dllexport)

#else
#define EXPORT_API

#endif

#endif //PORT_AUDIO_NATIVE_COMMON_H
