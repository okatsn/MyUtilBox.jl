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


# CHECKPOINT: Gemini suggest me convert `file` path with `abspath`, and mount the directory of the `file` to my-util-box's `/workspace` for a more robust path handling. Here is the critical code:
#
# ```
# # --- Improved Path Handling ---
# abs_target_file = abspath(file)
# host_mount_dir = dirname(abs_target_file)
# file_inside_container = basename(abs_target_file)
# # -----------------------------

# # Construct the command using Cmd for better safety with arguments
# # Note: We put the actual command for the container ("yq ...") as the last args to docker run
# docker_cmd = `docker run --rm --interactive` # Use -i if yq might need stdin? Usually not for file processing.
# docker_cmd = `$docker_cmd --volume $(host_mount_dir):/workspace`
# docker_cmd = `$docker_cmd --workdir /workspace`
# docker_cmd = `$docker_cmd --user $(uid):$(gid)`
# docker_cmd = `$docker_cmd okatsn/my-util-box:v2025b`
# ```
#
# For more details, see https://gemini.google.com/app/228cfcbbe2cc5422
#
# CHECKPOINT: I'm considering give up this package:
# - (in lab's PC) I currently encountered an issue that 1. `MyUtilBox.yq` works well in the workspace of ProjectTIPTree, but do not work (Error: no such file or director) on the workspace of the package MyUtilBox. Therefore, I cannot establish a test for `MyUtilBox.yq` even in local machine.
# - (in my notebook) Previously it constantly stuck on the communication issue between the main container and dind; after remove dind image and rebuild the main container, now `MyUtilBox.yq` returns `ProcessSignaled(11)` where when I run manually the shell script inside `MyUtilBox.yq`, it always returns "Segmentation fault".
# - It appears that the development of MyUtilBox requires intensive tests ACROSS MyUtilBox.jl and my-workspace/my-util-box. The current problem suggest every time the julia test of MyUtilBox failed, I may very likely needs more than one environment for figure out what's going on, and have to separately execute the wrapped shell script in bash.
# - The cost of having such a julia package is significant. Please consider the maintainability first (requires a good framework for testing the julia part and the shell script part separately in a couple of dev containers) before you dig in further. Since the price is significant, it must need a very good reason to develop and maintain such a package. It is expected to be (much) more painful than developing and maintaining `OkPkgTemplate.jl`.
