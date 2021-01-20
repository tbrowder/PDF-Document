class Build {
    method build($dist-path) {
        shell "raku --doc=Markdown docs/details.pod > DETAILS.md";
        shell "raku --doc=Markdown lib/PDF/PDF-role.rakumod > DOC-METHODS.md";
    }
}


