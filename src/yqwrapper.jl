"""
`yq_docker(expr, file)` run yq expression `expr` on `file`.
It has the same function interface as `yq`.

This function requires `docker` available in your environment.

# Example

```
outlier_ratio = 0.5
yq("-i .statind_long.ratio_outlier=\$(outlier_ratio)", "data.yaml")
```
"""
function yq(expr, file)
    uid = readchomp(`id -u`) # similar to `read(cmd, String)` but remove the trailing newline characters.
    gid = readchomp(`id -g`)
    current_path = pwd()
    filepathincontainer = relpath(file, current_path)

    command = ```
    docker run --rm \
      --volume "$(current_path):/workspace" \
      --workdir /workspace \
      --user "$(uid):$(gid)" \
      okatsn/my-util-box:v2025b "yq $expr $filepathincontainer"
    ```
    cmdexceptionhandling(command)
end
