package main

// #cgo CFLAGS: -I dart-sdk/include
// #include "stdint.h"
// #include "stdlib.h"
// #include "dart_api_dl.h"
// void dart_PostString(Dart_Port_DL port, int64_t context, const char *message);
// Dart_Port_DL init_ReceivePort();
import "C"
import (
	"encoding/json"
	"fmt"
	"strings"
	"unsafe"

	"github.com/piprate/json-gold/ld"
)

// Initialize Dart SDK and returns native port ID for SendPort used by JsonToRdfSendString function.
//export JsonToRdfInitSendPort
func JsonToRdfInitSendPort(api int64) int64 {
	if C.Dart_InitializeApiDL(unsafe.Pointer(uintptr(api))) != 0 {
		panic("failed to initialize Dart DL C API: version mismatch. " +
			"must update include/ to match Dart SDK version")
	}
	return int64(C.init_ReceivePort())
}

// Used internally to communicate between Dart and Go.
//export JsonToRdfSendString
func JsonToRdfSendString(port C.Dart_Port_DL, context int64, message int64) {
	C.dart_PostString(port, C.int64_t(context), (*C.char)(unsafe.Pointer(uintptr(message))))
}

func sendString(port int64, context int64, message string) {
	ps := C.CString(message)
	defer C.free(unsafe.Pointer(ps))
	C.dart_PostString(C.int64_t(port), C.int64_t(context), ps)
}

func sendErrorString(port int64, context int64, message string) {
	ps := C.CString(message)
	defer C.free(unsafe.Pointer(ps))
	C.dart_PostString(C.int64_t(port), C.int64_t(context|0xffffffff), ps)
}

// manages ID to Channel mapping that is used when receiving string from Dart.
var chanMap = make(map[int64](chan<- string))

// NOTE: Since JsonToRdfMessageHandler is called from C code, it must be exported with a name
// but not intended to be called by user codes.
//export JsonToRdfMessageHandler
func JsonToRdfMessageHandler(port C.Dart_Port_DL, context int64, message *C.char) {
	ch := chanMap[context]
	ch <- C.GoString(message)
	close(ch)
}

type JsonToRdfDownloader struct {
	Port    int64
	Context int64
}

// Call downloader defined on Dart side code.
func (dd JsonToRdfDownloader) sendAndReceive(url string) string {

	// generate new ID for channel maping
	// NOTE: Increment lower 32-bit value; higher 32-bit value must be kept as it is
	dd.Context = (dd.Context & 0x7fffffff00000000) | ((dd.Context + 1) & 0x7fffffff)
	id := dd.Context

	// create a new channel and associate it to the ID generate above
	ch := make(chan string)
	chanMap[id] = ch

	// send the URL with the ID
	sendString(dd.Port, id, url)

	// wait for response from Dart code...
	result := <-ch
	delete(chanMap, id) // We no longer need the channel
	return result
}

func loadDocument(dd *JsonToRdfDownloader, options *ld.JsonLdOptions, u string) (*ld.RemoteDocument, error) {
	var result string
	if strings.HasPrefix(u, "https://") || strings.HasPrefix(u, "http://") {
		if dd != nil {
			result = dd.sendAndReceive(u)
			if result == "" {
				return nil, ld.NewJsonLdError(ld.LoadingDocumentFailed, fmt.Sprintf("error downloading URL: %s", u))
			}
		} else if options != nil {
			return options.DocumentLoader.LoadDocument(u)
		}
	} else {
		result = u
	}

	b := []byte(result)
	var document interface{}
	err := json.Unmarshal(b, &document)
	if err != nil {
		return nil, ld.NewJsonLdError(ld.LoadingDocumentFailed, fmt.Sprintf("error parsing URL: %s", u))
	}

	// FIXME: remoteDoc.ContextURL is not set correctly; should we need it?
	// Reference: https://github.com/piprate/json-gold/blob/master/ld/document_loader.go#L134
	remoteDoc := &ld.RemoteDocument{DocumentURL: u, Document: document}
	return remoteDoc, nil
}

func (dd JsonToRdfDownloader) LoadDocument(u string) (*ld.RemoteDocument, error) {
	return loadDocument(&dd, nil, u)
}

func jsonToRdfNormalized(jsonLd string, port int64, context int64, useExternalDownloader bool) (string, error) {
	options := ld.NewJsonLdOptions("")
	options.Algorithm = "URDNA2015"
	options.Format = "application/n-quads"
	if useExternalDownloader {
		options.DocumentLoader = &JsonToRdfDownloader{Port: port, Context: context}
	}

	doc, err := loadDocument(nil, options, jsonLd)
	if err != nil {
		return "", err
	}

	proc := ld.NewJsonLdProcessor()
	triples, err := proc.Normalize(doc.Document, options)
	if err != nil {
		return "", fmt.Errorf("error when transforming JSON-LD document to RDF: %s", err)
	}

	// convert to RDF
	return triples.(string), nil
}

func jsonToRdfNormalizedAsync(port int64, context int64, jsonLd string, useExternalDownloader bool) {
	defer func() {
		if rec := recover(); rec != nil {
			sendErrorString(port, context, fmt.Sprintf("Recovered from: %v\n", rec))
		}
	}()

	rdf, err := jsonToRdfNormalized(jsonLd, port, context, useExternalDownloader)
	if err != nil {
		sendErrorString(port, context, err.Error())
		return
	}
	sendString(port, context, rdf)
}

// JSON-LD to RDF conversion running asynchronously using Dart's ReceivePort.
//export JsonToRdfNormalizedAsyncPtr
func JsonToRdfNormalizedAsyncPtr(port int64, context int64, jsonLd int64, useExternalDownloader bool) {
	go jsonToRdfNormalizedAsync(port, context, C.GoString((*C.char)(unsafe.Pointer(uintptr(jsonLd)))), useExternalDownloader)
}

func main() {}
