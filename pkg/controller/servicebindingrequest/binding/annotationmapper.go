package binding

import (
	"fmt"
	"strings"

	"k8s.io/client-go/dynamic"
)

type AnnotationToDefinitionMapperOptions interface {
	DefinitionMapperOptions
	GetValue() string
	GetName() string
}

type annotationToDefinitionMapperOptions struct {
	name  string
	value string
}

func (o *annotationToDefinitionMapperOptions) GetName() string  { return o.name }
func (o *annotationToDefinitionMapperOptions) GetValue() string { return o.value }

func NewAnnotationMapperOptions(name, value string) AnnotationToDefinitionMapperOptions {
	return &annotationToDefinitionMapperOptions{name: name, value: value}
}

type AnnotationToDefinitionMapper struct {
	KubeClient dynamic.Interface
}

var _ DefinitionMapper = (*AnnotationToDefinitionMapper)(nil)

type modelKey string

const (
	pathModelKey        modelKey = "path"
	objectTypeModelKey  modelKey = "objectType"
	sourceKeyModelKey   modelKey = "sourceKey"
	sourceValueModelKey modelKey = "sourceValue"
	elementTypeModelKey modelKey = "elementType"
)

const annotationPrefix = "service.binding"

func parseName(name string, defaultName string) (string, error) {
	// bail out in the case the annotation name doesn't start with "service.binding"
	if name != annotationPrefix && !strings.HasPrefix(name, annotationPrefix+"/") {
		return "", fmt.Errorf("can't process annotation with name %q", name)
	}

	outputName := defaultName
	if p := strings.SplitN(name, "/", 2); len(p) > 1 && len(p[1]) > 0 {
		outputName = p[1]
	}
	return outputName, nil
}

func (m *AnnotationToDefinitionMapper) Map(mapperOpts DefinitionMapperOptions) (Definition, error) {
	opts, ok := mapperOpts.(AnnotationToDefinitionMapperOptions)
	if !ok {
		return nil, fmt.Errorf("provide an AnnotationToDefinitionMapperOptions")
	}

	mod, err := newModel(opts.GetValue())
	if err != nil {
		return nil, err
	}

	defaultOutputName := mod.path[len(mod.path)-1]
	outputName, err := parseName(opts.GetName(), defaultOutputName)
	if err != nil {
		return nil, err
	}

	switch {
	case mod.isStringElementType() && mod.isStringObjectType():
		return &stringDefinition{
			outputName: outputName,
			path:       mod.path,
		}, nil

	case mod.isStringElementType() && mod.hasDataField():
		return &stringFromDataFieldDefinition{
			kubeClient: m.KubeClient,
			objectType: mod.objectType,
			outputName: outputName,
			path:       mod.path,
			sourceKey:  mod.sourceKey,
		}, nil

	case mod.isMapElementType() && mod.hasDataField():
		return &mapFromDataFieldDefinition{
			kubeClient: m.KubeClient,
			objectType: mod.objectType,
			outputName: outputName,
			path:       mod.path,
		}, nil

	case mod.isMapElementType() && mod.isStringObjectType():
		return &stringOfMapDefinition{
			outputName: outputName,
			path:       mod.path,
		}, nil

	case mod.isSliceOfMapsElementType():
		return &sliceOfMapsFromPathDefinition{
			outputName:  outputName,
			path:        mod.path,
			sourceKey:   mod.sourceKey,
			sourceValue: mod.sourceValue,
		}, nil

	case mod.isSliceOfStringsElementType():
		return &sliceOfStringsFromPathDefinition{
			outputName:  outputName,
			path:        mod.path,
			sourceValue: mod.sourceValue,
		}, nil
	}

	panic("not implemented")
}