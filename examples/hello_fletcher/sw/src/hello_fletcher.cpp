#include <arrow/api.h>
#include <fletcher/api.h>

#include <memory>
#include <iostream>

int main(int argc, char **argv)
{
    fletcher::Status status;
    std::shared_ptr<fletcher::Platform> platform;

    status = fletcher::Platform::Make("opae-ase", &platform, false);
    if (!status.ok())
    {
        std::cerr << "Could not create Fletcher platform." << std::endl;
        std::cerr << status.message << std::endl;
        return -1;
    }

    // OPAE hello_afu example
    const char *guid = "bcdf53bc-4ffb-4933-bf7c-4a7e1602c6e2";

    platform->init_data = &guid;
    status = platform->Init();
    if (!status.ok())
    {
        std::cerr << "Could not initialize platform." << std::endl;
        std::cerr << status.message << std::endl;
        return -1;
    }

    std::shared_ptr<fletcher::Context> context;
    status = fletcher::Context::Make(&context, platform);
    if (!status.ok())
    {
        std::cerr << "Could not create Fletcher context." << std::endl;
        return -1;
    }

    // generate a recordbatch
    arrow::BooleanBuilder builder;
    builder.Append(true);
    builder.Append(false);
    std::shared_ptr<arrow::Array> array;
    builder.Finish(&array);

    std::shared_ptr<arrow::RecordBatch> rb = arrow::RecordBatch::Make(arrow::schema({arrow::field("a", arrow::boolean())}), 2, {array});
    status = context->QueueRecordBatch(rb);
    if (!status.ok())
    {
        std::cerr << "Could not add recordbatch." << std::endl;
        return -1;
    }

    status = context->Enable();
    if (!status.ok())
    {
        std::cerr << "Could not enable the context." << std::endl;
        return -1;
    }

    fletcher::Kernel kernel(context);
    uint32_t st = 1;
    kernel.GetStatus(&st);
    std::cerr << std::hex << st << std::endl;

    return 0;
}

// // Create a kernel based on the context.
// fletcher::Kernel kernel(context);

// // Start the kernel.
// status = kernel.Start();

// if (!status.ok())
// {
//     std::cerr << "Could not start the kernel." << std::endl;
//     return -1;
// }

// // Wait for the kernel to finish.
// status = kernel.PollUntilDone();

// if (!status.ok())
// {
//     std::cerr << "Something went wrong waiting for the kernel to finish." << std::endl;
//     return -1;
// }

// // Obtain the return value.
// uint32_t return_value_0;
// uint32_t return_value_1;
// status = kernel.GetReturn(&return_value_0, &return_value_1);

// if (!status.ok())
// {
//     std::cerr << "Could not obtain the return value." << std::endl;
//     return -1;
// }

// // Print the return value.
// std::cout << *reinterpret_cast<int32_t *>(&return_value_0) << std::endl;

//     return 0;
// }