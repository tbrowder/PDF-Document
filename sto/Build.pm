class Build {
    method build($dist-path) {
        shell "raku --doc=Markdown docs/details.pod > DETAILS.md";
    }
}


