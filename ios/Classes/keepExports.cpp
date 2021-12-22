#include "libld2rdf.h"

extern "C" __attribute__((visibility("default"))) __attribute__((used))
void* keep_entry_points()
{
    static void* table[] = {
        reinterpret_cast<void*>(JsonToRdfInitSendPort),
        reinterpret_cast<void*>(JsonToRdfSendString),
        reinterpret_cast<void*>(JsonToRdfMessageHandler),
        reinterpret_cast<void*>(JsonToRdfNormalizedAsyncPtr),
        nullptr
    };
    return table;
}
