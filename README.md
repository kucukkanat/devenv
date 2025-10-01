Notes to self:
- Use basher to manage the environment
- Copy the dotfiles

# Build
`docker build -t dev .`

# Run
`docker run --rm -it -p 8080:8080 dev bash -l` . Here `-l` flag is important for the bash to source the `/root/.bash_profile`
Normally bash sources `~/.bashrc`. `.bash_profile` is imported only for login shells. 

# To update the basher link to the package:
```shell
export pkgname="mypackage"
rm -rf $(basher package-path $pkgname)
basher link . $pkgname
```