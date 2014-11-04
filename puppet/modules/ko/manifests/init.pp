class ko (
  $packages = {},
  $dotfiles = {},
){
  create_resources(package, $packages)
  #create_resources(ko::dotfile, $dotfiles)
}
