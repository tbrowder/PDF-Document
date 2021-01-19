unit module PDF::Roles;

role PDF-role is export {
    use PDF::Lite;
}

role AFM-role is export {
    use Font::AFM;
}
