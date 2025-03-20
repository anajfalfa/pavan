include("Exceptional.jl")

using .MyFunctions  # Import the module (the dot `.` is needed for local files)

say_hello()  # Now we can call the function



#= or 

import .MyFunctions: say_hello  # Import only `say_hello`

say_hello()  # Works the same way
=#

reciprocal(x) =
    x == 0 ?
        pa_error(DivisionByZero()) :
        1/x

reciprocal(10)

reciprocal(0)

function test_pa_error()
    # Uncomment one of these lines to test
    # pa_error(DivisionByZero())  # Throws DivisionByZero exception
    pa_error(LineEndLimit())  # Throws LineEndLimit exception
end



# Try-catch block to handle exceptions
try
    test_pa_error()  # Call the function that triggers an error
catch e
    println("Caught an error: ", e)
end



#=fun to_escape(func) {
  let res = null
  let exit = (args...) -> res = args
  let userRes = func(exit)
  return if (res!=null) res else userRes 
}
    =#
# non local --> throw

version2
function to_escape(func)
    let exit = (args...) -> throw(myEscape(args, exit)) # (args=args, exit=exit)
        try
            return func(exit) 
        catch e
            if e isa myEscape && e.exit === exit
                return length(e.args) == 1 ? e.args[1] : e.args
            else
                rethrow()  # Repropaga exceções inesperadas
            end
        end
    end
end 