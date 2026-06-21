package tree_sitter_llml_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_llml "github.com/tree-sitter/tree-sitter-llml/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_llml.Language())
	if language == nil {
		t.Errorf("Error loading Llml grammar")
	}
}
