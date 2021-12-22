#include "stdint.h"
#include "stdio.h"
#include "stdlib.h"
#include "dart_api_dl.h"

void dart_PostString(Dart_Port_DL port, int64_t context, const char *message)
{
    Dart_CObject data[2];
    data[0].type = Dart_CObject_kInt64;
    data[0].value.as_int64 = (int64_t)context;
    data[1].type = Dart_CObject_kString;
    data[1].value.as_string = (char *)message;
    Dart_CObject *objs[] = {&data[0], &data[1], &data[1]};
    Dart_CObject arr;
    arr.type = Dart_CObject_kArray;
    arr.value.as_array.length = 2;
    arr.value.as_array.values = objs;
    Dart_PostCObject_DL(port, &arr);
}

void JsonToRdfMessageHandler(Dart_Port_DL port, int64_t context, const char *message);

static void messageHandler(Dart_Port_DL port, Dart_CObject* message)
{
    if (!message || message->type != Dart_CObject_kArray || message->value.as_array.length != 2)
        return; // ignore
    Dart_CObject *pcontext = message->value.as_array.values[0];
    Dart_CObject *pmessage = message->value.as_array.values[1];
    // NOTE: int64 value may be sent with int32 in some special case. I don't know why...
    if ((pcontext->type != Dart_CObject_kInt32 && pcontext->type != Dart_CObject_kInt64) ||
        pmessage->type != Dart_CObject_kString)
    {
        return; // ignore
    }
    int64_t context = pcontext->type == Dart_CObject_kInt32 ? pcontext->value.as_int32 : pcontext->value.as_int64;
    JsonToRdfMessageHandler(port, context, pmessage->value.as_string);
}

Dart_Port_DL init_ReceivePort()
{
    return Dart_NewNativePort_DL("ld2rdf_dart2go", messageHandler, false);
}
