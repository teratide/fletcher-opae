#include <unistd.h>
#include <opae/fpga.h>
#include <uuid/uuid.h>

#include "./fletcher_opae.h"

platform_init config = {NULL};
platform_state state;

platform_buffer platform_buffer_map[FLETCHER_PLATFORM_BUFFER_MAP_CAPACITY];
size_t platform_buffer_map_size = 0;

da_t device_buffer_ptr = 0x0;

fstatus_t platformGetName(char *name, size_t size) {
  size_t len = strlen(FLETCHER_PLATFORM_NAME);
  if (len > size) {
    memcpy(name, FLETCHER_PLATFORM_NAME, size - 1);
    name[size - 1] = '\0';
  } else {
    memcpy(name, FLETCHER_PLATFORM_NAME, len + 1);
  }
  return FLETCHER_STATUS_OK;
}

fstatus_t platformInit(void *arg) {
  if (arg != NULL) {
    config = *(platform_init *) arg;
  } else {
    fprintf(stderr, "Error missing platform init configuration\n");
    return FLETCHER_STATUS_ERROR;
  }

  if (uuid_parse(config.guid, state.guid) < 0) {
    fprintf(stderr, "Error parsing AFU guid '%s'\n", config.guid);
    return FLETCHER_STATUS_ERROR;
  }

  platform_buffer_map_size = 0;

  fpga_result result = FPGA_OK;
  fpga_properties filter = NULL;

  result = fpgaGetProperties(NULL, &filter);
  OPAE_CHECK_RESULT(result, "getting properties object");

  result = fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);
  OPAE_CHECK_RESULT(result, "setting object type");

  result = fpgaPropertiesSetGUID(filter, state.guid);
  OPAE_CHECK_RESULT(result, "setting guid");

  uint32_t num_matches;
  result = fpgaEnumerate(&filter, 1, &state.token, 1, &num_matches);
  OPAE_CHECK_RESULT(result, "enumerating AFUs");

  result = fpgaDestroyProperties(&filter);
  OPAE_CHECK_RESULT(result, "destroying properties object");

  if (num_matches < 1) {
    fprintf(stderr, "AFU not found\n");
    return FLETCHER_STATUS_ERROR;
  }

  result = fpgaOpen(state.token, &state.handle, 0);
  OPAE_CHECK_RESULT(result, "opening AFU");

  result = fpgaMapMMIO(state.handle, 0, NULL);
  OPAE_CHECK_RESULT(result, "mapping MMIO space");

  return FLETCHER_STATUS_OK;
}

fstatus_t platformTerminate(void *arg) {
  fpga_result result = FPGA_OK;

  int i;
  for (i = 0; i < platform_buffer_map_size; i++) {
    if (platform_buffer_map[i].status == ACTIVE) {
      result = fpgaReleaseBuffer(state.handle, platform_buffer_map[i].wsid);
      OPAE_CHECK_RESULT(result, "releasing shared memory buffer");
      platform_buffer_map[i].status = RELEASED;
    }
  }

  if (state.handle != NULL) {
    result = fpgaUnmapMMIO(state.handle, 0);
    OPAE_CHECK_RESULT(result, "unmapping MMIO space");

    result = fpgaClose(state.handle);
    OPAE_CHECK_RESULT(result, "closing AFU");
  }

  if (state.token != NULL) {
    result = fpgaDestroyToken(&state.token);
    OPAE_CHECK_RESULT(result, "destroying token");
  }

  return FLETCHER_STATUS_OK;
}

fstatus_t platformWriteMMIO(uint64_t offset, uint32_t value) {
  fpga_result result = FPGA_OK;

  result = fpgaWriteMMIO32(state.handle,
                           0,
                           OPAE_MMIO_OFFSET + offset * sizeof(uint32_t),
                           value);
  OPAE_CHECK_RESULT(result, "writing to MMIO space");

  return FLETCHER_STATUS_OK;
}

fstatus_t platformReadMMIO(uint64_t offset, uint32_t *value) {
  fpga_result result = FPGA_OK;

  result = fpgaReadMMIO32(state.handle,
                          0,
                          OPAE_MMIO_OFFSET + offset * sizeof(uint32_t),
                          value);
  OPAE_CHECK_RESULT(result, "reading from MMIO space");

  return FLETCHER_STATUS_OK;
}

fstatus_t platformCopyHostToDevice(const uint8_t *host_source,
                                   da_t device_destination,
                                   int64_t size) {
  return FLETCHER_STATUS_OK;
}

fstatus_t platformCopyDeviceToHost(const da_t device_source,
                                   uint8_t *host_destination,
                                   int64_t size) {
  return FLETCHER_STATUS_OK;
}

fstatus_t platformDeviceMalloc(da_t *device_address, int64_t size) {
  fprintf(stderr, "Device malloc not supported\n");
  return FLETCHER_STATUS_ERROR;
}

fstatus_t platformDeviceFree(da_t device_address) {
  int i;
  for (i = 0; i < platform_buffer_map_size; i++) {
    if (platform_buffer_map[i].device_address == device_address) {
      if (platform_buffer_map[i].status == RELEASED) {
        fprintf(stderr, "Buffer already released\n");
        return FLETCHER_STATUS_ERROR;
      }

      fpga_result result = FPGA_OK;

      result = fpgaReleaseBuffer(state.handle, platform_buffer_map[i].wsid);
      OPAE_CHECK_RESULT(result, "releasing shared memory buffer");
      platform_buffer_map[i].status = RELEASED;

      return FLETCHER_STATUS_OK;
    }
  }

  fprintf(stderr, "Buffer address not found in platform buffer map\n");
  return FLETCHER_STATUS_ERROR;
}

