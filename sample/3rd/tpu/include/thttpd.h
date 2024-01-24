#ifndef __HI_THTTPD_H__
#define __HI_THTTPD_H__

#include <semaphore.h>
#include <sys/prctl.h>
#include "timers.h"

#ifdef __cplusplus
#if __cplusplus
extern "C"{
#endif
#endif /* __cplusplus */

void* thttpd_start_main(void* pvParam);
int set_video_path(const char* path);

#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif /* End of #ifdef __cplusplus */

#endif /* End of #ifndef __HI_THTTPD_H__ */


