#include <unistd.h>
#include "fletcher_opae.h"
#include <opae/fpga.h>
#include <uuid/uuid.h>

platform_init config = {NULL};
platform_state state;

platform_buffer platform_buffer_map[FLETCHER_PLATFORM_BUFFER_MAP_CAPACITY];
size_t platform_buffer_map_size = 0;

da_t device_buffer_ptr = 0x0;

fstatus_t platformGetName(char *name, size_t size)
{
    size_t len = strlen(FLETCHER_PLATFORM_NAME);
    if (len > size)
    {
        memcpy(name, FLETCHER_PLATFORM_NAME, size - 1);
        name[size - 1] = '\0';
    }
    else
    {
        memcpy(name, FLETCHER_PLATFORM_NAME, len + 1);
    }
    return FLETCHER_STATUS_OK;
}

fstatus_t platformInit(void *arg)
{
    if (arg != NULL)
    {
        config = *(platform_init *)arg;
    }
    else
    {
        fprintf(stderr, "Error missing platform init configuration\n");
        return FLETCHER_STATUS_ERROR;
    }

    if (uuid_parse(config.guid, state.guid) < 0)
    {
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

    if (num_matches < 1)
    {
        fprintf(stderr, "AFU not found\n");
        return FLETCHER_STATUS_ERROR;
    }

    result = fpgaOpen(state.token, &state.handle, 0);
    OPAE_CHECK_RESULT(result, "opening AFU");

    result = fpgaMapMMIO(state.handle, 0, NULL);
    OPAE_CHECK_RESULT(result, "mapping MMIO space");

    return FLETCHER_STATUS_OK;
}

fstatus_t platformTerminate(void *arg)
{
    fpga_result result = FPGA_OK;

    int i;
    for (i = 0; i < platform_buffer_map_size; i++)
    {
        if (platform_buffer_map[i].status == ACTIVE)
        {
            result = fpgaReleaseBuffer(state.handle, platform_buffer_map[i].wsid);
            OPAE_CHECK_RESULT(result, "releasing shared memory buffer");
            platform_buffer_map[i].status = RELEASED;
        }
    }

    if (state.handle != NULL)
    {
        result = fpgaUnmapMMIO(state.handle, 0);
        OPAE_CHECK_RESULT(result, "unmapping MMIO space");

        result = fpgaClose(state.handle);
        OPAE_CHECK_RESULT(result, "closing AFU");
    }

    if (state.token != NULL)
    {
        result = fpgaDestroyToken(&state.token);
        OPAE_CHECK_RESULT(result, "destroying token");
    }

    return FLETCHER_STATUS_OK;
}

fstatus_t platformWriteMMIO(uint64_t offset, uint32_t value)
{
    fpga_result result = FPGA_OK;

    result = fpgaWriteMMIO32(state.handle, 0, offset * sizeof(uint32_t), value);
    OPAE_CHECK_RESULT(result, "writing to MMIO space");

    return FLETCHER_STATUS_OK;
}

fstatus_t platformReadMMIO(uint64_t offset, uint32_t *value)
{
    fpga_result result = FPGA_OK;

    // todo ADD OPAE OFFSET

    result = fpgaReadMMIO32(state.handle, 0, offset * sizeof(uint32_t), value);
    OPAE_CHECK_RESULT(result, "reading from MMIO space");

    return FLETCHER_STATUS_OK;
}

fstatus_t platformCopyHostToDevice(const uint8_t *host_source, da_t device_destination, int64_t size)
{
    return FLETCHER_STATUS_OK;
}

fstatus_t platformCopyDeviceToHost(const da_t device_source, uint8_t *host_destination, int64_t size)
{
    return FLETCHER_STATUS_OK;
}

fstatus_t platformDeviceMalloc(da_t *device_address, int64_t size)
{
    if (platform_buffer_map_size == FLETCHER_PLATFORM_BUFFER_MAP_CAPACITY - 1)
    {
        fprintf(stderr, "Error: platform buffer map capacity reached. Increase `FLETCHER_PLATFORM_BUFFER_MAP_CAPACITY`.");
        return FLETCHER_STATUS_ERROR;
    }

    fpga_result result = FPGA_OK;

    uint64_t wsid;
    uint64_t *buffer_address;
    result = fpgaPrepareBuffer(state.handle, size, (void **)&buffer_address, &wsid, 0);
    OPAE_CHECK_RESULT(result, "preparing shared memory buffer");

    result = fpgaGetIOAddress(state.handle, wsid, device_address);
    OPAE_CHECK_RESULT(result, "getting IO address");

    platform_buffer buf = {wsid, *buffer_address, *device_address, ACTIVE};
    platform_buffer_map[platform_buffer_map_size] = buf;
    platform_buffer_map_size += 1;

    return FLETCHER_STATUS_OK;
}

fstatus_t platformDeviceFree(da_t device_address)
{
    int i;
    for (i = 0; i < platform_buffer_map_size; i++)
    {
        if (platform_buffer_map[i].device_address == device_address)
        {
            if (platform_buffer_map[i].status == RELEASED)
            {
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

fstatus_t platformPrepareHostBuffer(const uint8_t *host_source, da_t *device_destination, int64_t size, int *alloced)
{
    *device_destination = (da_t)host_source;
    *alloced = 0;
    device_buffer_ptr += size;

    return FLETCHER_STATUS_OK;
}

fstatus_t platformCacheHostBuffer(const uint8_t *host_source, da_t *device_destination, int64_t size)
{
    *device_destination = device_buffer_ptr;
    device_buffer_ptr += size;

    return FLETCHER_STATUS_OK;
}