fstatus_t platformPrepareHostBuffer(const uint8_t *host_source,
                                    da_t *device_destination,
                                    int64_t size,
                                    int *alloced) {
  // Check if there is enough space left in address map
  if (platform_buffer_map_size == FLETCHER_PLATFORM_BUFFER_MAP_CAPACITY - 1) {
    fprintf(stderr,
            "Error: platform buffer map capacity reached. "
            "Increase `FLETCHER_PLATFORM_BUFFER_MAP_CAPACITY`.");
    return FLETCHER_STATUS_ERROR;
  }

  // Get system page size.
  size_t page_size = (size_t) sysconf(_SC_PAGE_SIZE);

  fpga_result result = FPGA_OK;
  uint64_t wsid;
  volatile uint64_t *buffer_address;

  int copy_contents = 0;

  // OPAE requires buffers to be of a size that is a non-zero multiple of the page size.
  // OPAE seems to also require buffers to be page aligned.
  int is_properly_sized = size % page_size == 0;
  int is_page_aligned = ((uint64_t) host_source) % page_size == 0;

  // We need to make sure this is both true before calling fpgaPrepareBuffer.
  if (is_properly_sized && is_page_aligned) {
    // We can re-use the provided buffer,
    // since its size is a non-zero multiple of the page size.
    result = fpgaPrepareBuffer(state.handle,
                               size,
                               (void **) &host_source,
                               &wsid,
                               FPGA_BUF_PREALLOCATED);
    buffer_address = (uint64_t *) host_source;
    // Nothing was allocated.
    *alloced = 0;
  } else {
    size_t new_size = size;
    // Print the respective warning.
    if (!is_properly_sized) {
      fprintf(stderr,
              "WARNING: Host buffer size (%d) is not non-zero multiple of page size (%d) "
              "as required by Intel OPAE. Circumventing by copy to buffer of size (%d)\n",
              size,
              page_size,
              new_size);
      // Calculate new buffer size by rounding up to nearest multiple of page size.
      new_size = (size / page_size + (size % page_size ? 1 : 0)) * page_size;
    }
    if (!is_page_aligned) {
      fprintf(stderr,
              "WARNING: Host buffer address (%p) is not page-aligned "
              "(page size = %d). Circumventing by copy to page-aligned buffer.\n",
              host_source,
              page_size,
              new_size);
    }
    // Circumvent the restriction by allocating a new buffer of appropriate size
    // and alignment.

    // Allocate a new FPGA-accessible buffer, i.e. without FPGA_BUF_PREALLOCATED.
    result = fpgaPrepareBuffer(state.handle,
                               new_size,
                               (void **) &buffer_address,
                               &wsid,
                               0);
    // This buffer was newly allocated, and the caller should free it.
    *alloced = new_size;
    // After checking the result, copy the contents of the original host buffer into the
    // FPGA-accessible host buffer.
    copy_contents = 1;
  }

  // Check the result of the fpgaPrepareBuffer call.
  switch (result) {
    case FPGA_OK: {
      break;
    }
    case FPGA_NO_MEMORY:
      fprintf(stderr,
              "OPAE fpgaPrepareBuffer FPGA_NO_MEMORY: "
              "the requested memory could not be allocated.\n");
      return FLETCHER_STATUS_ERROR;
    case FPGA_INVALID_PARAM:
      fprintf(stderr,
              "OPAE fpgaPrepareBuffer FPGA_INVALID_PARAM: "
              "invalid parameters were provided, or the parameter combination is not "
              "valid. \n");
      fprintf(stderr, "  Page size: %d\n", page_size);
      fprintf(stderr, "  Address: %p\n", host_source);
      fprintf(stderr, "  Size: %ul\n", size);
      fprintf(stderr, "  Platform buffer map size: %d\n", platform_buffer_map_size);
      return FLETCHER_STATUS_ERROR;
    case FPGA_EXCEPTION:
      fprintf(stderr,
              "OPAE fpgaPrepareBuffer FPGA_EXCEPTION: "
              "an internal exception occurred while trying to access the handle.\n");
      return FLETCHER_STATUS_ERROR;
    default:
      fprintf(stderr,
              "OPAE fpgaPrepareBuffer returned unknown error code.\n");
      return FLETCHER_STATUS_ERROR;
  }

  if (copy_contents) {
    // Copy contents to new buffer
    memcpy(buffer_address, host_source, size);
  }

  result = fpgaGetIOAddress(state.handle, wsid, device_destination);
  OPAE_CHECK_RESULT(result, "getting IO address");

  platform_buffer buf = {wsid, *host_source, *device_destination, ACTIVE};
  platform_buffer_map[platform_buffer_map_size] = buf;
  platform_buffer_map_size += 1;

  return FLETCHER_STATUS_OK;
}

fstatus_t platformCacheHostBuffer(const uint8_t *host_source,
                                  da_t *device_destination,
                                  int64_t size) {
  fprintf(stderr, "Cache host buffer not supported\n");
  return FLETCHER_STATUS_ERROR;
}
