

# using YAML
# d = Dict(
#     "name" => "John",
#     "age" => 13,
# )
# open("test.yaml", "w") do x
#     YAML.write(x, d)
# end

# using MyUtilBox
# MyUtilBox.yq("-i \'.data.age=13\'", "test.yaml")

# file = "test.yaml"
# expr = "-i \'.data.age=13\'"
# uid = readchomp(`id -u`) # similar to `read(cmd, String)` but remove the trailing newline characters.
# gid = readchomp(`id -g`)
# current_path = pwd()
# filepathincontainer = relpath(file, current_path)

# command = ```
# docker run --rm \
#   --volume "$(current_path):/workspace" \
#   --workdir /workspace \
#   --user "$(uid):$(gid)" \
#   okatsn/my-util-box:v2025b "yq $expr $filepathincontainer"
# ```
# run(command)
