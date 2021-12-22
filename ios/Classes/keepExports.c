#include "libld2rdf.h"

__attribute__((visibility("default"))) __attribute__((used))
void* keep_entry_points()
{
    static void* table[] = {
        (void*)JsonToRdfInitSendPort,
        (void*)JsonToRdfSendString,
        (void*)JsonToRdfMessageHandler,
        (void*)JsonToRdfNormalizedAsyncPtr,
        0
    };
    return table;
}
