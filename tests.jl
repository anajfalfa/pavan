include("Exceptional.jl")

reciprocal(x) =
    #with_restart(:return_zero => ()->0,
    #            :return_value => identity,
    #            :retry_using => reciprocal) do
        x == 0 ?
            pa_error(DivisionByZero()) :
            1/x
#end


struct DivisionByZero <: Exception end

reciprocal(10)
reciprocal(0)

handling(()->reciprocal(0),
    DivisionByZero => (c)->println("I saw a division by zero"))

handling(DivisionByZero =>
        (c)->println("I saw it too")) do
    handling(DivisionByZero =>
            (c)->println("I saw a division by zero")) do
        reciprocal(0)
    end
 end

mystery(n) =
    1 +
    to_escape() do outer
        1 +
        to_escape() do inner
            1 +
            if n == 0
                inner(1)
            elseif n == 1
                outer(1)
            else
                1
            end
        end
    end

mystery(0)
mystery(1)

mystery(2)


to_escape() do exit
    handling(DivisionByZero =>
            (c)->(println("I saw it too"); exit("Done"))) do
        handling(DivisionByZero =>
                (c)->println("I saw a division by zero")) do
            reciprocal(0)
        end
    end
end

to_escape() do exit
    handling(DivisionByZero =>
            (c)->println("I saw it too")) do
        handling(DivisionByZero =>
                (c)->(println("I saw a division by zero");
                    exit("Done"))) do
            reciprocal(0)
        end
    end
end


reciprocal(value) =
    with_restart(:return_zero => ()->0,
            :return_value => identity,
            :retry_using => reciprocal) do
        value == 0 ?
        pa_error(DivisionByZero()) :
            1/value
end


handling(DivisionByZero => (c)->invoke_restart(:return_zero)) do
    reciprocal(0)
end

handling(DivisionByZero =>
        (c)-> for restart in (:return_one, :return_zero, :die_horribly)
                if available_restart(restart)
                    invoke_restart(restart)
                end
            end) do
    reciprocal(0)
end

infinity() =
    with_restart(:just_do_it => ()->1/0) do
        reciprocal(0)
    end

handling(DivisionByZero => (c)->invoke_restart(:return_zero)) do
        infinity()
    end

invoke_restart(:return_value, 1)
invoke_restart(:retry_using, 10)
invoke_restart(:just_do_it)

struct LineEndLimit <: Exception end

print_line(str, line_end=20) =
    let col = 0
        for c in str
            print(c)
            col += 1
            if col == line_end
                signal(LineEndLimit())
                col = 0 
        end
    end
end


to_escape() do exit
    handling(LineEndLimit => (c)->exit()) do
        print_line("Hi, everybody! How are you feeling today?")
    end
end

# signal function
handling(LineEndLimit => (c)->println()) do
    print_line("Hi, everybody! How are you feeling today?")
end

# error instead of signal function
to_escape() do exit
    handling(LineEndLimit => (c)->exit()) do
        print_line("Hi, everybody! How are you feeling today?")
    end
end

handling(LineEndLimit => (c)->println()) do
    print_line("Hi, everybody! How are you feeling today?")
end

#=Hi, everybody! How a
 ERROR: LineEndLimit()
 Stacktrace:
 [1] signal(exception::LineEndLimit, must_be_handled::Bool)
 @ ...
 [2] error(exception::LineEndLimit)
 @ ...
 [3] print_line(str::String, line_end::Int64)
 @ ...
 [4] print_line
 ...
=#
