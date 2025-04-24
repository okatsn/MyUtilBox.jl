
function cmdexceptionhandling(command)
    @info "Executing... $command"
    try
        run(command)
    catch
        read(command) # return the echoed messages.
    end
end
