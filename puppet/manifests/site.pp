node 'default' {
    if undef != hiera('classes', undef) {
        hiera_include('classes')
    }
}
