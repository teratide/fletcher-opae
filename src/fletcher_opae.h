#include <stddef.h>
#include <opae/fpga.h>
#include "fletcher/fletcher.h"

#ifdef ASE
#define FLETCHER_PLATFORM_NAME "opae-ase"
#else
#define FLETCHER_PLATFORM_NAME "opae"
#endif

#define OPAE_MMIO_OFFSET 64

#define FLETCHER_PLATFORM_BUFFER_MAP_CAPACITY 4096

#define OPAE_CHECK_RESULT(result, label)                              \
    if (result != FPGA_OK)                                            \
    {                                                                 \
        fprintf(stderr, "Error %s: %s\n", label, fpgaErrStr(result)); \
        return FLETCHER_STATUS_ERROR;                                 \
    }

typedef struct {
  char *guid;
} platform_init;

typedef struct {
  fpga_token token;
  fpga_handle handle;
  fpga_guid guid;
} platform_state;

typedef enum {
  ACTIVE,
  RELEASED
} buffer_status;

typedef struct {
  uint64_t wsid;
  uint64_t buffer_address;
  da_t device_address;
  buffer_status status;
} platform_buffer;

fstatus_t platformGetName(char *name, size_t size);

fstatus_t platformInit(void *arg);

fstatus_t platformWriteMMIO(uint64_t offset, uint32_t value);

fstatus_t platformReadMMIO(uint64_t offset, uint32_t *value);

fstatus_t platformCopyHostToDevice(const uint8_t *host_source,
                                   da_t device_destination,
                                   int64_t size);

fstatus_t platformCopyDeviceToHost(const da_t device_source,
                                   uint8_t *host_destination,
                                   int64_t size);

fstatus_t platformDeviceMalloc(da_t *device_address, int64_t size);

fstatus_t platformDeviceFree(da_t device_address);

fstatus_t platformPrepareHostBuffer(const uint8_t *host_source,
                                    da_t *device_destination,
                                    int64_t size,
                                    int *alloced);

fstatus_t platformCacheHostBuffer(const uint8_t *host_source,
                                  da_t *device_destination,
                                  int64_t size);

fstatus_t platformTerminate(void *arg);
